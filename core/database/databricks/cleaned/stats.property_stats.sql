-- DROP TABLE realitky.stats.property_stats;

CREATE TABLE IF NOT EXISTS realitky.stats.property_stats (
    property_stats_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_id STRING NOT NULL,
    history_date DATE,
    history_check BOOLEAN,
    images_date DATE,
    images_check BOOLEAN,
    images_count INT,
    poi_places_date DATE,
    poi_places_check BOOLEAN,
    poi_places_count INT,
    catastre_date DATE,
    catastre_check BOOLEAN,
    src_web STRING,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
)
USING DELTA
PARTITIONED BY (src_web)
TBLPROPERTIES (
    'description' = 'Základní informace o nemovitostech. Hlavní tabulka obsahující všechny důležité údaje o nemovitostech včetně adres, charakteristik a vybavení.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days',
    'delta.checkpointRetentionDuration' = 'interval 30 days'
);

-- Table comments
COMMENT ON TABLE realitky.stats.property_stats IS 'Statistiky a další údaje o nemovitostech.';

-- Column comments
COMMENT ON COLUMN realitky.stats.property_stats.property_stats_key IS 'Unikátní identifikátor statistik nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.property_id IS 'ID nemovitosti, na kterou se statistiky vztahují.';
COMMENT ON COLUMN realitky.stats.property_stats.history_date IS 'Datum poslední aktualizace historie nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.history_check IS 'Příznak, zda byla provedena kontrola historie nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.images_date IS 'Datum poslední aktualizace obrázků nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.images_check IS 'Příznak, zda byla provedena kontrola obrázků nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.images_count IS 'Počet obrázků spojených s nemovitostí.';
COMMENT ON COLUMN realitky.stats.property_stats.poi_places_date IS 'Datum poslední aktualizace údajů o místech zájmu (POI).';
COMMENT ON COLUMN realitky.stats.property_stats.poi_places_check IS 'Příznak, zda byla provedena kontrola míst zájmu (POI).';
COMMENT ON COLUMN realitky.stats.property_stats.poi_places_count IS 'Počet míst zájmu (POI) v okolí nemovitosti.';
COMMENT ON COLUMN realitky.stats.property_stats.catastre_date IS 'Datum poslední aktualizace údajů z katastru nemovitostí.';
COMMENT ON COLUMN realitky.stats.property_stats.catastre_check IS 'Příznak, zda byla provedena kontrola údajů z katastru nemovitostí.';
COMMENT ON COLUMN realitky.stats.property_stats.src_web IS 'Zdrojová webová stránka, ze které je nemovitost získána.';
COMMENT ON COLUMN realitky.stats.property_stats.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.stats.property_stats.ins_process_id IS 'ID procesu, který vložil záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.property_stats.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.stats.property_stats.upd_process_id IS 'ID procesu, který naposledy aktualizoval záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.property_stats.del_flag IS 'Příznak smazání záznamu.';