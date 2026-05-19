package deposit

import (
	"context"
	"fmt"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/domain/auth"
	apperr "github.com/JoelEmmanuelCloud/nearby-payments-api/internal/errors"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

type ServiceDeps struct {
	Store            *Store
	FincraClient     *FincraClient
	BlockradarClient *BlockradarClient
	AuthStore        *auth.Store
}

type Service struct {
	store      *Store
	fincra     *FincraClient
	blockradar *BlockradarClient
	authStore  *auth.Store
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:      deps.Store,
		fincra:     deps.FincraClient,
		blockradar: deps.BlockradarClient,
		authStore:  deps.AuthStore,
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

	fiatState, err := s.getFiatNgnState(ctx, userID)
	if err != nil {
		return nil, err
	}

	cryptoState, err := s.getCryptoState(ctx, userID, wallet.SuiAddress)
	if err != nil {
		return nil, err
	}

	return &DepositOptionsResponse{
		FiatNgn: fiatState,
		Crypto:  *cryptoState,
	}, nil
}

func (s *Service) getFiatNgnState(ctx context.Context, userID string) (interface{}, error) {
	now := utils.NowUnix()

	link, err := s.store.GetFincraLinkByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get fincra link: %w", err)
	}

	if link != nil && link.AccountNumber != "" {
		return &NgnAccountState{
			Kind: "account_details",
			Account: NgnAccount{
				AccountNumber: link.AccountNumber,
				AccountName:   link.AccountName,
				BankName:      link.BankName,
				Currency:      "NGN",
			},
		}, nil
	}

	va, err := s.fincra.CreateVirtualAccount(ctx, userID, "Nearby", "User")
	if err != nil {
		return nil, ErrFincraUnavailable
	}

	newLink := &FincraLink{
		UserID:                 userID,
		FincraCustomerID:       va.ID,
		FincraVirtualAccountID: va.ID,
		AccountNumber:          va.AccountNumber,
		AccountName:            va.AccountName,
		BankName:               va.BankName,
		CreatedAt:              now,
		UpdatedAt:              now,
	}
	if err := s.store.UpsertFincraLink(ctx, newLink); err != nil {
		return nil, fmt.Errorf("save fincra link: %w", err)
	}

	return &NgnAccountState{
		Kind: "account_details",
		Account: NgnAccount{
			AccountNumber: va.AccountNumber,
			AccountName:   va.AccountName,
			BankName:      va.BankName,
			Currency:      "NGN",
		},
	}, nil
}

func (s *Service) getCryptoState(ctx context.Context, userID, suiAddress string) (*CryptoDepositState, error) {
	now := utils.NowUnix()
	label := "user-" + userID
	destAddrHash := utils.SHA256HexString(suiAddress)

	type networkConfig struct {
		network  string
		currency string
	}

	configs := []networkConfig{
		{"ethereum", "usdc"},
		{"solana", "usdc"},
		{"tron", "usdt"},
		{"sui", "usdc"},
	}

	routes := make([]CryptoDepositRoute, 0, len(configs))

	for _, cfg := range configs {
		existing, _ := s.store.GetDepositRoute(ctx, userID, "deposit_address", cfg.network, cfg.currency)
		if existing != nil {
			routes = append(routes, CryptoDepositRoute{
				Network:  existing.SourceRail,
				Currency: existing.SourceCurrency,
				Address:  existing.SourceAddress,
			})
			continue
		}

		addr, err := s.blockradar.EnsureDepositAddress(ctx, cfg.network, label)
		if err != nil {
			continue
		}

		dr := &DepositRoute{
			ID:                  utils.NewID(),
			UserID:              userID,
			Provider:            "blockradar",
			ProviderRouteID:     addr.ID,
			Kind:                "deposit_address",
			SourceRail:          cfg.network,
			SourceCurrency:      cfg.currency,
			SourceAddress:       addr.Address,
			DestinationRail:     "sui",
			DestinationCurrency: "usdc",
			DestinationAddrHash: destAddrHash,
			State:               "active",
			CreatedAt:           now,
			UpdatedAt:           now,
		}
		_ = s.store.CreateDepositRoute(ctx, dr)

		routes = append(routes, CryptoDepositRoute{
			Network:  cfg.network,
			Currency: cfg.currency,
			Address:  addr.Address,
		})
	}

	return &CryptoDepositState{
		Kind:   "deposit_addresses",
		Routes: routes,
	}, nil
}
