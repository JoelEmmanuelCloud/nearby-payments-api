package deposit_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/utils"
)

var (
	testPool  *pgxpool.Pool
	testStore *deposit.Store
)

func TestMain(m *testing.M) {
	_ = godotenv.Load("../../../.env")
	ctx := context.Background()

	var err error
	testPool, err = dbpkg.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		panic("db pool: " + err.Error())
	}
	defer testPool.Close()

	testStore = deposit.NewStore(testPool)

	os.Exit(m.Run())
}

func insertTestUser(t *testing.T) string {
	t.Helper()
	userID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO users (id, status, created_at, updated_at) VALUES ($1, 'active', $2, $2)`,
		userID, utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert test user: %v", err)
	}
	t.Cleanup(func() {
		testPool.Exec(context.Background(), `DELETE FROM deposits WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM deposit_routes WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM bridge_links WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM users WHERE id = $1`, userID)
	})
	return userID
}

func newTestHandler() *deposit.Handler {
	svc := deposit.NewService(deposit.ServiceDeps{
		Store:        testStore,
		BridgeClient: nil,
		AuthStore:    nil,
	})
	return deposit.NewHandler(svc)
}

func testSessionContext(userID string) *auth.SessionContext {
	return &auth.SessionContext{
		User:      &auth.User{ID: userID, Status: "active"},
		Device:    &auth.Device{ID: utils.NewID(), Status: "active"},
		Session:   &auth.Session{ID: utils.NewID()},
		Integrity: &auth.DeviceIntegrityRecord{},
	}
}

func TestGetOptions_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/deposit/options", nil)
	rr := httptest.NewRecorder()
	handler.GetOptions(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestGetDeposits_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/deposit/history", nil)
	rr := httptest.NewRecorder()
	handler.GetDeposits(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestGetDeposit_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/deposit/some-id", nil)
	rr := httptest.NewRecorder()
	handler.GetDeposit(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestGetDeposits_EmptyForNewUser(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	req := httptest.NewRequest(http.MethodGet, "/v1/deposit/history", nil)
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.GetDeposits(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", rr.Code, rr.Body.String())
	}
}

func TestStoreGetDepositsByUserID_AfterUpsert(t *testing.T) {
	userID := insertTestUser(t)

	routeID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		  source_address, destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1,$2,'bridge',$3,'liquidation_address','solana','usdc','solana-addr','sui','usdc','hash','active',$4,$4)`,
		routeID, userID, utils.NewID(), utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert deposit route: %v", err)
	}

	err = testStore.UpsertDeposit(context.Background(), &deposit.Deposit{
		ID:                utils.NewID(),
		UserID:            userID,
		RouteID:           routeID,
		Provider:          "bridge",
		ProviderDepositID: utils.NewID(),
		Kind:              "liquidation_address",
		Status:            "payment_processed",
		Amount:            "1000000",
		Currency:          "usdc",
		TxHash:            "0xdeadbeef",
		CreatedAt:         utils.NowUnix(),
		UpdatedAt:         utils.NowUnix(),
	})
	if err != nil {
		t.Fatalf("upsert deposit: %v", err)
	}

	deposits, err := testStore.GetDepositsByUserID(context.Background(), userID, 20, 0)
	if err != nil {
		t.Fatalf("get deposits: %v", err)
	}
	if len(deposits) != 1 {
		t.Fatalf("expected 1 deposit, got %d", len(deposits))
	}
	if deposits[0].Status != "payment_processed" {
		t.Fatalf("expected status payment_processed, got %s", deposits[0].Status)
	}
	if deposits[0].TxHash != "0xdeadbeef" {
		t.Fatalf("expected tx hash 0xdeadbeef, got %s", deposits[0].TxHash)
	}
}

func TestStoreUpsertDeposit_StatusUpdate(t *testing.T) {
	userID := insertTestUser(t)

	routeID := utils.NewID()
	providerDepositID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		  source_address, destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1,$2,'bridge',$3,'virtual_account','fiat','usd','','sui','usdc','hash','active',$4,$4)`,
		routeID, userID, utils.NewID(), utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert deposit route: %v", err)
	}

	base := &deposit.Deposit{
		ID:                utils.NewID(),
		UserID:            userID,
		RouteID:           routeID,
		Provider:          "bridge",
		ProviderDepositID: providerDepositID,
		Kind:              "virtual_account",
		Status:            "funds_received",
		Amount:            "500000",
		Currency:          "usd",
		TxHash:            "",
		CreatedAt:         utils.NowUnix(),
		UpdatedAt:         utils.NowUnix(),
	}
	if err := testStore.UpsertDeposit(context.Background(), base); err != nil {
		t.Fatalf("first upsert: %v", err)
	}

	updated := *base
	updated.Status = "payment_processed"
	updated.TxHash = "0xcafe"
	if err := testStore.UpsertDeposit(context.Background(), &updated); err != nil {
		t.Fatalf("second upsert: %v", err)
	}

	got, err := testStore.GetDepositByID(context.Background(), base.ID, userID)
	if err != nil {
		t.Fatalf("get deposit: %v", err)
	}
	if got == nil {
		t.Fatal("expected deposit, got nil")
	}
	if got.Status != "payment_processed" {
		t.Fatalf("expected status payment_processed, got %s", got.Status)
	}
	if got.TxHash != "0xcafe" {
		t.Fatalf("expected txHash 0xcafe, got %s", got.TxHash)
	}
}

func TestGetDeposit_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	rctx := chi.NewRouteContext()
	rctx.URLParams.Add("id", utils.NewID())

	req := httptest.NewRequest(http.MethodGet, "/v1/deposit/some-id", nil)
	req = req.WithContext(context.WithValue(
		auth.WithSession(req.Context(), testSessionContext(userID)),
		chi.RouteCtxKey, rctx,
	))
	rr := httptest.NewRecorder()
	handler.GetDeposit(rr, req)

	if rr.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d: %s", rr.Code, rr.Body.String())
	}
}

func TestStoreGetDepositByID_WrongUser(t *testing.T) {
	userID := insertTestUser(t)
	otherUserID := insertTestUser(t)

	routeID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		  source_address, destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1,$2,'bridge',$3,'liquidation_address','solana','usdc','addr','sui','usdc','hash','active',$4,$4)`,
		routeID, userID, utils.NewID(), utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert deposit route: %v", err)
	}

	depositID := utils.NewID()
	err = testStore.UpsertDeposit(context.Background(), &deposit.Deposit{
		ID:                depositID,
		UserID:            userID,
		RouteID:           routeID,
		Provider:          "bridge",
		ProviderDepositID: utils.NewID(),
		Kind:              "liquidation_address",
		Status:            "payment_processed",
		Amount:            "1000",
		Currency:          "usdc",
		CreatedAt:         utils.NowUnix(),
		UpdatedAt:         utils.NowUnix(),
	})
	if err != nil {
		t.Fatalf("upsert deposit: %v", err)
	}

	got, err := testStore.GetDepositByID(context.Background(), depositID, otherUserID)
	if err != nil {
		t.Fatalf("get deposit: %v", err)
	}
	if got != nil {
		t.Fatal("expected nil for wrong user, got deposit")
	}
}
