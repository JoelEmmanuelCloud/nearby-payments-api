ALTER TABLE fincra_links RENAME TO bridge_links;
ALTER TABLE bridge_links RENAME COLUMN fincra_customer_id TO bridge_customer_id;
ALTER TABLE bridge_links RENAME COLUMN fincra_virtual_account_id TO bridge_kyc_link_id;
ALTER TABLE bridge_links DROP COLUMN IF EXISTS account_number;
ALTER TABLE bridge_links DROP COLUMN IF EXISTS account_name;
ALTER TABLE bridge_links DROP COLUMN IF EXISTS bank_name;

ALTER TABLE deposit_routes DROP CONSTRAINT deposit_routes_provider_check;
ALTER TABLE deposit_routes ADD CONSTRAINT deposit_routes_provider_check CHECK (provider = 'bridge');
ALTER TABLE deposit_routes DROP CONSTRAINT deposit_routes_kind_check;
ALTER TABLE deposit_routes ADD CONSTRAINT deposit_routes_kind_check CHECK (kind IN ('virtual_account', 'liquidation_address'));
ALTER TABLE deposit_routes DROP COLUMN IF EXISTS source_address;

ALTER TABLE webhook_events RENAME TO bridge_webhook_events;
ALTER TABLE bridge_webhook_events DROP COLUMN IF EXISTS provider;
DROP INDEX IF EXISTS idx_webhook_events_provider_event_id;
DROP INDEX IF EXISTS idx_webhook_events_provider;
CREATE INDEX IF NOT EXISTS idx_bridge_webhook_events_provider_event_id ON bridge_webhook_events (provider_event_id);
