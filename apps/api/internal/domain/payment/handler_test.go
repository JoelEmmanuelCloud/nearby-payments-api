package payment_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/payment"
	"github.com/vaariance/nearby/internal/utils"
)

func newTestPaymentHandler() *payment.Handler {
	svc := payment.NewService(payment.ServiceDeps{Store: testStore})
	return payment.NewHandler(svc)
}

func testSessionContext(userID string) *auth.SessionContext {
	return &auth.SessionContext{
		User:      &auth.User{ID: userID, Status: "active"},
		Device:    &auth.Device{ID: utils.NewID(), Status: "active"},
		Session:   &auth.Session{ID: utils.NewID()},
		Integrity: &auth.DeviceIntegrityRecord{},
	}
}

func TestCreateIntent_NoSession(t *testing.T) {
	handler := newTestPaymentHandler()
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents", bytes.NewReader([]byte(`{}`)))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.CreateIntent(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestCreateIntent_MissingRequiredFields(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestPaymentHandler()

	body, _ := json.Marshal(map[string]string{
		"asset": "USDsui",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.CreateIntent(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestCreateIntent_InvalidAsset(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestPaymentHandler()

	body, _ := json.Marshal(map[string]string{
		"recipientAddress": testRecipientAddress,
		"asset":            "ETH",
		"amountAtomic":     "1000000",
		"idempotencyKey":   utils.NewID(),
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.CreateIntent(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestCreateIntentHandler_Valid(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestPaymentHandler()

	body, _ := json.Marshal(map[string]string{
		"recipientAddress": testRecipientAddress,
		"asset":            "USDsui",
		"amountAtomic":     "1000000",
		"idempotencyKey":   utils.NewID(),
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.CreateIntent(rr, req)

	if rr.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d: %s", rr.Code, rr.Body.String())
	}
	var resp payment.CreateIntentResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if resp.IntentID == "" {
		t.Fatal("expected non-empty intent ID")
	}
}

func TestGetIntent_NoSession(t *testing.T) {
	handler := newTestPaymentHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/payments/intents/some-id", nil)
	rr := httptest.NewRecorder()
	handler.GetIntent(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestCancelIntent_NoSession(t *testing.T) {
	handler := newTestPaymentHandler()
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents/some-id/cancel", nil)
	rr := httptest.NewRecorder()
	handler.CancelIntent(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestGetPayment_NoSession(t *testing.T) {
	handler := newTestPaymentHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/payments/some-id", nil)
	rr := httptest.NewRecorder()
	handler.GetPayment(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestSubmitIntent_NoSession(t *testing.T) {
	handler := newTestPaymentHandler()
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents/some-id/submit", nil)
	rr := httptest.NewRecorder()
	handler.SubmitIntent(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestSubmitIntent_MissingFields(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestPaymentHandler()

	body, _ := json.Marshal(map[string]string{
		"txBytes": "dGVzdA==",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/payments/intents/some-id/submit", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.SubmitIntent(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}
