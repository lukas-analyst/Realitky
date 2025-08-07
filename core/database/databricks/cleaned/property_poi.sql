-- DROP TABLE realitky.cleaned.property_poi;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_poi (
    property_poi_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor POI záznamu
    poi_id STRING NOT NULL,

    property_id STRING NOT NULL,
    category_id STRING NOT NULL,
    poi_name STRING NOT NULL,
    poi_address STRING NOT NULL,
    poi_lat DOUBLE NOT NULL,
    poi_lng DOUBLE NOT NULL,
    distance_km DOUBLE NOT NULL,
    distance_walking_min INT,
    distance_driving_min INT,
    rank_in_category INT,
    
    poi_attributes MAP<STRING, STRING>,
    
    data_source STRING,
    data_quality_score DOUBLE,
    
    -- Standard metadata
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
) USING DELTA
PARTITIONED BY (category_id)
TBLPROPERTIES (
    'description' = 'POI (Points of Interest) spojené s nemovitostmi, včetně jejich atributů a vzdáleností.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_poi IS 'POI (Points of Interest) spojené s nemovitostmi, včetně jejich atributů a vzdáleností.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_poi.property_poi_id IS 'Unikátní identifikátor POI záznamu';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_id IS 'Unikátní identifikátor POI';

COMMENT ON COLUMN realitky.cleaned.property_poi.property_id IS 'ID nemovitosti, ke které se POI vztahuje';
COMMENT ON COLUMN realitky.cleaned.property_poi.category_id IS 'ID kategorie POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_name IS 'Název POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_address IS 'Adresa POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_lat IS 'Zeměpisná šířka POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_lng IS 'Zeměpisná délka POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.distance_km IS 'Vzdálenost POI od nemovitosti v kilometrech';
COMMENT ON COLUMN realitky.cleaned.property_poi.distance_walking_min IS 'Vzdálenost POI od nemovitosti pěšky v minutách';
COMMENT ON COLUMN realitky.cleaned.property_poi.distance_driving_min IS 'Vzdálenost POI od nemovitosti autem v minutách';
COMMENT ON COLUMN realitky.cleaned.property_poi.rank_in_category IS 'Pořadí v kategorii podle vzdálenosti (1 = nejbližší)';

COMMENT ON COLUMN realitky.cleaned.property_poi.poi_attributes IS 'Specifické atributy POI jako key-value';

COMMENT ON COLUMN realitky.cleaned.property_poi.data_source IS 'Zdroj dat (OSM, Google Places, HERE, atd.)';
COMMENT ON COLUMN realitky.cleaned.property_poi.data_quality_score IS 'Kvalita dat 0-1';

COMMENT ON COLUMN realitky.cleaned.property_poi.ins_dt IS 'Datum vložení záznamu';
COMMENT ON COLUMN realitky.cleaned.property_poi.ins_process_id IS 'ID procesu, který záznam vložil';
COMMENT ON COLUMN realitky.cleaned.property_poi.upd_dt IS 'Datum poslední aktualizace záznamu';
COMMENT ON COLUMN realitky.cleaned.property_poi.upd_process_id IS 'ID procesu, který záznam aktualizoval';
COMMENT ON COLUMN realitky.cleaned.property_poi.del_flag IS 'Příznak smazání záznamu (TRUE = smazáno, FALSE = aktivní)';