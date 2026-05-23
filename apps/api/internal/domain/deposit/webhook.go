package deposit

import (
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log/slog"
	"net/http"

	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/utils"
)

type WebhookHandler struct {
	store  *Store
	pubKey *rsa.PublicKey
}

func NewWebhookHandler(store *Store, pemPublicKey string) (*WebhookHandler, error) {
	block, _ := pem.Decode([]byte(pemPublicKey))
	if block == nil {
		return nil, fmt.Errorf("failed to decode PEM block from BRIDGE_WEBHOOK_PUBLIC_KEY")
	}
	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse BRIDGE_WEBHOOK_PUBLIC_KEY: %w", err)
	}
	rsaPub, ok := pub.(*rsa.PublicKey)
	if !ok {
		return nil, fmt.Errorf("BRIDGE_WEBHOOK_PUBLIC_KEY is not an RSA public key")
	}
	return &WebhookHandler{store: store, pubKey: rsaPub}, nil
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
		ID   string          `json:"id"`
		Type string          `json:"type"`
		Data json.RawMessage `json:"data"`
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
	sigBytes, err := base64.StdEncoding.DecodeString(sig)
	if err != nil {
		return false
	}
	digest := sha256.Sum256(body)
	return rsa.VerifyPKCS1v15(h.pubKey, crypto.SHA256, digest[:], sigBytes) == nil
}
