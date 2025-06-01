import os
import httpx
import hashlib
import json
import asyncio
from selectolax.parser import HTMLParser
from core.base_scraper import BaseScraper
from core.websites.utils.extract_url_id import extract_url_id
from core.websites.utils.save_html import save_html
from core.websites.utils.save_to_csv import save_to_csv
from core.websites.utils.save_to_json import save_to_json
from core.websites.utils.save_raw_to_postgres import save_raw_to_postgres
from core.utils import save_images, extract_details, extract_id

class RemaxScraper(BaseScraper):
    BASE_URL = "https://www.remax-czech.cz"
    NAME = "remax"
    MODE_MAPPING = {
        "prodej": "1",
        "pronajem": "2",
    }

    async def fetch_listings(self, max_pages: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        while page <= max_pages:
            mode_key = (self.mode[0] if isinstance(self.mode, list) and self.mode else self.mode or "prodej").lower()
            mode_value = self.MODE_MAPPING.get(mode_key, "PRODEJ")
            url = f"{self.BASE_URL}/reality/vyhledavani/?ldesc_text={self.location}&sale={mode_value}&stranka={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text, os.path.join("data", "raw", "html", "remax"), f"remax_page_{page}.html"
            )

            parser = HTMLParser(response.text)
            listings = parser.css("div.pl-items__item")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = [
                self.BASE_URL + listing.css_first("a.pl-items__link").attributes["href"]
                for listing in listings
                if listing.css_first("a.pl-items__link")
            ]
            self.logger.info(
                f"Extracted {len(detail_links)} detail links from page {page}"
            )

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            next_page = parser.css_first("a.page-link[title='další']")
            if not next_page or next_page.attributes.get("href") == "#":
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Save results to CSV and JSON after each page
        csv_path = self.output_paths.get("csv", "data/raw/csv/remax/remax.csv")
        save_to_csv(results, csv_path, True)
        json_dir = self.output_paths.get("json", "data/raw/json/remax/remax.json")
        save_to_json(results, json_dir, self.NAME, True)
        # Save raw data to PostgreSQL
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        property_id = extract_url_id(url, "/", -2)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_path = os.path.join("data", "raw", "html", "remax", f"remax_{property_id}.html")
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text, os.path.join("data", "raw", "html", "remax"), f"remax_{property_id}.html"
            )

            parser = HTMLParser(response.text)
            details = {"id": property_id, "URL": url}

            title_element = parser.css_first("h1.h2.pd-header__title")
            details["Property Name"] = (
                title_element.text(strip=True) if title_element else "N/A"
            )

            description_container = parser.css_first("div.pd-base-info__content-collapse-inner")
            details["Property Description"] = (
                description_container.text(strip=True) if description_container else "N/A"
            )

            price_container = parser.css_first("div.pd-table__inner")
            if price_container:
                details.update(
                    extract_details(
                        price_container,
                        "div.pd-table__row",
                        "div.pd-table__label",
                        "div.pd-table__value",
                    )
                )

            detail_container = parser.css_first("div.pd-detail-info")
            if detail_container:
                details.update(
                    extract_details(
                        detail_container,
                        "div.pd-detail-info__row",
                        "div.pd-detail-info__label",
                        "div.pd-detail-info__value",
                    )
                )

            map_element = parser.css_first("div#listingMap")
            details["GPS coordinates"] = (
                map_element.attributes.get("data-gps") if map_element else "N/A"
            )

            image_elements = parser.css("div.pd-gallery__item img")
            image_urls = list(
                {img.attributes["src"] for img in image_elements if "src" in img.attributes}
            )
            if image_urls:
                try:
                    await self.download_images(property_id, image_urls)
                    details["Images"] = image_urls
                except Exception as e:
                    self.logger.error(f"Error downloading images for {property_id}: {e}")
                    details["Images"] = "N/A"
            else:
                details["Images"] = "N/A"

            hash_input = {k: v for k, v in details.items() if k not in ["URL", "listing_hash"]}
            details["listing_hash"] = hashlib.sha256(
                json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode("utf-8")
            ).hexdigest()

            self.logger.info(f"Details for property ID {property_id} fetched successfully.")
            return details
        

        except Exception as e:
            self.logger.error(f"Error processing details for {property_id}: {e}")
            return None

    async def download_images(self, property_id: str, image_urls: list):
        await save_images(property_id, image_urls, self.output_paths["images"])