-- TRUNCATE TABLE realitky.cleaned.property_subtype;

INSERT INTO realitky.cleaned.property_subtype 
(
    property_subtype_key, 

    subtype_name, 
    desc, 
    
    subtype_code,
    -- subtype_accordinvest,
    -- subtype_bezrealitky,
    -- subtype_bidli,
    -- subtype_broker,
    -- subtype_gaia,
    -- subtype_century21,
    -- subtype_dreamhouse,
    -- subtype_gaia,
    -- subtype_housevip,
    -- subtype_idnes,
    -- subtype_mm,
    -- subtype_remax,
    -- subtype_sreality,
    -- subtype_tide,
    -- subtype_ulovdomov,

    ins_dt, 
    upd_dt, 
    del_flag
)
VALUES
    (1,     'Nespecifikováno',     'Podtyp nemovitosti není specifikován.',                                                                                        'NEURCENO',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (2,     '1+kk',                'Byt 1+kk je typ bytu s jedním pokojem a kuchyňským koutem.',                                                                   '1+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (3,     '1+1',                 'Byt 1+1 je typ bytu s jedním pokojem a samostatnou kuchyní.',                                                                  '1+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (4,     '2+kk',                'Byt 2+kk je typ bytu s dvěma pokoji a kuchyňským koutem.',                                                                     '2+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (5,     '2+1',                 'Byt 2+1 je typ bytu se dvěma pokoji a samostatnou kuchyní.',                                                                   '2+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (6,     '3+kk',                'Byt 3+kk je typ bytu se třemi pokoji a kuchyňským koutem.',                                                                    '3+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (7,     '3+1',                 'Byt 3+1 je typ bytu se třemi pokoji a samostatnou kuchyní.',                                                                   '3+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (8,     '4+kk',                'Byt 4+kk je typ bytu se čtyřmi pokoji a kuchyňským koutem.',                                                                   '4+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (9,     '4+1',                 'Byt 4+1 je typ bytu se čtyřmi pokoji a samostatnou kuchyní.',                                                                  '4+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (10,    '5+kk',                'Byt 5+kk je typ bytu s pěti pokoji a kuchyňským koutem.',                                                                      '5+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (11,    '5+1',                 'Byt 5+1 je typ bytu s pěti pokoji a samostatnou kuchyní.',                                                                     '5+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (12,    'Ateliér',             'Ateliér je obytný prostor s pracovním zázemím, často využívaný umělci.',                                                       'ATELIER',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (13,    'Loft',                'Loft je otevřený obytný prostor s vysokými stropy a industriálním vzhledem.',                                                  'LOFT',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (14,    'Řadový dům',          'Řadový dům je typ rodinného domu, který je součástí řady podobných domů.',                                                     'RADOVY DUM',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (15,    'Pole',                'Pole je zemědělská půda určená k pěstování plodin.',                                                                           'POLE',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (16,    'Kancelář',            'Kancelář je prostor určený pro administrativní činnost.',                                                                      'KANCELAR',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (17,    'Garáž',               'Garáž je uzavřený prostor určený pro parkování vozidel.',                                                                      'GARAZ',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (18,    'Sklad',               'Sklad je prostor určený pro uchovávání zboží nebo materiálu.',                                                                 'SKLAD',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (19,    'Chata',               'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.',                                            'CHATA',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (20,    'Zahrada',             'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.',                                             'ZAHRADA',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (21,    'Průmyslový objekt',   'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.',                              'PRUMYSLOVY OBJEKT',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (22,    'Obchodní prostor',    'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.',                                     'OBCHODNI PROSTOR', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (23,    'Restaurace',          'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.',                                             'RESTAURACE',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (24,    'Hotel',               'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.',                                                     'HOTEL',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (25,    'Pozemek',             'Pozemek je část zemského povrchu, která může být využita pro různé účely, jako je stavba, zemědělství nebo rekreace.',         'POZEMEK',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (26,    'Garsoniéra',          'Garsoniéra je malý byt, obvykle s jedním pokojem, který slouží jako obytný prostor a kuchyň.',                                 'GARSONIERA',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (27,    '6+kk',                'Byt 6+kk je typ bytu se šesti pokoji a kuchyňským koutem.',                                                                    '6+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (28,    '6+1',                 'Byt 6+1 je typ bytu se šesti pokoji a samostatnou kuchyní.',                                                                   '6+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (29,    '6+2',                 'Byt 6+2 je typ bytu se šesti pokoji a dvěma kuchyňskými kouty.',                                                               '6+2',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (30,    '7+kk',                'Byt 7+kk je typ bytu se sedmi pokoji a kuchyňským koutem.',                                                                    '7+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (31,    '7+1',                 'Byt 7+1 je typ bytu se sedmi pokoji a samostatnou kuchyní.',                                                                   '7+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (32,    '7+2',                 'Byt 7+2 je typ bytu se sedmi pokoji a dvěma kuchyňskými kouty.',                                                               '7+2',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (33,    '8+kk',                'Byt 8+kk je typ bytu s osmi pokoji a kuchyňským koutem.',                                                                      '8+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (34,    '8+1',                 'Byt 8+1 je typ bytu s osmi pokoji a samostatnou kuchyní.',                                                                     '8+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (35,    '8+2',                 'Byt 8+2 je typ bytu s osmi pokoji a dvěma kuchyňskými kouty.',                                                                 '8+2',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (36,    '9+kk',                'Byt 9+kk je typ bytu s devíti pokoji a kuchyňským koutem.',                                                                    '9+KK',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (37,    '9+1',                 'Byt 9+1 je typ bytu s devíti pokoji a samostatnou kuchyní.',                                                                   '9+1',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (38,    '9+2',                 'Byt 9+2 je typ bytu s devíti pokoji a dvěma kuchyňskými kouty.',                                                               '9+2',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (39,    'Větší než 9+2',       'Byt s více než devíti pokoji a dvěma kuchyňskými kouty.',                                                                      'VETSI NEZ 9+2',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (40,    'Atypický',            'Atypický byt je neobvyklý nebo jedinečný byt, který se neshoduje s běžnými standardy.',                                        'ATYPICKY',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (41,    'Studio',              'Studio je malý obytný prostor, obvykle s jedním otevřeným prostorem, který kombinuje obývací pokoj, ložnici a kuchyň.',        'STUDIO',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (42,    'Louka',               'Louka je otevřený prostor pokrytý trávou a jinými rostlinami, obvykle využívaný pro pastvu nebo jako přírodní biotop.',        'LOUKA',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (43,    'Les',                 'Lesy jsou rozsáhlé oblasti pokryté stromy a dalšími rostlinami, které slouží jako přírodní habitat pro různé druhy živočichů.','LESY',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (44,    'Sklep',               'Sklep je podzemní prostor, obvykle pod budovou, určený pro skladování nebo jako obytný prostor.',                              'SKLEP',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (45,    'Rybník',              'Rybník je uměle vytvořená nebo přirozená vodní plocha určená k chovu ryb nebo jako krajinný prvek.',                           'RYBNIK',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (46,    'Pokoj',               'Pokoj je samostatná místnost určená k bydlení nebo práci.',                                                                    'POKOJ',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (47,    'Ordinace',            'Ordinace je prostor určený pro lékařskou praxi nebo jiné zdravotnické služby.',                                                'ORDINACE',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    (48,    'Zemědělská usedlost', 'Zemědělská usedlost je komplex budov a pozemků určených pro zemědělskou výrobu a chov zvířat.',                                'ZEMEDELSKA USEDLOST',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);


-- Update bezrealitky codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_bezrealitky = 'Chaty a chalupy' WHERE property_subtype_key = 19;
UPDATE realitky.cleaned.property_subtype SET subtype_code_bezrealitky = subtype_code WHERE property_subtype_key NOT IN (19);

-- Update bidli codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_bidli = subtype_code;

-- Update broker codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'rodinný' WHERE property_subtype_key = 14;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'kanceláře' WHERE property_subtype_key = 16;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'výroba' WHERE property_subtype_key = 21;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'obchodní prostory' WHERE property_subtype_key = 22;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'ubytování' WHERE property_subtype_key = 24;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'pozemek' WHERE property_subtype_key = 25;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = 'vila' WHERE property_subtype_key = 39;
UPDATE realitky.cleaned.property_subtype SET subtype_code_broker = LOWER(subtype_name) WHERE property_subtype_key NOT IN (14, 16, 21, 22, 24, 25, 39);


-- Update century21 codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'studio' WHERE property_subtype_key = 12;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'kanceláře' WHERE property_subtype_key = 16;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'parkovací stání' WHERE property_subtype_key = 17;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'zahrady' WHERE property_subtype_key = 20;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'výroba' WHERE property_subtype_key = 21;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'obchodní prostory' WHERE property_subtype_key = 22;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'garsonka' WHERE property_subtype_key = 26;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'louky' WHERE property_subtype_key = 42;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'lesy' WHERE property_subtype_key = 43;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = 'sklepy' WHERE property_subtype_key = 44;
UPDATE realitky.cleaned.property_subtype SET subtype_code_century21 = LOWER(subtype_name) WHERE property_subtype_key NOT IN (12, 16, 17, 20, 21, 22, 26, 42, 43, 44);

-- Update housevip codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'apartmány' WHERE property_subtype_key = 12;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'zemědělská půda' WHERE property_subtype_key = 15;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'kanceláře' WHERE property_subtype_key = 16;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'garáže' WHERE property_subtype_key = 17;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'sklady' WHERE property_subtype_key = 18;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'výroba' WHERE property_subtype_key = 21;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'obchodní prostory' WHERE property_subtype_key = 22;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'ubytování' WHERE property_subtype_key = 24;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = 'pozemky pro bydlení' WHERE property_subtype_key = 25;
UPDATE realitky.cleaned.property_subtype SET subtype_code_housevip = LOWER(subtype_name) WHERE property_subtype_key NOT IN (12, 15, 16, 17, 18, 21, 22, 24, 25);

-- Update idnes codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_idnes = subtype_code;

-- Update remax codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Ostatní' WHERE property_subtype_key = 1;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Pro bydlení' WHERE property_subtype_key = 14;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Zemědělská' WHERE property_subtype_key = 15;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Zahrada' WHERE property_subtype_key = 20;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Pro komerční výstavbu' WHERE property_subtype_key = 22;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Trvalý travní porost' WHERE property_subtype_key = 42;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = 'Les' WHERE property_subtype_key = 43;
UPDATE realitky.cleaned.property_subtype SET subtype_code_remax = LOWER(subtype_code) WHERE property_subtype_key NOT IN (1, 14, 15, 20, 22, 42, 43);

-- Update sreality codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_sreality = 'Rodinný' WHERE property_subtype_key = 14;
UPDATE realitky.cleaned.property_subtype SET subtype_code_sreality = LOWER(subtype_code) WHERE property_subtype_key NOT IN (14);

-- Update ulovdomov codes
UPDATE realitky.cleaned.property_subtype SET subtype_code_ulovdomov = 'rodinný dům' WHERE property_subtype_key = 14;
UPDATE realitky.cleaned.property_subtype SET subtype_code_ulovdomov = 'vila' WHERE property_subtype_key = 39;
UPDATE realitky.cleaned.property_subtype SET subtype_code_ulovdomov = 'Atypický' WHERE property_subtype_key = 40;
UPDATE realitky.cleaned.property_subtype SET subtype_code_ulovdomov = LOWER(subtype_code) WHERE property_subtype_key NOT IN (14, 39, 40);

SELECT * FROM realitky.cleaned.property_subtype;