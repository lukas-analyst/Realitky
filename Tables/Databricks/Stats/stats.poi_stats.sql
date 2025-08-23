CREATE TABLE IF NOT EXISTS realitky.stats.poi (
    poi_stats_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE,
    poi_category_id BIGINT,
    poi_listings INT,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
);