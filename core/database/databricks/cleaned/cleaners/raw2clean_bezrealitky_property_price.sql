mERGE INTO realitky.cleaned.property_price AS target
USING(
    SELECT
        listing_details_bezrealitky.listing_id AS property_id,
        CASE
            WHEN listing_details_bezrealitky.category_1 = 'Pronájem' THEN 'rent'
            WHEN listing_details_bezrealitky.category_1 = 'Prodej' THEN 'sale'
            ELSE 'XNA'
        END AS property_mode,
        listing_details_bezrealitky.listing_url,
        COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_bezrealitky.cena, '[^0-9]', '') AS INT), 0) AS price_amount,
        listing_details_bezrealitky.listing_url,
        COALESCE(TRY_CAST(REGEXP_REPLACE(listing_details_bezrealitky.cena, '[^0-9]', '') AS INT), 0) / COALESCE(REGEXP_REPLACE(listing_details_bezrealitky.uzitna_plocha, '[^0-9]', ''), REGEXP_REPLACE(listing_details_bezrealitky.plocha_pozemku, '[^0-9]', ''), 1) AS price_per_sqm,
        CASE
            WHEN UPPER(listing_details_bezrealitky.cena) LIKE '%EUR%' OR UPPER(listing_details_bezrealitky.cena) LIKE '%€%' THEN 'EUR'
            WHEN UPPER(listing_details_bezrealitky.cena) LIKE '%USD%' OR UPPER(listing_details_bezrealitky.cena) LIKE '%$%' THEN 'USD'
            ELSE 'CZK'
        END AS currency_code,
        'XNA' AS price_type,
        COALESCE(listing_details_bezrealitky.price_details, 'XNA') AS price_detail,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
    FROM realitky.raw.listing_details_bezrealitky
    WHERE listing_details_bezrealitky.del_flag = false
) AS source
ON target.property_id = source.property_id
  AND target.property_mode = source.property_mode
  AND target.src_web = source.src_web
  AND target.del_flag = false
WHEN MATCHED 
    AND target.price_amount <> source.price_amount
    OR target.price_per_sqm <> source.price_per_sqm
    OR target.price_type <> source.price_type
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
