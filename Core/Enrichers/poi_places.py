# Databricks notebook source
# MAGIC %md
# MAGIC ## Notebook Configuration
# MAGIC
# MAGIC This section sets up interactive widgets for configuring the enrichment process. 
# MAGIC
# MAGIC - Geoapify API key, 
# MAGIC - POI category (included as an variable from the INPUT parameter), 
# MAGIC - process ID ({{Job.Run_id}}), 
# MAGIC - number of properties to process (limited by 'test_mode' to 5, else 50 (beacuse API limits))
# MAGIC - test mode (from the Config task)

# COMMAND ----------

# Configuration widgets
dbutils.widgets.text("api_key", "your_geoapify_api_key", "Geoapify API Key")
dbutils.widgets.text("category_key", "1", "category_key")
dbutils.widgets.text("process_id", "POI_001", "Process ID")
dbutils.widgets.text("max_properties", "2", "Number of Records")
dbutils.widgets.dropdown("test_mode", "true", ["true", "false"], "Test Mode (limit to 50 records)")


# Get widget values
api_key = dbutils.widgets.get("api_key")
category_key = int(dbutils.widgets.get("category_key"))
process_id = dbutils.widgets.get("process_id")
max_properties = int(dbutils.widgets.get("max_properties"))


print(f"Configuration:")
print(f"- API Key: {'*' * (len(api_key) - 4) + api_key[-4:] if len(api_key) > 4 else 'NOT_SET'}")
print(f"- Categeory Key: {category_key}")
print(f"- Process ID: {process_id}")
print(f"- Number of properties: {max_properties}")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Select POI Category and Properties to Enrich
# MAGIC
# MAGIC This section retrieves the POI category code and maximum number of POIs to fetch for the selected category.
# MAGIC It then selects the properties that need to be enriched with POI data, based on the current configuration. 
# MAGIC
# MAGIC The selection ensures only valid properties (with latitude and longitude) are included, and limits the number of records for efficient processing.
# MAGIC
# MAGIC

# COMMAND ----------

# Get POI Category
row = spark.sql(f"""
    SELECT 
      category_code, 
      max_results 
    FROM realitky.cleaned.poi_category 
    WHERE 
      category_key = {category_key} 
      AND del_flag = FALSE
""").first()

category_code = row['category_code']
max_results = row['max_results']

print(f"Category: {category_code}")
print(f"Max results: {max_results}")

# Get properties to enrich
df_properties_to_be_enriched = spark.sql(f"""
    SELECT 
      property.property_id, 
      property.address_latitude, 
      property.address_longitude
    FROM realitky.cleaned.property AS property
    FULL OUTER JOIN realitky.stats.property_stats
      ON property_stats.property_id = property.property_id 
     AND property_stats.src_web = property.src_web
     AND property_stats.poi_places_check = TRUE
     AND property_stats.del_flag = FALSE
    WHERE 
      property.property_type_id IN (1, 2, 7, 15) -- Byt, Dům, Chata, Rekreační objekt
      AND property.address_latitude > 0
      AND property.address_longitude > 0
      AND property.del_flag = FALSE
    ORDER BY
      property_stats.ins_dt DESC,
      property_stats.upd_dt    
    LIMIT {max_properties}
""")
display(df_properties_to_be_enriched)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Download POI data from Geoapify API for each property
# MAGIC
# MAGIC This block iterates over properties to be enriched, calls the Geoapify Places API, and collects the raw JSON responses for further processing.

# COMMAND ----------

import requests
import time
import json
from pyspark.sql.types import StructType
from datetime import datetime

BASE_URL = 'https://api.geoapify.com/v2/places'

all_pois = []

print(f"Getting POIs for {df_properties_to_be_enriched.count()} properties")

for idx, row in enumerate(df_properties_to_be_enriched.collect(), 1):
    property_id = row['property_id']
    address_latitude = row['address_latitude']
    address_longitude = row['address_longitude']
    params = {
        'categories': category_code,
        'bias': f'proximity:{address_longitude},{address_latitude}',
        'limit': max_results,
        'apiKey': api_key
    }
    print(f"Requesting POI category=\"{category_code}\" for property_id='{property_id}' at ({address_latitude}, {address_longitude})")
    try:
        response = requests.get(BASE_URL, params=params, timeout=5)
        response.raise_for_status()
        poi_data = response.json()
        all_pois.append({
            "property_id": property_id,
            "category_key": category_key,
            "poi_raw_response": json.dumps(poi_data, ensure_ascii=False) 
        })
        print(f"Success for property_id={property_id}, found {len(poi_data.get('features', []))} POIs.")
        time.sleep(0.1)
    except requests.exceptions.Timeout as e:
        print(f"TIMEOUT for property {property_id}: {e}\nParams: {params}")
        continue
    except requests.exceptions.HTTPError as e:
        print(f"HTTPError for property {property_id}: {e}\nStatus: {getattr(e.response, 'status_code', None)}\nParams: {params}")
        if e.response is not None and e.response.status_code == 400:
            print(f"Bad request for property {property_id}")
        continue
    except Exception as e:
        print(f"Error for property {property_id}: {e}\nParams: {params}")
        continue

print(f"Finished POI download. Total successful: {len(all_pois)}")

if all_pois:
    df_all_pois = spark.createDataFrame(all_pois)
    display(df_all_pois)
else:
    df_all_pois = None
    print("No POIs found")

# COMMAND ----------

# MAGIC %md
# MAGIC ### POI Data Cleaning and Transformation
# MAGIC This step processes the raw POI (Point of Interest) data by:
# MAGIC - Inferring the JSON schema from a sample row.
# MAGIC - Parsing the `poi_raw_response` JSON and exploding the features array.
# MAGIC - Extracting relevant POI fields such as name, address, coordinates, and data source.
# MAGIC - Generating additional metadata columns

# COMMAND ----------

import json
from pyspark.sql.functions import from_json, col, explode_outer, schema_of_json, element_at, current_timestamp, lit, concat, udf, trim
from pyspark.sql.types import StringType

if df_all_pois: 
    # UDF - extract empty field
    def extract_empty_field(json_str, key):
        try:
            obj = json.loads(json_str)
            features = obj.get('features', [])
            for feature in features:
                value = feature.get('properties', {}).get(key)
                if value is not None:
                    return value
            return None
        except Exception:
            return None


    extract_name_udf = udf(lambda x: extract_empty_field(x, 'name'), StringType())
    extract_address_line1_udf = udf(lambda x: extract_empty_field(x, 'address_line1'), StringType())
    extract_address_line2_udf = udf(lambda x: extract_empty_field(x, 'address_line2'), StringType())


    # Use the raw response for schema inference
    sample_row = df_all_pois.select("poi_raw_response").filter(col("poi_raw_response").isNotNull()).first()
    if sample_row is not None:
        sample_json = sample_row["poi_raw_response"]
        inferred_schema = schema_of_json(sample_json)
    else:
        inferred_schema = schema_of_json('{}')


    # Parse JSON and explode features
    df = df_all_pois.withColumn("json", from_json(col("poi_raw_response"), inferred_schema))
    df = df.withColumn("feature", explode_outer(col("json.features")))


    # Extract fields using UDFs
    df = df.withColumn("poi_name", extract_name_udf(col("poi_raw_response")))
    df = df.withColumn("poi_address1", extract_address_line1_udf(col("poi_raw_response")))
    df = df.withColumn("poi_address2", extract_address_line2_udf(col("poi_raw_response")))


    # Add metadata columns
    df = df.withColumn("ins_dt", current_timestamp()) \
        .withColumn("ins_process_id", lit(process_id)) \
        .withColumn("upd_dt", current_timestamp()) \
        .withColumn("upd_process_id", lit(process_id)) \
        .withColumn("del_flag", lit(False))


    # Select and cast final columns
    df_final = df.select(
        col("category_key"),
        col("property_id"),
        col("feature.properties").cast(StringType()).alias("poi_attributes"),
        element_at(col("feature.geometry.coordinates"), 2).alias("poi_latitude"),
        element_at(col("feature.geometry.coordinates"), 1).alias("poi_longitude"),
        col("poi_name"),
        col("feature.properties.place_id").alias("poi_id"),
        col("feature.properties.distance").alias("poi_distance_m"),
        col("poi_address1"),
        col("poi_address2"),
        col("feature.properties.datasource.sourcename").alias("data_source"),
        concat(
            lit("https://www.openstreetmap.org/#map=19/"),
            element_at(col("feature.geometry.coordinates"), 2), lit("/"),
            element_at(col("feature.geometry.coordinates"), 1)
        ).alias("poi_url"),
        col("ins_dt"),
        col("ins_process_id"),
        col("upd_dt"),
        col("upd_process_id"),
        col("del_flag")
    )


    # Filter out empty or null POI attributes
    df_final = df_final.filter(~((trim(col("poi_attributes")) == "{}") | (col("poi_attributes").isNull())))


    display(df_final)
else:
    print("No POIs found")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Writing POI to the property_poi table by partitioning on category_key
# MAGIC
# MAGIC This step saves the processed POI to the `realitky.cleaned.property_poi` table only for the current `category_key`. Thanks to partitioning, it is possible to write concurrently for different categories without conflicts.

# COMMAND ----------

if df_all_pois: 
    df_final.createOrReplaceTempView("tmp_property_poi")
    spark.sql(f"""
        MERGE INTO realitky.cleaned.property_poi AS target
        USING tmp_property_poi AS source
        ON target.property_id = source.property_id
            AND target.category_key = source.category_key
            AND target.poi_id = source.poi_id
        WHEN MATCHED 
            AND target.category_key = {category_key} -- partitioning
            AND target.poi_attributes <> source.poi_attributes
            OR target.del_flag <> source.del_flag
        THEN UPDATE SET
            target.poi_attributes = source.poi_attributes,
            target.poi_latitude = source.poi_latitude,
            target.poi_longitude = source.poi_longitude,
            target.poi_name = source.poi_name,
            target.poi_distance_m = source.poi_distance_m,
            target.poi_address1 = source.poi_address1,
            target.poi_address2 = source.poi_address2,
            target.data_source = source.data_source,
            target.poi_url = source.poi_url,
            target.upd_dt = source.upd_dt,
            target.upd_process_id = source.upd_process_id,
            target.del_flag = source.del_flag
        WHEN NOT MATCHED
            AND source.category_key = {category_key} -- partitioning
        THEN INSERT(
            category_key,
            property_id,
            poi_attributes,
            poi_latitude,
            poi_longitude,
            poi_name,
            poi_id,
            poi_distance_m,
            poi_address1,
            poi_address2,
            data_source,
            poi_url,
            ins_dt,
            ins_process_id,
            upd_dt,
            upd_process_id,
            del_flag
        ) VALUES(
            source.category_key,
            source.property_id,
            source.poi_attributes,
            source.poi_latitude,
            source.poi_longitude,
            source.poi_name,
            source.poi_id,
            source.poi_distance_m,
            source.poi_address1,
            source.poi_address2,
            source.data_source,
            source.poi_url,
            source.ins_dt,
            source.ins_process_id,
            source.upd_dt,
            source.upd_process_id,
            source.del_flag
        )
    """)
else:
    print("No POIs found")