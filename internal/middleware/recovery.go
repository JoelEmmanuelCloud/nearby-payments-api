package middleware

import (
	"log/slog"
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
)

func Recovery(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				slog.Error("panic recovered",
					"panic", rec,
					"request_id", GetRequestID(r.Context()),
					"method", r.Method,
					"path", r.URL.Path,
				)
				apperr.Write(w, apperr.ErrInternal)
			}
		}()
		next.ServeHTTP(w, r)
	})
}
