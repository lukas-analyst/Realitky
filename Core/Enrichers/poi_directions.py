# Databricks notebook source
# MAGIC %md
# MAGIC ## Notebook Configuration
# MAGIC
# MAGIC This section sets up interactive widgets for configuring the enrichment process. 
# MAGIC
# MAGIC - OpenRouteService API key, 
# MAGIC - POI category (included as an variable from the INPUT parameter), 
# MAGIC - process ID ({{Job.Run_id}}), 
# MAGIC - number of properties to process (limited by 'test_mode' to 5, else 50 (beacuse API limits))
# MAGIC - test mode (from the Config task)

# COMMAND ----------

# Configuration widgets
dbutils.widgets.text("api_key", "your_geoapify_api_key", "Geoapify API Key")
dbutils.widgets.text("direction_style", "foot-walking", "Direction Style")
dbutils.widgets.text("process_id", "POI_002", "Process ID")
dbutils.widgets.text("max_properties", "2", "Number of Records")
dbutils.widgets.dropdown("test_mode", "true", ["true", "false"], "Test Mode (limit to 50 records)")

# Get widget values
api_key = dbutils.widgets.get("api_key")
direction_style = dbutils.widgets.get("direction_style")
process_id = dbutils.widgets.get("process_id")
max_properties = int(dbutils.widgets.get("max_properties"))

print(f"Configuration:")
print(f"- API Key: {'*' * (len(api_key) - 4) + api_key[-4:] if len(api_key) > 4 else 'NOT_SET'}")
print(f"- Direction style: {direction_style}")
print(f"- Process ID: {process_id}")
print(f"- Number of properties: {max_properties}")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Select POIs
# MAGIC
# MAGIC This section retrieves the maximum number of POIs to fetch for the selected direction_style type of travel.
# MAGIC
# MAGIC The selection ensures only valid POIs (connected to property table) are included, and limits the number of records for efficient processing.
# MAGIC
# MAGIC

# COMMAND ----------

df_poi = spark.sql(f"""
    SELECT 
        property_poi.property_id, 
        property_poi.poi_id, 
        property_poi.poi_longitude, 
        property_poi.poi_latitude,
        property.address_longitude,
        property.address_latitude
    FROM realitky.cleaned.property_poi
    INNER JOIN realitky.cleaned.property
        ON property_poi.property_id = property.property_id
        AND property.del_flag = FALSE
    LIMIT {max_properties}
""")
display(df_poi)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Download direction data from OpenRouteService API for each POI
# MAGIC
# MAGIC This block iterates over POI to find directions, calls the OpenRouteService Direction API, and collects the raw JSON responses for further processing.

# COMMAND ----------

import requests
import time
import json
from datetime import datetime

BASE_URL = f"https://api.openrouteservice.org/v2/directions/{direction_style}"

all_poi_direction = []

for row in df_poi.collect():
    property_id = row['property_id']
    poi_id = row['poi_id']
    property_latitude = row['address_latitude']
    property_longitude = row['address_longitude']
    poi_latitude = row['poi_latitude']
    poi_longitude = row['poi_longitude']

    headers = {
        'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': api_key
    }

    params = {
        'start': f'{property_longitude},{property_latitude}',
        'end': f'{poi_longitude},{poi_latitude}',
        'apiKey': api_key
    }
    try:
        response = requests.get(BASE_URL, params=params, headers=headers)
        response.raise_for_status()
        poi_direction_data = response.json()
        all_poi_direction.append({
            "property_id": property_id,
            "poi_id": poi_id,
            "direction_style": direction_style,
            "poi_direction_raw_response": json.dumps(poi_direction_data, ensure_ascii=False) 
        })
        time.sleep(0.1)
    except requests.exceptions.Timeout as e:
        print(f"TIMEOUT for property '{property_id}' ({property_latitude},{property_longitude}) while searching for POI '{poi_id}' located at ({poi_latitude}, {poi_longitude})")
        continue
    except requests.exceptions.HTTPError as e:
        print(f"HTTPError for property '{property_id}' ({property_latitude},{property_longitude}) while searching for POI '{poi_id}' located at ({poi_latitude}, {poi_longitude})")
        print(f"Error: {e}\nStatus: {getattr(e.response, 'status_code', None)}")
        if e.response is not None and e.response.status_code == 400:
            print(f"Bad request for property '{property_id}' ({property_latitude},{property_longitude}) while searching for POI '{poi_id}' located at ({poi_latitude}, {poi_longitude})")
        continue
    except Exception as e:
        print(f"Error for property '{property_id}' ({property_latitude},{property_longitude}) while searching for POI '{poi_id}' located at ({poi_latitude}, {poi_longitude}):")
        print(f"Error: {e}")
        continue

df_all_poi_direction = spark.createDataFrame(all_poi_direction)
display(df_all_poi_direction)

# COMMAND ----------

# MAGIC %md
# MAGIC ### POI Data Cleaning and Transformation
# MAGIC This step processes the raw POI (Point of Interest) directions by:
# MAGIC - Inferring the JSON schema from a sample row.
# MAGIC - Parsing the `poi_direction_raw_response` JSON and exploding the features array.
# MAGIC - Extracting relevant POI fields such "distance" and "duration".
# MAGIC - Generating additional metadata columns.

# COMMAND ----------

# --- Parse OpenRouteService response and extract distance/duration using PySpark only (with direction_style-specific columns) ---
from pyspark.sql import Row
import json

# Defensive: handle empty input
if all_poi_direction:
    rows = []
    all_cols = set(['property_id', 'poi_id'])
    for row in all_poi_direction:
        property_id = row['property_id']
        poi_id = row['poi_id']
        direction_style = row.get('direction_style', '')
        try:
            data = json.loads(row['poi_direction_raw_response'])
            features = data.get('features', [])
            if features and 'properties' in features[0]:
                segments = features[0]['properties'].get('segments', [])
                if segments:
                    distance_m = segments[0].get('distance')
                    duration_min = segments[0].get('duration') / 60 if segments[0].get('duration') is not None else None
                    distance_m = round(distance_m, 2) if distance_m is not None else None
                    duration_min = round(duration_min, 2) if duration_min is not None else None
        except Exception:
            distance_m = None
            duration_min = None

        row_dict = {'property_id': property_id, 'poi_id': poi_id, 'distance_m': distance_m, 'duration_min': duration_min}
        all_cols.update(row_dict.keys())
        rows.append(Row(**row_dict))
        print(rows)

    # Create DataFrame, fill missing columns with None
    df_distance = spark.createDataFrame(rows)
    for c in all_cols:
        if c not in df_distance.columns:
            df_distance = df_distance.withColumn(c, lit(None))

    from pyspark.sql.functions import current_timestamp, lit
    df_distance = df_distance.withColumn('upd_dt', current_timestamp()) \
                                   .withColumn('upd_process_id', lit(process_id))
    display(df_distance)
else:
    print('No POI direction data found')

# COMMAND ----------

# MAGIC %md
# MAGIC ### Writing POI directions to the property_poi table
# MAGIC
# MAGIC This step saves the processed POI directions to the `realitky.cleaned.property_poi` table.

# COMMAND ----------

if all_poi_direction: 

    # Set column names based on direction_style
    if direction_style == 'foot-walking':
        col_dist = 'poi_distance_walk_m'
        col_time = 'poi_distance_walk_min'
    elif direction_style == 'driving-car':
        col_dist = 'poi_distance_drive_m'
        col_time = 'poi_distance_drive_min'
    elif direction_style == 'public-transport':
        col_dist = 'poi_distance_public_transport_m'
        col_time = 'poi_distance_public_transport_min'
        
    df_distance.createOrReplaceTempView("tmp_poi_direction")
    spark.sql(f"""
        MERGE INTO realitky.cleaned.property_poi AS target
        USING tmp_poi_direction AS source
        ON target.property_id = source.property_id
            AND target.poi_id = source.poi_id
        WHEN MATCHED 
            AND target.{col_dist} <> source.distance_m
            AND target.{col_time} <> source.duration_min
        THEN UPDATE SET
            target.{col_dist} = source.distance_m,
            target.{col_time} = source.duration_min,
            target.upd_dt = source.upd_dt,
            target.upd_process_id = source.upd_process_id
    """)
    print("POI direction data successfully merged")
else:
    print('No POI direction data found')