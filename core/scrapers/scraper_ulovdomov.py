# Define async function to fetch property details
import asyncio
import httpx
import hashlib
import json
from selectolax.parser import HTMLParser
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict

class Scraper_details:
    async def fetch_property_details(self, listing_id: str, listing_url: str, gps_coordinates: str) -> Optional[Dict]:
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
                "gps_coordinates": str(gps_coordinates)
            }

            # Extract property name
            title_element = parser.css_first("h1.chakra-heading.css-16h1lz")
            details["Property Name"] = str(title_element.text(strip=True))

            # Extract property description
            description_container = parser.css_first('p[data-test="offerDetail.description"]')
            if description_container:
                description_text = description_container.text(strip=True)
                details["Property Description"] = str(description_text)

            # Extract property price and basic details
            price = parser.css_first('h2[data-test="offerDetail.price"]')
            if price:
                price = price.css_first("span")
                price_text = price.text(strip=True)
                details["Cena"] = str(price_text)
                
            # Extract price details
            price_details = parser.css_first('p[data-test="offerDetail.price.note"]')
            if price_details:
                price_details_text = price_details.text(strip=True)
                details["Price Details"] = str(price_details_text)
            
            # Extract property additional details
            key_value_info = parser.css_first('div[data-test="offerDetail.keyValueInfo"]')
            if key_value_info:
                for item in key_value_info.css('div.chakra-stack'):
                    label_el = item.css_first('p.chakra-text')
                    if not label_el:
                        continue
                    label = label_el.text(strip=True)
                    # Value can be in <p> or <a><p>
                    value_el = item.css_first('a > p.chakra-text') or item.css_first('p.chakra-text:not(.css-1szwyl0)')
                    value = value_el.text(strip=True) if value_el else ""
                    details[label] = value

            # GPS Coordinates
            # geo = None
            # if "gps_coordinates" in details:
            #     geo = details.get("gps_coordinates")
            # if isinstance(geo, dict) and "lat" in geo and "lng" in geo:
            #     details["GPS Coordinates"] = str(f"{geo['lat']},{geo['lng']}")
            # else:
            #     details["GPS Coordinates"] = None

            # Generate hash
            hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            return details

        except Exception as e:
            print(f"Error processing details for {listing_id}: {e}")
            return None

# Execute the async function
print(f"Found {df.count()} listings")
if df.count() > 0:
    scraper = Scraper_details()
    parsed_details = await asyncio.gather(*[scraper.fetch_property_details(row.listing_id, row.listing_url, row.gps_coordinates) for row in df.collect()])
    parsed_details = [d for d in parsed_details if d is not None]
    print(f"Scraped {len(parsed_details)} listings")
    # Create a DF
    df_parsed_details = spark.createDataFrame(parsed_details)

else:
    schema = StructType([
        StructField("listing_id", StringType(), True),
        StructField("listing_url", StringType(), True),
        StructField("gps_coordinates", StringType(), True),
    ])
    df_parsed_details = spark.createDataFrame([], schema)

display(df_parsed_details)