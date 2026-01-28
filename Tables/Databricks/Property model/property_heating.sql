-- DROP TABLE realitky.cleaned.property_heating;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_heating (
    property_heating_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu vytápění
    property_heating_key BIGINT NOT NULL, -- Klíč typu vytápění pro referenční integritu
    
    heating_name STRING NOT NULL, -- Název typu vytápění
    desc STRING, -- Popis typu vytápění
    efficiency_rating SMALLINT, -- Hodnocení efektivity (1-5)
    environmental_impact SMALLINT, -- Dopad na životní prostředí (1-5, 5=nejlepší)
    operating_cost_level STRING, -- Úroveň provozních nákladů (NIZKA, STREDNI, VYSOKA)
    
    heating_code STRING, -- Obecný kód typu vytápění (např. PLYN, ELEKTRO, UHELNE)
    heating_code_accordinvest STRING,
    heating_code_bezrealitky STRING,
    heating_code_bidli STRING,
    heating_code_broker STRING,
    heating_code_gaia STRING,
    heating_code_century21 STRING,
    heating_code_dreamhouse STRING,
    heating_code_housevip STRING,
    heating_code_idnes STRING,
    heating_code_mm STRING,
    heating_code_remax STRING,
    heating_code_sreality STRING,
    heating_code_tide STRING,
    heating_code_ulovdomov STRING,
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Číselník typů vytápění nemovitostí',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_heating IS 'Číselník typů vytápění nemovitostí.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_heating.property_heating_id IS 'Unikátní identifikátor typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.property_heating_key IS 'Klíč typu vytápění pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_heating.heating_name IS 'Název typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.desc IS 'Popis typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.efficiency_rating IS 'Hodnocení efektivity (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_heating.environmental_impact IS 'Dopad na životní prostředí (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_heating.operating_cost_level IS 'Úroveň provozních nákladů.';

COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code IS 'Kód typu (např. PLYN, ELEKTRO, UHELNE).';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_accordinvest IS 'Kód typu vytápění pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_bezrealitky IS 'Kód typu vytápění pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_bidli IS 'Kód typu vytápění pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_broker IS 'Kód typu vytápění pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_gaia IS 'Kód typu vytápění pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_century21 IS 'Kód typu vytápění pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_dreamhouse IS 'Kód typu vytápění pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_housevip IS 'Kód typu vytápění pro realitní web housevip.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_idnes IS 'Kód typu vytápění pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_mm IS 'Kód typu vytápění pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_remax IS 'Kód typu vytápění pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_sreality IS 'Kód typu vytápění pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_tide IS 'Kód typu vytápění pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code_ulovdomov IS 'Kód typu vytápění pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_heating.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_heating.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_heating.del_flag IS 'Příznak smazání záznamu.';