-- DROP TABLE IF EXISTS realitky.cleaned.property_subtype;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_subtype (
    property_subtype_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor podtypu nemovitosti
    
    subtype_name STRING NOT NULL, -- Název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář)
    subtype_code STRING NOT NULL, -- Kód podtypu nemovitosti (např. "2+kk", "radovy dum", "pole", "kancelar")
    description STRING, -- Popis podtypu nemovitosti
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_subtype IS 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře, včetně odkazu na typ nemovitosti.';

COMMENT ON COLUMN realitky.cleaned.property_subtype.property_subtype_id IS 'Unikátní identifikátor podtypu nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_name IS 'Název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář).';
COMMENT ON COLUMN realitky.cleaned.property_subtype.subtype_code IS 'Kód podtypu nemovitosti (např. "2+kk", "radovy dum", "pole", "kancelar").';
COMMENT ON COLUMN realitky.cleaned.property_subtype.description IS 'Popis podtypu nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_subtype.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_subtype.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_subtype.del_flag IS 'Příznak smazání záznamu.';

-- INSERT DATA INTO TABLE
INSERT INTO realitky.cleaned.property_subtype (subtype_name, subtype_code, description, ins_dt, upd_dt, del_flag)
VALUES
    ('Nespecifikováno', 'NEURCENO', 'Podtyp nemovitosti není specifikován.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('1+kk', '1+KK', 'Byt 1+kk je typ bytu s jedním pokojem a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('1+1', '1+1', 'Byt 1+1 je typ bytu s jedním pokojem a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('2+kk', '2+KK', 'Byt 2+kk je typ bytu s dvěma pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('2+1', '2+1', 'Byt 2+1 je typ bytu se dvěma pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('3+kk', '3+KK', 'Byt 3+kk je typ bytu se třemi pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('3+1', '3+1', 'Byt 3+1 je typ bytu se třemi pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('4+kk', '4+KK', 'Byt 4+kk je typ bytu se čtyřmi pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('4+1', '4+1', 'Byt 4+1 je typ bytu se čtyřmi pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('5+kk', '5+KK', 'Byt 5+kk je typ bytu s pěti pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('5+1', '5+1', 'Byt 5+1 je typ bytu s pěti pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Ateliér', 'ATELIER', 'Ateliér je obytný prostor s pracovním zázemím, často využívaný umělci.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Loft', 'LOFT', 'Loft je otevřený obytný prostor s vysokými stropy a industriálním vzhledem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Řadový dům', 'RADOVY DUM', 'Řadový dům je typ rodinného domu, který je součástí řady podobných domů.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Pole', 'POLE', 'Pole je zemědělská půda určená k pěstování plodin.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Kancelář', 'KANCELAR', 'Kancelář je prostor určený pro administrativní činnost.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Garáž', 'GARAZ', 'Garáž je uzavřený prostor určený pro parkování vozidel.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Sklad', 'SKLAD', 'Sklad je prostor určený pro uchovávání zboží nebo materiálu.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Chata', 'CHATA', 'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Zahrada', 'ZAHRADA', 'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Průmyslový objekt', 'PRUMYSLOVY OBJEKT', 'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Obchodní prostor', 'OBCHODNI PROSTOR', 'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Restaurace', 'RESTAURACE', 'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Hotel', 'HOTEL', 'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Pozemek', 'POZEMEK', 'Pozemek je část zemského povrchu, která může být využita pro různé účely, jako je stavba, zemědělství nebo rekreace.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Garsoniéra', 'GARSONIERA', 'Garsoniéra je malý byt, obvykle s jedním pokojem, který slouží jako obytný prostor a kuchyň.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);