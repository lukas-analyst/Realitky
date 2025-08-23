# Databricks notebook source
# MAGIC %md
# MAGIC ###Load data from table

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

scraper_name = dbutils.widgets.get("scraper_name")

input_table_name = f"realitky.raw.listings_{scraper_name}"
output_table_name = f"realitky.raw.listing_details_{scraper_name}"

process_id = dbutils.widgets.get("process_id")
weekly = dbutils.widgets.get("weekly")
insert_mode = "append"

# COMMAND ----------

df = spark.sql(f"SELECT DISTINCT listing_id, listing_url FROM {input_table_name} WHERE parsed = false AND del_flag = false LIMIT 1000")
display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC ###Parse listing details from each URL

# COMMAND ----------

from pyspark.sql.types import StructType, StructField, StringType
import requests
import time
import hashlib

if df.count() > 0:
    listings_id = [row['listing_id'] for row in df.collect()]
    print(f"Found {df.count()} listings")
    details = []

    for listing in listings_id:
        try:
            BASE_URL = "https://www.sreality.cz/api/cs/v2/estates/"
            url = BASE_URL + listing
            response = requests.get(url, timeout=30.0)
            response.raise_for_status()
            listing_detail = response.text
            
            # Generate hash
            hash_input = listing_detail
            listing_hash = hashlib.sha256(hash_input.encode()).hexdigest()
            
            details.append((listing, url, listing_detail, listing_hash))
            
        except Exception as e:
            print(f"Error fetching details for property ID {listing}: {e}")

        # Small delay to be respectful to the API
        time.sleep(0.3)
else:
    details = []


# Define Schema
schema = StructType([
    StructField("listing_id", StringType(), True),
    StructField("listing_url", StringType(), True),
    StructField("listing_detail", StringType(), True),
    StructField("listing_hash", StringType(), True)
])

# Save into Spark DataFrame
df_parsed_details = spark.createDataFrame(details, schema=schema)
print(f"Scraped {df_parsed_details.count()} listings")

# COMMAND ----------

import sys
from pyspark.sql.functions import current_date

# import functions
%run "./utils/clean_column_name.ipynb"
%run "./utils/listing_details_import.ipynb"
%run "./utils/listings_update.ipynb"

if df_parsed_details.count() > 0:
    # Remove duplicates on listing_id
    df_parsed_details = df_parsed_details.dropDuplicates(["listing_id"])
    
    # Clean column names
    df_parsed_details = clean_column_names(df_parsed_details)

    # Export scraped data about property
    row_count = export_to_table(df_parsed_details, output_table_name, insert_mode)

    # Update all listing_ids with 'parsed = True'
    df_parsed_details.createOrReplaceTempView("listing_ids_view")
    update_listings(input_table_name, 'parsed', process_id)
    # Update input table with 'upd_check_date = current_date'
    spark.sql(f"""    
        UPDATE {input_table_name}
            SET upd_check_date = current_date()
            WHERE listing_id IN (SELECT listing_id FROM listing_ids_view) AND del_flag = false
        """)
else:
    row_count = 0

# Save row count
dbutils.jobs.taskValues.set("row_count", row_count)