import os
import httpx
import logging
import asyncio
import hashlib
import json
from core.utils import save_html, extract_details
from selectolax.parser import HTMLParser
from datetime import datetime

class RemaxScraper:
    BASE_URL = "https://www.remax-czech.cz"

    def __init__(self, location: str = None):
        """
        Inicializace scraperu s volitelnou lokalitou.
        :param location: Lokalita, kterou chceme vyhledávat.
        """
        self.location = location
        self.logger = logging.getLogger("remax_scrapper")

    async def fetch_listings(self, max_pages: int = 1):
        """
        Načte seznam nemovitostí z hlavní stránky.
        :param max_pages: Maximální počet stránek k načtení.
        :return: Seznam detailů nemovitostí.
        """
        self.logger.info(f"Fetching listings for location: {self.location}")
        results = []
        page = 1

        # Zajistit, že adresář pro výstupy existuje
        output_dir = "./test/remax_test/"
        os.makedirs(output_dir, exist_ok=True)

        # Získání aktuálního data ve formátu rok_měsíc_den
        current_date = datetime.now().strftime("%Y_%m_%d")

        while page <= max_pages:
            # Sestavení URL pro aktuální stránku
            url = f"{self.BASE_URL}/reality/vyhledavani/?ldesc_text={self.location}&sale=1&stranka={page}"
            self.logger.info(f"Fetching page {page}: {url}")

            # Načtení HTML stránky
            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()

            # Uložení HTML stránky
            html_file = os.path.join(output_dir, f"{current_date}_page_{page}.html")
            save_html(response.text, output_dir, f"{current_date}_page_{page}.html")
            self.logger.info(f"Saved HTML for page {page} to {html_file}")

            # Parsování HTML a extrakce nemovitostí
            parser = HTMLParser(response.text)
            listings = parser.css("div.pl-items__item")
            self.logger.info(f"Found {len(listings)} listings on page {page}")

            # Extrakce odkazů na detailní stránky
            detail_links = [
                self.BASE_URL + listing.css_first("a.pl-items__link").attributes["href"]
                for listing in listings if listing.css_first("a.pl-items__link")
            ]
            self.logger.info(f"Extracted {len(detail_links)} detail links from page {page}")

            # Paralelní načtení detailních stránek
            tasks = [self.fetch_property_details(link) for link in detail_links]
            details_list = await asyncio.gather(*tasks)
            results.extend(filter(None, details_list))  # Přidat pouze nenulové výsledky

            # Kontrola, zda je stránkování na poslední stránce
            next_page = parser.css_first("a.page-link[title='další']")
            if not next_page or next_page.attributes.get("href") == "#":
                self.logger.info(f"Reached the last page: {page}")
                break

            page += 1  # Pokračujeme na další stránku

        return results

    async def fetch_property_details(self, url: str):
        property_id = url.split("/")[5]
        self.logger.info(f"Fetching details for property ID: {property_id}")
    
        # Načtení HTML stránky
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()
    
        # Uložení HTML stránky
        save_html(response.text, "./test/remax_test/details", f"{property_id}.html")
    
        # Parsování HTML (musí být před použitím parseru)
        parser = HTMLParser(response.text)
    
        # ID nemovitosti
        details = {"ID": property_id, "URL": url}
    
        # Název nemovitosti
        title_element = parser.css_first("h1.h2.pd-header__title")
        details["Název nemovitosti"] = title_element.text(strip=True) if title_element else "N/A"

        # Popis nemovitosti
        description_container = parser.css_first("div.pd-base-info__content-collapse-inner")
        details["Popis nemovitosti"] = description_container.text(strip=True) if description_container else "N/A"
    
        # Cena a další detaily
        price_container = parser.css_first("div.pd-table__inner")
        if price_container:
            details.update(extract_details(price_container, "div.pd-table__row", "div.pd-table__label", "div.pd-table__value"))
    
        # Další detaily
        detail_container = parser.css_first("div.pd-detail-info")
        if detail_container:
            details.update(extract_details(detail_container, "div.pd-detail-info__row", "div.pd-detail-info__label", "div.pd-detail-info__value"))
    
        # GPS souřadnice
        map_element = parser.css_first("div#listingMap")
        details["GPS souřadnice"] = map_element.attributes.get("data-gps") if map_element else "N/A"

        # Obrázky
        image_elements = parser.css("div.gallery__items")
        details["Obrázky"] = [img.attributes.get("src") for img in image_elements if img.attributes.get("src")]

        # Vytvoření hashe po naplnění všech atributů nemovitosti
        hash_input = {k: v for k, v in details.items() if k not in ["URL", "listing_hash"]}
        details["listing_hash"] = hashlib.sha256(json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode("utf-8")).hexdigest()
    
        self.logger.info(f"Details for property ID {property_id}: {details}")
        return details