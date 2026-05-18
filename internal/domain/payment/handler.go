package payment

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/domain/auth"
	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) CreateIntent(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	var req CreateIntentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if req.RecipientAddress == "" || req.Asset == "" || req.AmountAtomic == "" || req.IdempotencyKey == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "recipientAddress, asset, amountAtomic, and idempotencyKey are required")
		return
	}

	resp, err := h.svc.CreateIntent(r.Context(), sessCtx.User.ID, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) GetIntent(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	intentID := chi.URLParam(r, "id")
	resp, err := h.svc.GetIntent(r.Context(), intentID, sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) SubmitIntent(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	intentID := chi.URLParam(r, "id")

	var req SubmitIntentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}
	if req.TxBytes == "" || req.UserSignature == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "txBytes and userSignature are required")
		return
	}

	resp, err := h.svc.SubmitIntent(r.Context(), intentID, sessCtx.User.ID, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) CancelIntent(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	intentID := chi.URLParam(r, "id")
	if err := h.svc.CancelIntent(r.Context(), intentID, sessCtx.User.ID); err != nil {
		apperr.Write(w, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) GetPayment(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	paymentID := chi.URLParam(r, "id")
	resp, err := h.svc.GetPayment(r.Context(), paymentID, sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
