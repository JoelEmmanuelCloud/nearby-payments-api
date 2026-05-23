package auth_test

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/auth"
)

func newTestAuthHandler(t *testing.T) *auth.Handler {
	t.Helper()
	_ = godotenv.Load("../../../.env")
	ctx := context.Background()

	pool, err := dbpkg.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		t.Fatalf("db pool: %v", err)
	}
	t.Cleanup(pool.Close)

	rdb, err := dbpkg.NewRedis(ctx, os.Getenv("REDIS_URL"))
	if err != nil {
		t.Fatalf("redis: %v", err)
	}
	t.Cleanup(func() { rdb.Close() })

	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		t.Fatalf("generate ed25519 key: %v", err)
	}

	store := auth.NewStore(pool)
	svc := auth.NewService(auth.ServiceDeps{
		Store:              store,
		Redis:              rdb,
		GoogleClientID:     "test-client-id",
		GoogleClientSecret: "test-client-secret",
		GoogleRedirectURI:  "http://localhost/callback",
		CredentialSignKey:  priv,
		CredentialPubKey:   pub,
	})
	return auth.NewHandler(svc)
}

func TestGetServerPublicKey(t *testing.T) {
	handler := newTestAuthHandler(t)
	req := httptest.NewRequest(http.MethodGet, "/v1/auth/server-public-key", nil)
	rr := httptest.NewRecorder()
	handler.GetServerPublicKey(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rr.Code)
	}
	var resp struct {
		PublicKey string `json:"publicKey"`
		Format    string `json:"format"`
	}
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if resp.PublicKey == "" {
		t.Fatal("expected non-empty public key")
	}
	if resp.Format != "ed25519_hex" {
		t.Fatalf("expected format ed25519_hex, got %s", resp.Format)
	}
}

func TestOAuthBegin_MissingProvider(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"codeChallenge": "challenge",
		"zkLoginNonce":  "nonce",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/begin", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthBegin(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthBegin_MissingCodeChallenge(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"provider":     "google",
		"zkLoginNonce": "nonce",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/begin", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthBegin(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthBegin_MissingZkLoginNonce(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"provider":      "google",
		"codeChallenge": "challenge",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/begin", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthBegin(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthBegin_UnsupportedProvider(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"provider":      "facebook",
		"codeChallenge": "challenge",
		"zkLoginNonce":  "nonce",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/begin", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthBegin(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthComplete_MissingCode(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"state":        "some-state",
		"codeVerifier": "verifier",
		"platform":     "ios",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/complete", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthComplete(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthComplete_MissingState(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"code":         "auth-code",
		"codeVerifier": "verifier",
		"platform":     "ios",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/complete", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthComplete(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestOAuthComplete_InvalidPlatform(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{
		"code":         "auth-code",
		"state":        "some-state",
		"codeVerifier": "verifier",
		"platform":     "windows",
	})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/oauth/complete", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.OAuthComplete(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestRefreshSession_MissingToken(t *testing.T) {
	handler := newTestAuthHandler(t)
	body, _ := json.Marshal(map[string]string{})
	req := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.RefreshSession(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}
