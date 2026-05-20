package payment

import (
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
)

var (
	ErrIntentNotFound     = apperr.New("intent_not_found", "Payment intent not found", http.StatusNotFound)
	ErrIntentExpired      = apperr.New("intent_expired", "Payment intent has expired", http.StatusGone)
	ErrIntentNotPending   = apperr.New("intent_not_pending", "Payment intent is not in a submittable state", http.StatusConflict)
	ErrPaymentNotFound    = apperr.New("payment_not_found", "Payment not found", http.StatusNotFound)
	ErrAssetUnsupported   = apperr.New("asset_unsupported", "Asset is not supported", http.StatusBadRequest)
	ErrSubmitFailed       = apperr.New("submit_failed", "Transaction submission failed", http.StatusBadGateway)
	ErrInvalidAmount      = apperr.New("invalid_amount", "Amount is invalid", http.StatusBadRequest)
	ErrInvalidAddress     = apperr.New("invalid_address", "Recipient address is invalid", http.StatusBadRequest)
)
