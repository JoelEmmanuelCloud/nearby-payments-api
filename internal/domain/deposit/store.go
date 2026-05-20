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

func (s *Store) GetBridgeLinkByUserID(ctx context.Context, userID string) (*BridgeLink, error) {
	bl := &BridgeLink{}
	err := s.db.QueryRow(ctx,
		`SELECT user_id, bridge_customer_id, bridge_kyc_link_id, created_at, updated_at
		 FROM bridge_links WHERE user_id = $1`,
		userID,
	).Scan(&bl.UserID, &bl.BridgeCustomerID, &bl.BridgeKycLinkID, &bl.CreatedAt, &bl.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return bl, err
}

func (s *Store) UpsertBridgeLink(ctx context.Context, bl *BridgeLink) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO bridge_links (user_id, bridge_customer_id, bridge_kyc_link_id, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5)
		 ON CONFLICT (user_id) DO UPDATE SET
		   bridge_customer_id = EXCLUDED.bridge_customer_id,
		   bridge_kyc_link_id = EXCLUDED.bridge_kyc_link_id,
		   updated_at = EXCLUDED.updated_at`,
		bl.UserID, bl.BridgeCustomerID, bl.BridgeKycLinkID, bl.CreatedAt, bl.UpdatedAt,
	)
	return err
}

func (s *Store) GetDepositRoute(ctx context.Context, userID, kind, sourceRail, sourceCurrency string) (*DepositRoute, error) {
	dr := &DepositRoute{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		        destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at
		 FROM deposit_routes
		 WHERE user_id = $1 AND kind = $2 AND source_rail = $3 AND source_currency = $4
		 ORDER BY created_at DESC LIMIT 1`,
		userID, kind, sourceRail, sourceCurrency,
	).Scan(&dr.ID, &dr.UserID, &dr.Provider, &dr.ProviderRouteID, &dr.Kind,
		&dr.SourceRail, &dr.SourceCurrency, &dr.DestinationRail, &dr.DestinationCurrency,
		&dr.DestinationAddrHash, &dr.State, &dr.CreatedAt, &dr.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return dr, err
}

func (s *Store) CreateDepositRoute(ctx context.Context, dr *DepositRoute) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		  destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		 ON CONFLICT (provider, provider_route_id) DO NOTHING`,
		dr.ID, dr.UserID, dr.Provider, dr.ProviderRouteID, dr.Kind,
		dr.SourceRail, dr.SourceCurrency, dr.DestinationRail, dr.DestinationCurrency,
		dr.DestinationAddrHash, dr.State, dr.CreatedAt, dr.UpdatedAt,
	)
	return err
}

func (s *Store) InsertWebhookEvent(ctx context.Context, ev *BridgeWebhookEvent) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO bridge_webhook_events (id, provider_event_id, event_type, raw_payload, processed, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		ev.ID, ev.ProviderEventID, ev.EventType, ev.RawPayload, ev.Processed, ev.CreatedAt,
	)
	return err
}

func (s *Store) WebhookEventExists(ctx context.Context, providerEventID string) (bool, error) {
	var exists bool
	err := s.db.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM bridge_webhook_events WHERE provider_event_id = $1)`,
		providerEventID,
	).Scan(&exists)
	return exists, err
}
