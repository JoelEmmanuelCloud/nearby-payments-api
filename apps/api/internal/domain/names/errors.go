package names

import (
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
)

var (
	ErrTaskNotFound       = apperr.New("task_not_found", "Name operation task not found", http.StatusNotFound)
	ErrTaskNotSubmittable = apperr.New("task_not_submittable", "Name operation task is not in a submittable state", http.StatusConflict)
	ErrTaskExpired        = apperr.New("task_expired", "Name operation task has expired", http.StatusGone)
	ErrNameInvalid        = apperr.New("name_invalid", "Leaf name is invalid", http.StatusBadRequest)
	ErrAVSUnauthorized    = apperr.New("avs_unauthorized", "AVS quorum authorization failed", http.StatusForbidden)
	ErrRegistrationFailed = apperr.New("registration_failed", "Name registration transaction failed", http.StatusBadGateway)
	ErrNoWalletBound      = apperr.New("no_wallet_bound", "No Sui wallet bound to this account", http.StatusBadRequest)
	ErrSuiNSUnavailable   = apperr.New("suins_unavailable", "SuiNS name service is unavailable", http.StatusServiceUnavailable)
)
