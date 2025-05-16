import os
import httpx
import logging
import asyncio
import hashlib
import json
from core.utils import save_html, extract_details
from selectolax.parser import HTMLParser
from datetime import datetime

class SRealityScraper:
    BASE_URL = "https://www.sreality.cz/hledani/prodej"

    def __init__(self, location: str = None):
        """
        Inicializace scraperu s volitelnou lokalitou.
        :param location: Lokalita, kterou chceme vyhledávat (např. 'praha').
        """
        self.location = location
        self.logger = logging.getLogger("sreality_scrapper")

    async def fetch_listings(self, max_pages: int = 1):
        """
        Načte seznam nemovitostí z hlavní stránky.
        :param max_pages: Maximální počet stránek k načtení.
        :return: Seznam detailů nemovitostí.
        """
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        output_dir = "./test/sreality_test/"
        os.makedirs(output_dir, exist_ok=True)
        current_date = datetime.now().strftime("%Y_%m_%d")

        while page <= max_pages:
            # Sestavení URL pro aktuální stránku
            url = f"{self.BASE_URL}/{self.location}?strana={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            html_file = os.path.join(output_dir, f"{current_date}_page_{page}.html")
            save_html(response.text, output_dir, f"{current_date}_page_{page}.html")
            self.logger.info(f"Saved HTML for page {page} to {html_file}")

            parser = HTMLParser(response.text)
            listings = parser.css("div.property")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            # Extrakce odkazů na detailní stránky
            detail_links = [
                "https://www.sreality.cz" + listing.css_first("a.title").attributes["href"]
                for listing in listings if listing.css_first("a.title")
            ]
            self.logger.info(f"Extracted {len(detail_links)} detail links from page {page}")

            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))

            # Kontrola, zda je stránkování na poslední stránce
            next_page = parser.css_first("a.paging-next")
            if not next_page or next_page.attributes.get("href") == "#":
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1

        return results

    async def fetch_property_details(self, url: str):
        property_id = url.split("/")[-1]
        self.logger.info(f"Fetching details for property ID: {property_id}")

        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()

        save_html(response.text, "./test/sreality_test/details", f"{property_id}.html")
        parser = HTMLParser(response.text)

        details = {"ID": property_id, "URL": url}

        # Název nemovitosti
        title_element = parser.css_first("h1.property-title")
        details["Název nemovitosti"] = title_element.text(strip=True) if title_element else "N/A"

        # Cena
        price_element = parser.css_first("span.norm-price")
        details["Cena"] = price_element.text(strip=True) if price_element else "N/A"

        # Další detaily (dle potřeby upravte selektory)
        # ...

        # Vytvoření hashe po naplnění všech atributů nemovitosti
        hash_input = {k: v for k, v in details.items() if k not in ["URL", "listing_hash"]}
        details["listing_hash"] = hashlib.sha256(json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode("utf-8")).hexdigest()

        self.logger.info(f"Details for property ID {property_id}: {details}")
        return details