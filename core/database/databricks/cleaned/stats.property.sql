CREATE TABLE IF NOT EXISTS realitky.stats.property (
    property_stats_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_id BIGINT,
    parsed_property INT,
    cleaned_property INT,
    located_property INT,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    upd_dt TIMESTAMP,
    upd_process_id STRING,
    del_flag BOOLEAN
);