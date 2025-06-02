import os
import glob
import json
import csv

def json_to_csv(json_path, csv_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        rows = data.get("data", [])
        if not rows:
            print(f"Žádná data v {json_path}")
            return
        # Najdi všechny unikátní klíče
        all_keys = set()
        for row in rows:
            all_keys.update(row.keys())
        all_keys = sorted(all_keys)
        # Ulož do CSV
        with open(csv_path, "w", encoding="utf-8", newline="") as out:
            writer = csv.DictWriter(out, fieldnames=all_keys)
            writer.writeheader()
            for row in rows:
                writer.writerow({k: row.get(k, "") for k in all_keys})
        print(f"Uloženo: {csv_path}")

# Pro všechny zdroje
json_dirs = glob.glob("data/raw/json/*")
for json_dir in json_dirs:
    name = os.path.basename(json_dir)
    json_files = glob.glob(os.path.join(json_dir, f"{name}_*.json"))
    for json_file in json_files:
        date_part = os.path.splitext(os.path.basename(json_file))[0].replace(f"{name}_", "")
        csv_dir = f"data/parsed/csv/{name}"
        os.makedirs(csv_dir, exist_ok=True)
        csv_path = os.path.join(csv_dir, f"{name}_{date_part}.csv")
        json_to_csv(json_file, csv_path)