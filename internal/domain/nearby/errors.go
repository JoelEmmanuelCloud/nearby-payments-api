package nearby

import (
	"net/http"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

var (
	ErrSessionNotFound   = apperr.New("session_not_found", "Nearby session not found", http.StatusNotFound)
	ErrSessionExpired    = apperr.New("session_expired", "Nearby session has expired", http.StatusGone)
	ErrSessionNotPending = apperr.New("session_not_pending", "Nearby session is not in a pending state", http.StatusConflict)
	ErrNoWalletBound     = apperr.New("no_wallet_bound", "No Sui wallet bound to this account", http.StatusBadRequest)
	ErrInvalidPayload    = apperr.New("invalid_payload", "Payload type or data is invalid", http.StatusBadRequest)
)
