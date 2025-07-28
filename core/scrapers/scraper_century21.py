# Define async function to fetch property details
import asyncio
import httpx
import hashlib
import re
from selectolax.parser import HTMLParser
from pyspark.sql.types import StructType, StructField, StringType
from typing import Optional, Dict

class Scraper_details:
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

            # Extract category1, category2, category3 from URL
            try:
                url_path = re.sub(r"^https?://[^/]+/", "", listing_url)
                path_parts = url_path.split("/")
                if len(path_parts) > 1:
                    segments = path_parts[1].split("-")
                    if len(segments) >= 3:
                        details["category1"] = segments[0]
                        details["category2"] = segments[1]
                        details["category3"] = segments[2]
            except Exception as e:
                print(f"Error extracting categories from URL for {listing_id}: {e}")

            # Extract property additional details
            tables_container = parser.css("table.w-full.text-white.border-t-2.border-b-2.border-black")
            for table in tables_container:
                details.update(
                    self._extract_details_from_table(
                        table,
                        "tr",
                        "th",
                        "td",
                    )
                )

            # GPS from <script>self.__next_f.push...
            gps_found = False
            try:
                import re
                
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

            # Generate hash
            hash_input = {k: v for k, v in details.items() if k not in ["listing_hash", "ins_dt"]}
            listing_hash = hashlib.sha256(str(sorted(hash_input.items())).encode()).hexdigest()
            details["listing_hash"] = str(listing_hash)

            return details

        except Exception as e:
            print(f"Error processing details for {listing_id}: {e}")
            return None

    def _extract_details_from_table(self, container, row_sel: str, label_sel: str, value_sel: str) -> Dict[str, str]:
        """Extract details from table-like HTML structure"""
        details = {}
        for row in container.css(row_sel):
            label = row.css_first(label_sel)
            value = row.css_first(value_sel)
            if label and value:
                details[label.text(strip=True)] = str(value.text(strip=True))
            else:
                details[label.text(strip=True)] = None
        print(details)
        return details

# Execute the async function
print(f"Found {df.count()} listings")
if df.count() > 0:
    scraper = Scraper_details()
    parsed_details = await asyncio.gather(*[scraper.fetch_property_details(row.listing_id, row.listing_url) for row in df.collect()])
    parsed_details = [d for d in parsed_details if d is not None]
    print(f"Scraped {len(parsed_details)} listings")
    # Create a DF
    df_parsed_details = spark.createDataFrame(parsed_details)

else:
    schema = StructType([
        StructField("listing_id", StringType(), True),
        StructField("listing_url", StringType(), True)
    ])
    df_parsed_details = spark.createDataFrame([], schema)

display(df_parsed_details)