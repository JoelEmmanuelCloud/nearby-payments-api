package middleware_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/middleware"
	"github.com/vaariance/nearby/internal/utils"
)

func TestMain(m *testing.M) {
	_ = godotenv.Load("../../.env")
	os.Exit(m.Run())
}

func TestIdempotency_MissingKey(t *testing.T) {
	_ = godotenv.Load("../../.env")
	ctx := context.Background()
	rdb, err := dbpkg.NewRedis(ctx, os.Getenv("REDIS_URL"))
	if err != nil {
		t.Fatalf("redis: %v", err)
	}
	defer rdb.Close()

	handler := middleware.Idempotency(rdb)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodPost, "/", nil)
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for missing key, got %d", rr.Code)
	}
}

func TestIdempotency_DuplicateKey(t *testing.T) {
	_ = godotenv.Load("../../.env")
	ctx := context.Background()
	rdb, err := dbpkg.NewRedis(ctx, os.Getenv("REDIS_URL"))
	if err != nil {
		t.Fatalf("redis: %v", err)
	}
	defer rdb.Close()

	key := utils.NewID()
	t.Cleanup(func() { rdb.Del(context.Background(), "idempotency:"+key) })

	handler := middleware.Idempotency(rdb)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	first := httptest.NewRequest(http.MethodPost, "/", nil)
	first.Header.Set("Idempotency-Key", key)
	rr1 := httptest.NewRecorder()
	handler.ServeHTTP(rr1, first)
	if rr1.Code != http.StatusOK {
		t.Fatalf("first request: expected 200, got %d", rr1.Code)
	}

	second := httptest.NewRequest(http.MethodPost, "/", nil)
	second.Header.Set("Idempotency-Key", key)
	rr2 := httptest.NewRecorder()
	handler.ServeHTTP(rr2, second)
	if rr2.Code != http.StatusConflict {
		t.Fatalf("duplicate request: expected 409, got %d", rr2.Code)
	}
}

func TestIdempotency_PassThrough(t *testing.T) {
	_ = godotenv.Load("../../.env")
	ctx := context.Background()
	rdb, err := dbpkg.NewRedis(ctx, os.Getenv("REDIS_URL"))
	if err != nil {
		t.Fatalf("redis: %v", err)
	}
	defer rdb.Close()

	key := utils.NewID()
	t.Cleanup(func() { rdb.Del(context.Background(), "idempotency:"+key) })

	reached := false
	handler := middleware.Idempotency(rdb)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reached = true
		w.WriteHeader(http.StatusCreated)
	}))

	req := httptest.NewRequest(http.MethodPost, "/", nil)
	req.Header.Set("Idempotency-Key", key)
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)

	if rr.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d", rr.Code)
	}
	if !reached {
		t.Fatal("expected handler to be called")
	}
}
