package middleware

import (
	"context"
	"net/http"
	"time"

	"github.com/redis/go-redis/v9"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

const idempotencyTTL = 24 * time.Hour

func Idempotency(rdb *redis.Client) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			key := r.Header.Get("Idempotency-Key")
			if key == "" {
				apperr.WriteStatus(w, http.StatusBadRequest, "idempotency_key_required", "Idempotency-Key header is required")
				return
			}

			redisKey := "idempotency:" + key
			ctx := context.Background()

			set, err := rdb.SetNX(ctx, redisKey, "1", idempotencyTTL).Result()
			if err != nil {
				apperr.Write(w, apperr.ErrInternal)
				return
			}

			if !set {
				apperr.WriteStatus(w, http.StatusConflict, "idempotent_replay", "Request with this idempotency key was already processed")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
