package auth

import (
	"context"
	"crypto/ed25519"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

const (
	accessTokenTTL  = 15 * 60
	refreshTokenTTL = 30 * 24 * 60 * 60
	credentialTTL   = 24 * 60 * 60
	oauthStateTTL   = 10 * time.Minute
)

type ServiceDeps struct {
	Store            *Store
	Redis            *redis.Client
	GoogleClientID   string
	GoogleClientSecret string
	GoogleRedirectURI  string
	CredentialSignKey  ed25519.PrivateKey
	CredentialPubKey   ed25519.PublicKey
}

type Service struct {
	store            *Store
	rdb              *redis.Client
	googleClientID   string
	googleClientSecret string
	googleRedirectURI  string
	credSignKey      ed25519.PrivateKey
	credPubKey       ed25519.PublicKey
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:             deps.Store,
		rdb:               deps.Redis,
		googleClientID:    deps.GoogleClientID,
		googleClientSecret: deps.GoogleClientSecret,
		googleRedirectURI:  deps.GoogleRedirectURI,
		credSignKey:       deps.CredentialSignKey,
		credPubKey:        deps.CredentialPubKey,
	}
}

func (s *Service) OAuthBegin(ctx context.Context, req OAuthBeginRequest) (*OAuthBeginResponse, error) {
	if req.Provider != "google" {
		return nil, ErrOAuthProviderUnsupported
	}

	state, err := utils.RandomHex(16)
	if err != nil {
		return nil, apperr.ErrInternal
	}

	stateData := map[string]string{
		"code_challenge":        req.CodeChallenge,
		"code_challenge_method": req.CodeChallengeMethod,
		"zklogin_nonce":         req.ZkLoginNonce,
	}
	stateJSON, _ := json.Marshal(stateData)
	if err := s.rdb.Set(ctx, "oauth:state:"+state, stateJSON, oauthStateTTL).Err(); err != nil {
		return nil, apperr.ErrInternal
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

	idToken, err := s.exchangeGoogleCode(ctx, req.Code, req.CodeVerifier)
	if err != nil {
		return nil, ErrOAuthFailed
	}

	claims, err := s.verifyGoogleIDToken(ctx, idToken)
	if err != nil {
		return nil, ErrOAuthFailed
	}

	sub, _ := claims["sub"].(string)
	email, _ := claims["email"].(string)
	emailVerified, _ := claims["email_verified"].(bool)
	iss, _ := claims["iss"].(string)
	aud, _ := claims["aud"].(string)

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

	if req.SuiAddress != "" {
		wb := &WalletBinding{
			UserID:     userID,
			SuiAddress: req.SuiAddress,
			AuthScheme: "zklogin",
			Issuer:     iss,
			Audience:   aud,
			CreatedAt:  now,
			UpdatedAt:  now,
		}
		if err := s.store.UpsertWalletBinding(ctx, wb); err != nil {
			return nil, fmt.Errorf("upsert wallet binding: %w", err)
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
		ID:           integrityID,
		DeviceID:     deviceID,
		Provider:     req.DeviceIntegrity.Provider,
		ProviderKeyID: req.DeviceIntegrity.KeyID,
		Status:       "active",
		CreatedAt:    now,
		UpdatedAt:    now,
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
		SuiAddress:       req.SuiAddress,
		ZkLoginSalt:      salt.Salt,
	}, nil
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
		AccessToken: newAccess,
		ExpiresAt:   expiresAt,
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
		ID:           integrityID,
		DeviceID:     sessCtx.Device.ID,
		Provider:     req.DeviceIntegrity.Provider,
		ProviderKeyID: req.DeviceIntegrity.KeyID,
		Status:       "active",
		CreatedAt:    now,
		UpdatedAt:    now,
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
		return "", fmt.Errorf("google token exchange failed: %d", resp.StatusCode)
	}

	idToken, ok := result["id_token"].(string)
	if !ok || idToken == "" {
		return "", fmt.Errorf("no id_token in response")
	}

	return idToken, nil
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
	if !strings.HasPrefix(aud, s.googleClientID) && aud != s.googleClientID {
		return nil, fmt.Errorf("audience mismatch")
	}

	return claims, nil
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
