package config

import (
	"fmt"
	"os"
	"strings"
)

type Config struct {
	Port                    string
	Env                     string
	DatabaseURL             string
	RedisURL                string
	SuiRPCURL               string
	SuiNetwork              string
	FincraAPIKey            string
	FincraAPIURL            string
	FincraWebhookSecret     string
	BlockradarAPIKey        string
	BlockradarAPIURL        string
	BlockradarWalletID      string
	BlockradarWebhookSecret string
	AccessTokenSecret       string
	RefreshTokenSecret      string
	SessionEncryptionKey    string
	CredentialSigningKey    string
	AVSOperatorKeys         []string
	GoogleClientID          string
	GoogleClientSecret      string
	GoogleRedirectURI       string
}

func Load() (*Config, error) {
	missing := []string{}

	get := func(key string) string {
		v := os.Getenv(key)
		if v == "" {
			missing = append(missing, key)
		}
		return v
	}

	optional := func(key, fallback string) string {
		if v := os.Getenv(key); v != "" {
			return v
		}
		return fallback
	}

	cfg := &Config{
		Port:                    optional("PORT", "8080"),
		Env:                     optional("ENV", "development"),
		DatabaseURL:             get("DATABASE_URL"),
		RedisURL:                get("REDIS_URL"),
		SuiRPCURL:               optional("SUI_RPC_URL", "https://fullnode.testnet.sui.io:443"),
		SuiNetwork:              optional("SUI_NETWORK", "testnet"),
		FincraAPIKey:            get("FINCRA_API_KEY"),
		FincraAPIURL:            optional("FINCRA_API_URL", "https://sandboxapi.fincra.com"),
		FincraWebhookSecret:     get("FINCRA_WEBHOOK_SECRET"),
		BlockradarAPIKey:        get("BLOCKRADAR_API_KEY"),
		BlockradarAPIURL:        optional("BLOCKRADAR_API_URL", "https://api.blockradar.co/v1"),
		BlockradarWalletID:      get("BLOCKRADAR_WALLET_ID"),
		BlockradarWebhookSecret: get("BLOCKRADAR_WEBHOOK_SECRET"),
		AccessTokenSecret:       get("ACCESS_TOKEN_SECRET"),
		RefreshTokenSecret:      get("REFRESH_TOKEN_SECRET"),
		SessionEncryptionKey:    get("SESSION_ENCRYPTION_KEY"),
		CredentialSigningKey:    optional("CREDENTIAL_SIGNING_KEY", ""),
		GoogleClientID:          get("GOOGLE_CLIENT_ID"),
		GoogleClientSecret:      get("GOOGLE_CLIENT_SECRET"),
		GoogleRedirectURI:       optional("GOOGLE_REDIRECT_URI", ""),
	}

	if len(missing) > 0 {
		return nil, fmt.Errorf("missing required environment variables: %s", strings.Join(missing, ", "))
	}

	if raw := os.Getenv("AVS_OPERATOR_KEYS"); raw != "" {
		cfg.AVSOperatorKeys = strings.Split(raw, ",")
	}

	return cfg, nil
}

func (c *Config) IsDevelopment() bool {
	return c.Env == "development"
}
