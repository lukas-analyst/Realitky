Table property_parking {
  property_parking_id smallint [pk, increment, note: 'Unikátní identifikátor typu parkování']
  
  parking_name varchar(100) [not null, note: 'Název typu parkování']
  parking_code varchar(50) [note: 'Kód typu (např. POZEMEK, ULICE, STANI)']
  description text [note: 'Popis typu parkování']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  Note: 'Číselník typů parkování (na pozemku, ulici, parkovací stání)'
}