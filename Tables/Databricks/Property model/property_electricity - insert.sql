-- TRUNACATE TABLE realitky.cleaned.property_electricity;

INSERT INTO realitky.cleaned.property_electricity 
(
    property_electricity_key,

    electricity_name, 
    desc, 
    capacity_rating, 

    electricity_code, 
    -- electricity_code_accordinvest,
    -- electricity_code_bezrealitky,
    -- electricity_code_bidli,
    -- electricity_code_broker,
    -- electricity_code_gaia,
    -- electricity_code_century21,
    -- electricity_code_dreamhouse,
    -- electricity_code_housevip,
    -- electricity_code_idnes,
    -- electricity_code_mm,
    -- electricity_code_remax,
    -- electricity_code_sreality,
    -- electricity_code_tide,
    -- electricity_code_ulovdomov,

    ins_dt, 
    upd_dt,
    del_flag
)
VALUES 
(1,     'Nespecifikováno',              'Typ elektrického připojení není specifikován',         -1, 'NEURCENO',     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Standardní 230V',              'Standardní domácí elektrické připojení 230V/50Hz',     3,  '230V',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Silnoproud 400V',              'Třífázové připojení 400V pro vyšší odběr',             5,  '400V',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Maloodběr',                    'Připojení s omezeným příkonem do 3kW',                 1,  'MALOODBER',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Středoodběr',                  'Připojení s příkonem 3-25kW',                          3,  'STREDOODBER',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Velkoodběr',                   'Připojení s vysokým příkonem nad 25kW',                5,  'VELKOODBER',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Bez elektrického připojení',   'Nemovitost není připojena k elektrické síti',          0,  'ZADNE',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Vlastní zdroj',                'Nezávislý zdroj elektřiny (fotovoltaika, generátor)',  4,  'VLASTNI',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Fotovoltaika',                 'Elektrické připojení s fotovoltaickými panely',        4,  'FOTOVOLTAIKA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Nouzové napájení',             'Záložní elektrické napájení (UPS, generátor)',         2,  'NOUZOVE',      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Průmyslové 6kV',               'Vysokonapěťové připojení pro průmyslové objekty',      5,  '6KV',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Inteligentní síť',             'Připojení k inteligentní elektrické síti',             5,  'SMART_GRID',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes (bezrealitky does not have specific codes)
UPDATE realitky.cleaned.property_electricity SET electricity_code_bezrealitky = 'XNA';

-- Update bidli codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_bidli = '230V, 400V (motorový proud)' WHERE property_electricity_key = 5;
UPDATE realitky.cleaned.property_electricity SET electricity_code_bidli = '400V (motorový proud)' WHERE property_electricity_key = 6;
UPDATE realitky.cleaned.property_electricity SET electricity_code_bidli = 'Není' WHERE property_electricity_key = 7;
UPDATE realitky.cleaned.property_electricity SET electricity_code_bidli = electricity_code WHERE property_electricity_key NOT IN (5, 6, 7);

-- Update century21 codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_century21 = '380V' WHERE property_electricity_key = 3;
UPDATE realitky.cleaned.property_electricity SET electricity_code_century21 = 'Není' WHERE property_electricity_key = 7;
UPDATE realitky.cleaned.property_electricity SET electricity_code_century21 = 'Jiný' WHERE property_electricity_key = 8;
UPDATE realitky.cleaned.property_electricity SET electricity_code_century21 = electricity_code WHERE property_electricity_key NOT IN (3, 7, 8);

-- Update housevip codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_housevip = '230V' WHERE property_electricity_key = 2;
UPDATE realitky.cleaned.property_electricity SET electricity_code_housevip = '400V' WHERE property_electricity_key = 3;
UPDATE realitky.cleaned.property_electricity SET electricity_code_housevip = 'bez elektřiny' WHERE property_electricity_key = 7;
UPDATE realitky.cleaned.property_electricity SET electricity_code_housevip = 'vlastní zdroj' WHERE property_electricity_key = 8;
UPDATE realitky.cleaned.property_electricity SET electricity_code_housevip = electricity_code WHERE property_electricity_key NOT IN (2, 3, 7, 8);

-- Update idnes codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_idnes = 'bez elektřiny' WHERE property_electricity_key = 7;
UPDATE realitky.cleaned.property_electricity SET electricity_code_idnes = 'vlastní zdroj' WHERE property_electricity_key = 8;
UPDATE realitky.cleaned.property_electricity SET electricity_code_idnes = electricity_code WHERE property_electricity_key NOT IN (7, 8);

-- Update remax codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_remax = '230 V' WHERE property_electricity_key = 2;
UPDATE realitky.cleaned.property_electricity SET electricity_code_remax = '400 V' WHERE property_electricity_key = 3;
UPDATE realitky.cleaned.property_electricity SET electricity_code_remax = electricity_code WHERE property_electricity_key NOT IN (2, 3);

-- Update sreality codes
UPDATE realitky.cleaned.property_electricity SET electricity_code_sreality = 'bez přípojky' WHERE property_electricity_key = 7;
UPDATE realitky.cleaned.property_electricity SET electricity_code_sreality = electricity_code WHERE property_electricity_key NOT IN (7);

-- Update ulovdomov codes (ulovdomov does not have specific codes)
UPDATE realitky.cleaned.property_electricity SET electricity_code_ulovdomov = 'XNA';

SELECT * FROM realitky.cleaned.property_electricity;