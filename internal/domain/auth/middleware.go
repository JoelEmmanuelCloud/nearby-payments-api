package auth

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"

	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/utils"
)

type contextKeySession struct{}

const (
	highFidelitySkewSeconds = 300
	nonceTTL                = 10 * time.Minute
)

func Middleware(svc *Service, fidelity string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			rawToken := extractBearerToken(r)
			if rawToken == "" {
				apperr.Write(w, ErrUnauthorized)
				return
			}

			sessCtx, err := svc.VerifyAccessToken(r.Context(), rawToken)
			if err != nil {
				apperr.Write(w, err)
				return
			}

			if fidelity == "high" {
				if err := verifyHighFidelity(r, svc.rdb, sessCtx); err != nil {
					apperr.Write(w, err)
					return
				}
			}

			ctx := context.WithValue(r.Context(), contextKeySession{}, sessCtx)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func GetSession(ctx context.Context) *SessionContext {
	if s, ok := ctx.Value(contextKeySession{}).(*SessionContext); ok {
		return s
	}
	return nil
}

func WithSession(ctx context.Context, sess *SessionContext) context.Context {
	return context.WithValue(ctx, contextKeySession{}, sess)
}

func extractBearerToken(r *http.Request) string {
	auth := r.Header.Get("Authorization")
	if !strings.HasPrefix(auth, "Bearer ") {
		return ""
	}
	return strings.TrimPrefix(auth, "Bearer ")
}

func verifyHighFidelity(r *http.Request, rdb *redis.Client, sessCtx *SessionContext) error {
	provider := r.Header.Get("X-Device-Provider")
	nonce := r.Header.Get("X-Request-Nonce")
	timestampStr := r.Header.Get("X-Request-Timestamp")

	if provider == "" || nonce == "" || timestampStr == "" {
		return ErrHighFidelityRequired
	}

	var tsMs int64
	if _, err := fmt.Sscanf(timestampStr, "%d", &tsMs); err != nil {
		return ErrHighFidelityRequired
	}
	tsSec := tsMs / 1000
	if !utils.InWindow(tsSec, highFidelitySkewSeconds) {
		return ErrTimestampOutOfWindow
	}

	nonceKey := "hf:nonce:" + sessCtx.Session.DeviceIntegrityID + ":" + nonce
	set, err := rdb.SetNX(context.Background(), nonceKey, "1", nonceTTL).Result()
	if err != nil {
		return apperr.ErrInternal
	}
	if !set {
		return ErrReplayDetected
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		return apperr.ErrInternal
	}
	r.Body = io.NopCloser(bytes.NewReader(body))

	expectedBodyHash := "0x" + utils.SHA256Hex(body)
	clientBodyHash := r.Header.Get("X-Body-Hash")
	if clientBodyHash != "" && clientBodyHash != expectedBodyHash {
		return ErrBodyHashMismatch
	}

	return nil
}
