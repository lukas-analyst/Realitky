# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "bidli")
dbutils.widgets.text("process_id", "0Z")

scraper_name = dbutils.widgets.get("scraper_name")
input_table_name = f"realitky.raw.listings_{scraper_name}"
output_table_name = f"realitky.raw.listing_details_{scraper_name}"
output_images_table_name = f"realitky.raw.listing_images_{scraper_name}"

process_id = dbutils.widgets.get("process_id")
insert_mode = "append"

# COMMAND ----------

# MAGIC %md
# MAGIC ###Load data from table

# COMMAND ----------

df = spark.sql(f"SELECT DISTINCT listing_id, listing_url FROM {input_table_name} WHERE parsed = false AND del_flag = false LIMIT 1000")
display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC ###Prepare parsing script
# MAGIC Contains:
# MAGIC - details (dictionary) + listing_hash
# MAGIC - images (list) + images_hash

# COMMAND ----------

# Define async function to fetch property details
import asyncio
import httpx
import hashlib
import re
from selectolax.parser import HTMLParser
from typing import Optional, Dict
from pyspark.sql.types import StructType, StructField, StringType


class Scraper_details:
    def extract_details_from_table(self, container, row_sel: str, label_sel: str, value_sel: str) -> Dict[str, str]:
        """Extract details from table-like HTML structure"""
        details = {}
        for row in container.css(row_sel):
            label = row.css_first(label_sel)
            value = row.css_first(value_sel)
            if label and value:
                details[label.text(strip=True)] = str(value.text(strip=True))
        return details

    def extract_direct_image_url(self, next_image_url: str) -> str:
        """Extract direct image URL from Next.js image wrapper"""
        try:
            parsed_url = urlparse(next_image_url)
            if parsed_url.path == '/_next/image' and 'url' in parse_qs(parsed_url.query):
                # Extract the actual image URL from the 'url' parameter
                direct_url = parse_qs(parsed_url.query)['url'][0]
                return unquote(direct_url)
            else:
                # If it's not a Next.js wrapper, return as is
                return next_image_url
        except:
            return next_image_url
        
    async def fetch_property_details(self, listing_id: str, listing_url: str) -> Optional[Dict]:
        try:
            # Download HTML content and parse it
            url = listing_url
            print(url)
            async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                response = await client.get(url)
                response.raise_for_status()
                parser = HTMLParser(response.text)

            # Define details as dict
            details = {
                "listing_id": str(listing_id),
                "listing_url": str(listing_url)
            }

            print(f"Processing details for {listing_id}")

            # Extract property name
            title_element = parser.css_first("h2.orange.bmg-0")
            if title_element:
                details["Property Name"] = str(title_element.text(strip=True))

            # PENB
            penb_type_element = parser.css_first("span.energeticky-stitek-type")
            if penb_type_element:
                details["PENB"] = penb_type_element.text(strip=True)

            # Property description
            description_element = parser.css_first("#top > div.screen > div.screen-in > div:nth-child(1) > div > div:nth-child(7) > div.col-66 > p")
            if description_element:
                details["Property Description"] = description_element.text(strip=True)

            # Extract property price and basic details
            price_container = parser.css_first("div.h2.orange.bmg-0.t-right")
            if price_container:
                details["Price"] = str(price_container.text(strip=True))

            # Extract property price details
            price_details_container = parser.css_first("div.t-right.small-font2.black.bmg-10.tmg--5")
            if price_details_container:
                details["Price details"] = str(price_details_container.text(strip=True)) if price_details_container else None

            # Extract property additional details
            tables = parser.css("table")
            if tables:
                for table in tables:
                    details.update(
                        self.extract_details_from_table(
                            table,
                            "tr",
                            "th",
                            "td",
                        )
                    )

            # Extract property GPS coordinates
            map_element = parser.css_first("div#listingMap")
            if map_element:
                details["GPS coordinates"] = str(map_element.attributes.get("data-gps"))

            html_content = parser.html
            match = re.search(
                r"LatLng\s*=\s*new google\.maps\.LatLng\(\s*([0-9\.\-]+)\s*,\s*([0-9\.\-]+)\s*\)",
                html_content,
            )
            if match:
                lat = match.group(1)
                lng = match.group(2)
                details["GPS coordinates"] = str(f"{lat},{lng}")

            # Set status
            if title_element:
                details["Status"] = 'active'
            else:
                details["Status"] = 'inactive'

            # Generate listing_hash
            detail_hash_input = {k: v for k, v in details.items()}
            listing_hash = hashlib.sha256(str(sorted(detail_hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            
            #######################
            ##### -- IMAGES -- ####
            #######################
            
            # Extract property images from main detail slider
            images = []
            images_container = parser.css("div.nem-detail-slider div.swiper-slide:not(.swiper-slide-duplicate)")
            if images_container:
                for img_number, slide in enumerate(images_container, 1):
                    style = slide.attributes.get("style", "")
                    if "background-image:" in style:
                        # Extract URL from background-image: url("...") or url(...) without quotes
                        match = re.search(r'background-image:\s*url\(["\']?(.*?)["\']?\)', style)
                        if match:
                            src = match.group(1)

                            # Handle relative URLs - bidli.cz uses relative paths
                            if src.startswith("/"):
                                src = "https://www.bidli.cz" + src
                            elif not src.startswith("http"):
                                src = "https://www.bidli.cz/" + src

                            # Create image record
                            image_record = {
                                "listing_id": str(listing_id),
                                "img_number": img_number,
                                "img_link": str(src)
                            }
                            images.append(image_record)
                        else:
                            print(f"DEBUG {listing_id}: No URL match in style")
                    else:
                        print(f"DEBUG {listing_id}: No background-image in style")
            else:
                print(f"DEBUG {listing_id}: No detail slides found, returning empty data...")
                if not images:
                    image_record = {
                        "listing_id": str(listing_id),
                        "img_number": None,
                        "img_link": None
                    }
                    images.append(image_record)
            
            # Generate images_hash
            image_hash_input = str(sorted([sorted(img.items()) for img in images]))
            images_hash = hashlib.sha256(image_hash_input.encode()).hexdigest()
            for image_record in images:
                image_record["images_hash"] = str(images_hash)
            
            print(f"Found {len(images)} images for listing {listing_id}")
            return details, images

        except Exception as e:
            print(f"Error parsing {listing_id}: {e}")
            return None, []

# COMMAND ----------

# MAGIC %md
# MAGIC ### Execute parsing
# MAGIC - Run the parsing script to extract relevant data from the raw input.
# MAGIC - Ensure all required fields are captured and formatted correctly.
# MAGIC - Log any errors or missing data for review.

# COMMAND ----------

# Execute the async function
print(f"Found {df.count()} listings")
if df.count() > 0:
    scraper = Scraper_details()
    results = await asyncio.gather(*[scraper.fetch_property_details(row.listing_id, row.listing_url) for row in df.collect()])
    
    # Separate details and images
    parsed_details = [result[0] for result in results if result[0] is not None] # results = [0, 1]
    parsed_images = []
    for result in results:
        if result[1]:
            parsed_images.extend(result[1])
    
    print(f"Scraped {len(parsed_details)} listings with {len(parsed_images)} total images")
    
    df_parsed_details = spark.createDataFrame(parsed_details)
    df_parsed_images = spark.createDataFrame(parsed_images)

    print("--- DETAILS ---")
    display(df_parsed_details)
    print("--- IMAGES ---")
    display(df_parsed_images)

# COMMAND ----------

# MAGIC %md
# MAGIC ###Export data and update stats
# MAGIC - From 'clean_column_name.ipynb. get script for cleaning names of columns (eg. no diacritics, lowercase, replace spaces with underscore, etc.)
# MAGIC - From 'listing_details_import.ipynb' get script for importing scraped information about property
# MAGIC - From 'listing_update.ipynb' get script for updating state of listing_id to be 'parsed = True'
# MAGIC - After all get all the listing_ids and set upd_check_date to current date

# COMMAND ----------

import sys
from pyspark.sql.functions import current_date

# import functions
%run "./utils/clean_column_name.ipynb"
%run "./utils/listing_details_import.ipynb"
%run "./utils/listings_update.ipynb"

if df.count() > 0:
    # Clean column names
    df_parsed_details = clean_column_names(df_parsed_details)
    df_parsed_images = clean_column_names(df_parsed_images)

    # Export scraped data about property
    row_count = export_to_table(df_parsed_details, output_table_name, insert_mode, "listing_hash")
    images_count = export_to_table(df_parsed_images, output_images_table_name, insert_mode, "images_hash")

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