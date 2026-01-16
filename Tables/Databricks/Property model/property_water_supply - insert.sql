-- TRUNCATE TABLE realitky.cleaned.property_water_supply;

INSERT INTO realitky.cleaned.property_water_supply 
(
    property_water_supply_key,
    water_supply_name, 
    desc,
    is_connected_to_grid, 
    quality_rating,

    water_supply_code,
    -- water_supply_code_accordinvest,
    -- water_supply_code_bezrealitky,
    -- water_supply_code_bidli,
    -- water_supply_code_broker,
    -- water_supply_code_gaia,
    -- water_supply_code_century21,
    -- water_supply_code_dreamhouse,
    -- water_supply_code_idnes,
    -- water_supply_code_mm,
    -- water_supply_code_remax,
    -- water_supply_code_sreality,
    -- water_supply_code_tide,
    -- water_supply_code_ulovdomov,
    
    ins_dt,
    upd_dt,
    del_flag
)
VALUES 
(1, 'Nespecifikováno',  'Typ vodovodní přípojky není specifikován', false,  0,  'NEURCENO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2, 'Veřejný vodovod',  'Připojení k veřejné vodovodní síti',       true,   5,  'VEREJNY',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3, 'Vlastní studna',   'Vlastní kopané nebo vrtané studny',        false,  3,  'STUDNA',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4, 'Artézská studna',  'Artézská studna s vysokou kvalitou vody',  false,  4,  'ARTEZSKA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5, 'Cisterna/nádrž',   'Cisterna nebo nádrž na dešťovou vodu',     false,  2,  'CISTERNA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6, 'Společná studna',  'Společná studna pro více nemovitostí',     false,  3,  'SPOLECNA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7, 'Bez vody',         'Nemovitost bez přípojky vody',             false,  1,  'ZADNA',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes (bezrealitky does not have specific codes)
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_bezrealitky = 'XNA';

-- Update bidli codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_bidli = 'Není' WHERE property_water_supply_key = 1;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_bidli = water_supply_code WHERE property_water_supply_key NOT IN (1);

-- Update century21 codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = 'Jiný zdroj' WHERE property_water_supply_key = 1;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = 'Veřejný vodovod' WHERE property_water_supply_key = 2;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = 'Vlastní studna' WHERE property_water_supply_key = 3;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = 'Společná studna' WHERE property_water_supply_key = 6;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = 'Není' WHERE property_water_supply_key = 7;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_century21 = water_supply_code WHERE property_water_supply_key NOT IN (1, 2, 3, 6, 7);

-- Update idnes codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_idnes = 'vlastní zdroj' WHERE property_water_supply_key = 3;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_idnes = water_supply_code WHERE property_water_supply_key NOT IN (3);

-- Update remax codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_remax = water_supply_code;

-- Update sreality codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_sreality = 'vodovod' WHERE property_water_supply_key = 2;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_sreality = 'místní zdroj vody' WHERE property_water_supply_key = 3;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_sreality = 'retenční nádrž na dešťovou vodu' WHERE property_water_supply_key = 5;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_sreality = water_supply_code WHERE property_water_supply_key NOT IN (2, 3, 5);

-- Update ulovdomov codes
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_ulovdomov = 'vodovod' WHERE property_water_supply_key = 2;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_ulovdomov = 'studna' WHERE property_water_supply_key = 3;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_ulovdomov = 'místní zdroj' WHERE property_water_supply_key = 6;
UPDATE realitky.cleaned.property_water_supply SET water_supply_code_ulovdomov = water_supply_code WHERE property_water_supply_key NOT IN (2, 3, 6);

SELECT * FROM realitky.cleaned.property_water_supply;