import os
import pandas as pd
from datetime import datetime

def save_html(content, output_dir, filename):
    os.makedirs(output_dir, exist_ok=True)
    filepath = os.path.join(output_dir, filename)
    with open(filepath, mode="w", encoding="utf-8") as file:
        file.write(content)

def extract_details(container, row_selector, label_selector, value_selector):
    """Extrahuje detaily z daného kontejneru."""
    details = {}
    rows = container.css(row_selector)
    for row in rows:
        label_element = row.css_first(label_selector)
        value_element = row.css_first(value_selector)
        if label_element and value_element:
            label = label_element.text(strip=True).rstrip(":")
            value = value_element.text(strip=True)
            details[label] = value
    return details

def load_existing_data(file_path):
    """
    Načte existující CSV soubor, pokud existuje, jinak vrátí prázdný DataFrame se správnými sloupci.
    """
    columns = ["ID", "Název nemovitosti", "Cena", "GPS souřadnice", "src_web", "ins_dt", "upd_dt", "del_flag"]
    try:
        return pd.read_csv(file_path)
    except FileNotFoundError:
        # Pokud soubor neexistuje, vrátí prázdný DataFrame se správnými sloupci
        return pd.DataFrame(columns=columns)

def save_to_csv(new_data, file_path):
    """
    Aktualizuje nebo přidá nové záznamy do CSV souboru.
    :param new_data: Nová data (list slovníků).
    :param file_path: Cesta k CSV souboru.
    """
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    existing_data = load_existing_data(file_path)
    updated_data = existing_data.copy()

    for record in new_data:
        # Najít existující záznam podle ID
        existing_record = updated_data[updated_data["ID"] == record["ID"]]

        if not existing_record.empty:
            # Pokud se data změnila, označit starý záznam jako zastaralý a přidat nový
            if not existing_record.iloc[0][["Název nemovitosti", "Cena", "GPS souřadnice"]].equals(
                pd.Series(record, index=["Název nemovitosti", "Cena", "GPS souřadnice"])
            ):
                updated_data.loc[existing_record.index, "del_flag"] = True
                updated_data.loc[existing_record.index, "upd_dt"] = now
                record["ins_dt"] = now
                record["upd_dt"] = now
                record["del_flag"] = False
                updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)
        else:
            # Pokud záznam neexistuje, přidat nový
            record["ins_dt"] = now
            record["upd_dt"] = now
            record["del_flag"] = False
            updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)

    # Uložit aktualizovaná data do CSV
    updated_data.to_csv(file_path, index=False)

def save_scraped_data(new_data, source_web, output_dir="./data"):
    """
    Uloží nascrapovaná data do specifického souboru podle zdrojového webu.
    :param new_data: Nová data (list slovníků).
    :param source_web: Název zdrojového webu (např. 'remax', 'sreality').
    :param output_dir: Adresář, kam se data uloží.
    """
    os.makedirs(output_dir, exist_ok=True)
    file_path = os.path.join(output_dir, f"{source_web}_listings.csv")
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Načíst existující data
    existing_data = load_existing_data(file_path)
    updated_data = existing_data.copy()

    for record in new_data:
        # Přidat časové značky a zdrojový web
        record["src_web"] = source_web
        record["ins_dt"] = now
        record["upd_dt"] = now
        record["del_flag"] = False

        # Přidat nový záznam
        updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)

    # Uložit aktualizovaná data
    updated_data.to_csv(file_path, index=False)