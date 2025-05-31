import os
import pandas as pd
from datetime import datetime


def load_existing_data(file_path):
    """
    Načte existující CSV soubor, pokud existuje.
    """
    try:
        return pd.read_csv(file_path)
    except FileNotFoundError:
        # Pokud soubor neexistuje, vrátí prázdný DataFrame
        return pd.DataFrame(columns=["ID", "Název nemovitosti", "ins_dt", "upd_dt", "del_flag"])
    
# Funkce pro porovnání a filtrování záznamů podle hashe (listing_hash)
def filter_unchanged_records(new_data, main_data):
    filtered = []
    for record in new_data:
        existing = main_data[(main_data["ID"] == record["ID"]) & (main_data["del_flag"] == False)]
        if not existing.empty:
            if record.get("listing_hash") == existing.iloc[0].get("listing_hash"):
                continue  # Nemovitost se nezměnila, přeskočit
        filtered.append(record)
    return filtered


def upsert_to_main_data(source_web, main_file="main_data_raw.csv", output_dir="./data"):
    """
    Porovná data z hlavního datového souboru s daty z konkrétního webu a provede upsert.
    Porovnává všechny sloupce kromě ins_dt, upd_dt, del_flag.
    """
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    current_date = datetime.now().strftime("%Y_%m_%d")
    source_file = os.path.join(output_dir, f"{source_web}_listings_{current_date}.csv")

    # Načíst data z hlavního souboru a zdrojového souboru
    main_data = load_existing_data(main_file)
    source_data = load_existing_data(source_file)

    # Filtrace nových/změněných záznamů podle hash
    filtered_source_data = filter_unchanged_records(source_data.to_dict(orient="records"), main_data)

    # Pokud není co upsertovat, skonči
    if not filtered_source_data:
        return

    # Zajistit, že všechny nové sloupce budou v main_data
    for col in source_data.columns:
        if col not in main_data.columns:
            main_data[col] = None

    # Pracujeme pouze s platnými záznamy (del_flag == False)
    filtered_main_data = main_data[(main_data["src_web"] == source_web) & (main_data["del_flag"] == False)]
    updated_data = main_data.copy()

    ignore_cols = {"ins_dt", "upd_dt", "del_flag"}
    compare_cols = [col for col in source_data.columns if col not in ignore_cols]

    for record in filtered_source_data:
        existing_record = filtered_main_data[filtered_main_data["ID"] == record["ID"]]

        # Pokud existuje platný záznam, provedeme porovnání a případný upsert
        if not existing_record.empty:
            is_different = False
            for col in compare_cols:
                val_main = existing_record.iloc[0].get(col, None)
                val_new = record.get(col, None)
                if pd.isna(val_main) and pd.isna(val_new):
                    continue
                if val_main != val_new:
                    is_different = True
                    break

            if is_different:
                updated_data.loc[existing_record.index, "del_flag"] = True
                updated_data.loc[existing_record.index, "upd_dt"] = now
                # Nový záznam má vždy aktuální ins_dt
                record["ins_dt"] = now
                record["upd_dt"] = now
                record["del_flag"] = False
                updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)
        else:
            # Pokud žádný platný záznam neexistuje (nebo existuje pouze del_flag=True), přidáme nový záznam
            record["ins_dt"] = now
            record["upd_dt"] = now
            record["del_flag"] = False
            updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)

    updated_data.to_csv(main_file, index=False)