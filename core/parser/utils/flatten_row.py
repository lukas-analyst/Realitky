def flatten_row(row, parent_key='', sep='.'):
    items = {}
    for k, v in row.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.update(flatten_row(v, new_key, sep=sep))
        elif isinstance(v, list):
            for i, item in enumerate(v):
                if isinstance(item, dict):
                    items.update(flatten_row(item, f"{new_key}_{i}", sep=sep))
                else:
                    items[f"{new_key}_{i}"] = item
        else:
            items[new_key] = v
    return items