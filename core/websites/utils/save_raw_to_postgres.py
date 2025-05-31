import os
import json
import psycopg2
import logging
from psycopg2 import sql
from dotenv import load_dotenv
from typing import List, Any, Optional

load_dotenv()
logger = logging.getLogger("save_raw_to_postgres")

def save_raw_to_postgres(
    data: List[Any],
    table_name: str,
    id_field: str = "id"
) -> Optional[bool]:
    """
    Save raw data (list of dicts) into a PostgreSQL table with columns (id, data).

    :param data: List of dictionaries to save.
    :param table_name: Target table name (must have columns id, data).
    :param id_field: Field in dict to use as primary key (default 'id').
    :return: True if successful, None if failed.
    """
    try:
        conn = psycopg2.connect(
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
        )
        cur = conn.cursor()
        for detail in data:
            # Get id (for Sreality it's hash_id or id)
            raw_id = detail.get(id_field) or detail.get("hash_id") or detail.get("id")
            if not raw_id:
                continue
            cur.execute(
                sql.SQL("""
                    INSERT INTO raw.{} (id, data)
                    VALUES (%s, %s)
                """).format(sql.Identifier(table_name)),
                (raw_id, json.dumps(detail, ensure_ascii=False)),
            )
        conn.commit()
        cur.close()
        conn.close()
        logger.info(f"RAW data saved to PostgreSQL table raw.{table_name}")
        return True
    except Exception as e:
        logger.error(f"Error saving to PostgreSQL: {e}")
        return None