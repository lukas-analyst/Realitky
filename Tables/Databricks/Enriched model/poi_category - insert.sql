-- TRUNCATE TABLE realitky.cleaned.poi_category;

INSERT INTO realitky.cleaned.poi_category
(
    category_key,
    category_code,
    category_name,
    category_description,
    category_code_geoapi,
    category_code_google,
    category_code_mapy,
    max_distance_m,
    max_results,
    priority,
    ins_dt,
    upd_dt,
    del_flag
)
VALUES
(1,     'public_transport.bus',    'Autobusová zastávka',      'Veřejná doprava',              'public_transport.bus',      'bus_station',                      NULL, 1000,   3,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'public_transport.tram',   'Tramvajová zastávka',      'Veřejná doprava',              'public_transport.tram',     'transit_station',                  NULL, 1000,   3,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'public_transport.subway', 'Metro stanice',            'Veřejná doprava',              'public_transport.subway',   'subway_station',                   NULL, 2000,   2,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'public_transport.train',  'Železniční stanice',       'Veřejná doprava',              'public_transport.train',    'train_station',                    NULL, 5000,   2,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'catering',                'Restaurace',               'Stravovací zařízení',          'catering',                  'restaurant',                       NULL, 2000,   10, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'commercial',              'Obchod',                   'Nákupní možnosti',             'commercial',                'store,shopping_mall,supermarket',  NULL, 2000,   5,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'education.school',        'Škola/Školka',             'Vzdělávací instituce',         'education.school',          'school',                           NULL, 3000,   2,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'healthcare',              'Zdravotnictví',            'Lékař, nemocnice, lékárna',    'healthcare',                'hospital,doctor',                  NULL, 5000,   5,  1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'sport',                   'Sportoviště',              'Sport a rekreace',             'sport',                     'gym',                              NULL, 5000,   10, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'production.factory',      'Průmysl',                  'Továrny a průmyslové areály',  'production.factory',        NULL,                               NULL, 5000,   2,  4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'airport',                 'Letiště',                  'Letecká doprava',              'airport',                   'airport',                          NULL, 10000,  1,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'power.plant',             'Elektrárna',               'Energetická infrastruktura',   'power.plant',               NULL,                               NULL, 10000,  1,  4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(13,    'power.line',              'Sloup vysokého napětí',    'Energetická infrastruktura',   'power.line',                NULL,                               NULL, 1000,   1,  4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(14,    'highway',                 'Cesty',                    'Silniční infrastruktura',      'highway',                   NULL,                               NULL, 1000,   5,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(15,    'highway.motorway',        'Dálnice',                  'Silniční infrastruktura',      'highway.motorway',          NULL,                               NULL, 10000,  2,  2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);