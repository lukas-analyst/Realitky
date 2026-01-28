MERGE INTO realitky.cleaned.property AS target
  USING (
    SELECT
        listing_details_sreality.listing_url,
        listing_details_sreality.listing_id AS property_id,
        listing_details_sreality.name AS property_name,
        -- address is handled using reverse geolocation --
        'XNA' AS address_street,
        'XNA' AS address_house_number,
        'XNA' AS ruian_code,
        'XNA' AS address_city,
        'XNA' AS address_state,
        'XNA' AS address_country_code,
        'XNA' AS address_postal_code,
        'XNA' AS address_district_code,
        0 AS address_latitude,
        0 AS address_longitude,
        COALESCE(property_type.property_type_key, -1) :: INT AS property_type_id,
        COALESCE(property_subtype.property_subtype_key, -1) :: INT AS property_subtype_id,
        CASE
          WHEN listing_details_sreality.podlazi IS NULL THEN -1
          WHEN listing_details_sreality.podlazi LIKE '%z celkem%' 
            THEN TRY_CAST(
              REGEXP_EXTRACT(listing_details_sreality.podlazi, 'z celkem ([0-9]+)', 1)
              AS INT
            )
          ELSE -1
        END AS property_number_of_floors,
        CASE
          WHEN LOWER(listing_details_sreality.podlazi) = 'přízemí%' THEN 1
          WHEN listing_details_sreality.podlazi RLIKE '^(-?[0-9]+)\\. podlaží' THEN TRY_CAST(REGEXP_EXTRACT(listing_details_sreality.podlazi, '^(-?[0-9]+)\\. podlaží', 1) AS INT)
          WHEN listing_details_sreality.podlazi RLIKE '^(-?[0-9]+)$' THEN TRY_CAST(listing_details_sreality.podlazi AS INT)
          WHEN listing_details_sreality.podlazi RLIKE '^(-?[0-9]+) včetně' THEN TRY_CAST(REGEXP_EXTRACT(listing_details_sreality.podlazi, '^(-?[0-9]+) včetně', 1) AS INT)
          ELSE -9
        END AS property_floor_number,
        COALESCE(property_location.property_location_key, -1) :: INT AS property_location_id,
        COALESCE(property_construction_type.property_construction_type_key, -1) :: INT AS property_construction_type_id,
        TRY_CAST(COALESCE(listing_details_sreality.celkova_plocha, listing_details_sreality.uzitna_ploch, '-1') AS DOUBLE) AS area_total_sqm,
        TRY_CAST(COALESCE(listing_details_sreality.plocha_pozemku, listing_details_sreality.plocha_zahrady, '-1') AS DOUBLE) AS area_land_sqm,
        -1 AS number_of_rooms,
        COALESCE(TRY_CAST(RIGHT(listing_details_sreality.datum_ukonceni_vystavby, 4) AS INT), -1) AS construction_year,
        COALESCE(listing_details_sreality.rok_rekonstrukce, -1) :: INT AS last_reconstruction_year,
        COALESCE(SUBSTRING(listing_details_sreality.energeticka_narocnost_budovy, 7, 1), 'X') AS energy_class_penb,
        COALESCE(listing_details_sreality.stav_objektu, 'XNA') AS property_condition,
        CASE 
          WHEN listing_details_sreality.parkovani IS NULL THEN -1
          WHEN LOWER(listing_details_sreality.parkovani) IN ('ne', 'false', '0') THEN 0
          ELSE 1
        END :: INT AS property_parking_id,
        COALESCE(property_heating.property_heating_key, -1) :: INT AS property_heating_id,
        COALESCE(property_electricity.property_electricity_key, -1) :: INT AS property_electricity_id,
        COALESCE(property_accessibility.property_accessibility_key, -1) :: INT AS property_accessibility_id,
        CASE 
          WHEN listing_details_sreality.balkon IS NULL THEN -1
          WHEN LOWER(listing_details_sreality.balkon) IN ('ne', 'false', '0') THEN 0
          ELSE 1
        END AS property_balcony,
        CASE 
          WHEN COALESCE(listing_details_sreality.lodzie, listing_details_sreality.terasa) IS NULL THEN -1
          WHEN LOWER(COALESCE(listing_details_sreality.lodzie, listing_details_sreality.terasa)) IN ('ne', 'false', '0') THEN 0
          ELSE 1
        END  AS property_terrace,
        CASE 
          WHEN listing_details_sreality.sklep IS NULL THEN -1
          WHEN LOWER(listing_details_sreality.sklep) IN ('ne', 'false', '0') THEN 0
          ELSE 1
        END AS property_cellar,
        CASE
          WHEN listing_details_sreality.vytah = 'True' THEN 1
          WHEN listing_details_sreality.vytah = 'False' THEN 0
          ELSE -1
        END AS property_elevator,
        CASE
          WHEN LOWER(listing_details_sreality.odpad) LIKE '%jímka%' THEN 'jímka'
          WHEN LOWER(listing_details_sreality.odpad) LIKE '%septik%' THEN 'jímka'
          WHEN LOWER(listing_details_sreality.odpad) LIKE '%trativod%' THEN 'jímka'
          WHEN LOWER(listing_details_sreality.odpad) LIKE '%kanalizace%' THEN 'kanalizace'
          WHEN LOWER(listing_details_sreality.odpad) LIKE '%čov%' THEN 'kanalizace'
          ELSE 'XNA'
        END AS property_canalization,
        IF(listing_details_sreality.voda IS NOT null, 2, 1) :: INT AS property_water_supply_id,
        'XNA' AS property_air_conditioning,
        COALESCE(property_gas.property_gas_key, -1) :: INT AS property_gas_id,
        IF(LOWER(listing_details_sreality.telekomunikace) LIKE '%internet%', 1, -1) AS property_internet,
        CASE
          WHEN listing_details_sreality.vybaveni = 'True' THEN 'Vybaveno'
          WHEN listing_details_sreality.vybaveni = 'False' THEN 'Nevybaveno'
          ELSE 'XNA'
        END AS furnishing_level,
        COALESCE(listing_details_sreality.vlastnictvi, 'XNA') AS ownership_type,
        IF(listing_details_sreality.status = 'inactive', false, true) AS is_active_listing,
        COALESCE(listing_details_sreality.reserved, False) AS reserved,
        listing_details_sreality.listing_url AS source_url,
        COALESCE(listing_details_sreality.description, 'XNA') AS description,
        :cleaner AS src_web,
        current_timestamp() AS ins_dt,
        :process_id AS ins_process_id,
        current_timestamp() AS upd_dt,
        :process_id AS upd_process_id,
        false AS del_flag
        
    FROM realitky.raw.listing_details_sreality
      LEFT JOIN realitky.cleaned.property_type 
        ON LOWER(listing_details_sreality.property_type) = property_type.type_code_sreality
          AND property_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_subtype 
        ON
          CASE
            WHEN listing_details_sreality.disposition = 'Chalupa' THEN 'Chata'
            WHEN listing_details_sreality.disposition = 'Neznámé' THEN 'Nespecifikováno'
            ELSE LOWER(listing_details_sreality.disposition)
          END = property_subtype.subtype_code_sreality
          AND property_subtype.del_flag = false
      LEFT JOIN realitky.cleaned.property_location
        ON LOWER(listing_details_sreality.umisteni_objektu) = property_location.location_code_sreality
          AND property_location.del_flag = false
      LEFT JOIN realitky.cleaned.property_construction_type 
        ON LOWER(listing_details_sreality.stavba) = property_construction_type.construction_code_sreality
          AND property_construction_type.del_flag = false
      LEFT JOIN realitky.cleaned.property_heating
        ON 
          CASE 
            WHEN LOWER(listing_details_sreality.topeni) LIKE '%ústřední dálkové%' THEN 'ústřední dálkové'
            WHEN LOWER(listing_details_sreality.topeni) LIKE '%lokální plynové%' THEN 'lokální plynové'
            WHEN LOWER(listing_details_sreality.topeni) LIKE '%lokální elektrické%' THEN 'lokální elektrické'
            WHEN LOWER(listing_details_sreality.topeni) LIKE '%ústřední tuhá paliva%' THEN 'ústřední tuhá paliva'
            WHEN LOWER(listing_details_sreality.topeni) LIKE '%lokální tuhá paliva%' THEN 'lokální tuhá paliva'
            ELSE 'Nespecifikováno'
          END = property_heating.heating_code_sreality
          AND property_heating.del_flag = false
      LEFT JOIN realitky.cleaned.property_electricity
        ON 
          CASE 
            WHEN listing_details_sreality.elektrina LIKE '%120%' THEN '230V'
            WHEN listing_details_sreality.elektrina LIKE '%230%' THEN '230V'
            WHEN listing_details_sreality.elektrina LIKE '%380%' THEN '400V'
            WHEN listing_details_sreality.elektrina LIKE '%400%' THEN '400V'
            WHEN LOWER(listing_details_sreality.elektrina) LIKE '%bez přípojky%' THEN '400V'
            ELSE 'Nespecifikováno'
          END = property_electricity.electricity_code_sreality
          AND property_electricity.del_flag = false
      LEFT JOIN realitky.cleaned.property_gas
        ON 
          CASE 
            WHEN listing_details_sreality.plyn like '%plynovod%' THEN 'plynovod'
            WHEN LOWER(listing_details_sreality.plyn) LIKE '%individuální%' THEN 'individuální'
            ELSE listing_details_sreality.plyn
          END = property_gas.gas_code_sreality
          AND property_gas.del_flag = false
      LEFT JOIN realitky.cleaned.property_water_supply
        ON 
          CASE 
            WHEN LOWER(listing_details_sreality.voda) like '%vodovod%' THEN 'vodovod'
            WHEN LOWER(listing_details_sreality.voda) LIKE '%místní zdroj vody%' THEN 'místní zdroj vody'
            WHEN LOWER(listing_details_sreality.voda) LIKE '%studna%' THEN 'místní zdroj vody'
            WHEN LOWER(listing_details_sreality.voda) LIKE '%retenční nádrž na dešťovou vodu%' THEN 'retenční nádrž na dešťovou vodu'
            ELSE 'NEURCENO'
          END = property_water_supply.water_supply_code_sreality
          AND property_water_supply.del_flag = false
      LEFT JOIN realitky.cleaned.property_accessibility
        ON 
          CASE 
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%asfaltová%' THEN 'asfaltová'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%betonová%' THEN 'betonová'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%dlážděná%' THEN 'dlážděná'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%štěrková%' THEN 'štěrková'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%zpevněná%' THEN 'zpevněná'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%šotolina%' THEN 'šotolina'
            WHEN LOWER(listing_details_sreality.komunikace) LIKE '%neupravená%' THEN 'neupravená'
            ELSE 'NEURCENO'
          END = property_accessibility.accessibility_code_sreality

    WHERE
      listing_details_sreality.del_flag = false
      AND listing_details_sreality.status = 'active'
      AND listing_details_sreality.listing_id NOT IN ('2634167116')

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
  OR target.reserved <> source.reserved
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
      reserved = source.reserved,
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
      address_country_code,
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
      source.address_street,
      source.address_house_number,
      source.ruian_code,
      source.address_city,
      source.address_state,
      source.address_country_code,
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