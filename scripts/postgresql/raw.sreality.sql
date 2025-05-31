--DROP TABLE IF EXISTS raw.sreality;

CREATE TABLE IF NOT EXISTS raw.sreality (
    pk SERIAL PRIMARY KEY,
    id TEXT NOT NULL,
    data JSONB NOT NULL,
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    del_flag BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS raw_sreality_id ON raw.sreality (id);
CREATE INDEX IF NOT EXISTS raw_sreality_data ON raw.sreality USING gin (data);
CREATE INDEX IF NOT EXISTS raw_sreality_ins_dt ON raw.sreality (ins_dt);

-- Trigger funkce
CREATE OR REPLACE FUNCTION raw.sreality_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.sreality
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM
CREATE TRIGGER archive_old_sreality
BEFORE INSERT ON raw.sreality
FOR EACH ROW EXECUTE FUNCTION raw.sreality_archive_old();