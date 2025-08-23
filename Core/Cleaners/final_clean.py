# Databricks notebook source
# MAGIC %pip install nbformat>=5.1.0

# COMMAND ----------

import json

dbutils.widgets.text("process_id", "4D")
dbutils.widgets.text("row_count", '[{"num_affected_rows":"0","num_updated_rows":"0","num_deleted_rows":"0","num_inserted_rows":"0"}]')
dbutils.widgets.text("cleaner", "idnes,bezrealitky")

process_id = dbutils.widgets.get("process_id")
results_located = dbutils.widgets.get("row_count")
cleaner = dbutils.widgets.get("cleaner")

num_affected_rows = json.loads(results_located)[0]["num_affected_rows"]

display({"Process ID": process_id, "Num affected rows": num_affected_rows, "Cleaner": cleaner})

# COMMAND ----------

# MAGIC %md
# MAGIC ###Update scraper stats

# COMMAND ----------

import sys
%run "../Scrapers/utils/scraper_statistics_update.ipynb"

update_stats(cleaner, 'cleaned', num_affected_rows, process_id)


# COMMAND ----------

# MAGIC %md
# MAGIC ###Insert new properties into property_stats