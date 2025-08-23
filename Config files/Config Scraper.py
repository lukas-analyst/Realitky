# Databricks notebook source
# MAGIC %md
# MAGIC ### Configuration of the scraper
# MAGIC
# MAGIC Here we can overwrite:
# MAGIC - whether and which core.scrapers are gonna run
# MAGIC - which mode (sale/rent/both) is active
# MAGIC - which location is gonna be searched
# MAGIC - to which location ar output files gonna be saved to
# MAGIC
# MAGIC **Note**: none yet

# COMMAND ----------

# MAGIC %md
# MAGIC ###Create a widget

# COMMAND ----------

# Create widgets for user inputs
dbutils.widgets.dropdown("test_mode", "True", ["True", "False"], "Test Mode")

#Scraper parameters:
dbutils.widgets.dropdown("scraper_remax", "False", ["True", "False"], "Scrape REMAX")
dbutils.widgets.dropdown("scraper_sreality", "False", ["True", "False"], "Scrape Sreality")
dbutils.widgets.dropdown("scraper_bezrealitky", "False", ["True", "False"], "Scrape Bezrealitky")
dbutils.widgets.dropdown("scraper_bidli", "False", ["True", "False"], "Scrape Bidli")
dbutils.widgets.dropdown("scraper_idnes", "False", ["True", "False"], "Scrape Idnes")
dbutils.widgets.dropdown("scraper_century21", "False", ["True", "False"], "Scrape Century21")

# COMMAND ----------

# MAGIC %md
# MAGIC ###Defining parameters

# COMMAND ----------

from datetime import datetime

# Scraping parameters:
test_mode = dbutils.widgets.get("test_mode")
# Scrapers parameters
scraper_remax = dbutils.widgets.get("scraper_remax")
scraper_sreality = dbutils.widgets.get("scraper_sreality")
scraper_bezrealitky = dbutils.widgets.get("scraper_bezrealitky")
scraper_bidli = dbutils.widgets.get("scraper_bidli")
scraper_idnes = dbutils.widgets.get("scraper_idnes")
scraper_century21 = dbutils.widgets.get("scraper_century21")

# Parameter 'scrapers'
scrapers = {
    "scraper_remax": "remax",
    "scraper_sreality": "sreality",
    "scraper_bezrealitky": "bezrealitky",
    "scraper_bidli": "bidli",
    "scraper_idnes": "idnes",
    "scraper_century21": "century21"
}
running_scrapers = [scrapers[key] for key in scrapers if dbutils.widgets.get(key) == "True"]

# Define variables:
# If is Monday then 'weekly' = True
weekly = datetime.today().weekday() == 0


max_pages: int = None
per_page: int = None

if test_mode == "True":
  max_pages = 13
  per_page = 20
  print("========= Testing mode active =========")
else:
  max_pages = 9999 #must be an INT
  per_page = 90

print(f"Max pages: {max_pages}")
print(f"Per page: {per_page}")
print(f"Are we scraping all properties: {weekly}")
print("============ Scrapers: ============")
print(f"{running_scrapers}")

# Out as a parameter:
dbutils.jobs.taskValues.set(key = "max_pages", value = max_pages)
dbutils.jobs.taskValues.set(key = "per_page", value = per_page)
dbutils.jobs.taskValues.set(key = "scrapers", value = running_scrapers)
dbutils.jobs.taskValues.set(key = "weekly", value = weekly)
