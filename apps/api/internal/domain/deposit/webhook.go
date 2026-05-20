package deposit

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/utils"
)

type WebhookHandler struct {
	store                   *Store
	fincraWebhookSecret     string
	blockradarWebhookSecret string
}

func NewWebhookHandler(store *Store, fincraSecret, blockradarSecret string) *WebhookHandler {
	return &WebhookHandler{
		store:                   store,
		fincraWebhookSecret:     fincraSecret,
		blockradarWebhookSecret: blockradarSecret,
	}
}

func (h *WebhookHandler) HandleFincraWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if !h.verifyFincraSignature(r, body) {
		apperr.Write(w, ErrWebhookSignatureInvalid)
		return
	}

	var envelope struct {
		Event string          `json:"event"`
		Data  json.RawMessage `json:"data"`
	}
	if err := json.Unmarshal(body, &envelope); err != nil || envelope.Event == "" {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	var dataID struct {
		ID string `json:"_id"`
	}
	_ = json.Unmarshal(envelope.Data, &dataID)
	providerEventID := dataID.ID
	if providerEventID == "" {
		providerEventID = utils.SHA256Hex(body)
	}

	h.recordEvent(w, r, "fincra", providerEventID, envelope.Event, body)
}

func (h *WebhookHandler) HandleBlockradarWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if !h.verifyBlockradarSignature(r, body) {
		apperr.Write(w, ErrWebhookSignatureInvalid)
		return
	}

	var envelope struct {
		Event string          `json:"event"`
		Data  json.RawMessage `json:"data"`
	}
	if err := json.Unmarshal(body, &envelope); err != nil || envelope.Event == "" {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	var dataID struct {
		ID string `json:"id"`
	}
	_ = json.Unmarshal(envelope.Data, &dataID)
	providerEventID := dataID.ID
	if providerEventID == "" {
		providerEventID = utils.SHA256Hex(body)
	}

	h.recordEvent(w, r, "blockradar", providerEventID, envelope.Event, body)
}

func (h *WebhookHandler) recordEvent(w http.ResponseWriter, r *http.Request, provider, providerEventID, eventType string, body []byte) {
	exists, err := h.store.WebhookEventExists(r.Context(), providerEventID)
	if err != nil {
		apperr.Write(w, apperr.ErrInternal)
		return
	}
	if exists {
		w.WriteHeader(http.StatusOK)
		return
	}

	ev := &WebhookEvent{
		ID:              utils.NewID(),
		Provider:        provider,
		ProviderEventID: providerEventID,
		EventType:       eventType,
		RawPayload:      body,
		Processed:       false,
		CreatedAt:       utils.NowUnix(),
	}

	if err := h.store.InsertWebhookEvent(r.Context(), ev); err != nil {
		slog.Error("failed to insert webhook event",
			"provider", provider,
			"provider_event_id", providerEventID,
			"error", err,
		)
		apperr.Write(w, apperr.ErrInternal)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *WebhookHandler) verifyFincraSignature(r *http.Request, body []byte) bool {
	sig := r.Header.Get("x-webhook-signature")
	if sig == "" {
		return false
	}
	mac := hmac.New(sha512.New, []byte(h.fincraWebhookSecret))
	mac.Write(body)
	expected := hex.EncodeToString(mac.Sum(nil))
	return hmac.Equal([]byte(sig), []byte(expected))
}

func (h *WebhookHandler) verifyBlockradarSignature(r *http.Request, body []byte) bool {
	sig := r.Header.Get("x-blockradar-signature")
	if sig == "" {
		return false
	}
	mac := hmac.New(sha256.New, []byte(h.blockradarWebhookSecret))
	mac.Write(body)
	expected := hex.EncodeToString(mac.Sum(nil))
	return hmac.Equal([]byte(sig), []byte(expected))
}
