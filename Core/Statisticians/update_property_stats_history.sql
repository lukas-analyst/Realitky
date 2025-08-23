MERGE INTO realitky.stats.property_stats AS target
USING (
  SELECT DISTINCT
    property_id,
    src_web,
    DATE(upd_dt) AS history_date,
    TRUE AS history_check,
    current_timestamp() AS upd_dt,
    :process_id AS upd_process_id
  FROM realitky.cleaned.property_h
  WHERE 
    current_flag = TRUE
    AND del_flag = FALSE
) AS source
ON 
  target.property_id = source.property_id
  AND target.src_web = source.src_web
WHEN MATCHED
  AND target.history_date < source.history_date
THEN UPDATE SET
    target.history_date = source.history_date,
    target.history_check = source.history_check,
    target.upd_dt = source.upd_dt,
    target.upd_process_id = source.upd_process_id