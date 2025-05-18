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

def sreality_extract_details(parser):
    """
    Extrahuje všechny detaily nemovitosti z bloků Sreality.cz.
    Vrací slovník {název: hodnota}.
    """
    details = {}
    for row in parser.css("div.MuiStack-root.css-1xhj18k"):
        label_element = row.css_first("dt")
        value_element = row.css_first("dd")
        if label_element and value_element:
            label = label_element.text(strip=True).rstrip(":")
            # Najdi všechny vnořené divy (kromě rootu)
            all_divs = [div for div in value_element.iter() if div is not value_element and div.tag == "div"]
            div_texts = [div.text(strip=True) for div in all_divs if div.text(strip=True)]
            if div_texts:
                value = "\n".join(div_texts)
            else:
                value = value_element.text(strip=True)
            details[label] = value
    return details
def load_existing_data(file_path):
    """
    Načte existující CSV soubor, pokud existuje, jinak vrátí prázdný DataFrame se správnými sloupci.
    """
    columns = ["ID", "Název nemovitosti", "src_web", "ins_dt", "upd_dt", "del_flag"]
    try:
        return pd.read_csv(file_path)
    except FileNotFoundError:
        # Pokud soubor neexistuje, vrátí prázdný DataFrame se správnými sloupci
        return pd.DataFrame(columns=columns)

def save_scraped_data(new_data, source_web, output_dir="./data", filename=None):
    """
    Uloží nascrapovaná data do specifického souboru podle zdrojového webu.
    Pokud soubor existuje, smaže jej. Do názvu souboru přidá dnešní datum.
    :param new_data: Nová data (list slovníků).
    :param source_web: Název zdrojového webu (např. 'remax', 'sreality').
    :param output_dir: Adresář, kam se data uloží.
    :param filename: Volitelný název souboru (pokud není zadán, vygeneruje se automaticky).
    """
    os.makedirs(output_dir, exist_ok=True)
    current_date = datetime.now().strftime("%Y_%m_%d")
    if filename is None:
        file_path = os.path.join(output_dir, f"{source_web}_listings_{current_date}.csv")
    else:
        file_path = os.path.join(output_dir, filename)

    # Pokud soubor existuje, smaž ho
    if os.path.exists(file_path):
        os.remove(file_path)

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    updated_data = pd.DataFrame()

    for record in new_data:
        # Přidat časové značky a zdrojový web
        record["src_web"] = source_web
        record["ins_dt"] = now
        record["upd_dt"] = now
        record["del_flag"] = False

        # Přidat nový záznam
        updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)

    # Uložit data do nového souboru
    updated_data.to_csv(file_path, index=False)