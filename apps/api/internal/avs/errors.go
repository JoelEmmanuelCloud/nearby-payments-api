package avs

import (
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
)

var (
	ErrActionForbidden      = apperr.New("avs_action_forbidden", "AVS action is not allowed", http.StatusForbidden)
	ErrQuorumNotMet         = apperr.New("avs_quorum_not_met", "AVS signature quorum could not be reached", http.StatusServiceUnavailable)
	ErrAuthorizationExpired = apperr.New("avs_authorization_expired", "AVS authorization has expired", http.StatusGone)
	ErrInvalidPayload       = apperr.New("avs_invalid_payload", "AVS payload is invalid", http.StatusBadRequest)
)
