import os
import logging
from core.utils import save_scraped_data
from core.websites.remax_scrapper import RemaxScraper
#from websites.sreality_scrapper import SRealityScraper

# Nastavení logování
os.makedirs("logs", exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("logs/scrapper.log", mode="w", encoding="utf-8"),
        logging.StreamHandler()  # Logy se budou zobrazovat i v konzoli
    ]
)
logger = logging.getLogger("scrapper")


async def run_scrapers():
    """
    Spustí všechny scrapery a uloží data do jednotlivých souborů.
    """
    scrapers = [
        {"scraper": RemaxScraper(location="praha"), "source_web": "remax", "max_pages": 2},
        #{"scraper": SRealityScraper(location="brno"), "source_web": "sreality", "max_pages": 3},  # Příklad dalšího scraperu
    ]

    for scraper_config in scrapers:
        scraper = scraper_config["scraper"]
        source_web = scraper_config["source_web"]
        max_pages = scraper_config["max_pages"]

        logger.info(f"Starting scraper for {source_web} in location: {scraper.location}")
        listings = await scraper.fetch_listings(max_pages=max_pages)
        logger.info(f"Scrapped {len(listings)} listings from {source_web}")

        # Uložit data do souboru specifického pro zdrojový web
        save_scraped_data(listings, source_web=source_web)
        logger.info(f"Data from {source_web} saved to {source_web}_listings.csv")
