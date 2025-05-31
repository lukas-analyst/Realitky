# Get code from local .html file 
# Find GPS coordinates in __NEXT_DATA__ script tag
import json
import logging
from selectolax.parser import HTMLParser


# Nastav logger
logger = logging.getLogger("test_gps")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

# Path to the HTML file
html_file_path = 'data/raw/html/bezrealitky/bezrealitky_883696.html'
# Read the HTML content from the file
with open(html_file_path, 'r', encoding='utf-8') as file:
    html_content = file.read()
# Parse the HTML content
parser = HTMLParser(html_content)

details = {}

next_data_script = parser.css_first('script#__NEXT_DATA__')
if next_data_script:
    logger.info("Found __NEXT_DATA__ script tag.")
    try:
        script_text = next_data_script.text()
        logger.info(f"First 500 chars of __NEXT_DATA__ script: {script_text[:500]}")
        data = json.loads(script_text)
        logger.info(f"Top-level keys in __NEXT_DATA__: {list(data.keys())}")
        page_props = data.get("props", {}).get("pageProps", {})
        logger.info(f"Keys in pageProps: {list(page_props.keys())}")
        # Zjisti, co je v origAdvert
        if "origAdvert" in page_props:
            logger.info(f"Keys in origAdvert: {list(page_props['origAdvert'].keys())}")
            logger.info(f"Sample origAdvert: {json.dumps(page_props['origAdvert'])[:1000]}")
        # Pokud je tam advert, vypiš jeho klíče
        if "advert" in page_props:
            logger.info(f"Keys in advert: {list(page_props['advert'].keys())}")
        # Vypiš část pageProps pro ruční kontrolu
        logger.info(f"Sample pageProps: {json.dumps(page_props)[:1000]}")
        gps = data.get("props", {}) \
                  .get("pageProps", {}) \
                  .get("advert", {}) \
                  .get("gps", {})
        logger.info(f"Extracted gps object: {gps}")
        lat = gps.get("lat")
        lng = gps.get("lng")
        if lat is not None and lng is not None:
            details["GPS coordinates"] = f"{lat},{lng}"
        else:
            details["GPS coordinates"] = "N/A"
        # Zkus najít GPS v origAdvert
        gps = page_props.get("origAdvert", {}).get("gps", {})
        logger.info(f"Extracted gps object from origAdvert: {gps}")
        lat = gps.get("lat")
        lng = gps.get("lng")
        if lat is not None and lng is not None:
            details["GPS coordinates"] = f"{lat},{lng}"
        else:
            details["GPS coordinates"] = "N/A"
    except Exception as e:
        logger.error(f"Error parsing GPS from __NEXT_DATA__: {e}")
        details["GPS coordinates"] = "N/A"
else:
    logger.warning("No __NEXT_DATA__ script tag found!")
    details["GPS coordinates"] = "N/A"

print(details)
