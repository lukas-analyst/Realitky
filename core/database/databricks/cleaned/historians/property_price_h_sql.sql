-- TASK 1: property_price_h_sql.sql

-- Najde změněné záznamy - porovná dnešní data s včerejšími
-- Vloží nové verze záznamů, které se změnily
-- Označí je jako aktuální (`is_current = TRUE`)


MERGE INTO realitky.cleaned.property_price_h AS trg
USING (
    SELECT *
    FROM realitky.cleaned.property_price src
    WHERE src.upd_dt::date = :load_date
    AND (:src_web_filter IS NULL OR :src_web_filter = '' OR src.src_web = :src_web_filter)
    
    EXCEPT
    
    SELECT 
        property_price_id,
        property_id,
        price_amount,
        price_per_sqm,
        currency_code,
        price_type,
        src_web,
        ins_dt,
        ins_process_id,
        upd_dt,
        upd_process_id,
        del_flag
    FROM realitky.cleaned.property_price_h hist
    WHERE hist.is_current = TRUE
    AND (:src_web_filter IS NULL OR :src_web_filter = '' OR hist.src_web = :src_web_filter)
) AS src
ON (
    trg.is_current = TRUE
    AND trg.valid_from = :load_date
    AND trg.property_id = src.property_id
    AND trg.src_web = src.src_web
)
WHEN MATCHED THEN UPDATE SET
    trg.property_price_id = src.property_price_id,
    trg.price_amount = src.price_amount,
    trg.price_per_sqm = src.price_per_sqm,
    trg.currency_code = src.currency_code,
    trg.price_type = src.price_type,
    trg.del_flag = src.del_flag,
    trg.upd_dt = current_timestamp(),
    trg.upd_process_id = :process_id
WHEN NOT MATCHED THEN INSERT (
    property_price_id,
    property_id,
    price_amount,
    price_per_sqm,
    currency_code,
    price_type,
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
    src.price_amount,
    src.price_per_sqm,
    src.currency_code,
    src.price_type,
    src.src_web,
    src.del_flag,
    src.ins_dt,
    src.ins_process_id,
    current_timestamp(),
    :process_id,
    :load_date,
    NULL,
    TRUE
);
