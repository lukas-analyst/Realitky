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

            # GPS Coordinates
            gps_dict = json.loads(gps_coordinates.replace("'", '"'))
            lat = gps_dict.get("lat")
            lng = gps_dict.get("lng")
            if lat is not None and lng is not None:
                details["GPS Coordinates"] = f"{lat},{lng}"

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