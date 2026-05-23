package payment_test

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/payment"
	"github.com/vaariance/nearby/internal/utils"
)

const testRecipientAddress = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

var (
	testPool  *pgxpool.Pool
	testStore *payment.Store
	testSvc   *payment.Service
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

	testStore = payment.NewStore(testPool)
	testSvc = payment.NewService(payment.ServiceDeps{
		Store: testStore,
	})

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
		testPool.Exec(context.Background(), `DELETE FROM payments WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM payment_intents WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM users WHERE id = $1`, userID)
	})
	return userID
}

func TestCreateIntent_UnsupportedAsset(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "BTC",
		AmountAtomic:     "1000000",
		IdempotencyKey:   utils.NewID(),
	})
	if !errors.Is(err, payment.ErrAssetUnsupported) {
		t.Fatalf("expected ErrAssetUnsupported, got %v", err)
	}
}

func TestCreateIntent_InvalidAmount(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "0",
		IdempotencyKey:   utils.NewID(),
	})
	if !errors.Is(err, payment.ErrInvalidAmount) {
		t.Fatalf("expected ErrInvalidAmount, got %v", err)
	}
}

func TestCreateIntent_InvalidAddress(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: "not-a-valid-address",
		Asset:            "USDsui",
		AmountAtomic:     "1000000",
		IdempotencyKey:   utils.NewID(),
	})
	if !errors.Is(err, payment.ErrInvalidAddress) {
		t.Fatalf("expected ErrInvalidAddress, got %v", err)
	}
}

func TestCreateIntent_Valid(t *testing.T) {
	userID := insertTestUser(t)
	resp, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "1000000",
		IdempotencyKey:   utils.NewID(),
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.IntentID == "" {
		t.Fatal("expected non-empty intent ID")
	}
	if resp.Status != "pending" {
		t.Fatalf("expected status pending, got %s", resp.Status)
	}
	if resp.Asset != "USDsui" {
		t.Fatalf("expected asset USDsui, got %s", resp.Asset)
	}
}

func TestCreateIntent_Idempotency(t *testing.T) {
	userID := insertTestUser(t)
	key := utils.NewID()
	req := payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "1000000",
		IdempotencyKey:   key,
	}

	first, err := testSvc.CreateIntent(context.Background(), userID, req)
	if err != nil {
		t.Fatalf("first create: %v", err)
	}

	second, err := testSvc.CreateIntent(context.Background(), userID, req)
	if err != nil {
		t.Fatalf("second create: %v", err)
	}

	if first.IntentID != second.IntentID {
		t.Fatalf("expected same intent ID, got %s and %s", first.IntentID, second.IntentID)
	}
}

func TestGetIntent_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.GetIntent(context.Background(), utils.NewID(), userID)
	if !errors.Is(err, payment.ErrIntentNotFound) {
		t.Fatalf("expected ErrIntentNotFound, got %v", err)
	}
}

func TestGetIntent_WrongUser(t *testing.T) {
	userID := insertTestUser(t)
	otherUserID := insertTestUser(t)

	resp, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "500000",
		IdempotencyKey:   utils.NewID(),
	})
	if err != nil {
		t.Fatalf("create intent: %v", err)
	}

	_, err = testSvc.GetIntent(context.Background(), resp.IntentID, otherUserID)
	if !errors.Is(err, payment.ErrIntentNotFound) {
		t.Fatalf("expected ErrIntentNotFound for wrong user, got %v", err)
	}
}

func TestGetIntent_Valid(t *testing.T) {
	userID := insertTestUser(t)
	created, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "750000",
		IdempotencyKey:   utils.NewID(),
	})
	if err != nil {
		t.Fatalf("create intent: %v", err)
	}

	got, err := testSvc.GetIntent(context.Background(), created.IntentID, userID)
	if err != nil {
		t.Fatalf("get intent: %v", err)
	}
	if got.IntentID != created.IntentID {
		t.Fatalf("expected intent ID %s, got %s", created.IntentID, got.IntentID)
	}
	if got.Status != "pending" {
		t.Fatalf("expected status pending, got %s", got.Status)
	}
	if got.AmountAtomic != "750000" {
		t.Fatalf("expected amount 750000, got %s", got.AmountAtomic)
	}
}

func TestCancelIntent_Valid(t *testing.T) {
	userID := insertTestUser(t)
	created, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "100000",
		IdempotencyKey:   utils.NewID(),
	})
	if err != nil {
		t.Fatalf("create intent: %v", err)
	}

	if err := testSvc.CancelIntent(context.Background(), created.IntentID, userID); err != nil {
		t.Fatalf("cancel intent: %v", err)
	}

	got, err := testSvc.GetIntent(context.Background(), created.IntentID, userID)
	if err != nil {
		t.Fatalf("get intent after cancel: %v", err)
	}
	if got.Status != "cancelled" {
		t.Fatalf("expected status cancelled, got %s", got.Status)
	}
}

func TestCancelIntent_NotPending(t *testing.T) {
	userID := insertTestUser(t)
	created, err := testSvc.CreateIntent(context.Background(), userID, payment.CreateIntentRequest{
		RecipientAddress: testRecipientAddress,
		Asset:            "USDsui",
		AmountAtomic:     "200000",
		IdempotencyKey:   utils.NewID(),
	})
	if err != nil {
		t.Fatalf("create intent: %v", err)
	}

	if err := testSvc.CancelIntent(context.Background(), created.IntentID, userID); err != nil {
		t.Fatalf("first cancel: %v", err)
	}

	err = testSvc.CancelIntent(context.Background(), created.IntentID, userID)
	if !errors.Is(err, payment.ErrIntentNotPending) {
		t.Fatalf("expected ErrIntentNotPending on second cancel, got %v", err)
	}
}

func TestCancelIntent_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	err := testSvc.CancelIntent(context.Background(), utils.NewID(), userID)
	if !errors.Is(err, payment.ErrIntentNotFound) {
		t.Fatalf("expected ErrIntentNotFound, got %v", err)
	}
}

func TestGetPayment_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.GetPayment(context.Background(), utils.NewID(), userID)
	if !errors.Is(err, payment.ErrPaymentNotFound) {
		t.Fatalf("expected ErrPaymentNotFound, got %v", err)
	}
}
