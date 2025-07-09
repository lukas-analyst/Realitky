Table property_electricity {
  property_electricity_id smallint [pk, increment, note: 'Unikátní identifikátor typu elektřiny']
  
  electricity_name varchar(100) [not null, note: 'Název typu elektřiny']
  electricity_code varchar(50) [note: 'Kód typu (např. 220V, 380V, ZADNY)']
  description text [note: 'Popis typu elektřiny']
  voltage varchar(20) [note: 'Napětí (220V, 380V)']
  capacity_rating smallint [note: 'Hodnocení kapacity (1-5)']
  
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  Note: 'Číselník typů elektrického připojení'
}