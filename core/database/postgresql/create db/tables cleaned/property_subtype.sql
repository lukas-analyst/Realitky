CREATE TABLE IF NOT EXISTS cleaned.property_subtype (
    property_subtype_id SERIAL PRIMARY KEY,
    subtype_name VARCHAR(50) NOT NULL, -- název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář)
    subtyp_name_cleaned VARCHAR(50) NOT NULL, -- název podtypu nemovitosti bez diakritiky (např. 2+kk, radovy dum, pole, kancelar)
    description TEXT, -- popis podtypu nemovitosti
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.property_subtype IS 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře, včetně jejich popisu a odkazu na typ nemovitosti.';
COMMENT ON COLUMN cleaned.property_subtype.property_subtype_id IS 'Unikátní identifikátor podtypu nemovitosti.';
COMMENT ON COLUMN cleaned.property_subtype.subtype_name IS 'Název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář).';
COMMENT ON COLUMN cleaned.property_subtype.subtyp_name_cleaned IS 'Název podtypu nemovitosti bez diakritiky (např. "2+kk", "radovy dum", "pole", "kancelar").';
COMMENT ON COLUMN cleaned.property_subtype.description IS 'Popis podtypu nemovitosti.';
COMMENT ON COLUMN cleaned.property_subtype.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN cleaned.property_subtype.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN cleaned.property_subtype.del_flag IS 'Příznak smazání záznamu.';

-- INSERT DATA INTO TABLE
INSERT INTO cleaned.property_subtype (subtype_name, subtyp_name_cleaned, description, ins_dt, upd_dt, del_flag)
VALUES
    ('1+kk', '1+kk', 'Byt 1+kk je typ bytu s jedním pokojem a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('1+1', '1+1', 'Byt 1+1 je typ bytu s jedním pokojem a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('2+kk', '2+kk', 'Byt 2+kk je typ bytu s dvěma pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('2+1', '2+1', 'Byt 2+1 je typ bytu se dvěma pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('3+kk', '3+kk', 'Byt 3+kk je typ bytu se třemi pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('3+1', '3+1', 'Byt 3+1 je typ bytu se třemi pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('4+kk', '4+kk', 'Byt 4+kk je typ bytu se čtyřmi pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('4+1', '4+1', 'Byt 4+1 je typ bytu se čtyřmi pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('5+kk', '5+kk', 'Byt 5+kk je typ bytu s pěti pokoji a kuchyňským koutem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('5+1', '5+1', 'Byt 5+1 je typ bytu s pěti pokoji a samostatnou kuchyní.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Ateliér', 'atelier', 'Ateliér je obytný prostor s pracovním zázemím, často využívaný umělci.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Loft', 'loft', 'Loft je otevřený obytný prostor s vysokými stropy a industriálním vzhledem.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Řadový dům', 'radovy dum', 'Řadový dům je typ rodinného domu, který je součástí řady podobných domů.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Pole', 'pole', 'Pole je zemědělská půda určená k pěstování plodin.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Kancelář', 'kancelar', 'Kancelář je prostor určený pro administrativní činnost.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Garáž', 'garaz', 'Garáž je uzavřený prostor určený pro parkování vozidel.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Sklad', 'sklad', 'Sklad je prostor určený pro uchovávání zboží nebo materiálu.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Chata', 'chata', 'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Zahrada', 'zahrada', 'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Průmyslový objekt', 'prumyslovy objekt', 'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Obchodní prostor', 'obchodni prostor', 'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Restaurace', 'restaurace', 'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Hotel', 'hotel', 'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);