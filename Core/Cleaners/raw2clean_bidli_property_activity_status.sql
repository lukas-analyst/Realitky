MERGE INTO realitky.cleaned.property AS target
  USING (
    SELECT
        listing_details_bidli.listing_id AS property_id,
        IF(listing_details_bidli.status = 'inactive', false, true) AS is_active_listing,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
        
    FROM realitky.raw.listing_details_bidli
    WHERE listing_details_bidli.del_flag = false
      AND listing_details_bidli.status = 'inactive'
  ) AS source
  ON target.property_id = source.property_id
    AND target.src_web = source.src_web
    AND target.del_flag = false
  WHEN MATCHED 
  AND target.is_active_listing <> source.is_active_listing
  THEN UPDATE SET
      is_active_listing = source.is_active_listing,    
      upd_dt = source.upd_dt,
      upd_process_id = source.upd_process_id