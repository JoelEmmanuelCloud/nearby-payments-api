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
		 (id, user_id, sui_address, leaf_name, parent_name, action, status, tx_digest, auth_task_id, error_msg, created_at, updated_at)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
		t.ID, t.UserID, t.SuiAddress, t.LeafName, t.ParentName,
		t.Action, t.Status, t.TxDigest, t.AuthTaskID, t.ErrorMsg,
		t.CreatedAt, t.UpdatedAt,
	)
	return err
}

func (s *Store) GetTaskByID(ctx context.Context, id string) (*NameOperationTask, error) {
	t := &NameOperationTask{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, sui_address, leaf_name, parent_name, action, status, tx_digest, auth_task_id, error_msg, created_at, updated_at
		 FROM name_operation_tasks WHERE id = $1`,
		id,
	).Scan(&t.ID, &t.UserID, &t.SuiAddress, &t.LeafName, &t.ParentName,
		&t.Action, &t.Status, &t.TxDigest, &t.AuthTaskID, &t.ErrorMsg,
		&t.CreatedAt, &t.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return t, err
}

func (s *Store) UpdateTaskStatus(ctx context.Context, id, status, txDigest, errorMsg string, updatedAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE name_operation_tasks SET status = $1, tx_digest = $2, error_msg = $3, updated_at = $4 WHERE id = $5`,
		status, txDigest, errorMsg, updatedAt, id,
	)
	return err
}
