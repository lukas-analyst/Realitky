// Main property table for dbdiagram.io
// PostgreSQL syntax for real estate properties

Table property {
  property_id varchar(36) [pk, note: 'Unikátní identifikátor nemovitosti (UUID)']
  
  // Basic property information
  property_name varchar(255) [not null, note: 'Název nemovitosti (např. "Prodej bytu 2+kk v Praze")']
  
  // Address information
  address_street varchar(255) [not null, note: 'Ulice']
  ruian_code varchar(20) [not null, note: 'Kód RÚIAN (pro propojení s demografickými daty ČSÚ)']
  address_city varchar(100) [not null, note: 'Město/obec']
  address_state varchar(100) [not null, note: 'Kraj/stát']
  address_postal_code varchar(10) [not null, note: 'PSČ']
  address_district_code varchar(20) [note: 'Kód městské části/okresu (pro propojení s demografickými daty ČSÚ)']
  address_latitude decimal(9,6) [not null, note: 'Zeměpisná šířka']
  address_longitude decimal(9,6) [not null, note: 'Zeměpisná délka']
  
  // Property type and subtype (foreign keys)
  property_type_id smallint [not null, ref: > property_type.property_type_id, note: 'Byt, dům, pozemek, komerční (FK na property_type)']
  property_subtype_id smallint [not null, ref: > property_subtype.property_subtype_id, note: '2+kk, řadový, pole, kancelář (FK na property_subtype)']
  
  // Building characteristics
  property_number_of_floors smallint [not null, default: 0, note: 'Počet podlaží (pro domy)']
  property_floor_number smallint [not null, default: 0, note: 'Číslo podlaží (pro byty)']
  property_location varchar(50) [not null, note: 'Centrum, předměstí, klidná část (FK na property_location)']
  property_construction_type varchar(50) [not null, note: 'Panel, cihla, dřevo, smíšené (FK na property_construction_type)']
  
  // Area measurements
  area_total_sqm decimal(10,2) [not null, default: 0, note: 'Celková užitá/zastavěná plocha v m²']
  area_land_sqm decimal(10,2) [not null, default: 0, note: 'Plocha pozemku v m² (pro domy/pozemky)']
  number_of_rooms smallint [not null, default: 0, note: 'Počet místností']
  
  // Building age and condition
  construction_year smallint [not null, default: 0, note: 'Rok výstavby']
  last_reconstruction_year smallint [not null, default: 0, note: 'Rok poslední větší rekonstrukce']
  energy_class_penb char(1) [not null, default: 'G', note: 'Energetická třída (A-G)']
  property_condition varchar(50) [not null, note: 'Stav nemovitosti (novostavba, dobrý, standard, k rekonstrukci, špatný)']
  
  // Utilities and amenities
  property_parking varchar(50) [not null, note: 'Na pozemku, ulici, parkovací stání (FK na property_parking)']
  property_heating_id smallint [not null, ref: > property_heating.property_heating_id, note: 'ID vytápění (FK na property_heating)']
  property_electricity varchar(20) [not null, note: '220V, 380V']
  property_accessibility varchar(50) [not null, note: 'Přístupnost nemovitosti']
  
  // Additional spaces (in square meters)
  property_balcony smallint [not null, default: 0, note: 'Plocha balkonu v m² (pokud je přítomen)']
  property_terrace smallint [not null, default: 0, note: 'Plocha terasy v m² (pokud je přítomna)']
  property_cellar smallint [not null, default: 0, note: 'Plocha sklepa v m² (pokud je přítomen)']
  
  // Building features (boolean flags)
  property_elevator boolean [not null, default: false, note: 'Zda je přítomen výtah (TRUE/FALSE)']
  property_canalization varchar(50) [not null, note: 'Typ kanalizace']
  property_water_supply_id smallint [not null, ref: > property_water_supply.property_water_supply_id, note: 'Typ vody na pozemku (FK na property_water_supply)']
  property_air_conditioning varchar(20) [not null, note: 'Zda je přítomna klimatizace (TRUE/FALSE)']
  property_gas smallint [not null, ref: > property_gas.property_gas_id, note: 'Typ plynu (FK na property_gas)']
  property_internet boolean [not null, default: false, note: 'Zda je přítomen internet (TRUE/FALSE)']
  
  // Property status and ownership
  furnishing_level varchar(50) [not null, note: 'Částečně zařízeno, nezařízeno, plně zařízeno, null']
  ownership_type varchar(50) [not null, note: 'Osobní, družstevní, obecní, státní, jiný']
  is_active_listing boolean [not null, default: true, note: 'Zda je nemovitost aktuálně inzerována']
  source_url varchar(500) [not null, note: 'URL na inzerát']
  description text [not null, note: 'Popis nemovitosti']
  
  // Metadata
  src_web varchar(50) [not null, note: 'Zdrojová webová stránka (např. Sreality, Bezrealitky)']
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    (property_type_id, property_subtype_id) [name: 'idx_property_type_subtype']
    (address_city, address_state) [name: 'idx_property_location']
    (ruian_code) [name: 'idx_property_ruian']
    (address_latitude, address_longitude) [name: 'idx_property_coordinates']
    (construction_year) [name: 'idx_property_construction_year']
    (area_total_sqm) [name: 'idx_property_area']
    (is_active_listing) [name: 'idx_property_active']
    (src_web) [name: 'idx_property_source']
    (ins_dt) [name: 'idx_property_ins_dt']
  }
  
  Note: 'Základní informace o nemovitostech. Hlavní tabulka obsahující všechny důležité údaje o nemovitostech včetně adres, charakteristik a vybavení.'
}

// Referenced lookup tables (partial definitions for foreign keys)
Table property_type {
  property_type_id smallint [pk]
  property_type_name varchar(50) [not null]
  Note: 'Typy nemovitostí (byt, dům, pozemek, komerční)'
}

Table property_subtype {
  property_subtype_id smallint [pk]
  property_subtype_name varchar(50) [not null]
  property_type_id smallint [ref: > property_type.property_type_id]
  Note: 'Podtypy nemovitostí (2+kk, řadový, pole, kancelář)'
}

Table property_heating {
  property_heating_id smallint [pk]
  property_heating_name varchar(50) [not null]
  Note: 'Typy vytápění (ústřední, lokální, tepelné čerpadlo, atd.)'
}

Table property_water_supply {
  property_water_supply_id smallint [pk]
  property_water_supply_name varchar(50) [not null]
  Note: 'Typy zásobování vodou (veřejný vodovod, vlastní studna, atd.)'
}

Table property_gas {
  property_gas_id smallint [pk]
  property_gas_name varchar(50) [not null]
  Note: 'Typy plynu (zemní plyn, propan-butan, bez plynu)'
}
