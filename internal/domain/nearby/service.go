package nearby

import (
	"context"
	"fmt"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/domain/auth"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

const (
	sessionTTL = 5 * 60
)

var allowedPayloadTypes = map[string]bool{
	"payment_request": true,
	"contact_share":   true,
}

type ServiceDeps struct {
	Store     *Store
	AuthStore *auth.Store
}

type Service struct {
	store     *Store
	authStore *auth.Store
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:     deps.Store,
		authStore: deps.AuthStore,
	}
}

func (s *Service) InitiateSession(ctx context.Context, initiatorUserID string, req InitiateSessionRequest) (*InitiateSessionResponse, error) {
	if !allowedPayloadTypes[req.PayloadType] {
		return nil, ErrInvalidPayload
	}
	if req.PayloadData == "" {
		return nil, ErrInvalidPayload
	}
	if req.RecipientSuiAddress == "" {
		return nil, ErrNoWalletBound
	}

	recipientWB, err := s.authStore.GetWalletBindingBySuiAddress(ctx, req.RecipientSuiAddress)
	if err != nil {
		return nil, fmt.Errorf("get recipient wallet: %w", err)
	}
	if recipientWB == nil {
		return nil, ErrSessionNotFound
	}

	now := utils.NowUnix()
	ns := &NearbySession{
		ID:              utils.NewID(),
		InitiatorUserID: initiatorUserID,
		RecipientUserID: recipientWB.UserID,
		Status:          "pending",
		PayloadType:     req.PayloadType,
		PayloadData:     req.PayloadData,
		CreatedAt:       now,
		UpdatedAt:       now,
		ExpiresAt:       now + sessionTTL,
	}

	if err := s.store.CreateSession(ctx, ns); err != nil {
		return nil, fmt.Errorf("create session: %w", err)
	}

	return &InitiateSessionResponse{
		SessionID:           ns.ID,
		RecipientSuiAddress: req.RecipientSuiAddress,
		PayloadType:         ns.PayloadType,
		Status:              ns.Status,
		ExpiresAt:           ns.ExpiresAt,
	}, nil
}

func (s *Service) GetSession(ctx context.Context, sessionID, userID string) (*GetSessionResponse, error) {
	ns, err := s.store.GetSessionByID(ctx, sessionID)
	if err != nil {
		return nil, fmt.Errorf("get session: %w", err)
	}
	if ns == nil {
		return nil, ErrSessionNotFound
	}
	if ns.InitiatorUserID != userID && ns.RecipientUserID != userID {
		return nil, ErrSessionNotFound
	}
	if ns.ExpiresAt < utils.NowUnix() {
		return nil, ErrSessionExpired
	}

	var initiatorAddr, recipientAddr string

	initiatorWB, err := s.authStore.GetWalletBinding(ctx, ns.InitiatorUserID)
	if err == nil && initiatorWB != nil {
		initiatorAddr = initiatorWB.SuiAddress
	}

	recipientWB, err := s.authStore.GetWalletBinding(ctx, ns.RecipientUserID)
	if err == nil && recipientWB != nil {
		recipientAddr = recipientWB.SuiAddress
	}

	return &GetSessionResponse{
		SessionID:           ns.ID,
		InitiatorSuiAddress: initiatorAddr,
		RecipientSuiAddress: recipientAddr,
		PayloadType:         ns.PayloadType,
		PayloadData:         ns.PayloadData,
		Status:              ns.Status,
		CreatedAt:           ns.CreatedAt,
		ExpiresAt:           ns.ExpiresAt,
	}, nil
}

func (s *Service) AcknowledgeSession(ctx context.Context, sessionID, userID string, req AcknowledgeSessionRequest) (*AcknowledgeSessionResponse, error) {
	ns, err := s.store.GetSessionByID(ctx, sessionID)
	if err != nil {
		return nil, fmt.Errorf("get session: %w", err)
	}
	if ns == nil || ns.RecipientUserID != userID {
		return nil, ErrSessionNotFound
	}
	if ns.Status != "pending" {
		return nil, ErrSessionNotPending
	}
	if ns.ExpiresAt < utils.NowUnix() {
		return nil, ErrSessionExpired
	}

	newStatus := "declined"
	if req.Accept {
		newStatus = "accepted"
	}

	if err := s.store.UpdateSessionStatus(ctx, ns.ID, newStatus, utils.NowUnix()); err != nil {
		return nil, fmt.Errorf("update session: %w", err)
	}

	return &AcknowledgeSessionResponse{
		SessionID: ns.ID,
		Status:    newStatus,
	}, nil
}
