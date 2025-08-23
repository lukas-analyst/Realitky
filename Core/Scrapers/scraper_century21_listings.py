# Databricks notebook source
# MAGIC %md
# MAGIC ### Scrapper for www.century21.cz
# MAGIC
# MAGIC This file scrapes century21 page for real estate URLs
# MAGIC
# MAGIC On the output it gives a list of ID and URL in the parameter 'listing_url'
# MAGIC
# MAGIC Everything gets exported into a table 'listings_url_century21'
# MAGIC
# MAGIC
# MAGIC **Note**: none yet

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0


# COMMAND ----------

# MAGIC %md
# MAGIC ###Main config

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
# MAGIC ###Prepare scraping URL

# COMMAND ----------

BASE_URL = "https://www.century21.cz/nemovitosti"
LIST_URL = "https://www.century21.cz"

PREP_URL = BASE_URL

# COMMAND ----------

# MAGIC %md
# MAGIC ### Scrap all pages and get 'listings'

# COMMAND ----------

import httpx
import json
import asyncio
from selectolax.parser import HTMLParser
from urllib.parse import urlparse, parse_qs

class Scraper_listings:
    async def scrap_listings(self, max_pages):
        print(f"Fetching listings for url: {PREP_URL}")
        listings = []
        page = 1

        while max_pages is None or page <= max_pages:
            url = f"{PREP_URL}?page={page}"
            print(f"Fetching page {page}")

            # Download HTML content and parse it
            async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                response = await client.get(url)
                response.raise_for_status()
                parser = HTMLParser(response.text)
            
            listing_container = parser.css("article.bg-shade-300")
            print(f"Found {len(listing_container)} listings on page {page}")

            # Save list of URLs and IDs
            listing = [
                {
                    "listing_id": a.attributes["href"].split("=")[-1],
                    "listing_url": f"{LIST_URL}{a.attributes['href']}"
                }
                for listing in listing_container
                if (a := listing.css_first("a"))
            ]
            listings.extend(listing)

            # Go to next page
            next_page_btn = parser.css_first('a[aria-label="Next page"]')
            if not next_page_btn or next_page_btn.attributes.get("aria-disabled") == "true":
                print(f"Reached the last page: {page}")
                break

            await asyncio.sleep(3)

            page += 1

        return listings

# Run the Scraper_listings and get 'listings'
scraper = Scraper_listings()
listings = await scraper.scrap_listings(max_pages=max_pages)
df_listings = spark.createDataFrame(listings)

display(df_listings)

# COMMAND ----------

# MAGIC %md
# MAGIC ###Expport into the output table

# COMMAND ----------

import sys
%run "./utils/listings_import.ipynb"
%run "./utils/scraper_statistics_update.ipynb"


row_count = export_to_table(df_listings, output_table_name, insert_mode)
update_stats(scraper_name, 'scraped', row_count, process_id)

dbutils.jobs.taskValues.set("row_count", row_count)