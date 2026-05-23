CREATE TABLE IF NOT EXISTS deposits (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    route_id TEXT NOT NULL,
    provider TEXT NOT NULL CHECK (provider = 'bridge'),
    provider_deposit_id TEXT NOT NULL,
    kind TEXT NOT NULL CHECK (kind IN ('virtual_account', 'liquidation_address')),
    status TEXT NOT NULL,
    amount TEXT NOT NULL,
    currency TEXT NOT NULL,
    tx_hash TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    UNIQUE (provider, provider_deposit_id),
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (route_id) REFERENCES deposit_routes (id)
);

CREATE INDEX IF NOT EXISTS idx_deposits_user_id ON deposits (user_id);
CREATE INDEX IF NOT EXISTS idx_deposits_route_id ON deposits (route_id);
CREATE INDEX IF NOT EXISTS idx_bridge_webhook_events_unprocessed ON bridge_webhook_events (processed, created_at) WHERE processed = FALSE;
