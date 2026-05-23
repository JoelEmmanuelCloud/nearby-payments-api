package deposit_test

import (
	"bytes"
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/utils"
)

func setupHandler(t *testing.T) (*deposit.WebhookHandler, *rsa.PrivateKey) {
	t.Helper()

	privKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("generate rsa key: %v", err)
	}

	pubDER, err := x509.MarshalPKIXPublicKey(&privKey.PublicKey)
	if err != nil {
		t.Fatalf("marshal public key: %v", err)
	}
	pubPEM := string(pem.EncodeToMemory(&pem.Block{Type: "PUBLIC KEY", Bytes: pubDER}))

	_ = godotenv.Load("../../../.env")

	ctx := context.Background()
	pool, err := dbpkg.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		t.Fatalf("database connection: %v", err)
	}
	t.Cleanup(func() { pool.Close() })

	store := deposit.NewStore(pool)
	handler, err := deposit.NewWebhookHandler(store, pubPEM)
	if err != nil {
		t.Fatalf("create webhook handler: %v", err)
	}

	return handler, privKey
}

func signedRequest(t *testing.T, privKey *rsa.PrivateKey, body []byte) *http.Request {
	t.Helper()

	digest := sha256.Sum256(body)
	sig, err := rsa.SignPKCS1v15(rand.Reader, privKey, crypto.SHA256, digest[:])
	if err != nil {
		t.Fatalf("sign payload: %v", err)
	}

	req := httptest.NewRequest(http.MethodPost, "/v1/webhooks/bridge", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Bridge-Signature", base64.StdEncoding.EncodeToString(sig))
	return req
}

func TestHandleBridgeWebhook_ValidSignature(t *testing.T) {
	handler, privKey := setupHandler(t)

	payload := map[string]any{
		"id":   utils.NewID(),
		"type": "kyc_link.approved",
		"data": map[string]string{"status": "approved"},
	}
	body, _ := json.Marshal(payload)

	rr := httptest.NewRecorder()
	handler.HandleBridgeWebhook(rr, signedRequest(t, privKey, body))

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", rr.Code, rr.Body.String())
	}
}

func TestHandleBridgeWebhook_InvalidSignature(t *testing.T) {
	handler, privKey := setupHandler(t)

	body := []byte(`{"id":"test-id","type":"kyc_link.approved","data":{}}`)

	digest := sha256.Sum256(body)
	sig, _ := rsa.SignPKCS1v15(rand.Reader, privKey, crypto.SHA256, digest[:])

	tampered := append(body, 'x')
	req := httptest.NewRequest(http.MethodPost, "/v1/webhooks/bridge", bytes.NewReader(tampered))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Bridge-Signature", base64.StdEncoding.EncodeToString(sig))

	rr := httptest.NewRecorder()
	handler.HandleBridgeWebhook(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestHandleBridgeWebhook_MissingSignature(t *testing.T) {
	handler, _ := setupHandler(t)

	body := []byte(`{"id":"test-id","type":"kyc_link.approved","data":{}}`)
	req := httptest.NewRequest(http.MethodPost, "/v1/webhooks/bridge", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	handler.HandleBridgeWebhook(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestHandleBridgeWebhook_Idempotency(t *testing.T) {
	handler, privKey := setupHandler(t)

	eventID := utils.NewID()
	payload := map[string]any{
		"id":   eventID,
		"type": "kyc_link.approved",
		"data": map[string]string{"status": "approved"},
	}
	body, _ := json.Marshal(payload)

	rr1 := httptest.NewRecorder()
	handler.HandleBridgeWebhook(rr1, signedRequest(t, privKey, body))
	if rr1.Code != http.StatusOK {
		t.Fatalf("first request: expected 200, got %d", rr1.Code)
	}

	rr2 := httptest.NewRecorder()
	handler.HandleBridgeWebhook(rr2, signedRequest(t, privKey, body))
	if rr2.Code != http.StatusOK {
		t.Fatalf("duplicate request: expected 200, got %d", rr2.Code)
	}
}
