package names

import (
	"net/http"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

var (
	ErrTaskNotFound     = apperr.New("task_not_found", "Name operation task not found", http.StatusNotFound)
	ErrNameInvalid      = apperr.New("name_invalid", "Leaf name is invalid", http.StatusBadRequest)
	ErrParentInvalid    = apperr.New("parent_invalid", "Parent name is invalid", http.StatusBadRequest)
	ErrAVSUnauthorized  = apperr.New("avs_unauthorized", "AVS quorum authorization failed", http.StatusForbidden)
	ErrRegistrationFailed = apperr.New("registration_failed", "Name registration transaction failed", http.StatusBadGateway)
	ErrNoWalletBound    = apperr.New("no_wallet_bound", "No Sui wallet bound to this account", http.StatusBadRequest)
)
