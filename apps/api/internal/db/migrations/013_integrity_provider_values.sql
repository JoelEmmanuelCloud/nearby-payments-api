ALTER TABLE device_integrity_records DROP CONSTRAINT device_integrity_records_provider_check;

ALTER TABLE device_integrity_records ADD CONSTRAINT device_integrity_records_provider_check
    CHECK (provider IN ('play_integrity', 'apple_dcapp_attest', 'android_play_integrity', 'ios_app_attest', 'stub'));
