CREATE TABLE IF NOT EXISTS name_operation_tasks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('leaf_name.register_initial', 'parent_name.renew', 'parent_name.admin_recover')),
    payload_hash TEXT NOT NULL,
    nonce TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'authorized', 'submitted', 'failed', 'expired')),
    avs_task_id TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_name_operation_tasks_user_id ON name_operation_tasks (user_id);
CREATE INDEX IF NOT EXISTS idx_name_operation_tasks_nonce ON name_operation_tasks (nonce);
