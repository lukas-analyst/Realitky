import hashlib

def hash_listing(details: dict):
    """Vytvoří hash z detailů nemovitosti."""
    return hashlib.sha256(str(details).encode("utf-8")).hexdigest()
