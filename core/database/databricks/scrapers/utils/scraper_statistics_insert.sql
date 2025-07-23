MERGE INTO realitky.stats.scrapers AS target
USING (
    SELECT 
        current_date() AS date,
        :scraper_name AS scraper_name,
        :scraped_row_count AS scraped_listings,
        0 AS parsed_listings,
        0 AS cleaned_listings,
        0 AS located_listings,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
) AS source
ON target.date = source.date AND target.scraper_name = source.scraper_name
WHEN MATCHED THEN
    UPDATE SET
        target.scraped_listings = source.scraped_listings,
        target.parsed_listings = source.parsed_listings,
        target.cleaned_listings = source.cleaned_listings,
        target.located_listings = source.located_listings,
        target.upd_dt = source.upd_dt,
        target.upd_process_id = source.upd_process_id,
        target.del_flag = source.del_flag
WHEN NOT MATCHED THEN
    INSERT (
        date, 
        scraper_name, 
        scraped_listings, 
        parsed_listings,
        cleaned_listings,
        located_listings,
        ins_dt,
        ins_process_id,
        upd_dt,
        upd_process_id,
        del_flag
    )
    VALUES (
        source.date,
        source.scraper_name,
        source.scraped_listings, 
        source.parsed_listings,
        source.cleaned_listings,
        source.located_listings,
        source.ins_dt,
        source.ins_process_id,
        source.upd_dt,
        source.upd_process_id,
        source.del_flag
    )