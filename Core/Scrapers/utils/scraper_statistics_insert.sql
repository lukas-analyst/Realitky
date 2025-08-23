MERGE INTO realitky.stats.scrapers AS target
USING (
    SELECT 
        current_date() as date,
        scraper_data.scraper_name,
        0 as scraped_listings,
        0 as parsed_listings,
        0 as cleaned_listings, 
        0 as located_listings,
        current_timestamp() as ins_dt,
        :process_id as ins_process_id,
        current_timestamp() as upd_dt,
        :process_id as upd_process_id,
        false as del_flag
    FROM (
        SELECT 'bezrealitky' as scraper_name WHERE :scraper_bezrealitky = 'True'
        UNION ALL
        SELECT 'bidli' as scraper_name WHERE :scraper_bidli = 'True'
        UNION ALL
        SELECT 'century21' as scraper_name WHERE :scraper_century21 = 'True'
        UNION ALL
        SELECT 'idnes' as scraper_name WHERE :scraper_idnes = 'True'
        UNION ALL
        SELECT 'remax' as scraper_name WHERE :scraper_remax = 'True'
        UNION ALL
        SELECT 'sreality' as scraper_name WHERE :scraper_sreality = 'True'
        UNION ALL
        SELECT 'ulovdomov' as scraper_name WHERE :scraper_ulovdomov = 'True'
    ) AS scraper_data(scraper_name)
) AS source
ON target.date = source.date AND target.scraper_name = source.scraper_name
WHEN MATCHED THEN
    UPDATE SET
        scraped_listings = source.scraped_listings,
        parsed_listings = source.parsed_listings,
        cleaned_listings = source.cleaned_listings,
        located_listings = source.located_listings,
        upd_dt = source.upd_dt,
        upd_process_id = source.upd_process_id
WHEN NOT MATCHED THEN
    INSERT (date, scraper_name, scraped_listings, parsed_listings, cleaned_listings, located_listings, ins_dt, ins_process_id, upd_dt, upd_process_id, del_flag)
    VALUES (source.date, source.scraper_name, source.scraped_listings, source.parsed_listings, source.cleaned_listings, source.located_listings, source.ins_dt, source.ins_process_id, source.upd_dt, source.upd_process_id, source.del_flag)