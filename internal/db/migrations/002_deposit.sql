CREATE TABLE IF NOT EXISTS bridge_links (
    user_id TEXT PRIMARY KEY,
    bridge_customer_id TEXT,
    bridge_kyc_link_id TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS deposit_routes (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    provider TEXT NOT NULL CHECK (provider = 'bridge'),
    provider_route_id TEXT NOT NULL,
    kind TEXT NOT NULL CHECK (kind IN ('virtual_account', 'liquidation_address')),
    source_rail TEXT NOT NULL,
    source_currency TEXT NOT NULL,
    destination_rail TEXT NOT NULL,
    destination_currency TEXT NOT NULL,
    destination_address_hash TEXT NOT NULL,
    state TEXT NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    UNIQUE (provider, provider_route_id),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS bridge_webhook_events (
    id TEXT PRIMARY KEY,
    provider_event_id TEXT NOT NULL UNIQUE,
    event_type TEXT NOT NULL,
    raw_payload JSONB NOT NULL,
    processed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_deposit_routes_user_id ON deposit_routes (user_id);
CREATE INDEX IF NOT EXISTS idx_bridge_webhook_events_provider_event_id ON bridge_webhook_events (provider_event_id);
