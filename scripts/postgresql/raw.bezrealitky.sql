--DROP TABLE IF EXISTS raw.bezrealitky;

CREATE TABLE IF NOT EXISTS raw.bezrealitky (
    pk SERIAL PRIMARY KEY,
    id TEXT NOT NULL,
    data JSONB NOT NULL,
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(),
    del_flag BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS raw_bezrealitky_id ON raw.bezrealitky (id);
CREATE INDEX IF NOT EXISTS raw_bezrealitky_data ON raw.bezrealitky USING gin (data);
CREATE INDEX IF NOT EXISTS raw_bezrealitky_ins_dt ON raw.bezrealitky (ins_dt);

-- Trigger funkce
CREATE OR REPLACE FUNCTION raw.bezrealitky_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.bezrealitky
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM
CREATE TRIGGER archive_old_bezrealitky
BEFORE INSERT ON raw.bezrealitky
FOR EACH ROW EXECUTE FUNCTION raw.bezrealitky_archive_old();