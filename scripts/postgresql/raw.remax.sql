--DROP TABLE IF EXISTS raw.remax;

CREATE TABLE IF NOT EXISTS raw.remax (
    pk SERIAL PRIMARY KEY,
    id TEXT NOT NULL,
    data JSONB NOT NULL,
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    del_flag BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS raw_remax_id ON raw.remax (id);
CREATE INDEX IF NOT EXISTS raw_remax_data ON raw.remax USING gin (data);
CREATE INDEX IF NOT EXISTS raw_remax_ins_dt ON raw.remax (ins_dt);

-- Trigger funkce
CREATE OR REPLACE FUNCTION raw.remax_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.remax
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM
CREATE TRIGGER archive_old_remax
BEFORE INSERT ON raw.remax
FOR EACH ROW EXECUTE FUNCTION raw.remax_archive_old();