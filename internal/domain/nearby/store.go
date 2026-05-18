package nearby

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

func (s *Store) CreateSession(ctx context.Context, ns *NearbySession) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO nearby_sessions
		 (id, initiator_user_id, recipient_user_id, status, payload_type, payload_data, created_at, updated_at, expires_at)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
		ns.ID, ns.InitiatorUserID, ns.RecipientUserID, ns.Status,
		ns.PayloadType, ns.PayloadData, ns.CreatedAt, ns.UpdatedAt, ns.ExpiresAt,
	)
	return err
}

func (s *Store) GetSessionByID(ctx context.Context, id string) (*NearbySession, error) {
	ns := &NearbySession{}
	err := s.db.QueryRow(ctx,
		`SELECT id, initiator_user_id, recipient_user_id, status, payload_type, payload_data, created_at, updated_at, expires_at
		 FROM nearby_sessions WHERE id = $1`,
		id,
	).Scan(&ns.ID, &ns.InitiatorUserID, &ns.RecipientUserID, &ns.Status,
		&ns.PayloadType, &ns.PayloadData, &ns.CreatedAt, &ns.UpdatedAt, &ns.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return ns, err
}

func (s *Store) UpdateSessionStatus(ctx context.Context, id, status string, updatedAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE nearby_sessions SET status = $1, updated_at = $2 WHERE id = $3`,
		status, updatedAt, id,
	)
	return err
}
