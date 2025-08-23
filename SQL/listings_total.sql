WITH all_listings AS (
    SELECT DISTINCT 'bezrealitky' AS zdroj, lst.listing_id, scraped, parsed, located, status FROM realitky.raw.listings_bezrealitky lst LEFT JOIN realitky.raw.listing_details_bezrealitky ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'bidli', lst.listing_id, scraped, parsed, located, status FROM realitky.raw.listings_bidli lst LEFT JOIN realitky.raw.listing_details_bidli ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'century21', lst.listing_id, scraped, parsed, located, status FROM realitky.raw.listings_century21 lst LEFT JOIN realitky.raw.listing_details_century21 ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'idnes', lst.listing_id, scraped, parsed, located, status FROM realitky.raw.listings_idnes lst LEFT JOIN realitky.raw.listing_details_idnes ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'remax', lst.listing_id, scraped, parsed, located, status FROM realitky.raw.listings_remax lst LEFT JOIN realitky.raw.listing_details_remax ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'sreality', lst.listing_id, scraped, parsed, located,  'inactive' AS status FROM realitky.raw.listings_sreality lst LEFT JOIN realitky.raw.listing_details_sreality ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
    UNION ALL
    SELECT DISTINCT 'ulovdomov', lst.listing_id, scraped, parsed, located, ldt.status FROM realitky.raw.listings_ulovdomov lst LEFT JOIN realitky.raw.listing_details_ulovdomov ldt ON ldt.listing_id = lst.listing_id AND ldt.del_flag = false WHERE lst.del_flag = false
)
SELECT
    zdroj,
    COUNT(listing_id) AS total_listings,
    COUNT_IF(scraped = true) AS scraped_true,
    COUNT_IF(parsed = true) AS parsed_true,
    COUNT_IF(located = true) AS located_true,
    COUNT_IF(status = 'active') AS status_active
FROM all_listings
GROUP BY zdroj
ORDER BY zdroj;
