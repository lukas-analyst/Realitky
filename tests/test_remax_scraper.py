import unittest
import asyncio
from core.websites.remax_scraper import RemaxScraper

class DummyLogger:
    def info(self, msg, *args): pass
    def warning(self, msg, *args): pass
    def error(self, msg, *args): pass

class TestRemaxScraper(unittest.IsolatedAsyncioTestCase):
    async def test_init_and_attrs(self):
        config = {"scraper": {"per_page": 2, "max_pages": 1}}
        filters = {}
        output_paths = {}
        logger = DummyLogger()
        scraper = RemaxScraper(config, filters, output_paths, logger)
        self.assertEqual(scraper.per_page, 2)
        self.assertEqual(scraper.pages, 1)

    # Další testy lze přidat podle potřeby

if __name__ == "__main__":
    unittest.main()