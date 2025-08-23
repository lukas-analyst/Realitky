# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "idnes")
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
import json
from selectolax.parser import HTMLParser
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict

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
        
    async def fetch_property_details(self, listing_id: str, listing_url: str) -> Optional[Dict]:
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
            title_element = parser.css_first("h1.b-detail__title")
            if title_element:
                details["Property Name"] = str(title_element.text(strip=True))

            # Extract property description
            description_container = parser.css_first("div.b-desc.pt-10.mt-10")
            if description_container:
                details["Property Description"] = str(description_container.text(strip=True))

            # Extract property price and basic details
            price_container = parser.css_first("header.b-detail")
            if price_container:
                strong = price_container.css_first("strong")
                details["Cena"] = str(strong.text(strip=True)) if strong else "XNA"

            # Extract price details
            price_details = parser.css_first('div.wrapper-price-notes.color-grey.mb-5')
            if price_details:
                full_text = price_details.text(strip=True)
                clean_text = full_text.replace("Poznámka k ceně:", "").strip()
                details["Price Details"] = clean_text if clean_text else "XNA"
            
            # Extract property additional details
            for definition in parser.css('div.b-definition.mb-0, div.b-definition-columns.mb-0'):
                dts = definition.css('dt')
                dds = definition.css('dd')
                for dt, dd in zip(dts, dds):
                    if 'advertisement' in dd.attributes.get('class', ''):
                        continue
                    label = str(dt.text(strip=True))
                    value = ''.join([str(node.text(strip=True)) for node in dd.iter() if node.tag in ('#text')])
                    if not value:
                        value = str(dd.text(strip=True))
                    details[label] = str(value)

            # Extract property GPS coordinates
            app_maps_div = parser.css_first('div#app-maps')
            gps_found = False
            if app_maps_div and "data-last-center" in app_maps_div.attributes:
                try:
                    last_center_json = app_maps_div.attributes["data-last-center"]
                    last_center = json.loads(last_center_json)
                    lat = last_center.get("lat")
                    lng = last_center.get("lng")
                    if lat is not None and lng is not None:
                        details["GPS coordinates"] = str(f"{lat},{lng}")
                        gps_found = True
                    else:
                        details["GPS coordinates"] = "XNA"
                except Exception as e:
                    print(f"Error parsing GPS from data-last-center: {e}")

            if not gps_found:
                script = parser.css_first('script[type="application/json"][data-maptiler-json]')
                if script and script.text():
                    try:
                        data = json.loads(script.text())
                        features = data.get("geojson", {}).get("features", [])
                        for feature in features:
                            props = feature.get("properties", {})
                            if not props.get("isSimilar", False):
                                coords = feature.get("geometry", {}).get("coordinates", [])
                                if isinstance(coords, list) and len(coords) == 2:
                                    details["GPS coordinates"] = str(f"{coords[1]},{coords[0]}")
                                    gps_found = True
                                    break
                    except Exception as e:
                        print(f"Error parsing GPS from script: {e}")
            
            # Set status
            if title_element:
                details["Status"] = 'active'
            else:
                details["Status"] = 'inactive'

            # Generate hash
            hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            #######################
            ##### -- IMAGES -- ####
            #######################
            
            # Extract property images from carousel
            images = []
            
            # Look for carousel slides (slick-slide elements)
            images_container = parser.css("div.carousel__list a.carousel__item")
            
            if images_container:
                for img_number, slide in enumerate(images_container, 1):
                    img_element = slide.css_first("img")
                    if img_element:
                        # Try data-lazy first (for lazy-loaded images), then src
                        src = img_element.attributes.get("data-lazy") or img_element.attributes.get("src")
                        
                        if src and not src.endswith("no-image-gallery.png"):
                            # Handle relative URLs
                            if src.startswith("//"):
                                src = "https:" + src
                            elif src.startswith("/"):
                                src = "https://www.reality.idnes.cz" + src
                            
                            # Create image record
                            image_record = {
                                "listing_id": str(listing_id),
                                "img_number": img_number,
                                "img_link": str(src)
                            }
                            images.append(image_record)
            
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