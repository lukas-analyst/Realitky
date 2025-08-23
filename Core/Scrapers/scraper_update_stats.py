# Databricks notebook source
# Install required packages
%pip install nbformat>=5.1.0

# COMMAND ----------

import sys
%run "./utils/scraper_statistics_update.ipynb"

row_count_bezrealitky = dbutils.widgets.get("row_count_bezrealitky")
row_count_bidli = dbutils.widgets.get("row_count_bidli")
row_count_century21 = dbutils.widgets.get("row_count_century21")
row_count_idnes = dbutils.widgets.get("row_count_idnes")
row_count_remax = dbutils.widgets.get("row_count_remax")
row_count_sreality = dbutils.widgets.get("row_count_sreality")
row_count_ulovdomov = dbutils.widgets.get("row_count_ulovdomov")
process_id = dbutils.widgets.get("process_id")

scraper_names = [
    ('bezrealitky', row_count_bezrealitky),
    ('bidli', row_count_bidli),
    ('century21', row_count_century21),
    ('idnes', row_count_idnes),
    ('remax', row_count_remax),
    ('sreality', row_count_sreality),
    ('ulovdomov', row_count_ulovdomov)
]

print(scraper_names)

scraper_row_counts = [
    (name, int(count)) for name, count in scraper_names if count
]

for scraper_name, row_count in scraper_row_counts:
    update_stats(scraper_name, 'parsed', row_count, process_id)