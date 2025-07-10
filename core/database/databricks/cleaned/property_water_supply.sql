-- DROP TABLE realitky.cleaned.property_water_supply;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_water_supply (
    property_water_supply_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu vodovodní přípojky
    
    water_supply_name STRING NOT NULL, -- Název typu vodovodní přípojky
    water_supply_code STRING, -- Kód typu (např. VEREJNY, STUDNA, CISTERNA)
    desc STRING, -- Popis typu vodovodní přípojky
    is_connected_to_grid BOOLEAN, -- Zda je připojeno k veřejné síti
    quality_rating SMALLINT, -- Hodnocení kvality vody (1-5)
    
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

COMMENT ON TABLE realitky.cleaned.property_water_supply IS 'Číselník typů vodovodních přípojek a zdrojů vody pro nemovitosti.';

COMMENT ON COLUMN realitky.cleaned.property_water_supply.property_water_supply_id IS 'Unikátní identifikátor typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_name IS 'Název typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.water_supply_code IS 'Kód typu (např. VEREJNY, STUDNA, CISTERNA).';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.desc IS 'Popis typu vodovodní přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.is_connected_to_grid IS 'Zda je připojeno k veřejné síti.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.quality_rating IS 'Hodnocení kvality vody (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_water_supply.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_water_supply ZORDER BY (water_supply_code, is_connected_to_grid, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_water_supply 
(water_supply_name, water_supply_code, desc, is_connected_to_grid, quality_rating, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ vodovodní přípojky není specifikován', false, 0, current_timestamp(), current_timestamp(), false),
('Veřejný vodovod', 'VEREJNY', 'Připojení k veřejné vodovodní síti', true, 5, current_timestamp(), current_timestamp(), false),
('Vlastní studna', 'STUDNA', 'Vlastní kopané nebo vrtané studny', false, 3, current_timestamp(), current_timestamp(), false),
('Artézská studna', 'ARTEZSKA', 'Artézská studna s vysokou kvalitou vody', false, 4, current_timestamp(), current_timestamp(), false),
('Cisterna/nádrž', 'CISTERNA', 'Cisterna nebo nádrž na dešťovou vodu', false, 2, current_timestamp(), current_timestamp(), false),
('Společná studna', 'SPOLECNA', 'Společná studna pro více nemovitostí', false, 3, current_timestamp(), current_timestamp(), false),
('Bez vody', 'ZADNA', 'Nemovitost bez přípojky vody', false, 1, current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_water_supply ORDER BY property_water_supply_id;
