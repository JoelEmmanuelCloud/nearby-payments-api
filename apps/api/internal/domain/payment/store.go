package payment

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

func (s *Store) CreateIntent(ctx context.Context, pi *PaymentIntent) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO payment_intents
		 (id, user_id, idempotency_key, recipient_address, recipient_name, asset, amount_atomic,
		  status, sponsor_address, funding_mode, created_at, updated_at, expires_at)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
		pi.ID, pi.UserID, pi.IdempotencyKey, pi.RecipientAddress, pi.RecipientName,
		pi.Asset, pi.AmountAtomic, pi.Status, pi.SponsorAddress, pi.FundingMode,
		pi.CreatedAt, pi.UpdatedAt, pi.ExpiresAt,
	)
	return err
}

func (s *Store) GetIntentByID(ctx context.Context, id string) (*PaymentIntent, error) {
	pi := &PaymentIntent{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, idempotency_key, recipient_address, recipient_name, asset, amount_atomic,
		        status, tx_digest, sponsor_address, funding_mode, created_at, updated_at, expires_at
		 FROM payment_intents WHERE id = $1`,
		id,
	).Scan(&pi.ID, &pi.UserID, &pi.IdempotencyKey, &pi.RecipientAddress, &pi.RecipientName,
		&pi.Asset, &pi.AmountAtomic, &pi.Status, &pi.TxDigest, &pi.SponsorAddress,
		&pi.FundingMode, &pi.CreatedAt, &pi.UpdatedAt, &pi.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return pi, err
}

func (s *Store) GetIntentByIdempotencyKey(ctx context.Context, key string) (*PaymentIntent, error) {
	pi := &PaymentIntent{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, idempotency_key, recipient_address, recipient_name, asset, amount_atomic,
		        status, tx_digest, sponsor_address, funding_mode, created_at, updated_at, expires_at
		 FROM payment_intents WHERE idempotency_key = $1`,
		key,
	).Scan(&pi.ID, &pi.UserID, &pi.IdempotencyKey, &pi.RecipientAddress, &pi.RecipientName,
		&pi.Asset, &pi.AmountAtomic, &pi.Status, &pi.TxDigest, &pi.SponsorAddress,
		&pi.FundingMode, &pi.CreatedAt, &pi.UpdatedAt, &pi.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return pi, err
}

func (s *Store) UpdateIntentStatus(ctx context.Context, id, status, txDigest string, updatedAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE payment_intents SET status = $1, tx_digest = $2, updated_at = $3 WHERE id = $4`,
		status, txDigest, updatedAt, id,
	)
	return err
}

func (s *Store) CreatePayment(ctx context.Context, p *Payment) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO payments
		 (id, intent_id, user_id, recipient_address, asset, amount_atomic, tx_digest, status, confirmed_at, created_at)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
		p.ID, p.IntentID, p.UserID, p.RecipientAddress, p.Asset, p.AmountAtomic,
		p.TxDigest, p.Status, p.ConfirmedAt, p.CreatedAt,
	)
	return err
}

func (s *Store) GetPaymentByID(ctx context.Context, id string) (*Payment, error) {
	p := &Payment{}
	err := s.db.QueryRow(ctx,
		`SELECT id, intent_id, user_id, recipient_address, asset, amount_atomic, tx_digest, status, confirmed_at, created_at
		 FROM payments WHERE id = $1`,
		id,
	).Scan(&p.ID, &p.IntentID, &p.UserID, &p.RecipientAddress, &p.Asset,
		&p.AmountAtomic, &p.TxDigest, &p.Status, &p.ConfirmedAt, &p.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return p, err
}
