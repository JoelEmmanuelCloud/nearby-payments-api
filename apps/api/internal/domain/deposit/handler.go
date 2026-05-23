package deposit

import (
	"encoding/json"
	"net/http"
	"strconv"

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

func (h *Handler) GetOptions(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	resp, err := h.svc.GetOptions(r.Context(), sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) GetDeposits(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	limit := 20
	offset := 0
	if l := r.URL.Query().Get("limit"); l != "" {
		if v, err := strconv.Atoi(l); err == nil {
			limit = v
		}
	}
	if o := r.URL.Query().Get("offset"); o != "" {
		if v, err := strconv.Atoi(o); err == nil {
			offset = v
		}
	}

	resp, err := h.svc.GetDeposits(r.Context(), sessCtx.User.ID, limit, offset)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) GetDeposit(w http.ResponseWriter, r *http.Request) {
	sessCtx := auth.GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, apperr.ErrUnauthorized)
		return
	}

	id := chi.URLParam(r, "id")

	resp, err := h.svc.GetDeposit(r.Context(), id, sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
