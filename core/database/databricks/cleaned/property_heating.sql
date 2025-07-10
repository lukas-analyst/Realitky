-- DROP TABLE realitky.cleaned.property_heating;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_heating (
    property_heating_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu vytápění
    
    heating_name STRING NOT NULL, -- Název typu vytápění
    heating_code STRING, -- Kód typu (např. PLYN, ELEKTRO, UHELNE)
    description STRING, -- Popis typu vytápění
    energy_source STRING, -- Zdroj energie (plyn, elektřina, uhlí, dřevo, tepelné čerpadlo)
    efficiency_rating SMALLINT, -- Hodnocení efektivity (1-5)
    environmental_impact SMALLINT, -- Dopad na životní prostředí (1-5, 5=nejlepší)
    operating_cost_level STRING, -- Úroveň provozních nákladů (NIZKA, STREDNI, VYSOKA)
    
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

COMMENT ON TABLE realitky.cleaned.property_heating IS 'Číselník typů vytápění nemovitostí.';

COMMENT ON COLUMN realitky.cleaned.property_heating.property_heating_id IS 'Unikátní identifikátor typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_name IS 'Název typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.heating_code IS 'Kód typu (např. PLYN, ELEKTRO, UHELNE).';
COMMENT ON COLUMN realitky.cleaned.property_heating.description IS 'Popis typu vytápění.';
COMMENT ON COLUMN realitky.cleaned.property_heating.energy_source IS 'Zdroj energie.';
COMMENT ON COLUMN realitky.cleaned.property_heating.efficiency_rating IS 'Hodnocení efektivity (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_heating.environmental_impact IS 'Dopad na životní prostředí (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_heating.operating_cost_level IS 'Úroveň provozních nákladů.';
COMMENT ON COLUMN realitky.cleaned.property_heating.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_heating.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_heating.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_heating ZORDER BY (heating_code, energy_source, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_heating 
(heating_name, heating_code, description, energy_source, efficiency_rating, environmental_impact, operating_cost_level, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ vytápění není specifikován', 'Neznámé', -1, -1, 'XNA', current_timestamp(), current_timestamp(), false),
('Plynové ústřední', 'PLYN_USTREDNI', 'Ústřední vytápění na zemní plyn', 'Zemní plyn', 4, 3, 'STREDNI', current_timestamp(), current_timestamp(), false),
('Plynové lokální', 'PLYN_LOKALNI', 'Lokální plynové topení (kotle, kamna)', 'Zemní plyn', 3, 3, 'STREDNI', current_timestamp(), current_timestamp(), false),
('Elektrické ústřední', 'ELEKTRO_USTREDNI', 'Ústřední elektrické vytápění', 'Elektřina', 4, 2, 'VYSOKA', current_timestamp(), current_timestamp(), false),
('Elektrické lokální', 'ELEKTRO_LOKALNI', 'Lokální elektrické topení (kotle, kamna)', 'Elektřina', 3, 2, 'VYSOKA', current_timestamp(), current_timestamp(), false),
('Elektrické přímotopné', 'ELEKTRO_PRIMOTOP', 'Přímotopné elektrické vytápění', 'Elektřina', 5, 2, 'VYSOKA', current_timestamp(), current_timestamp(), false),
('Elektrické akumulační', 'ELEKTRO_AKUMULACE', 'Akumulační elektrické vytápění', 'Elektřina', 4, 2, 'VYSOKA', current_timestamp(), current_timestamp(), false),
('Tepelné čerpadlo vzduch-voda', 'TC_VZDUCH_VODA', 'Tepelné čerpadlo vzduch-voda', 'Elektřina/tepelné čerpadlo', 5, 5, 'NIZKA', current_timestamp(), current_timestamp(), false),
('Tepelné čerpadlo zemní', 'TC_ZEMNI', 'Geotermální tepelné čerpadlo', 'Elektřina/geotermální', 5, 5, 'NIZKA', current_timestamp(), current_timestamp(), false),
('Dálkové teplo', 'DALKOVE', 'Dálkové vytápění z teplárny', 'Teplárenská pára/voda', 4, 4, 'STREDNI', current_timestamp(), current_timestamp(), false),
('Kotel na tuhá paliva', 'TUHA_PALIVA', 'Kotel na uhlí, dřevo, pelety', 'Uhlí/dřevo/pelety', 2, 1, 'STREDNI', current_timestamp(), current_timestamp(), false),
('Krbová kamna', 'KRBY', 'Krbová kamna na dřevo', 'Dřevo', 2, 2, 'NIZKA', current_timestamp(), current_timestamp(), false),
('Solární systém', 'SOLAR', 'Solární vytápění s doplňkovým zdrojem', 'Sluneční energie', 4, 5, 'NIZKA', current_timestamp(), current_timestamp(), false),
('Kombinované vytápění', 'KOMBINOVANE', 'Kombinace více zdrojů vytápění', 'Smíšené', 4, 3, 'STREDNI', current_timestamp(), current_timestamp(), false),
('Bez vytápění', 'ZADNE', 'Nemovitost bez stálého vytápění', 'Žádné', 1, 5, 'NIZKA', current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_heating ORDER BY property_heating_id;
