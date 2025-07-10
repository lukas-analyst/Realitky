-- DROP TABLE realitky.cleaned.property_construction_type;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_construction_type (
    property_construction_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu konstrukce
    
    construction_name STRING NOT NULL, -- Název typu konstrukce
    construction_code STRING, -- Kód typu (např. PANEL, CIHLA, DREVO)
    desc STRING, -- Popis typu konstrukce
    
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

COMMENT ON TABLE realitky.cleaned.property_construction_type IS 'Číselník typů konstrukce (panel, cihla, dřevo, smíšené).';

COMMENT ON COLUMN realitky.cleaned.property_construction_type.property_construction_type_id IS 'Unikátní identifikátor typu konstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_name IS 'Název typu konstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.construction_code IS 'Kód typu (např. PANEL, CIHLA, DREVO).';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.desc IS 'Popis typu konstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_construction_type.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_construction_type ZORDER BY (construction_code, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_construction_type 
(construction_name, construction_code, desc, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ konstrukce není specifikován', current_timestamp(), current_timestamp(), false),
('Panelová', 'PANEL', 'Panelová konstrukce typická pro bytové domy z 70.-80. let', current_timestamp(), current_timestamp(), false),
('Cihlová', 'CIHLA', 'Klasická cihlová konstrukce s vysokou tepelnou akumulací', current_timestamp(), current_timestamp(), false),
('Dřevěná', 'DREVO', 'Dřevěná konstrukce, včetně roubenek a dřevostaveb', current_timestamp(), current_timestamp(), false),
('Železobetonová', 'ZELEZO_BETON', 'Železobetonová monolitická konstrukce', current_timestamp(), current_timestamp(), false),
('Skeletová', 'SKELET', 'Skeletová konstrukce s výplní ze sendvičových panelů', current_timestamp(), current_timestamp(), false),
('Smíšená', 'SMISENA', 'Kombinace více konstrukčních systémů', current_timestamp(), current_timestamp(), false),
('Kamenná', 'KAMEN', 'Kamenná konstrukce, historické stavby', current_timestamp(), current_timestamp(), false),
('Ocelová', 'OCEL', 'Ocelová konstrukce, typická pro průmyslové budovy', current_timestamp(), current_timestamp(), false),
('Sendvičová', 'SENDVIC', 'Sendvičové panely s tepelnou izolací', current_timestamp(), current_timestamp(), false),
('Nízkoenergetická', 'NIZKOENERGIE', 'Speciální konstrukce pro nízkoenergetické domy', current_timestamp(), current_timestamp(), false),
('Pasivní dům', 'PASIVNI', 'Konstrukce pasivního domu s minimální energetickou náročností', current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_construction_type ORDER BY property_construction_type_id;
