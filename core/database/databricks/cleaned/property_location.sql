-- DROP TABLE realitky.cleaned.property_location;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_location (
    property_location_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu lokality
    
    location_name STRING NOT NULL, -- Název typu lokality
    location_code STRING, -- Kód typu (např. CENTRUM, PREDMESTI, KLIDNA)
    desc STRING, -- Popis typu lokality
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů lokalit (centrum, předměstí, klidná část)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_location IS 'Číselník typů lokalit (centrum, předměstí, klidná část).';

COMMENT ON COLUMN realitky.cleaned.property_location.property_location_id IS 'Unikátní identifikátor typu lokality.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_name IS 'Název typu lokality.';
COMMENT ON COLUMN realitky.cleaned.property_location.location_code IS 'Kód typu (např. CENTRUM, PREDMESTI, KLIDNA).';
COMMENT ON COLUMN realitky.cleaned.property_location.desc IS 'Popis typu lokality.';
COMMENT ON COLUMN realitky.cleaned.property_location.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_location.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_location.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_location ZORDER BY (location_code, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_location 
(location_name, location_code, desc, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ lokality není specifikován', current_timestamp(), current_timestamp(), false),
('Centrum města', 'CENTRUM', 'Centrum města s dobrou občanskou vybaveností a dopravní dostupností', current_timestamp(), current_timestamp(), false),
('Širší centrum', 'SIRSE_CENTRUM', 'Širší centrum města s velmi dobrou dostupností služeb', current_timestamp(), current_timestamp(), false),
('Předměstí', 'PREDMESTI', 'Předměstské oblasti s řidší zástavbou a klidnějším prostředím', current_timestamp(), current_timestamp(), false),
('Klidná část', 'KLIDNA', 'Klidná část města s minimálním provozem', current_timestamp(), current_timestamp(), false),
('Rušná lokalita', 'RUSNA', 'Lokalita s vyšším dopravním zatížením nebo hlukem', current_timestamp(), current_timestamp(), false),
('Výborná lokalita', 'VYBORNE', 'Prestižní lokalita s výbornou infrastrukturou', current_timestamp(), current_timestamp(), false),
('Průmyslová zóna', 'PRUMYSL', 'Průmyslová nebo komerční zóna', current_timestamp(), current_timestamp(), false),
('Rekreační oblast', 'REKREACE', 'Oblast určená především pro rekreaci a odpočinek', current_timestamp(), current_timestamp(), false),
('Nová zástavba', 'NOVA_ZASTAVBA', 'Nově budovaná lokalita s moderní infrastrukturou', current_timestamp(), current_timestamp(), false),
('Historické centrum', 'HISTORICKE', 'Historické jádro města s památkami a kulturními objekty', current_timestamp(), current_timestamp(), false),
('Obchodní zóna', 'OBCHODNI', 'Lokalita s koncentrací obchodů a služeb', current_timestamp(), current_timestamp(), false),
('Vilová čtvrť', 'VILOVA', 'Prestižní vilová čtvrť s rodinnou zástavbou', current_timestamp(), current_timestamp(), false),
('Panelové sídliště', 'SIDLISTE', 'Sídliště s panelovou zástavbou', current_timestamp(), current_timestamp(), false),
('Přírodní prostředí', 'PRIRODA', 'Lokalita v blízkosti přírody, parků nebo lesů', current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_location ORDER BY property_location_id;
