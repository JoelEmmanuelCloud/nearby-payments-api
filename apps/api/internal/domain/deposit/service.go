package deposit

import (
	"context"
	"fmt"

	"github.com/vaariance/nearby/internal/domain/auth"
	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/utils"
)

type ServiceDeps struct {
	Store        *Store
	BridgeClient *BridgeClient
	AuthStore    *auth.Store
}

type Service struct {
	store     *Store
	bridge    *BridgeClient
	authStore *auth.Store
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:     deps.Store,
		bridge:    deps.BridgeClient,
		authStore: deps.AuthStore,
	}
}

func (s *Service) GetOptions(ctx context.Context, userID string) (*DepositOptionsResponse, error) {
	wallet, err := s.authStore.GetWalletBinding(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get wallet binding: %w", err)
	}
	if wallet == nil {
		return nil, apperr.ErrUnprocessable
	}

	fiatState, err := s.getFiatUsdState(ctx, userID, wallet.SuiAddress)
	if err != nil {
		return nil, err
	}

	cryptoState, err := s.getCryptoState(ctx, userID, wallet.SuiAddress)
	if err != nil {
		return nil, err
	}

	return &DepositOptionsResponse{
		FiatUsd: fiatState,
		Crypto:  *cryptoState,
	}, nil
}

func (s *Service) getFiatUsdState(ctx context.Context, userID, suiAddress string) (any, error) {
	now := utils.NowUnix()

	link, err := s.store.GetBridgeLinkByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get bridge link: %w", err)
	}

	if link == nil || link.BridgeCustomerID == "" || link.BridgeKycLinkID == "" {
		kycLink, err := s.bridge.CreateHostedKycLink(ctx, userID, "individual", "base")
		if err != nil {
			return nil, ErrBridgeUnavailable
		}

		newLink := &BridgeLink{
			UserID:           userID,
			BridgeCustomerID: kycLink.CustomerID,
			BridgeKycLinkID:  kycLink.ID,
			CreatedAt:        now,
			UpdatedAt:        now,
		}
		if err := s.store.UpsertBridgeLink(ctx, newLink); err != nil {
			return nil, fmt.Errorf("save bridge link: %w", err)
		}

		return &KycRequiredState{
			Kind:            "kyc_required",
			BridgeKycLinkID: kycLink.ID,
			KycURL:          kycLink.KycURL,
			TosURL:          kycLink.TosURL,
			Status:          kycLink.Status,
		}, nil
	}

	eligibility, err := s.bridge.GetCustomerEligibility(ctx, link.BridgeCustomerID)
	if err != nil {
		kycLink, kycErr := s.bridge.GetKycLink(ctx, link.BridgeKycLinkID)
		if kycErr != nil {
			return nil, ErrBridgeUnavailable
		}
		return &KycRequiredState{
			Kind:            "kyc_required",
			BridgeKycLinkID: kycLink.ID,
			KycURL:          kycLink.KycURL,
			TosURL:          kycLink.TosURL,
			Status:          kycLink.Status,
		}, nil
	}

	if eligibility.KycStatus == "approved" && eligibility.Endorsed {
		va, err := s.bridge.EnsureVirtualAccount(ctx, link.BridgeCustomerID, suiAddress)
		if err != nil {
			return nil, ErrBridgeUnavailable
		}

		existing, _ := s.store.GetDepositRoute(ctx, userID, "virtual_account", "fiat", "usd")
		if existing == nil {
			dr := &DepositRoute{
				ID:                  utils.NewID(),
				UserID:              userID,
				Provider:            "bridge",
				ProviderRouteID:     va.ID,
				Kind:                "virtual_account",
				SourceRail:          "fiat",
				SourceCurrency:      "usd",
				SourceAddress:       "",
				DestinationRail:     "sui",
				DestinationCurrency: "usdc",
				DestinationAddrHash: utils.SHA256HexString(suiAddress),
				State:               "active",
				CreatedAt:           now,
				UpdatedAt:           now,
			}
			_ = s.store.CreateDepositRoute(ctx, dr)
		}

		return &AccountDetailsState{
			Kind: "account_details",
			Account: UsdAccount{
				ID:                 va.ID,
				Currency:           "usd",
				Rails:              va.Rails,
				BankName:           va.BankName,
				AccountNumberLast4: va.AccountNumberLast4,
				RoutingNumber:      va.RoutingNumber,
				AccountHolderName:  va.AccountHolderName,
			},
		}, nil
	}

	kycLink, err := s.bridge.GetKycLink(ctx, link.BridgeKycLinkID)
	if err != nil {
		return nil, ErrBridgeUnavailable
	}

	switch eligibility.KycStatus {
	case "under_review", "awaiting_questionnaire", "awaiting_ubo":
		return &KycPendingState{
			Kind:            "kyc_pending",
			BridgeKycLinkID: link.BridgeKycLinkID,
			Status:          eligibility.KycStatus,
		}, nil
	default:
		return &KycRequiredState{
			Kind:            "kyc_required",
			BridgeKycLinkID: kycLink.ID,
			KycURL:          kycLink.KycURL,
			TosURL:          kycLink.TosURL,
			Status:          eligibility.KycStatus,
		}, nil
	}
}

func (s *Service) getCryptoState(ctx context.Context, userID, suiAddress string) (*CryptoDepositState, error) {
	now := utils.NowUnix()
	link, _ := s.store.GetBridgeLinkByUserID(ctx, userID)
	if link == nil || link.BridgeCustomerID == "" {
		return &CryptoDepositState{
			Kind:   "deposit_addresses",
			Routes: []CryptoDepositRoute{},
		}, nil
	}

	type routeConfig struct {
		chain    string
		currency string
		rail     string
	}

	configs := []routeConfig{
		{"evm", "usdc", "evm"},
		{"solana", "usdc", "solana"},
		{"solana", "usdt", "solana"},
	}

	routes := make([]CryptoDepositRoute, 0, len(configs))

	for _, cfg := range configs {
		existing, _ := s.store.GetDepositRoute(ctx, userID, "liquidation_address", cfg.chain, cfg.currency)
		if existing != nil {
			routes = append(routes, buildCryptoRoute(existing))
			continue
		}

		la, err := s.bridge.EnsureLiquidationAddress(ctx, link.BridgeCustomerID, cfg.chain, cfg.currency, suiAddress)
		if err != nil {
			continue
		}

		dr := &DepositRoute{
			ID:                  utils.NewID(),
			UserID:              userID,
			Provider:            "bridge",
			ProviderRouteID:     la.ID,
			Kind:                "liquidation_address",
			SourceRail:          cfg.chain,
			SourceCurrency:      cfg.currency,
			SourceAddress:       la.Address,
			DestinationRail:     "sui",
			DestinationCurrency: "usdc",
			DestinationAddrHash: utils.SHA256HexString(suiAddress),
			State:               "active",
			CreatedAt:           now,
			UpdatedAt:           now,
		}
		_ = s.store.CreateDepositRoute(ctx, dr)

		routes = append(routes, CryptoDepositRoute{
			Rail:     cfg.rail,
			Currency: cfg.currency,
			Address:  la.Address,
		})
	}

	return &CryptoDepositState{
		Kind:   "deposit_addresses",
		Routes: routes,
	}, nil
}

func buildCryptoRoute(dr *DepositRoute) CryptoDepositRoute {
	route := CryptoDepositRoute{
		Rail:     dr.SourceRail,
		Currency: dr.SourceCurrency,
		Address:  dr.SourceAddress,
	}
	if dr.SourceRail == "evm" {
		route.SupportedChains = []string{"ethereum", "base", "polygon", "arbitrum", "optimism", "avalanche_c_chain"}
	}
	return route
}

func (s *Service) GetDeposits(ctx context.Context, userID string, limit, offset int) (*ListDepositsResponse, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	deposits, err := s.store.GetDepositsByUserID(ctx, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("get deposits: %w", err)
	}
	summaries := make([]DepositSummary, 0, len(deposits))
	for _, d := range deposits {
		summaries = append(summaries, DepositSummary{
			ID:        d.ID,
			Kind:      d.Kind,
			Status:    d.Status,
			Amount:    d.Amount,
			Currency:  d.Currency,
			TxHash:    d.TxHash,
			CreatedAt: d.CreatedAt,
			UpdatedAt: d.UpdatedAt,
		})
	}
	return &ListDepositsResponse{Deposits: summaries}, nil
}

func (s *Service) GetDeposit(ctx context.Context, id, userID string) (*DepositSummary, error) {
	d, err := s.store.GetDepositByID(ctx, id, userID)
	if err != nil {
		return nil, fmt.Errorf("get deposit: %w", err)
	}
	if d == nil {
		return nil, ErrRouteNotFound
	}
	return &DepositSummary{
		ID:        d.ID,
		Kind:      d.Kind,
		Status:    d.Status,
		Amount:    d.Amount,
		Currency:  d.Currency,
		TxHash:    d.TxHash,
		CreatedAt: d.CreatedAt,
		UpdatedAt: d.UpdatedAt,
	}, nil
}
