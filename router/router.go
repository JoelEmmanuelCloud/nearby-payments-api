package router

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"

	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/domain/names"
	"github.com/vaariance/nearby/internal/domain/nearby"
	"github.com/vaariance/nearby/internal/domain/payment"
	"github.com/vaariance/nearby/internal/middleware"
	"github.com/redis/go-redis/v9"
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

	r.Route("/v1", func(r chi.Router) {
		r.Route("/auth", func(r chi.Router) {
			r.Get("/server-public-key", deps.AuthHandler.GetServerPublicKey)
			r.Post("/oauth/begin", deps.AuthHandler.OAuthBegin)
			r.Get("/oauth/complete", deps.AuthHandler.OAuthCallbackPage)
			r.Post("/oauth/complete", deps.AuthHandler.OAuthComplete)

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "low"))
				r.Post("/refresh", deps.AuthHandler.RefreshSession)
				r.Post("/revoke", deps.AuthHandler.RevokeSession)
			})

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "high"))
				r.Post("/integrity", deps.AuthHandler.AssertDeviceIntegrity)
				r.Post("/credential", deps.AuthHandler.IssueDeviceCredential)
			})
		})

		r.Route("/deposit", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "low"))
			r.Get("/options", deps.DepositHandler.GetOptions)
			r.Get("/history", deps.DepositHandler.GetDeposits)
			r.Get("/{id}", deps.DepositHandler.GetDeposit)
		})

		r.Route("/payments", func(r chi.Router) {
			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "high"))
				r.Use(middleware.Idempotency(deps.Redis))
				r.Post("/intents", deps.PaymentHandler.CreateIntent)
			})

			r.Group(func(r chi.Router) {
				r.Use(auth.Middleware(deps.AuthService, "low"))
				r.Get("/intents/{id}", deps.PaymentHandler.GetIntent)
				r.Post("/intents/{id}/submit", deps.PaymentHandler.SubmitIntent)
				r.Post("/intents/{id}/cancel", deps.PaymentHandler.CancelIntent)
				r.Get("/{id}", deps.PaymentHandler.GetPayment)
			})
		})

		r.Route("/names", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "high"))
			r.Post("/leaf", deps.NamesHandler.RegisterLeaf)
			r.Get("/tasks/{id}", deps.NamesHandler.GetTask)
		})

		r.Route("/nearby", func(r chi.Router) {
			r.Use(auth.Middleware(deps.AuthService, "high"))
			r.Post("/sessions", deps.NearbyHandler.InitiateSession)
			r.Get("/sessions/{id}", deps.NearbyHandler.GetSession)
			r.Post("/sessions/{id}/acknowledge", deps.NearbyHandler.AcknowledgeSession)
		})

		r.Post("/webhooks/bridge", deps.WebhookHandler.HandleBridgeWebhook)
	})

	return r
}
