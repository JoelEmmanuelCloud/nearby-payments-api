CREATE TABLE IF NOT EXISTS payment_intents (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    idempotency_key TEXT NOT NULL UNIQUE,
    recipient_address TEXT NOT NULL,
    recipient_name TEXT,
    asset TEXT NOT NULL,
    amount_atomic TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'submitted', 'confirmed', 'failed', 'cancelled')),
    tx_digest TEXT,
    sponsor_address TEXT,
    funding_mode TEXT NOT NULL CHECK (funding_mode IN ('gasless_stablecoin', 'sponsored', 'user_paid')),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS payments (
    id TEXT PRIMARY KEY,
    intent_id TEXT NOT NULL UNIQUE,
    user_id TEXT NOT NULL,
    recipient_address TEXT NOT NULL,
    asset TEXT NOT NULL,
    amount_atomic TEXT NOT NULL,
    tx_digest TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('confirmed', 'failed')),
    confirmed_at BIGINT,
    created_at BIGINT NOT NULL,
    FOREIGN KEY (intent_id) REFERENCES payment_intents (id),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_payment_intents_user_id ON payment_intents (user_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_idempotency_key ON payment_intents (idempotency_key);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments (user_id);
