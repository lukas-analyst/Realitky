Table property_type {
  property_type_id smallint [pk, increment, note: 'Unikátní identifikátor typu nemovitosti']
  
  type_name varchar(100) [not null, note: 'Název typu nemovitosti (např. byt, dům, pozemek)']
  type_code varchar(50) [not null, unique, note: 'Kód typu nemovitosti (např. "byt", "dum", "pozemek")']
  description text [note: 'Popis typu nemovitosti']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    (type_code) [name: 'idx_property_type_code']
    (del_flag) [name: 'idx_property_type_del_flag']
  }
  
  Note: 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu'
}