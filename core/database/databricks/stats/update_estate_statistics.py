import sys
from pyspark.sql.functions import current_date, current_timestamp, lit

# Parameters
scraper_name = sys.argv[1]
scraped_row_count = int(sys.argv[2])
process_id = sys.argv[3]

# Create the table if it does not exist
spark.sql("""
CREATE TABLE IF NOT EXISTS realitky.stats.scrapers (
    scraper_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scraper_name STRING,
    scraped_rows INT,
    date DATE,
    ins_dt TIMESTAMP,
    ins_process_id STRING,
    del_flag BOOLEAN
)
""")

# Insert the new row into the table
spark.sql(f"""
INSERT INTO realitky.stats.scrapers (scraper_name, scraped_rows, date, ins_dt, ins_process_id, del_flag)
VALUES ('{scraper_name}', {scraped_row_count}, current_date(), current_timestamp(), '{process_id}', False)
""")

