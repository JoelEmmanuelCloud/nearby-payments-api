package auth

import (
	"bytes"
	"context"
	"crypto"
	"crypto/ed25519"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	_ "crypto/sha256"

	"github.com/redis/go-redis/v9"

	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/utils"
	"github.com/vaariance/nearby/internal/walrus"
)

const (
	accessTokenTTL  = 15 * 60
	refreshTokenTTL = 30 * 24 * 60 * 60
	credentialTTL   = 24 * 60 * 60
	oauthStateTTL   = 10 * time.Minute
)

type ServiceDeps struct {
	Store                 *Store
	Redis                 *redis.Client
	Walrus                *walrus.Client
	GoogleClientID        string
	GoogleClientSecret    string
	GoogleRedirectURI     string
	GoogleIOSClientID     string
	GoogleAndroidClientID string
	AppleBundleID         string
	CredentialSignKey     ed25519.PrivateKey
	CredentialPubKey      ed25519.PublicKey
	ProverURL             string
}

type Service struct {
	store                 *Store
	rdb                   *redis.Client
	walrus                *walrus.Client
	googleClientID        string
	googleClientSecret    string
	googleRedirectURI     string
	googleIOSClientID     string
	googleAndroidClientID string
	appleBundleID         string
	credSignKey           ed25519.PrivateKey
	credPubKey            ed25519.PublicKey
	proverURL             string
	proverClient          *http.Client
	appleJWKSCache        appleJWKSCache
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:                 deps.Store,
		rdb:                   deps.Redis,
		walrus:                deps.Walrus,
		googleClientID:        deps.GoogleClientID,
		googleClientSecret:    deps.GoogleClientSecret,
		googleRedirectURI:     deps.GoogleRedirectURI,
		googleIOSClientID:     deps.GoogleIOSClientID,
		googleAndroidClientID: deps.GoogleAndroidClientID,
		appleBundleID:         deps.AppleBundleID,
		credSignKey:           deps.CredentialSignKey,
		credPubKey:            deps.CredentialPubKey,
		proverURL:             deps.ProverURL,
		proverClient:          &http.Client{Timeout: 60 * time.Second},
	}
}

func (s *Service) OAuthBegin(ctx context.Context, req OAuthBeginRequest) (*OAuthBeginResponse, error) {
	switch req.Provider {
	case "google":
	case "apple":
		if s.appleBundleID == "" {
			return nil, ErrOAuthProviderUnsupported
		}
	default:
		return nil, ErrOAuthProviderUnsupported
	}

	state, err := utils.RandomHex(16)
	if err != nil {
		return nil, apperr.ErrInternal
	}

	stateData := map[string]string{
		"provider":      req.Provider,
		"flow_type":     req.FlowType,
		"zklogin_nonce": req.ZkLoginNonce,
	}
	if req.FlowType == "web" {
		stateData["code_challenge"] = req.CodeChallenge
		stateData["code_challenge_method"] = req.CodeChallengeMethod
	}
	stateJSON, _ := json.Marshal(stateData)
	if err := s.rdb.Set(ctx, "oauth:state:"+state, stateJSON, oauthStateTTL).Err(); err != nil {
		return nil, apperr.ErrInternal
	}

	if req.FlowType == "native" {
		return &OAuthBeginResponse{State: state}, nil
	}

	params := url.Values{
		"client_id":             {s.googleClientID},
		"redirect_uri":          {s.googleRedirectURI},
		"response_type":         {"code"},
		"scope":                 {"openid email profile"},
		"state":                 {state},
		"nonce":                 {req.ZkLoginNonce},
		"code_challenge":        {req.CodeChallenge},
		"code_challenge_method": {req.CodeChallengeMethod},
		"access_type":           {"offline"},
	}

	authURL := "https://accounts.google.com/o/oauth2/v2/auth?" + params.Encode()
	return &OAuthBeginResponse{State: state, AuthURL: authURL}, nil
}

func (s *Service) OAuthComplete(ctx context.Context, req OAuthCompleteRequest) (*OAuthCompleteResponse, error) {
	stateJSON, err := s.rdb.GetDel(ctx, "oauth:state:"+req.State).Bytes()
	if err != nil {
		return nil, ErrOAuthStateMismatch
	}

	var stateData map[string]string
	if err := json.Unmarshal(stateJSON, &stateData); err != nil {
		return nil, ErrOAuthStateMismatch
	}

	provider := stateData["provider"]
	if provider == "" {
		provider = "google"
	}

	var idToken string
	var claims map[string]interface{}
	if req.FlowType == "native" {
		idToken = req.IDToken
		if provider == "apple" {
			claims, err = s.verifyAppleIDToken(ctx, idToken)
		} else {
			claims, err = s.verifyGoogleIDToken(ctx, idToken)
		}
	} else {
		idToken, err = s.exchangeGoogleCode(ctx, req.Code, req.CodeVerifier)
		if err != nil {
			return nil, ErrOAuthFailed
		}
		claims, err = s.verifyGoogleIDToken(ctx, idToken)
	}
	if err != nil {
		return nil, ErrOAuthFailed
	}

	sub, _ := claims["sub"].(string)
	email, _ := claims["email"].(string)
	iss, _ := claims["iss"].(string)
	aud, _ := claims["aud"].(string)

	emailVerified := false
	switch v := claims["email_verified"].(type) {
	case bool:
		emailVerified = v
	case string:
		emailVerified = v == "true"
	}

	if sub == "" || iss == "" || aud == "" {
		return nil, ErrOAuthFailed
	}

	if stateData["zklogin_nonce"] != "" {
		nonceClaim, _ := claims["nonce"].(string)
		if nonceClaim != stateData["zklogin_nonce"] {
			return nil, ErrOAuthFailed
		}
	}

	now := utils.NowUnix()

	existing, err := s.store.GetOAuthIdentity(ctx, iss, sub, aud)
	if err != nil {
		return nil, fmt.Errorf("get oauth identity: %w", err)
	}

	var userID string
	if existing != nil {
		userID = existing.UserID
	} else {
		userID = utils.NewID()
		user := &User{
			ID:        userID,
			Status:    "active",
			CreatedAt: now,
			UpdatedAt: now,
		}
		if err := s.store.CreateUser(ctx, user); err != nil {
			return nil, fmt.Errorf("create user: %w", err)
		}
		oi := &OAuthIdentity{
			ID:            utils.NewID(),
			UserID:        userID,
			Issuer:        iss,
			Subject:       sub,
			Audience:      aud,
			Email:         email,
			EmailVerified: emailVerified,
			CreatedAt:     now,
		}
		if err := s.store.CreateOAuthIdentity(ctx, oi); err != nil {
			return nil, fmt.Errorf("create oauth identity: %w", err)
		}
	}

	user, err := s.store.GetUserByID(ctx, userID)
	if err != nil || user == nil {
		return nil, fmt.Errorf("get user: %w", err)
	}
	if user.Status != "active" {
		return nil, ErrUnauthorized
	}

	salt, err := s.store.GetOrCreateZkLoginSalt(ctx, userID, iss, sub, aud)
	if err != nil {
		return nil, fmt.Errorf("get zklogin salt: %w", err)
	}
	if salt == nil {
		saltHex, err := utils.RandomHex(32)
		if err != nil {
			return nil, apperr.ErrInternal
		}
		salt = &ZkLoginSalt{
			ID:        utils.NewID(),
			UserID:    userID,
			Issuer:    iss,
			Subject:   sub,
			Audience:  aud,
			Salt:      saltHex,
			CreatedAt: now,
		}
		if err := s.store.CreateZkLoginSalt(ctx, salt); err != nil {
			return nil, fmt.Errorf("create zklogin salt: %w", err)
		}
	}

	deviceID := utils.NewID()
	device := &Device{
		ID:          deviceID,
		UserID:      userID,
		Platform:    req.Platform,
		OsVersion:   req.OsVersion,
		AppBundleID: req.AppBundleID,
		Status:      "active",
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	if err := s.store.CreateDevice(ctx, device); err != nil {
		return nil, fmt.Errorf("create device: %w", err)
	}

	integrityID := utils.NewID()
	integrity := &DeviceIntegrityRecord{
		ID:            integrityID,
		DeviceID:      deviceID,
		Provider:      req.DeviceIntegrity.Provider,
		ProviderKeyID: req.DeviceIntegrity.KeyID,
		Status:        "active",
		CreatedAt:     now,
		UpdatedAt:     now,
	}
	if err := s.store.CreateDeviceIntegrityRecord(ctx, integrity); err != nil {
		return nil, fmt.Errorf("create integrity record: %w", err)
	}

	accessToken, err := utils.NewToken()
	if err != nil {
		return nil, apperr.ErrInternal
	}
	refreshToken, err := utils.NewToken()
	if err != nil {
		return nil, apperr.ErrInternal
	}

	expiresAt := now + accessTokenTTL
	refreshExpiresAt := now + refreshTokenTTL

	sess := &Session{
		ID:                utils.NewID(),
		UserID:            userID,
		DeviceID:          deviceID,
		DeviceIntegrityID: integrityID,
		AccessTokenHash:   utils.SHA256HexString(accessToken),
		RefreshTokenHash:  utils.SHA256HexString(refreshToken),
		IssuedAt:          now,
		ExpiresAt:         expiresAt,
		RefreshExpiresAt:  refreshExpiresAt,
		Status:            "active",
	}
	if err := s.store.CreateSession(ctx, sess); err != nil {
		return nil, fmt.Errorf("create session: %w", err)
	}

	return &OAuthCompleteResponse{
		AccessToken:      accessToken,
		RefreshToken:     refreshToken,
		ExpiresAt:        expiresAt,
		RefreshExpiresAt: refreshExpiresAt,
		UserID:           userID,
		JWT:              idToken,
		Salt:             salt.Salt,
	}, nil
}

func (s *Service) BindWallet(ctx context.Context, sessCtx *SessionContext, req BindWalletRequest) error {
	oi, err := s.store.GetOAuthIdentityByUserID(ctx, sessCtx.User.ID)
	if err != nil {
		return fmt.Errorf("get oauth identity: %w", err)
	}
	if oi == nil {
		return ErrUnauthorized
	}

	now := utils.NowUnix()
	wb := &WalletBinding{
		UserID:     sessCtx.User.ID,
		SuiAddress: req.SuiAddress,
		AuthScheme: "zklogin",
		Issuer:     oi.Issuer,
		Audience:   oi.Audience,
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	if err := s.store.UpsertWalletBinding(ctx, wb); err != nil {
		return fmt.Errorf("upsert wallet binding: %w", err)
	}
	return nil
}

func (s *Service) RefreshSession(ctx context.Context, refreshToken string) (*SessionRefreshResponse, error) {
	hash := utils.SHA256HexString(refreshToken)
	sess, err := s.store.GetSessionByRefreshTokenHash(ctx, hash)
	if err != nil {
		return nil, apperr.ErrInternal
	}
	if sess == nil {
		return nil, ErrInvalidToken
	}
	if sess.Status == "revoked" {
		return nil, ErrSessionRevoked
	}
	now := utils.NowUnix()
	if sess.RefreshExpiresAt < now {
		return nil, ErrSessionExpired
	}

	newAccess, err := utils.NewToken()
	if err != nil {
		return nil, apperr.ErrInternal
	}
	newRefresh, err := utils.NewToken()
	if err != nil {
		return nil, apperr.ErrInternal
	}

	expiresAt := now + accessTokenTTL
	refreshExpiresAt := now + refreshTokenTTL

	if err := s.store.UpdateSessionTokens(ctx, sess.ID,
		utils.SHA256HexString(newAccess),
		utils.SHA256HexString(newRefresh),
		expiresAt, refreshExpiresAt,
	); err != nil {
		return nil, fmt.Errorf("update session tokens: %w", err)
	}

	return &SessionRefreshResponse{
		AccessToken:  newAccess,
		RefreshToken: newRefresh,
		ExpiresAt:    expiresAt,
	}, nil
}

func (s *Service) RevokeSession(ctx context.Context, sessCtx *SessionContext) error {
	return s.store.RevokeSession(ctx, sessCtx.Session.ID)
}

func (s *Service) AssertDeviceIntegrity(ctx context.Context, sessCtx *SessionContext, req AssertIntegrityRequest) error {
	if req.DeviceIntegrity.Provider == "" {
		return ErrDeviceNotTrusted
	}
	now := utils.NowUnix()
	if !utils.InWindow(req.TimestampMs/1000, 300) {
		return ErrTimestampOutOfWindow
	}
	integrityID := utils.NewID()
	record := &DeviceIntegrityRecord{
		ID:            integrityID,
		DeviceID:      sessCtx.Device.ID,
		Provider:      req.DeviceIntegrity.Provider,
		ProviderKeyID: req.DeviceIntegrity.KeyID,
		Status:        "active",
		CreatedAt:     now,
		UpdatedAt:     now,
	}
	return s.store.CreateDeviceIntegrityRecord(ctx, record)
}

func (s *Service) IssueDeviceCredential(ctx context.Context, sessCtx *SessionContext, req IssueCredentialRequest) (*DeviceIdentityCredential, error) {
	if req.LocalProofPublicKey == "" {
		return nil, apperr.ErrBadRequest
	}

	wb, err := s.store.GetWalletBinding(ctx, sessCtx.User.ID)
	if err != nil {
		return nil, fmt.Errorf("get wallet binding: %w", err)
	}

	suiAddress := ""
	if wb != nil {
		suiAddress = wb.SuiAddress
	}

	now := utils.NowUnix()
	cred := &DeviceIdentityCredential{
		Version:             1,
		UserID:              sessCtx.User.ID,
		DeviceID:            sessCtx.Device.ID,
		Platform:            sessCtx.Device.Platform,
		AppBundleID:         sessCtx.Device.AppBundleID,
		IntegrityProvider:   sessCtx.Integrity.Provider,
		LocalProofPublicKey: req.LocalProofPublicKey,
		SuiAddress:          suiAddress,
		SuinsName:           req.SuinsName,
		Capabilities: DeviceCredentialCapabilities{
			NearbyPayments: true,
			NearbyAssist:   req.NearbyAssist,
		},
		IssuedAt:  now,
		ExpiresAt: now + credentialTTL,
		Issuer:    "nearby-payments-api",
	}

	sig, err := s.signCredential(cred)
	if err != nil {
		return nil, fmt.Errorf("sign credential: %w", err)
	}
	cred.Signature = sig

	return cred, nil
}

func (s *Service) UploadAvatar(ctx context.Context, userID, contentType string, data []byte) (string, error) {
	blobID, err := s.walrus.UploadBlob(ctx, contentType, data)
	if err != nil {
		return "", fmt.Errorf("walrus upload: %w", err)
	}
	if err := s.store.UpdateUserAvatar(ctx, userID, blobID, utils.NowUnix()); err != nil {
		return "", fmt.Errorf("update user avatar: %w", err)
	}
	return s.walrus.AggregatorURL(blobID), nil
}

func (s *Service) GetProfile(ctx context.Context, userID string) (*UserProfileResponse, error) {
	user, err := s.store.GetUserByID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get user: %w", err)
	}
	if user == nil {
		return nil, ErrUnauthorized
	}
	resp := &UserProfileResponse{
		UserID:    user.ID,
		Status:    user.Status,
		CreatedAt: user.CreatedAt,
	}
	if user.AvatarBlobID != "" {
		resp.AvatarURL = s.walrus.AggregatorURL(user.AvatarBlobID)
	}
	return resp, nil
}

func (s *Service) GetServerPublicKey() ServerPublicKeyResponse {
	return ServerPublicKeyResponse{
		PublicKey: utils.HexEncode(s.credPubKey),
		Format:    "ed25519_hex",
	}
}

func (s *Service) signCredential(cred *DeviceIdentityCredential) (string, error) {
	payload := &DeviceIdentityCredential{
		Version:             cred.Version,
		UserID:              cred.UserID,
		DeviceID:            cred.DeviceID,
		Platform:            cred.Platform,
		AppBundleID:         cred.AppBundleID,
		IntegrityProvider:   cred.IntegrityProvider,
		LocalProofPublicKey: cred.LocalProofPublicKey,
		SuiAddress:          cred.SuiAddress,
		SuinsName:           cred.SuinsName,
		Capabilities:        cred.Capabilities,
		IssuedAt:            cred.IssuedAt,
		ExpiresAt:           cred.ExpiresAt,
		Issuer:              cred.Issuer,
	}
	data, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}
	sig := ed25519.Sign(s.credSignKey, data)
	return utils.Base64URLEncode(sig), nil
}

func (s *Service) exchangeGoogleCode(ctx context.Context, code, codeVerifier string) (string, error) {
	params := url.Values{
		"code":          {code},
		"client_id":     {s.googleClientID},
		"client_secret": {s.googleClientSecret},
		"redirect_uri":  {s.googleRedirectURI},
		"code_verifier": {codeVerifier},
		"grant_type":    {"authorization_code"},
	}

	resp, err := http.PostForm("https://oauth2.googleapis.com/token", params)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("google token exchange failed: status=%d body=%s", resp.StatusCode, string(body))
	}

	idToken, ok := result["id_token"].(string)
	if !ok || idToken == "" {
		return "", fmt.Errorf("no id_token in response")
	}

	return idToken, nil
}

func (s *Service) ProveZkLogin(ctx context.Context, req ZkLoginProveRequest) ([]byte, error) {
	if req.KeyClaimName == "" {
		req.KeyClaimName = "sub"
	}

	body, err := json.Marshal(req)
	if err != nil {
		return nil, apperr.ErrInternal
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, s.proverURL, bytes.NewReader(body))
	if err != nil {
		return nil, apperr.ErrInternal
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := s.proverClient.Do(httpReq)
	if err != nil {
		return nil, ErrProverUnavailable
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, apperr.ErrInternal
	}

	if resp.StatusCode != http.StatusOK {
		return nil, ErrProverUnavailable
	}

	return respBody, nil
}

func (s *Service) verifyGoogleIDToken(ctx context.Context, idToken string) (map[string]interface{}, error) {
	resp, err := http.Get("https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("token verification failed: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var claims map[string]interface{}
	if err := json.Unmarshal(body, &claims); err != nil {
		return nil, err
	}

	aud, _ := claims["aud"].(string)
	allowed := map[string]bool{s.googleClientID: true}
	if s.googleIOSClientID != "" {
		allowed[s.googleIOSClientID] = true
	}
	if s.googleAndroidClientID != "" {
		allowed[s.googleAndroidClientID] = true
	}
	if !allowed[aud] {
		return nil, fmt.Errorf("audience mismatch: %s", aud)
	}

	return claims, nil
}

type appleJWK struct {
	Kty string `json:"kty"`
	Kid string `json:"kid"`
	Alg string `json:"alg"`
	N   string `json:"n"`
	E   string `json:"e"`
}

type appleJWKSCache struct {
	mu        sync.RWMutex
	keys      []appleJWK
	fetchedAt time.Time
}

func (s *Service) verifyAppleIDToken(ctx context.Context, idToken string) (map[string]interface{}, error) {
	parts := strings.Split(idToken, ".")
	if len(parts) != 3 {
		return nil, fmt.Errorf("invalid token format")
	}

	headerJSON, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return nil, fmt.Errorf("decode header: %w", err)
	}
	var header struct {
		Kid string `json:"kid"`
	}
	if err := json.Unmarshal(headerJSON, &header); err != nil {
		return nil, fmt.Errorf("parse header: %w", err)
	}

	key, err := s.fetchAppleJWKSKey(ctx, header.Kid)
	if err != nil {
		return nil, fmt.Errorf("get jwks key: %w", err)
	}

	nBytes, err := base64.RawURLEncoding.DecodeString(key.N)
	if err != nil {
		return nil, fmt.Errorf("decode modulus: %w", err)
	}
	eBytes, err := base64.RawURLEncoding.DecodeString(key.E)
	if err != nil {
		return nil, fmt.Errorf("decode exponent: %w", err)
	}
	pubKey := &rsa.PublicKey{
		N: new(big.Int).SetBytes(nBytes),
		E: int(new(big.Int).SetBytes(eBytes).Int64()),
	}

	signingInput := []byte(parts[0] + "." + parts[1])
	digest := sha256.Sum256(signingInput)
	sig, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return nil, fmt.Errorf("decode signature: %w", err)
	}
	if err := rsa.VerifyPKCS1v15(pubKey, crypto.SHA256, digest[:], sig); err != nil {
		return nil, fmt.Errorf("invalid signature: %w", err)
	}

	payloadJSON, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return nil, fmt.Errorf("decode payload: %w", err)
	}
	var claims map[string]interface{}
	if err := json.Unmarshal(payloadJSON, &claims); err != nil {
		return nil, fmt.Errorf("parse payload: %w", err)
	}

	iss, _ := claims["iss"].(string)
	if iss != "https://appleid.apple.com" {
		return nil, fmt.Errorf("invalid issuer: %s", iss)
	}
	var aud string
	switch v := claims["aud"].(type) {
	case string:
		aud = v
	case []interface{}:
		if len(v) > 0 {
			aud, _ = v[0].(string)
		}
	}
	if aud != s.appleBundleID {
		return nil, fmt.Errorf("invalid audience: %s", aud)
	}
	exp, _ := claims["exp"].(float64)
	if int64(exp) < utils.NowUnix() {
		return nil, fmt.Errorf("token expired")
	}

	if ev, ok := claims["email_verified"].(string); ok {
		claims["email_verified"] = ev == "true"
	}

	return claims, nil
}

func (s *Service) fetchAppleJWKSKey(ctx context.Context, kid string) (*appleJWK, error) {
	s.appleJWKSCache.mu.RLock()
	if s.appleJWKSCache.keys != nil && time.Since(s.appleJWKSCache.fetchedAt) < 24*time.Hour {
		for _, k := range s.appleJWKSCache.keys {
			if k.Kid == kid {
				k := k
				s.appleJWKSCache.mu.RUnlock()
				return &k, nil
			}
		}
	}
	s.appleJWKSCache.mu.RUnlock()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, "https://appleid.apple.com/auth/keys", nil)
	if err != nil {
		return nil, err
	}
	resp, err := s.proverClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetch apple jwks: %w", err)
	}
	defer resp.Body.Close()

	var jwks struct {
		Keys []appleJWK `json:"keys"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return nil, fmt.Errorf("decode apple jwks: %w", err)
	}

	s.appleJWKSCache.mu.Lock()
	s.appleJWKSCache.keys = jwks.Keys
	s.appleJWKSCache.fetchedAt = time.Now()
	s.appleJWKSCache.mu.Unlock()

	for _, k := range jwks.Keys {
		if k.Kid == kid {
			k := k
			return &k, nil
		}
	}
	return nil, fmt.Errorf("key %s not found in apple jwks", kid)
}

func (s *Service) VerifyAccessToken(ctx context.Context, rawToken string) (*SessionContext, error) {
	hash := utils.SHA256HexString(rawToken)
	sess, err := s.store.GetSessionByAccessTokenHash(ctx, hash)
	if err != nil {
		return nil, apperr.ErrInternal
	}
	if sess == nil {
		return nil, ErrInvalidToken
	}

	now := utils.NowUnix()
	if sess.Status == "revoked" {
		return nil, ErrSessionRevoked
	}
	if sess.ExpiresAt < now {
		return nil, ErrSessionExpired
	}

	user, err := s.store.GetUserByID(ctx, sess.UserID)
	if err != nil || user == nil {
		return nil, apperr.ErrInternal
	}
	if user.Status != "active" {
		return nil, ErrUnauthorized
	}

	device, err := s.store.GetDeviceByID(ctx, sess.DeviceID)
	if err != nil || device == nil {
		return nil, apperr.ErrInternal
	}
	if device.Status != "active" {
		return nil, ErrDeviceNotTrusted
	}

	integrity, err := s.store.GetIntegrityRecordByID(ctx, sess.DeviceIntegrityID)
	if err != nil {
		return nil, apperr.ErrInternal
	}

	return &SessionContext{
		Session:   sess,
		User:      user,
		Device:    device,
		Integrity: integrity,
	}, nil
}
