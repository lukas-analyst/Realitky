import os
import glob
import json
import psycopg2
import dotenv

dotenv.load_dotenv()

def detect_type(values):
    for v in values:
        if v is None or v == "":
            continue
        if isinstance(v, bool):
            return "BOOLEAN"
        try:
            int(v)
            return "BIGINT"
        except:
            try:
                float(v)
                return "FLOAT"
            except:
                pass
        if isinstance(v, str) and len(v) > 255:
            return "TEXT"
    return "TEXT"

def get_column_types(rows):
    types = {}
    for key in set(k for row in rows for k in row.keys()):
        if not key or not str(key).strip():
            print("VAROVÁNÍ: Prázdný název sloupce bude přeskočen.")
            continue
        values = [row.get(key, None) for row in rows]
        types[key] = detect_type(values)
    return types

def create_table(cur, table_name, columns):
    cols = ", ".join(f'"{k}" {v}' for k, v in columns.items())
    cur.execute(f'DROP TABLE IF EXISTS parsed."{table_name}";')
    cur.execute(f'CREATE TABLE parsed."{table_name}" ({cols});')

def clean_value(value, col_type):
    if value is None:
        return None
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    if col_type in ("BIGINT", "FLOAT"):
        if isinstance(value, str):
            value = value.replace(" ", "").replace("\xa0", "")
        try:
            if col_type == "BIGINT":
                return int(value)
            else:
                return float(value)
        except:
            return None
    return value

def insert_rows(cur, table_name, columns, rows):
    keys = list(columns.keys())
    for row in rows:
        values = [clean_value(row.get(k, None), columns[k]) for k in keys]
        placeholders = ", ".join(["%s"] * len(keys))
        columns_str = ", ".join([f'"{k}"' for k in keys])
        sql = f'INSERT INTO parsed."{table_name}" ({columns_str}) VALUES ({placeholders})'
        cur.execute(sql, values)
        

def process_json(json_path, table_name, conn):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        rows = data.get("data", [])
        if not rows:
            print(f"Žádná data v {json_path}")
            return
        date = data.get("date", None)
        for row in rows:
            row["date"] = date
        columns = get_column_types(rows)
        with conn.cursor() as cur:
            create_table(cur, table_name, columns)
            insert_rows(cur, table_name, columns, rows)
        conn.commit()
        print(f"Tabulka {table_name} vytvořena a naplněna ({len(rows)} řádků).")
# Nastav připojení k DB - dotenv
conn = psycopg2.connect(
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT")
)

# Pro všechny zdroje
json_dirs = glob.glob("data/raw/json/*")
for json_dir in json_dirs:
    name = os.path.basename(json_dir)
    json_files = glob.glob(os.path.join(json_dir, f"{name}_*.json"))
    for json_file in json_files:
        table_name = name
        process_json(json_file, table_name, conn)

conn.close()