-- DROP TABLE realitky.cleaned.property_parking;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_parking (
    property_parking_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu parkování
    property_parking_key BIGINT NOT NULL, -- Klíč typu parkování pro referenční integritu
    
    parking_name STRING NOT NULL, -- Název typu parkování
    desc STRING, -- Popis typu parkování

    parking_code STRING, -- Kód typu (např. POZEMEK, ULICE, STANI)
    parking_code_accordinvest STRING,
    parking_code_bezrealitky STRING,
    parking_code_bidli STRING,
    parking_code_broker STRING,
    parking_code_gaia STRING,
    parking_code_century21 STRING,
    parking_code_dreamhouse STRING,
    parking_code_idnes STRING,
    parking_code_mm STRING,
    parking_code_remax STRING,
    parking_code_sreality STRING,
    parking_code_tide STRING,
    parking_code_ulovdomov STRING,

    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů parkování (na pozemku, ulici, parkovací stání)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_parking IS 'Číselník typů parkování (na pozemku, ulici, parkovací stání).';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_parking.property_parking_id IS 'Unikátní identifikátor typu parkování.';
COMMENT ON COLUMN realitky.cleaned.property_parking.property_parking_key IS 'Klíč typu parkování pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_parking.parking_name IS 'Název typu parkování.';
COMMENT ON COLUMN realitky.cleaned.property_parking.desc IS 'Popis typu parkování.';

COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code IS 'Kód typu (např. POZEMEK, ULICE, STANI).';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_accordinvest IS 'Kód typu parkování pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_bezrealitky IS 'Kód typu parkování pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_bidli IS 'Kód typu parkování pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_broker IS 'Kód typu parkování pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_gaia IS 'Kód typu parkování pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_century21 IS 'Kód typu parkování pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_dreamhouse IS 'Kód typu parkování pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_idnes IS 'Kód typu parkování pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_mm IS 'Kód typu parkování pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_remax IS 'Kód typu parkování pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_sreality IS 'Kód typu parkování pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_tide IS 'Kód typu parkování pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code_ulovdomov IS 'Kód typu parkování pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_parking.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_parking.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_parking.del_flag IS 'Příznak smazání záznamu.';