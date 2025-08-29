# Databricks notebook source
# MAGIC %md
# MAGIC ### Scrapper for www.bidli.cz
# MAGIC
# MAGIC This file scrapes bidli page for real estate URLs
# MAGIC
# MAGIC On the output it gives a list of ID and URL in the parameter 'listing_url'
# MAGIC
# MAGIC Everything gets exported into a table 'listings_url_bidli'
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

# Create widgets
dbutils.widgets.text("max_pages", "2", "Max Pages")
dbutils.widgets.text("per_page", "20", "Per Page")
dbutils.widgets.text("scraper_name", "bidli", "Scraper Name")
dbutils.widgets.text("process_id", "0A", "Process ID")

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

BASE_URL = "https://www.bidli.cz/chci-koupit/list/"

mode_sale = "akce=1" 
mode_rent = "akce=2"
modes = [mode_sale, mode_rent]

# COMMAND ----------

# MAGIC %md
# MAGIC ### Scrap all pages and get 'listings'

# COMMAND ----------

import httpx
import json
import asyncio
from selectolax.parser import HTMLParser

class Scraper_listings:
    async def scrap_listings(self, max_pages):
        all_listings = []

        for mode in modes:
            PREP_URL = f"{BASE_URL}?{mode}"
            print(f"Fetching listings for url: {PREP_URL}")
            listings = []
            page = 0 # Bidli starts at page = 0

            while max_pages is None or page <= max_pages:
                url = f"{PREP_URL}&page={page}"
                print(f"Fetching page {page}")

                # Download HTML content and parse it
                async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                    response = await client.get(url)
                    response.raise_for_status()
                    parser = HTMLParser(response.text)

                # Scope to the listings container(s) first
                containers = parser.css("div.nemlist")
                anchors = []

                if containers:
                    for c in containers:
                        # Primary: specific anchors within the container
                        local_anchors = c.css("a.nemlist-item")
                        # Fallback: any detail links within the container if class changes
                        if not local_anchors:
                            local_anchors = [
                                a for a in c.css("a")
                                if a.attributes.get("href", "").startswith("/chci-koupit/detail/")
                            ]
                        anchors.extend(local_anchors)
                else:
                    # Global fallback if the container is not found (structure change)
                    anchors = parser.css("a.nemlist-item")
                    if not anchors:
                        anchors = parser.css('a[href^="/chci-koupit/detail/"]')

                print(f"Found {len(anchors)} listings on page {page}")

                # Save list of URLs and IDs
                for a in anchors:
                    href = a.attributes.get("href", "")
                    if not href:
                        continue
                    # Keep only detail links
                    if not href.startswith("/chci-koupit/detail/"):
                        continue
                    listing_id = href.rstrip("/").split("/")[-1]
                    listings.append({
                        "listing_id": listing_id,
                        "listing_url": f"https://www.bidli.cz{href}",
                    })

                # Go to next page
                next_page_btn = parser.css_first("a.next")
                if not next_page_btn or next_page_btn.attributes.get("href") == "#" or page == max_pages:
                    print(f"Reached the last page: {page}")
                    break

                await asyncio.sleep(3)

                page += 1

            unique_listings = {item["listing_id"]: item for item in listings}
            all_listings.extend(unique_listings.values())

        # Deduplicate across all modes
        final_unique_listings = {item["listing_id"]: item for item in all_listings}
        return list(final_unique_listings.values())
    
# Run the Scraper_listings and get 'listings'
scraper = Scraper_listings()
listings = await scraper.scrap_listings(max_pages=max_pages)
df_listings = spark.createDataFrame(listings)

display(df_listings)

# COMMAND ----------

# MAGIC %md
# MAGIC ####Export into the output table

# COMMAND ----------

import sys
%run "./utils/listings_import.ipynb"
%run "./utils/scraper_statistics_update.ipynb"


row_count = export_to_table(df_listings, output_table_name, insert_mode)
update_stats(scraper_name, 'scraped', row_count, process_id)

dbutils.jobs.taskValues.set("row_count", row_count)