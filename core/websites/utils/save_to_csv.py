import os
import json
import logging
import csv
from datetime import datetime
from typing import Any, List, Optional

logger = logging.getLogger("save_to_csv")

def save_to_csv(
    data: List[Any],
    csv_path: str,
    add_timestamp: bool = True
) -> Optional[str]:
    """
    Save the provided data to a CSV file.

    :param data: List of dictionaries to save.
    :param csv_path: Target CSV file path.
    :param add_timestamp: If True, add date to filename.
    :return: Path to the saved file or None if failed.
    """
    os.makedirs(os.path.dirname(csv_path), exist_ok=True)
    current_date = datetime.now().strftime("%Y_%m_%d")
    final_path = (
        csv_path.replace(".csv", f"_{current_date}.csv") if add_timestamp else csv_path
    )

    if not data:
        logger.warning("No data to save to CSV.")
        return None

    all_keys = set()
    for row in data:
        all_keys.update(row.keys())
    keys = sorted(all_keys)
    try:
        with open(final_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=keys, extrasaction='ignore')
            writer.writeheader()
            for row in data:
                writer.writerow({
                    k: json.dumps(v, ensure_ascii=False) if isinstance(v, (dict, list)) else v
                    for k, v in row.items()
                })
        logger.info(f"RAW data saved to CSV: {final_path}")
        return final_path
    except Exception as e:
        logger.error(f"Error saving to CSV: {e}")
        return None