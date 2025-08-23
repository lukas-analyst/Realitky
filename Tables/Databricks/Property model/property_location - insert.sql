-- TRUNCATE TABLE realitky.cleaned.property_location;

INSERT INTO realitky.cleaned.property_location 
(
    property_location_key,
    location_name, 
    desc,

    location_code,
    -- location_code_accordinvest,
    -- location_code_bezrealitky,
    -- location_code_bidli,
    -- location_code_broker,
    -- location_code_gaia,
    -- location_code_century21,
    -- location_code_dreamhouse,
    -- location_code_idnes,
    -- location_code_mm,
    -- location_code_remax,
    -- location_code_sreality,
    -- location_code_tide,
    -- location_code_ulovdomov,
    
    ins_dt,
    upd_dt,
    del_flag
)
VALUES 
(1,     'Nespecifikováno',      'Typ lokality není specifikován',                                       'NEURCENO',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(2,     'Centrum města',        'Centrum města s dobrou občanskou vybaveností a dopravní dostupností',  'CENTRUM',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(3,     'Širší centrum',        'Širší centrum města s velmi dobrou dostupností služeb',                'SIRSE_CENTRUM',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(4,     'Předměstí',            'Předměstské oblasti s řidší zástavbou a klidnějším prostředím',        'PREDMESTI',        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(5,     'Klidná část',          'Klidná část města s minimálním provozem',                              'KLIDNA',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(6,     'Rušná lokalita',       'Lokalita s vyšším dopravním zatížením nebo hlukem',                    'RUSNA',            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(7,     'Výborná lokalita',     'Prestižní lokalita s výbornou infrastrukturou',                        'VYBORNE',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(8,     'Průmyslová zóna',      'Průmyslová nebo komerční zóna',                                        'PRUMYSL',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(9,     'Rekreační oblast',     'Oblast určená především pro rekreaci a odpočinek',                     'REKREACE',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(10,    'Nová zástavba',        'Nově budovaná lokalita s moderní infrastrukturou',                     'NOVA_ZASTAVBA',    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(11,    'Historické centrum',   'Historické jádro města s památkami a kulturními objekty',              'HISTORICKE',       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(12,    'Obchodní zóna',        'Lokalita s koncentrací obchodů a služeb',                              'OBCHODNI',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(13,    'Vilová čtvrť',         'Prestižní vilová čtvrť s rodinnou zástavbou',                          'VILOVA',           CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(14,    'Panelové sídliště',    'Sídliště s panelovou zástavbou',                                       'SIDLISTE',         CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
(15,    'Přírodní prostředí',   'Lokalita v blízkosti přírody, parků nebo lesů',                        'PRIRODA',          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);

-- Update bezrealitky location codes
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = 'Centrum' WHERE property_location_key = 2;
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = 'Okraj' WHERE property_location_key = 4;
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = 'Klidná část' WHERE property_location_key = 5;
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = 'Sídliště' WHERE property_location_key = 14;
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = 'Samota' WHERE property_location_key = 15;
UPDATE realitky.cleaned.property_location SET location_code_bezrealitky = location_code WHERE property_location_key NOT IN (2, 4, 5, 14, 15);

-- Update bidli location codes (bidli does not have specific codes)
UPDATE realitky.cleaned.property_location SET location_code_bidli = 'XNA';

-- Update century21 location codes (century21 does not have specific codes)
UPDATE realitky.cleaned.property_location SET location_code_century21 = 'XNA';

-- Update idnes location codes
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'centrum' WHERE property_location_key = 2;
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'předměstí' WHERE property_location_key = 4;
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'klidná část' WHERE property_location_key = 5;
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'rušná část' WHERE property_location_key = 6;
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'polosamota' WHERE property_location_key = 9;
UPDATE realitky.cleaned.property_location SET location_code_idnes = 'samota' WHERE property_location_key = 15;
UPDATE realitky.cleaned.property_location SET location_code_idnes = location_code WHERE property_location_key NOT IN (2, 4, 5, 6, 9, 15);

-- Update remax location codes
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Centrum obce' WHERE property_location_key = 2;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Okraj obce' WHERE property_location_key = 4;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Klidná část obce' WHERE property_location_key = 5;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Rušná část obce' WHERE property_location_key = 6;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Polosamota' WHERE property_location_key = 9;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Sídliště' WHERE property_location_key = 14;
UPDATE realitky.cleaned.property_location SET location_code_remax = 'Samota' WHERE property_location_key = 15;
UPDATE realitky.cleaned.property_location SET location_code_remax = location_code WHERE property_location_key NOT IN (2, 4, 5, 6, 9, 14, 15);

-- Update ulovdomov location codes
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'centrum města' WHERE property_location_key = 2;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'okraj obce' WHERE property_location_key = 4;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'klidná část' WHERE property_location_key = 5;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'rušná část' WHERE property_location_key = 6;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'polosamota' WHERE property_location_key = 9;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = 'sídliště' WHERE property_location_key = 14;
UPDATE realitky.cleaned.property_location SET location_code_ulovdomov = LOWER(location_code) WHERE property_location_key NOT IN (2, 4, 5, 6, 9, 14);

SELECT * FROM realitky.cleaned.property_location;