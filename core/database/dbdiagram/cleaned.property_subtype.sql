Table property_subtype {
  property_subtype_id smallint [pk, increment, note: 'Unikátní identifikátor podtypu nemovitosti']
  
  subtype_name varchar(100) [not null, note: 'Název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář)']
  subtype_code varchar(50) [not null, unique, note: 'Kód podtypu nemovitosti (např. "2+kk", "radovy_dum", "pole", "kancelar")']
  description text [note: 'Popis podtypu nemovitosti']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    (subtype_code) [name: 'idx_property_subtype_code']
    (del_flag) [name: 'idx_property_subtype_del_flag']
  }
  
  Note: 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře'
}