# Databricks notebook source
# Configuration widgets
dbutils.widgets.text("api_key", "your_geoapify_api_key", "Geoapify API Key")
dbutils.widgets.text("process_id", "POI_001", "Process ID")
dbutils.widgets.dropdown("test_mode", "true", ["true", "false"], "Test Mode (limit to 5 records)")

# Get widget values
api_key = dbutils.widgets.get("api_key")
process_id = dbutils.widgets.get("process_id")
test_mode = dbutils.widgets.get("test_mode").lower() == "true"

if test_mode:
    max_properties = 5
    dbutils.jobs.taskValues.set(key = "max_properties", value = max_properties)
else:
    max_properties = 100
    dbutils.jobs.taskValues.set(key = "max_properties", value = max_properties)


print(f"Configuration:")
print(f"- Test mode: {test_mode}")
print(f"- Number of properties to be enriched: {max_properties}")