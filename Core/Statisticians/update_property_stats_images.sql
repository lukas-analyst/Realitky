MERGE INTO realitky.stats.property_stats AS target
USING (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY property_id ORDER BY DATE(upd_dt) DESC) AS row_number,
        property_id,
        src_web,
        DATE(upd_dt) AS images_date,
        COALESCE(count(*), 0) AS images_count,
        TRUE AS images_check,
        current_timestamp() AS now_dt,
        :process_id AS upd_process_id
    FROM realitky.cleaned.property_image
    WHERE
        del_flag = FALSE
    GROUP BY
        property_id,
        src_web,
        DATE(upd_dt),
        current_timestamp(),
        :process_id
) AS source
ON 
  target.property_id = source.property_id
  AND target.src_web = source.src_web
  AND source.row_number = 1
WHEN MATCHED
  AND target.images_date < source.images_date
  OR target.images_count <> source.images_count
THEN UPDATE SET
    target.images_date = source.images_date,
    target.images_check = source.images_check,
    target.images_count = source.images_count,
    target.upd_dt = source.now_dt,
    target.upd_process_id = source.upd_process_id