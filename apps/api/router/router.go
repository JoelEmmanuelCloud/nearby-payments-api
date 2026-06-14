package router

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"

	"github.com/redis/go-redis/v9"
	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/domain/names"
	"github.com/vaariance/nearby/internal/domain/nearby"
	"github.com/vaariance/nearby/internal/domain/payment"
	"github.com/vaariance/nearby/internal/middleware"
)

type Deps struct {
	AuthHandler    *auth.Handler
	AuthService    *auth.Service
	DepositHandler *deposit.Handler
	WebhookHandler *deposit.WebhookHandler
	PaymentHandler *payment.Handler
	NamesHandler   *names.Handler
	NearbyHandler  *nearby.Handler
	Redis          *redis.Client
}

func New(deps Deps) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.Recovery)
	r.Use(middleware.RequestID)
	r.Use(middleware.Logger)
	r.Use(chimiddleware.RealIP)

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	})

	r.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	authLimit := middleware.RateLimit(deps.Redis, middleware.RateLimitConfig{Name: "auth", Limit: 20, Window: time.Minute})
	deviceLimit := middleware.RateLimit(deps.Redis, middleware.RateLimitConfig{Name: "auth-device", Limit: 10, Window: time.Minute})
	readLimit := middleware.RateLimit(deps.Redis, middleware.RateLimitConfig{Name: "read", Limit: 120, Window: time.Minute})
	writeLimit := middleware.RateLimit(deps.Redis, middleware.RateLimitConfig{Name: "write", Limit: 30, Window: time.Minute})
	webhookLimit := middleware.RateLimit(deps.Redis, middleware.RateLimitConfig{Name: "webhook", Limit: 300, Window: time.Minute})

	r.Route("/v1", func(r chi.Router) {
		r.Route("/auth", func(r chi.Router) {
			r.Group(func(r chi.Router) {
				r.Use(authLimit)
				r.Get("/server-public-key", deps.AuthHandler.GetServerPublicKey)
				r.Post("/oauth/begin", deps.AuthHandler.OAuthBegin)
				r.Get("/oauth/complete", deps.AuthHandler.OAuthCallbackPage)
				r.Post("/oauth/complete", deps.AuthHandler.OAuthComplete)
				r.Post("/oauth/callback/apple", deps.AuthHandler.OAuthAppleCallback)
				r.Post("/zklogin/prove", deps.AuthHandler.ProveZkLogin)
				r.Post("/refresh", deps.AuthHandler.RefreshSession)
			})

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "low"))
				r.Use(writeLimit)
				r.Post("/revoke", deps.AuthHandler.RevokeSession)
			})

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "high"))
				r.Use(deviceLimit)
				r.Post("/integrity", deps.AuthHandler.AssertDeviceIntegrity)
				r.Post("/credential", deps.AuthHandler.IssueDeviceCredential)
			})
		})

		r.Route("/deposit", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "low"))
			r.Group(func(r chi.Router) {
				r.Use(readLimit)
				r.Get("/options", deps.DepositHandler.GetOptions)
				r.Get("/history", deps.DepositHandler.GetDeposits)
				r.Get("/{id}", deps.DepositHandler.GetDeposit)
			})
			r.Group(func(r chi.Router) {
				r.Use(writeLimit)
				r.Post("/liquidation-address", deps.DepositHandler.GetLiquidationAddress)
			})
		})

		r.Route("/payments", func(r chi.Router) {
			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "high"))
				r.Use(writeLimit)
				r.Use(middleware.Idempotency(deps.Redis))
				r.Post("/intents", deps.PaymentHandler.CreateIntent)
			})

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "low"))
				r.Use(readLimit)
				r.Get("/intents/{id}", deps.PaymentHandler.GetIntent)
				r.Post("/intents/{id}/submit", deps.PaymentHandler.SubmitIntent)
				r.Post("/intents/{id}/cancel", deps.PaymentHandler.CancelIntent)
				r.Get("/{id}", deps.PaymentHandler.GetPayment)
			})
		})

		r.Route("/names", func(r chi.Router) {
			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "low"))
				r.Use(readLimit)
				r.Get("/leaf/{leafName}/available", deps.NamesHandler.CheckAvailability)
			})
			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "high"))
				r.Use(writeLimit)
				r.Post("/leaf", deps.NamesHandler.RegisterLeaf)
				r.Post("/tasks/{id}/submit", deps.NamesHandler.SubmitLeaf)
				r.Get("/tasks/{id}", deps.NamesHandler.GetTask)
			})
		})

		r.Route("/me", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "low"))
			r.Use(readLimit)
			r.Get("/profile", deps.AuthHandler.GetProfile)
			r.Put("/avatar", deps.AuthHandler.UploadAvatar)
			r.Put("/wallet", deps.AuthHandler.BindWallet)
		})

		r.Route("/nearby", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "high"))
			r.Use(writeLimit)
			r.Post("/sessions", deps.NearbyHandler.InitiateSession)
			r.Get("/sessions/{id}", deps.NearbyHandler.GetSession)
			r.Post("/sessions/{id}/acknowledge", deps.NearbyHandler.AcknowledgeSession)
		})

		r.Group(func(r chi.Router) {
			r.Use(webhookLimit)
			r.Post("/webhooks/bridge", deps.WebhookHandler.HandleBridgeWebhook)
		})
	})

	return r
}
