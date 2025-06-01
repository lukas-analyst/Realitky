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
from core.utils import save_images, extract_details, extract_id

class BezrealitkyScraper(BaseScraper):
    BASE_URL = "https://www.bezrealitky.cz/"
    NAME = "bezrealitky"
    

    async def fetch_listings(self, max_pages: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        # Compose mode (make sure it's uppercase)
        mode_value = self.mode[0] if isinstance(self.mode, list) and self.mode else (self.mode or "prodej")
        mode = str(mode_value).upper()
        mode_param = f"vyhledat?offerType={mode}"
        # Compose Czechia region URL
        czechia_url = "&regionOsmIds=R51684&osm_value=Česko&location=exact"
        # Construct the base URL
        base_url = self.BASE_URL + mode_param + czechia_url

        while page <= max_pages:
            url = f"{base_url}&page={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text, os.path.join("data", "raw", "html", "bezrealitky"), f"bezrealitky_page_{page}.html"
            )

            parser = HTMLParser(response.text)
            listings = parser.css("div.PropertyCard_propertyCardContent__osPAM")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = []
            for listing in listings:
                a_tag = listing.css_first("a")
                if a_tag and "href" in a_tag.attributes:
                    href = a_tag.attributes["href"]
                    if href.startswith("http"):
                        detail_links.append(href)
                    else:
                        detail_links.append("https://www.bezrealitky.cz" + href)
            self.logger.info(
                f"Extracted {len(detail_links)} detail links from page {page}"
            )

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Najdi odkaz na další stránku (musí to být <a> s href)
            next_page_link = None
            for a in parser.css("a.page-link"):
                if a.attributes.get("href"):
                    next_page_link = a
                    break
            
            if not next_page_link:
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Save results to CSV and JSON after each page
        csv_path = self.output_paths.get("csv", "data/raw/csv/bezrealitky/bezrealitky.csv")
        save_to_csv(results, csv_path, True)
        json_dir = self.output_paths.get("json", "data/raw/json/bezrealitky/bezrealitky.json")
        save_to_json(results, json_dir, self.NAME, True)
        # Save raw data to PostgreSQL
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        # Extract ID from URL: between last '/' and first '-' after that
        match = re.search(r'/(\d+)-', url)
        property_id = match.group(1) if match else extract_url_id(url, "/", -1)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_path = os.path.join("data", "raw", "html", "bezrealitky", f"bezrealitky_{property_id}.html")
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text, os.path.join("data", "raw", "html", "bezrealitky"), f"bezrealitky_{property_id}.html"
            )

            parser = HTMLParser(response.text)
            details = {"id": property_id, "URL": url}

            # Extract property name and description
            title_element = parser.css_first("h1.h2.pd-header__title, h1.h2, h1.mb-3.mb-lg-10.h2")
            if title_element:
                # Vezme text z prvního <span> uvnitř <h1>
                span = title_element.css_first("span")
                details["Property Name"] = span.text(strip=True) if span else title_element.text(strip=True)
            else:
                details["Property Name"] = "N/A"

            # Extract property description from react-aria tabpane
            description_container = parser.css_first('div[id^="react-aria-"][id$="-tabpane-native"]')
            details["Property Description"] = (
                description_container.text(strip=True) if description_container else "N/A"
            )

            # Extract price from the price container
            price_container = parser.css_first("div.justify-content-between.align-items-baseline.mb-lg-9.mb-6.row")
            if price_container:
                price_span = price_container.css_first("strong.h4.fw-bold span")
                details["Cena"] = price_span.text(strip=True) if price_span else "N/A"
            else:
                details["Cena"] = "N/A"

            # Extract property details from all ParamsTable tables
            for detail_container in parser.css("div.ParamsTable_paramsTable__tX8zj.paramsTable"):
                for tr in detail_container.css("tr"):
                    th = tr.css_first("th span")
                    td = tr.css_first("td")
                    if th and td:
                        label = th.text(strip=True)
                        value_span = td.css_first("span")
                        value = value_span.text(strip=True) if value_span else td.text(strip=True)
                        details[label] = value

            # Extract GPS
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
                    if lat is not None and lng is not None:
                        details["GPS coordinates"] = f"{lat},{lng}"
                    else:
                        details["GPS coordinates"] = "N/A"
                except Exception as e:
                    self.logger.error(f"Error parsing GPS from __NEXT_DATA__: {e}")
                    details["GPS coordinates"] = "N/A"
            else:
                self.logger.warning("No __NEXT_DATA__ script tag found!")
                details["GPS coordinates"] = "N/A"

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