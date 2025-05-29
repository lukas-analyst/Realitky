import asyncio
import yaml
import logging
import pandas as pd
import os
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

    # Nastavte location podle configu nebo natvrdo pro test
    scraper = RemaxScraper(config, filters, output_paths, logger)
    scraper.location = filters.get("location", "Liberec")    

    # Test na prvních 2 stránkách
    results = await scraper.fetch_listings(max_pages=2) # počet stránek pro testování
    print(f"Staženo {len(results)} nemovitostí.")

    # Uložení do CSV podle configu
    web_name = scraper.__class__.__name__.replace("Scraper", "").lower()
    csv_dir = os.path.dirname(config["output"]["csv_path"])
    os.makedirs(csv_dir, exist_ok=True)
    csv_path = os.path.join(csv_dir, f"{web_name}.csv")

    if results:
        df = pd.DataFrame(results)
        df.to_csv(csv_path, index=False, encoding="utf-8")
        print(f"Výsledky uloženy do {csv_path}")
    else:
        print("Žádná data ke stažení.")

if __name__ == "__main__":
    asyncio.run(main())