package apperr

import (
	"encoding/json"
	"net/http"
)

type errorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

func Write(w http.ResponseWriter, err error) {
	var appErr *AppError
	if e, ok := err.(*AppError); ok {
		appErr = e
	} else {
		appErr = ErrInternal
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(appErr.Status)
	json.NewEncoder(w).Encode(errorResponse{
		Code:    appErr.Code,
		Message: appErr.Message,
	})
}

func WriteStatus(w http.ResponseWriter, status int, code, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(errorResponse{Code: code, Message: message})
}
