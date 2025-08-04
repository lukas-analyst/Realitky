-- TASK 1: property_price_h_sql.sql

-- Najde změněné záznamy - porovná dnešní data s včerejšími
-- Vloží nové verze záznamů do historické tabulky
-- Označí je jako aktuální (`is_current = TRUE`)


MERGE INTO realitky.cleaned.property_price_h AS trg
USING (
    SELECT 
        property_price_id,
        property_id,
        property_mode,
        price_amount,
        price_per_sqm,
        currency_code,
        price_type,
        price_detail,
        src_web,
        del_flag 
    FROM realitky.cleaned.property_price src
    WHERE src.upd_dt::date = :load_date
    AND (:src_web_filter IS NULL OR :src_web_filter = '' OR src.src_web = :src_web_filter)
    
    EXCEPT
    
    SELECT 
        hist.property_price_id,
        hist.property_id,
        hist.property_mode,
        hist.price_amount,
        hist.price_per_sqm,
        hist.currency_code,
        hist.price_type,
        hist.price_detail,
        hist.src_web,
        hist.del_flag
    FROM realitky.cleaned.property_price_h hist
    WHERE hist.is_current = TRUE
    AND (:src_web_filter IS NULL OR :src_web_filter = '' OR hist.src_web = :src_web_filter)
) AS src
ON (
    trg.is_current = TRUE
    AND trg.valid_from = :load_date
    AND trg.property_id = src.property_id
    AND trg.property_mode = src.property_mode
    AND trg.src_web = src.src_web
)
WHEN MATCHED THEN UPDATE SET
    trg.property_price_id = src.property_price_id,
    trg.price_amount = src.price_amount,
    trg.price_per_sqm = src.price_per_sqm,
    trg.currency_code = src.currency_code,
    trg.price_type = src.price_type,
    trg.price_detail = src.price_detail,
    trg.del_flag = src.del_flag,
    trg.upd_dt = current_timestamp(),
    trg.upd_process_id = :process_id
WHEN NOT MATCHED THEN INSERT (
    property_price_id,
    property_id,
    property_mode,
    price_amount,
    price_per_sqm,
    currency_code,
    price_type,
    price_detail,
    src_web,
    del_flag,
    ins_dt,
    ins_process_id,
    upd_dt,
    upd_process_id,
    valid_from,
    valid_to,
    is_current
) VALUES (
    src.property_price_id,
    src.property_id,
    src.property_mode,
    src.price_amount,
    src.price_per_sqm,
    src.currency_code,
    src.price_type,
    src.price_detail,
    src.src_web,
    src.del_flag,
    current_timestamp(),
    :process_id,
    current_timestamp(),
    :process_id,
    :load_date,
    NULL,
    TRUE
);
