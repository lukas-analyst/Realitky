MERGE INTO realitky.cleaned.property AS target
  USING (
    SELECT
        listing_details_remax.listing_url,
        listing_details_remax.listing_id AS property_id,
        listing_details_remax.property_name AS property_name,
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
        COALESCE(listing_details_remax.pocet_podlazi_v_objektu, -1) :: INT AS property_number_of_floors,
        COALESCE(listing_details_remax.cislo_podlazi, -9) :: INT AS property_floor_number,
        COALESCE(property_location.property_location_key, -1) :: INT AS property_location_id,
        COALESCE(property_construction_type.property_construction_type_key, -1) :: INT AS property_construction_type_id,
        TRY_CAST(REGEXP_REPLACE(COALESCE(listing_details_remax.celkova_plocha, listing_details_remax.uzitna_plocha, '-1'), '[^0-9-]', '') AS DOUBLE) AS area_total_sqm,
        TRY_CAST(REGEXP_REPLACE(COALESCE(listing_details_remax.plocha_zahrady, listing_details_remax.plocha_parcely, '-1'), '[^0-9-]', '') AS DOUBLE) AS area_land_sqm,
        -1 AS number_of_rooms,
        COALESCE(listing_details_remax.rok_vystavby, -1) :: INT AS construction_year,
        COALESCE(listing_details_remax.rok_rekonstrukce, -1) :: INT AS last_reconstruction_year,
        COALESCE(LEFT(listing_details_remax.energeticka_narocnost_budovy, 1), 'X') AS energy_class_penb,
        COALESCE(listing_details_remax.stav_objektu, 'XNA') AS property_condition,
        -1 AS property_parking_id,
        COALESCE(property_heating.property_heating_key, -1) :: INT AS property_heating_id,
        COALESCE(property_electricity.property_electricity_key, -1) :: INT AS property_electricity_id,
        -1 AS property_accessibility_id,
        -1 AS property_balcony,
        -1 AS property_terrace,
        -1 AS property_cellar,
        IF(listing_details_remax.vytah = 'Ano', 1, -1) AS property_elevator,
        CASE
          WHEN listing_details_remax.odpad IN ('Septik', 'Kanalizace, Septik') THEN 'jímka'
          WHEN listing_details_remax.odpad IN ('Kanalizace', 'Kanalizace, Čistička odpadních vod pro celý objekt', 'Čistička odpadních vod pro celý objekt') THEN 'kanalizace' 
          ELSE 'XNA'
        END AS property_canalization,
        IF(listing_details_remax.voda IS NOT null, 2, 1) :: INT AS property_water_supply_id,
        'XNA' AS property_air_conditioning,
        COALESCE(listing_details_remax.plyn, -1) :: INT AS property_gas_id,
        IF(listing_details_remax.telekomunikace LIKE '%Internet', 1, -1) AS property_internet,
        IF(listing_details_remax.vybaveno = 'Ano', 'Vybaveno', 'Nevybaveno') AS furnishing_level,
        COALESCE(listing_details_remax.vlastnictvi, 'XNA') AS ownership_type,
        IF(listing_details_remax.status = 'inactive', false, true) AS is_active_listing,
        listing_details_remax.listing_url AS source_url,
        COALESCE(listing_details_remax.property_description, 'XNA') AS description,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
        
    FROM realitky.raw.listing_details_remax
      LEFT JOIN realitky.cleaned.property_type 
        ON 
            CASE 
                WHEN listing_details_remax.typ_nemovitosti = 'Nájemní domy' THEN 'Komerční prostory'
                ELSE listing_details_remax.typ_nemovitosti
            END = property_type.type_code_remax
      LEFT JOIN realitky.cleaned.property_subtype 
        ON 
            COALESCE(listing_details_remax.dispozice, listing_details_remax.druh_pozemku) = property_subtype.subtype_code_remax
      LEFT JOIN realitky.cleaned.property_location
        ON 
          listing_details_remax.umisteni_objektu = property_location.location_code_remax
          AND property_location.del_flag = false
      LEFT JOIN realitky.cleaned.property_construction_type 
        ON
          listing_details_remax.druh_objektu = property_construction_type.construction_code_remax
          AND property_construction_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_heating 
        ON 
          listing_details_remax.topeni = property_heating.heating_code_remax
          AND property_heating.del_flag = false
      LEFT JOIN realitky.cleaned.property_electricity
        ON 
          CASE 
            WHEN listing_details_remax.elektrina IN ('120 V, 230 V', '120 V') THEN '230 V'
            WHEN listing_details_remax.elektrina IN ('230 V, 400 V', '120 V, 230 V, 400 V') THEN '400 V'
            ELSE listing_details_remax.elektrina
          END = property_electricity.electricity_code_remax
          AND property_electricity.del_flag = false
      LEFT JOIN realitky.cleaned.property_gas
        ON 
          CASE 
            WHEN listing_details_remax.plyn = 'Individuální, Plynovod' THEN 'Individuální'
            ELSE listing_details_remax.plyn
          END = property_gas.gas_code_remax
          AND property_gas.del_flag = false
    WHERE
      listing_details_remax.del_flag = false
      AND listing_details_remax.status = 'active'
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
  */