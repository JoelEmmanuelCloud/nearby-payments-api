DROP TABLE IF EXISTS nearby_sessions;

CREATE TABLE IF NOT EXISTS nearby_sessions (
    id TEXT PRIMARY KEY,
    initiator_user_id TEXT NOT NULL,
    recipient_user_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'declined')),
    payload_type TEXT NOT NULL,
    payload_data TEXT NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    FOREIGN KEY (initiator_user_id) REFERENCES users (id),
    FOREIGN KEY (recipient_user_id) REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_nearby_sessions_initiator ON nearby_sessions (initiator_user_id);
CREATE INDEX IF NOT EXISTS idx_nearby_sessions_recipient ON nearby_sessions (recipient_user_id);
