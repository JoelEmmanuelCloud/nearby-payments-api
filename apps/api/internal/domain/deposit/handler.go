package deposit

import (
	"encoding/json"
	"net/http"

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
