# Databricks notebook source
# Configuration widgets
dbutils.widgets.text("scraper", "bezrealitky", "Scraper Name")
dbutils.widgets.text("process_id", "import_001", "Process ID")

# Get widget values
scraper = dbutils.widgets.get("scraper")
process_id = dbutils.widgets.get("process_id")

input_table = f"realitky.raw.listings_{scraper}"
output_table = "realitky.stats.property_stats"

print(f"Configuration:")
print(f"- Scraper {scraper}")
print(f"- Process ID: {process_id}")

# COMMAND ----------

spark.sql(f"""
    MERGE INTO {output_table} target
    USING (
    SELECT DISTINCT
        listing_id AS property_id, 
        '1000-01-01' AS history_date,
        FALSE AS history_check,
        '1000-01-01' AS images_date,
        FALSE AS images_check,
        0 AS images_count,
        '1000-01-01' AS poi_places_date,
        FALSE AS poi_places_check,
        0 AS poi_places_count,
        '1000-01-01' AS catastre_date,
        FALSE AS catastre_check,
        '{scraper}' AS src_web,
        current_timestamp() AS ins_dt,
        '{process_id}' AS ins_process_id,
        current_timestamp() AS upd_dt,
        '{process_id}' AS upd_process_id,
        false AS del_flag
    FROM {input_table}
    WHERE  del_flag = FALSE
    ) AS source
    ON target.property_id = source.property_id
    AND target.src_web = '{scraper}' -- partitioning
    WHEN NOT MATCHED THEN 
    INSERT (
        property_id,
        history_date,
        history_check,
        images_date,
        images_check,
        images_count,
        poi_places_date,
        poi_places_check,
        poi_places_count,
        catastre_date,
        catastre_check,
        src_web,
        ins_dt,
        ins_process_id,
        upd_dt,
        upd_process_id,
        del_flag
    ) VALUES (
        source.property_id, 
        source.history_date,
        source.history_check,
        source.images_date,
        source.images_check,
        source.images_count,
        source.poi_places_date,
        source.poi_places_check,
        source.poi_places_count,
        source.catastre_date,
        source.catastre_check,
        source.src_web,
        source.ins_dt,
        source.ins_process_id,
        source.upd_dt,
        source.upd_process_id,
        source.del_flag
    )
    """)