import pytest
import asyncio
from core.websites.sreality_scraper import SrealityScraper

class DummyLogger:
    def info(self, msg, *args): pass
    def warning(self, msg, *args): pass
    def error(self, msg, *args): pass

@pytest.mark.asyncio
async def test_fetch_page_returns_estates():
    config = {"scraper": {"per_page": 2, "max_pages": 1}}
    filters = {}
    output_paths = {}
    logger = DummyLogger()
    scraper = SrealityScraper(config, filters, output_paths, logger)
    estates = await scraper.fetch_page(1)
    assert isinstance(estates, list)
    assert len(estates) > 0

@pytest.mark.asyncio
async def test_fetch_detail_410(monkeypatch):
    config = {"scraper": {"per_page": 2, "max_pages": 1}}
    filters = {}
    output_paths = {}
    logger = DummyLogger()
    scraper = SrealityScraper(config, filters, output_paths, logger)

    class DummyResponse:
        status_code = 410
        def raise_for_status(self): raise Exception("410 Gone")

    async def dummy_get(*args, **kwargs):
        class DummyClient:
            async def __aenter__(self): return self
            async def __aexit__(self, exc_type, exc, tb): pass
            async def get(self, *a, **kw): return DummyResponse()
        return DummyClient()

    monkeypatch.setattr("httpx.AsyncClient", dummy_get)
    result = await scraper.fetch_detail("fake_id")
    assert result is None