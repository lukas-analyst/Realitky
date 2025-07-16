import sys
from pyspark.sql.functions import current_date, current_timestamp, lit

# Parameters
scraper_name = sys.argv[1]
parsed_row_count = int(sys.argv[2])
process_id = sys.argv[3]

# Create the stats table if it does not exist
spark.sql("""
CREATE TABLE IF NOT EXISTS realitky.stats.scrapers_detail (
    scraper_detail_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scraper_name STRING,
    parsed_rows INT,
    date DATE,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    del_flag BOOLEAN
)
""")

# Insert stats into the stats table
spark.sql(f"""
INSERT INTO realitky.stats.scrapers_detail (scraper_name, parsed_rows, date, ins_dt, ins_process_id, del_flag)
VALUES ('{scraper_name}', {parsed_row_count}, current_date(), current_timestamp(), '{process_id}', false)
""")


# Update the listings table with parsed parameter
listings_table = f"realitky.raw.listings_{scraper_name}"
details_table = f"realitky.raw.listing_details_{scraper_name}"

# Update parsed IDs
spark.sql(f"""
UPDATE {listings_table}
SET parsed = true,
    parsed_date = current_date(),
    upd_dt = current_timestamp(),
    upd_process_id = '{process_id}'
WHERE listing_id IN (SELECT dt.listing_id FROM {details_table} dt WHERE dt.del_flag = false)
""")