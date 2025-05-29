import os
import httpx
import logging
import hashlib
import json
import asyncio
from selectolax.parser import HTMLParser
from core.base_scraper import BaseScraper
from core.utils import save_html, extract_details, extract_id

class SRealityScraper(BaseScraper):
    BASE_URL = "https://www.sreality.cz"

    async def fetch_listings(self, max_pages: int = 1):
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        # Pouze první stránka
        url = f"{self.BASE_URL}/hledani/prodej?lokalita={self.location}&strana={page}"
        self.logger.info(f"Fetching page {page}: {url}")

        async with httpx.AsyncClient(follow_redirects=True) as client:
            response = await client.get(url)
            response.raise_for_status()

        await save_html(
            response.text, self.output_paths["html"], f"sreality_page_{page}.html"
        )

        parser = HTMLParser(response.text)
        listings_container = parser.css_first("div.css-tq8fjv")
        if not listings_container:
            self.logger.warning(f"No listings container found on page {page}")
            return results

        listings = listings_container.css("li")
        self.logger.info(f"Found {len(listings)} listings on page {page}")

        # Vezmeme pouze první detail link
        detail_link = None
        for li in listings:
            a = li.css_first("a.MuiLink-root")
            if a and "href" in a.attributes:
                detail_link = self.BASE_URL + a.attributes["href"]
                break

        if detail_link:
            self.logger.info(f"Testing only first detail link: {detail_link}")
            details = await self.fetch_property_details(detail_link)
            if details:
                results.append(details)
        else:
            self.logger.warning("No detail link found on first page.")

        return results

    async def fetch_property_details(self, url: str) -> dict:
        property_id = extract_id(url)
        self.logger.info(f"Fetching details for property ID: {property_id}")

        html_path = os.path.join(self.output_paths["html"], f"sreality_{property_id}.html")
        if os.path.exists(html_path):
            self.logger.info(f"Property ID {property_id} already scraped, skipping.")
            return None

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url)
                response.raise_for_status()

            await save_html(
                response.text, self.output_paths["html"], f"sreality_{property_id}.html"
            )

            parser = HTMLParser(response.text)
            details = {"ID": property_id, "URL": url}

            # Název nemovitosti
            title_element = parser.css_first("h1.css-h2bhwn")
            details["Název nemovitosti"] = (
                title_element.text(strip=True) if title_element else "N/A"
            )

            # Popis nemovitosti
            description_container = parser.css_first("pre.css-16eb98b")
            details["Popis nemovitosti"] = (
                description_container.text(strip=True) if description_container else "N/A"
            )

            # Další detaily (implementujte podle potřeby)
            # details.update(extract_details(...))

            # GPS souřadnice z JSON ve scriptu
            script = parser.css_first('script#__NEXT_DATA__')
            if script:
                try:
                    data = json.loads(script.text())
                    coords = None
                    stack = [data]
                    while stack:
                        obj = stack.pop()
                        if isinstance(obj, dict):
                            if "locality" in obj and isinstance(obj["locality"], dict):
                                loc = obj["locality"]
                                if "latitude" in loc and "longitude" in loc:
                                    coords = (loc["latitude"], loc["longitude"])
                                    break
                            stack.extend(obj.values())
                        elif isinstance(obj, list):
                            stack.extend(obj)
                    if coords:
                        details["GPS souřadnice"] = f"{coords[0]},{coords[1]}"
                    else:
                        details["GPS souřadnice"] = "N/A"
                except Exception as e:
                    self.logger.error(f"Chyba při extrakci GPS: {e}")
                    details["GPS souřadnice"] = "N/A"
            else:
                details["GPS souřadnice"] = "N/A"

            hash_input = {k: v for k, v in details.items() if k not in ["URL", "listing_hash"]}
            details["listing_hash"] = hashlib.sha256(
                json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode("utf-8")
            ).hexdigest()

            self.logger.info(f"Details for property ID {property_id} fetched successfully.")
            return details

        except Exception as e:
            self.logger.error(f"Chyba při zpracování detailu {property_id}: {e}")
            return None