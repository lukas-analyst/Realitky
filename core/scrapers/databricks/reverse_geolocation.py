from pyspark.sql.types import StructType, StructField, StringType
import requests
import re
import sys
%run "../Scrapers/utils/scraper_statistics_update.ipynb"
%run "../Scrapers/utils/listings_update.ipynb"

# Define the schema for the DataFrame
schema = StructType([
    StructField("listing_id", StringType(), True),
    StructField("gps_coordinates", StringType(), True),
    StructField("street", StringType(), True),
    StructField("house_number", StringType(), True),
    StructField("city", StringType(), True),
    StructField("postcode", StringType(), True),
    StructField("state", StringType(), True),
    StructField("country", StringType(), True),
    StructField("lat", StringType(), True),
    StructField("lon", StringType(), True)
])

def parse_coordinates(gps_coordinates):
    """
    Parsuje různé formáty GPS souřadnic:
    - "49.123456,16.654321" - standardní formát
    - "49°12'34\"N,16°39'15\"E" - DMS formát
    - "[16.67782877304817, 49.18383426696714]" - JSON array
    - "[[lat,lon],[lat,lon],...]" - pole souřadnic (vezme první)
    """
    try:
        # Pokud obsahuje '[' - jedná se o JSON formát
        if '[' in gps_coordinates:
            import json
            coords_data = json.loads(gps_coordinates)
            
            # Pokud je to pole polí - vezmi první souřadnice
            if isinstance(coords_data[0], list):
                lat, lon = coords_data[0][:2]  # Vezmi první pár souřadnic
            else:
                # Jednoduché pole [lon, lat] nebo [lat, lon]
                lat, lon = coords_data[:2]
            
            # Ověř, že souřadnice jsou v rozumných mezích
            # Lon je obvykle první v OpenStreetMap formátu [lon, lat]
            if abs(lat) > 90 or abs(lon) > 180:
                # Prohodíme, pokud vypadá, že je to [lon, lat] místo [lat, lon]
                lat, lon = lon, lat
                
            return float(lat), float(lon)
            
        # DMS formát (stupně, minuty, sekundy)
        elif re.match(r"^\d+°\d+'\d+(\.\d+)?\"[NS],\d+°\d+'\d+(\.\d+)?\"[EW]$", gps_coordinates):
            dms_str = gps_coordinates.replace("°", " ").replace("'", " ").replace('"', " ")
            parts = dms_str.split()
            lat = float(parts[0]) + float(parts[1])/60 + float(parts[2])/3600
            if 'S' in dms_str:
                lat = -lat
            lon = float(parts[3]) + float(parts[4])/60 + float(parts[5])/3600
            if 'W' in dms_str:
                lon = -lon
            return lat, lon
            
        # Standardní formát "lat,lon"
        else:
            lat, lon = map(float, gps_coordinates.split(","))
            return lat, lon
            
    except (json.JSONDecodeError, ValueError, IndexError) as e:
        print(f"Error parsing GPS coordinates '{gps_coordinates}': {e}")
        return None, None

def reverse_geocode(lat, lon):
    url = "https://nominatim.openstreetmap.org/reverse"
    params = {"lat": lat, "lon": lon, "format": "json", "addressdetails": 1, "zoom": 18}
    headers = {"User-Agent": "realitky-bot"}
    resp = requests.get(url, params=params, headers=headers)
    if resp.status_code == 200:
        address = resp.json().get("address", {})
        return {
            "street": address.get("road"),
            "house_number": address.get("house_number"),
            "city": address.get("city") or address.get("town") or address.get("village"),
            "postcode": address.get("postcode"),
            "state": address.get("state"),
            "country": address.get("country"),
            "lat": lat,
            "lon": lon
        }
    return None


# for each do a reverse geocode
for scraper in scrapers:
    listing_ids_table = f"realitky.raw.listings_{scraper}"
    listing_details_table = f"realitky.raw.listing_details_{scraper}"

    listings_to_be_located = spark.sql(f"""
        SELECT 
            ldt.listing_id, 
            ldt.gps_coordinates 
        FROM {listing_details_table} ldt
            JOIN {listing_ids_table} lst
                ON ldt.listing_id = lst.listing_id 
                AND lst.located = false 
                AND lst.del_flag = false 
        WHERE
                ldt.gps_coordinates IS NOT null
                AND ldt.gps_coordinates NOT LIKE '%[%'
                AND ldt.del_flag = false
    """)

    results = []
    for row in listings_to_be_located.collect():
        lat, lon = parse_coordinates(row.gps_coordinates)
        
        # Přeskočíme záznamy, kde se nepodařilo parsovat souřadnice
        if lat is None or lon is None:
            print(f"Skipping listing {row.listing_id} - could not parse coordinates: {row.gps_coordinates}")
            continue
            
        address = reverse_geocode(lat, lon)
        if address:
            results.append({
                "listing_id": row.listing_id,
                "gps_coordinates": row.gps_coordinates,
                "street": address.get("street") or 'XNA',
                "house_number": address.get("house_number") or 'XNA',
                "city": address.get("city") or 'XNA',
                "postcode": address.get("postcode") or 'XNA',
                "state": address.get("state") or 'XNA',
                "country": address.get("country") or 'XNA',
                "lat": lat,
                "lon": lon
            })
    listings_located = spark.createDataFrame(results, schema)
    listings_located.createOrReplaceTempView("listings_located")

    spark.sql(f"""
        MERGE INTO realitky.cleaned.property AS target
        USING listings_located AS source
        ON target.property_id = source.listing_id
        AND target.src_web = '{scraper}'
        WHEN MATCHED THEN
        UPDATE SET
            target.address_street = source.street,
            target.address_house_number = source.house_number,
            target.address_city = source.city,
            target.address_postal_code = source.postcode,
            target.address_state = source.country,
            target.address_latitude = source.lat,
            target.address_longitude = source.lon,
            target.upd_dt = current_timestamp(),
            target.upd_process_id = '{process_id}'
    """)

    results_located = len(results)

    update_stats(scraper, 'located', results_located, process_id)
    update_listings(listing_ids_table, 'located', process_id)