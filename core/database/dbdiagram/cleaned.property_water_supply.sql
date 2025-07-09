Table property_water_supply {
  property_water_supply_id serial [pk, note: 'Unikátní identifikátor typu vodovodní přípojky']
  water_supply_name varchar(100) [not null, note: 'Název typu vodovodní přípojky']
  water_supply_code varchar(20) [note: 'Kód typu (např. VEREJNY, STUDNA, CISTERNA)']
  description text [note: 'Popis typu vodovodní přípojky']
  is_connected_to_grid boolean [note: 'Zda je připojeno k veřejné síti']
  quality_rating smallint [note: 'Hodnocení kvality vody (1-5)']
  ins_dt timestamp [not null, default: `now()`, note: 'Datum vložení záznamu']
  upd_dt timestamp [not null, default: `now()`, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']
  
  indexes {
    water_supply_code
    is_connected_to_grid
    del_flag
  }
  
  Note: 'Číselník typů vodovodních přípojek a zdrojů vody pro nemovitosti'
}