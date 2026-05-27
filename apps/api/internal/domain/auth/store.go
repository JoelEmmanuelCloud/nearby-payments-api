package auth

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct {
	db *pgxpool.Pool
}

func NewStore(db *pgxpool.Pool) *Store {
	return &Store{db: db}
}

func (s *Store) CreateUser(ctx context.Context, u *User) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO users (id, status, created_at, updated_at) VALUES ($1, $2, $3, $4)`,
		u.ID, u.Status, u.CreatedAt, u.UpdatedAt,
	)
	return err
}

func (s *Store) GetUserByID(ctx context.Context, id string) (*User, error) {
	u := &User{}
	err := s.db.QueryRow(ctx,
		`SELECT id, status, COALESCE(walrus_avatar_blob_id, ''), created_at, updated_at FROM users WHERE id = $1`,
		id,
	).Scan(&u.ID, &u.Status, &u.AvatarBlobID, &u.CreatedAt, &u.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return u, err
}

func (s *Store) UpdateUserAvatar(ctx context.Context, userID, blobID string, updatedAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE users SET walrus_avatar_blob_id = $1, updated_at = $2 WHERE id = $3`,
		blobID, updatedAt, userID,
	)
	return err
}

func (s *Store) GetOAuthIdentity(ctx context.Context, issuer, subject, audience string) (*OAuthIdentity, error) {
	oi := &OAuthIdentity{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, issuer, subject, audience, email, email_verified, created_at
		 FROM oauth_identities WHERE issuer = $1 AND subject = $2 AND audience = $3`,
		issuer, subject, audience,
	).Scan(&oi.ID, &oi.UserID, &oi.Issuer, &oi.Subject, &oi.Audience, &oi.Email, &oi.EmailVerified, &oi.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return oi, err
}

func (s *Store) CreateOAuthIdentity(ctx context.Context, oi *OAuthIdentity) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO oauth_identities (id, user_id, issuer, subject, audience, email, email_verified, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		oi.ID, oi.UserID, oi.Issuer, oi.Subject, oi.Audience, oi.Email, oi.EmailVerified, oi.CreatedAt,
	)
	return err
}

func (s *Store) CreateDevice(ctx context.Context, d *Device) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO devices (id, user_id, platform, os_version, app_bundle_id, status, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		d.ID, d.UserID, d.Platform, d.OsVersion, d.AppBundleID, d.Status, d.CreatedAt, d.UpdatedAt,
	)
	return err
}

func (s *Store) GetDeviceByID(ctx context.Context, id string) (*Device, error) {
	d := &Device{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, platform, os_version, app_bundle_id, status, created_at, updated_at
		 FROM devices WHERE id = $1`,
		id,
	).Scan(&d.ID, &d.UserID, &d.Platform, &d.OsVersion, &d.AppBundleID, &d.Status, &d.CreatedAt, &d.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return d, err
}

func (s *Store) CreateDeviceIntegrityRecord(ctx context.Context, r *DeviceIntegrityRecord) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO device_integrity_records
		 (id, device_id, provider, provider_key_id, public_key, sign_count, last_verdict, status, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		r.ID, r.DeviceID, r.Provider, r.ProviderKeyID, r.PublicKey,
		r.SignCount, r.LastVerdict, r.Status, r.CreatedAt, r.UpdatedAt,
	)
	return err
}

func (s *Store) GetActiveIntegrityRecord(ctx context.Context, deviceID string) (*DeviceIntegrityRecord, error) {
	r := &DeviceIntegrityRecord{}
	err := s.db.QueryRow(ctx,
		`SELECT id, device_id, provider, provider_key_id, public_key, sign_count, last_verdict, status, created_at, updated_at
		 FROM device_integrity_records WHERE device_id = $1 AND status = 'active' ORDER BY created_at DESC LIMIT 1`,
		deviceID,
	).Scan(&r.ID, &r.DeviceID, &r.Provider, &r.ProviderKeyID, &r.PublicKey,
		&r.SignCount, &r.LastVerdict, &r.Status, &r.CreatedAt, &r.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return r, err
}

func (s *Store) GetIntegrityRecordByID(ctx context.Context, id string) (*DeviceIntegrityRecord, error) {
	r := &DeviceIntegrityRecord{}
	err := s.db.QueryRow(ctx,
		`SELECT id, device_id, provider, provider_key_id, public_key, sign_count, last_verdict, status, created_at, updated_at
		 FROM device_integrity_records WHERE id = $1`,
		id,
	).Scan(&r.ID, &r.DeviceID, &r.Provider, &r.ProviderKeyID, &r.PublicKey,
		&r.SignCount, &r.LastVerdict, &r.Status, &r.CreatedAt, &r.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return r, err
}

func (s *Store) CreateSession(ctx context.Context, sess *Session) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO sessions
		 (id, user_id, device_id, device_integrity_id, access_token_hash, refresh_token_hash,
		  issued_at, expires_at, refresh_expires_at, status)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		sess.ID, sess.UserID, sess.DeviceID, sess.DeviceIntegrityID,
		sess.AccessTokenHash, sess.RefreshTokenHash,
		sess.IssuedAt, sess.ExpiresAt, sess.RefreshExpiresAt, sess.Status,
	)
	return err
}

func (s *Store) GetSessionByAccessTokenHash(ctx context.Context, hash string) (*Session, error) {
	sess := &Session{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, device_id, device_integrity_id, access_token_hash, refresh_token_hash,
		        issued_at, expires_at, refresh_expires_at, status
		 FROM sessions WHERE access_token_hash = $1`,
		hash,
	).Scan(&sess.ID, &sess.UserID, &sess.DeviceID, &sess.DeviceIntegrityID,
		&sess.AccessTokenHash, &sess.RefreshTokenHash,
		&sess.IssuedAt, &sess.ExpiresAt, &sess.RefreshExpiresAt, &sess.Status)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return sess, err
}

func (s *Store) GetSessionByRefreshTokenHash(ctx context.Context, hash string) (*Session, error) {
	sess := &Session{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, device_id, device_integrity_id, access_token_hash, refresh_token_hash,
		        issued_at, expires_at, refresh_expires_at, status
		 FROM sessions WHERE refresh_token_hash = $1`,
		hash,
	).Scan(&sess.ID, &sess.UserID, &sess.DeviceID, &sess.DeviceIntegrityID,
		&sess.AccessTokenHash, &sess.RefreshTokenHash,
		&sess.IssuedAt, &sess.ExpiresAt, &sess.RefreshExpiresAt, &sess.Status)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return sess, err
}

func (s *Store) UpdateSessionTokens(ctx context.Context, sessionID, accessTokenHash, refreshTokenHash string, expiresAt, refreshExpiresAt int64) error {
	_, err := s.db.Exec(ctx,
		`UPDATE sessions SET access_token_hash = $1, refresh_token_hash = $2, expires_at = $3, refresh_expires_at = $4
		 WHERE id = $5`,
		accessTokenHash, refreshTokenHash, expiresAt, refreshExpiresAt, sessionID,
	)
	return err
}

func (s *Store) RevokeSession(ctx context.Context, sessionID string) error {
	_, err := s.db.Exec(ctx, `UPDATE sessions SET status = 'revoked' WHERE id = $1`, sessionID)
	return err
}

func (s *Store) GetOrCreateZkLoginSalt(ctx context.Context, userID, issuer, subject, audience string) (*ZkLoginSalt, error) {
	salt := &ZkLoginSalt{}
	err := s.db.QueryRow(ctx,
		`SELECT id, user_id, issuer, subject, audience, salt, created_at
		 FROM zklogin_salts WHERE issuer = $1 AND subject = $2 AND audience = $3`,
		issuer, subject, audience,
	).Scan(&salt.ID, &salt.UserID, &salt.Issuer, &salt.Subject, &salt.Audience, &salt.Salt, &salt.CreatedAt)

	if err == nil {
		return salt, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("query zklogin salt: %w", err)
	}

	return nil, nil
}

func (s *Store) CreateZkLoginSalt(ctx context.Context, salt *ZkLoginSalt) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO zklogin_salts (id, user_id, issuer, subject, audience, salt, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)
		 ON CONFLICT (issuer, subject, audience) DO NOTHING`,
		salt.ID, salt.UserID, salt.Issuer, salt.Subject, salt.Audience, salt.Salt, salt.CreatedAt,
	)
	return err
}

func (s *Store) GetWalletBinding(ctx context.Context, userID string) (*WalletBinding, error) {
	wb := &WalletBinding{}
	err := s.db.QueryRow(ctx,
		`SELECT user_id, sui_address, auth_scheme, issuer, audience, created_at, updated_at
		 FROM wallet_bindings WHERE user_id = $1`,
		userID,
	).Scan(&wb.UserID, &wb.SuiAddress, &wb.AuthScheme, &wb.Issuer, &wb.Audience, &wb.CreatedAt, &wb.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return wb, err
}

func (s *Store) GetWalletBindingBySuiAddress(ctx context.Context, suiAddress string) (*WalletBinding, error) {
	wb := &WalletBinding{}
	err := s.db.QueryRow(ctx,
		`SELECT user_id, sui_address, auth_scheme, issuer, audience, created_at, updated_at
		 FROM wallet_bindings WHERE sui_address = $1`,
		suiAddress,
	).Scan(&wb.UserID, &wb.SuiAddress, &wb.AuthScheme, &wb.Issuer, &wb.Audience, &wb.CreatedAt, &wb.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return wb, err
}

func (s *Store) UpsertWalletBinding(ctx context.Context, wb *WalletBinding) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO wallet_bindings (user_id, sui_address, auth_scheme, issuer, audience, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)
		 ON CONFLICT (user_id) DO UPDATE SET sui_address = $2, updated_at = $7`,
		wb.UserID, wb.SuiAddress, wb.AuthScheme, wb.Issuer, wb.Audience, wb.CreatedAt, wb.UpdatedAt,
	)
	return err
}
