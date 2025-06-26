import requests
import time

def reverse_geocode(lat, lon):
    url = f"https://nominatim.openstreetmap.org/reverse"
    params = {
        "lat": lat,
        "lon": lon,
        "format": "json",
        "addressdetails": 1,
        "zoom": 18
    }
    headers = {"User-Agent": "realitky-bot"}
    resp = requests.get(url, params=params, headers=headers)
    if resp.status_code == 200:
        data = resp.json()
        address = data.get("address", {})
        return {
            "street": address.get("road"),
            "house_number": address.get("house_number"),
            "city": address.get("city") or address.get("town") or address.get("village"),
            "postcode": address.get("postcode"),
            "state": address.get("state"),
            "country": address.get("country"),
            "ruian_code": None  # zde doplníš z dalšího kroku
        }
    else:
        return None

# Příklad použití:
lat, lon = 50.068979010553, 15.749180482254
adresa = reverse_geocode(lat, lon)
print(adresa)
time.sleep(1)  # respektuj limity API!