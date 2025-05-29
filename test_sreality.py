import json
import sys
import os
import logging
import httpx
from selectolax.parser import HTMLParser

def extract_next_data_json(html: str, logger) -> dict:
    parser = HTMLParser(html)
    script = parser.css_first('script#__NEXT_DATA__')
    if not script:
        logger.error("Nenalezen script#__NEXT_DATA__")
        return {}

    try:
        data = json.loads(script.text())
        return data
    except Exception as e:
        logger.error(f"Chyba při načítání JSON: {e}")
        return {}

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[logging.StreamHandler()]
    )
    logger = logging.getLogger("sreality_json_extract")

    # Pokud je zadán argument, použijeme lokální HTML, jinak stáhneme z webu
    if len(sys.argv) > 1:
        html_path = sys.argv[1]
        logger.info(f"Načítám HTML ze souboru: {html_path}")
        with open(html_path, "r", encoding="utf-8") as f:
            html = f.read()
    else:
        url = "https://www.sreality.cz/hledani/prodej"
        logger.info(f"Stahuji HTML z webu: {url}")
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
        }
        with httpx.Client(headers=headers, follow_redirects=True) as client:
            response = client.get(url)
            response.raise_for_status()
            html = response.text

    # Uložení celého __NEXT_DATA__ JSON do souboru
    data = extract_next_data_json(html, logger)
    if data:
        output_dir = os.path.join(os.path.dirname(__file__), "data/json/")
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, "sreality_next_data.json")
        with open(output_path, "w", encoding="utf-8") as out_f:
            json.dump(data, out_f, ensure_ascii=False, indent=2)
        logger.info(f"Uloženo do: {output_path}")
    else:
        logger.warning("JSON nebyl extrahován.")