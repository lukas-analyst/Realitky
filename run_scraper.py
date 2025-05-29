import asyncio
import yaml
import logging
from core.websites.remax_scraper import RemaxScraper

def load_config():
    with open("config/settings.yaml", "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

async def main():
    config = load_config()
    filters = config.get("filters", {})
    output_paths = config.get("paths", {})
    logger = logging.getLogger("scraper")
    logging.basicConfig(level=logging.INFO)

    # Zde lze dynamicky načítat scrapery podle configu
    scraper = RemaxScraper(config, filters, output_paths, logger)
    await scraper.fetch_listings(max_pages=config["scraper"].get("max_pages"))

if __name__ == "__main__":
    asyncio.run(main())