import os
import httpx
import hashlib
import json
import asyncio
import re
from selectolax.parser import HTMLParser
from core.base_scraper import BaseScraper
from core.websites.utils.extract_url_id import extract_url_id
from core.websites.utils.save_html import save_html
from core.websites.utils.save_to_csv import save_to_csv
from core.websites.utils.save_to_json import save_to_json
from core.websites.utils.save_raw_to_postgres import save_raw_to_postgres
from core.utils import save_images


class Century21Scraper(BaseScraper):
    BASE_URL = "https://www.century21.cz/"
    NAME = "century21"
    MODE_MAPPING = {
        "prodej": "1",
        "pronajem": "2",
    }

    async def fetch_listings(self, max_pages: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        max_pages = max_pages or self.pages

        while page < max_pages:
            # Mode doesn not work with Century21
            # Construct the URL with page number
            url = f"{self.BASE_URL}/nemovitosti?page={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text,
                os.path.join("data", "raw", "html", "century21"),
                f"century21_page_{page}.html",
            )

            parser = HTMLParser(response.text)
            listings = parser.css("article.bg-shade-300")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = []
            for listing in listings:
                # find the first <a> tag with href attribute
                a_tag = listing.css_first("a[href]")
                if a_tag:
                    href = a_tag.attributes.get("href")
                    if href:
                        if href.startswith("http"):
                            detail_links.append(href)
                        else:
                            # prepend the base URL if href is relative
                            detail_links.append(f"https://www.century21.cz{href}")
            self.logger.info(
                f"Extracted {len(detail_links)} detail links from page {page}"
            )

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Find next page (century21 uses ?page=)
            next_page_link = parser.css_first("a.next")
            if not next_page_link or not next_page_link.attributes.get("href"):
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Save results to CSV and JSON after each page
        csv_path = self.output_paths.get("csv", "data/raw/csv/century21/century21.csv")
        save_to_csv(results, csv_path, True)
        json_dir = self.output_paths.get("json", "data/raw/json/century21/century21.json")
        save_to_json(results, json_dir, self.NAME, True)
        # Save raw data to PostgreSQL
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        # Extract property ID from the URL
        property_id = extract_url_id(url, regex=r'id=([^-]+)')
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_path = os.path.join(
            "data", "raw", "html", "century21", f"century21_{property_id}.html"
        )
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text,
                os.path.join("data", "raw", "html", "century21"),
                f"century21_{property_id}.html",
            )

            # Parse the HTML response
            parser = HTMLParser(response.text)
            details = {"id": property_id, "URL": url}
 
            # Extract property name
            title_element = parser.css_first("h3.font-barlow.font-bold")
            details["Property Name"] = (
                title_element.text(strip=True) if title_element else "N/A"
            )

            description_container = parser.css_first(
                "div.text-white.font-light.whitespace-break-spaces"
            )
            details["Property Description"] = (
                description_container.text(strip=True)
                if description_container
                else "N/A"
            )

            # Extract price information
            price_container = parser.css_first("p.font-barlow.font-bold")
            details["Price"] = price_container.text(strip=True) if price_container else "N/A"

            # Extract additional details from all tables in the grid
            tables = parser.css("table")
            self.logger.info(f"Found {len(tables)} tables on the whole page for property {property_id}")
            for i, table in enumerate(tables):
                rows = table.css("tr")
                self.logger.info(f"Table {i} has {len(rows)} rows")
                for row in rows:
                    th = row.css_first("th")
                    td = row.css_first("td")
                    th_text = th.text(strip=True) if th else None
                    td_text = td.text(strip=True) if td else None
                    self.logger.info(f"Row: th={th_text}, td={td_text}")
                    if th_text and td_text:
                        details[th_text] = td_text
            else:
                self.logger.warning(f"No grid container found for property {property_id}")
            
            self.logger.info(f"Extracted details for {property_id}: {details}")

            # Extract GPS coordinates from the map element
            map_element = parser.css_first("div#listingMap")
            details["GPS coordinates"] = (
                map_element.attributes.get("data-gps") if map_element else "N/A"
            )
            
            # Extract GPS coordinates extraction using regex
            html_content = response.text
            match = re.search(
                r"LatLng\s*=\s*new google\.maps\.LatLng\(\s*([0-9\.\-]+)\s*,\s*([0-9\.\-]+)\s*\)",
                html_content,
            )
            if match:
                lat = match.group(1)
                lng = match.group(2)
                details["GPS coordinates"] = f"{lat},{lng}"
            else:
                details["GPS coordinates"] = "N/A"

            # Extract images
            image_elements = parser.css("div.pd-gallery__item img")
            image_urls = list(
                {
                    img.attributes["src"]
                    for img in image_elements
                    if "src" in img.attributes
                }
            )
            if image_urls:
                try:
                    await self.download_images(property_id, image_urls)
                    details["Images"] = image_urls
                except Exception as e:
                    self.logger.error(
                        f"Error downloading images for {property_id}: {e}"
                    )
                    details["Images"] = "N/A"
            else:
                details["Images"] = "N/A"

            hash_input = {
                k: v for k, v in details.items() if k not in ["URL", "listing_hash"]
            }
            details["listing_hash"] = hashlib.sha256(
                json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode(
                    "utf-8"
                )
            ).hexdigest()

            self.logger.info(
                f"Details for property ID {property_id} fetched successfully."
            )
            return details

        except Exception as e:
            self.logger.error(f"Error processing details for {property_id}: {e}")
            return None

    async def download_images(self, property_id: str, image_urls: list):
        await save_images(property_id, image_urls, self.output_paths["images"])
