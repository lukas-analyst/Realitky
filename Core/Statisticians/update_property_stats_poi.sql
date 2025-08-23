MERGE INTO realitky.stats.property_stats AS target
USING (
    SELECT DISTINCT
        property_id,
        MAX(DATE(upd_dt)) AS poi_places_date,
        COALESCE(count(*), 0) AS poi_places_count,
        TRUE AS poi_places_check,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id
    FROM realitky.cleaned.property_poi
    WHERE
        del_flag = FALSE
    GROUP BY
        property_id,
        current_timestamp(),
        :process_id
) AS source
ON 
  target.property_id = source.property_id
WHEN MATCHED
  AND target.poi_places_date < source.poi_places_date
  OR target.poi_places_count <> source.poi_places_count
THEN UPDATE SET
    target.poi_places_date = source.poi_places_date,
    target.poi_places_check = source.poi_places_check,
    target.poi_places_count = source.poi_places_count,
    target.upd_dt = source.upd_dt,
    target.upd_process_id = source.upd_process_id