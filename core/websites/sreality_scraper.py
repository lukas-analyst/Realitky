import os
import httpx
import json
from core.base_scraper import BaseScraper

class SrealityApiScraper(BaseScraper):
    BASE_URL = "https://www.sreality.cz/api/cs/v2/estates"
    PER_PAGE = 2  # Maximum allowed by API

    async def fetch_listings(self, max_pages: int = None):
        self.logger.info("Fetching Sreality API listings")
        results = []
        page = 1

        # První request pro zjištění počtu inzerátů
        params = {"per_page": self.PER_PAGE, "page": page}
        async with httpx.AsyncClient() as client:
            response = await client.get(self.BASE_URL, params=params)
            response.raise_for_status()
            data = response.json()
            result_size = data.get('result_size', 0)
            total_pages = (result_size // self.PER_PAGE) + (1 if result_size % self.PER_PAGE else 0)
            # if max_pages:
            #     total_pages = min(total_pages, max_pages)
            # For testing purposes, limit max_pages to 2
            total_pages = min(total_pages, 2)

        # Stáhni všechny stránky
        for page in range(1, total_pages + 1):
            params = {"per_page": self.PER_PAGE, "page": page}
            async with httpx.AsyncClient() as client:
                response = await client.get(self.BASE_URL, params=params)
                response.raise_for_status()
                data = response.json()
                estates = data.get('_embedded', {}).get('estates', [])
                for estate in estates:
                    details = {
                        "id": estate.get('hash_id'),
                        "name": estate.get('name'),
                        "labelsAll": estate.get('labelsAll'),
                        "exclusively_at_rk": estate.get('exclusively_at_rk'),
                        "category": estate.get('category'),
                        "has_floor_plan": estate.get('has_floor_plan'),
                        "locality": estate.get('locality'),
                        "new": estate.get('new'),
                        "type": estate.get('type'),
                        "price": estate.get('price'),
                        "seo_category_main_cb": estate.get('seo', {}).get('category_main_cb'),
                        "seo_category_sub_cb": estate.get('seo', {}).get('category_sub_cb'),
                        "seo_category_type_cb": estate.get('seo', {}).get('category_type_cb'),
                        "seo_locality": estate.get('seo', {}).get('locality'),
                        "price_czk_value_raw": estate.get('price_czk', {}).get('value_raw'),
                        "price_czk_unit": estate.get('price_czk', {}).get('unit'),
                        "links_iterator_href": estate.get('_links', {}).get('iterator', {}).get('href'),
                        "links_self_href": estate.get('_links', {}).get('self', {}).get('href'),
                        "links_images": estate.get('_links', {}).get('images'),
                        "gps_lat": estate.get('gps', {}).get('lat'),
                        "gps_lon": estate.get('gps', {}).get('lon'),
                        "price_czk_alt_value_raw": estate.get('price_czk', {}).get('alt', {}).get('value_raw') if estate.get('price_czk', {}).get('alt') else None,
                        "price_czk_alt_unit": estate.get('price_czk', {}).get('alt', {}).get('unit') if estate.get('price_czk', {}).get('alt') else None,
                        "embedded_company_url": estate.get('_embedded', {}).get('company', {}).get('url'),
                        "embedded_company_id": estate.get('_embedded', {}).get('company', {}).get('id'),
                        "embedded_company_name": estate.get('_embedded', {}).get('company', {}).get('name'),
                        "embedded_company_logo_small": estate.get('_embedded', {}).get('company', {}).get('logo_small'),
                    }
                    results.append(details)
            self.logger.info(f"Fetched page {page}/{total_pages} ({len(estates)} estates)")

        # Uložení do JSON
        output_dir = self.output_paths.get("json", "data/json/")
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, "sreality_api_list.json")
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        self.logger.info(f"Výsledky uloženy do: {output_path}")

        return results