# Databricks notebook source
# MAGIC %md
# MAGIC ## Update parsed listings
# MAGIC After one week do an update on parsed listings
# MAGIC - new information
# MAGIC - new photos/images
# MAGIC - update on _is_active_listing_ (true/false)

# COMMAND ----------

dbutils.widgets.text("src_web", "ulovdomov", "Source web")
dbutils.widgets.text("process_id", "UPDATE_MANUAL", "Process ID")

src_web = dbutils.widgets.get("src_web")
process_id = dbutils.widgets.get("process_id")

# COMMAND ----------

row_count = sql(f"""
    UPDATE realitky.raw.listings_{src_web}
SET 
  scraped = false,
  parsed = false,
  upd_dt = CURRENT_TIMESTAMP,
  upd_process_id = '{process_id}'
WHERE
  upd_check_date < current_date() - 7
  AND del_flag = false
  AND listing_id NOT IN (
    SELECT 
      property.property_id
    FROM realitky.cleaned.property
    WHERE
      property.is_active_listing = false
      AND property.src_web = '{src_web}'
      AND property.del_flag = false
  )
""")

display(row_count)