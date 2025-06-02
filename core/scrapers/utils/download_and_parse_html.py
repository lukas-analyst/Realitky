import httpx
from selectolax.parser import HTMLParser
from core.scrapers.utils.save_html import save_html

async def download_and_parse_html(url: str, save_dir: str, save_name: str) -> HTMLParser:
    """
    Downloads HTML content from the given URL and saves it to a specified directory.
    
    :param url: The URL to download the HTML from.
    :param save_dir: The directory where the HTML file will be saved.
    :param save_name: The name of the file to save the HTML content as.
    :return: An HTMLParser object containing the parsed HTML content.
    """
    async with httpx.AsyncClient(follow_redirects=True) as client:
        response = await client.get(url)
        response.raise_for_status()
    await save_html(response.text, save_dir, save_name)
    return HTMLParser(response.text)