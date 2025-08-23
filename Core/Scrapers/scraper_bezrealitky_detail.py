# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "bezrealitky")
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

    async def fetch_property_details(self, listing_id: str, listing_url: str) -> Tuple[Optional[Dict], List[Dict]]:
        try:
            url = listing_url
            async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                try:
                    response = await client.get(url)
                    response.raise_for_status()
                except httpx.HTTPStatusError as e:
                    print(f"Error fetching {listing_id}: {e} (HTTP error)")
                    return None, []
                except Exception as e:
                    print(f"Error fetching {listing_id}: {e}")
                    return None, []

                parser = HTMLParser(response.text)

            details = {
                "listing_id": str(listing_id),
                "listing_url": str(listing_url)
            }

            title_element = parser.css_first("h1.h2.pd-header__title, h1.h2, h1.mb-3.mb-lg-10.h2")
            if title_element:
                span_element = title_element.css_first("span")
                details["Property Name"] = str(span_element.text(strip=True))

            description_container = parser.css_first('div[id^="react-aria-"][id$="-tabpane-native"]')
            if description_container:
                details["Property Description"] = str(description_container.text(strip=True))

            # Price (Sale)
            price_container = parser.css_first("div.justify-content-between.align-items-baseline.mb-lg-9.mb-6.row")
            if price_container:
                price_span = price_container.css_first("strong.h4.fw-bold span")
                if price_span:
                    details["Cena"] = price_span.text(strip=True)
            
            # Price (Rent)
            price_container_alt = parser.css_first("div.justify-content-between.align-items-baseline.row")
            if price_container_alt:
                price_span_alt = price_container_alt.css_first("strong.h4.fw-bold span")
                if price_span_alt:
                    details["Cena"] = price_span_alt.text(strip=True)

            # Price details
            price_details_caontainer = parser.css_first("div.justify-content-between.mb-2.mb-last-0.row")
            if price_details_caontainer:
                details["Price details"] = str(price_details_caontainer.text(strip=True))
                
            # Category
            category_element = parser.css_first("nav[aria-label='breadcrumb'] ol.breadcrumb")
            if category_element:
                category_texts = [
                    li.text(strip=True)
                    for li in category_element.css("li.breadcrumb-item")
                    if li.text(strip=True) and "Domů" not in li.text(strip=True)
                ]
                # Remove the first element ("Výpis nemovitostí") if present
                if category_texts and category_texts[0] == "Výpis nemovitostí":
                    category_texts = category_texts[1:]
                
                # Get Category
                details["Category"] = ",".join(category_texts) if category_texts else "XNA"
                
                # Dynamically assign category fields
                if category_texts:
                    for idx, val in enumerate(category_texts, 1):
                        details[f"category_{idx}"] = val

            # Additional property details
            details_container = parser.css("div.ParamsTable_paramsTable__tX8zj.paramsTable")
            if details_container:
                for detail_container in details_container:
                    for tr in detail_container.css("tr"):
                        th = tr.css_first("th span")
                        td = tr.css_first("td")
                        if th and td:
                            label = th.text(strip=True)
                            value_span = td.css_first("span")
                            value = value_span.text(strip=True) if value_span else td.text(strip=True)
                            details[label] = str(value)

            # GPS coordinates
            next_data_script = parser.css_first('script#__NEXT_DATA__')
            if next_data_script:
                try:
                    data = json.loads(next_data_script.text())
                    gps = data.get("props", {}) \
                            .get("pageProps", {}) \
                            .get("origAdvert", {}) \
                            .get("gps", {})
                    lat = gps.get("lat")
                    lng = gps.get("lng")
                    details["GPS coordinates"] = str(f"{lat},{lng}")
                except Exception:
                    pass

            # Set status
            inactive_element = parser.css_first('section.box.Section_section__gjwvr.section.mb-0.py-10.py-xl-25 h1.mb-5.mb-lg-10.h1.text-center span')
            if inactive_element and inactive_element.text(strip=True) == "Inzerát již není v nabídce":
                details["Status"] = "inactive"
            else:
                details["Status"] = "active"
            
            # Generate listing_hash
            detail_hash_input = {k: v for k, v in details.items()}
            listing_hash = hashlib.sha256(str(sorted(detail_hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            
            #######################
            ##### -- IMAGES -- ####
            #######################
            
            # Extract property images - separate structure
            images = []
            images_container = parser.css("div.PropertyCarousel_propertyCarouselSlide__BPboJ")
            if images_container:
                for img_number, slide in enumerate(images_container, 1):
                    img_element = slide.css_first("img")
                    if img_element:
                        src = img_element.attributes.get("src")

                        if src:
                            # Handle relative URLs
                            if src.startswith("//"):
                                src = "https:" + src
                            elif src.startswith("/"):
                                src = "https://www.bezrealitky.cz" + src
                            
                            # Extract direct image URL
                            direct_url = self.extract_direct_image_url(src)
                            
                            # Create image record
                            image_record = {
                                "listing_id": str(listing_id),
                                "img_number": img_number,
                                "img_link": str(direct_url)
                            }
                            images.append(image_record)
            else:
                # No images found, push listing_id and leave other columns as None
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