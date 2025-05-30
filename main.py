import os
import asyncio
import yaml
import logging
from core.websites.remax_scraper import RemaxScraper
from core.websites.sreality_scraper import SrealityScraper

def load_config():
    with open("config/settings.yaml", "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

async def main():
    config = load_config()
    filters = config.get("filters", {})
    output_paths = config.get("paths", {})
    logging_config = config.get("logging", {})
    log_file = logging_config.get("file", "logs/scraper.log")
    log_level = getattr(logging, logging_config.get("level", "INFO").upper(), logging.INFO)

    # Zajisti existenci složky pro logy
    os.makedirs(os.path.dirname(log_file), exist_ok=True)

    logging.basicConfig(
        level=log_level,
        format="%(asctime)s %(levelname)s %(message)s",
        filename=log_file,
        filemode="a"
    )
    logger = logging.getLogger("scraper")

    # Testovací režim
    test_mode = config.get("test_mode", {}).get("enabled", False)
    if test_mode:
        max_pages = config.get("test_mode", {}).get("max_pages", 2)
        per_page = config.get("test_mode", {}).get("per_page", 10)
        logger.info("=== TESTOVACÍ REŽIM: max_pages=%s, per_page=%s ===", max_pages, per_page)
    else:
        max_pages = config.get("scraper", {}).get("max_pages", 10)
        per_page = config.get("scraper", {}).get("per_page", 20)

    # Spuštění Remax scraperu
    logger.info("=== Spouštím Remax scraper ===")
    remax_scraper = RemaxScraper(config, filters, output_paths, logger)
    remax_scraper.pages = max_pages
    remax_scraper.per_page = per_page
    await remax_scraper.fetch_listings(max_pages=max_pages)

    # Spuštění Sreality scraperu
    logger.info("=== Spouštím Sreality scraper ===")
    sreality_scraper = SrealityScraper(config, filters, output_paths, logger)
    sreality_scraper.pages = max_pages
    sreality_scraper.per_page = per_page
    await sreality_scraper.fetch_listings(max_pages=max_pages)

if __name__ == "__main__":
    asyncio.run(main())