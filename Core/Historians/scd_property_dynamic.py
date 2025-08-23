# Databricks notebook source
# MAGIC %md
# MAGIC # Dynamic SCD Type 2 Implementation for Property Table
# MAGIC
# MAGIC **Purpose:** Dynamicky implementuje SCD Type 2 pro tabulku `property` bez nutnosti hardcoding specifických sloupců.
# MAGIC
# MAGIC **Key Features:**
# MAGIC - Automatická detekce všech business sloupců
# MAGIC - Použití `current_flag` namísto `valid_to = 2999-12-31`
# MAGIC - Podpora `src_web` jako source systému
# MAGIC - Flexibilní přístup umožňující změny schématu bez úprav kódu
# MAGIC
# MAGIC **Generated:** July 22, 2025  
# MAGIC **Table:** realitky.cleaned.property  
# MAGIC **Environment:** Databricks

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Setup Environment and Parameters
# MAGIC
# MAGIC Nastavení prostředí, parametrů a inicializace logování.

# COMMAND ----------

# Import required libraries
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from delta.tables import *
import logging
from datetime import datetime, date

# Setup Databricks widgets
dbutils.widgets.removeAll()
dbutils.widgets.text("load_date", str(date.today()), "Load Date (YYYY-MM-DD)")
dbutils.widgets.text("job_id", "manual_run", "Job ID")
dbutils.widgets.text("job_run_id", "1", "Job Run ID")
dbutils.widgets.text("job_task_run_id", "2", "Job Task Run ID")
dbutils.widgets.text("src_web", "", "Source Web Filter (optional)")

# Get parameters
load_date = dbutils.widgets.get("load_date")
job_id = dbutils.widgets.get("job_id")
job_run_id = dbutils.widgets.get("job_run_id")
job_task_run_id = dbutils.widgets.get("job_task_run_id")
src_web_filter = dbutils.widgets.get("src_web")

# Create job identifier
job_identifier = f"{job_id}.{job_run_id}.{job_task_run_id}"

print("=== Execution Context ===")
print(f"Load Date: {load_date}")
print(f"Job ID: {job_identifier}")
print(f"Source Web Filter: {src_web_filter if src_web_filter else 'All sources'}")
print("=========================")

# COMMAND ----------

# Define table names
source_table = f"realitky.cleaned.property"
history_table = f"realitky.cleaned.property_h"

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def log_step(step_name, message, step_order=None):
    """Helper function for consistent logging"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if step_order:
        log_message = f"[{timestamp}] Step {step_order}: {step_name} - {message}"
    else:
        log_message = f"[{timestamp}] {step_name} - {message}"
    print(log_message)
    logger.info(log_message)

log_step("Initialization", "SCD Type 2 process started for property table", 1)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Define Dynamic Column Detection
# MAGIC
# MAGIC Automatická detekce všech business sloupců v tabulce property (bez audit a SCD sloupců).

# COMMAND ----------

# Get table schema and identify business columns
def get_business_columns(table_name):
    """
    Dynamicky získá všechny business sloupce z tabulky.
    Vyloučí audit sloupce a SCD sloupce.
    """
    # Audit a SCD sloupce, které se neporovnávají pro změny
    excluded_columns = {
        'ins_dt', 'ins_process_id', 'upd_dt', 'upd_process_id',
        'valid_from', 'valid_to', 'current_flag'
    }
    
    # Získání schématu tabulky
    table_df = spark.table(table_name)
    all_columns = [field.name for field in table_df.schema.fields]
    
    # Filtrování business sloupců
    business_columns = [col for col in all_columns if col not in excluded_columns]
    
    return business_columns, all_columns

# Získání sloupců
business_columns, all_columns = get_business_columns(source_table)

print(f"Total columns in source table: {len(all_columns)}")
print(f"Business columns for comparison: {len(business_columns)}")
print(f"Business columns: {', '.join(business_columns[:10])}{'...' if len(business_columns) > 10 else ''}")

log_step("Schema Analysis", f"Identified {len(business_columns)} business columns for comparison", 2)

# COMMAND ----------

# Functions for dynamic SQL generation
def generate_select_clause(columns, table_alias=""):
    """Generuje SELECT klauzuli pro zadané sloupce"""
    prefix = f"{table_alias}." if table_alias else ""
    return ",\n        ".join([f"{prefix}{col}" for col in columns])

def generate_update_clause(columns, source_alias="src", target_alias="trg"):
    """Generuje UPDATE SET klauzuli pro zadané sloupce"""
    updates = []
    for col in columns:
        updates.append(f"{target_alias}.{col} = {source_alias}.{col}")
    return ",\n          ".join(updates)

def generate_insert_columns_clause(columns):
    """Generuje seznam sloupců pro INSERT"""
    return ",\n        ".join(columns)

def generate_insert_values_clause(columns, source_alias="src"):
    """Generuje VALUES klauzuli pro INSERT"""
    values = []
    for col in columns:
        values.append(f"{source_alias}.{col}")
    return ",\n        ".join(values)

# Test functions
print("=== Dynamic SQL Generation Test ===")
test_columns = business_columns[:3]  # First 3 columns for testing
print(f"SELECT clause: {generate_select_clause(test_columns, 'src')}")
print(f"UPDATE clause: {generate_update_clause(test_columns)}")
print("====================================")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Implement SCD Type 2 Logic with Dynamic Columns
# MAGIC
# MAGIC Dynamická implementace SCD Type 2 logiky pomocí MERGE statement.

# COMMAND ----------

# Build dynamic MERGE SQL
def build_scd_merge_sql():
    """Sestaví kompletní MERGE SQL pro SCD Type 2"""
    
    # Prepare source filter
    src_web_condition = ""
    if src_web_filter:
        src_web_condition = f"AND src.src_web = '{src_web_filter}'"
    
    # Generate dynamic parts
    business_select = generate_select_clause(business_columns, "src")
    business_update = generate_update_clause(business_columns)
    business_insert_cols = generate_insert_columns_clause(business_columns)
    business_insert_vals = generate_insert_values_clause(business_columns)
    
    merge_sql = f"""
    MERGE INTO {history_table} AS trg
    USING (
        SELECT 
            {business_select},
            -- Audit columns from source
            ins_dt,
            ins_process_id,
            upd_dt,
            upd_process_id
        FROM {source_table} src
        WHERE src.upd_dt::date = '{load_date}'
        {src_web_condition}
        
        EXCEPT
        
        SELECT 
            {generate_select_clause(business_columns, "hist")},
            -- Audit columns from history
            hist.ins_dt,
            hist.ins_process_id,
            hist.upd_dt,
            hist.upd_process_id
        FROM {history_table} hist
        WHERE hist.current_flag = TRUE
        {f"AND hist.src_web = '{src_web_filter}'" if src_web_filter else ""}
    ) AS src
    ON (
        trg.current_flag = TRUE 
        AND trg.valid_from = '{load_date}'
        AND trg.property_id = src.property_id
        AND trg.src_web = src.src_web
    )
    WHEN MATCHED THEN UPDATE SET
        {business_update},
        trg.upd_dt = current_timestamp(),
        trg.upd_process_id = '{job_identifier}'
    WHEN NOT MATCHED THEN INSERT (
        {business_insert_cols},
        ins_dt,
        ins_process_id,
        upd_dt,
        upd_process_id,
        valid_from,
        valid_to,
        current_flag
    ) VALUES (
        {business_insert_vals},
        src.ins_dt,
        src.ins_process_id,
        current_timestamp(),
        '{job_identifier}',
        '{load_date}',
        NULL,
        TRUE
    )
    """
    
    return merge_sql

# Generate and display the SQL
merge_sql = build_scd_merge_sql()
print("=== Generated MERGE SQL (first 500 chars) ===")
print(merge_sql[:500] + "...")
print("===============================================")

log_step("SQL Generation", "Dynamic MERGE SQL statement created", 3)

# COMMAND ----------

# Execute the MERGE statement
try:
    log_step("Merge Execution", "Starting MERGE operation for new/changed records", 4)
    
    # Execute the merge
    spark.sql(merge_sql)
    
    log_step("Merge Execution", "MERGE operation completed successfully", 4)
    
except Exception as e:
    log_step("Merge Execution", f"MERGE operation failed: {str(e)}", 4)
    print(f"SQL that failed:\n{merge_sql}")
    raise

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Close Previous Versions
# MAGIC
# MAGIC Aktualizace předchozích verzí - nastavení `current_flag = FALSE` a `valid_to` pro záznamy, které mají novější verze.

# COMMAND ----------

# Close previous versions
def build_close_versions_sql():
    """Sestaví SQL pro uzavření předchozích verzí"""
    
    src_web_condition = ""
    if src_web_filter:
        src_web_condition = f"AND src_web = '{src_web_filter}'"
    
    close_sql = f"""
    MERGE INTO {history_table} AS trg
    USING (
        SELECT 
            hist.property_id,
            hist.src_web,
            hist.valid_from,
            date_sub(next_valid_from, 1) AS new_valid_to
        FROM (
            SELECT 
                property_id,
                src_web,
                valid_from,
                current_flag,
                LEAD(valid_from, 1) OVER (
                    PARTITION BY property_id, src_web 
                    ORDER BY valid_from ASC
                ) AS next_valid_from
            FROM {history_table}
            WHERE current_flag = TRUE
            {src_web_condition}
        ) hist
        WHERE 
            hist.valid_from < '{load_date}'
            AND hist.next_valid_from IS NOT NULL
            AND hist.next_valid_from > hist.valid_from
    ) AS src
    ON (
        trg.property_id = src.property_id
        AND trg.src_web = src.src_web
        AND trg.valid_from = src.valid_from
        AND trg.current_flag = TRUE
    )
    WHEN MATCHED THEN UPDATE SET
        trg.current_flag = FALSE,
        trg.valid_to = src.new_valid_to,
        trg.upd_dt = current_timestamp(),
        trg.upd_process_id = '{job_identifier}'
    """
    
    return close_sql

# Execute close versions SQL
try:
    log_step("Close Versions", "Starting to close previous versions", 5)
    
    close_sql = build_close_versions_sql()
    spark.sql(close_sql)
    
    log_step("Close Versions", "Previous versions closed successfully", 5)
    
except Exception as e:
    log_step("Close Versions", f"Failed to close previous versions: {str(e)}", 5)
    print(f"SQL that failed:\n{close_sql}")
    raise

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Validate and Log Results
# MAGIC
# MAGIC Validace integrity dat a logování výsledků zpracování.

# COMMAND ----------

# Count processed rows and validate results
try:
    log_step("Validation", "Starting data validation and result counting", 6)
    
    # Count records processed in this run
    src_web_filter_sql = f"AND upd_process_id = '{job_identifier}'"
    if src_web_filter:
        src_web_filter_sql += f" AND src_web = '{src_web_filter}'"
    
    processed_count = spark.sql(f"""
        SELECT COUNT(*) as cnt 
        FROM {history_table} 
        WHERE upd_process_id = '{job_identifier}'
        {f"AND src_web = '{src_web_filter}'" if src_web_filter else ""}
    """).collect()[0]['cnt']
    
    # Count current active records
    current_count = spark.sql(f"""
        SELECT COUNT(*) as cnt 
        FROM {history_table} 
        WHERE current_flag = TRUE
        {f"AND src_web = '{src_web_filter}'" if src_web_filter else ""}
    """).collect()[0]['cnt']
    
    # Count total historical records
    total_count = spark.sql(f"""
        SELECT COUNT(*) as cnt 
        FROM {history_table}
        {f"WHERE src_web = '{src_web_filter}'" if src_web_filter else ""}
    """).collect()[0]['cnt']
    
    # Validate data integrity
    validation_sql = f"""
        SELECT 
            COUNT(*) as total_records,
            COUNT(CASE WHEN current_flag = TRUE THEN 1 END) as current_records,
            COUNT(CASE WHEN current_flag = FALSE THEN 1 END) as historical_records,
            COUNT(DISTINCT property_id) as unique_properties
        FROM {history_table}
        {f"WHERE src_web = '{src_web_filter}'" if src_web_filter else ""}
    """
    
    validation_result = spark.sql(validation_sql).collect()[0]
    
    print("=== Processing Results ===")
    print(f"Records processed in this run: {processed_count}")
    print(f"Current active records: {current_count}")
    print(f"Total historical records: {total_count}")
    print(f"Unique properties: {validation_result['unique_properties']}")
    print("==========================")
    
    log_step("Validation", f"Processed {processed_count} records successfully", 6)
    
except Exception as e:
    log_step("Validation", f"Validation failed: {str(e)}", 6)
    raise

# COMMAND ----------

# Display sample data and final summary
try:
    # Show sample of processed records
    print("=== Sample of Processed Records ===")
    sample_df = spark.sql(f"""
        SELECT 
            property_id,
            property_name,
            src_web,
            valid_from,
            valid_to,
            current_flag,
            upd_process_id
        FROM {history_table}
        WHERE upd_process_id = '{job_identifier}'
        {f"AND src_web = '{src_web_filter}'" if src_web_filter else ""}
        ORDER BY upd_dt DESC
        LIMIT 5
    """)
    
    sample_df.show(truncate=False)
    
    # Final summary
    print("=== Final Summary ===")
    print(f"Load Date: {load_date}")
    print(f"Job ID: {job_identifier}")
    print(f"Source Filter: {src_web_filter if src_web_filter else 'All sources'}")
    print(f"Business Columns Monitored: {len(business_columns)}")
    print(f"Records Processed: {processed_count}")
    print(f"Current Active Records: {current_count}")
    print(f"Process Status: SUCCESS")
    print("=====================")
    
    log_step("Final Summary", f"SCD Type 2 process completed successfully. Processed {processed_count} records.", 7)
    
except Exception as e:
    log_step("Final Summary", f"Error in final summary: {str(e)}", 7)
    print(f"Process Status: PARTIAL SUCCESS (validation error)")

# Return the count for downstream processes
dbutils.notebook.exit(processed_count)