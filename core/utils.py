import os
import aiofiles
import aiohttp
import asyncio

async def download_image(session, url, img_path):
    try:
        async with session.get(url) as resp:
            if resp.status == 200:
                async with aiofiles.open(img_path, "wb") as f:
                    await f.write(await resp.read())
    except Exception as e:
        print(f"Chyba při stahování obrázku {url}: {e}")

async def save_images(property_id: str, image_urls: list, base_dir: str):
    prop_dir = os.path.join(base_dir, property_id)
    os.makedirs(prop_dir, exist_ok=True)
    async with aiohttp.ClientSession() as session:
        tasks = []
        for idx, url in enumerate(image_urls):
            img_path = os.path.join(prop_dir, f"image_{idx+1}.jpg")
            tasks.append(download_image(session, url, img_path))
        await asyncio.gather(*tasks)

# Funkce pro extrakci detailů z kontejneru pomocí CSS selektorů
def extract_details(container, row_selector, label_selector, value_selector):
    """Extrahuje detaily z daného kontejneru."""
    details = {}
    rows = container.css(row_selector)
    for row in rows:
        label_element = row.css_first(label_selector)
        value_element = row.css_first(value_selector)
        if label_element and value_element:
            label = label_element.text(strip=True).rstrip(":")
            value = value_element.text(strip=True)
            details[label] = value
    return details