-- DROP TABLE realitky.cleaned.property_accessibility;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_accessibility (
    property_accessibility_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu přístupové cesty
    
    accessibility_name STRING NOT NULL, -- Název typu přístupové cesty
    accessibility_code STRING, -- Kód typu (např. ASFALT, DLAZBA, STERK)
    desc STRING, -- Popis typu přístupové cesty
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Číselník typů přístupových cest k nemovitostem',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_accessibility IS 'Číselník typů přístupových cest k nemovitostem.';

COMMENT ON COLUMN realitky.cleaned.property_accessibility.property_accessibility_id IS 'Unikátní identifikátor typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_name IS 'Název typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.accessibility_code IS 'Kód typu (např. ASFALT, DLAZBA, STERK).';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.desc IS 'Popis typu přístupové cesty.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_accessibility.del_flag IS 'Příznak smazání záznamu.';

-- Create optimized indexes using Z-ORDER clustering
OPTIMIZE realitky.cleaned.property_accessibility ZORDER BY (accessibility_code, del_flag);

-- Insert sample reference data
INSERT INTO realitky.cleaned.property_accessibility 
(accessibility_name, accessibility_code, desc, ins_dt, upd_dt, del_flag)
VALUES 
('Nespecifikováno', 'NEURCENO', 'Typ přístupové cesty není specifikován', current_timestamp(), current_timestamp(), false),
('Asfaltová cesta', 'ASFALT', 'Přístupová cesta z asfaltu', current_timestamp(), current_timestamp(), false),
('Betonová cesta', 'BETON', 'Přístupová cesta z betonu', current_timestamp(), current_timestamp(), false),
('Dlážděná cesta', 'DLAZBA', 'Přístupová cesta z dlažby nebo dlažebních kostek', current_timestamp(), current_timestamp(), false),
('Zámková dlažba', 'ZAMKOVA_DLAZBA', 'Přístupová cesta ze zámkové dlažby', current_timestamp(), current_timestamp(), false),
('Štěrková cesta', 'STERK', 'Přístupová cesta ze štěrku', current_timestamp(), current_timestamp(), false),
('Travnatá cesta', 'TRAVNIK', 'Přístupová cesta přes travnatý povrch', current_timestamp(), current_timestamp(), false),
('Zemní cesta', 'ZEMNI', 'Nezpevněná zemní přístupová cesta', current_timestamp(), current_timestamp(), false),
('Kamenná cesta', 'KAMEN', 'Přístupová cesta z přírodního kamene', current_timestamp(), current_timestamp(), false),
('Dřevěná cesta', 'DREVO', 'Přístupová cesta z dřevěných prvků (prken, dlaždic)', current_timestamp(), current_timestamp(), false),
('Smíšený povrch', 'SMISENY', 'Kombinace více typů povrchů přístupové cesty', current_timestamp(), current_timestamp(), false),
('Bez přístupové cesty', 'ZADNA', 'Nemovitost bez zpevněné přístupové cesty', current_timestamp(), current_timestamp(), false);

-- Show inserted data
SELECT * FROM realitky.cleaned.property_accessibility ORDER BY property_accessibility_id;
