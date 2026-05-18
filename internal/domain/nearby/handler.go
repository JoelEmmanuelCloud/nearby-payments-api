package nearby

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

func (h *Handler) InitiateSession(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	var req InitiateSessionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}
	if req.RecipientSuiAddress == "" || req.PayloadType == "" || req.PayloadData == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "recipientSuiAddress, payloadType, and payloadData are required")
		return
	}

	resp, err := h.svc.InitiateSession(r.Context(), sessCtx.User.ID, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) GetSession(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	sessionID := chi.URLParam(r, "id")
	resp, err := h.svc.GetSession(r.Context(), sessionID, sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) AcknowledgeSession(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	sessionID := chi.URLParam(r, "id")

	var req AcknowledgeSessionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	resp, err := h.svc.AcknowledgeSession(r.Context(), sessionID, sessCtx.User.ID, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
