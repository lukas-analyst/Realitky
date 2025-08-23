# Databricks notebook source
dbutils.widgets.text("process_id", "3C", "Process ID")
dbutils.widgets.text("cleaner","ulovdomov", "Cleaner")

process_id = dbutils.widgets.get("process_id")
cleaner = dbutils.widgets.get("cleaner")

source_table = f"realitky.raw.listing_images_{cleaner}"
target_table = "realitky.cleaned.property_image"

# COMMAND ----------

query = f"""
    MERGE INTO {target_table} AS target
    USING (
        SELECT 
            src.listing_id AS property_id, 
            src.img_link AS img_link,
            src.img_number AS img_number,
            '{cleaner}' AS src_web,
            src.ins_dt AS original_ins_dt,
            current_timestamp() AS ins_dt,
            '{process_id}' AS ins_process_id,
            current_timestamp() AS upd_dt,
            '{process_id}' AS upd_process_id,
            false AS del_flag
        FROM {source_table} AS src
        WHERE 
            src.img_link IS NOT NULL 
            AND src.del_flag = FALSE 
    ) AS source
    ON target.property_id = source.property_id 
    AND target.img_link = source.img_link 
    AND target.src_web = '{cleaner}' -- partitioning

    WHEN NOT MATCHED THEN 
        INSERT (
            property_id,
            img_link,
            img_number,
            src_web,
            ins_dt,
            ins_process_id,
            upd_dt,
            upd_process_id,
            del_flag
        )
        VALUES (
            source.property_id,
            source.img_link,
            source.img_number,
            source.src_web,
            source.ins_dt,
            source.ins_process_id,
            source.upd_dt,
            source.upd_process_id,
            source.del_flag
        )
"""

result = spark.sql(query)
display(result)