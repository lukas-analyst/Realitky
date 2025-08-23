# Databricks notebook source
# MAGIC %md
# MAGIC #Export dataframe into a table
# MAGIC Export only data that are not yet in the table (lookup for listing_id / listing_url)
# MAGIC - if the call contains parameter 'parsed = False' then lookup for listing_id which haven't yet been parsed (test-mode)
# MAGIC
# MAGIC ## Definition
# MAGIC
# MAGIC export_to_table(new_df, table_name, insert_mode, parsed)
# MAGIC 1. new_df         - Spark.DataFrame to be exported
# MAGIC 2. table_name     - Name of the table, must include schema and workspace (eg. "realitky.raw.listing_idnes")
# MAGIC 3. insert_mode    - Mode in which to insert data (default: overwrite)
# MAGIC 4. parsed         - Whether to include not parsed listings

# COMMAND ----------

from pyspark.sql.functions import broadcast, lit, current_date, current_timestamp

def filter_df(new_df, table_name):
    existing_ids_df = spark.sql(f"SELECT listing_id FROM {table_name} WHERE del_flag = false")
    filtered_df = new_df.join(broadcast(existing_ids_df), on='listing_id', how='left_anti')
    return filtered_df

def add_columns(filtered_df):
    filtered_df = filtered_df.withColumn("upd_check_date", lit(current_date()).cast("date"))
    filtered_df = filtered_df.withColumn("scraped", lit(True).cast("boolean"))
    filtered_df = filtered_df.withColumn("scraped_date", lit(current_date()).cast("date"))
    filtered_df = filtered_df.withColumn("parsed", lit(False).cast("boolean"))
    filtered_df = filtered_df.withColumn("parsed_date", lit('1000-01-01').cast("date"))
    filtered_df = filtered_df.withColumn("located", lit(False).cast("boolean"))
    filtered_df = filtered_df.withColumn("located_date", lit('1000-01-01').cast("date"))
    filtered_df = filtered_df.withColumn("ins_dt", current_timestamp().cast("timestamp"))
    filtered_df = filtered_df.withColumn("ins_process_id", lit(process_id).cast("string"))
    filtered_df = filtered_df.withColumn("upd_dt", current_timestamp().cast("timestamp"))
    filtered_df = filtered_df.withColumn("upd_process_id", lit(process_id).cast("string"))
    filtered_df = filtered_df.withColumn("del_flag", lit(False).cast("boolean"))
    return filtered_df

def save_to_table(full_df, table_name, insert_mode, table_exists):
    # Check if the table exists, if not create it
    if table_exists:
        full_df.write.mode(insert_mode).option("mergeSchema", "true").saveAsTable(table_name)
    else:
        spark.sql(f"DROP TABLE IF EXISTS {table_name}")
        full_df.write.mode("overwrite").saveAsTable(table_name)

def export_to_table(new_df, table_name, insert_mode):
    table_exists = spark.catalog.tableExists(table_name)
    if table_exists:
        # filter out IDs that are already in the output table
        filtered_df = filter_df(new_df, table_name)
    else:
        filtered_df = new_df
    # add metadata columns
    full_df = add_columns(filtered_df)
    # import df
    row_count = full_df.count()
    save_to_table(full_df, table_name, insert_mode, table_exists)
    return row_count