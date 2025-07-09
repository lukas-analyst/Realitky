Table property_construction_type {
  property_construction_type_id smallint [pk, increment, note: 'Unikátní identifikátor typu konstrukce']
  
  construction_name varchar(100) [not null, note: 'Název typu konstrukce']
  construction_code varchar(50) [note: 'Kód typu (např. PANEL, CIHLA, DREVO)']
  description text [note: 'Popis typu konstrukce']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  Note: 'Číselník typů konstrukce (panel, cihla, dřevo, smíšené)'
}