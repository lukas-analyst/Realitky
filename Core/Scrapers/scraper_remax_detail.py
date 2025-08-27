# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "remax")
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
from selectolax.parser import HTMLParser
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict, Tuple, List

class Scraper_details:
    def _extract_details_from_table(self, container, row_sel: str, label_sel: str, value_sel: str) -> Dict[str, str]:
        """Extract details from table-like HTML structure"""
        details = {}
        for row in container.css(row_sel):
            label = row.css_first(label_sel)
            value = row.css_first(value_sel)
            if label and value:
                details[label.text(strip=True)] = str(value.text(strip=True))
        return details

    async def fetch_property_details(self, listing_id: str, listing_url: str) -> Tuple[Optional[Dict], List[Dict]]:
        try:
            # Download HTML content and parse it
            url = listing_url
            async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                response = await client.get(url)
                response.raise_for_status()
                parser = HTMLParser(response.text)

            # Define details as dict
            details = {
                "listing_id": str(listing_id),
                "listing_url": str(listing_url)
            }

            # Extract property name
            title_element = parser.css_first("h1.h2.pd-header__title")
            if title_element:
                details["Property Name"] = str(title_element.text(strip=True))

            # Extract property description
            description_container = parser.css_first("div.pd-base-info__content-collapse-inner")
            if description_container:
                details["Property Description"] = str(description_container.text(strip=True))

            # Extract property price and basic details
            price_container = parser.css_first("div.pd-table__inner")
            if price_container:
                details.update(
                    self._extract_details_from_table(
                        price_container,
                        "div.pd-table__row",
                        "div.pd-table__label",
                        "div.pd-table__value",
                    )
                )
                 # Set status / inactivity is when we get an error 410 or the price contains 'pronajato'
                price_value = details.get('Cena:')
                if price_value and 'pronajato' in price_value.lower():
                    details["status"] = "inactive"
                else:
                    details["status"] = "active"

            # Extract property additional details
            detail_container = parser.css_first("div.pd-detail-info")
            if detail_container:
                details.update(
                    self._extract_details_from_table(
                        detail_container,
                        "div.pd-detail-info__row",
                        "div.pd-detail-info__label",
                        "div.pd-detail-info__value",
                    )
                )

            # Extract property GPS coordinates
            map_element = parser.css_first("div#listingMap")
            if map_element:
                details["GPS coordinates"] = str(map_element.attributes.get("data-gps"))
            
            # Generate hash
            hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            #######################
            ##### -- IMAGES -- ####
            #######################
            
            # Extract property images from RE/MAX gallery structure
            images = []
            
            # 1. Get main image from gallery__main-img
            main_img = parser.css_first("div.gallery__main-img a.gallery__main-img-inner")
            if main_img:
                href = main_img.attributes.get("href")
                if href:
                    image_record = {
                        "listing_id": str(listing_id),
                        "img_number": 1,
                        "img_link": str(href)
                    }
                    images.append(image_record)
            
            # 2. Get visible small images from gallery__small-img
            small_images = parser.css("div.gallery__small-img div.gallery__item a")
            for i, img_link in enumerate(small_images, start=len(images) + 1):
                href = img_link.attributes.get("href")
                if href:
                    image_record = {
                        "listing_id": str(listing_id),
                        "img_number": i,
                        "img_link": str(href)
                    }
                    images.append(image_record)
            
            # 3. Get hidden images from gallery__hidden-items
            hidden_images = parser.css("div.gallery__hidden-items a.gallery__item")
            for i, img_link in enumerate(hidden_images, start=len(images) + 1):
                href = img_link.attributes.get("href")
                if href:
                    image_record = {
                        "listing_id": str(listing_id),
                        "img_number": i,
                        "img_link": str(href)
                    }
                    images.append(image_record)
            
            # If no images found, create empty record
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

        # If we get 410 (inactive property):
        except Exception as e:
            if hasattr(e, "response") and getattr(e.response, "status_code", None) == 410:
                
                # Set details
                details = {
                    "listing_id": str(listing_id),
                    "listing_url": str(listing_url),
                    "status": "inactive"
                }

                # Generate hash
                hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
                listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
                details["listing_hash"] = str(listing_hash)
                
                return details, []
            print(f"Error processing details for {listing_id}: {e}")
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
    
    # Create DataFrames
    if parsed_details:
        df_parsed_details = spark.createDataFrame(parsed_details)
    else:
        schema = StructType([
            StructField("listing_id", StringType(), True),
            StructField("listing_url", StringType(), True)
        ])
        df_parsed_details = spark.createDataFrame([], schema)
    
    if parsed_images:
        df_parsed_images = spark.createDataFrame(parsed_images)
    else:
        images_schema = StructType([
            StructField("listing_id", StringType(), True),
            StructField("img_number", StringType(), True),
            StructField("img_link", StringType(), True)
        ])
        df_parsed_images = spark.createDataFrame([], images_schema)

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