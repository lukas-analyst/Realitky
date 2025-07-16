Table property_price {
  property_price_id bigint [primary key, increment, note: 'Unikátní identifikátor cenového záznamu']
  
  property_id varchar [not null, ref: > property.property_id, note: 'ID nemovitosti (FK na property)']
  
  price_amount decimal(15,2) [not null, note: 'Celková cena nemovitosti v Kč']
  price_per_sqm decimal(10,2) [note: 'Cena za m² (vypočítaná jako price_amount/area_total_sqm)']
  currency_code varchar [not null, default: 'CZK', note: 'Měna (CZK, EUR, USD)']
  
  price_type varchar [not null, note: 'Typ ceny (VISIBLE - viditelná cena, HIDDEN - skrytá cena)']
  
  price_w_vat decimal(15,2) [note: 'Cena včetně DPH']
  price_wo_vat decimal(15,2) [note: 'Cena bez DPH']
  price_w_commission decimal(15,2) [note: 'Cena včetně provize']
  price_wo_commission decimal(15,2) [note: 'Cena bez provize']
  
  src_web varchar [not null, note: 'Zdrojová webová stránka (např. Sreality, Bezrealitky)']
  ins_dt timestamp [not null, note: 'Datum vložení záznamu']
  ins_process_id varchar [not null, note: 'ID procesu, který vložil záznam']
  upd_dt timestamp [not null, note: 'Datum poslední aktualizace záznamu']
  del_flag boolean [not null, default: false, note: 'Příznak smazání záznamu']

  Indexes {
  (property_id, price_type, del_flag) [name: 'idx_property_price_main']
  }

  Note: 'Aktuální ceny nemovitostí s možností sledování změn cen v čase'
}
