# Databricks notebook source
from pyspark.sql.functions import current_date, current_timestamp

def update_stats(scraper_name, operation, row_count, process_id):
    # Update the listings table with parsed parameter
    operation_type = f"{operation}_listings"

    print("Update statistics of th scraper")
    print(f"Updating 'realitky.stats.scrapers' table")
    print(f"Operation: {operation}")
    print(f"Scraper: {scraper_name}")
    print(f"Row count: {row_count}")

    # Merge IDs
    spark.sql(f"""
    MERGE INTO realitky.stats.scrapers AS target
    USING (
        SELECT 
            current_date() AS date, 
            '{scraper_name}' AS scraper_name, 
            {row_count} AS {operation_type}
        ) AS source
    ON 
        target.date = source.date 
        AND target.scraper_name = source.scraper_name
    WHEN MATCHED 
        AND target.{operation_type} <> source.{operation_type}
    THEN
        UPDATE 
            SET target.{operation_type} = source.{operation_type},
            target.upd_dt = current_timestamp(),
            target.upd_process_id = '{process_id}'
    """)