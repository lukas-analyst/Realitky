# Databricks notebook source
import unicodedata
from pyspark.sql.functions import col

def clean_column_names(df):
    def clean_col_name(col):
        col_clean = unicodedata.normalize('NFD', col.lower()).encode('ascii', 'ignore').decode().replace(' ', '_')
        col_clean = ''.join(e for e in col_clean if e.isalnum() or e == '_')
        return col_clean.rstrip(':') if col_clean else 'unnamed_column'

    new_columns = [clean_col_name(col) for col in df.columns]
    rename_expr = [f"`{old_col}` AS `{new_col}`" for old_col, new_col in zip(df.columns, new_columns)]
    
    df = df.selectExpr(*rename_expr)
    
    if 'datum' in df.columns:
        df = df.withColumnRenamed('datum', 'date')
    
    return df