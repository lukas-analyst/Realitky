MERGE INTO realitky.stats.listings AS target
USING (
    SELECT
        src_web,
        CURRENT_DATE AS date,
        COUNT(listing_id) AS total_listings,
        COUNT_IF(scraped = true) AS scraped_true,
        COUNT_IF(parsed = true) AS parsed_true,
        COUNT_IF(located = true) AS located_true,
        COUNT_IF(status = 'active') AS status_active,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id
    FROM (
        WITH all_listings AS (
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, status, 'bezrealitky' AS src_web                FROM realitky.raw.listings_bezrealitky lst  LEFT JOIN realitky.raw.listing_details_bezrealitky ldt ON ldt.listing_id = lst.listing_id   AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, status, 'bidli' AS src_web                      FROM realitky.raw.listings_bidli lst        LEFT JOIN realitky.raw.listing_details_bidli ldt ON ldt.listing_id = lst.listing_id         AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, status, 'century21' AS src_web                  FROM realitky.raw.listings_century21 lst    LEFT JOIN realitky.raw.listing_details_century21 ldt ON ldt.listing_id = lst.listing_id     AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, status, 'idnes' AS src_web                      FROM realitky.raw.listings_idnes lst        LEFT JOIN realitky.raw.listing_details_idnes ldt ON ldt.listing_id = lst.listing_id         AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, status, 'remax' AS src_web                      FROM realitky.raw.listings_remax lst        LEFT JOIN realitky.raw.listing_details_remax ldt ON ldt.listing_id = lst.listing_id         AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located,  'inactive' AS status, 'sreality' AS src_web    FROM realitky.raw.listings_sreality lst     LEFT JOIN realitky.raw.listing_details_sreality ldt ON ldt.listing_id = lst.listing_id      AND ldt.del_flag = false WHERE lst.del_flag = false
            UNION ALL
            SELECT DISTINCT lst.listing_id, scraped, parsed, located, ldt.status, 'ulovdomov' AS src_web              FROM realitky.raw.listings_ulovdomov lst    LEFT JOIN realitky.raw.listing_details_ulovdomov ldt ON ldt.listing_id = lst.listing_id     AND ldt.del_flag = false WHERE lst.del_flag = false
        )
        SELECT * FROM all_listings
    )
    GROUP BY src_web
) AS source
ON target.src_web = source.src_web AND target.date = source.date
WHEN MATCHED THEN UPDATE SET
    target.total_listings = source.total_listings,
    target.scraped_true = source.scraped_true,
    target.parsed_true = source.parsed_true,
    target.located_true = source.located_true,
    target.status_active = source.status_active,
    target.upd_dt = source.upd_dt,
    target.upd_process_id = source.upd_process_id
WHEN NOT MATCHED THEN INSERT (
    date, src_web, total_listings, scraped_true, parsed_true, located_true, status_active,
    ins_dt, ins_process_id, upd_dt, upd_process_id, del_flag
) VALUES (
    source.date, source.src_web, source.total_listings, source.scraped_true, source.parsed_true, source.located_true, source.status_active,
    current_timestamp(), :process_id, source.upd_dt, source.upd_process_id, FALSE
);
