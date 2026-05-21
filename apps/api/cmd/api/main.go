package main

import (
	"context"
	"crypto/ed25519"
	"encoding/hex"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"
	"github.com/vaariance/nearby/internal/avs"
	"github.com/vaariance/nearby/internal/config"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/domain/names"
	"github.com/vaariance/nearby/internal/domain/nearby"
	"github.com/vaariance/nearby/internal/domain/payment"
	"github.com/vaariance/nearby/internal/sui"
	"github.com/vaariance/nearby/router"
)

func main() {
	ctx := context.Background()

	_ = godotenv.Load()

	cfg, err := config.Load()
	if err != nil {
		slog.Error("config load failed", "error", err)
		os.Exit(1)
	}

	logLevel := slog.LevelInfo
	if cfg.IsDevelopment() {
		logLevel = slog.LevelDebug
	}
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: logLevel})))

	pool, err := dbpkg.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("database connection failed", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	rdb, err := dbpkg.NewRedis(ctx, cfg.RedisURL)
	if err != nil {
		slog.Error("redis connection failed", "error", err)
		os.Exit(1)
	}
	defer rdb.Close()

	migrationsDir := "internal/db/migrations"
	if err := dbpkg.Migrate(ctx, pool, migrationsDir); err != nil {
		slog.Error("migration failed", "error", err)
		os.Exit(1)
	}

	avsClient, err := avs.NewClient(cfg.AVSOperatorKeys)
	if err != nil {
		slog.Error("avs client init failed", "error", err)
		os.Exit(1)
	}

	suiClient := sui.NewClient(cfg.SuiRPCURL)
	sponsor := sui.NewSponsor(suiClient, avsClient)

	var credSignKey ed25519.PrivateKey
	var credPubKey ed25519.PublicKey

	if cfg.CredentialSigningKey != "" {
		keyBytes, err := hex.DecodeString(cfg.CredentialSigningKey)
		if err != nil {
			slog.Error("invalid CREDENTIAL_SIGNING_KEY", "error", err)
			os.Exit(1)
		}
		credSignKey = ed25519.PrivateKey(keyBytes)
		credPubKey = credSignKey.Public().(ed25519.PublicKey)
	} else {
		credPubKey, credSignKey, err = ed25519.GenerateKey(nil)
		if err != nil {
			slog.Error("credential key generation failed", "error", err)
			os.Exit(1)
		}
	}

	authStore := auth.NewStore(pool)
	authSvc := auth.NewService(auth.ServiceDeps{
		Store:              authStore,
		Redis:              rdb,
		GoogleClientID:     cfg.GoogleClientID,
		GoogleClientSecret: cfg.GoogleClientSecret,
		GoogleRedirectURI:  cfg.GoogleRedirectURI,
		CredentialSignKey:  credSignKey,
		CredentialPubKey:   credPubKey,
	})
	authHandler := auth.NewHandler(authSvc)

	depositStore := deposit.NewStore(pool)
	fincraClient := deposit.NewFincraClient(cfg.FincraAPIKey, cfg.FincraAPIURL)
	blockradarClient := deposit.NewBlockradarClient(cfg.BlockradarAPIKey, cfg.BlockradarWalletID, cfg.BlockradarAPIURL)
	depositSvc := deposit.NewService(deposit.ServiceDeps{
		Store:            depositStore,
		FincraClient:     fincraClient,
		BlockradarClient: blockradarClient,
		AuthStore:        authStore,
	})
	depositHandler := deposit.NewHandler(depositSvc)
	webhookHandler := deposit.NewWebhookHandler(depositStore, cfg.FincraWebhookSecret, cfg.BlockradarWebhookSecret)

	paymentStore := payment.NewStore(pool)
	paymentSvc := payment.NewService(payment.ServiceDeps{
		Store:     paymentStore,
		SuiClient: suiClient,
		Sponsor:   sponsor,
	})
	paymentHandler := payment.NewHandler(paymentSvc)

	namesStore := names.NewStore(pool)
	namesSvc := names.NewService(names.ServiceDeps{
		Store:     namesStore,
		AuthStore: authStore,
		AVSClient: avsClient,
	})
	namesHandler := names.NewHandler(namesSvc)

	nearbyStore := nearby.NewStore(pool)
	nearbySvc := nearby.NewService(nearby.ServiceDeps{
		Store:     nearbyStore,
		AuthStore: authStore,
	})
	nearbyHandler := nearby.NewHandler(nearbySvc)

	h := router.New(router.Deps{
		AuthHandler:    authHandler,
		AuthService:    authSvc,
		DepositHandler: depositHandler,
		WebhookHandler: webhookHandler,
		PaymentHandler: paymentHandler,
		NamesHandler:   namesHandler,
		NearbyHandler:  nearbyHandler,
		Redis:          rdb,
	})

	addr := fmt.Sprintf(":%s", cfg.Port)
	srv := &http.Server{
		Addr:         addr,
		Handler:      h,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		slog.Info("server starting", "addr", addr, "env", cfg.Env)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server error", "error", err)
			os.Exit(1)
		}
	}()

	<-quit
	slog.Info("server shutting down")

	shutdownCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("graceful shutdown failed", "error", err)
		os.Exit(1)
	}

	slog.Info("server stopped")
}
