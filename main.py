import os
import asyncio
import logging
from config.load_config import load_config
from core.scrapers.scraper_remax import RemaxScraper
from core.scrapers.scraper_sreality import SrealityScraper
from core.scrapers.scraper_bezrealitky import BezrealitkyScraper
from core.scrapers.scraper_bidli import BidliScraper
from core.scrapers.scraper_century21 import Century21Scraper
from core.scrapers.scraper_idnes import idnesScraper

CONFIG = load_config()

# Logging - get configuration from config.yaml (if true, logging_level, logging_file)
if CONFIG.get('logging', True):
    logging.basicConfig(
        level=CONFIG.get('logging_level', 'INFO').upper(),
        format='%(asctime)s %(levelname)s: %(message)s',
        handlers=[
            logging.FileHandler(CONFIG.get('logging_file'), encoding='utf-8'),
            # logging.StreamHandler()
        ]
    )
else:
    logging.basicConfig(level=logging.CRITICAL)
    

async def main():
    filters_config = CONFIG.get("filters") # location, propery_type, mode
    scraper_config = CONFIG.get("scraper") # config for scraping (images, user_agent, parallelism)
    output_config = CONFIG.get("output") # config for output (html, csv, json, postgres)

    # Load test mode settings
    test_mode = CONFIG.get("test_mode")
    if test_mode.get("enabled"):
        logging.info("=== Test mode enabled ===")
        max_pages = test_mode.get("max_pages")
        per_page = test_mode.get("per_page")
        logging.info(f"Max pages: {max_pages}, Per page: {per_page}")
    else:
        max_pages = None
        per_page = None


    # Run Remax scraper
    if CONFIG.get("remax"):
        remax_scraper = RemaxScraper(filters_config, scraper_config, output_config, max_pages, per_page)
        await remax_scraper.fetch_listings(max_pages=max_pages)
#
    # Run Sreality scraper
    if CONFIG.get("sreality"):
        sreality_scraper = SrealityScraper(filters_config, scraper_config, output_config)
        sreality_scraper.pages = max_pages
        sreality_scraper.per_page = per_page
        await sreality_scraper.fetch_listings(max_pages=max_pages)

    # Run Bezrealitky scraper
    if CONFIG.get("bezrealitky"):
        bezrealitky_scraper = BezrealitkyScraper(filters_config, scraper_config)
        bezrealitky_scraper.pages = max_pages
        bezrealitky_scraper.per_page = per_page
        await bezrealitky_scraper.fetch_listings(max_pages=max_pages)

    # Run Bidli scraper
    if CONFIG.get("bidli"):
        bidli_scraper = BidliScraper(filters_config, scraper_config)
        bidli_scraper.pages = max_pages
        bidli_scraper.per_page = per_page
        await bidli_scraper.fetch_listings(max_pages=max_pages)

    # Run Century21 scraper
    if CONFIG.get("century21"):
        century21_scraper = Century21Scraper(filters_config, scraper_config)
        century21_scraper.pages = max_pages
        century21_scraper.per_page = per_page
        await century21_scraper.fetch_listings(max_pages=max_pages)

    # Run idnesReality scraper
    if CONFIG.get("idnes"):
        idnes_scraper = idnesScraper(filters_config, scraper_config)
        idnes_scraper.pages = max_pages
        idnes_scraper.per_page = per_page
        await idnes_scraper.fetch_listings(max_pages=max_pages)

if __name__ == "__main__":
    asyncio.run(main())