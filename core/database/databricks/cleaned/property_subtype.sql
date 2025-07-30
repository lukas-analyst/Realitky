-- DROP TABLE IF EXISTS realitky.cleaned.property_subtype;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_subtype (
    property_subtype_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_subtype_key BIGINT NOT NULL,
    subtype_name STRING NOT NULL,
    desc STRING,
    subtype_code_accordinvest STRING,
    subtype_code_bezrealitky STRING,
    subtype_code_bidli STRING,
    subtype_code_broker STRING,
    subtype_code_gaia STRING,
    subtype_code_century21 STRING,
    subtype_code_dreamhouse STRING,
    subtype_code_idnes STRING,
    subtype_code_mm STRING,
    subtype_code_remax STRING,
    subtype_code_sreality STRING,
    subtype_code_tide STRING,
    subtype_code_ulovdomov STRING,
    ins_dt TIMESTAMP NOT NULL,
    upd_dt TIMESTAMP NOT NULL,
    del_flag BOOLEAN NOT NULL
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře, včetně jejich popisu.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_subtype IS 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře, včetně jejich popisu.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_subtype.property_subtype_id IS 'Unikátní identifikátor podtypu nemovitosti';
COMMENT ON COLUMN realitky.cleaned.property_subtype.property_subtype_key IS 'Klíč podtypu nemovitosti pro referenční integritu';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_name IS 'Název podtypu nemovitosti (např. byt, dům, pozemek)';
COMMENT ON COLUMN realitky.cleaned.property_subtype.desc IS 'Popis podtypu nemovitosti';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_accordinvest IS 'Kód podtypu nemovitosti pro accordinvest';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_bezrealitky IS 'kód podtypu nemovitosti pro bezrealitky.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_bidli IS 'kód podtypu nemovitosti pro bidli.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_broker IS 'kód podtypu nemovitosti pro broker-consulting.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_gaia IS 'kód podtypu nemovitosti pro gaia.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_century21 IS 'kód podtypu nemovitosti pro century21.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_dreamhouse IS 'kód podtypu nemovitosti pro dreamhome.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_idnes IS 'kód podtypu nemovitosti pro reality.idnes.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_mm IS 'kód podtypu nemovitosti pro mmreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_remax IS 'kód podtypu nemovitosti pro remax.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_sreality IS 'kód podtypu nemovitosti pro sreality.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_tide IS 'kód podtypu nemovitosti pro tide.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code_ulovdomov IS 'kód podtypu nemovitosti pro ulovdomov.cz';
COMMENT ON COLUMN realitky.cleaned.property_subtype.ins_dt IS 'Datum vložení záznamu';
COMMENT ON COLUMN realitky.cleaned.property_subtype.upd_dt IS 'Datum poslední aktualizace záznamu';
COMMENT ON COLUMN realitky.cleaned.property_subtype.del_flag IS 'Příznak smazání záznamu';