import os
import asyncio
import yaml
import logging
from core.websites.remax_scraper import RemaxScraper
from core.websites.sreality_scraper import SrealityScraper
from core.websites.bezrealitky_scraper import BezrealitkyScraper
from core.websites.bidli_scraper import BidliScraper

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

    # Ensure the log folder exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)

    logging.basicConfig(
        level=log_level,
        format="%(asctime)s %(levelname)s %(message)s",
        filename=log_file,
        filemode="a"
    )
    logger = logging.getLogger("scraper")

    # Test mode
    test_mode = config.get("test_mode", {}).get("enabled", False)
    if test_mode:
        max_pages = config.get("test_mode", {}).get("max_pages", 2)
        per_page = config.get("test_mode", {}).get("per_page", 10)
        logger.info("=== TEST MODE: max_pages=%s, per_page=%s ===", max_pages, per_page)
    else:
        max_pages = config.get("scraper", {}).get("max_pages", 10)
        per_page = config.get("scraper", {}).get("per_page", 20)

    ## Run Remax scraper
    #logger.info("=== Starting Remax scraper ===")
    #remax_scraper = RemaxScraper(config, filters, output_paths, logger)
    #remax_scraper.pages = max_pages
    #remax_scraper.per_page = per_page
    #await remax_scraper.fetch_listings(max_pages=max_pages)
    #logger.info("=== Scraping Remax finished ===")
#
    ## Run Sreality scraper
    #logger.info("=== Starting Sreality scraper ===")
    #sreality_scraper = SrealityScraper(config, filters, output_paths, logger)
    #sreality_scraper.pages = max_pages
    #sreality_scraper.per_page = per_page
    #await sreality_scraper.fetch_listings(max_pages=max_pages)
    #logger.info("=== Scraping Sreality finished ===")
#
    ## Run Bezrealitky scraper
    #logger.info("=== Starting Bezrealitky scraper ===")
    #bezrealitky_scraper = BezrealitkyScraper(config, filters, output_paths, logger)
    #bezrealitky_scraper.pages = max_pages
    #bezrealitky_scraper.per_page = per_page
    #await bezrealitky_scraper.fetch_listings(max_pages=max_pages)
    #logger.info("=== Scraping BezRealitky finished ===")

    # Run Bidli scraper
    # logger.info("=== Starting Bidli scraper ===")
    # bidli_scraper = BidliScraper(config, filters, output_paths, logger)
    # bidli_scraper.pages = max_pages
    # bidli_scraper.per_page = per_page
    # await bidli_scraper.fetch_listings(max_pages=max_pages)
    # logger.info("=== Scraping Bidli finished ===")


if __name__ == "__main__":
    asyncio.run(main())