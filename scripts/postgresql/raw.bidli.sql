--DROP TABLE IF EXISTS raw.bidli;

CREATE TABLE IF NOT EXISTS raw.bidli (
    pk SERIAL PRIMARY KEY,
    id TEXT NOT NULL,
    data JSONB NOT NULL,
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    del_flag BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS raw_bidli_id ON raw.bidli (id);
CREATE INDEX IF NOT EXISTS raw_bidli_data ON raw.bidli USING gin (data);
CREATE INDEX IF NOT EXISTS raw_bidli_ins_dt ON raw.bidli (ins_dt);

-- Trigger funkce
CREATE OR REPLACE FUNCTION raw.bidli_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.bidli
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM
CREATE TRIGGER archive_old_bidli
BEFORE INSERT ON raw.bidli
FOR EACH ROW EXECUTE FUNCTION raw.bidli_archive_old();