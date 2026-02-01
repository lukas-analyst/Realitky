-- DROP TABLE IF EXISTS realitky.stats.scrapers;

CREATE TABLE IF NOT EXISTS realitky.stats.scrapers (
    scrapers_stats_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE,
    iteration INT,
    scraper_name STRING,
    scraped_listings INT,
    parsed_listings INT, 
    cleaned_listings INT,
    located_listings INT,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
);

-- Table comments
COMMENT ON TABLE realitky.stats.scrapers IS 'Statistiky o běhu scraperů.';

-- Column comments
COMMENT ON COLUMN realitky.stats.scrapers.scrapers_stats_key IS 'Unikátní identifikátor záznamu statistik scraperu.';
COMMENT ON COLUMN realitky.stats.scrapers.date IS 'Datum agregace statistik.';
COMMENT ON COLUMN realitky.stats.scrapers.iteration IS 'Iterační číslo pro sledování opakovaných běhů za stejný den.';
COMMENT ON COLUMN realitky.stats.scrapers.scraper_name IS 'Název scraperu.';
COMMENT ON COLUMN realitky.stats.scrapers.scraped_listings IS 'Počet inzerátů, které byly úspěšně staženy (scraped = true).';
COMMENT ON COLUMN realitky.stats.scrapers.parsed_listings IS 'Počet inzerátů, které byly úspěšně zpracovány (parsed = true).';
COMMENT ON COLUMN realitky.stats.scrapers.cleaned_listings IS 'Počet inzerátů, které byly úspěšně očištěny (cleaned = true).';
COMMENT ON COLUMN realitky.stats.scrapers.located_listings IS 'Počet inzerátů, které mají určenou polohu (located = true).';
COMMENT ON COLUMN realitky.stats.scrapers.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.stats.scrapers.ins_process_id IS 'ID procesu, který vložil záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.scrapers.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.stats.scrapers.upd_process_id IS 'ID procesu, který naposledy aktualizoval záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.stats.scrapers.del_flag IS 'Příznak smazání záznamu.';