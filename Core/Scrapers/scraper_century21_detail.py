# Databricks notebook source
# MAGIC %md
# MAGIC ### Prepare environment

# COMMAND ----------

# Install required packages
%pip install aiohttp>=3.8.0 aiofiles>=22.1.0 httpx>=0.24.0 selectolax>=0.3.0 nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("scraper_name", "century21")
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
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict

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
        
    # Async function
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
                "listing_url": str(listing_url),
            }
            
            # Extract category1, category2, category3 from URL
            try:
                url_path = re.sub(r"^https?://[^/]+/", "", listing_url)
                path_parts = url_path.split("/")
                if len(path_parts) > 1:
                    segments = path_parts[1].split("-")
                    for i in range(min(4, len(segments))):
                        details[f"category{i+1}"] = segments[i]
            except Exception as e:
                print(f"Error extracting categories from URL for {listing_id}: {e}")

            # Extract property name
            title_element = parser.css_first("h3.font-barlow.font-bold")
            if title_element:
                details["Property Name"] = str(title_element.text(strip=True))

            # Extract address point with translate="no" attribute
            address_point = parser.css_first('p.uppercase.font-barlow.font-medium')
            if address_point:
                details["Address Point"] = str(address_point.text(strip=True))

            # Extract property description
            description_container = parser.css_first("div.text-white.font-light.whitespace-break-spaces")
            if description_container:
                details["Property Description"] = str(description_container.text(strip=True))

            # Extract property price and basic details
            price_container = parser.css("div.bg-primary-300.rounded-b-2xl")
            for price_div in price_container:
                p_elements = price_div.css("p")
                if len(p_elements) > 0:
                    details["Price Detail"] = str(p_elements[0].text(strip=True))
                if len(p_elements) > 1:
                    details["Price"] = str(p_elements[1].text(strip=True))

            # Extract property additional details
            tables_container = parser.css("table.w-full.text-white.border-t-2.border-b-2.border-black")
            for table in tables_container:
                details.update(
                    self.extract_details_from_table(
                        table,
                        "tr",
                        "th",
                        "td",
                    )
                )

           # GPS from <script>self.__next_f.push...
            gps_found = False
            try:
                # Get all script tags
                script_tags = parser.css("script")
                
                # First try: look in scripts with both next_f and coordinates
                for script in script_tags:
                    script_text = script.text()
                    if script_text and "self.__next_f.push" in script_text and "coordinates" in script_text:
                        
                        # Try specific coordinate patterns
                        patterns = [
                            r'"coordinates":\{"latitude":([\d.-]+),"longitude":([\d.-]+)\}',
                            r'"coordinates":\s*\{\s*"latitude":([\d.-]+),\s*"longitude":([\d.-]+)\s*\}',
                            r'"latitude":([\d.-]+),"longitude":([\d.-]+)',
                        ]
                        
                        for pattern in patterns:
                            coord_match = re.search(pattern, script_text, re.IGNORECASE)
                            if coord_match:
                                latitude = coord_match.group(1)
                                longitude = coord_match.group(2)
                                details["GPS coordinates"] = f"{latitude},{longitude}"
                                gps_found = True
                                break
                        
                        if gps_found:
                            break
                
                # Second try: look in any script with coordinates (broader search)
                if not gps_found:
                    for script in script_tags:
                        script_text = script.text()
                        if script_text and "coordinates" in script_text:
                            
                            # Try all coordinate patterns
                            patterns = [
                                r'"coordinates":\{"latitude":([\d.-]+),"longitude":([\d.-]+)\}',
                                r'"coordinates":\s*\{\s*"latitude":([\d.-]+),\s*"longitude":([\d.-]+)\s*\}',
                                r'"latitude":([\d.-]+),"longitude":([\d.-]+)',
                                r'"lat":([\d.-]+),"lng":([\d.-]+)',
                                r'"lat":([\d.-]+),"lon":([\d.-]+)',
                            ]
                            
                            for pattern in patterns:
                                coord_match = re.search(pattern, script_text, re.IGNORECASE)
                                if coord_match:
                                    latitude = coord_match.group(1)
                                    longitude = coord_match.group(2)
                                    details["GPS coordinates"] = f"{latitude},{longitude}"
                                    gps_found = True
                                    break
                            
                            if gps_found:
                                break
                
                # Third try: fallback to numerical pattern in any next_f script
                if not gps_found:
                    for script in script_tags:
                        script_text = script.text()
                        if script_text and "self.__next_f.push" in script_text:
                            
                            coord_numbers = re.findall(r'\b(-?[0-9]{1,2}\.\d{4,})\b.*?\b(-?1?[0-9]{1,2}\.\d{4,})\b', script_text)
                            if coord_numbers:
                                for lat_str, lon_str in coord_numbers:
                                    lat = float(lat_str)
                                    lon = float(lon_str)
                                    if -90 <= lat <= 90 and -180 <= lon <= 180 and not (abs(lat) < 0.01 and abs(lon) < 0.01):
                                        details["GPS coordinates"] = f"{lat},{lon}"
                                        gps_found = True
                                        break
                            
                            if gps_found:
                                break
                    
            except Exception as e:
                print(f"Error extracting GPS: {e}")

            # Set status
            if title_element:
                details["Status"] = 'active'
            else:
                details["Status"] = 'inactive'

            # Generate hash
            hash_input = {k: v for k, v in details.items()}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            #######################
            ##### -- IMAGES -- ####
            #######################
            
            # Extract property images from Slick carousel
            images = []
            images_container = parser.css("div.slick-slide:not(.slick-cloned)")
            if images_container:
                for img_number, slide in enumerate(images_container, 1):
                    # Look for div with background-image style
                    img_element = slide.css_first("div[style*='background-image']")
                    if img_element:
                        style = img_element.attributes.get("style", "")

                        if "background-image:" in style:
                            # Extract URL from background-image: url("...") or url(...)
                            match = re.search(r'background-image:\s*url\(["\']?(.*?)["\']?\)', style)
                            if match:
                                src = match.group(1)                               
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