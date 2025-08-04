-- TRUNCATE TABLE realitky.cleaned.property_type;

INSERT INTO realitky.cleaned.property_type 
(
    property_type_key,

    type_name,
    desc,
    
    type_code,
    -- type_code_accordinvest,
    -- type_code_bezrealitky,
    -- type_code_bidli,
    -- type_code_broker,
    -- type_code_gaia,
    -- type_code_century21,
    -- type_code_dreamhouse,
    -- type_code_idnes,
    -- type_code_mm,
    -- type_code_remax,
    -- type_code_sreality,
    -- type_code_tide,
    -- type_code_ulovdomov,
    
    ins_dt,
    upd_dt,
    del_flag
)
VALUES
    (1,     'Byt',                'Byt je samostatná obytná jednotka v budově, která může být součástí většího bytového domu nebo komplexu.',      'BYT',                  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (2,     'Dům',                'Dům je samostatná obytná budova, která může obsahovat jednu nebo více bytových jednotek.',                      'DUM',                  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (3,     'Pozemek',            'Pozemek je kus země, který může být využíván pro různé účely, jako je výstavba, zemědělství nebo rekreace.',    'POZEMEK',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (4,     'Kancelář',           'Kancelář je prostor určený pro administrativní činnost, obvykle v komerční budově.',                            'KANCELAR',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (5,     'Garáž',              'Garáž je uzavřený prostor určený pro parkování vozidel.',                                                       'GARAZ',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (6,     'Sklad',              'Sklad je prostor určený pro uchovávání zboží nebo materiálu.',                                                  'SKLAD',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (7,     'Chata',              'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.',                             'CHATA',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (8,     'Pole',               'Pole je rozsáhlý kus země, obvykle využívaný pro zemědělské účely, jako je pěstování plodin nebo chov zvířat.', 'POLE',                 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (9,     'Zahrada',            'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.',                              'ZAHRADA',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (10,    'Průmyslový objekt',  'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.',               'PRUMYSLOVY_OBJEKT',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (11,    'Obchodní prostor',   'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.',                      'OBCHODNI_PROSTOR',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (12,    'Restaurace',         'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.',                              'RESTAURACE',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (13,    'Hotel',              'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.',                                      'HOTEL',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (14,    'Komerční nemovitost','Komerční nemovitost zahrnuje budovy a pozemky určené pro podnikání, jako jsou kanceláře, obchody a sklady.',    'KOMERCNI_NEMOVITOST',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (15,    'Rekreační objekt',   'Rekreační objekt je nemovitost určená pro rekreaci, jako jsou chaty, chalupy nebo rekreační domy.',             'REKREACNI_OBJEKT',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes
UPDATE realitky.cleaned.property_type SET type_code_bezrealitky = type_name;

-- Update bidli codes
UPDATE realitky.cleaned.property_type SET type_code_bidli = type_code;

-- Update century21 codes
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'byty' WHERE property_type_key = 1;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'domy' WHERE property_type_key = 2;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'pozemky' WHERE property_type_key = 3;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'kancelare' WHERE property_type_key = 4;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'garaz' WHERE property_type_key = 5;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'lisovna' WHERE property_type_key = 10;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'komercni' WHERE property_type_key = 14;
UPDATE realitky.cleaned.property_type SET type_code_century21 = 'komplex' WHERE property_type_key = 15;
UPDATE realitky.cleaned.property_type SET type_code_century21 = type_code WHERE property_type_key NOT IN (1, 2, 3, 4, 5, 10, 14, 15);

-- Update idnes codes
UPDATE realitky.cleaned.property_type SET type_code_idnes = type_code;

-- Update remax codes
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Byty' WHERE property_type_key = 1;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Domy a vily' WHERE property_type_key = 2;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Pozemky' WHERE property_type_key = 3;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Malé objekty, garáže' WHERE property_type_key = 5;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Chaty a rekreační objekty' WHERE property_type_key = 7;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Zemědělské objekty' WHERE property_type_key = 8;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Historické objekty' WHERE property_type_key = 10;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Hotely, penziony a restaurace' WHERE property_type_key = 13;
UPDATE realitky.cleaned.property_type SET type_code_remax = 'Komerční prostory' WHERE property_type_key = 14;
UPDATE realitky.cleaned.property_type SET type_code_remax = type_code WHERE property_type_key NOT IN (1, 2, 3, 5, 7, 8, 10, 13, 14);


SELECT * FROM realitky.cleaned.property_type;