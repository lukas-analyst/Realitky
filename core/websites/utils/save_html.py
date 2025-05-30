import os
import aiofiles

async def save_html(content: str, output_dir: str, filename: str):
    """
    Asynchronously saves HTML content to the specified directory and file.

    :param content: HTML content to save.
    :param output_dir: Path to the directory where the file should be saved.
    :param filename: Name of the file to save the content to.
    """
    os.makedirs(output_dir, exist_ok=True)
    async with aiofiles.open(os.path.join(output_dir, filename), "w", encoding="utf-8") as f:
        await f.write(content)