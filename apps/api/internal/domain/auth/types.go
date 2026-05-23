package auth

type User struct {
	ID        string
	Status    string
	CreatedAt int64
	UpdatedAt int64
}

type OAuthIdentity struct {
	ID            string
	UserID        string
	Issuer        string
	Subject       string
	Audience      string
	Email         string
	EmailVerified bool
	CreatedAt     int64
}

type Device struct {
	ID          string
	UserID      string
	Platform    string
	OsVersion   string
	AppBundleID string
	Status      string
	CreatedAt   int64
	UpdatedAt   int64
}

type DeviceIntegrityRecord struct {
	ID            string
	DeviceID      string
	Provider      string
	ProviderKeyID string
	PublicKey     string
	SignCount     int64
	LastVerdict   string
	Status        string
	CreatedAt     int64
	UpdatedAt     int64
}

type Session struct {
	ID                string
	UserID            string
	DeviceID          string
	DeviceIntegrityID string
	AccessTokenHash   string
	RefreshTokenHash  string
	IssuedAt          int64
	ExpiresAt         int64
	RefreshExpiresAt  int64
	Status            string
}

type ZkLoginSalt struct {
	ID        string
	UserID    string
	Issuer    string
	Subject   string
	Audience  string
	Salt      string
	CreatedAt int64
}

type WalletBinding struct {
	UserID     string
	SuiAddress string
	AuthScheme string
	Issuer     string
	Audience   string
	CreatedAt  int64
	UpdatedAt  int64
}

type DeviceIdentityCredential struct {
	Version             int                          `json:"version"`
	UserID              string                       `json:"userId"`
	DeviceID            string                       `json:"deviceId"`
	Platform            string                       `json:"platform"`
	AppBundleID         string                       `json:"appBundleId"`
	IntegrityProvider   string                       `json:"integrityProvider"`
	LocalProofPublicKey string                       `json:"localProofPublicKey"`
	SuiAddress          string                       `json:"suiAddress"`
	SuinsName           string                       `json:"suinsName"`
	Capabilities        DeviceCredentialCapabilities `json:"capabilities"`
	IssuedAt            int64                        `json:"issuedAt"`
	ExpiresAt           int64                        `json:"expiresAt"`
	Issuer              string                       `json:"issuer"`
	Signature           string                       `json:"signature"`
}

type DeviceCredentialCapabilities struct {
	NearbyPayments bool `json:"nearbyPayments"`
	NearbyAssist   bool `json:"nearbyAssist"`
}

type SessionContext struct {
	Session   *Session
	User      *User
	Device    *Device
	Integrity *DeviceIntegrityRecord
}

type OAuthBeginRequest struct {
	Provider            string `json:"provider"`
	CodeChallenge       string `json:"codeChallenge"`
	CodeChallengeMethod string `json:"codeChallengeMethod"`
	ZkLoginNonce        string `json:"zkLoginNonce"`
}

type OAuthBeginResponse struct {
	State   string `json:"state"`
	AuthURL string `json:"authUrl"`
}

type DeviceIntegrityProof struct {
	Provider       string `json:"provider"`
	Assertion      string `json:"assertion"`
	KeyID          string `json:"keyId,omitempty"`
	Nonce          string `json:"nonce"`
	TimestampMs    int64  `json:"timestampMs"`
	RequestHash    string `json:"requestHash,omitempty"`
	IntegrityToken string `json:"integrityToken,omitempty"`
}

type OAuthCompleteRequest struct {
	Code                string               `json:"code"`
	State               string               `json:"state"`
	CodeVerifier        string               `json:"codeVerifier"`
	DeviceIntegrity     DeviceIntegrityProof `json:"deviceIntegrity"`
	LocalProofPublicKey string               `json:"localProofPublicKey"`
	Platform            string               `json:"platform"`
	OsVersion           string               `json:"osVersion"`
	AppBundleID         string               `json:"appBundleId"`
	SuiAddress          string               `json:"suiAddress"`
}

type OAuthCompleteResponse struct {
	AccessToken      string `json:"accessToken"`
	RefreshToken     string `json:"refreshToken"`
	ExpiresAt        int64  `json:"expiresAt"`
	RefreshExpiresAt int64  `json:"refreshExpiresAt"`
	UserID           string `json:"userId"`
	SuiAddress       string `json:"suiAddress"`
	ZkLoginSalt      string `json:"zkLoginSalt"`
}

type SessionRefreshResponse struct {
	AccessToken string `json:"accessToken"`
	ExpiresAt   int64  `json:"expiresAt"`
}

type AssertIntegrityRequest struct {
	DeviceIntegrity DeviceIntegrityProof `json:"deviceIntegrity"`
	TimestampMs     int64                `json:"timestampMs"`
}

type IssueCredentialRequest struct {
	LocalProofPublicKey string `json:"localProofPublicKey"`
	SuinsName           string `json:"suinsName"`
	NearbyAssist        bool   `json:"nearbyAssist"`
}

type ServerPublicKeyResponse struct {
	PublicKey string `json:"publicKey"`
	Format    string `json:"format"`
}
