import pandas as pd
import psycopg2
from psycopg2 import sql
import logging

logger = logging.getLogger("parser")

def save_to_postgres(df, table_name, schema="parsed"):
    # Connect to PostgreSQL
    import os
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
    )
    cur = conn.cursor()
    # Dynamically create table if not exists
    columns = df.columns
    col_types = []
    for col in columns:
        dtype = df[col].dropna()
        if dtype.empty:
            col_types.append(f'"{col}" TEXT')
        elif pd.api.types.is_integer_dtype(dtype):
            col_types.append(f'"{col}" BIGINT')
        elif pd.api.types.is_float_dtype(dtype):
            col_types.append(f'"{col}" DOUBLE PRECISION')
        elif pd.api.types.is_bool_dtype(dtype):
            col_types.append(f'"{col}" BOOLEAN')
        elif dtype.apply(lambda x: isinstance(x, str) and len(x) > 255).any():
            col_types.append(f'"{col}" TEXT')
        else:
            col_types.append(f'"{col}" VARCHAR(255)')
    # Delete existing table if it exists
    delete_table_sql = f'DROP TABLE IF EXISTS {schema}."{table_name}";'
    cur.execute(delete_table_sql)
    create_table_sql = f'CREATE TABLE IF NOT EXISTS {schema}."{table_name}" ({", ".join(col_types)});'
    cur.execute(create_table_sql)
    # Insert data
    for _, row in df.iterrows():
        values = [row[col] if pd.notnull(row[col]) else None for col in columns]
        insert_sql = sql.SQL("INSERT INTO {}.{} ({}) VALUES ({}) ON CONFLICT DO NOTHING").format(
            sql.Identifier(schema),
            sql.Identifier(table_name),
            sql.SQL(", ").join(map(sql.Identifier, columns)),
            sql.SQL(", ").join(sql.Placeholder() * len(columns))
        )
        cur.execute(insert_sql, values)
    conn.commit()
    cur.close()
    conn.close()
    logger.info(f"Saved to PostgreSQL table {schema}.{table_name}")