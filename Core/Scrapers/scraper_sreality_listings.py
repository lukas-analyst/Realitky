# Databricks notebook source
# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0


# COMMAND ----------

# Get parameter values
max_pages = int(dbutils.widgets.get("max_pages"))
per_page = int(dbutils.widgets.get("per_page"))
scraper_name = dbutils.widgets.get("scraper_name")
dbutils.jobs.taskValues.set("scraper_name", scraper_name)
process_id = dbutils.widgets.get("process_id")

# Name of the output table
output_table_name = (f"realitky.raw.listings_{scraper_name}")
# Mode in which the data are going to be inserted into the output table
insert_mode = "append"

# COMMAND ----------

# MAGIC %md
# MAGIC ###Prepare fetching from API

# COMMAND ----------

# API endpoint
BASE_URL = "https://www.sreality.cz/api/cs/v2/estates"

PREP_URL = f"{BASE_URL}?per_page={per_page}"

# COMMAND ----------

from pyspark.sql.types import StructType, StructField, StringType
import time
import requests

# Fetch Property Listings
listings = []
page = 1

PREP_URL = f"{BASE_URL}?per_page={per_page}"

while max_pages is None or page <= max_pages:
    url = f"{PREP_URL}&page={page}"
    print(f"Fetching page {page}")
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        listing = response.json()['_embedded']['estates']

        # Add page info and ensure ID is available
        for attributes in listing:
            attributes['listing_id'] = attributes.get('hash_id', attributes.get('id'))
            attributes['listing_url'] = attributes.get('seo', {}).get('locality', '')

        print(f"Found {len(listing)} listings on page {page}")
        listings.extend(listing)

    except requests.exceptions.RequestException as e:
        print(f"Error fetching page {page}: {e}")
        break

    # Small delay to be respectful to the API
    time.sleep(0.5)

    page += 1

print(f"Reached the last page: {page}")
print(f"Total listings fetched: {len(listings)}")

# Schema needs to be explicitly defined
schema = StructType([
    StructField("listing_id", StringType(), True),
    StructField("listing_url", StringType(), True)
])

df_listings = spark.createDataFrame(listings, schema=schema)

# COMMAND ----------

import sys
%run "./utils/listings_import.ipynb"
%run "./utils/scraper_statistics_update.ipynb"


row_count = export_to_table(df_listings, output_table_name, insert_mode)
update_stats(scraper_name, 'scraped', row_count, process_id)

dbutils.jobs.taskValues.set("row_count", row_count)