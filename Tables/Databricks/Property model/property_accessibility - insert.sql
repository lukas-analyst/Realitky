-- TRUNCATE TABLE realitky.cleaned.property_accessibility;

INSERT INTO realitky.cleaned.property_accessibility 
(
    property_accessibility_key,

    accessibility_name,
    desc,

    accessibility_code,
    -- accessibility_code_accordinvest,
    -- accessibility_code_bezrealitky,
    -- accessibility_code_bidli,
    -- accessibility_code_broker,
    -- accessibility_code_gaia,
    -- accessibility_code_century21,
    -- accessibility_code_dreamhouse,
    -- accessibility_code_housevip,
    -- accessibility_code_idnes,
    -- accessibility_code_mm,
    -- accessibility_code_remax,
    -- accessibility_code_sreality,
    -- accessibility_code_tide,
    -- accessibility_code_ulovdomov,

    ins_dt,
    upd_dt,
    del_flag
)
VALUES 
(1,     'Nespecifikováno',          'Typ přístupové cesty není specifikován',               'NEURCENO',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Asfaltová cesta',          'Přístupová cesta z asfaltu',                           'ASFALT',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Betonová cesta',           'Přístupová cesta z betonu',                            'BETON',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Dlážděná cesta',           'Přístupová cesta z dlažby nebo dlažebních kostek',     'DLAZBA',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Zámková dlažba',           'Přístupová cesta ze zámkové dlažby',                   'ZAMKOVA_DLAZBA',   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Štěrková cesta',           'Přístupová cesta ze štěrku',                           'STERK',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Travnatá cesta',           'Přístupová cesta přes travnatý povrch',                'TRAVNIK',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Zemní cesta',              'Nezpevněná zemní přístupová cesta',                    'ZEMNI',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Kamenná cesta',            'Přístupová cesta z přírodního kamene',                 'KAMEN',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Dřevěná cesta',            'Přístupová cesta z dřevěných prvků (prken, dlaždic)',  'DREVO',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Smíšený povrch',           'Kombinace více typů povrchů přístupové cesty',         'SMISENY',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Bez přístupové cesty',     'Nemovitost bez zpevněné přístupové cesty',             'ZADNA',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky codes'
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_bezrealitky = 'XNA';

-- Update bidli codes (bidli does not have specific codes)
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_bidli = 'XNA';

-- Update century21 codes
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Asfaltová' WHERE property_accessibility_key = 2;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Betonová' WHERE property_accessibility_key = 3;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Dlažba' WHERE property_accessibility_key = 4;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Štěrk' WHERE property_accessibility_key = 6;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Nezpevněná' WHERE property_accessibility_key = 7;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = 'Zpevněná' WHERE property_accessibility_key = 8;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_century21 = accessibility_code WHERE property_accessibility_key NOT IN (2, 3, 4, 6, 7, 8);

-- Update housevip codes
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = 'Asfaltová' WHERE property_accessibility_key = 2;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = 'Betonová' WHERE property_accessibility_key = 3;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = 'Dlážděná' WHERE property_accessibility_key = 4;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = 'Štěrková' WHERE property_accessibility_key = 6;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = 'Zpevněná' WHERE property_accessibility_key = 8;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_housevip = accessibility_name WHERE property_accessibility_key NOT IN (2, 3, 4, 6, 8);


-- Update idnes codes
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_idnes = 'asfalt' WHERE property_accessibility_key = 2;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_idnes = 'dlažba' WHERE property_accessibility_key = 4;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_idnes = 'žádné úpravy' WHERE property_accessibility_key = 12;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_idnes = accessibility_code WHERE property_accessibility_key NOT IN (2, 4, 12);

-- Update remax codes (remax does not have specific codes)
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_remax = 'XNA';

-- Update sreality codes
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'asfaltová' WHERE property_accessibility_key = 2;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'betonová' WHERE property_accessibility_key = 3;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'dlážděná' WHERE property_accessibility_key = 4;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'štěrková' WHERE property_accessibility_key = 6;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'zpevněná' WHERE property_accessibility_key = 8;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'šotolina' WHERE property_accessibility_key = 11;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = 'neupravená' WHERE property_accessibility_key = 12;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_sreality = accessibility_code WHERE property_accessibility_key NOT IN (2, 3, 4, 6, 8, 11, 12);


-- Update ulovdomov codes
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'asfaltová' WHERE property_accessibility_key = 2;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'betonová' WHERE property_accessibility_key = 3;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'dlážděná' WHERE property_accessibility_key = 4;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'zpevněná' WHERE property_accessibility_key = 5;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'štěrková' WHERE property_accessibility_key = 6;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = 'neupravená' WHERE property_accessibility_key = 12;
UPDATE realitky.cleaned.property_accessibility SET accessibility_code_ulovdomov = accessibility_code WHERE property_accessibility_key NOT IN (2, 3, 4, 5, 6, 12);

SELECT * FROM realitky.cleaned.property_accessibility;