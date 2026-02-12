-- ============================================================================
-- TASK 2: property_h_upd.sql
-- 
-- Uzavírání starých verzí záznamů (SCD Type 2)
-- 
-- Logika:
-- 1. Identifikuje všechny aktuální záznamy (current_flag = TRUE)
-- 2. Najde ty, které mají novější verzi (next_valid_from IS NOT NULL)
-- 3. Uzavře je - nastaví current_flag = FALSE a doplní valid_to
-- 4. valid_to se nastaví na den PŘED datumem nové verze
-- ============================================================================


MERGE INTO realitky.cleaned.property_h AS trg
USING (
    SELECT 
        hist.property_id,
        hist.src_web,
        hist.valid_from,
        DATE_SUB(hist.next_valid_from, 1) AS new_valid_to
    FROM (
        SELECT 
            property_id,
            src_web,
            valid_from,
            current_flag,
            LEAD(valid_from, 1) OVER (
                PARTITION BY property_id, src_web 
                ORDER BY valid_from ASC
            ) AS next_valid_from
        FROM realitky.cleaned.property_h
        WHERE current_flag = TRUE
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
    AND trg.current_flag = TRUE
)
WHEN MATCHED THEN UPDATE SET
    trg.current_flag = false,
    trg.valid_to = src.new_valid_to,
    trg.upd_dt = CURRENT_TIMESTAMP(),
    trg.upd_process_id = :process_id;