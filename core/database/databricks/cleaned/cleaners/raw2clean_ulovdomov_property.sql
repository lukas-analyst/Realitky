MERGE INTO realitky.cleaned.property AS target
  USING (
    SELECT
        listing_details_ulovdomov.listing_url,
        listing_details_ulovdomov.listing_id AS property_id,
        listing_details_ulovdomov.property_name AS property_name,
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
        COALESCE(listing_details_ulovdomov.pocet_podlazi, -1) :: INT AS property_number_of_floors,
        COALESCE(listing_details_ulovdomov.patro, -9) :: INT AS property_floor_number,
        COALESCE(property_location.property_location_key, -1) :: INT AS property_location_id,
        COALESCE(property_construction_type.property_construction_type_key, -1) :: INT AS property_construction_type_id,
        TRY_CAST(REGEXP_REPLACE(COALESCE(LEFT(listing_details_ulovdomov.uzitna_plocha, LENGTH(listing_details_ulovdomov.uzitna_plocha) -3), '-1'), '[^0-9-]', '') AS DOUBLE) AS area_total_sqm,
        TRY_CAST(REGEXP_REPLACE(COALESCE(LEFT(listing_details_ulovdomov.plocha_pozemku, LENGTH(listing_details_ulovdomov.plocha_pozemku) -3), '-1'), '[^0-9-]', '') AS DOUBLE) AS area_land_sqm,
        COALESCE(TRY_CAST(REGEXP_REPLACE(left(pocet_pokoju, 1), '[^0-9]', '') AS INT), -1) AS number_of_rooms,
        CASE
            WHEN listing_details_ulovdomov.rok_vystavby IS null THEN -1
            WHEN listing_details_ulovdomov.rok_vystavby = 0 THEN -1
            ELSE listing_details_ulovdomov.rok_vystavby :: INT
        END AS construction_year,
        CASE
            WHEN listing_details_ulovdomov.rok_rekonstrukce IS null THEN -1
            WHEN listing_details_ulovdomov.rok_rekonstrukce = 0 THEN -1
            ELSE listing_details_ulovdomov.rok_rekonstrukce :: INT
        END AS last_reconstruction_year,
        COALESCE(listing_details_ulovdomov.energeticka_narocnost, 'X') AS energy_class_penb,
        COALESCE(listing_details_ulovdomov.stav_objektu, 'XNA') AS property_condition,
        -1 AS property_parking_id,
        COALESCE(property_heating.property_heating_key, -1) :: INT AS property_heating_id,
        -1 AS property_electricity_id,
        COALESCE(property_accessibility.property_accessibility_key, -1) :: INT AS property_accessibility_id,
        IF(listing_details_ulovdomov.balkon = 'Ano', 1, -1) AS property_balcony,
        IF(listing_details_ulovdomov.terasa = 'Ano', 1, -1) AS property_terrace,
        IF(listing_details_ulovdomov.sklep = 'Ano', 1, -1) AS property_cellar,
        IF(listing_details_ulovdomov.vytah = 'Ano', 1, -1) AS property_elevator,
        CASE
          WHEN listing_details_ulovdomov.odpad IN ('jímka','septik', 'ČOV', 'septik, jímka','jímka, trativod','ČOV, jímka','septik, trativod','trativod') THEN 'jímka'
          WHEN listing_details_ulovdomov.odpad IN ('veřejná kanalizace','veřejná kanalizace, ČOV','veřejná kanalizace, jímka') THEN 'kanalizace'
          ELSE 'XNA'
        END AS property_canalization,
        COALESCE(property_water_supply.property_water_supply_key, -1) :: INT AS property_water_supply_id,
        'XNA' AS property_air_conditioning,
        COALESCE(property_gas.property_gas_key, -1) :: INT AS property_gas_id,
        IF(listing_details_ulovdomov.transport LIKE '%internet', 1, -1) AS property_internet,
        CASE
          WHEN listing_details_ulovdomov.vybaveni = 'vybavené' THEN 'vybaveno'
          WHEN listing_details_ulovdomov.vybaveni = 'nevybavené' THEN 'nevybaveno'
          WHEN listing_details_ulovdomov.vybaveni = 'částečně' THEN 'částečně'
          ELSE 'XNA'
        END AS furnishing_level,
        COALESCE(listing_details_ulovdomov.vlastnictvi, 'XNA') AS ownership_type,
        true AS is_active_listing,
        listing_details_ulovdomov.listing_url AS source_url,
        COALESCE(listing_details_ulovdomov.property_description, 'XNA') AS description,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
        
    FROM realitky.raw.listing_details_ulovdomov
      LEFT JOIN realitky.cleaned.property_type 
        ON 
            listing_details_ulovdomov.typ_nemovitosti = property_type.type_code_ulovdomov
      LEFT JOIN realitky.cleaned.property_subtype 
        ON 
            CASE
                WHEN listing_details_ulovdomov.dispozice = 'chalupa' THEN 'chata'
                ELSE listing_details_ulovdomov.dispozice
            END = property_subtype.subtype_code_ulovdomov
      LEFT JOIN realitky.cleaned.property_location
        ON 
          listing_details_ulovdomov.umisteni_objektu = property_location.location_code_ulovdomov
          AND property_location.del_flag = false
      LEFT JOIN realitky.cleaned.property_construction_type 
        ON
          listing_details_ulovdomov.stavba = property_construction_type.construction_code_ulovdomov
          AND property_construction_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_heating 
        ON 
          CASE
            WHEN listing_details_ulovdomov.vytapeni LIKE '%ústředné plynové%' THEN 'ústřední plynové'
            WHEN listing_details_ulovdomov.vytapeni LIKE '%ústřední dálkové%' THEN 'ústřední plynové'
            WHEN listing_details_ulovdomov.vytapeni LIKE '%lokální elektrické%' THEN 'lokální elektrické'
            WHEN listing_details_ulovdomov.vytapeni LIKE '%ústřední elektrické%' THEN 'ústřední elektrické'
            WHEN listing_details_ulovdomov.vytapeni LIKE '%ústřední tuhá paliva%' THEN 'lokální tuhá paliva'
            WHEN listing_details_ulovdomov.vytapeni LIKE '%podlahové%' THEN 'lokální elektrické'
            ELSE listing_details_ulovdomov.vytapeni
          END  = property_heating.heating_code_ulovdomov
          AND property_heating.del_flag = false
      LEFT JOIN realitky.cleaned.property_accessibility
        ON 
          CASE 
            WHEN listing_details_ulovdomov.cesta LIKE '%betonová%' THEN 'betonová'
            WHEN listing_details_ulovdomov.cesta LIKE '%asfaltová%' THEN 'asfaltová'
            ELSE listing_details_ulovdomov.cesta
          END = property_accessibility.accessibility_code_ulovdomov
          AND property_accessibility.del_flag = false
      LEFT JOIN realitky.cleaned.property_gas
        ON 
          CASE
            WHEN listing_details_ulovdomov.plyn LIKE '%individuální, plynovod%' THEN 'plynovod'
            ELSE listing_details_ulovdomov.plyn
          END = property_gas.gas_code_ulovdomov
          AND property_gas.del_flag = false
      LEFT JOIN realitky.cleaned.property_water_supply
        ON 
          CASE
            WHEN listing_details_ulovdomov.vodni_zdroj LIKE '%vodovod%' THEN 'vodovod'
            WHEN listing_details_ulovdomov.vodni_zdroj LIKE '%studna%' THEN 'studna'
            WHEN listing_details_ulovdomov.vodni_zdroj LIKE '%místní zdroj%' THEN 'místní zdroj'
            ELSE listing_details_ulovdomov.vodni_zdroj
          END = property_water_supply.water_supply_code_ulovdomov
          AND property_water_supply.del_flag = false
    WHERE
      listing_details_ulovdomov.del_flag = false
      AND listing_details_ulovdomov.status = 'active'
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