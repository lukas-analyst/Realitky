-- DROP TABLE IF EXISTS realitky.cleaned.property_type;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_type (
    property_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu nemovitosti
    property_type_key BIGINT NOT NULL, -- Klíč typu nemovitosti pro referenční integritu
    
    type_name STRING NOT NULL, -- Název typu nemovitosti (např. byt, dům, pozemek)
    desc STRING, -- Popis typu nemovitosti
    
    type_code STRING, -- Obecný kód typu nemovitosti
    type_code_accordinvest STRING,
    type_code_bezrealitky STRING,
    type_code_bidli STRING,
    type_code_broker STRING,
    type_code_gaia STRING,
    type_code_century21 STRING,
    type_code_dreamhouse STRING,
    type_code_idnes STRING,
    type_code_mm STRING,
    type_code_remax STRING,
    type_code_sreality STRING,
    type_code_tide STRING,
    type_code_ulovdomov STRING,

    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_type IS 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_type.property_type_id IS 'Unikátní identifikátor typu nemovitosti';
COMMENT ON COLUMN realitky.cleaned.property_type.property_type_key IS 'Klíč typu nemovitosti pro referenční integritu';

COMMENT ON COLUMN realitky.cleaned.property_type.type_name IS 'Název typu nemovitosti (např. byt, dům, pozemek)';
COMMENT ON COLUMN realitky.cleaned.property_type.desc IS 'Popis typu nemovitosti';

COMMENT ON COLUMN realitky.cleaned.property_type.type_code IS 'Obecný kód typu nemovitosti';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_accordinvest IS 'Kód typu nemovitosti pro realitní web accordinvest';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_bezrealitky IS 'Kód typu nemovitosti pro realitní web bezrealitky.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_bidli IS 'Kód typu nemovitosti pro realitní web bidli.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_broker IS 'Kód typu nemovitosti pro realitní web broker-consulting.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_gaia IS 'Kód typu nemovitosti pro realitní web gaia.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_century21 IS 'Kód typu nemovitosti pro realitní web century21.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_dreamhouse IS 'Kód typu nemovitosti pro realitní web dreamhome.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_idnes IS 'Kód typu nemovitosti pro realitní web reality.idnes.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_mm IS 'Kód typu nemovitosti pro realitní web mmreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_remax IS 'Kód typu nemovitosti pro realitní web remax.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_sreality IS 'Kód typu nemovitosti pro realitní web sreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_tide IS 'Kód typu nemovitosti pro realitní web tide.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_ulovdomov IS 'Kód typu nemovitosti pro realitní web ulovdomov.cz';

COMMENT ON COLUMN realitky.cleaned.property_type.ins_dt IS 'Datum vložení záznamu';
COMMENT ON COLUMN realitky.cleaned.property_type.upd_dt IS 'Datum poslední aktualizace záznamu';
COMMENT ON COLUMN realitky.cleaned.property_type.del_flag IS 'Příznak smazání záznamu';
