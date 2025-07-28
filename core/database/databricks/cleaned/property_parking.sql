-- DROP TABLE realitky.cleaned.property_parking;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_parking (
    property_parking_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu parkování
    
    parking_name STRING NOT NULL, -- Název typu parkování
    desc STRING, -- Popis typu parkování

    parking_code STRING, -- Kód typu (např. POZEMEK, ULICE, STANI)

    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů parkování (na pozemku, ulici, parkovací stání)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_parking IS 'Číselník typů parkování (na pozemku, ulici, parkovací stání).';

COMMENT ON COLUMN realitky.cleaned.property_parking.property_parking_id IS 'Unikátní identifikátor typu parkování.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_name IS 'Název typu parkování.';
COMMENT ON COLUMN realitky.cleaned.property_parking.parking_code IS 'Kód typu (např. POZEMEK, ULICE, STANI).';
COMMENT ON COLUMN realitky.cleaned.property_parking.desc IS 'Popis typu parkování.';
COMMENT ON COLUMN realitky.cleaned.property_parking.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_parking.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_parking.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_parking ZORDER BY (parking_code, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_parking 
(parking_name, parking_code, desc, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ parkování není specifikován', current_timestamp(), current_timestamp(), false),
('Parkování na pozemku', 'POZEMEK', 'Parkování na vlastním nebo přilehlém pozemku', current_timestamp(), current_timestamp(), false),
('Garáž', 'GARAZ', 'Uzavřená garáž pro vozidlo', current_timestamp(), current_timestamp(), false),
('Krytá garáž', 'GARAZ_KRYTA', 'Krytá nebo podzemní garáž', current_timestamp(), current_timestamp(), false),
('Parkování na ulici', 'ULICE', 'Parkování na veřejné komunikaci', current_timestamp(), current_timestamp(), false),
('Vyhrazené stání', 'VYHRAZENE', 'Vyhrazené parkovací místo', current_timestamp(), current_timestamp(), false),
('Parkovací dům', 'PARKOVACI_DUM', 'Parkování v parkovacím domě', current_timestamp(), current_timestamp(), false),
('Podzemní parkování', 'PODZEMI', 'Podzemní parkovací místa', current_timestamp(), current_timestamp(), false),
('Carport', 'CARPORT', 'Zastřešené parkování bez stěn', current_timestamp(), current_timestamp(), false),
('Parkování před domem', 'PRED_DOMEM', 'Parkování na veřejném prostranství před domem', current_timestamp(), current_timestamp(), false),
('Parkování na dvoře', 'DVUR', 'Parkování na společném dvoře', current_timestamp(), current_timestamp(), false),
('Bez parkování', 'ZADNE', 'Bez možnosti parkování', current_timestamp(), current_timestamp(), false),
('Rezidentní parkování', 'REZIDENTNI', 'Parkování vyhrazené pro rezidenty', current_timestamp(), current_timestamp(), false),
('Parkování za poplatek', 'PLACENE', 'Parkování za poplatek (parkovací hodiny, karty)', current_timestamp(), current_timestamp(), false),
('Návštěvnické parkování', 'NAVSTEVNICKE', 'Parkování pro návštěvy', current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_parking ORDER BY property_parking_id;
