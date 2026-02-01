-- DROP TABLE realitky.cleaned.property_water_supply;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_water_supply (
    property_water_supply_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu vodovodní přípojky
    property_water_supply_key BIGINT NOT NULL, -- Klíč typu vodovodní přípojky pro referenční integritu
    
    water_supply_name STRING NOT NULL, -- Název typu vodovodní přípojky
    desc STRING, -- Popis typu vodovodní přípojky
    is_connected_to_grid BOOLEAN, -- Zda je připojeno k veřejné síti
    quality_rating SMALLINT, -- Hodnocení kvality vody (1-5)

    water_supply_code STRING, -- Obecný kód typu vodovodní přípojky (např. VEREJNY, STUDNA, CISTERNA)
    water_supply_code_accordinvest STRING,
    water_supply_code_bezrealitky STRING,
    water_supply_code_bidli STRING,
    water_supply_code_broker STRING,
    water_supply_code_gaia STRING,
    water_supply_code_century21 STRING,
    water_supply_code_dreamhouse STRING,
    water_supply_code_housevip STRING,
    water_supply_code_idnes STRING,
    water_supply_code_mm STRING,
    water_supply_code_remax STRING,
    water_supply_code_sreality STRING,
    water_supply_code_tide STRING,
    water_supply_code_ulovdomov STRING,
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Číselník typů vodovodních přípojek a zdrojů vody pro nemovitosti',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_water_supply IS 'Číselník typů vodovodních přípojek a zdrojů vody pro nemovitosti.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_water_supply.property_water_supply_id IS 'Unikátní identifikátor typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.property_water_supply_key IS 'Klíč typu vodovodní přípojky pro referenční integritu.';

COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_name IS 'Název typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.desc IS 'Popis typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.is_connected_to_grid IS 'Zda je připojeno k veřejné síti.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.quality_rating IS 'Hodnocení kvality vody (1-5).';

COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code IS 'Kód typu (např. VEREJNY, STUDNA, CISTERNA).';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_accordinvest IS 'Kód typu vodovodní přípojky pro realitní web accordinvest.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_bezrealitky IS 'Kód typu vodovodní přípojky pro realitní web bezrealitky.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_bidli IS 'Kód typu vodovodní přípojky pro realitní web bidli.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_broker IS 'Kód typu vodovodní přípojky pro realitní web broker-consulting.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_gaia IS 'Kód typu vodovodní přípojky pro realitní web gaia.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_century21 IS 'Kód typu vodovodní přípojky pro realitní web century21.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_dreamhouse IS 'Kód typu vodovodní přípojky pro realitní web dreamhome.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_housevip IS 'Kód typu vodovodní přípojky pro realitní web housevip.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_idnes IS 'Kód typu vodovodní přípojky pro realitní web reality.idnes.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_mm IS 'Kód typu vodovodní přípojky pro realitní web mmreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_remax IS 'Kód typu vodovodní přípojky pro realitní web remax.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_sreality IS 'Kód typu vodovodní přípojky pro realitní web sreality.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_tide IS 'Kód typu vodovodní přípojky pro realitní web tide.cz.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code_ulovdomov IS 'Kód typu vodovodní přípojky pro realitní web ulovdomov.cz.';

COMMENT ON COLUMN realitky.cleaned.property_water_supply.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.del_flag IS 'Příznak smazání záznamu.';