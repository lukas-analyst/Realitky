-- DROP TABLE realitky.cleaned.property_electricity;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_electricity (
    property_electricity_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu elektřiny
    property_electricity_key BIGINT NOT NULL, -- Klíč typu elektřiny pro referenční integritu

    electricity_name STRING NOT NULL, -- Název typu elektřiny
    desc STRING, -- Popis typu elektřiny
    capacity_rating SMALLINT, -- Hodnocení kapacity (1-5)

    electricity_code STRING, -- Obecný kód typu (např. 220V, 380V, ZADNY)
    electricity_code_accordinvest STRING,
    electricity_code_bezrealitky STRING,
    electricity_code_bidli STRING,
    electricity_code_broker STRING,
    electricity_code_gaia STRING,
    electricity_code_century21 STRING,
    electricity_code_dreamhouse STRING,
    electricity_code_idnes STRING,
    electricity_code_mm STRING,
    electricity_code_remax STRING,
    electricity_code_sreality STRING,
    electricity_code_tide STRING,
    electricity_code_ulovdomov STRING,

    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů elektrického připojení',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_electricity IS 'Číselník typů elektrického připojení.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_electricity.property_electricity_id IS 'Unikátní identifikátor typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.property_electricity_key IS 'Klíč typu elektřiny pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_name IS 'Název typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.desc IS 'Popis typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.capacity_rating IS 'Hodnocení kapacity (1-5).';

COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code IS 'Kód typu (např. 220V, 380V, ZADNY).';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_accordinvest IS 'Kód typu elektřiny pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_bezrealitky IS 'Kód typu elektřiny pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_bidli IS 'Kód typu elektřiny pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_broker IS 'Kód typu elektřiny pro realitní web broker.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_gaia IS 'Kód typu elektřiny pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_century21 IS 'Kód typu elektřiny pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_dreamhouse IS 'Kód typu elektřiny pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_idnes IS 'Kód typu elektřiny pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_mm IS 'Kód typu elektřiny pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_remax IS 'Kód typu elektřiny pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_sreality IS 'Kód typu elektřiny pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_tide IS 'Kód typu elektřiny pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code_ulovdomov IS 'Kód typu elektřiny pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_electricity.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.del_flag IS 'Příznak smazání záznamu.';