MERGE INTO realitky.cleaned.property_price AS target
USING(
    SELECT
        listing_details_century21.listing_id AS property_id,
        CASE
            WHEN listing_details_century21.category1 = 'pronajem' THEN 'rent'
            WHEN listing_details_century21.category1 = 'prodej' THEN 'sale'
            ELSE 'XNA'
        END AS property_mode,
        listing_details_century21.listing_url,
        CASE
            WHEN listing_details_century21.price like '%m²%' THEN COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_century21.price, '[^0-9]', '') AS INT), 0) * COALESCE(REGEXP_REPLACE(listing_details_century21.plocha_uzitna, '[^0-9]', ''), REGEXP_REPLACE(listing_details_century21.plocha_pozemku, '[^0-9]', ''), 1)
            ELSE COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_century21.price, '[^0-9]', '') AS INT), 0)
        END AS price_amount,
        CASE 
            WHEN listing_details_century21.price like '%m²%' THEN ROUND(COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_century21.price, '[^0-9]', '') AS INT), 0), 2)
            ELSE ROUND(
                COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_century21.price, '[^0-9]', '') AS INT), 0) 
                / COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_century21.plocha_uzitna, '[^0-9]', '') AS INT), TRY_CAST(REGEXP_REPLACE(listing_details_century21.plocha_pozemku, '[^0-9]', '') AS INT), 1)
            , 2)
        END AS price_per_sqm,
        CASE
            WHEN UPPER(listing_details_century21.price) LIKE '%EUR%' OR UPPER(listing_details_century21.price) LIKE '%€%' THEN 'EUR'
            WHEN UPPER(listing_details_century21.price) LIKE '%USD%' OR UPPER(listing_details_century21.price) LIKE '%$%' THEN 'USD'
            ELSE 'CZK'
        END AS currency_code,
        CASE
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%+ poplatky%' THEN 'No utilities'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%+ služby%' THEN 'No utilities'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%+ poplatky%' THEN 'No utilities'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%bez provize%' THEN 'No comission'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%+ provize%' THEN 'No comission'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%četně provize%' THEN 'With comission'
          WHEN LOWER(listing_details_century21.price_detail) LIKE '%č. provize%' THEN 'With comission'
          ELSE 'XNA'
        END AS price_type,
        listing_details_century21.price_detail AS price_detail,
        listing_details_century21.reserved AS reserved,
        listing_details_century21.status AS status,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
    FROM realitky.raw.listing_details_century21
    WHERE listing_details_century21.del_flag = false
) AS source
ON target.property_id = source.property_id
  AND target.property_mode = source.property_mode
  AND target.src_web = source.src_web
  AND target.del_flag = false
WHEN MATCHED 
    AND (target.price_amount <> source.price_amount
    OR target.price_per_sqm <> source.price_per_sqm
    OR target.price_type <> source.price_type)
    AND source.reserved = False 
    AND source.status = 'active'
THEN UPDATE SET
        target.price_amount = source.price_amount,
        target.price_per_sqm = source.price_per_sqm,
        target.currency_code = source.currency_code,
        target.price_type = source.price_type,
        target.upd_dt = source.upd_dt,
        target.upd_process_id = source.upd_process_id
WHEN NOT MATCHED THEN
    INSERT (
        property_id,
        property_mode,
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
    )
    VALUES (
        source.property_id,
        source.property_mode,
        source.price_amount,
        source.price_per_sqm,
        source.currency_code,
        source.price_type,
        source.src_web,
        source.ins_dt,
        source.ins_process_id,
        source.upd_dt,
        source.upd_process_id,
        source.del_flag
    );