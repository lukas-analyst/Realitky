import os
import pandas as pd
import asyncio
import logging
from core.scrapper import run_scrapers
from core.data_manager import upsert_to_main_data

# Nastavení logování
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("logs/main.log", mode="w", encoding="utf-8"),
        logging.StreamHandler()  # Logy se budou zobrazovat i v konzoli
    ]
)
logger = logging.getLogger("main")


def update_main_data():
    """
    Aktualizuje hlavní datový soubor na základě dat z jednotlivých webů.
    """
    source_webs = ["remax", "sreality"]  # Přidat další weby podle potřeby
    main_file = "main_data_raw.csv"

    # Inicializovat hlavní datový soubor, pokud neexistuje
    if not os.path.exists(main_file):
        pd.DataFrame(columns=["ID", "src_web", "ins_dt", "upd_dt", "del_flag"]).to_csv(main_file, index=False)

    for source_web in source_webs:
        logger.info(f"Updating main data for source: {source_web}")
        upsert_to_main_data(source_web=source_web, main_file=main_file)
        logger.info(f"Main data updated for source: {source_web}")


async def main():
    """
    Hlavní funkce, která spustí scraping a aktualizaci hlavního datového souboru.
    """
    # Spustit scrapery
    await run_scrapers()

    # Aktualizovat hlavní datový soubor
    update_main_data()


if __name__ == "__main__":
    asyncio.run(main())