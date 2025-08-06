-- TRUNCATE TABLE realitky.cleaned.property_construction_type;

INSERT INTO realitky.cleaned.property_construction_type 
(
    property_construction_type_key,

    construction_name,
    desc, 

    construction_code, 
    -- construction_code_accordinvest,
    -- construction_code_bezrealitky,
    -- construction_code_bidli,
    -- construction_code_broker,
    -- construction_code_gaia,
    -- construction_code_century21,
    -- construction_code_dreamhouse,
    -- construction_code_idnes,
    -- construction_code_mm,
    -- construction_code_remax,
    -- construction_code_sreality,
    -- construction_code_tide,
    -- construction_code_ulovdomov,

    ins_dt, 
    upd_dt, 
    del_flag
)
VALUES 
(1,     'Nespecifikováno', 'Typ konstrukce není specifikován',                                 'NEURCENO',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Panelová',        'Panelová konstrukce typická pro bytové domy z 70.-80. let',        'PANEL',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Cihlová',         'Klasická cihlová konstrukce s vysokou tepelnou akumulací',         'CIHLA',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Dřevěná',         'Dřevěná konstrukce, včetně roubenek a dřevostaveb',                'DREVO',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Železobetonová',  'Železobetonová monolitická konstrukce',                            'ZELEZO_BETON', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Skeletová',       'Skeletová konstrukce s výplní ze sendvičových panelů',             'SKELET',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Smíšená',         'Kombinace více konstrukčních systémů',                             'SMISENA',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Kamenná',         'Kamenná konstrukce, historické stavby',                            'KAMEN',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Ocelová',         'Ocelová konstrukce, typická pro průmyslové budovy',                'OCEL',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Sendvičová',      'Sendvičové panely s tepelnou izolací',                             'SENDVIC',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Nízkoenergetická','Speciální konstrukce pro nízkoenergetické domy',                   'NIZKOENERGIE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Pasivní dům',     'Konstrukce pasivního domu s minimální energetickou náročností',    'PASIVNI',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Panel' WHERE property_construction_type_key = 2;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Cihla' WHERE property_construction_type_key = 3;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Dřevostavba' WHERE property_construction_type_key = 4;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Skeletová' WHERE property_construction_type_key = 6;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Smíšená' WHERE property_construction_type_key = 7;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = 'Kamenná' WHERE property_construction_type_key = 8;
UPDATE realitky.cleaned.property_construction_type SET construction_code_bezrealitky = construction_code WHERE property_construction_type_key NOT IN (2, 3, 4, 6, 7, 8);

-- Update bidli codes (bidli does not have specific codes)
UPDATE realitky.cleaned.property_construction_type SET construction_code_bidli = 'XNA';

-- Update century21 codes
UPDATE realitky.cleaned.property_construction_type SET construction_code_century21 = 'Dřevostavba' WHERE property_construction_type_key = 4;
UPDATE realitky.cleaned.property_construction_type SET construction_code_century21 = 'PREFABRICATED' WHERE property_construction_type_key = 10;
UPDATE realitky.cleaned.property_construction_type SET construction_code_century21 = construction_code WHERE property_construction_type_key NOT IN (4, 10);

-- Update idnes codes
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'panelová' WHERE property_construction_type_key = 2;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'cihlová' WHERE property_construction_type_key = 3;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'dřevěná' WHERE property_construction_type_key = 4;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'skeletová' WHERE property_construction_type_key = 6;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'smíšená' WHERE property_construction_type_key = 7;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = 'kamenná' WHERE property_construction_type_key = 8;
UPDATE realitky.cleaned.property_construction_type SET construction_code_idnes = construction_code WHERE property_construction_type_key NOT IN (2, 3, 4, 6, 7, 8);

-- Update remax codes
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Panelová' WHERE property_construction_type_key = 2;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Cihlová' WHERE property_construction_type_key = 3;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Dřevěná' WHERE property_construction_type_key = 4;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Skeletová' WHERE property_construction_type_key = 6;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Smíšená' WHERE property_construction_type_key = 7;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = 'Kamenná' WHERE property_construction_type_key = 8;
UPDATE realitky.cleaned.property_construction_type SET construction_code_remax = construction_code WHERE property_construction_type_key NOT IN (2, 3, 4, 6, 7, 8);

-- Update ulovdomov codes
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'panelová' WHERE property_construction_type_key = 2;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'cihlová' WHERE property_construction_type_key = 3;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'dřevěná' WHERE property_construction_type_key = 4;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'skeletová' WHERE property_construction_type_key = 6;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'smíšená' WHERE property_construction_type_key = 7;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'kamenná' WHERE property_construction_type_key = 8;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = 'montovaná' WHERE property_construction_type_key = 11;
UPDATE realitky.cleaned.property_construction_type SET construction_code_ulovdomov = construction_code WHERE property_construction_type_key NOT IN (2, 3, 4, 6, 7, 8, 11);

SELECT * FROM realitky.cleaned.property_construction_type;