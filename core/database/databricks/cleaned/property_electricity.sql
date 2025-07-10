-- DROP TABLE realitky.cleaned.property_electricity;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_electricity (
    property_electricity_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu elektřiny
    
    electricity_name STRING NOT NULL, -- Název typu elektřiny
    electricity_code STRING, -- Kód typu (např. 220V, 380V, ZADNY)
    desc STRING, -- Popis typu elektřiny
    voltage STRING, -- Napětí (220V, 380V)
    capacity_rating SMALLINT, -- Hodnocení kapacity (1-5)
    
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

COMMENT ON TABLE realitky.cleaned.property_electricity IS 'Číselník typů elektrického připojení.';

COMMENT ON COLUMN realitky.cleaned.property_electricity.property_electricity_id IS 'Unikátní identifikátor typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_name IS 'Název typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.electricity_code IS 'Kód typu (např. 220V, 380V, ZADNY).';
COMMENT ON COLUMN realitky.cleaned.property_electricity.desc IS 'Popis typu elektřiny.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.voltage IS 'Napětí (220V, 380V).';
COMMENT ON COLUMN realitky.cleaned.property_electricity.capacity_rating IS 'Hodnocení kapacity (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_electricity.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_electricity.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_electricity ZORDER BY (electricity_code, voltage, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_electricity 
(electricity_name, electricity_code, desc, voltage, capacity_rating, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ elektrického připojení není specifikován', 'N/A', -1, current_timestamp(), current_timestamp(), false),
('Standardní 230V', '230V', 'Standardní domácí elektrické připojení 230V/50Hz', '230V', 3, current_timestamp(), current_timestamp(), false),
('Silnoproud 400V', '400V', 'Třífázové připojení 400V pro vyšší odběr', '400V', 5, current_timestamp(), current_timestamp(), false),
('Maloodběr', 'MALOODBER', 'Připojení s omezeným příkonem do 3kW', '230V', 1, current_timestamp(), current_timestamp(), false),
('Středoodběr', 'STREDOODBER', 'Připojení s příkonem 3-25kW', '230V/400V', 3, current_timestamp(), current_timestamp(), false),
('Velkoodběr', 'VELKOODBER', 'Připojení s vysokým příkonem nad 25kW', '400V', 5, current_timestamp(), current_timestamp(), false),
('Bez elektrického připojení', 'ZADNE', 'Nemovitost není připojena k elektrické síti', 'N/A', 0, current_timestamp(), current_timestamp(), false),
('Vlastní zdroj', 'VLASTNI', 'Nezávislý zdroj elektřiny (fotovoltaika, generátor)', 'Variabilní', 4, current_timestamp(), current_timestamp(), false),
('Fotovoltaika', 'FOTOVOLTAIKA', 'Elektrické připojení s fotovoltaickými panely', '230V/400V', 4, current_timestamp(), current_timestamp(), false),
('Nouzové napájení', 'NOUZOVE', 'Záložní elektrické napájení (UPS, generátor)', '230V/400V', 2, current_timestamp(), current_timestamp(), false),
('Průmyslové 6kV', '6KV', 'Vysokonapěťové připojení pro průmyslové objekty', '6kV', 5, current_timestamp(), current_timestamp(), false),
('Inteligentní síť', 'SMART_GRID', 'Připojení k inteligentní elektrické síti', '230V/400V', 5, current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_electricity ORDER BY property_electricity_id;
