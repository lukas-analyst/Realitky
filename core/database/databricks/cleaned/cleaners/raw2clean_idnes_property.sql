MERGE INTO realitky.cleaned.property AS target
USING (
    SELECT
        listing_details_idnes.listing_id AS property_id,
        listing_details_idnes.property_name AS property_name,
        -- address is handled using reverse geolocation --
        'XNA' AS address_street,
        'XNA' AS address_house_number,
        'XNA' AS ruian_code,
        'XNA' AS address_city,
        'XNA' AS address_state,
        'XNA' AS address_postal_code,
        'XNA' AS address_district_code,
        0 AS address_latitude,
        0 AS address_longitude,
        COALESCE(property_type.property_type_key, -1) :: INT AS property_type_id,
        COALESCE(property_subtype.property_subtype_key, -1) :: INT AS property_subtype_id,
        COALESCE(REGEXP_REPLACE(listing_details_idnes.pocet_podlazi, '[^0-9]', ''), -1) :: INT AS property_number_of_floors,
        CASE 
            WHEN listing_details_idnes.podlazi IN ('zvýšené přízemí (1. NP)','přízemí (1. NP = nadzemní podlaží)') THEN 0
            WHEN listing_details_idnes.podlazi IN ('-1. patro, suterén (1. PP = podzemní podlaží)','snížené přízemí (1. PP = podzemní podlaží)') THEN -1
            WHEN listing_details_idnes.podlazi IS null THEN -9
            ELSE REGEXP_EXTRACT(LEFT(listing_details_idnes.podlazi, 3), '(-?[0-9]+)')
        END :: INT AS property_floor_number,
        COALESCE(property_location.property_location_key, -1) :: INT AS property_location_id,
        COALESCE(property_construction_type.property_construction_type_key, -1) :: INT AS property_construction_type_id,
        COALESCE(TRY_CAST(REGEXP_EXTRACT(COALESCE(listing_details_idnes.celkova_plocha, listing_details_idnes.uzitna_plocha), '([0-9]+)', 1) AS DOUBLE), -1) AS area_total_sqm,
        COALESCE(LEFT(listing_details_idnes.plocha_pozemku, LENGTH(listing_details_idnes.plocha_pozemku) -3) :: DOUBLE, -1) AS area_land_sqm,
        COALESCE(listing_details_idnes.pocet_mistnosti, -1) :: INT AS number_of_rooms,
        COALESCE(listing_details_idnes.vystavba_rok, listing_details_idnes.vystavba, listing_details_idnes.kolaudace, -1) :: INT AS construction_year,
        COALESCE(listing_details_idnes.rekonstrukce, -1) :: INT AS last_reconstruction_year,
        COALESCE(LEFT(listing_details_idnes.penb, 1), 'X') AS energy_class_penb,
        COALESCE(listing_details_idnes.stav_budovy, listing_details_idnes.stav_bytu, 'XNA') AS property_condition,
        COALESCE(property_parking.property_parking_key, -1) :: INT AS property_parking_id,
        COALESCE(property_heating.property_heating_key, - 1) :: INT AS property_heating_id,
        COALESCE(property_electricity.property_electricity_key, -1) :: INT AS property_electricity_id,
        COALESCE(property_accessibility.property_accessibility_key, -1) :: INT AS property_accessibility_id,
        CASE
          WHEN listing_details_idnes.balkon = '' THEN 1
          ELSE 0
        END AS property_balcony,
        CASE
          WHEN listing_details_idnes.lodzie = '' THEN 1
          ELSE 0
        END AS property_terrace,
        CASE
          WHEN listing_details_idnes.sklep = '' THEN 1
          ELSE 0
        END AS property_cellar,
        CASE
          WHEN listing_details_idnes.vytah = '' THEN 1
          ELSE 0
        END AS property_elevator,
        CASE
          WHEN COALESCE(listing_details_idnes.odpad, listing_details_idnes.kanalizace) IN ('septik / jímka', 'vlastní čistička') THEN 'jímka'
          WHEN COALESCE(listing_details_idnes.odpad, listing_details_idnes.kanalizace) IN ('veřejná kanalizace', 'septik / jímka, veřejná kanalizace') THEN 'kanalizace' 
          ELSE COALESCE(listing_details_idnes.odpad, listing_details_idnes.kanalizace, 'XNA')
        END AS property_canalization,
        COALESCE(property_water_supply.property_water_supply_key, -1) :: INT AS property_water_supply_id,
        'XNA' AS property_air_conditioning,
        COALESCE(property_gas.property_gas_key, -1) :: INT AS property_gas_id,
        CASE
          WHEN listing_details_idnes.internet = '' THEN 1
          ELSE -1
        END AS property_internet,
        COALESCE(listing_details_idnes.vybaveni, 'XNA') AS furnishing_level,
        COALESCE(listing_details_idnes.vlastnictvi, 'XNA') AS ownership_type,
        true AS is_active_listing,
        listing_details_idnes.listing_url AS source_url,
        COALESCE(listing_details_idnes.property_description, 'XNA') AS description,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
        
    FROM realitky.raw.listing_details_idnes
      LEFT JOIN realitky.cleaned.property_type 
        ON UPPER(REPLACE(SPLIT(listing_details_idnes.listing_url, '/')[size(SPLIT(listing_details_idnes.listing_url, '/')) - 4], '-', ' ')) = property_type.type_code_idnes
      LEFT JOIN realitky.cleaned.property_subtype 
        ON UPPER(listing_details_idnes.property_name) LIKE CONCAT('%', property_subtype.subtype_code_idnes, '%')
      LEFT JOIN realitky.cleaned.property_water_supply 
        ON 
          CASE
            WHEN listing_details_idnes.voda IN ('na hranici pozemku', 'veřejný', 'veřejný, vlastní zdroj') THEN 'VEREJNY' 
            ELSE listing_details_idnes.voda
          END = property_water_supply.water_supply_code_idnes
        AND property_water_supply.del_flag = false
      LEFT JOIN realitky.cleaned.property_electricity 
        ON 
          CASE 
            WHEN listing_details_idnes.elektrina IN ('220V', '230V, zavedena', 'zavedena') THEN '230V'
            WHEN listing_details_idnes.elektrina = '380V' THEN '400V'
            WHEN listing_details_idnes.elektrina IN ('230-400V', '230V, 230-400V', '230V, 230-400V, ') THEN 'STREDOODBER'
            WHEN listing_details_idnes.elektrina = 'bez elektřiny' THEN 'ZADNE'
            WHEN listing_details_idnes.elektrina = 'vlastní zdroj' THEN 'VLASTNI'
            ELSE listing_details_idnes.elektrina
          END = property_electricity.electricity_code_idnes
          AND property_electricity.del_flag = false
      LEFT JOIN realitky.cleaned.property_accessibility 
        ON 
          listing_details_idnes.pristupova_komunikace = property_accessibility.accessibility_code_idnes
          AND property_accessibility.del_flag = false
      LEFT JOIN realitky.cleaned.property_construction_type 
        ON
          listing_details_idnes.konstrukce_budovy = property_construction_type.construction_code_idnes
          AND property_construction_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_heating 
        ON 
          CASE 
            WHEN COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso) IN ('ústřední - dálkové', 'ústřední dálkové') THEN 'DALKOVE'
            WHEN COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso) IN ('lokální - tuhá paliva, ústřední - plynové, ústřední - tuhá paliva', 'ústřední - plynové, ústřední - tuhá paliva', 'ústřední - plynové') THEN 'PLYN_USTREDNI'
            WHEN COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso) IN ('lokální - plyn','plynový kondenzacní kotel', 'plynový kotel') THEN 'PLYN_LOKALNI'
            WHEN COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso) IN ('přímotop, krbová kamna', 'přímotop, krb') THEN 'KRBY'
            WHEN COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso) = 'lokální - elektrické' THEN 'ELEKTRO_LOKALNI'
            ELSE COALESCE(listing_details_idnes.topeni, listing_details_idnes.zdroj_vytapeni, listing_details_idnes.topne_teleso)
          END = property_heating.heating_code_idnes
          AND property_heating.del_flag = false
      LEFT JOIN realitky.cleaned.property_location
        ON 
          COALESCE(lokalita_objektu, lokalita_projektu) = property_location.location_code_idnes
          AND property_location.del_flag = false
      LEFT JOIN realitky.cleaned.property_parking
        ON
          CASE
            WHEN listing_details_idnes.parkovani LIKE 'garáž%' THEN 'GARAZ'
            WHEN listing_details_idnes.parkovani LIKE '%parkování na pozemku' THEN 'POZEMEK'
            ELSE listing_details_idnes.parkovani
          END = property_parking.parking_code_idnes
          AND property_parking.del_flag = false
      LEFT JOIN realitky.cleaned.property_gas
        ON
          CASE
            WHEN listing_details_idnes.plyn IN ('veřejný přívod', 'zaveden') THEN 'ZEMNI_SIT'
            ELSE listing_details_idnes.plyn
          END = property_gas.gas_code_idnes
          AND property_gas.del_flag = false
      INNER JOIN realitky.raw.listings_idnes 
        ON listings_idnes.listing_id = listing_details_idnes.listing_id
        AND listings_idnes.del_flag = false

    WHERE
      listing_details_idnes.del_flag = false
      AND listing_details_idnes.status = 'active'
) AS source
ON target.property_id = source.property_id
AND target.src_web = source.src_web
AND target.del_flag = false
WHEN MATCHED 
AND target.property_name <> source.property_name
 OR target.property_type_id <> source.property_type_id
 OR target.property_subtype_id <> source.property_subtype_id
 OR target.property_number_of_floors <> source.property_number_of_floors
 OR target.property_floor_number <> source.property_floor_number
 OR target.property_location_id <> source.property_location_id
 OR target.property_construction_type_id <> source.property_construction_type_id
 OR target.area_total_sqm <> source.area_total_sqm
 OR target.area_land_sqm <> source.area_land_sqm
 OR target.number_of_rooms <> source.number_of_rooms
 OR target.construction_year <> source.construction_year
 OR target.last_reconstruction_year <> source.last_reconstruction_year
 OR target.energy_class_penb <> source.energy_class_penb
 OR target.property_condition <> source.property_condition
 OR target.property_parking_id <> source.property_parking_id
 OR target.property_heating_id <> source.property_heating_id
 OR target.property_electricity_id <> source.property_electricity_id
 OR target.property_accessibility_id <> source.property_accessibility_id
 OR target.property_balcony <> source.property_balcony
 OR target.property_terrace <> source.property_terrace
 OR target.property_cellar <> source.property_cellar
 OR target.property_elevator <> source.property_elevator
 OR target.property_canalization <> source.property_canalization
 OR target.property_water_supply_id <> source.property_water_supply_id
 OR target.property_air_conditioning <> source.property_air_conditioning
 OR target.property_gas_id <> source.property_gas_id
 OR target.property_internet <> source.property_internet
 OR target.furnishing_level <> source.furnishing_level
 OR target.ownership_type <> source.ownership_type
 OR target.is_active_listing <> source.is_active_listing
 OR target.source_url <> source.source_url
 OR target.description <> source.description
THEN UPDATE SET
    property_name = source.property_name,
    address_street = source.address_street,
    address_house_number = source.address_house_number,
    ruian_code = source.ruian_code,
    address_city = source.address_city,
    address_state = source.address_state,
    address_postal_code = source.address_postal_code,
    address_district_code = source.address_district_code,
    address_latitude = source.address_latitude,
    address_longitude = source.address_longitude,
    property_type_id = source.property_type_id,
    property_subtype_id = source.property_subtype_id,
    property_number_of_floors = source.property_number_of_floors,
    property_floor_number = source.property_floor_number,
    property_location_id = source.property_location_id,
    property_construction_type_id = source.property_construction_type_id,
    area_total_sqm = source.area_total_sqm,
    area_land_sqm = source.area_land_sqm,
    number_of_rooms = source.number_of_rooms,
    construction_year = source.construction_year,
    last_reconstruction_year = source.last_reconstruction_year,
    energy_class_penb = source.energy_class_penb,
    property_condition = source.property_condition,
    property_parking_id = source.property_parking_id,
    property_heating_id = source.property_heating_id,
    property_electricity_id = source.property_electricity_id,
    property_accessibility_id = source.property_accessibility_id,
    property_balcony = source.property_balcony,
    property_terrace = source.property_terrace,
    property_cellar = source.property_cellar,
    property_elevator = source.property_elevator,
    property_canalization = source.property_canalization,
    property_water_supply_id = source.property_water_supply_id,
    property_air_conditioning = source.property_air_conditioning,
    property_gas_id = source.property_gas_id,
    property_internet = source.property_internet,
    furnishing_level = source.furnishing_level,
    ownership_type = source.ownership_type,
    is_active_listing = source.is_active_listing,
    source_url = source.source_url,
    description = source.description,
    src_web = source.src_web,
    upd_dt = source.upd_dt,
    upd_process_id = source.upd_process_id
WHEN NOT MATCHED THEN INSERT (
    property_id,
    property_name,
    address_street,
    address_house_number,
    ruian_code,
    address_city,
    address_state,
    address_postal_code,
    address_district_code,
    address_latitude,
    address_longitude,
    property_type_id,
    property_subtype_id,
    property_number_of_floors,
    property_floor_number,
    property_location_id,
    property_construction_type_id,
    area_total_sqm,
    area_land_sqm,
    number_of_rooms,
    construction_year,
    last_reconstruction_year,
    energy_class_penb,
    property_condition,
    property_parking_id,
    property_heating_id,
    property_electricity_id,
    property_accessibility_id,
    property_balcony,
    property_terrace,
    property_cellar,
    property_elevator,
    property_canalization,
    property_water_supply_id,
    property_air_conditioning,
    property_gas_id,
    property_internet,
    furnishing_level,
    ownership_type,
    is_active_listing,
    source_url,
    description,
    src_web,
    ins_dt,
    ins_process_id,
    upd_dt,
    upd_process_id,
    del_flag
) VALUES (
    source.property_id,
    source.property_name,
    source.address_street,
    source.address_house_number,
    source.ruian_code,
    source.address_city,
    source.address_state,
    source.address_postal_code,
    source.address_district_code,
    source.address_latitude,
    source.address_longitude,
    source.property_type_id,
    source.property_subtype_id,
    source.property_number_of_floors,
    source.property_floor_number,
    source.property_location_id,
    source.property_construction_type_id,
    source.area_total_sqm,
    source.area_land_sqm,
    source.number_of_rooms,
    source.construction_year,
    source.last_reconstruction_year,
    source.energy_class_penb,
    source.property_condition,
    source.property_parking_id,
    source.property_heating_id,
    source.property_electricity_id,
    source.property_accessibility_id,
    source.property_balcony,
    source.property_terrace,
    source.property_cellar,
    source.property_elevator,
    source.property_canalization,
    source.property_water_supply_id,
    source.property_air_conditioning,
    source.property_gas_id,
    source.property_internet,
    source.furnishing_level,
    source.ownership_type,
    source.is_active_listing,
    source.source_url,
    source.description,
    source.src_web,
    source.ins_dt,
    source.ins_process_id,
    source.upd_dt,
    source.upd_process_id,
    source.del_flag
);