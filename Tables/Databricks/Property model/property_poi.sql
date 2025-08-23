-- DROP TABLE realitky.cleaned.property_poi;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_poi (
    property_poi_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor POI záznamu
    poi_id STRING NOT NULL,

    property_id STRING NOT NULL,
    category_key STRING NOT NULL,
    poi_name STRING,
    poi_url STRING,
    poi_address1 STRING,
    poi_address2 STRING,
    poi_latitude DOUBLE,
    poi_longitude DOUBLE,
    poi_distance_m DOUBLE,
    poi_distance_walk_m INT,
    poi_distance_walk_min INT,
    poi_distance_drive_m INT,
    poi_distance_drive_min INT,
    poi_distance_public_transport_m INT,
    poi_distance_public_transport_min INT,

    poi_attributes STRING,
    
    data_source STRING,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
) USING DELTA
PARTITIONED BY (category_key)
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
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_attributes IS 'Atributy POI jako key-value map';

COMMENT ON COLUMN realitky.cleaned.property_poi.property_id IS 'ID nemovitosti, ke které se POI vztahuje';
COMMENT ON COLUMN realitky.cleaned.property_poi.category_key IS 'Klíč kategorie POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_name IS 'Název POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_url IS 'URL POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_address1 IS 'Adresa POI (řádek 1)';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_address2 IS 'Adresa POI (řádek 2)';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_latitude IS 'Zeměpisná šířka POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_longitude IS 'Zeměpisná délka POI';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_m IS 'Vzdálenost POI od nemovitosti v metrech';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_walk_m IS 'Vzdálenost POI od nemovitosti pěšky v metrech';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_walk_min IS 'Vzdálenost POI od nemovitosti pěšky v minutách';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_drive_m IS 'Vzdálenost POI od nemovitosti autem v metrech';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_drive_min IS 'Vzdálenost POI od nemovitosti autem v minutách';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_public_transport_m IS 'Vzdálenost POI od nemovitosti veřejnou dopravou v metrech';
COMMENT ON COLUMN realitky.cleaned.property_poi.poi_distance_public_transport_min IS 'Vzdálenost POI od nemovitosti veřejnou dopravou v minutách';

COMMENT ON COLUMN realitky.cleaned.property_poi.poi_attributes IS 'Specifické atributy POI jako key-value';

COMMENT ON COLUMN realitky.cleaned.property_poi.data_source IS 'Zdroj dat (OSM, Google Places, HERE, atd.)';

COMMENT ON COLUMN realitky.cleaned.property_poi.ins_dt IS 'Datum vložení záznamu';
COMMENT ON COLUMN realitky.cleaned.property_poi.ins_process_id IS 'ID procesu, který záznam vložil';
COMMENT ON COLUMN realitky.cleaned.property_poi.upd_dt IS 'Datum poslední aktualizace záznamu';
COMMENT ON COLUMN realitky.cleaned.property_poi.upd_process_id IS 'ID procesu, který záznam aktualizoval';
COMMENT ON COLUMN realitky.cleaned.property_poi.del_flag IS 'Příznak smazání záznamu (TRUE = smazáno, FALSE = aktivní)';