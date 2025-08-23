-- DROP TABLE IF EXISTS realitky.stats.scrapers;

CREATE TABLE IF NOT EXISTS realitky.stats.scrapers (
    scrapers_stats_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE,
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