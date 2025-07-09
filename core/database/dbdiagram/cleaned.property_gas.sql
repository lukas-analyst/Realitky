Table property_gas {
  property_gas_id smallint [pk, increment, note: 'Unikátní identifikátor typu plynové přípojky']
  
  gas_name varchar(100) [not null, note: 'Název typu plynové přípojky']
  gas_code varchar(50) [note: 'Kód typu (např. ZEMNI, PROPAN, ZADNY)']
  description text [note: 'Popis typu plynové přípojky']
  gas_type varchar(50) [note: 'Typ plynu (zemní, propan-butan, bioplyn)']
  connection_type varchar(50) [note: 'Typ připojení (veřejná síť, nádrž, lahve)']
  safety_rating smallint [note: 'Hodnocení bezpečnosti (1-5)']
  cost_efficiency smallint [note: 'Hodnocení nákladové efektivity (1-5)']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    (gas_code) [name: 'idx_property_gas_code']
    (gas_type) [name: 'idx_property_gas_type']
    (del_flag) [name: 'idx_property_gas_del_flag']
  }
  
  Note: 'Číselník typů plynových přípojek a zdrojů plynu pro nemovitosti'
}