import requests
from bs4 import BeautifulSoup
from ..models import Property

class SrealityScraper:
    BASE_URL = "https://www.sreality.cz"

    def __init__(self, location: str, property_type: str, limit: int = 10):
        self.location = location
        self.property_type = property_type
        self.limit = limit

    def fetch_listings(self):
        url = f"{self.BASE_URL}/hledani/prodej/{self.property_type}/{self.location}"
        response = requests.get(url)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "lxml")
        listings = soup.find_all("div", class_="property")[:self.limit]

        results = []
        for listing in listings:
            title = listing.find("span", class_="name").text.strip()
            price = listing.find("span", class_="price").text.strip()
            link = self.BASE_URL + listing.find("a")["href"]
            results.append(Property(title=title, price=price, link=link))

        return results