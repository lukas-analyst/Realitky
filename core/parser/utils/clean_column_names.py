import pandas as pd
import unicodedata
import logging

logger = logging.getLogger(__name__)

def clean_column_names(df):
    new_columns = []
    unnamed_count = 1
    for idx, col in enumerate(df.columns):
        # Pokud je název prázdný, pojmenuj ho unikátně
        if not col or str(col).strip() == '':
            col_clean = f'unnamed_{unnamed_count}'
            unnamed_count += 1
        else:
            # Remove '_m' suffix, lowercase, replace spaces, remove diacritics
            col_clean = unicodedata.normalize('NFD', col.split('_m')[0].lower() if '_m' in col else col.lower())
            col_clean = col_clean.encode('ascii', 'ignore').decode().replace(' ', '_')
        new_columns.append(col_clean)
    df.columns = new_columns
    # Rename 'datum' to 'date'
    if 'datum' in df.columns:
        df.rename(columns={'datum': 'date'}, inplace=True)
        logger.info("Column 'datum' has been renamed to 'date'.")
    return df