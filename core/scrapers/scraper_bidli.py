import os
import asyncio
import re
from core.base_scraper import BaseScraper
from core.scrapers.utils.extract_url_id import extract_url_id
from core.scrapers.utils.save_to_csv import save_to_csv
from core.scrapers.utils.save_to_json import save_to_json
from core.scrapers.utils.save_raw_to_postgres import save_raw_to_postgres
from core.scrapers.utils.download_and_parse_html import download_and_parse_html
from core.scrapers.utils.extract_details_from_table import extract_details_from_table
from core.scrapers.utils.hash_details import hash_details
from core.utils import save_images

class BidliScraper(BaseScraper):
    BASE_URL = "https://www.bidli.cz/"
    NAME = "bidli"
    MODE_MAPPING = {
        "prodej": "1",
        "pronajem": "2",
    }

    async def fetch_listings(self, max_pages: int = None, per_page: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 0  # Bidli stránkování začíná od 0

        while max_pages is None or page < max_pages:
            mode_key = (self.mode[0] if isinstance(self.mode, list) and self.mode else self.mode or "prodej").lower()
            mode_value = self.MODE_MAPPING.get(mode_key, "1")
            url = f"{self.BASE_URL}chci-koupit/list/?akce={mode_value}&page={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            parser = await download_and_parse_html(
                url, os.path.join("data", "raw", "html", "bidli"), f"bidli_page_{page}.html"
            )

            listings = parser.css("a.item")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = []
            for listing in listings:
                href = listing.attributes.get("href")
                if href:
                    if href.startswith("http"):
                        detail_links.append(href)
                    else:
                        detail_links.append(f"https://www.bidli.cz{href}")

            if per_page is not None:
                detail_links = detail_links[:per_page]

            self.logger.info(f"Extracted {len(detail_links)} detail links from page {page}")

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Najdi další stránku
            next_page_link = parser.css_first("a.next")
            if not next_page_link or not next_page_link.attributes.get("href"):
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Ulož výsledky
        csv_dir = self.output_paths.get("csv", "data/raw/csv/bidli")
        save_to_csv(results, csv_dir, self.NAME, True)
        json_dir = self.output_paths.get("json", "data/raw/json/bidli")
        save_to_json(results, json_dir, self.NAME, True)
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        property_id = extract_url_id(url, "/", -1)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_dir = os.path.join("data", "raw", "html", "bidli")
        html_path = os.path.join(html_dir, f"bidli_{property_id}.html")
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            parser = await download_and_parse_html(
                url, html_dir, f"bidli_{property_id}.html"
            )
            details = {"id": property_id, "URL": url}

            # Název
            title_element = parser.css_first("h2.orange.bmg-0")
            details["Property Name"] = title_element.text(strip=True) if title_element else "N/A"

            # Popis
            description_element = parser.css_first("#top > div.screen > div.screen-in > div:nth-child(1) > div > div:nth-child(7) > div.col-66 > p")
            details["Property Description"] = description_element.text(strip=True) if description_element else "N/A"

            # PENB (energetický štítek)
            penb_type_element = parser.css_first("span.energeticky-stitek-type")
            details["PENB"] = penb_type_element.text(strip=True)

            # Cena
            price_container = parser.css_first("div.h2.orange.bmg-0.t-right")
            details["Price"] = price_container.text(strip=True) if price_container else "N/A"

            # Detaily z tabulek
            for table in parser.css("table"):
                details.update(
                    extract_details_from_table(table, "tr", "th", "td")
                )

            # GPS z mapy nebo z JS
            map_element = parser.css_first("div#listingMap")
            details["GPS coordinates"] = map_element.attributes.get("data-gps") if map_element else "N/A"
            html_content = parser.html
            match = re.search(
                r"LatLng\s*=\s*new google\.maps\.LatLng\(\s*([0-9\.\-]+)\s*,\s*([0-9\.\-]+)\s*\)",
                html_content,
            )
            if match:
                lat = match.group(1)
                lng = match.group(2)
                details["GPS coordinates"] = f"{lat},{lng}"

            # Obrázky (zatím pouze příprava)
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

            details["listing_hash"] = hash_details(details)

            self.logger.info(f"Details for property ID {property_id} fetched successfully.")
            return details

        except Exception as e:
            self.logger.error(f"Error processing details for {property_id}: {e}")
            return None

    async def download_images(self, property_id: str, image_urls: list):
        await save_images(property_id, image_urls, self.output_paths["images"])

# --- připrav si extract_images zde, až bude potřeba ---