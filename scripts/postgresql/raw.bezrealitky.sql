--DROP TABLE IF EXISTS raw.bezrealitky;

CREATE TABLE IF NOT EXISTS raw.bezrealitky (
    pk SERIAL PRIMARY KEY, -- Fyzický primární klíč (interní identifikátor řádku)
    id TEXT NOT NULL, -- Logický identifikátor nemovitosti (např. z URL)
    data JSONB NOT NULL, -- RAW data nemovitosti ve formátu JSON
    hash TEXT NOT NULL UNIQUE, -- Unikátní hash kombinace id a data (verzování změn)
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas vložení záznamu
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas poslední změny (aktualizace)
    del_flag BOOLEAN NOT NULL DEFAULT FALSE -- Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)
);

-- Komentáře k tabulce a sloupcům
COMMENT ON TABLE raw.bezrealitky IS 'Tabulka pro ukládání nemovitostí z BezRealitky';
-- Komentáře k tabulce a sloupcům
COMMENT ON COLUMN raw.bezrealitky.pk IS 'Fyzický primární klíč (interní identifikátor řádku)';
COMMENT ON COLUMN raw.bezrealitky.id IS 'Logický identifikátor nemovitosti (např. z URL)';
COMMENT ON COLUMN raw.bezrealitky.data IS 'RAW data nemovitosti ve formátu JSON';
COMMENT ON COLUMN raw.bezrealitky.hash IS 'Unikátní hash kombinace id a data (verzování změn)';
COMMENT ON COLUMN raw.bezrealitky.ins_dt IS 'Datum a čas vložení záznamu';
COMMENT ON COLUMN raw.bezrealitky.upd_dt IS 'Datum a čas poslední změny (aktualizace)';
COMMENT ON COLUMN raw.bezrealitky.del_flag IS 'Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)';

CREATE INDEX IF NOT EXISTS raw_bezrealitky_id ON raw.bezrealitky (id);
CREATE INDEX IF NOT EXISTS raw_bezrealitky_id_active ON raw.bezrealitky (id) WHERE del_flag = FALSE;
CREATE INDEX IF NOT EXISTS raw_bezrealitky_data ON raw.bezrealitky USING gin (data);
CREATE INDEX IF NOT EXISTS raw_bezrealitky_ins_dt ON raw.bezrealitky (ins_dt);

-- Trigger funkce pro archivaci starých záznamů se stejným id
CREATE OR REPLACE FUNCTION raw.bezrealitky_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.bezrealitky
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM: označí staré záznamy se stejným id jako historické
CREATE TRIGGER archive_old_bezrealitky
BEFORE INSERT ON raw.bezrealitky
FOR EACH ROW EXECUTE FUNCTION raw.bezrealitky_archive_old();