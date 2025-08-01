-- DROP TABLE realitky.cleaned.property_price;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_price (
    property_price_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor cenového záznamu
    
    property_id STRING NOT NULL, -- ID nemovitosti (FK na property)
    property_mode STRING NOT NULL, -- Režim nemovitosti (např. prodej, pronájem)
    
    price_amount DECIMAL(15,2) NOT NULL, -- Celková cena nemovitosti v Kč
    price_per_sqm DECIMAL(10,2), -- Cena za m² (vypočítaná jako price_amount/area_total_sqm)
    currency_code STRING NOT NULL, -- Měna (CZK, EUR, USD)
    
    price_type STRING NOT NULL, -- Typ ceny (VISIBLE - viditelná cena, HIDDEN - skrytá cena)
    price_detail STRING, -- Detail ceny (např. "Cena k jednání", "Cena včetně služeb")
    
    src_web STRING NOT NULL, -- Zdrojová webová stránka (např. Sreality, Bezrealitky)
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    ins_process_id STRING NOT NULL, -- ID procesu, který vložil záznam
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    upd_process_id STRING, -- ID procesu, který záznam aktualizoval
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
PARTITIONED BY (src_web)
TBLPROPERTIES (
    'description' = 'Current property prices with the ability to track price changes over time - partitioned by src_web for concurrent processing',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.checkpointRetentionDuration' = 'interval 30 days',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days',
    'delta.isolationLevel' = 'WriteSerializable',
    'delta.enableChangeDataFeed' = 'true'
);

COMMENT ON TABLE realitky.cleaned.property_price IS 'Aktuální ceny nemovitostí s možností sledování změn cen v čase.';

COMMENT ON COLUMN realitky.cleaned.property_price.property_price_id IS 'Unikátní identifikátor cenového záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price.property_id IS 'ID nemovitosti (FK na property).';
COMMENT ON COLUMN realitky.cleaned.property_price.property_mode IS 'Režim nemovitosti (např. prodej, pronájem).';
COMMENT ON COLUMN realitky.cleaned.property_price.price_amount IS 'Celková cena nemovitosti v Kč.';
COMMENT ON COLUMN realitky.cleaned.property_price.price_per_sqm IS 'Cena za m² (vypočítaná jako price_amount/area_total_sqm).';
COMMENT ON COLUMN realitky.cleaned.property_price.currency_code IS 'Měna (CZK, EUR, USD).';
COMMENT ON COLUMN realitky.cleaned.property_price.price_type IS 'Typ ceny (VISIBLE - viditelná cena, HIDDEN - skrytá cena).';
COMMENT ON COLUMN realitky.cleaned.property_price.price_detail IS 'Detail ceny (např. "Cena k jednání", "Cena včetně služeb").';
COMMENT ON COLUMN realitky.cleaned.property_price.src_web IS 'Zdrojová webová stránka (např. Sreality, Bezrealitky).';
COMMENT ON COLUMN realitky.cleaned.property_price.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price.ins_process_id IS 'ID procesu, který vložil záznam.';
COMMENT ON COLUMN realitky.cleaned.property_price.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_price.upd_process_id IS 'ID procesu, který záznam aktualizoval.';
COMMENT ON COLUMN realitky.cleaned.property_price.del_flag IS 'Příznak smazání záznamu.';