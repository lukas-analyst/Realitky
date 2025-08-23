Table property_heating {
  property_heating_id smallint [pk, increment, note: 'Unikátní identifikátor typu vytápění']
  
  heating_name varchar(100) [not null, note: 'Název typu vytápění']
  heating_code varchar(50) [note: 'Kód typu (např. PLYN, ELEKTRO, UHELNE)']
  description text [note: 'Popis typu vytápění']
  energy_source varchar(50) [note: 'Zdroj energie (plyn, elektřina, uhlí, dřevo, tepelné čerpadlo)']
  efficiency_rating smallint [note: 'Hodnocení efektivity (1-5)']
  environmental_impact smallint [note: 'Dopad na životní prostředí (1-5, 5=nejlepší)']
  operating_cost_level varchar(20) [note: 'Úroveň provozních nákladů (NIZKA, STREDNI, VYSOKA)']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    (heating_code) [name: 'idx_property_heating_code']
    (energy_source) [name: 'idx_property_heating_source']
    (del_flag) [name: 'idx_property_heating_del_flag']
  }
  
  Note: 'Číselník typů vytápění nemovitostí'
}