import hashlib

def hash_listing(details: dict):
    """
    Create a SHA-256 hash of the listing details.
    
    :param details: Dictionary containing property details.
    :return: SHA-256 hash of the details as a hexadecimal string.
    """
    return hashlib.sha256(str(details).encode("utf-8")).hexdigest()
