package deposit

import (
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
)

var (
	ErrBridgeUnavailable       = apperr.New("bridge_unavailable", "Bridge service is currently unavailable", http.StatusServiceUnavailable)
	ErrKycNotApproved          = apperr.New("kyc_not_approved", "KYC verification is not yet approved", http.StatusForbidden)
	ErrWebhookSignatureInvalid = apperr.New("webhook_signature_invalid", "Webhook signature is invalid", http.StatusUnauthorized)
	ErrWebhookDuplicate        = apperr.New("webhook_duplicate", "Webhook event already processed", http.StatusConflict)
	ErrRouteNotFound           = apperr.New("route_not_found", "Deposit route not found", http.StatusNotFound)
	ErrUnsupportedNetwork      = apperr.New("unsupported_network", "Network or currency combination is not supported", http.StatusBadRequest)
	ErrNoBridgeCustomer        = apperr.New("no_bridge_customer", "KYC must be initiated before requesting a deposit address", http.StatusForbidden)
)
