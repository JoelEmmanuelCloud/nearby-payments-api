package deposit

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct {
	db *pgxpool.Pool
}

func NewStore(db *pgxpool.Pool) *Store {
	return &Store{db: db}
}

func (s *Store) GetFincraLinkByUserID(ctx context.Context, userID string) (*FincraLink, error) {
	fl := &FincraLink{}
	err := s.db.QueryRow(ctx,
		`SELECT user_id, fincra_customer_id, fincra_virtual_account_id, account_number, account_name, bank_name, created_at, updated_at
		 FROM fincra_links WHERE user_id = $1`,
		userID,
	).Scan(&fl.UserID, &fl.FincraCustomerID, &fl.FincraVirtualAccountID, &fl.AccountNumber, &fl.AccountName, &fl.BankName, &fl.CreatedAt, &fl.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return fl, err
}

func (s *Store) UpsertFincraLink(ctx context.Context, fl *FincraLink) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO fincra_links (user_id, fincra_customer_id, fincra_virtual_account_id, account_number, account_name, bank_name, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		 ON CONFLICT (user_id) DO UPDATE SET
		   fincra_customer_id = EXCLUDED.fincra_customer_id,
		   fincra_virtual_account_id = EXCLUDED.fincra_virtual_account_id,
		   account_number = EXCLUDED.account_number,
		   account_name = EXCLUDED.account_name,
		   bank_name = EXCLUDED.bank_name,
		   updated_at = EXCLUDED.updated_at`,
		fl.UserID, fl.FincraCustomerID, fl.FincraVirtualAccountID, fl.AccountNumber, fl.AccountName, fl.BankName, fl.CreatedAt, fl.UpdatedAt,
	)
	return err
}

func (s *Store) GetDepositRoute(ctx context.Context, userID, kind, sourceRail, sourceCurrency string) (*DepositRoute, error) {
	dr := &DepositRoute{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, provider, provider_route_id, kind, source_rail, source_currency, source_address,
		        destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at
		 FROM deposit_routes
		 WHERE user_id = $1 AND kind = $2 AND source_rail = $3 AND source_currency = $4
		 ORDER BY created_at DESC LIMIT 1`,
		userID, kind, sourceRail, sourceCurrency,
	).Scan(&dr.ID, &dr.UserID, &dr.Provider, &dr.ProviderRouteID, &dr.Kind,
		&dr.SourceRail, &dr.SourceCurrency, &dr.SourceAddress, &dr.DestinationRail, &dr.DestinationCurrency,
		&dr.DestinationAddrHash, &dr.State, &dr.CreatedAt, &dr.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return dr, err
}

func (s *Store) CreateDepositRoute(ctx context.Context, dr *DepositRoute) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency, source_address,
		  destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		 ON CONFLICT (provider, provider_route_id) DO NOTHING`,
		dr.ID, dr.UserID, dr.Provider, dr.ProviderRouteID, dr.Kind,
		dr.SourceRail, dr.SourceCurrency, dr.SourceAddress, dr.DestinationRail, dr.DestinationCurrency,
		dr.DestinationAddrHash, dr.State, dr.CreatedAt, dr.UpdatedAt,
	)
	return err
}

func (s *Store) InsertWebhookEvent(ctx context.Context, ev *WebhookEvent) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO webhook_events (id, provider, provider_event_id, event_type, raw_payload, processed, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		ev.ID, ev.Provider, ev.ProviderEventID, ev.EventType, ev.RawPayload, ev.Processed, ev.CreatedAt,
	)
	return err
}

func (s *Store) WebhookEventExists(ctx context.Context, providerEventID string) (bool, error) {
	var exists bool
	err := s.db.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM webhook_events WHERE provider_event_id = $1)`,
		providerEventID,
	).Scan(&exists)
	return exists, err
}
