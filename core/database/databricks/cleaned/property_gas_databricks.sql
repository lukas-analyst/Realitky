-- DROP TABLE realitky.cleaned.property_gas;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_gas (
    property_gas_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu plynové přípojky
    
    gas_name STRING NOT NULL, -- Název typu plynové přípojky
    gas_code STRING, -- Kód typu (např. ZEMNI, PROPAN, ZADNY)
    description STRING, -- Popis typu plynové přípojky
    gas_type STRING, -- Typ plynu (zemní, propan-butan, bioplyn)
    connection_type STRING, -- Typ připojení (veřejná síť, nádrž, lahve)
    safety_rating SMALLINT, -- Hodnocení bezpečnosti (1-5)
    cost_efficiency SMALLINT, -- Hodnocení nákladové efektivity (1-5)
    
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
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_name IS 'Název typu plynové přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_code IS 'Kód typu (např. ZEMNI, PROPAN, ZADNY).';
COMMENT ON COLUMN realitky.cleaned.property_gas.description IS 'Popis typu plynové přípojky.';
COMMENT ON COLUMN realitky.cleaned.property_gas.gas_type IS 'Typ plynu.';
COMMENT ON COLUMN realitky.cleaned.property_gas.connection_type IS 'Typ připojení.';
COMMENT ON COLUMN realitky.cleaned.property_gas.safety_rating IS 'Hodnocení bezpečnosti (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_gas.cost_efficiency IS 'Hodnocení nákladové efektivity (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_gas.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_gas.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_gas.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_gas ZORDER BY (gas_code, gas_type, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_gas 
(gas_name, gas_code, description, gas_type, connection_type, safety_rating, cost_efficiency, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ plynové přípojky není specifikován', 'Neznámý', 'Neznámé', 0, 0, current_timestamp(), current_timestamp(), false),
('Zemní plyn - veřejná síť', 'ZEMNI_SIT', 'Připojení k veřejné distribuční síti zemního plynu', 'Zemní plyn', 'Veřejná síť', 5, 4, current_timestamp(), current_timestamp(), false),
('Zemní plyn - přípojka', 'ZEMNI_PRIPOJKA', 'Zemní plyn s vlastní přípojkou k distribuční síti', 'Zemní plyn', 'Vlastní přípojka', 5, 4, current_timestamp(), current_timestamp(), false),
('Propan-butan - nádrž', 'PROPAN_NADRZ', 'Propan-butan z nadzemní nebo podzemní nádrže', 'Propan-butan', 'Nádrž', 4, 3, current_timestamp(), current_timestamp(), false),
('Propan-butan - lahve', 'PROPAN_LAHVE', 'Propan-butan z výměnných lahví', 'Propan-butan', 'Lahve', 3, 2, current_timestamp(), current_timestamp(), false),
('Bioplyn - vlastní výroba', 'BIOPLYN', 'Bioplyn z vlastní bioplynové stanice', 'Bioplyn', 'Vlastní výroba', 4, 5, current_timestamp(), current_timestamp(), false),
('Stlačený zemní plyn (CNG)', 'CNG', 'Stlačený zemní plyn pro speciální použití', 'CNG', 'Tlakové nádoby', 4, 3, current_timestamp(), current_timestamp(), false),
('Zkapalněný zemní plyn (LNG)', 'LNG', 'Zkapalněný zemní plyn pro větší spotřebiče', 'LNG', 'Kryogenní nádrž', 4, 4, current_timestamp(), current_timestamp(), false),
('Bez plynu', 'ZADNY', 'Nemovitost bez plynové přípojky', 'Žádný', 'Bez připojení', 5, 5, current_timestamp(), current_timestamp(), false),
('Připraveno pro plyn', 'PRIPRAVENO', 'Nemovitost připravena pro budoucí plynovou přípojku', 'Připraveno', 'Příprava', 5, 3, current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_gas ORDER BY property_gas_id;
