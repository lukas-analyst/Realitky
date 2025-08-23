# Databricks notebook source
from pyspark.sql.functions import current_date, current_timestamp

def update_listings(table_name, operation, process_id):
    # Update the listings table with parsed parameter
    operation_date = f"{operation}_date"

    print("Update listing_ids in listings_{scraper} based on the listing_ids_view")
    print(f"Updating {table_name} table")
    print(f"Operation: {operation}")

    spark.sql(f"""
    MERGE INTO {table_name} AS target
    USING (
        SELECT 
            listing_id,
            true AS {operation},
            current_date() AS {operation_date},
            current_timestamp() AS upd_dt,
            '{process_id}' AS upd_process_id
        FROM listing_ids_view
    ) AS source
    ON target.listing_id = source.listing_id
    WHEN MATCHED 
        AND target.{operation} <> source.{operation}
        AND target.{operation_date} <> source.{operation_date}
    THEN
        UPDATE SET
            target.{operation} = source.{operation},
            target.{operation_date} = source.{operation_date},
            target.upd_dt = source.upd_dt,
            target.upd_process_id = source.upd_process_id
    WHEN NOT MATCHED THEN
        INSERT (listing_id, {operation}, {operation_date}, upd_dt, upd_process_id)
        VALUES (source.listing_id, source.{operation}, source.{operation_date}, source.upd_dt, source.upd_process_id)
    """)