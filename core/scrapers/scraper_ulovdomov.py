import httpx
import json
import asyncio
from pyspark.sql.types import StructType, StructField, StringType

class UlovdomovScraper:
    def __init__(self):
        self.base_api_url = "https://ud.api.ulovdomov.cz/v1/offer/find"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 OPR/120.0.0.0',
            'Accept': '*/*',
            'Accept-Language': 'cs,en;q=0.9,sk;q=0.8,zh-CN;q=0.7,zh;q=0.6,de;q=0.5,hu;q=0.4',
            'Accept-Encoding': 'gzip, deflate, br, zstd',
            'Authorization': 'Bearer',
            'Content-Type': 'application/json',
            'DNT': '1',
            'Origin': 'https://www.ulovdomov.cz',
            'Referer': 'https://www.ulovdomov.cz/',
            'Sec-CH-UA': '"Opera";v="120", "Not-A.Brand";v="8", "Chromium";v="135"',
            'Sec-CH-UA-Mobile': '?0',
            'Sec-CH-UA-Platform': '"Windows"',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'same-site',
        }
    
    async def scrap_listings(self, max_pages=None, per_page=None, offer_types=None):
        # Nastavení výchozích hodnot
        if per_page is None:
            per_page = 20
        if offer_types is None:
            offer_types = ["sale", "rent"]  # Výchozí: prodej i pronájem
        
        all_listings = []
        
        for offer_type in offer_types:
            print(f"Scraping offer type: {offer_type}")
            listings = await self._scrap_offer_type(offer_type, max_pages, per_page)
            all_listings.extend(listings)
        
        return all_listings
    
    async def _scrap_offer_type(self, offer_type, max_pages, per_page):
        listings = []
        page = 1
        
        async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
            # První požadavek pro zjištění celkového počtu stránek
            total_pages = await self._get_total_pages(client, per_page, offer_type)
            if total_pages is None:
                return []
            
            # Určení maximálního počtu stránek
            if max_pages is None:
                max_pages = total_pages
            else:
                max_pages = min(max_pages, total_pages)
            
            print(f"Maximum pages: {max_pages}")
            
            while page <= max_pages:
                url = f"{self.base_api_url}?page={page}&perPage={per_page}&sorting=latest"
                print(f"Fetching listings for url: {url}")
                
                payload = {
                    "bounds": {
                        "northEast": {"lat": 52.95525697845468, "lng": 19.193115234375004},
                        "southWest": {"lat": 46.4605655457854, "lng": 11.755371093750002}
                    },
                    "offerType": offer_type
                }
                
                print(f"Fetching page {page}")
                
                try:
                    response = await client.post(url, json=payload, headers=self.headers)
                    response.raise_for_status()
                    data = response.json()
                    
                    if not data.get('success', False):
                        break
                    
                    page_listings = data.get('data', {}).get('offers', [])
                    if not page_listings:
                        break
                    
                    print(f"Found {len(page_listings)} listings on page {page}")
                    
                    # Extrahuj pouze požadované informace
                    for listing in page_listings:
                        listings.append({
                            "listing_id": listing.get('id'),
                            "listing_url": listing.get('absoluteUrl'),
                            "gps_coordinates" : listing.get('geoCoordinates', {})
                        })
                    
                    # Kontrola, zda jsme na konci
                    extra_data = data.get('extraData', {})
                    current_page = extra_data.get('currentPage', page)
                    if current_page >= total_pages:
                        print(f"Reached the last page: {current_page}")
                        break
                    
                    page += 1
                    await asyncio.sleep(1.0)  # Rate limiting
                    
                except Exception as e:
                    break
        
        return listings
    
    async def _get_total_pages(self, client, per_page, offer_type):
        """Získá celkový počet stránek z prvního požadavku."""
        url = f"{self.base_api_url}?page=1&perPage={per_page}&sorting=latest"
        payload = {
            "bounds": {
                "northEast": {"lat": 52.95525697845468, "lng": 19.193115234375004},
                "southWest": {"lat": 46.4605655457854, "lng": 11.755371093750002}
            },
            "offerType": offer_type
        }
        
        try:
            response = await client.post(url, json=payload, headers=self.headers)
            response.raise_for_status()
            data = response.json()
            
            if data.get('success', False):
                extra_data = data.get('extraData', {})
                return extra_data.get('totalPages', 0)
        except Exception:
            pass
        
        return None

# Použití:
scraper = UlovdomovScraper()

# Možné způsoby volání:
# listings = await scraper.scrap_listings()  # Vše (prodej i pronájem)
# listings = await scraper.scrap_listings(max_pages=5)  # Pouze 5 stránek z obou typů
# listings = await scraper.scrap_listings(max_pages=3, per_page=20, offer_types=["sale"])  # Pouze prodej
# listings = await scraper.scrap_listings(max_pages=3, per_page=20, offer_types=["rent"])  # Pouze pronájem
# listings = await scraper.scrap_listings(max_pages=3, per_page=20, offer_types=["sale", "rent"])  # Oba typy

listings = await scraper.scrap_listings(max_pages=2, per_page=20)
print(f"Total results: {len(listings)}")

# Vytvoření Spark DataFrame
schema = StructType([
    StructField("listing_id", StringType(), True),
    StructField("listing_url", StringType(), True)
])

df_listings = spark.createDataFrame(listings, schema=schema)