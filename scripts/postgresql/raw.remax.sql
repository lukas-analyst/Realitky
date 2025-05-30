--DROP TABLE IF EXISTS raw.remax;

CREATE TABLE IF NOT EXISTS raw.remax (
    id TEXT PRIMARY KEY,
    data JSONB NOT NULL,
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    del_flag BOOLEAN NOT NULL DEFAULT FALSE
);

-- Trigger to update upd_dt on row update
CREATE TRIGGER set_upd_dt
BEFORE UPDATE ON raw.remax
FOR EACH ROW EXECUTE FUNCTION raw.remax_set_upd_dt();

-- Function to set upd_dt
CREATE OR REPLACE FUNCTION raw.remax_set_upd_dt()
RETURNS TRIGGER AS $$
BEGIN
    NEW.upd_dt = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Indexes
CREATE INDEX IF NOT EXISTS raw_remax_id ON raw.remax (id);
CREATE INDEX IF NOT EXISTS raw_remax_data ON raw.remax USING GIN (data);