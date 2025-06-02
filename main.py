import os
import asyncio
import yaml
import logging
from core.scrapers.scraper_remax import RemaxScraper
from core.scrapers.scraper_sreality import SrealityScraper
from core.scrapers.scraper_bezrealitky import BezrealitkyScraper
from core.scrapers.scraper_bidli import BidliScraper
from core.scrapers.scraper_century21 import Century21Scraper
from core.scrapers.scraper_idnes import idnesScraper

def load_config():
    with open("config/settings.yaml", "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

async def main():
    config = load_config()
    filters = config.get("filters") # location, propery_type, mode
    output_paths = config.get("paths") # html, csv, json, raw
    logging_config = config.get("logging") # file, level
    log_file = logging_config.get("file")
    log_level = getattr(logging, logging_config.get("level"), logging.INFO)
    # Load test mode settings
    test_mode = config.get("test_mode", {})
    if test_mode.get("enabled", False):
        max_pages = test_mode.get("max_pages")
        per_page = test_mode.get("per_page")
    else:
        max_pages = None
        per_page = None

    # Ensure the log folder exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)

    logging.basicConfig(
        level=log_level,
        format="%(asctime)s %(levelname)s %(message)s",
        filename=log_file,
        filemode="a"
    )
    logger = logging.getLogger("scraper")

    # Run Remax scraper
    logger.info("=== Starting Remax scraper ===")
    remax_scraper = RemaxScraper(config, filters, output_paths, logger)
    remax_scraper.pages = max_pages
    remax_scraper.per_page = per_page
    await remax_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping Remax finished ===")
#
    # Run Sreality scraper
    logger.info("=== Starting Sreality scraper ===")
    sreality_scraper = SrealityScraper(config, filters, output_paths, logger)
    sreality_scraper.pages = max_pages
    sreality_scraper.per_page = per_page
    await sreality_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping Sreality finished ===")

    # Run Bezrealitky scraper
    logger.info("=== Starting Bezrealitky scraper ===")
    bezrealitky_scraper = BezrealitkyScraper(config, filters, output_paths, logger)
    bezrealitky_scraper.pages = max_pages
    bezrealitky_scraper.per_page = per_page
    await bezrealitky_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping BezRealitky finished ===")

    # Run Bidli scraper
    logger.info("=== Starting Bidli scraper ===")
    bidli_scraper = BidliScraper(config, filters, output_paths, logger)
    bidli_scraper.pages = max_pages
    bidli_scraper.per_page = per_page
    await bidli_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping Bidli finished ===")

    # Run Century21 scraper
    logger.info("=== Starting Century21 scraper ===")
    century21_scraper = Century21Scraper(config, filters, output_paths, logger)
    century21_scraper.pages = max_pages
    century21_scraper.per_page = per_page
    await century21_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping Century21 finished ===")   

    # Run idnesReality scraper
    logger.info("=== Starting idnesReality scraper ===")
    idnes_scraper = idnesScraper(config, filters, output_paths, logger)
    idnes_scraper.pages = max_pages
    idnes_scraper.per_page = per_page
    await idnes_scraper.fetch_listings(max_pages=max_pages)
    logger.info("=== Scraping idnesReality finished ===")

if __name__ == "__main__":
    asyncio.run(main())