import hashlib
import json

def hash_details(details: dict) -> str:
    """
    Create a SHA-256 hash of the property details, excluding URL and listing_hash.

    :param details: Dictionary containing property details.
    :return: SHA-256 hash of the details as a hexadecimal string.
    """
    hash_input = {k: v for k, v in details.items() if k not in ["URL", "listing_hash"]}
    return hashlib.sha256(
        json.dumps(hash_input, sort_keys=True, ensure_ascii=False).encode("utf-8")
    ).hexdigest()