package payment

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/sui"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

const (
	intentTTL       = 2 * 60
	supportedAsset  = "USDsui"
)

type ServiceDeps struct {
	Store     *Store
	SuiClient *sui.Client
	Sponsor   *sui.Sponsor
}

type Service struct {
	store     *Store
	suiClient *sui.Client
	sponsor   *sui.Sponsor
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:     deps.Store,
		suiClient: deps.SuiClient,
		sponsor:   deps.Sponsor,
	}
}

func (s *Service) CreateIntent(ctx context.Context, userID string, req CreateIntentRequest) (*CreateIntentResponse, error) {
	if req.Asset != supportedAsset {
		return nil, ErrAssetUnsupported
	}
	if req.AmountAtomic == "" || req.AmountAtomic == "0" {
		return nil, ErrInvalidAmount
	}
	if !strings.HasPrefix(req.RecipientAddress, "0x") || len(req.RecipientAddress) != 66 {
		return nil, ErrInvalidAddress
	}
	if req.IdempotencyKey == "" {
		return nil, ErrInvalidAmount
	}

	existing, err := s.store.GetIntentByIdempotencyKey(ctx, req.IdempotencyKey)
	if err != nil {
		return nil, fmt.Errorf("check idempotency: %w", err)
	}
	if existing != nil {
		return toCreateIntentResponse(existing, s.sponsor.Address()), nil
	}

	now := utils.NowUnix()
	fundingMode := req.FundingMode
	if fundingMode == "" {
		fundingMode = "user_paid"
	}

	sponsorAddr := ""
	if fundingMode == "sponsored" {
		sponsorAddr = s.sponsor.Address()
	}

	pi := &PaymentIntent{
		ID:               utils.NewID(),
		UserID:           userID,
		IdempotencyKey:   req.IdempotencyKey,
		RecipientAddress: req.RecipientAddress,
		RecipientName:    req.RecipientName,
		Asset:            req.Asset,
		AmountAtomic:     req.AmountAtomic,
		Status:           "pending",
		SponsorAddress:   sponsorAddr,
		FundingMode:      fundingMode,
		CreatedAt:        now,
		UpdatedAt:        now,
		ExpiresAt:        now + intentTTL,
	}

	if err := s.store.CreateIntent(ctx, pi); err != nil {
		return nil, fmt.Errorf("create intent: %w", err)
	}

	return toCreateIntentResponse(pi, sponsorAddr), nil
}

func (s *Service) GetIntent(ctx context.Context, intentID, userID string) (*GetIntentResponse, error) {
	pi, err := s.store.GetIntentByID(ctx, intentID)
	if err != nil {
		return nil, fmt.Errorf("get intent: %w", err)
	}
	if pi == nil || pi.UserID != userID {
		return nil, ErrIntentNotFound
	}

	return &GetIntentResponse{
		IntentID:         pi.ID,
		Status:           pi.Status,
		RecipientAddress: pi.RecipientAddress,
		Asset:            pi.Asset,
		AmountAtomic:     pi.AmountAtomic,
		TxDigest:         pi.TxDigest,
		CreatedAt:        pi.CreatedAt,
		ExpiresAt:        pi.ExpiresAt,
	}, nil
}

func (s *Service) SubmitIntent(ctx context.Context, intentID, userID string, req SubmitIntentRequest) (*SubmitIntentResponse, error) {
	pi, err := s.store.GetIntentByID(ctx, intentID)
	if err != nil {
		return nil, fmt.Errorf("get intent: %w", err)
	}
	if pi == nil || pi.UserID != userID {
		return nil, ErrIntentNotFound
	}
	if pi.Status != "pending" {
		return nil, ErrIntentNotPending
	}
	if pi.ExpiresAt < utils.NowUnix() {
		return nil, ErrIntentExpired
	}

	txBytes, err := base64.StdEncoding.DecodeString(req.TxBytes)
	if err != nil {
		return nil, fmt.Errorf("decode tx bytes: %w", err)
	}

	var execResp *sui.ExecuteTransactionResponse

	switch pi.FundingMode {
	case "sponsored":
		execResp, err = s.sponsor.SubmitSponsoredTransaction(ctx, txBytes, req.UserSignature)
	default:
		execResp, err = s.sponsor.RelayUserTransaction(ctx, txBytes, req.UserSignature)
	}

	if err != nil {
		_ = s.store.UpdateIntentStatus(ctx, pi.ID, "failed", "", utils.NowUnix())
		return nil, ErrSubmitFailed
	}

	now := utils.NowUnix()
	_ = s.store.UpdateIntentStatus(ctx, pi.ID, "submitted", execResp.Digest, now)

	payment := &Payment{
		ID:               utils.NewID(),
		IntentID:         pi.ID,
		UserID:           userID,
		RecipientAddress: pi.RecipientAddress,
		Asset:            pi.Asset,
		AmountAtomic:     pi.AmountAtomic,
		TxDigest:         execResp.Digest,
		Status:           "confirmed",
		ConfirmedAt:      now,
		CreatedAt:        now,
	}
	_ = s.store.CreatePayment(ctx, payment)

	return &SubmitIntentResponse{
		PaymentID: payment.ID,
		TxDigest:  execResp.Digest,
		Status:    "confirmed",
	}, nil
}

func (s *Service) CancelIntent(ctx context.Context, intentID, userID string) error {
	pi, err := s.store.GetIntentByID(ctx, intentID)
	if err != nil {
		return fmt.Errorf("get intent: %w", err)
	}
	if pi == nil || pi.UserID != userID {
		return ErrIntentNotFound
	}
	if pi.Status != "pending" {
		return ErrIntentNotPending
	}
	return s.store.UpdateIntentStatus(ctx, pi.ID, "cancelled", "", utils.NowUnix())
}

func (s *Service) GetPayment(ctx context.Context, paymentID, userID string) (*GetPaymentResponse, error) {
	p, err := s.store.GetPaymentByID(ctx, paymentID)
	if err != nil {
		return nil, fmt.Errorf("get payment: %w", err)
	}
	if p == nil || p.UserID != userID {
		return nil, ErrPaymentNotFound
	}

	return &GetPaymentResponse{
		PaymentID:        p.ID,
		IntentID:         p.IntentID,
		RecipientAddress: p.RecipientAddress,
		Asset:            p.Asset,
		AmountAtomic:     p.AmountAtomic,
		TxDigest:         p.TxDigest,
		Status:           p.Status,
		ConfirmedAt:      p.ConfirmedAt,
		CreatedAt:        p.CreatedAt,
	}, nil
}

func toCreateIntentResponse(pi *PaymentIntent, sponsorAddr string) *CreateIntentResponse {
	return &CreateIntentResponse{
		IntentID:         pi.ID,
		RecipientAddress: pi.RecipientAddress,
		Asset:            pi.Asset,
		AmountAtomic:     pi.AmountAtomic,
		FundingMode:      pi.FundingMode,
		SponsorAddress:   sponsorAddr,
		Status:           pi.Status,
		ExpiresAt:        pi.ExpiresAt,
	}
}
