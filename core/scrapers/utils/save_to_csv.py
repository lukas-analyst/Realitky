import os
import json
import logging
import csv
from datetime import datetime
from typing import Any, List, Optional

logger = logging.getLogger("save_to_csv")

def save_to_csv(
    data: List[Any],
    csv_dir: str,
    name: str,
    add_timestamp: bool = True
) -> Optional[str]:
    """
    Save the provided data to a CSV file.

    :param data: List of dictionaries to save.
    :param csv_path: Target CSV file path.
    :param name: Base name for the file.
    :param add_timestamp: If True, add date to filename.
    :return: Path to the saved file or None if failed.
    """
    os.makedirs(csv_dir, exist_ok=True)
    current_date = datetime.now().strftime("%Y_%m_%d")
    filename = f"{name}_{current_date}.csv" if add_timestamp else f"{name}.csv"
    csv_path = os.path.join(csv_dir, filename)

    if not data:
        logger.warning("No data to save to CSV.")
        return None

    all_keys = set()
    for row in data:
        all_keys.update(row.keys())
    keys = sorted(all_keys)
    try:
        with open(csv_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=keys, extrasaction='ignore')
            writer.writeheader()
            for row in data:
                writer.writerow({
                    k: json.dumps(v, ensure_ascii=False) if isinstance(v, (dict, list)) else v
                    for k, v in row.items()
                })
        logger.info(f"RAW data saved to CSV: {csv_path}")
        return csv_path
    except Exception as e:
        logger.error(f"Error saving to CSV: {e}")
        return None