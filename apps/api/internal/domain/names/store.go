package names

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

func (s *Store) CreateTask(ctx context.Context, t *NameOperationTask) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO name_operation_tasks
		 (id, user_id, action, payload_hash, nonce, status, avs_task_id, created_at, updated_at, expires_at)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
		t.ID, t.UserID, t.Action, t.PayloadHash, t.Nonce,
		t.Status, t.AVSTaskID, t.CreatedAt, t.UpdatedAt, t.ExpiresAt,
	)
	return err
}

func (s *Store) GetTaskByID(ctx context.Context, id string) (*NameOperationTask, error) {
	t := &NameOperationTask{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, action, payload_hash, nonce, status, avs_task_id, created_at, updated_at, expires_at
		 FROM name_operation_tasks WHERE id = $1`,
		id,
	).Scan(&t.ID, &t.UserID, &t.Action, &t.PayloadHash, &t.Nonce,
		&t.Status, &t.AVSTaskID, &t.CreatedAt, &t.UpdatedAt, &t.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return t, err
}

func (s *Store) UpdateTaskStatus(ctx context.Context, id, status string, updatedAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE name_operation_tasks SET status = $1, updated_at = $2 WHERE id = $3`,
		status, updatedAt, id,
	)
	return err
}
