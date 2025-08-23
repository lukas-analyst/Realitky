-- TRUNCATE TABLE realitky.cleaned.property_parking;

INSERT INTO realitky.cleaned.property_parking 
(
    property_parking_key,
    
    parking_name, 
    desc,

    parking_code,
    -- parking_code_accordinvest,
    -- parking_code_bezrealitky,
    -- parking_code_bidli,
    -- parking_code_broker,
    -- parking_code_gaia,
    -- parking_code_century21,
    -- parking_code_dreamhouse,
    -- parking_code_idnes,
    -- parking_code_mm,
    -- parking_code_remax,
    -- parking_code_sreality,
    -- parking_code_tide,
    -- parking_code_ulovdomov,
    
    ins_dt,
    upd_dt,
    del_flag
)
VALUES 
(1,     'Nespecifikováno',          'Typ parkování není specifikován',                  'NEURCENO',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Parkování na pozemku',     'Parkování na vlastním nebo přilehlém pozemku',     'POZEMEK',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Garáž',                    'Uzavřená garáž pro vozidlo',                       'GARAZ',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Krytá garáž',              'Krytá nebo podzemní garáž',                        'GARAZ_KRYTA',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Parkování na ulici',       'Parkování na veřejné komunikaci',                  'ULICE',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Vyhrazené stání',          'Vyhrazené parkovací místo',                        'VYHRAZENE',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Parkovací dům',            'Parkování v parkovacím domě',                      'PARKOVACI_DUM',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Podzemní parkování',       'Podzemní parkovací místa',                         'PODZEMI',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Carport',                  'Zastřešené parkování bez stěn',                    'CARPORT',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Parkování před domem',     'Parkování na veřejném prostranství před domem',    'PRED_DOMEM',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Parkování na dvoře',       'Parkování na společném dvoře',                     'DVUR',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Bez parkování',            'Bez možnosti parkování',                           'ZADNE',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(13,    'Rezidentní parkování',     'Parkování vyhrazené pro rezidenty',                'REZIDENTNI',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(14,    'Parkování za poplatek',    'Parkování za poplatek (parkovací hodiny, karty)',  'PLACENE',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(15,    'Návštěvnické parkování',   'Parkování pro návštěvy',                           'NAVSTEVNICKE',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky parking codes (bezrealitky does not have specific codes)
UPDATE realitky.cleaned.property_parking SET parking_code_bezrealitky = 'XNA';

-- Update bidli parking codes (bidli does not have specific codes)
UPDATE realitky.cleaned.property_parking SET parking_code_bidli = 'XNA';

-- Update century21 parking codes
UPDATE realitky.cleaned.property_parking SET parking_code_century21 = 'Jiné' WHERE property_parking_key = 1;
UPDATE realitky.cleaned.property_parking SET parking_code_century21 = 'Kryté' WHERE property_parking_key = 4;
UPDATE realitky.cleaned.property_parking SET parking_code_century21 = 'Přidělené' WHERE property_parking_key = 6;
UPDATE realitky.cleaned.property_parking SET parking_code_century21 = 'Bez parkování' WHERE property_parking_key = 12;
UPDATE realitky.cleaned.property_parking SET parking_code_century21 = parking_code WHERE property_parking_key NOT IN (1, 4, 6, 12);

-- Update idnes parking codes
UPDATE realitky.cleaned.property_parking SET parking_code_idnes = 'parkování na ulici' WHERE property_parking_key = 5;
UPDATE realitky.cleaned.property_parking SET parking_code_idnes = 'parkovací místo' WHERE property_parking_key = 6;
UPDATE realitky.cleaned.property_parking SET parking_code_idnes = parking_code WHERE property_parking_key NOT IN (5, 6);

-- Update remax parking codes (remax does not have specific codes)
UPDATE realitky.cleaned.property_parking SET parking_code_remax = 'XNA';

-- Update ulovdomov parking codes (ulovdomov does not have specific codes)
UPDATE realitky.cleaned.property_parking SET parking_code_ulovdomov = 'XNA';

SELECT * FROM realitky.cleaned.property_parking;