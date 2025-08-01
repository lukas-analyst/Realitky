INSERT INTO realitky.cleaned.property_type (
    property_type_key,
    type_name,
    desc,
    type_code_accordinvest,
    type_code_bezrealitky,
    type_code_bidli,
    type_code_broker,
    type_code_gaia,
    type_code_century21,
    type_code_dreamhouse,
    type_code_idnes,
    type_code_mm,
    type_code_remax,
    type_code_sreality,
    type_code_tide,
    type_code_ulovdomov,
    ins_dt,
    upd_dt,
    del_flag
)
VALUES
    (1,  'Byt',                'Byt je samostatná obytná jednotka v budově, která může být součástí většího bytového domu nebo komplexu.', 'BYT',                'Byt',                'BYT',                'byt',                'byt',                'byt',                'byt',                'BYT',                'byt',                'byt',                'byt',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (2,  'Dům',                'Dům je samostatná obytná budova, která může obsahovat jednu nebo více bytových jednotek.',                 'DUM',                'Dům',                'DUM',                'dum',                'dum',                'dum',                'dum',                'DUM',                'dum',                'dum',                'dum',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (3,  'Pozemek',            'Pozemek je kus země, který může být využíván pro různé účely, jako je výstavba, zemědělství nebo rekreace.', 'POZEMEK',          'Pozemek',            'POZEMEK',            'pozemek',            'pozemek',            'pozemek',            'pozemek',            'POZEMEK',            'pozemek',            'pozemek',            'pozemek',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (4,  'Kancelář',           'Kancelář je prostor určený pro administrativní činnost, obvykle v komerční budově.',                       'KANCELAR',           'Kancelář',           'KANCELAR',           'kancelar',           'kancelar',           'kancelar',           'kancelar',           'KANCELAR',           'kancelar',           'kancelar',           'kancelar',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (5,  'Garáž',              'Garáž je uzavřený prostor určený pro parkování vozidel.',                                                  'GARAZ',              'Garáž',              'GARAZ',              'garaz',              'garaz',              'garaz',              'garaz',              'GARAZ',              'garaz',              'garaz',              'garaz',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (6,  'Sklad',              'Sklad je prostor určený pro uchovávání zboží nebo materiálu.',                                             'SKLAD',              'Sklad',              'SKLAD',              'sklad',              'sklad',              'sklad',              'sklad',              'SKLAD',              'sklad',              'sklad',              'sklad',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (7,  'Chata',              'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.',                        'CHATA',              'Chaty a chalupy',    'CHATA',              'chata',              'chata',              'chata',              'chata',              'CHATA',              'chata',              'chata',              'chata',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (8,  'Pole',               'Pole je rozsáhlý kus země, obvykle využívaný pro zemědělské účely, jako je pěstování plodin nebo chov zvířat.', 'POLE',          'Pole',               'POLE',               'pole',               'pole',               'pole',               'pole',               'POLE',               'pole',               'pole',               'pole',               CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (9,  'Zahrada',            'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.',                         'ZAHRADA',            'Zahrada',            'ZAHRADA',            'zahrada',            'zahrada',            'zahrada',            'zahrada',            'ZAHRADA',            'zahrada',            'zahrada',            'zahrada',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (10, 'Průmyslový objekt',  'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.',          'PRUMYSLOVY_OBJEKT',  'Průmyslový objekt',  'PRUMYSLOVY OBJEKT',  'prumyslovy_objekt',  'prumyslovy_objekt',  'prumyslovy_objekt',  'prumyslovy_objekt',  'PRUMYSLOVY OBJEKT',  'prumyslovy_objekt',  'prumyslovy_objekt',  'prumyslovy_objekt',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (11, 'Obchodní prostor',   'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.',                 'OBCHODNI_PROSTOR',   'Obchodní prostor',   'OBCHODNI PROSTOR',   'obchodni_prostor',   'obchodni_prostor',   'obchodni_prostor',   'obchodni_prostor',   'OBCHODNI PROSTOR',   'obchodni_prostor',   'obchodni_prostor',   'obchodni_prostor',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (12, 'Restaurace',         'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.',                         'RESTAURACE',         'Restaurace',         'RESTAURACE',         'restaurace',         'restaurace',         'restaurace',         'restaurace',         'RESTAURACE',         'restaurace',         'restaurace',         'restaurace',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (13, 'Hotel',              'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.',                                 'HOTEL',              'Hotel',              'HOTEL',              'hotel',              'hotel',              'hotel',              'hotel',              'HOTEL',              'hotel',              'hotel',              'hotel',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (14, 'Komerční nemovitost','Komerční nemovitost zahrnuje budovy a pozemky určené pro podnikání, jako jsou kanceláře, obchody a sklady.','KOMERCNI_NEMOVITOST','Nebytový prostor',  'KOMERCNI NEMOVITOST','komercni_nemovitost','komercni_nemovitost','komercni_nemovitost','komercni_nemovitost','KOMERCNI NEMOVITOST','komercni_nemovitost','komercni_nemovitost','komercni_nemovitost',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (15, 'Rekreační objekt',   'Rekreační objekt je nemovitost určená pro rekreaci, jako jsou chaty, chalupy nebo rekreační domy.',        'REKREACNI_OBJEKT',   'Rekreační objekt',   'REKREACNI OBJEKT',   'rekreacni_objekt',   'rekreacni_objekt',   'rekreacni_objekt',   'rekreacni_objekt',   'REKREACNI OBJEKT',   'rekreacni_objekt',   'rekreacni_objekt',   'rekreacni_objekt',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

update realitky.cleaned.property_type set type_code_century21 = 'byty' where property_type_key = 1;
update realitky.cleaned.property_type set type_code_century21 = 'domy' where property_type_key = 2;
update realitky.cleaned.property_type set type_code_century21 = 'pozemky' where property_type_key = 3;
update realitky.cleaned.property_type set type_code_century21 = 'kancelare' where property_type_key = 4;
update realitky.cleaned.property_type set type_code_century21 = 'garaz' where property_type_key = 5;
update realitky.cleaned.property_type set type_code_century21 = 'lisovna' where property_type_key = 10;
update realitky.cleaned.property_type set type_code_century21 = 'komercni' where property_type_key = 14;
update realitky.cleaned.property_type set type_code_century21 = 'komplex' where property_type_key = 15;
update realitky.cleaned.property_type set type_code_century21 = type_code_idnes where property_type_key NOT IN (1, 2, 3, 4, 5, 10, 14, 15);


update realitky.cleaned.property_type set type_code_bezrealitky = type_name