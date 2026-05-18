package deposit

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"

	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

type WebhookHandler struct {
	store         *Store
	webhookSecret string
}

func NewWebhookHandler(store *Store, webhookSecret string) *WebhookHandler {
	return &WebhookHandler{store: store, webhookSecret: webhookSecret}
}

func (h *WebhookHandler) HandleBridgeWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if !h.verifySignature(r, body) {
		apperr.Write(w, ErrWebhookSignatureInvalid)
		return
	}

	var envelope struct {
		ID        string          `json:"id"`
		Type      string          `json:"type"`
		Data      json.RawMessage `json:"data"`
	}
	if err := json.Unmarshal(body, &envelope); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if envelope.ID == "" || envelope.Type == "" {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	exists, err := h.store.WebhookEventExists(r.Context(), envelope.ID)
	if err != nil {
		apperr.Write(w, apperr.ErrInternal)
		return
	}
	if exists {
		w.WriteHeader(http.StatusOK)
		return
	}

	ev := &BridgeWebhookEvent{
		ID:              utils.NewID(),
		ProviderEventID: envelope.ID,
		EventType:       envelope.Type,
		RawPayload:      body,
		Processed:       false,
		CreatedAt:       utils.NowUnix(),
	}

	if err := h.store.InsertWebhookEvent(r.Context(), ev); err != nil {
		slog.Error("failed to insert webhook event",
			"provider_event_id", envelope.ID,
			"error", err,
		)
		apperr.Write(w, apperr.ErrInternal)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *WebhookHandler) verifySignature(r *http.Request, body []byte) bool {
	sig := r.Header.Get("X-Bridge-Signature")
	if sig == "" {
		return false
	}

	mac := hmac.New(sha256.New, []byte(h.webhookSecret))
	mac.Write(body)
	expected := hex.EncodeToString(mac.Sum(nil))

	return hmac.Equal([]byte(sig), []byte(expected))
}
