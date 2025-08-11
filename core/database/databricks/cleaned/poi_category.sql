-- DROP TABLE realitky.cleaned.poi_category;

CREATE TABLE IF NOT EXISTS realitky.cleaned.poi_category (
    poi_category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_key BIGINT NOT NULL,
    category_code STRING NOT NULL,
    category_name STRING NOT NULL,
    category_description STRING,
    max_distance_m DOUBLE,
    max_results INT,
    priority INT,
    ins_dt TIMESTAMP NOT NULL,
    upd_dt TIMESTAMP NOT NULL,
    del_flag BOOLEAN NOT NULL
) 
USING DELTA
TBLPROPERTIES (
    'description' = 'Katalog kategorií POI (např. doprava, stravování, školy)',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.poi_category IS 'Katalog kategorií POI (např. doprava, stravování, školy).';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.poi_category.poi_category_id IS 'Unikátní identifikátor kategorie POI.';
COMMENT ON COLUMN realitky.cleaned.poi_category.category_key IS 'Klíč kategorie POI (např. 1, 2, 3).';
COMMENT ON COLUMN realitky.cleaned.poi_category.category_code IS 'Kód kategorie POI (např. transport_bus, restaurant).';
COMMENT ON COLUMN realitky.cleaned.poi_category.category_name IS 'Název kategorie POI (např. Autobusová zastávka, Restaurace).';
COMMENT ON COLUMN realitky.cleaned.poi_category.category_description IS 'Popis kategorie POI (např. zastávka autobusu, restaurace s českou kuchyní).';
COMMENT ON COLUMN realitky.cleaned.poi_category.max_distance_m IS 'Maximální vzdálenost v metrech pro vyhledávání POI v této kategorii.';
COMMENT ON COLUMN realitky.cleaned.poi_category.max_results IS 'Maximální počet výsledků pro vyhledávání v této kategorii.';
COMMENT ON COLUMN realitky.cleaned.poi_category.priority IS 'Priorita kategorie pro řazení výsledků (nižší číslo = vyšší priorita).';
COMMENT ON COLUMN realitky.cleaned.poi_category.ins_dt IS 'Datum a čas vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.poi_category.upd_dt IS 'Datum a čas poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.poi_category.del_flag IS 'Příznak smazání záznamu (TRUE = smazáno, FALSE = aktivní).';