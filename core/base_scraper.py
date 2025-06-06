import abc

class BaseScraper(abc.ABC):
    """
    Abstraktní třída pro všechny scrapery.
    """

    def __init__(self, config, filters, output_paths, logger):
        self.config = config
        self.location = filters.get("location", None)
        self.property_type = filters.get("property_type", None)
        self.mode = filters.get("mode", None)
        self.filters = filters
        self.output_paths = output_paths
        self.logger = logger

    @abc.abstractmethod
    async def fetch_listings(self, max_pages: int = None, per_page: int = None):
        """
        Stáhne seznam nemovitostí dle filtrů.
        """
        pass

    @abc.abstractmethod
    async def fetch_property_details(self, url: str) -> dict:
        """
        Stáhne detaily konkrétní nemovitosti.
        """
        pass

    @abc.abstractmethod
    async def download_images(self, property_id: str, image_urls: list):
        """
        Stáhne obrázky nemovitosti.
        """
        pass