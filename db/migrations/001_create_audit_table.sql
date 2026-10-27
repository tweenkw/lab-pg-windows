CREATE TABLE IF NOT EXISTS audit_log (
    id           bigserial PRIMARY KEY,
    event_type   text        NOT NULL,
    target_table text        NOT NULL,
    old_data     jsonb,
    new_data     jsonb,
    actor        text        NOT NULL,
    occurred_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE audit_log IS 'Журнал аудита изменений данных';
CREATE INDEX IF NOT EXISTS idx_audit_log_occurred_at ON audit_log (occurred_at);