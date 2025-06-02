from urllib.parse import urlparse
import re

def extract_url_id(url: str, split_by: str = "/", sequence: int = -1, regex: str = None) -> str:
    """
    Extracts part of the URL split by 'split_by' and returns the part at 'sequence' index.
    Negative sequence means from the end (like Python lists).
    Example: extract_url_id("https://a/b/c/d", "/", -1) -> "d"
    If 'regex' is provided, it will search for the first match in the URL and return the matched group.

    :param url: str - The URL from which to extract the ID.
    :param split_by: str - The character to split the URL by (default is "/").
    :param sequence: int - The index of the part to return (default is -1, meaning the last part).
    :param regex: str - Optional regex pattern to search in the URL.
    :return str
    
    Returns the extracted ID or "unknown" if extraction fails.
    """
    try:
        if regex:
            match = re.search(regex, url)
            if match:
                return match.group(1)
        path = urlparse(url).path
        parts = [p for p in path.split(split_by) if p]
        if not parts:
            return "unknown"
        # Ošetření rozsahu
        if abs(sequence) > len(parts):
            return parts[-1]
        return parts[sequence]
    except Exception:
        return "unknown"