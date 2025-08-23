/* --- ! -------------------------------- ! --- */
/* --- ! --------- STATS TABLES --------- ! --- */
/* --- ! -------------------------------- ! --- */

SELECT * FROM realitky.stats.scrapers ORDER BY date DESC, scraper_name;
SELECT * FROM realitky.stats.property_stats ORDER BY upd_dt DESC;


/* --- ! -------------------------------- ! --- */
/* --- ! --------- CLEAN TABLES --------- ! --- */
/* --- ! -------------------------------- ! --- */

SELECT * FROM realitky.cleaned.property;
SELECT * FROM realitky.cleaned.property WHERE property_id = '684c06d282a6dffed007df09';
SELECT * FROM realitky.cleaned.property_h WHERE current_flag = false order by upd_dt;
SELECT * FROM realitky.cleaned.property_price WHERE property_id = '5610227';
SELECT * FROM realitky.cleaned.property_price_h WHERE current_flag = false order by upd_dt desc;
SELECT * FROM realitky.cleaned.property_image LIMIT 100;
SELECT * FROM realitky.cleaned.property_poi;



SELECT * FROM realitky.cleaned.property_accessibility;
SELECT * FROM realitky.cleaned.property_construction_type;
SELECT * FROM realitky.cleaned.property_electricity;
SELECT * FROM realitky.cleaned.property_gas;
SELECT * FROM realitky.cleaned.property_heating;
SELECT * FROM realitky.cleaned.property_location;
SELECT * FROM realitky.cleaned.property_parking;
SELECT * FROM realitky.cleaned.property_subtype;
SELECT * FROM realitky.cleaned.property_type order by property_type_id;
SELECT * FROM realitky.cleaned.property_water_supply;

SELECT * FROM realitky.cleaned.property_poi;
SELECT * FROM realitky.cleaned.poi_category;

update realitky.cleaned.poi_category set category_code = 'airport.international' WHERE category_key = 11

/* --- ! ------------------------------ ! --- */
/* --- ! --------- RAW TABLES --------- ! --- */
/* --- ! ------------------------------ ! --- */

SELECT * FROM realitky.raw.listings_bezrealitky ORDER BY ins_dt;
SELECT * FROM realitky.raw.listings_bidli ORDER BY ins_dt;
SELECT * FROM realitky.raw.listings_century21 ORDER BY ins_dt;
SELECT * FROM realitky.raw.listings_idnes WHERE upd_check_date = '2025-08-14'; --5956
SELECT * FROM realitky.raw.listings_remax ORDER BY listing_id;
SELECT * FROM realitky.raw.listings_sreality ORDER BY listing_id;
SELECT * FROM realitky.raw.listings_ulovdomov WHERE gps_coordinates_raw not like '{%' ;

SELECT * FROM realitky.raw.listing_details_bezrealitky;
SELECT * FROM realitky.raw.listing_images_bezrealitky;
SELECT count(distinct listing_id) FROM realitky.raw.listing_details_bidli where status = 'active';
SELECT * FROM realitky.raw.listing_images_bidli;
SELECT * FROM realitky.raw.listing_details_century21;
SELECT * FROM realitky.raw.listing_images_century21;
SELECT * FROM realitky.raw.listing_details_idnes;
SELECT * FROM realitky.raw.listing_images_idnes;
SELECT * FROM realitky.raw.listing_details_remax;
SELECT * FROM realitky.raw.listing_images_remax;
SELECT * FROM realitky.raw.listing_details_sreality;
SELECT * FROM realitky.raw.listing_images_sreality;
SELECT * FROM realitky.raw.listing_details_ulovdomov WHERE listing_id = '4597646';
SELECT * FROM realitky.raw.listing_images_ulovdomov WHERE listing_id = '5610227';


/*
-----------------------------
-------- DROP TABLES --------
-----------------------------

DROP TABLE realitky.stats.scrapers; ------------------- ##

DROP TABLE realitky.raw.listings_bezrealitky; --------- ##
DROP TABLE realitky.raw.listings_bidli; --------------- ##
DROP TABLE realitky.raw.listings_century21; ----------- ##
DROP TABLE realitky.raw.listings_idnes; --------------- ##
DROP TABLE realitky.raw.listings_remax; --------------- ##
DROP TABLE realitky.raw.listings_sreality; ------------ ##
DROP TABLE realitky.raw.listings_ulovdomov; ------------ ##

DROP TABLE realitky.raw.listing_details_bezrealitky; -- ##
DROP TABLE realitky.raw.listing_details_bidli; -------- ##
DROP TABLE realitky.raw.listing_details_century21; ---- ##
DROP TABLE realitky.raw.listing_details_idnes; -------- ##
DROP TABLE realitky.raw.listing_details_remax; -------- ##
DROP TABLE realitky.raw.listing_details_sreality; ----- ##
DROP TABLE realitky.raw.listing_details_ulovdomov; ----- ##



---------------------------------
-------- TRUNCATE TABLES --------
---------------------------------

TRUNCATE TABLE realitky.stats.scrapers; ------------------- ##

TRUNCATE TABLE realitky.raw.listings_bezrealitky; --------- ##
TRUNCATE TABLE realitky.raw.listings_bidli; --------------- ##
TRUNCATE TABLE realitky.raw.listings_century21; ----------- ##
TRUNCATE TABLE realitky.raw.listings_idnes; --------------- ##
TRUNCATE TABLE realitky.raw.listings_remax; --------------- ##
TRUNCATE TABLE realitky.raw.listings_sreality; ------------ ##
TRUNCATE TABLE realitky.raw.listings_ulovdomov; ------------ ##

TRUNCATE TABLE realitky.raw.listing_details_bezrealitky; -- ##
TRUNCATE TABLE realitky.raw.listing_details_bidli; -------- ##
TRUNCATE TABLE realitky.raw.listing_details_century21; ---- ##
TRUNCATE TABLE realitky.raw.listing_details_idnes; -------- ##
TRUNCATE TABLE realitky.raw.listing_details_remax; -------- ##
TRUNCATE TABLE realitky.raw.listing_details_sreality; ----- ##
TRUNCATE TABLE realitky.raw.listing_details_ulovdomov; ----- ##

*/