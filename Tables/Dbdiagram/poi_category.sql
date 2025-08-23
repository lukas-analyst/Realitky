Table poi_category {
  poi_category_id bigint [pk, increment, note: 'Unikátní identifikátor kategorie POI.']
  category_key bigint [not null, ref: > property_poi.category_key, note: 'Klíč kategorie POI (např. 1, 2, 3).']
  category_code string [not null, note: 'Kód kategorie POI (např. transport_bus, restaurant).']
  category_name string [not null, note: 'Název kategorie POI (např. Autobusová zastávka, Restaurace).']
  category_description string [note: 'Popis kategorie POI (např. zastávka autobusu, restaurace s českou kuchyní).']
  max_distance_m double [note: 'Maximální vzdálenost v metrech pro vyhledávání POI v této kategorii.']
  max_results int [note: 'Maximální počet výsledků pro vyhledávání v této kategorii.']
  priority int [note: 'Priorita kategorie pro řazení výsledků (nižší číslo = vyšší priorita).']
  ins_dt timestamp [not null, note: 'Datum a čas vložení záznamu.']
  upd_dt timestamp [not null, note: 'Datum a čas poslední aktualizace záznamu.']
  del_flag boolean [not null, note: 'Příznak smazání záznamu (TRUE = smazáno, FALSE = aktivní).']

  Note: 'Katalog kategorií POI (např. doprava, stravování, školy)'
}