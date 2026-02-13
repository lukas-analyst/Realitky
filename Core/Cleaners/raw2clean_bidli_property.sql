MERGE INTO realitky.cleaned.property AS target
  USING (
    SELECT DISTINCT
    listing_details_bidli.listing_id AS property_id,
    listing_details_bidli.property_name AS property_name,

    'XNA' AS address_country_code,
    'XNA' AS address_postal_code,
    'XNA' AS address_district_code,
    'XNA' AS address_state,
    'XNA' AS address_city,
    'XNA' AS address_street,
    'XNA' AS address_house_number,
    'XNA' AS address_street_number,
    false AS address_averaged_flag,
    'XNA' AS ruian_code,
    -1 AS ruian_confidence,
    0 AS address_latitude,
    0 AS address_longitude,
    
    COALESCE(property_type.property_type_key, -1) :: BIGINT AS property_type_id,
    COALESCE(property_subtype.property_subtype_key, -1) :: BIGINT AS property_subtype_id,
    -1 AS property_number_of_floors,
    -1 AS property_floor_number,
    -1 AS property_location_id,
    -1 AS property_construction_type_id,
    COALESCE(listing_details_bidli.uzitna_plocha, listing_details_bidli.podlahova_plocha, -1) AS area_total_sqm,
    COALESCE(REGEXP_REPLACE(listing_details_bidli.uzitna_plocha, '[^0-9]', ''), -1) AS area_land_sqm,
    -1 AS number_of_rooms,
    -1 :: SMALLINT AS construction_year,
    -1 :: SMALLINT AS last_reconstruction_year,
    COALESCE(listing_details_bidli.penb, 'X') AS energy_class_penb,
    COALESCE(listing_details_bidli.stav_objektu, 'XNA') AS property_condition,
    -1 AS property_parking_id,
    -1 AS property_heating_id,
    COALESCE(property_electricity.property_electricity_key, -1) AS property_electricity_id,
    -1 AS property_accessibility_id,
    -1 AS property_balcony,
    -1 AS property_terrace,
    -1 AS property_cellar,
    -1 AS property_elevator,
    CASE
        WHEN listing_details_bidli.odpad IN ('Septik','ČOV vlastní') THEN 'jímka'
        WHEN listing_details_bidli.odpad IN ('Veřejná kanalizace','V dosahu') THEN 'kanalizace' 
        ELSE 'XNA'
    END AS property_canalization,
    COALESCE(property_water_supply.property_water_supply_key, -1) AS property_water_supply_id,
    'XNA' AS property_air_conditioning,
    COALESCE(property_gas.property_gas_key, -1) AS property_gas_id,
    -1 AS property_internet,
    'XNA' AS furnishing_level,
    COALESCE(listing_details_bidli.vlastnictvi, 'XNA') AS ownership_type,
    true AS is_active_listing,
    COALESCE(listing_details_bidli.reserved, False) AS reserved,
    listing_details_bidli.listing_url AS source_url,
    COALESCE(listing_details_bidli.property_description, 'XNA') AS description,
    :cleaner AS src_web,
    current_timestamp() AS ins_dt,
    :process_id AS ins_process_id,
    current_timestamp() AS upd_dt,
    :process_id AS upd_process_id,
    false AS del_flag
        
    FROM realitky.raw.listing_details_bidli
      LEFT JOIN realitky.cleaned.property_type 
        ON 
          CASE
            WHEN UPPER(listing_details_bidli.property_name) LIKE '%RODINN%' THEN 'DUM'
            WHEN UPPER(listing_details_bidli.property_name) RLIKE 'NEBYT|OBCHOD|KOMER' THEN 'KOMERCNI NEMOVITOST'
            WHEN UPPER(listing_details_bidli.property_name) LIKE '%GARÁŽ%' THEN 'GARAZ'
            WHEN UPPER(listing_details_bidli.property_name) RLIKE 'CHAT|CHALUPPOZEM|ZAHRADA' THEN 'POZEMEK'
            WHEN UPPER(listing_details_bidli.property_name) RLIKE 'DOM|DŮM|RD' THEN 'DUM'
            WHEN UPPER(listing_details_bidli.property_name) RLIKE 'BYT|APARTM' THEN 'BYT'
            ELSE NULL
          END = property_type.type_code_bidli
        AND property_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_subtype 
        ON UPPER(listing_details_bidli.dispozice) = property_subtype.subtype_code_bidli
        AND property_subtype.del_flag = false
      LEFT JOIN realitky.cleaned.property_electricity 
        ON 
          listing_details_bidli.elektrina = property_electricity.electricity_code_bidli
          AND property_electricity.del_flag = false
      LEFT JOIN realitky.cleaned.property_water_supply 
        ON 
          CASE 
            WHEN UPPER(listing_details_bidli.voda) RLIKE 'DÁLKOVÝ VODOVOD|V DOSAHU|NA HRANICI' THEN 'VEREJNY'
            ELSE UPPER(listing_details_bidli.voda)
          END = property_water_supply.water_supply_code_bidli
          AND property_water_supply.del_flag = false
      LEFT JOIN realitky.cleaned.property_gas 
        ON 
          listing_details_bidli.plyn = property_gas.gas_code_bidli
          AND property_gas.del_flag = false
      
      INNER JOIN realitky.raw.listings_bidli 
        ON listings_bidli.listing_id = listing_details_bidli.listing_id
        AND listings_bidli.del_flag = false
    WHERE
      listing_details_bidli.del_flag = false
      AND listing_details_bidli.status = "active"
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
    address_country_code,
    address_postal_code,
    address_district_code,
    address_state,
    address_city,
    address_street,
    address_house_number,
    address_street_number,
    address_averaged_flag,
    ruian_code,
    ruian_confidence,
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
    reserved,
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
    source.address_country_code,
    source.address_postal_code,
    source.address_district_code,
    source.address_state,
    source.address_city,
    source.address_street,
    source.address_house_number,
    source.address_street_number,
    source.address_averaged_flag,
    source.ruian_code,
    source.ruian_confidence,
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
    source.reserved,
    source.source_url,
    source.description,
    source.src_web,
    source.ins_dt,
    source.ins_process_id,
    source.upd_dt,
    source.upd_process_id,
    source.del_flag
);