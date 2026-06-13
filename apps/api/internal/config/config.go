package config

import (
	"fmt"
	"os"
	"strings"
)

type Config struct {
	Port                   string
	Env                    string
	DatabaseURL            string
	RedisURL               string
	SuiRPCURL              string
	SuiNetwork             string
	BridgeAPIKey           string
	BridgeAPIURL           string
	BridgeWebhookPublicKey string
	AccessTokenSecret      string
	RefreshTokenSecret     string
	SessionEncryptionKey   string
	CredentialSigningKey   string
	AVSOperatorKeys        []string
	GoogleClientID         string
	GoogleClientSecret     string
	GoogleRedirectURI      string
	GoogleIOSClientID      string
	GoogleAndroidClientID  string
	AppleBundleID          string
	AppleWebClientID       string
	AppleWebRedirectURI    string
	AppleKeyID             string
	ApplePrivateKeyPEM     string
	AppleTeamID            string
	WalrusPublisherURL     string
	WalrusAggregatorURL    string
	ZkLoginProverURL       string
	AppCallbackURL         string
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
		Port:                   optional("PORT", "8080"),
		Env:                    optional("ENV", "development"),
		DatabaseURL:            get("DATABASE_URL"),
		RedisURL:               get("REDIS_URL"),
		SuiRPCURL:              optional("SUI_RPC_URL", "https://fullnode.testnet.sui.io:443"),
		SuiNetwork:             optional("SUI_NETWORK", "testnet"),
		BridgeAPIKey:           get("BRIDGE_API_KEY"),
		BridgeAPIURL:           optional("BRIDGE_API_URL", "https://api.sandbox.bridge.xyz"),
		BridgeWebhookPublicKey: strings.ReplaceAll(get("BRIDGE_WEBHOOK_PUBLIC_KEY"), `\n`, "\n"),
		AccessTokenSecret:      get("ACCESS_TOKEN_SECRET"),
		RefreshTokenSecret:     get("REFRESH_TOKEN_SECRET"),
		SessionEncryptionKey:   get("SESSION_ENCRYPTION_KEY"),
		CredentialSigningKey:   optional("CREDENTIAL_SIGNING_KEY", ""),
		GoogleClientID:         get("GOOGLE_CLIENT_ID"),
		GoogleClientSecret:     optional("GOOGLE_CLIENT_SECRET", ""),
		GoogleRedirectURI:      optional("GOOGLE_REDIRECT_URI", ""),
		GoogleIOSClientID:      optional("GOOGLE_IOS_CLIENT_ID", ""),
		GoogleAndroidClientID:  optional("GOOGLE_ANDROID_CLIENT_ID", ""),
		AppleBundleID:          optional("APPLE_BUNDLE_ID", ""),
		AppleWebClientID:       optional("APPLE_WEB_CLIENT_ID", ""),
		AppleWebRedirectURI:    optional("APPLE_WEB_REDIRECT_URI", ""),
		AppleKeyID:             optional("APPLE_KEY_ID", ""),
		ApplePrivateKeyPEM:     strings.ReplaceAll(optional("APPLE_PRIVATE_KEY_PEM", ""), `\n`, "\n"),
		AppleTeamID:            optional("APPLE_TEAM_ID", ""),
		WalrusPublisherURL:     optional("WALRUS_PUBLISHER_URL", ""),
		WalrusAggregatorURL:    optional("WALRUS_AGGREGATOR_URL", ""),
		ZkLoginProverURL:       optional("ZKLOGIN_PROVER_URL", "https://prover.variance.space/v1"),
		AppCallbackURL:         optional("APP_CALLBACK_URL", "https://variance.space/callback"),
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
