# Databricks notebook source
# MAGIC %md
# MAGIC ## Notebook Configuration
# MAGIC
# MAGIC This section sets up interactive widgets for configuring the geolocation process. 
# MAGIC
# MAGIC - process ID ({{Job.Run_id}}), 
# MAGIC - scraper name (the source web of listings to be located)

# COMMAND ----------

# MAGIC %pip install nbformat>=5.1.0

# COMMAND ----------

dbutils.widgets.text("process_id", "3C", "Process ID")
dbutils.widgets.text("scrapers","bidli", "Scraper list")
dbutils.widgets.text("maps_api","API_KEY", "Google Maps API key")


process_id = dbutils.widgets.get("process_id")
scraper = dbutils.widgets.get("scrapers")
maps_api = dbutils.widgets.get("maps_api")

print(scraper)

# COMMAND ----------

# MAGIC %md
# MAGIC #### Defining GPS (latitude/longitude) parser
# MAGIC - "49.123456,16.654321" - _standard format_
# MAGIC - "49°12'34\"N,16°39'15\"E" - _DMS format_
# MAGIC - "[16.67782877304817, 49.18383426696714]" - _JSON array_
# MAGIC - "[[lat,lon],[lat,lon],...]" - _array of coordinates (get the first one)_
# MAGIC
# MAGIC

# COMMAND ----------

from pyspark.sql.types import StructType, StructField, StringType
import requests
import re
import sys
import json
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
    try:
        if not gps_coordinates or gps_coordinates.strip().lower() == "none":
            return None, None

        # If it contains '[', it is a JSON format
        if '[' in gps_coordinates:
            coords_data = json.loads(gps_coordinates)
            
            # If it is an array of arrays - take the first coordinates
            if isinstance(coords_data[0], list):
                lat, lon = coords_data[0][:2]  # Take the first pair of coordinates
            else:
                # Simple array [lon, lat] or [lat, lon]
                lat, lon = coords_data[:2]
            
            # Check that the coordinates are within reasonable bounds
            # Lon is usually first in OpenStreetMap format [lon, lat]
            if abs(lat) > 90 or abs(lon) > 180:
                # Swap if it looks like [lon, lat] instead of [lat, lon]
                lat, lon = lon, lat
                
            return float(lat), float(lon)
            
        # DMS format
        dms_pattern = r"""(\d+)[°\s]+(\d+)[\'\s]+([\d\.]+)["]?\s*([NS]),\s*
                          (\d+)[°\s]+(\d+)[\'\s]+([\d\.]+)["]?\s*([EW])"""
        match = re.match(dms_pattern, gps_coordinates.replace("’", "'").replace("”", "\""), re.VERBOSE)
        if match:
            lat_deg, lat_min, lat_sec, lat_dir, lon_deg, lon_min, lon_sec, lon_dir = match.groups()
            lat = float(lat_deg) + float(lat_min)/60 + float(lat_sec)/3600
            lon = float(lon_deg) + float(lon_min)/60 + float(lon_sec)/3600
            if lat_dir == 'S':
                lat = -lat
            if lon_dir == 'W':
                lon = -lon
            return lat, lon
            
        # Standard format "lat,lon"
        else:
            lat, lon = map(float, gps_coordinates.split(","))
            return lat, lon
            
    except (json.JSONDecodeError, ValueError, IndexError) as e:
        print(f"Error parsing GPS coordinates '{gps_coordinates}': {e}")
        return None, None

# COMMAND ----------

# MAGIC %md
# MAGIC ### Define Google Maps Geolocate API
# MAGIC

# COMMAND ----------

import requests

def google_reverse_geocode(lat, lon, api_key):
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "latlng": f"{lat},{lon}",
        "key": api_key,
        "language": "cs"
    }
    resp = requests.get(url, params=params, timeout=10)
    if resp.status_code == 200:
        data = resp.json()
        if data["status"] == "OK" and data["results"]:
            return data["results"][0]  # první výsledek
        else:
            print("No result:", data.get("status"))
            return None
    else:
        print("HTTP error:", resp.status_code)
        return None

# COMMAND ----------

# MAGIC %md
# MAGIC ### Get listings to be located

# COMMAND ----------

# for each do a reverse geocode
listing_ids_table_name = f"realitky.raw.listings_{scraper}"
listing_details_table_name = f"realitky.raw.listing_details_{scraper}"

listings_to_be_located = spark.sql(f"""
    SELECT DISTINCT
        ldt.listing_id, 
        ldt.gps_coordinates 
    FROM {listing_details_table_name} ldt
        JOIN {listing_ids_table_name} lst
            ON ldt.listing_id = lst.listing_id 
            and lst.parsed = true
            AND lst.located = false 
            AND lst.del_flag = false 
    WHERE
            ldt.gps_coordinates IS NOT null
            AND ldt.gps_coordinates NOT LIKE '%[%'
            AND ldt.del_flag = false
""")

display(listings_to_be_located)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Call the reverse_geolocation API and get response

# COMMAND ----------

import time

results = []

MAX_REQ_PER_SEC = 12.5
PAUSE = 1.0 / MAX_REQ_PER_SEC
print(PAUSE)

for row in listings_to_be_located.collect():
    lat, lon = parse_coordinates(row.gps_coordinates)

    # Skip listings with invalid coordinates
    if lat is None or lon is None:
        continue

    # Použij Google reverse geocoding
    g_result = google_reverse_geocode(lat, lon, maps_api)
    if g_result:
        # Extrakce adresních komponent
        address_components = {c['types'][0]: c['long_name'] for c in g_result.get('address_components', []) if c['types']}
        street = address_components.get('route') or address_components.get('street_address')
        house_number = address_components.get('street_number')
        city = address_components.get('locality') or address_components.get('administrative_area_level_2')
        postcode = address_components.get('postal_code')
        state = address_components.get('administrative_area_level_1')
        country = address_components.get('country')
        results.append({
            "listing_id": row.listing_id,
            "gps_coordinates": row.gps_coordinates,
            "street": street or 'XNA',
            "house_number": house_number or 'XNA',
            "city": city or 'XNA',
            "postcode": postcode or 'XNA',
            "state": state or 'XNA',
            "country": country or 'XNA',
            "lat": lat,
            "lon": lon
        })

    time.sleep(PAUSE)

listings_located = spark.createDataFrame(results, schema)
listings_located.createOrReplaceTempView("listing_ids_view")

display(listings_located)


# COMMAND ----------

# MAGIC %md
# MAGIC ### Insert located data into a target table 'property'

# COMMAND ----------

spark.sql(f"""
    MERGE INTO realitky.cleaned.property AS target
    USING listing_ids_view AS source
        ON target.property_id = source.listing_id
        AND target.src_web = '{scraper}'
    WHEN MATCHED 
        AND target.src_web = '{scraper}' -- partitioning
    THEN
    UPDATE SET
        target.address_street = source.street,
        target.address_house_number = source.house_number,
        target.address_city = source.city,
        target.address_postal_code = source.postcode,
        target.address_state = source.country,
        target.address_latitude = source.lat,
        target.address_longitude = source.lon,
        target.upd_dt = CURRENT_TIMESTAMP,
        target.upd_process_id = '{process_id}'
""")

results_located = len(results)

update_stats(scraper, 'located', results_located, process_id)
update_listings(listing_ids_table_name, 'located', process_id)