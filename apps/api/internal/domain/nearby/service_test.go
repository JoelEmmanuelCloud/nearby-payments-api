package nearby_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/nearby"
	"github.com/vaariance/nearby/internal/utils"
)

var (
	testPool      *pgxpool.Pool
	testAuthStore *auth.Store
	testStore     *nearby.Store
	testSvc       *nearby.Service
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

	testAuthStore = auth.NewStore(testPool)
	testStore = nearby.NewStore(testPool)
	testSvc = nearby.NewService(nearby.ServiceDeps{
		Store:     testStore,
		AuthStore: testAuthStore,
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
		testPool.Exec(context.Background(), `DELETE FROM nearby_sessions WHERE initiator_user_id = $1 OR recipient_user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM wallet_bindings WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM users WHERE id = $1`, userID)
	})
	return userID
}

func insertWalletBinding(t *testing.T, userID, suiAddress string) {
	t.Helper()
	now := utils.NowUnix()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO wallet_bindings (user_id, sui_address, auth_scheme, issuer, audience, created_at, updated_at)
		 VALUES ($1, $2, 'zklogin', 'https://accounts.google.com', 'test-client', $3, $3)`,
		userID, suiAddress, now,
	)
	if err != nil {
		t.Fatalf("insert wallet binding: %v", err)
	}
}

func newTestHandler() *nearby.Handler {
	return nearby.NewHandler(testSvc)
}

func testSessionContext(userID string) *auth.SessionContext {
	return &auth.SessionContext{
		User:      &auth.User{ID: userID, Status: "active"},
		Device:    &auth.Device{ID: utils.NewID(), Status: "active"},
		Session:   &auth.Session{ID: utils.NewID()},
		Integrity: &auth.DeviceIntegrityRecord{},
	}
}

func TestInitiateSession_NoSession(t *testing.T) {
	handler := newTestHandler()
	body, _ := json.Marshal(map[string]string{
		"recipientSuiAddress": "0xabc",
		"payloadType":         "payment_request",
		"payloadData":         "{}",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/nearby/sessions", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.InitiateSession(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestInitiateSession_MissingFields(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	body, _ := json.Marshal(map[string]string{
		"payloadType": "payment_request",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/nearby/sessions", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.InitiateSession(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestGetSession_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/nearby/sessions/some-id", nil)
	rr := httptest.NewRecorder()
	handler.GetSession(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestAcknowledgeSession_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodPost, "/v1/nearby/sessions/some-id/acknowledge", nil)
	rr := httptest.NewRecorder()
	handler.AcknowledgeSession(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestService_InitiateSession_InvalidPayloadType(t *testing.T) {
	initiatorID := insertTestUser(t)
	_, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: "0xabc",
		PayloadType:         "unsupported_type",
		PayloadData:         "{}",
	})
	if !errors.Is(err, nearby.ErrInvalidPayload) {
		t.Fatalf("expected ErrInvalidPayload, got %v", err)
	}
}

func TestService_InitiateSession_EmptyPayloadData(t *testing.T) {
	initiatorID := insertTestUser(t)
	_, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: "0xabc",
		PayloadType:         "payment_request",
		PayloadData:         "",
	})
	if !errors.Is(err, nearby.ErrInvalidPayload) {
		t.Fatalf("expected ErrInvalidPayload for empty payload data, got %v", err)
	}
}

func TestService_InitiateSession_RecipientNotFound(t *testing.T) {
	initiatorID := insertTestUser(t)
	_, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: "0x" + utils.SHA256HexString("unknown-address"),
		PayloadType:         "payment_request",
		PayloadData:         `{"amount":"1000"}`,
	})
	if !errors.Is(err, nearby.ErrSessionNotFound) {
		t.Fatalf("expected ErrSessionNotFound for unknown recipient, got %v", err)
	}
}

func TestService_GetSession_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.GetSession(context.Background(), utils.NewID(), userID)
	if !errors.Is(err, nearby.ErrSessionNotFound) {
		t.Fatalf("expected ErrSessionNotFound, got %v", err)
	}
}

func TestService_GetSession_NotParticipant(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)
	outsiderID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID)
	insertWalletBinding(t, recipientID, suiAddr)

	resp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "payment_request",
		PayloadData:         `{"amount":"500"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}

	_, err = testSvc.GetSession(context.Background(), resp.SessionID, outsiderID)
	if !errors.Is(err, nearby.ErrSessionNotFound) {
		t.Fatalf("expected ErrSessionNotFound for non-participant, got %v", err)
	}
}

func TestService_AcknowledgeSession_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.AcknowledgeSession(context.Background(), utils.NewID(), userID, nearby.AcknowledgeSessionRequest{Accept: true})
	if !errors.Is(err, nearby.ErrSessionNotFound) {
		t.Fatalf("expected ErrSessionNotFound, got %v", err)
	}
}

func TestService_AcknowledgeSession_NotRecipient(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID)
	insertWalletBinding(t, recipientID, suiAddr)

	resp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "contact_share",
		PayloadData:         `{"name":"Joel"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}

	_, err = testSvc.AcknowledgeSession(context.Background(), resp.SessionID, initiatorID, nearby.AcknowledgeSessionRequest{Accept: true})
	if !errors.Is(err, nearby.ErrSessionNotFound) {
		t.Fatalf("expected ErrSessionNotFound when initiator tries to acknowledge, got %v", err)
	}
}

func TestService_FullFlow_Accept(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID+"accept")
	insertWalletBinding(t, recipientID, suiAddr)

	initResp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "payment_request",
		PayloadData:         `{"amount":"1000000"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}
	if initResp.Status != "pending" {
		t.Fatalf("expected status pending, got %s", initResp.Status)
	}

	getResp, err := testSvc.GetSession(context.Background(), initResp.SessionID, initiatorID)
	if err != nil {
		t.Fatalf("get session as initiator: %v", err)
	}
	if getResp.Status != "pending" {
		t.Fatalf("expected status pending, got %s", getResp.Status)
	}

	ackResp, err := testSvc.AcknowledgeSession(context.Background(), initResp.SessionID, recipientID, nearby.AcknowledgeSessionRequest{Accept: true})
	if err != nil {
		t.Fatalf("acknowledge session: %v", err)
	}
	if ackResp.Status != "accepted" {
		t.Fatalf("expected status accepted, got %s", ackResp.Status)
	}
}

func TestService_FullFlow_Decline(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID+"decline")
	insertWalletBinding(t, recipientID, suiAddr)

	initResp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "contact_share",
		PayloadData:         `{"card":"info"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}

	ackResp, err := testSvc.AcknowledgeSession(context.Background(), initResp.SessionID, recipientID, nearby.AcknowledgeSessionRequest{Accept: false})
	if err != nil {
		t.Fatalf("acknowledge session: %v", err)
	}
	if ackResp.Status != "declined" {
		t.Fatalf("expected status declined, got %s", ackResp.Status)
	}
}

func TestService_AcknowledgeSession_NotPending(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID+"notpending")
	insertWalletBinding(t, recipientID, suiAddr)

	initResp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "payment_request",
		PayloadData:         `{"amount":"100"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}

	if _, err := testSvc.AcknowledgeSession(context.Background(), initResp.SessionID, recipientID, nearby.AcknowledgeSessionRequest{Accept: true}); err != nil {
		t.Fatalf("first acknowledge: %v", err)
	}

	_, err = testSvc.AcknowledgeSession(context.Background(), initResp.SessionID, recipientID, nearby.AcknowledgeSessionRequest{Accept: true})
	if !errors.Is(err, nearby.ErrSessionNotPending) {
		t.Fatalf("expected ErrSessionNotPending on second acknowledge, got %v", err)
	}
}

func TestHandler_InitiateSession_Valid(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID+"handler")
	insertWalletBinding(t, recipientID, suiAddr)

	handler := newTestHandler()
	body, _ := json.Marshal(map[string]string{
		"recipientSuiAddress": suiAddr,
		"payloadType":         "payment_request",
		"payloadData":         `{"amount":"9999"}`,
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/nearby/sessions", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(initiatorID)))
	rr := httptest.NewRecorder()
	handler.InitiateSession(rr, req)

	if rr.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d: %s", rr.Code, rr.Body.String())
	}
	var resp nearby.InitiateSessionResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if resp.SessionID == "" {
		t.Fatal("expected non-empty session id")
	}
	if resp.Status != "pending" {
		t.Fatalf("expected status pending, got %s", resp.Status)
	}
}

func TestHandler_AcknowledgeSession_Valid(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)

	suiAddr := "0x" + utils.SHA256HexString(recipientID+"ackhandler")
	insertWalletBinding(t, recipientID, suiAddr)

	initResp, err := testSvc.InitiateSession(context.Background(), initiatorID, nearby.InitiateSessionRequest{
		RecipientSuiAddress: suiAddr,
		PayloadType:         "payment_request",
		PayloadData:         `{"amount":"42"}`,
	})
	if err != nil {
		t.Fatalf("initiate session: %v", err)
	}

	handler := newTestHandler()
	body, _ := json.Marshal(map[string]bool{"accept": true})

	rctx := chi.NewRouteContext()
	rctx.URLParams.Add("id", initResp.SessionID)

	req := httptest.NewRequest(http.MethodPost, "/v1/nearby/sessions/"+initResp.SessionID+"/acknowledge", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(context.WithValue(
		auth.WithSession(req.Context(), testSessionContext(recipientID)),
		chi.RouteCtxKey, rctx,
	))
	rr := httptest.NewRecorder()
	handler.AcknowledgeSession(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", rr.Code, rr.Body.String())
	}
	var resp nearby.AcknowledgeSessionResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if resp.Status != "accepted" {
		t.Fatalf("expected status accepted, got %s", resp.Status)
	}
}

func TestStore_CreateAndGetSession(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)
	now := utils.NowUnix()

	ns := &nearby.NearbySession{
		ID:              utils.NewID(),
		InitiatorUserID: initiatorID,
		RecipientUserID: recipientID,
		Status:          "pending",
		PayloadType:     "payment_request",
		PayloadData:     `{"amount":"100"}`,
		CreatedAt:       now,
		UpdatedAt:       now,
		ExpiresAt:       now + 300,
	}
	if err := testStore.CreateSession(context.Background(), ns); err != nil {
		t.Fatalf("create session: %v", err)
	}

	got, err := testStore.GetSessionByID(context.Background(), ns.ID)
	if err != nil {
		t.Fatalf("get session: %v", err)
	}
	if got == nil {
		t.Fatal("expected session, got nil")
	}
	if got.InitiatorUserID != initiatorID {
		t.Fatalf("expected initiator %s, got %s", initiatorID, got.InitiatorUserID)
	}
	if got.Status != "pending" {
		t.Fatalf("expected status pending, got %s", got.Status)
	}
}

func TestStore_GetSession_NotFound(t *testing.T) {
	got, err := testStore.GetSessionByID(context.Background(), utils.NewID())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != nil {
		t.Fatal("expected nil for unknown session id")
	}
}

func TestStore_UpdateSessionStatus(t *testing.T) {
	initiatorID := insertTestUser(t)
	recipientID := insertTestUser(t)
	now := utils.NowUnix()

	ns := &nearby.NearbySession{
		ID:              utils.NewID(),
		InitiatorUserID: initiatorID,
		RecipientUserID: recipientID,
		Status:          "pending",
		PayloadType:     "contact_share",
		PayloadData:     `{}`,
		CreatedAt:       now,
		UpdatedAt:       now,
		ExpiresAt:       now + 300,
	}
	if err := testStore.CreateSession(context.Background(), ns); err != nil {
		t.Fatalf("create session: %v", err)
	}

	if err := testStore.UpdateSessionStatus(context.Background(), ns.ID, "accepted", now+1); err != nil {
		t.Fatalf("update session status: %v", err)
	}

	got, err := testStore.GetSessionByID(context.Background(), ns.ID)
	if err != nil {
		t.Fatalf("get session: %v", err)
	}
	if got.Status != "accepted" {
		t.Fatalf("expected status accepted, got %s", got.Status)
	}
}
