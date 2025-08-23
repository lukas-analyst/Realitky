# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "ulovdomov")
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

df = spark.sql(f"SELECT DISTINCT listing_id, listing_url, gps_coordinates_raw FROM {input_table_name} WHERE parsed = false AND del_flag = false LIMIT 1000")
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
import json
from selectolax.parser import HTMLParser
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict, Tuple, List
from urllib.parse import urlparse, parse_qs, unquote

class Scraper_details:
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
        
    async def fetch_property_details(self, listing_id: str, listing_url: str, gps_coordinates_raw: str) -> Tuple[Optional[Dict], List[Dict]]:
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
                "listing_url": str(listing_url),
                "gps_coordinates_raw": str(gps_coordinates_raw)
            }

            # Extract property name
            title_element = parser.css_first("h1.chakra-heading.css-16h1lz")
            if title_element:
                details["Property Name"] = str(title_element.text(strip=True))

            # Extract property description
            description_container = parser.css_first('p[data-test="offerDetail.description"]')
            if description_container:
                description_text = description_container.text(strip=True)
                details["Property Description"] = str(description_text)

            # Extract property price and basic details
            price = parser.css_first('h2[data-test="offerDetail.price"]')
            if price:
                price_span = price.css_first("span")
                if price_span:
                    price_text = price_span.text(strip=True)
                    details["Cena"] = str(price_text)
                
            # Extract price details
            price_details = parser.css_first('p[data-test="offerDetail.price.note"]')
            if price_details:
                price_details_text = price_details.text(strip=True)
                details["Price Details"] = str(price_details_text)
            
            # Extract property_additional_details
            parameters = None
            try:
                offer_json_script = parser.css_first('script#__NEXT_DATA__')
                if offer_json_script:
                    offer_json = json.loads(offer_json_script.text())
                    offer_data = offer_json["props"]["pageProps"]["offer"]["data"]
                    parameters = offer_data.get("parameters", {})
            except Exception as e:
                print(f"Error loading parameters from __NEXT_DATA__: {e}")
            if not isinstance(parameters, dict):
                parameters = {}
            for key, param in parameters.items():
                if param is None:
                    continue
                title = param.get("title", key)
                # Some parameters have "options", others only "value"
                if "options" in param and isinstance(param["options"], list):
                    if len(param["options"]) == 1:
                        details[title] = param["options"][0].get("title")
                    else:
                        details[title] = ", ".join([opt.get("title", "") for opt in param["options"]])
                elif "value" in param:
                    details[title] = param["value"]
                else:
                    details[title] = str(param)
                
            # GPS
            try:
                gps_dict = json.loads(gps_coordinates_raw.replace("'", '"'))
                if gps_dict:
                    lat = gps_dict.get("lat")
                    lng = gps_dict.get("lng")
                    if lat is not None and lng is not None:
                        details["GPS Coordinates"] = f"{lat},{lng}"
            except Exception as e:
                print(f"Error parsing GPS coordinates: {e}")

            # Get status of the property:
            status_element = parser.css_first('h2.chakra-heading.css-joick')
            if status_element:
                status_text = status_element.text(strip=True)
                if status_text and "Inzerát už má zájemce" in status_text:
                    details["status"] = "inactive"
                else:
                    details["status"] = "active"
            else:
                details["status"] = "active"

            # Generate hash
            hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            #######################
            ##### -- IMAGES -- ####
            #######################
            
            images = []
            image_selectors = [
                "img[src*='photo.ulovdomov.cz']",  # Direct images from ulovdomov CDN
            ]
            seen_urls = set()
            
            for selector in image_selectors:
                found_images = parser.css(selector)
                if found_images:
                    for img_element in found_images:
                        src = img_element.attributes.get("src")
                        if src and "photo.ulovdomov.cz" in src:
                            # Only add unique URLs
                            if src not in seen_urls:
                                seen_urls.add(src)
                                image_record = {
                                    "listing_id": str(listing_id),
                                    "img_number": str(len(images) + 1),
                                    "img_link": str(src)
                                }
                                images.append(image_record)
                    break
            
            # If still no images found, create empty record
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
    results = await asyncio.gather(*[scraper.fetch_property_details(row.listing_id, row.listing_url, row.gps_coordinates_raw) for row in df.collect()])

    
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