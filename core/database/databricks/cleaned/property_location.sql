-- DROP TABLE realitky.cleaned.property_location;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_location (
    property_location_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu lokality
    property_location_key BIGINT NOT NULL, -- Klíč typu lokality pro referenční integritu
    
    location_name STRING NOT NULL, -- Název typu lokality
    desc STRING, -- Popis typu lokality

    location_code STRING, -- Obecný kód typu lokality (např. CENTRUM, PREDMESTI, KLIDNA)
    location_code_accordinvest STRING,
    location_code_bezrealitky STRING,
    location_code_bidli STRING,
    location_code_broker STRING,
    location_code_gaia STRING,
    location_code_century21 STRING,
    location_code_dreamhouse STRING,
    location_code_idnes STRING,
    location_code_mm STRING,
    location_code_remax STRING,
    location_code_sreality STRING,
    location_code_tide STRING,
    location_code_ulovdomov STRING,
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů lokalit (centrum, předměstí, klidná část)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_location IS 'Číselník typů lokalit (centrum, předměstí, klidná část).';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_location.property_location_id IS 'Unikátní identifikátor typu lokality.';
COMMENT ON COLUMN realitky.cleaned.property_location.property_location_key IS 'Klíč typu lokality pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_location.location_name IS 'Název typu lokality.';
COMMENT ON COLUMN realitky.cleaned.property_location.desc IS 'Popis typu lokality.';

COMMENT ON COLUMN realitky.cleaned.property_location.location_code IS 'Kód typu (např. CENTRUM, PREDMESTI, KLIDNA).';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_accordinvest IS 'Kód typu lokality pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_bezrealitky IS 'Kód typu lokality pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_bidli IS 'Kód typu lokality pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_broker IS 'Kód typu lokality pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_gaia IS 'Kód typu lokality pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_century21 IS 'Kód typu lokality pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_dreamhouse IS 'Kód typu lokality pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_idnes IS 'Kód typu lokality pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_mm IS 'Kód typu lokality pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_remax IS 'Kód typu lokality pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_sreality IS 'Kód typu lokality pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_tide IS 'Kód typu lokality pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code_ulovdomov IS 'Kód typu lokality pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_location.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_location.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_location.del_flag IS 'Příznak smazání záznamu.';