ALTER TABLE bridge_links RENAME TO fincra_links;
ALTER TABLE fincra_links RENAME COLUMN bridge_customer_id TO fincra_customer_id;
ALTER TABLE fincra_links RENAME COLUMN bridge_kyc_link_id TO fincra_virtual_account_id;
ALTER TABLE fincra_links ADD COLUMN account_number TEXT NOT NULL DEFAULT '';
ALTER TABLE fincra_links ADD COLUMN account_name TEXT NOT NULL DEFAULT '';
ALTER TABLE fincra_links ADD COLUMN bank_name TEXT NOT NULL DEFAULT '';

ALTER TABLE deposit_routes DROP CONSTRAINT deposit_routes_provider_check;
ALTER TABLE deposit_routes ADD CONSTRAINT deposit_routes_provider_check CHECK (provider IN ('fincra', 'blockradar'));
ALTER TABLE deposit_routes DROP CONSTRAINT deposit_routes_kind_check;
ALTER TABLE deposit_routes ADD CONSTRAINT deposit_routes_kind_check CHECK (kind IN ('virtual_account', 'deposit_address'));
ALTER TABLE deposit_routes ADD COLUMN source_address TEXT NOT NULL DEFAULT '';

ALTER TABLE bridge_webhook_events RENAME TO webhook_events;
ALTER TABLE webhook_events ADD COLUMN provider TEXT NOT NULL DEFAULT 'blockradar';
DROP INDEX IF EXISTS idx_bridge_webhook_events_provider_event_id;
CREATE INDEX IF NOT EXISTS idx_webhook_events_provider_event_id ON webhook_events (provider_event_id);
CREATE INDEX IF NOT EXISTS idx_webhook_events_provider ON webhook_events (provider);
