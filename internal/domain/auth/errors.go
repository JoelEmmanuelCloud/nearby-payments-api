package auth

import (
	"net/http"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

var (
	ErrUnauthorized            = apperr.New("unauthorized", "Unauthorized", http.StatusUnauthorized)
	ErrHighFidelityRequired    = apperr.New("high_fidelity_required", "High fidelity authentication is required", http.StatusForbidden)
	ErrDeviceNotTrusted        = apperr.New("device_not_trusted", "Device is not trusted", http.StatusForbidden)
	ErrDeviceIntegrityUnsupported = apperr.New("device_integrity_unsupported", "This device does not support required app integrity checks", http.StatusForbidden)
	ErrReplayDetected          = apperr.New("replay_detected", "Request replay detected", http.StatusConflict)
	ErrSessionExpired          = apperr.New("session_expired", "Session has expired", http.StatusUnauthorized)
	ErrSessionRevoked          = apperr.New("session_revoked", "Session has been revoked", http.StatusUnauthorized)
	ErrInvalidToken            = apperr.New("invalid_token", "Invalid token", http.StatusUnauthorized)
	ErrOAuthStateMismatch      = apperr.New("oauth_state_mismatch", "OAuth state mismatch", http.StatusBadRequest)
	ErrOAuthFailed             = apperr.New("oauth_failed", "OAuth authentication failed", http.StatusBadRequest)
	ErrOAuthProviderUnsupported = apperr.New("oauth_provider_unsupported", "OAuth provider is not supported", http.StatusBadRequest)
	ErrTimestampOutOfWindow    = apperr.New("timestamp_out_of_window", "Request timestamp is outside allowed window", http.StatusBadRequest)
	ErrBodyHashMismatch        = apperr.New("body_hash_mismatch", "Request body hash does not match", http.StatusBadRequest)
)
