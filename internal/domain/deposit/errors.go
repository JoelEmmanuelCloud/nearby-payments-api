package deposit

import (
	"net/http"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

var (
	ErrFincraUnavailable       = apperr.New("fincra_unavailable", "Fincra service is currently unavailable", http.StatusServiceUnavailable)
	ErrBlockradarUnavailable   = apperr.New("blockradar_unavailable", "Blockradar service is currently unavailable", http.StatusServiceUnavailable)
	ErrWebhookSignatureInvalid = apperr.New("webhook_signature_invalid", "Webhook signature is invalid", http.StatusUnauthorized)
	ErrRouteNotFound           = apperr.New("route_not_found", "Deposit route not found", http.StatusNotFound)
)
