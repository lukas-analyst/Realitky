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
        return pd.DataFrame(columns=["ID", "Název nemovitosti", "Cena", "GPS souřadnice", "ins_dt", "upd_dt", "del_flag"])


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



def upsert_to_main_data(source_web, main_file="main_data.csv", output_dir="./data"):
    """
    Porovná data z hlavního datového souboru s daty z konkrétního webu a provede upsert.
    :param source_web: Název zdrojového webu (např. 'remax', 'sreality').
    :param main_file: Cesta k hlavnímu datovému souboru.
    :param output_dir: Adresář, kde jsou uložené soubory jednotlivých webů.
    """
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    source_file = os.path.join(output_dir, f"{source_web}_listings.csv")

    # Načíst data z hlavního souboru a zdrojového souboru
    main_data = load_existing_data(main_file)
    source_data = load_existing_data(source_file)

    # Filtrovat hlavní data podle zdrojového webu
    filtered_main_data = main_data[main_data["src_web"] == source_web]
    updated_data = main_data.copy()

    for _, record in source_data.iterrows():
        # Najít existující záznam podle ID
        existing_record = filtered_main_data[filtered_main_data["ID"] == record["ID"]]

        if not existing_record.empty:
            # Pokud se data změnila, označit starý záznam jako zastaralý a přidat nový
            if not existing_record.iloc[0][["Název nemovitosti", "Cena", "GPS souřadnice"]].equals(
                record[["Název nemovitosti", "Cena", "GPS souřadnice"]]
            ):
                updated_data.loc[existing_record.index, "del_flag"] = True
                updated_data.loc[existing_record.index, "upd_dt"] = now
                record["ins_dt"] = existing_record.iloc[0]["ins_dt"]
                record["upd_dt"] = now
                record["del_flag"] = False
                updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)
        else:
            # Pokud záznam neexistuje, přidat nový
            record["ins_dt"] = now
            record["upd_dt"] = now
            record["del_flag"] = False
            updated_data = pd.concat([updated_data, pd.DataFrame([record])], ignore_index=True)

    # Uložit aktualizovaná data do hlavního souboru
    updated_data.to_csv(main_file, index=False)