-- DROP TABLE realitky.cleaned.property_price_h;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_price_h (
    property_price_h_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate key pro historickou tabulku
    property_price_id BIGINT NOT NULL, -- Business key - původní ID z hlavní tabulky
    
    valid_from TIMESTAMP NOT NULL, -- Datum začátku platnosti záznamu
    valid_to TIMESTAMP, -- Datum konce platnosti záznamu (NULL = aktuální)
    is_current BOOLEAN NOT NULL, -- Příznak aktuálního záznamu
    
    property_id STRING NOT NULL, -- ID nemovitosti (FK na property)
    
    price_amount DECIMAL(15,2) NOT NULL, -- Celková cena nemovitosti v Kč
    price_per_sqm DECIMAL(10,2), -- Cena za m² (vypočítaná jako price_amount/area_total_sqm)
    currency_code STRING NOT NULL, -- Měna (CZK, EUR, USD)
    
    price_type STRING NOT NULL, -- Typ ceny (VISIBLE - viditelná cena, HIDDEN - skrytá cena)
    
    src_web STRING NOT NULL, -- Zdrojová webová stránka (např. Sreality, Bezrealitky)
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    ins_process_id STRING NOT NULL, -- ID ETL procesu/job run ID, který záznam vložil
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    upd_process_id STRING, -- ID ETL procesu, který záznam aktualizoval
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Historická tabulka pro sledování změn cen nemovitostí. Implementuje SCD Type 2 s úplnou historií všech cenových změn.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.checkpointRetentionDuration' = 'interval 365 days',
    'delta.deletedFileRetentionDuration' = 'interval 30 days',
    'delta.logRetentionDuration' = 'interval 90 days'
);

COMMENT ON TABLE realitky.cleaned.property_price_h IS 'Historická tabulka pro sledování změn cen nemovitostí. Implementuje SCD Type 2 s úplnou historií všech cenových změn.';

COMMENT ON COLUMN realitky.cleaned.property_price_h.property_price_h_id IS 'Surrogate key pro historickou tabulku (auto-increment).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.property_price_id IS 'Business key - původní ID z hlavní tabulky.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.valid_from IS 'Datum začátku platnosti záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.valid_to IS 'Datum konce platnosti záznamu (NULL = aktuální).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.is_current IS 'Příznak aktuálního záznamu (TRUE = aktuální, FALSE = historický).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.property_id IS 'ID nemovitosti (FK na property).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.price_amount IS 'Celková cena nemovitosti v Kč.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.price_per_sqm IS 'Cena za m² (vypočítaná jako price_amount/area_total_sqm).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.currency_code IS 'Měna (CZK, EUR, USD).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.price_type IS 'Typ ceny (VISIBLE - viditelná cena, HIDDEN - skrytá cena).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.src_web IS 'Zdrojová webová stránka (např. Sreality, Bezrealitky).';
COMMENT ON COLUMN realitky.cleaned.property_price_h.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.ins_process_id IS 'ID ETL procesu/job run ID, který záznam vložil.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.upd_process_id IS 'ID ETL procesu, který záznam aktualizoval.';
COMMENT ON COLUMN realitky.cleaned.property_price_h.del_flag IS 'Příznak smazání záznamu.';