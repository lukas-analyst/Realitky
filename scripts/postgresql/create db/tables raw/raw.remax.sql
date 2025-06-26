--DROP TABLE IF EXISTS raw.remax;

CREATE TABLE IF NOT EXISTS raw.remax (
    pk SERIAL PRIMARY KEY, -- Fyzický primární klíč (interní identifikátor řádku)
    id TEXT NOT NULL, -- Logický identifikátor nemovitosti (např. z URL)
    data JSONB NOT NULL, -- RAW data nemovitosti ve formátu JSON
    hash TEXT NOT NULL UNIQUE, -- Unikátní hash kombinace id a data (verzování změn)
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas vložení záznamu
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas poslední změny (aktualizace)
    del_flag BOOLEAN NOT NULL DEFAULT FALSE -- Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)
);

-- Komentáře k tabulce a sloupcům
COMMENT ON TABLE raw.remax IS 'Tabulka pro ukládání nemovitostí z Remax';
-- Komentáře k tabulce a sloupcům
COMMENT ON COLUMN raw.remax.pk IS 'Fyzický primární klíč (interní identifikátor řádku)';
COMMENT ON COLUMN raw.remax.id IS 'Logický identifikátor nemovitosti (např. z URL)';
COMMENT ON COLUMN raw.remax.data IS 'RAW data nemovitosti ve formátu JSON';
COMMENT ON COLUMN raw.remax.hash IS 'Unikátní hash kombinace id a data (verzování změn)';
COMMENT ON COLUMN raw.remax.ins_dt IS 'Datum a čas vložení záznamu';
COMMENT ON COLUMN raw.remax.upd_dt IS 'Datum a čas poslední změny (aktualizace)';
COMMENT ON COLUMN raw.remax.del_flag IS 'Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)';

CREATE INDEX IF NOT EXISTS raw_remax_id ON raw.remax (id);
CREATE INDEX IF NOT EXISTS raw_remax_id_active ON raw.remax (id) WHERE del_flag = FALSE;
CREATE INDEX IF NOT EXISTS raw_remax_data ON raw.remax USING gin (data);
CREATE INDEX IF NOT EXISTS raw_remax_ins_dt ON raw.remax (ins_dt);

-- Trigger funkce pro archivaci starých záznamů se stejným id
CREATE OR REPLACE FUNCTION raw.remax_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.remax
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM: označí staré záznamy se stejným id jako historické
CREATE TRIGGER archive_old_remax
BEFORE INSERT ON raw.remax
FOR EACH ROW EXECUTE FUNCTION raw.remax_archive_old();