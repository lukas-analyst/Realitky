Table property_accessibility {
  property_accessibility_id smallint [pk, increment, note: 'Unikátní identifikátor typu přístupnosti']
  
  accessibility_name varchar(100) [not null, note: 'Název typu přístupnosti']
  accessibility_code varchar(50) [note: 'Kód typu (např. BEZBARIERY, OMEZENE, STANDARDNI)']
  description text [note: 'Popis typu přístupnosti']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  Note: 'Číselník typů přístupnosti nemovitostí'
}