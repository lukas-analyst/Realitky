Table property {
  property_id varchar(255) [pk, note: 'Unikátní identifikátor nemovitosti (UUID)']
  
  property_name varchar(255) [not null, note: 'Název nemovitosti (např. "Prodej bytu 2+kk v Praze")']
  
  address_street varchar(255) [not null, note: 'Ulice']
  ruian_code varchar(20) [not null, note: 'Kód RÚIAN (pro propojení s demografickými daty ČSÚ)']
  address_city varchar(100) [not null, note: 'Město/obec']
  address_state varchar(100) [not null, note: 'Kraj/stát']
  address_postal_code varchar(10) [not null, note: 'PSČ']
  address_district_code varchar(20) [note: 'Kód městské části/okresu (pro propojení s demografickými daty ČSÚ)']
  address_latitude decimal(9,6) [not null, note: 'Zeměpisná šířka']
  address_longitude decimal(9,6) [not null, note: 'Zeměpisná délka']
  
  property_type_id smallint [not null, ref: > property_type.property_type_id, note: 'Byt, dům, pozemek, komerční (FK na property_type)']
  property_subtype_id smallint [not null, ref: > property_subtype.property_subtype_id, note: '2+kk, řadový, pole, kancelář (FK na property_subtype)']
  
  property_number_of_floors smallint [not null, default: 0, note: 'Počet podlaží (pro domy)']
  property_floor_number smallint [not null, default: 0, note: 'Číslo podlaží (pro byty)']
  property_location_id smallint [not null, ref: > property_location.property_location_id, note: 'Typ lokality (FK na property_location)']
  property_construction_type_id smallint [not null, ref: > property_construction_type.property_construction_type_id, note: 'Typ konstrukce (panel, cihla, dřevostavba) (FK na property_construction_type)']
  
  area_total_sqm decimal(10,2) [not null, default: 0, note: 'Celková užitá/zastavěná plocha v m²']
  area_land_sqm decimal(10,2) [not null, default: 0, note: 'Plocha pozemku v m² (pro domy/pozemky)']
  number_of_rooms smallint [not null, default: 0, note: 'Počet místností']
  
  construction_year smallint [not null, default: 0, note: 'Rok výstavby']
  last_reconstruction_year smallint [not null, default: 0, note: 'Rok poslední větší rekonstrukce']
  energy_class_penb char(1) [not null, default: 'G', note: 'Energetická třída (A-G)']
  property_condition varchar(50) [not null, note: 'Stav nemovitosti (novostavba, dobrý, standard, k rekonstrukci, špatný)']
  
  property_parking_id smallint [not null, ref: > property_parking.property_parking_id, note: 'Typ parkování (FK na property_parking)']
  property_heating_id smallint [not null, ref: > property_heating.property_heating_id, note: 'ID vytápění (FK na property_heating)']
  property_electricity_id smallint [not null, ref: > property_electricity.property_electricity_id, note: 'ID elektrické energie (FK na property_electricity)']
  property_accessibility_id smallint [not null, ref: > property_accessibility.property_accessibility_id, note: 'Typ přístupové cesty (FK na property_accessibility)']
  
  property_balcony smallint [not null, default: 0, note: 'Plocha balkonu v m² (pokud je přítomen)']
  property_terrace smallint [not null, default: 0, note: 'Plocha terasy v m² (pokud je přítomna)']
  property_cellar smallint [not null, default: 0, note: 'Plocha sklepa v m² (pokud je přítomen)']
  property_elevator smallint [not null, default: 0, note: 'Zda je přítomen výtah (TRUE/FALSE)']

  property_canalization varchar(255) [not null, note: 'Typ kanalizace']
  property_water_supply_id smallint [not null, ref: > property_water_supply.property_water_supply_id, note: 'Typ vody na pozemku (FK na property_water_supply)']
  property_air_conditioning varchar(20) [not null, note: 'Typ klimatizace']
  property_gas_id smallint [not null, ref: > property_gas.property_gas_id, note: 'Typ plynu (FK na property_gas)']
  property_internet smallint [not null, default: false, note: 'Zda je přítomen internet (TRUE/FALSE)']
  
  furnishing_level varchar(50) [not null, note: 'Částečně zařízeno, nezařízeno, plně zařízeno, null']
  ownership_type varchar(50) [not null, note: 'Osobní, družstevní, obecní, státní, jiný']
  is_active_listing boolean [not null, default: true, note: 'Zda je nemovitost aktuálně inzerována']
  source_url varchar(500) [not null, note: 'URL na inzerát']
  description text [not null, note: 'Popis nemovitosti']
  
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