-- DROP TABLE realitky.cleaned.property_gas;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_gas (
    property_gas_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu plynové přípojky
    property_gas_key BIGINT NOT NULL, -- Klíč typu plynové přípojky pro referenční integritu
    
    gas_name STRING NOT NULL, -- Název typu plynové přípojky
    desc STRING, -- Popis typu plynové přípojky
    safety_rating SMALLINT, -- Hodnocení bezpečnosti (1-5)
    cost_efficiency SMALLINT, -- Hodnocení nákladové efektivity (1-5)

    gas_code STRING, -- Obecný kód typu plynové přípojky (např. ZEMNI, PROPAN, ZADNY)
    gas_code_accordinvest STRING,
    gas_code_bezrealitky STRING,
    gas_code_bidli STRING,
    gas_code_broker STRING,
    gas_code_gaia STRING,
    gas_code_century21 STRING,
    gas_code_dreamhouse STRING,
    gas_code_idnes STRING,
    gas_code_mm STRING,
    gas_code_remax STRING,
    gas_code_sreality STRING,
    gas_code_tide STRING,
    gas_code_ulovdomov STRING,
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Číselník typů plynových přípojek a zdrojů plynu pro nemovitosti',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_gas IS 'Číselník typů plynových přípojek a zdrojů plynu pro nemovitosti.';

COMMENT ON COLUMN realitky.cleaned.property_gas.property_gas_id IS 'Unikátní identifikátor typu plynové přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_gas.property_gas_key IS 'Klíč typu plynové přípojky pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_gas.gas_name IS 'Název typu plynové přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_gas.desc IS 'Popis typu plynové přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_gas.safety_rating IS 'Hodnocení bezpečnosti (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_gas.cost_efficiency IS 'Hodnocení nákladové efektivity (1-5).';

COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code IS 'Kód typu (např. ZEMNI, PROPAN, ZADNY).';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_accordinvest IS 'Kód typu pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_bezrealitky IS 'Kód typu pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_bidli IS 'Kód typu pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_broker IS 'Kód typu pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_gaia IS 'Kód typu pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_century21 IS 'Kód typu pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_dreamhouse IS 'Kód typu pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_idnes IS 'Kód typu pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_mm IS 'Kód typu pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_remax IS 'Kód typu pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_sreality IS 'Kód typu pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_tide IS 'Kód typu pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code_ulovdomov IS 'Kód typu pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_gas.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_gas.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_gas.del_flag IS 'Příznak smazání záznamu.';