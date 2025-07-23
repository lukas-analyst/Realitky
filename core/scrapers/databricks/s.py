from pyspark.sql.functions import broadcast, lit, current_timestamp
from delta.tables import DeltaTable

def export_to_table(new_df, table_name, insert_mode, process_id):
    """
    Export new_df to table_name with proper upsert logic.
    """
    table_exists = spark.catalog.tableExists(table_name)
    
    if not table_exists:
        # Create new table
        full_df = new_df.withColumn("ins_dt", current_timestamp()) \
                        .withColumn("ins_process_id", lit(process_id)) \
                        .withColumn("upd_dt", current_timestamp()) \
                        .withColumn("upd_process_id", lit(process_id)) \
                        .withColumn("del_flag", lit(False))
        
        full_df.write.mode("overwrite").saveAsTable(table_name)
        return full_df.count()
    
    # Get existing records
    existing_records = spark.sql(f"""
        SELECT listing_id, listing_hash 
        FROM {table_name} 
        WHERE del_flag = false
    """)
    
    # Filter new/changed records only
    filtered_df = new_df.join(
        broadcast(existing_records), 
        on=['listing_id', 'listing_hash'], 
        how='left_anti'
    )
    
    if filtered_df.count() == 0:
        print("No new or updated records to process.")
        return 0
    
    # Add audit columns
    records_to_insert = filtered_df.withColumn("ins_dt", current_timestamp()) \
                                  .withColumn("ins_process_id", lit(process_id)) \
                                  .withColumn("upd_dt", current_timestamp()) \
                                  .withColumn("upd_process_id", lit(process_id)) \
                                  .withColumn("del_flag", lit(False))
    
    # Update existing records to del_flag=True
    listing_ids = filtered_df.select("listing_id").distinct()
    delta_table = DeltaTable.forName(spark, table_name)
    
    delta_table.alias("target").merge(
        listing_ids.alias("source"),
        "target.listing_id = source.listing_id AND target.del_flag = false"
    ).whenMatchedUpdate(
        set={
            "del_flag": lit(True),
            "upd_dt": current_timestamp(),
            "upd_process_id": lit(process_id)
        }
    ).execute()
    
    # Insert new records
    records_to_insert.write.mode("append").option("mergeSchema", "true").saveAsTable(table_name)
    
    return records_to_insert.count()