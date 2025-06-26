import requests
import dotenv

dotenv.load_dotenv()

def get_ruian(address_dict):
    """
    Get RUIAN code from address dictionary using FNX RUIAN API.
    Input: address_dict (dict)
    Output: RUIAN code (string) or None if not found.
    """
    api_key = dotenv.get_key(dotenv.find_dotenv(), "RUIAN_API_KEY")
    params = {
        "apiKey": api_key,
        "municipalityName": address_dict.get("village") or address_dict.get("city") or address_dict.get("town"),
        "municipalityPartName": address_dict.get("municipality_part") or address_dict.get("municipality_part_name"),
        "zip": address_dict.get("postcode"),
        "street": address_dict.get("street") or address_dict.get("address_street"),
        "cp": address_dict.get("house_number"),
        "co": address_dict.get("orientation_number"),
        "ce": address_dict.get("registration_number"),
        "municipalityId": address_dict.get("municipality_id"),
        "municipalityPartId": address_dict.get("municipality_part_id"),
        "ruianId": address_dict.get("ruian_id"),
    }
    params = {k: v for k, v in params.items() if v}

    url = "https://ruian.fnx.io/api/v1/ruian/validate"
    resp = requests.get(url, params=params)
    if resp.status_code == 200:
        data = resp.json()
        return data
    return None