-- DROP TABLE realitky.cleaned.property_construction_type;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_construction_type (
    property_construction_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu konstrukce
    property_construction_type_key BIGINT NOT NULL, -- Klíč typu konstrukce pro referenční integritu

    construction_name STRING NOT NULL, -- Název typu konstrukce
    desc STRING, -- Popis typu konstrukce

    construction_code STRING, -- Obecný kód typu konstrukce (např. PANEL, CIHLA, DREVO)
    construction_code_accordinvest STRING,
    construction_code_bezrealitky STRING,
    construction_code_bidli STRING,
    construction_code_broker STRING,
    construction_code_gaia STRING,
    construction_code_century21 STRING,
    construction_code_dreamhouse STRING,
    construction_code_idnes STRING,
    construction_code_mm STRING,
    construction_code_remax STRING,
    construction_code_sreality STRING,
    construction_code_tide STRING,
    construction_code_ulovdomov STRING,
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů konstrukce (panel, cihla, dřevo, smíšené)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_construction_type IS 'Číselník typů konstrukce (panel, cihla, dřevo, smíšené).';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_construction_type.property_construction_type_id IS 'Unikátní identifikátor typu konstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.property_construction_type_key IS 'Klíč typu konstrukce pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_name IS 'Název typu konstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.desc IS 'Popis typu konstrukce.';

COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code IS 'Kód typu (např. PANEL, CIHLA, DREVO).';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_accordinvest IS 'Kód typu konstrukce pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_bezrealitky IS 'Kód typu konstrukce pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_bidli IS 'Kód typu konstrukce pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_broker IS 'Kód typu konstrukce pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_gaia IS 'Kód typu konstrukce pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_century21 IS 'Kód typu konstrukce pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_dreamhouse IS 'Kód typu konstrukce pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_idnes IS 'Kód typu konstrukce pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_mm IS 'Kód typu konstrukce pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_remax IS 'Kód typu konstrukce pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_sreality IS 'Kód typu konstrukce pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_tide IS 'Kód typu konstrukce pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code_ulovdomov IS 'Kód typu konstrukce pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_construction_type.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.del_flag IS 'Příznak smazání záznamu.';