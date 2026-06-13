package middleware

import (
	"log/slog"
	"net"
	"net/http"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/vaariance/nearby/internal/domain/auth"
	apperr "github.com/vaariance/nearby/internal/errors"
)

type RateLimitConfig struct {
	Name   string
	Limit  int
	Window time.Duration
}

var rateLimitScript = redis.NewScript(`
local current = redis.call("INCR", KEYS[1])
if current == 1 then
	redis.call("PEXPIRE", KEYS[1], ARGV[1])
end
local ttl = redis.call("PTTL", KEYS[1])
return {current, ttl}
`)

func RateLimit(rdb *redis.Client, cfg RateLimitConfig) func(http.Handler) http.Handler {
	windowMs := cfg.Window.Milliseconds()
	limitHeader := strconv.Itoa(cfg.Limit)

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			key := "ratelimit:" + cfg.Name + ":" + rateLimitIdentifier(r)

			res, err := rateLimitScript.Run(r.Context(), rdb, []string{key}, windowMs).Slice()
			if err != nil {
				slog.Warn("rate limit check failed, allowing request",
					"error", err,
					"request_id", GetRequestID(r.Context()),
					"limiter", cfg.Name,
				)
				next.ServeHTTP(w, r)
				return
			}

			count, _ := res[0].(int64)
			ttlMs, _ := res[1].(int64)
			resetSeconds := (ttlMs + 999) / 1000

			remaining := max(cfg.Limit-int(count), 0)

			w.Header().Set("X-RateLimit-Limit", limitHeader)
			w.Header().Set("X-RateLimit-Remaining", strconv.Itoa(remaining))
			w.Header().Set("X-RateLimit-Reset", strconv.FormatInt(time.Now().Add(time.Duration(ttlMs)*time.Millisecond).Unix(), 10))

			if int(count) > cfg.Limit {
				w.Header().Set("Retry-After", strconv.FormatInt(resetSeconds, 10))
				apperr.Write(w, apperr.ErrRateLimited)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func rateLimitIdentifier(r *http.Request) string {
	if sess := auth.GetSession(r.Context()); sess != nil && sess.Session != nil && sess.Session.UserID != "" {
		return "user:" + sess.Session.UserID
	}
	return "ip:" + clientIP(r)
}

func clientIP(r *http.Request) string {
	if ip, _, err := net.SplitHostPort(r.RemoteAddr); err == nil {
		return ip
	}
	return r.RemoteAddr
}
