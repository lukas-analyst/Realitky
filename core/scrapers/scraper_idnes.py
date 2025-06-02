import os
import asyncio
import re
import json
from core.base_scraper import BaseScraper
from core.scrapers.utils.extract_url_id import extract_url_id
from core.scrapers.utils.save_to_csv import save_to_csv
from core.scrapers.utils.save_to_json import save_to_json
from core.scrapers.utils.save_raw_to_postgres import save_raw_to_postgres
from core.scrapers.utils.download_and_parse_html import download_and_parse_html
from core.scrapers.utils.hash_details import hash_details
from core.utils import save_images

class idnesScraper(BaseScraper):
    BASE_URL = "https://www.reality.idnes.cz/"
    NAME = "idnes"

    async def fetch_listings(self, max_pages: int = None, per_page: int = None):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        mode_value = self.mode[0] if isinstance(self.mode, list) and self.mode else (self.mode or "prodej")
        mode = str(mode_value)
        mode_param = f"s/{mode}"
        base_url = self.BASE_URL + mode_param

        while max_pages is None or page <= max_pages:
            url = f"{base_url}/?page={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            parser = await download_and_parse_html(
                url, os.path.join("data", "raw", "html", "idnes"), f"idnes_page_{page}.html"
            )

            listings = parser.css('div[id^="snippet-s-result-article-"]')
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            detail_links = []
            for listing in listings:
                a_tag = listing.css_first("a.c-products__link")
                if a_tag and "href" in a_tag.attributes:
                    href = a_tag.attributes["href"]
                    if href.startswith("http"):
                        detail_links.append(href)
                    else:
                        detail_links.append("https://www.reality.idnes.cz" + href)

            if per_page is not None:
                detail_links = detail_links[:per_page]

            self.logger.info(f"Extracted {len(detail_links)} detail links from page {page}")

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Najdi odkaz na další stránku
            next_page_link = None
            for a in parser.css("a.btn.paging__item.next"):
                if a.attributes.get("href"):
                    next_page_link = a
                    break

            if not next_page_link:
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        # Ulož výsledky
        csv_path = self.output_paths.get("csv", "data/raw/csv/idnes")
        save_to_csv(results, csv_path, self.NAME, True)
        json_dir = self.output_paths.get("json", "data/raw/json/idnes")
        save_to_json(results, json_dir, self.NAME, True)
        save_raw_to_postgres(results, self.NAME, "id")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        match = re.search(r'/(\d+)-', url)
        property_id = match.group(1) if match else extract_url_id(url, "/", -1)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_dir = os.path.join("data", "raw", "html", "idnes")
        html_path = os.path.join(html_dir, f"idnes_{property_id}.html")
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            parser = await download_and_parse_html(
                url, html_dir, f"idnes_{property_id}.html"
            )
            details = {"id": property_id, "URL": url}

            # Název
            title_element = parser.css_first("h1.b-detail__title")
            if title_element:
                span = title_element.css_first("span")
                details["Property Name"] = span.text(strip=True) if span else title_element.text(strip=True)
            else:
                details["Property Name"] = "N/A"

            # Popis
            description_container = parser.css_first('div.b-desc.pt-10.mt-10')
            details["Property Description"] = (
                description_container.text(strip=True) if description_container else "N/A"
            )

            # Cena
            price_container = parser.css_first("header.b-detail")
            if price_container:
                strong = price_container.css_first("strong")
                details["Cena"] = strong.text(strip=True) if strong else price_container.text(strip=True)
            else:
                details["Cena"] = "N/A"

            # Detaily z <div class="b-definition mb-0"> a <div class="b-definition-columns mb-0">
            for definition in parser.css('div.b-definition.mb-0, div.b-definition-columns.mb-0'):
                dts = definition.css('dt')
                dds = definition.css('dd')
                for dt, dd in zip(dts, dds):
                    if 'advertisement' in dd.attributes.get('class', ''):
                        continue
                    label = dt.text(strip=True)
                    value = ''.join([node.text(strip=True) for node in dd.iter() if node.tag in ('#text', 'sup')])
                    if not value:
                        value = dd.text(strip=True)
                    details[label] = value

            # GPS
            app_maps_div = parser.css_first('div#app-maps')
            gps_found = False
            if app_maps_div and "data-last-center" in app_maps_div.attributes:
                try:
                    last_center_json = app_maps_div.attributes["data-last-center"]
                    last_center = json.loads(last_center_json)
                    lat = last_center.get("lat")
                    lng = last_center.get("lng")
                    if lat is not None and lng is not None:
                        details["GPS coordinates"] = f"{lat},{lng}"
                        gps_found = True
                    else:
                        details["GPS coordinates"] = "N/A"
                except Exception as e:
                    self.logger.error(f"Error parsing GPS from data-last-center: {e}")
                    details["GPS coordinates"] = "N/A"

            if not gps_found:
                script = parser.css_first('script[type="application/json"][data-maptiler-json]')
                if script:
                    try:
                        data = json.loads(script.text())
                        features = data.get("geojson", {}).get("features", [])
                        for feature in features:
                            props = feature.get("properties", {})
                            if not props.get("isSimilar", False):
                                coords = feature.get("geometry", {}).get("coordinates", [])
                                if len(coords) == 2:
                                    details["GPS coordinates"] = f"{coords[1]},{coords[0]}"
                                    gps_found = True
                                    break
                        if not gps_found:
                            details["GPS coordinates"] = "N/A"
                    except Exception as e:
                        self.logger.error(f"Error parsing GPS from maptiler-json: {e}")
                        details["GPS coordinates"] = "N/A"

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