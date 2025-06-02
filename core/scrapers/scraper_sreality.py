import asyncio
import httpx
from core.scrapers.utils.save_to_csv import save_to_csv
from core.scrapers.utils.save_to_json import save_to_json
from core.scrapers.utils.save_raw_to_postgres import save_raw_to_postgres

class SrealityScraper:
    BASE_URL = "https://www.sreality.cz/api/cs/v2/estates"
    DETAIL_URL = "https://www.sreality.cz/api/cs/v2/estates/{}"
    NAME = "sreality"

    def __init__(self, config, filters, output_paths, logger):
        self.per_page = config.get("scraper", {}).get("per_page", 10)
        self.pages = config.get("scraper", {}).get("max_pages", 2)
        self.output_paths = output_paths
        self.logger = logger

    async def fetch_page(self, page):
        params = {"per_page": self.per_page, "page": page}
        async with httpx.AsyncClient() as client:
            response = await client.get(self.BASE_URL, params=params)
            response.raise_for_status()
            data = response.json()
            return data.get('_embedded', {}).get('estates', [])

    async def fetch_detail(self, hash_id):
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(self.DETAIL_URL.format(hash_id))
                response.raise_for_status()
                return response.json()
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 410:
                self.logger.warning(f"Listing {hash_id} was removed (410 Gone). Skipping.")
            else:
                self.logger.error(f"HTTP error while downloading detail {hash_id}: {e}")
        except Exception as e:
            self.logger.error(f"General error while downloading detail {hash_id}: {e}")
        return None

    async def fetch_listings(self, max_pages=None):
        pages = max_pages or self.pages
        self.logger.info("Starting to download the list of properties from Sreality API...")
        all_estates = []
        for page in range(1, pages + 1):
            estates = await self.fetch_page(page)
            self.logger.info(f"Page {page}: {len(estates)} properties")
            all_estates.extend(estates)
        self.logger.info(f"Total found {len(all_estates)} properties on {pages} pages.")

        if not all_estates:
            self.logger.warning("No properties found, script is ending.")
            return

        self.logger.info("Downloading details of all properties...")
        tasks = [self.fetch_detail(estate["hash_id"]) for estate in all_estates]
        final_data = []
        for estate, detail in zip(all_estates, await asyncio.gather(*tasks)):
            if detail is not None:
                detail["id"] = estate["hash_id"]
                final_data.append(detail)
        self.logger.info(f"Downloaded details: {len(final_data)}")

        # Save to CSV
        csv_path = self.output_paths.get("csv", "data/raw/csv/sreality")
        save_to_csv(final_data, csv_path, self.NAME, True)
        # Save to JSON
        json_dir = self.output_paths.get("json", "data/raw/json/sreality")
        save_to_json(final_data, json_dir, self.NAME, True)
        # Save to PostgreSQL
        save_raw_to_postgres(final_data, self.NAME, "id")

        self.logger.info("Sreality scraper finished successfully.")