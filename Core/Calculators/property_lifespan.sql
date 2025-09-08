-- TASK: property_lifespan.sql

-- Vypočítá metriky životnosti inzerátu a upsertne je do realitky.calculated.property_lifespan
-- Dodržuje styl MERGE skriptů v projektu (parametry :load_date, :process_id)

MERGE INTO realitky.calculated.property_lifespan AS trg
USING (
    SELECT DISTINCT
	    property.property_id AS property_id,
		DATE(MIN(property_h.ins_dt)) AS open_date,
        CASE
            WHEN property_h.is_active_listing = false THEN DATE(MAX(property_h.upd_dt))
            ELSE null
        END AS sold_date
		AS reactivated_count,
		AS active_days,
		AS active_days_expected,
		AS ins_dt,
		AS upd_dt,
		AS ins_process_id,
		AS upd_process_id,
		AS del_flag
    FROM
        realitky.cleaned.property
    INNER JOIN realitky.cleaned.property_h 
        ON property.property_id = property_h.property_id
        AND property.src_web = property_h.src_web
        AND property_h.del_flag = false
    GROUP BY 
        property.property_id,
        property_h.is_active_listing
) AS src
ON trg.property_id = src.property_id
WHEN MATCHED THEN UPDATE SET
		trg.open_date = src.open_date,
		trg.sold_date = src.sold_date,
		trg.reactivated_count = src.reactivated_count,
		trg.active_days = src.active_days,
		trg.active_days_expected = src.active_days_expected,
		trg.upd_dt = src.upd_dt,
		trg.upd_process_id = src.upd_process_id,
		trg.del_flag = src.del_flag
WHEN NOT MATCHED THEN INSERT (
		property_id,
		open_date,
		sold_date,
		reactivated_count,
		active_days,
		active_days_expected,
		ins_dt,
		upd_dt,
		ins_process_id,
		upd_process_id,
		del_flag
) VALUES (
		src.property_id,
		src.open_date,
		src.sold_date,
		src.reactivated_count,
		src.active_days,
		src.active_days_expected,
		src.ins_dt,
		src.upd_dt,
		src.ins_process_id,
		src.upd_process_id,
        src.del_flag
);

