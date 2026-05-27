package auth

import (
	"encoding/json"
	"io"
	"net/http"
	"net/url"

	"github.com/go-chi/chi/v5"

	apperr "github.com/vaariance/nearby/internal/errors"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) Routes(r chi.Router, rdb interface{}) {
}

func (h *Handler) OAuthBegin(w http.ResponseWriter, r *http.Request) {
	var req OAuthBeginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if req.Provider == "" || req.CodeChallenge == "" || req.ZkLoginNonce == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "provider, codeChallenge, and zkLoginNonce are required")
		return
	}
	if req.CodeChallengeMethod == "" {
		req.CodeChallengeMethod = "S256"
	}

	resp, err := h.svc.OAuthBegin(r.Context(), req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) OAuthComplete(w http.ResponseWriter, r *http.Request) {
	var req OAuthCompleteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	if req.FlowType == "native" {
		if req.IDToken == "" {
			apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "idToken is required for native flow")
			return
		}
	} else {
		if req.Code == "" || req.State == "" || req.CodeVerifier == "" {
			apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "code, state, and codeVerifier are required")
			return
		}
	}
	if req.Platform != "ios" && req.Platform != "android" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "platform must be ios or android")
		return
	}

	resp, err := h.svc.OAuthComplete(r.Context(), req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) RefreshSession(w http.ResponseWriter, r *http.Request) {
	var body struct {
		RefreshToken string `json:"refreshToken"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.RefreshToken == "" {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}

	resp, err := h.svc.RefreshSession(r.Context(), body.RefreshToken)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) RevokeSession(w http.ResponseWriter, r *http.Request) {
	sessCtx := GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, ErrUnauthorized)
		return
	}

	if err := h.svc.RevokeSession(r.Context(), sessCtx); err != nil {
		apperr.Write(w, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) AssertDeviceIntegrity(w http.ResponseWriter, r *http.Request) {
	sessCtx := GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, ErrUnauthorized)
		return
	}

	var req AssertIntegrityRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}
	if req.DeviceIntegrity.Provider == "" || req.TimestampMs == 0 {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "deviceIntegrity.provider and timestampMs are required")
		return
	}

	if err := h.svc.AssertDeviceIntegrity(r.Context(), sessCtx, req); err != nil {
		apperr.Write(w, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) IssueDeviceCredential(w http.ResponseWriter, r *http.Request) {
	sessCtx := GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, ErrUnauthorized)
		return
	}

	var req IssueCredentialRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperr.Write(w, apperr.ErrBadRequest)
		return
	}
	if req.LocalProofPublicKey == "" {
		apperr.WriteStatus(w, http.StatusBadRequest, "validation_error", "localProofPublicKey is required")
		return
	}

	cred, err := h.svc.IssueDeviceCredential(r.Context(), sessCtx, req)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(cred)
}

func (h *Handler) GetServerPublicKey(w http.ResponseWriter, r *http.Request) {
	resp := h.svc.GetServerPublicKey()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *Handler) UploadAvatar(w http.ResponseWriter, r *http.Request) {
	sessCtx := GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, ErrUnauthorized)
		return
	}

	ct := r.Header.Get("Content-Type")
	switch ct {
	case "image/jpeg", "image/png", "image/webp", "image/gif":
	default:
		apperr.WriteStatus(w, http.StatusUnsupportedMediaType, "unsupported_media_type", "content-type must be image/jpeg, image/png, image/webp, or image/gif")
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, 5<<20)
	data, err := io.ReadAll(r.Body)
	if err != nil {
		apperr.WriteStatus(w, http.StatusRequestEntityTooLarge, "payload_too_large", "image must be 5MB or less")
		return
	}

	avatarURL, err := h.svc.UploadAvatar(r.Context(), sessCtx.User.ID, ct, data)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"avatarUrl": avatarURL})
}

func (h *Handler) GetProfile(w http.ResponseWriter, r *http.Request) {
	sessCtx := GetSession(r.Context())
	if sessCtx == nil {
		apperr.Write(w, ErrUnauthorized)
		return
	}

	profile, err := h.svc.GetProfile(r.Context(), sessCtx.User.ID)
	if err != nil {
		apperr.Write(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(profile)
}

func (h *Handler) OAuthCallbackPage(w http.ResponseWriter, r *http.Request) {
	q := url.Values{}
	q.Set("code", r.URL.Query().Get("code"))
	q.Set("state", r.URL.Query().Get("state"))
	http.Redirect(w, r, "/static/auth_test.html?"+q.Encode(), http.StatusFound)
}

var _ = chi.RouteContext
