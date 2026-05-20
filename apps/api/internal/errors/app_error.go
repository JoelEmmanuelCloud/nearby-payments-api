package apperr

import "net/http"

type AppError struct {
	Code    string
	Message string
	Status  int
}

func (e *AppError) Error() string {
	return e.Message
}

func New(code, message string, status int) *AppError {
	return &AppError{Code: code, Message: message, Status: status}
}

var (
	ErrUnauthorized    = New("unauthorized", "Unauthorized", http.StatusUnauthorized)
	ErrForbidden       = New("forbidden", "Forbidden", http.StatusForbidden)
	ErrNotFound        = New("not_found", "Not found", http.StatusNotFound)
	ErrBadRequest      = New("bad_request", "Bad request", http.StatusBadRequest)
	ErrConflict        = New("conflict", "Conflict", http.StatusConflict)
	ErrUnprocessable   = New("unprocessable", "Unprocessable entity", http.StatusUnprocessableEntity)
	ErrInternal        = New("internal_error", "Internal server error", http.StatusInternalServerError)
	ErrServiceUnavail  = New("service_unavailable", "Service temporarily unavailable", http.StatusServiceUnavailable)
)

func IsNotFound(err error) bool {
	if e, ok := err.(*AppError); ok {
		return e.Status == http.StatusNotFound
	}
	return false
}
