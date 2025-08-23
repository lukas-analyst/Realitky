-- DROP TABLE realitky.cleaned.property_accessibility;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_accessibility (
    property_accessibility_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu přístupové cesty
    property_accessibility_key BIGINT NOT NULL, -- Klíč typu přístupové cesty pro referenční integritu
    
    accessibility_name STRING NOT NULL, -- Název typu přístupové cesty
    desc STRING, -- Popis typu přístupové cesty

    accessibility_code STRING, -- Obecný kód typu přístupové cesty 
    accessibility_code_accordinvest STRING,
    accessibility_code_bezrealitky STRING,
    accessibility_code_bidli STRING,
    accessibility_code_broker STRING,
    accessibility_code_gaia STRING,
    accessibility_code_century21 STRING,
    accessibility_code_dreamhouse STRING,
    accessibility_code_idnes STRING,
    accessibility_code_mm STRING,
    accessibility_code_remax STRING,
    accessibility_code_sreality STRING,
    accessibility_code_tide STRING,
    accessibility_code_ulovdomov STRING,

    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů přístupových cest k nemovitostem',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_accessibility IS 'Číselník typů přístupových cest k nemovitostem.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_accessibility.property_accessibility_id IS 'Unikátní identifikátor typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.property_accessibility_key IS 'Klíč typu přístupové cesty pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_name IS 'Název typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.desc IS 'Popis typu přístupové cesty.';

COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code IS 'Kód typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_accordinvest IS 'Kód typu přístupové cesty pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_bezrealitky IS 'Kód typu přístupové cesty pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_bidli IS 'Kód typu přístupové cesty pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_broker IS 'Kód typu přístupové cesty pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_gaia IS 'Kód typu přístupové cesty pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_century21 IS 'Kód typu přístupové cesty pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_dreamhouse IS 'Kód typu přístupové cesty pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_idnes IS 'Kód typu přístupové cesty pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_mm IS 'Kód typu přístupové cesty pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_remax IS 'Kód typu přístupové cesty pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_sreality IS 'Kód typu přístupové cesty pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_tide IS 'Kód typu přístupové cesty pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code_ulovdomov IS 'Kód typu přístupové cesty pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_accessibility.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.del_flag IS 'Příznak smazání záznamu.';
