-- DROP TABLE IF EXISTS realitky.cleaned.property_type;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_type (
    property_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_type_key BIGINT NOT NULL,
    type_name STRING NOT NULL,
    desc STRING,
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
    ins_dt TIMESTAMP NOT NULL,
    upd_dt TIMESTAMP NOT NULL,
    del_flag BOOLEAN NOT NULL
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
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_accordinvest IS 'Kód typu nemovitosti pro accordinvest';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_bezrealitky IS 'kód typu nemovitosti pro bezrealitky.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_bidli IS 'kód typu nemovitosti pro bidli.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_broker IS 'kód typu nemovitosti pro broker-consulting.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_gaia IS 'kód typu nemovitosti pro gaia.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_century21 IS 'kód typu nemovitosti pro century21.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_dreamhouse IS 'kód typu nemovitosti pro dreamhome.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_idnes IS 'kód typu nemovitosti pro reality.idnes.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_mm IS 'kód typu nemovitosti pro mmreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_remax IS 'kód typu nemovitosti pro remax.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_sreality IS 'kód typu nemovitosti pro sreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_tide IS 'kód typu nemovitosti pro tide.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code_ulovdomov IS 'kód typu nemovitosti pro ulovdomov.cz';
COMMENT ON COLUMN realitky.cleaned.property_type.ins_dt IS 'Datum vložení záznamu';
COMMENT ON COLUMN realitky.cleaned.property_type.upd_dt IS 'Datum poslední aktualizace záznamu';
COMMENT ON COLUMN realitky.cleaned.property_type.del_flag IS 'Příznak smazání záznamu';
