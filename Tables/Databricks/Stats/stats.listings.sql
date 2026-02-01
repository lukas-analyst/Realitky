
-- DROP TABLE realitky.stats.listings;

CREATE TABLE IF NOT EXISTS realitky.stats.listings (
    listings_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE,
    src_web STRING,
    total_listings INT,
    scraped_true INT,
    parsed_true INT,
    located_true INT,
    status_active INT,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
)
USING DELTA
PARTITIONED BY (src_web)
TBLPROPERTIES (
    'description' = 'Souhrnná tabulka s počty inzerátů a metadaty pro jednotlivé zdroje.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days',
    'delta.checkpointRetentionDuration' = 'interval 30 days'
);

-- Table comments
COMMENT ON TABLE realitky.stats.listings IS 'Statistiky a souhrnné údaje o inzerátech napříč zdroji.';

-- Column comments
COMMENT ON COLUMN realitky.stats.listings.listings_key IS 'Unikátní identifikátor souhrnu inzerátů.';
COMMENT ON COLUMN realitky.stats.listings.date IS 'Datum agregace statistik.';
COMMENT ON COLUMN realitky.stats.listings.src_web IS 'Zdrojová webová stránka.';
COMMENT ON COLUMN realitky.stats.listings.total_listings IS 'Celkový počet inzerátů.';
COMMENT ON COLUMN realitky.stats.listings.scraped_true IS 'Počet inzerátů, které byly úspěšně staženy (scraped = true).';
COMMENT ON COLUMN realitky.stats.listings.parsed_true IS 'Počet inzerátů, které byly úspěšně zpracovány (parsed = true).';
COMMENT ON COLUMN realitky.stats.listings.located_true IS 'Počet inzerátů, které mají určenou polohu (located = true).';
COMMENT ON COLUMN realitky.stats.listings.status_active IS 'Počet aktivních inzerátů (status = active).';
COMMENT ON COLUMN realitky.stats.listings.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.stats.listings.ins_process_id IS 'ID procesu, který vložil záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.listings.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.stats.listings.upd_process_id IS 'ID procesu, který naposledy aktualizoval záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.listings.del_flag IS 'Příznak smazání záznamu.';
