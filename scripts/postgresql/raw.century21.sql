--DROP TABLE IF EXISTS raw.century21;

CREATE TABLE IF NOT EXISTS raw.century21 (
    pk SERIAL PRIMARY KEY, -- Fyzický primární klíč (interní identifikátor řádku)
    id TEXT NOT NULL, -- Logický identifikátor nemovitosti (např. z URL)
    data JSONB NOT NULL, -- RAW data nemovitosti ve formátu JSON
    hash TEXT NOT NULL UNIQUE, -- Unikátní hash kombinace id a data (verzování změn)
    ins_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas vložení záznamu
    upd_dt TIMESTAMPTZ NOT NULL DEFAULT now(), -- Datum a čas poslední změny (aktualizace)
    del_flag BOOLEAN NOT NULL DEFAULT FALSE -- Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)
);

-- Komentáře k tabulce a sloupcům
COMMENT ON TABLE raw.century21 IS 'Tabulka pro ukládání nemovitostí z Century 21';
-- Komentáře k tabulce a sloupcům
COMMENT ON COLUMN raw.century21.pk IS 'Fyzický primární klíč (interní identifikátor řádku)';
COMMENT ON COLUMN raw.century21.id IS 'Logický identifikátor nemovitosti (např. z URL)';
COMMENT ON COLUMN raw.century21.data IS 'RAW data nemovitosti ve formátu JSON';
COMMENT ON COLUMN raw.century21.hash IS 'Unikátní hash kombinace id a data (verzování změn)';
COMMENT ON COLUMN raw.century21.ins_dt IS 'Datum a čas vložení záznamu';
COMMENT ON COLUMN raw.century21.upd_dt IS 'Datum a čas poslední změny (aktualizace)';
COMMENT ON COLUMN raw.century21.del_flag IS 'Označení, zda je záznam historický (TRUE = starý, FALSE = aktuální)';

CREATE INDEX IF NOT EXISTS raw_century21_id ON raw.century21 (id);
CREATE INDEX IF NOT EXISTS raw_century21_id_active ON raw.century21 (id) WHERE del_flag = FALSE;
CREATE INDEX IF NOT EXISTS raw_century21_data ON raw.century21 USING gin (data);
CREATE INDEX IF NOT EXISTS raw_century21_ins_dt ON raw.century21 (ins_dt);

-- Trigger funkce pro archivaci starých záznamů se stejným id
CREATE OR REPLACE FUNCTION raw.century21_archive_old()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE raw.century21
    SET del_flag = TRUE, upd_dt = now()
    WHERE id = NEW.id AND del_flag = FALSE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger před INSERTEM: označí staré záznamy se stejným id jako historické
CREATE TRIGGER archive_old_century21
BEFORE INSERT ON raw.century21
FOR EACH ROW EXECUTE FUNCTION raw.century21_archive_old();