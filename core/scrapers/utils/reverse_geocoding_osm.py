import requests
import re

def dms_to_decimal(dms_coordionates):
    """
    Convert DMS (degrees, minutes, seconds) string to decimal degrees.
    Example input: 49°37'12.7"N,18°13'07.2"E
    """
    
    def parse_part(part):
        match = re.match(r"(\d+)°(\d+)'([\d\.]+)\"?([NSEW])", part.strip())
        if not match:
            raise ValueError(f"Invalid DMS format: {part}")
        deg, min_, sec, direction = match.groups()
        dec = float(deg) + float(min_) / 60 + float(sec) / 3600
        if direction in ['S', 'W']:
            dec = -dec
        return dec

    lat_str, lng_str = dms_coordionates.split(",")
    lat = parse_part(lat_str)
    lng = parse_part(lng_str)
    return lat, lng

def reverse_geocoding_osm(lat, lng):
    """
    Reverse geocode DMS coordinates using OSM Nominatim API.
    Input: string in DMS format, e.g. '49°37\'12.7"N,18°13\'07.2"E'
    Output: dict with address or None
    """
    
    url = "https://nominatim.openstreetmap.org/reverse"
    headers = {"User-Agent": "realitky-bot"}
    params = {
        "lat": lat,
        "lon": lng,
        "format": "json",
        "addressdetails": 1,
        "zoom": 18
    }

    resp = requests.get(url, params=params, headers=headers)
    if resp.status_code == 200:
        data = resp.json()
        return data.get("address", {})
    else:
        return None