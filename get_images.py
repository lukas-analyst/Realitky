import os
import pandas as pd
import requests

csv_path = r'C:\Data\random_sql_2025_08_14 (4).csv'
output_dir = r'C:\Data\images'

os.makedirs(output_dir, exist_ok=True)

df = pd.read_csv(csv_path)

for idx, row in df.iterrows():
    url = row['img_link']
    if pd.isna(url):
        continue
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        ext = os.path.splitext(url)[1]
        if not ext or len(ext) > 5:
            ext = '.jpg'
        property_id = str(row['property_id'])
        img_number = str(row['img_number'])
        filename = f"{property_id}_{img_number}{ext}"
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(response.content)
        print(f"Saved: {filepath}")
    except Exception as e:
        print(f"Failed to download {url}: {e}")