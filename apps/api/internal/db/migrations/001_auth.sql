CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    status TEXT NOT NULL CHECK (status IN ('active', 'restricted', 'revoked')),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS oauth_identities (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    issuer TEXT NOT NULL,
    subject TEXT NOT NULL,
    audience TEXT NOT NULL,
    email TEXT,
    email_verified BOOLEAN,
    created_at BIGINT NOT NULL,
    UNIQUE (issuer, subject, audience),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS devices (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
    os_version TEXT NOT NULL,
    app_bundle_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'restricted', 'revoked')),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS device_integrity_records (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    provider TEXT NOT NULL CHECK (provider IN ('ios_app_attest', 'android_play_integrity', 'stub')),
    provider_key_id TEXT,
    public_key TEXT,
    sign_count BIGINT,
    last_verdict TEXT,
    status TEXT NOT NULL CHECK (status IN ('active', 'revoked')),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices (id)
);

CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    device_integrity_id TEXT NOT NULL,
    access_token_hash TEXT NOT NULL UNIQUE,
    refresh_token_hash TEXT NOT NULL UNIQUE,
    issued_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    refresh_expires_at BIGINT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'revoked')),
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (device_id) REFERENCES devices (id),
    FOREIGN KEY (device_integrity_id) REFERENCES device_integrity_records (id)
);

CREATE TABLE IF NOT EXISTS zklogin_salts (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    issuer TEXT NOT NULL,
    subject TEXT NOT NULL,
    audience TEXT NOT NULL,
    salt TEXT NOT NULL,
    created_at BIGINT NOT NULL,
    UNIQUE (issuer, subject, audience),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS wallet_bindings (
    user_id TEXT PRIMARY KEY,
    sui_address TEXT NOT NULL UNIQUE,
    auth_scheme TEXT NOT NULL CHECK (auth_scheme IN ('zklogin')),
    issuer TEXT NOT NULL,
    audience TEXT NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_sessions_access_token_hash ON sessions (access_token_hash);
CREATE INDEX IF NOT EXISTS idx_sessions_refresh_token_hash ON sessions (refresh_token_hash);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_devices_user_id ON devices (user_id);
