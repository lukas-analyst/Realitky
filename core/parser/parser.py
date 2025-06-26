import os
import glob
import json
import pandas as pd
import logging
from utils.flatten_row import flatten_row
from utils.clean_column_names import clean_column_names
from utils.save_to_postgres import save_to_postgres

logger = logging.getLogger("parser")

def load_column_list(path):
    with open(path, "r", encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip() and not line.startswith("#")]

def load_json(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        rows = data.get("data", [])
        meta = {k: v for k, v in data.items() if k != "data"}
        return rows, meta

def parse_and_clean(flat_rows, meta):
    df = pd.DataFrame(flat_rows)
    # Add meta columns (e.g. date, source) if not present
    for k, v in meta.items():
        if k not in df.columns:
            df[k] = v
    df = clean_column_names(df)
    return df

def export_to_csv(df, csv_path, columns=None):
    if columns:
        # Only export selected columns (e.g. for sreality)
        df = df[[col for col in columns if col in df.columns]]
    df.to_csv(csv_path, index=False, encoding="utf-8")
    logger.info(f"Exported to CSV: {csv_path}")

def process_json(json_path, csv_path, table_name, columns=None):
    rows, meta = load_json(json_path)
    if not rows:
        logger.warning(f"No data in {json_path}, skipping.")
        return
    flat_rows = [flatten_row(row) for row in rows]
    df = parse_and_clean(flat_rows, meta)
    export_to_csv(df, csv_path, columns)
    save_to_postgres(df, table_name)

def main():
    json_dirs = glob.glob("data/raw/json/*")
    for json_dir in json_dirs:
        name = os.path.basename(json_dir)
        if "sreality" in name:
            logger.info(f"Ignoring sreality source: {name}")
            continue
        json_files = glob.glob(os.path.join(json_dir, f"{name}_*.json"))
        for json_file in json_files:
            date_part = os.path.splitext(os.path.basename(json_file))[0].replace(f"{name}_", "")
            csv_dir = f"data/parsed/csv/{name}"
            os.makedirs(csv_dir, exist_ok=True)
            csv_path = os.path.join(csv_dir, f"{name}_{date_part}.csv")
            columns = None
            process_json(json_file, csv_path, name, columns)

if __name__ == "__main__":
    main()