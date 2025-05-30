from typing import Any, List, Optional
import json
import os
from datetime import datetime

def save_to_json(
    data: List[Any],
    json_dir: str,
    name: str,
    add_timestamp: bool = True
) -> Optional[str]:
    """
    Save the provided data to a JSON file in the specified directory.

    :param data: The data to be saved, typically a list of dictionaries.
    :param json_dir: The directory where the JSON file will be saved.
    :param name: Base name for the file.
    :param add_timestamp: If True, add date to filename.
    :return: Path to the saved file or None if failed.
    """
    os.makedirs(json_dir, exist_ok=True)
    current_date = datetime.now().strftime("%Y_%m_%d")
    filename = f"{name}_{current_date}.json" if add_timestamp else f"{name}.json"
    json_path = os.path.join(json_dir, filename)
    final_data = {
        "name": name,
        "date": current_date,
        "data": data
    }
    try:
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(final_data, f, ensure_ascii=False, indent=4)
        print(f"Data saved to {json_path}")
        return json_path
    except Exception as e:
        print(f"Chyba při ukládání JSON: {e}")
        return None