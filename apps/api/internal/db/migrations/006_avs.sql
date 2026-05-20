CREATE TABLE IF NOT EXISTS avs_authorization_tasks (
    id TEXT PRIMARY KEY,
    action TEXT NOT NULL,
    payload_hash TEXT NOT NULL,
    nonce TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'authorized', 'rejected', 'expired')),
    issued_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_avs_authorization_tasks_nonce ON avs_authorization_tasks (nonce);
