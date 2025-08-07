-- TRUNCATE TABLE realitky.cleaned.poi_categories;

INSERT INTO realitky.cleaned.poi_categories
(
    category_code,
    category_name,
    category_description,
    max_distance_m,
    max_results,
    priority,
    ins_dt,
    upd_dt,
    del_flag
)
VALUES
('transport_bus',   'Autobusová zastávka',  'Veřejná doprava - autobus',    1000.0,     10, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('transport_tram',  'Tramvajová zastávka',  'Veřejná doprava - tramvaj',    1000.0,     10, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('transport_metro', 'Metro stanice',        'Veřejná doprava - metro',      2000.0,     5,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('transport_train', 'Železniční stanice',   'Veřejná doprava - vlak',       5000.0,     3,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('restaurant',      'Restaurace',           'Stravovací zařízení',          2000.0,     5,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('shop',            'Obchod',               'Nákupní možnosti',             2000.0,     5,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('school',          'Škola/Školka',         'Vzdělávací instituce',         3000.0,     5,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('healthcare',      'Zdravotnictví',        'Lékař, nemocnice, lékárna',    5000.0,     5,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('sports',          'Sportoviště',          'Sport a rekreace',             5000.0,     10, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('industry',        'Průmysl',              'Továrny a průmyslové areály',  10000.0,    5,  4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('airport',         'Letiště',              'Letecká doprava',              50000.0,    1,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('power_plant',     'Elektrárna',           'Energetická infrastruktura',   20000.0,    1,  4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('highway',         'Dálnice',              'Silniční infrastruktura',      10000.0,    2,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);