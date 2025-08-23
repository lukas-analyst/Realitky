Table property_location {
  property_location_id smallint [pk, increment, note: 'Unikátní identifikátor typu lokality']
  
  location_name varchar(100) [not null, note: 'Název typu lokality']
  location_code varchar(50) [note: 'Kód typu (např. CENTRUM, PREDMESTI, KLIDNA)']
  description text [note: 'Popis typu lokality']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  Note: 'Číselník typů lokalit (centrum, předměstí, klidná část)'
}