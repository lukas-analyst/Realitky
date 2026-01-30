-- TRUNCATE TABLE realitky.cleaned.property_heating;

INSERT INTO realitky.cleaned.property_heating 
(
    property_heating_key,

    heating_name, 
    desc, 
    efficiency_rating, 
    environmental_impact, 
    operating_cost_level, 

    heating_code,
    -- heating_code_accordinvest,
    -- heating_code_bezrealitky,
    -- heating_code_bidli,
    -- heating_code_broker,
    -- heating_code_gaia,
    -- heating_code_century21,
    -- heating_code_dreamhouse,
    -- heating_code_housevip,
    -- heating_code_idnes,
    -- heating_code_mm,
    -- heating_code_remax,
    -- heating_code_sreality,
    -- heating_code_tide,
    -- heating_code_ulovdomov,

    ins_dt, 
    upd_dt, 
    del_flag
)
VALUES 
(1,     'Nespecifikováno',              'Typ vytápění není specifikován',           -1, -1, 'XNA',      'NEURCENO',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Plynové ústřední',             'Ústřední vytápění na zemní plyn',          4,  3,  'STREDNI',  'PLYN_USTREDNI',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Plynové lokální',              'Lokální plynové topení (kotle, kamna)',    3,  3,  'STREDNI',  'PLYN_LOKALNI',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Elektrické ústřední',          'Ústřední elektrické vytápění',             4,  2,  'VYSOKA',   'ELEKTRO_USTREDNI',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Elektrické lokální',           'Lokální elektrické topení (kotle, kamna)', 3,  2,  'VYSOKA',   'ELEKTRO_LOKALNI',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Elektrické přímotopné',        'Přímotopné elektrické vytápění',           5,  2,  'VYSOKA',   'ELEKTRO_PRIMOTOP',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Elektrické akumulační',        'Akumulační elektrické vytápění',           4,  2,  'VYSOKA',   'ELEKTRO_AKUMULACE',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Tepelné čerpadlo vzduch-voda', 'Tepelné čerpadlo vzduch-voda',             5,  5,  'NIZKA',    'TC_VZDUCH_VODA',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Tepelné čerpadlo zemní',       'Geotermální tepelné čerpadlo',             5,  5,  'NIZKA',    'TC_ZEMNI',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Dálkové teplo',                'Dálkové vytápění z teplárny',              4,  4,  'STREDNI',  'DALKOVE',              CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Kotel na tuhá paliva',         'Kotel na uhlí, dřevo, pelety',             2,  1,  'STREDNI',  'TUHA_PALIVA',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Krbová kamna',                 'Krbová kamna na dřevo',                    2,  2,  'NIZKA',    'KRBY',                 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(13,    'Solární systém',               'Solární vytápění s doplňkovým zdrojem',    4,  5,  'NIZKA',    'SOLAR',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(14,    'Kombinované vytápění',         'Kombinace více zdrojů vytápění',           4,  3,  'STREDNI',  'KOMBINOVANE',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(15,    'Bez vytápění',                 'Nemovitost bez stálého vytápění',          1,  5,  'NIZKA',    'ZADNE',                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes
UPDATE realitky.cleaned.property_heating SET heating_code_bezrealitky = 'Plynové' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_bezrealitky = heating_code WHERE property_heating_key NOT IN (2);

-- Update bidli codes
UPDATE realitky.cleaned.property_heating SET heating_code_bidli = 'XNA';

-- Update broker codes
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'lokální elektrické' WHERE property_heating_key = 5;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'lokální plynové' WHERE property_heating_key = 3;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'tuhá paliva' WHERE property_heating_key = 11;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'ústřední dálkové' WHERE property_heating_key = 10;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'ústřední elektrické' WHERE property_heating_key = 4;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = 'ústřední plynové' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_broker = LOWER(heating_name) WHERE property_heating_key NOT IN (2, 3, 4, 5, 10, 11);

-- Update century21 codes
UPDATE realitky.cleaned.property_heating SET heating_code_century21 = 'Tepelné čerpadlo' WHERE property_heating_key = 8;
UPDATE realitky.cleaned.property_heating SET heating_code_century21 = heating_code WHERE property_heating_key NOT IN (8);

-- Update housevip codes
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Plynový kotel' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'WAW' WHERE property_heating_key = 3;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Elektrokotel' WHERE property_heating_key = 5;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Přímotop' WHERE property_heating_key = 6;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Infrapanel' WHERE property_heating_key = 7;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Tepelné čerpadlo' WHERE property_heating_key = 8;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Centrální dálkové' WHERE property_heating_key = 10;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = 'Krb' WHERE property_heating_key = 12;
UPDATE realitky.cleaned.property_heating SET heating_code_housevip = heating_name WHERE property_heating_key NOT IN (2, 3, 5, 6, 7, 8, 10, 12);

-- Update idnes codes
UPDATE realitky.cleaned.property_heating SET heating_code_idnes = 'ústřední - elektrické' WHERE property_heating_key = 4;
UPDATE realitky.cleaned.property_heating SET heating_code_idnes = 'elektrokotel' WHERE property_heating_key = 5;
UPDATE realitky.cleaned.property_heating SET heating_code_idnes = 'tepelné čerpadlo' WHERE property_heating_key = 8;
UPDATE realitky.cleaned.property_heating SET heating_code_idnes = 'lokální - tuhá paliva' WHERE property_heating_key = 11;
UPDATE realitky.cleaned.property_heating SET heating_code_idnes = heating_code WHERE property_heating_key NOT IN (4, 5, 8, 11);

-- Update remax codes
UPDATE realitky.cleaned.property_heating SET heating_code_remax = 'Lokální - plynové' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_remax = 'Lokální - plynové, Lokální - tuhá paliva' WHERE property_heating_key = 3;
UPDATE realitky.cleaned.property_heating SET heating_code_remax = 'Ústřední - dálkové' WHERE property_heating_key = 10;
UPDATE realitky.cleaned.property_heating SET heating_code_remax = 'Lokální - tuhá paliva' WHERE property_heating_key = 11;
UPDATE realitky.cleaned.property_heating SET heating_code_remax = heating_code WHERE property_heating_key NOT IN (2, 3, 10, 11);

-- Update sreality codes
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = 'ústřední dálkové' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = 'lokální plynové' WHERE property_heating_key = 3;
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = 'lokální elektrické' WHERE property_heating_key = 5;
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = 'ústřední tuhá paliva' WHERE property_heating_key = 10;
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = 'lokální tuhá paliva' WHERE property_heating_key = 11;
UPDATE realitky.cleaned.property_heating SET heating_code_sreality = heating_code WHERE property_heating_key NOT IN (2, 3, 5, 10, 11);

-- Update ulovdomov codes
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'jiné' WHERE property_heating_key = 1;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'lokální plynové' WHERE property_heating_key = 2;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'ústřední plynové' WHERE property_heating_key = 3;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'ústřední elektrické' WHERE property_heating_key = 4;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'lokální elektrické' WHERE property_heating_key = 5;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = 'lokální tuhá paliva' WHERE property_heating_key = 11;
UPDATE realitky.cleaned.property_heating SET heating_code_ulovdomov = LOWER(heating_name) WHERE property_heating_key NOT IN (1, 2, 3, 4, 5, 11);

SELECT * FROM realitky.cleaned.property_heating;