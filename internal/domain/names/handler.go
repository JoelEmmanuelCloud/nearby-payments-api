package names

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/vaariance/nearby/internal/domain/auth"
	apperr "github.com/vaariance/nearby/internal/errors"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) RegisterLeaf(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	var req RegisterLeafRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}
	if req.LeafName == "" || req.ParentName == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "leafName and parentName are required")
		return
	}

	resp, err := h.svc.RegisterLeaf(r.Context(), sessCtx.User.ID, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) GetTask(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	taskID := chi.URLParam(r, "id")
	resp, err := h.svc.GetTask(r.Context(), taskID, sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
