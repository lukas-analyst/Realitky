-- TASK 2: property_price_h_upd.sql 

-- Najde staré verze záznamů, které mají novější verze
-- Uzavře" je - nastaví `is_current = FALSE`
-- Doplní datum konce platnosti (`valid_to`)


MERGE INTO realitky.cleaned.property_price_h AS trg
USING (
    SELECT 
        hist.property_id,
        hist.src_web,
        hist.valid_from,
        date_sub(hist.next_valid_from, 1) AS new_valid_to
    FROM (
        SELECT 
            property_id,
            src_web,
            valid_from,
            is_current,
            LEAD(valid_from, 1) OVER (
                PARTITION BY property_id, src_web 
                ORDER BY valid_from ASC
            ) AS next_valid_from
        FROM realitky.cleaned.property_price_h
        WHERE is_current = TRUE
        AND (:src_web_filter IS NULL OR :src_web_filter = '' OR src_web = :src_web_filter)
    ) hist
    WHERE 
        hist.valid_from < :load_date
        AND hist.next_valid_from IS NOT NULL
        AND hist.next_valid_from > hist.valid_from
) AS src
ON (
    trg.property_id = src.property_id
    AND trg.src_web = src.src_web
    AND trg.valid_from = src.valid_from
    AND trg.is_current = TRUE
)
WHEN MATCHED THEN UPDATE SET
    trg.is_current = FALSE,
    trg.valid_to = src.new_valid_to,
    trg.upd_dt = current_timestamp(),
    trg.upd_process_id = :process_id;
