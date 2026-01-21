-- TRUNCATE TABLE realitky.cleaned.property_gas;

INSERT INTO realitky.cleaned.property_gas 
(
    property_gas_key,

    gas_name, 
    desc, 
    safety_rating, 
    cost_efficiency,

    gas_code,
    -- gas_code_accordinvest,
    -- gas_code_bezrealitky,
    -- gas_code_bidli,
    -- gas_code_broker,
    -- gas_code_gaia,
    -- gas_code_century21,
    -- gas_code_dreamhouse,
    -- gas_code_idnes,
    -- gas_code_mm,
    -- gas_code_remax,
    -- gas_code_sreality,
    -- gas_code_tide,
    -- gas_code_ulovdomov,
    
    ins_dt,
    upd_dt,
    del_flag
)
VALUES 
(1,     'Nespecifikováno',              'Typ plynové přípojky není specifikován',               0,  0,   'NEURCENO',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Zemní plyn - veřejná síť',     'Připojení k veřejné distribuční síti zemního plynu',   5,  4,   'ZEMNI_SIT',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Zemní plyn - přípojka',        'Zemní plyn s vlastní přípojkou k distribuční síti',    5,  4,   'ZEMNI_PRIPOJKA',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Propan-butan - nádrž',         'Propan-butan z nadzemní nebo podzemní nádrže',         4,  3,   'PROPAN_NADRZ',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Propan-butan - lahve',         'Propan-butan z výměnných lahví',                       3,  2,   'PROPAN_LAHVE',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Bioplyn - vlastní výroba',     'Bioplyn z vlastní bioplynové stanice',                 4,  5,   'BIOPLYN',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Stlačený zemní plyn (CNG)',    'Stlačený zemní plyn pro speciální použití',            4,  3,   'CNG',               CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Zkapalněný zemní plyn (LNG)',  'Zkapalněný zemní plyn pro větší spotřebiče',           4,  4,   'LNG',               CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Bez plynu',                    'Nemovitost bez plynové přípojky',                      5,  5,   'ZADNY',             CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Připraveno pro plyn',          'Nemovitost připravena pro budoucí plynovou přípojku',  5,  3,   'PRIPRAVENO',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes (bezrealitky does not have specific codes)
UPDATE realitky.cleaned.property_gas SET gas_code_bezrealitky = 'XNA';

-- Update bidli codes
UPDATE realitky.cleaned.property_gas SET gas_code_bidli = 'V dosahu' WHERE property_gas_key = 2;
UPDATE realitky.cleaned.property_gas SET gas_code_bidli = 'Zaveden' WHERE property_gas_key = 3;
UPDATE realitky.cleaned.property_gas SET gas_code_bidli = 'Není' WHERE property_gas_key = 9;
UPDATE realitky.cleaned.property_gas SET gas_code_bidli = gas_code WHERE property_gas_key NOT IN (2, 3, 9);

-- Update century21 codes
UPDATE realitky.cleaned.property_gas SET gas_code_century21 = 'Nepodařilo se zjistit' WHERE property_gas_key = 1;
UPDATE realitky.cleaned.property_gas SET gas_code_century21 = 'Ano' WHERE property_gas_key = 2;
UPDATE realitky.cleaned.property_gas SET gas_code_century21 = 'Jiný' WHERE property_gas_key = 4;
UPDATE realitky.cleaned.property_gas SET gas_code_century21 = 'Není' WHERE property_gas_key = 9;
UPDATE realitky.cleaned.property_gas SET gas_code_century21 = gas_code WHERE property_gas_key NOT IN (1, 2, 4, 9);

-- Update idnes codes
UPDATE realitky.cleaned.property_gas SET gas_code_idnes = 'nádrž' WHERE property_gas_key = 4;
UPDATE realitky.cleaned.property_gas SET gas_code_idnes = gas_code WHERE property_gas_key NOT IN (4);

-- Update remax codes
UPDATE realitky.cleaned.property_gas SET gas_code_remax = 'Individuální' WHERE property_gas_key = 4;
UPDATE realitky.cleaned.property_gas SET gas_code_remax = 'Plynovod' WHERE property_gas_key = 2;
UPDATE realitky.cleaned.property_gas SET gas_code_remax = gas_code WHERE property_gas_key NOT IN (2, 4);

-- Update sreality codes
UPDATE realitky.cleaned.property_gas SET gas_code_sreality = 'individuální' WHERE property_gas_key = 4;
UPDATE realitky.cleaned.property_gas SET gas_code_sreality = 'plynovod' WHERE property_gas_key = 2;
UPDATE realitky.cleaned.property_gas SET gas_code_sreality = gas_code WHERE property_gas_key NOT IN (2, 4);

-- Update ulovdomov codes
UPDATE realitky.cleaned.property_gas SET gas_code_ulovdomov = 'plynovod' WHERE property_gas_key = 2;
UPDATE realitky.cleaned.property_gas SET gas_code_ulovdomov = 'individuální' WHERE property_gas_key = 4;
UPDATE realitky.cleaned.property_gas SET gas_code_ulovdomov = gas_code WHERE property_gas_key NOT IN (2, 4);

SELECT * FROM realitky.cleaned.property_gas;