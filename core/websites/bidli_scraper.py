import os
import httpx
import hashlib
import json
import asyncio
import re
from selectolax.parser import HTMLParser
from core.base_scraper import BaseScraper
from core.websites.utils.save_html import save_html
from core.websites.utils.save_to_csv import save_to_csv
from core.websites.utils.save_to_json import save_to_json
from core.websites.utils.save_raw_to_postgres import save_raw_to_postgres
from core.utils import save_images, extract_details, extract_id


class BidliScraper(BaseScraper):
    BASE_URL = "https://www.bidli.cz/"
    NAME = "bidli"

    async def fetch_listings(self, max_pages: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 0  # Start at 0 for Bidli

        max_pages = max_pages or self.pages

        while page < max_pages:
            url = f"{self.BASE_URL}chci-koupit/list/?akce=1&page={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text,
                os.path.join("data", "raw", "html", "bidli"),
                f"bidli_page_{page}.html",
            )

            parser = HTMLParser(response.text)
            listings = parser.css("a.item")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = []
            for listing in listings:
                href = listing.attributes.get("href")
                if href:
                    if href.startswith("http"):
                        detail_links.append(href)
                    else:
                        # Correct Bidli detail URL
                        detail_links.append(f"https://www.bidli.cz{href}")
            self.logger.info(
                f"Extracted {len(detail_links)} detail links from page {page}"
            )

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Find next page (Bidli uses ?page=)
            next_page_link = parser.css_first("a.next")
            if not next_page_link or not next_page_link.attributes.get("href"):
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Save results to CSV and JSON after each page
        csv_path = self.output_paths.get("csv", "data/raw/csv/bidli/bidli.csv")
        save_to_csv(results, csv_path, True)
        json_dir = self.output_paths.get("json", "data/raw/json/bidli/bidli.json")
        save_to_json(results, json_dir, self.NAME, True)
        # Save raw data to PostgreSQL
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        try:
            url_parts = url.split("/")
            property_id = url_parts[6] if len(url_parts) > 6 else extract_id(url)
        except Exception:
            property_id = extract_id(url)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_path = os.path.join(
            "data", "raw", "html", "bidli", f"bidli_{property_id}.html"
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
                os.path.join("data", "raw", "html", "bidli"),
                f"bidli_{property_id}.html",
            )

            parser = HTMLParser(response.text)
            details = {"id": property_id, "URL": url}
 
            # Extract property name
            title_element = parser.css_first("h2.orange.bmg-0")
            details["Property Name"] = (
                title_element.text(strip=True) if title_element else "N/A"
            )

            description_container = parser.css_first(
                "div.col-66"
            )
            details["Property Description"] = (
                description_container.text(strip=True)
                if description_container
                else "N/A"
            )

            # Extract price information
            price_container = parser.css_first("div.h2.orange.bmg-0.t-right")
            details["Price"] = price_container.text(strip=True) if price_container else "N/A"

            # Extract additional details from table in div.col-32
            detail_container = parser.css_first("div.col-32")
            if detail_container:
                rows = detail_container.css("tr")
                for row in rows:
                    th = row.css_first("th")
                    td = row.css_first("td")
                    if th and td:
                        label = th.text(strip=True)
                        value = td.text(strip=True)
                        details[label] = value

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
