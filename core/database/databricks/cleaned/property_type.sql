-- DROP TABLE IF EXISTS realitky.cleaned.property_type;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_type (
    property_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor typu nemovitosti
    
    type_name STRING NOT NULL, -- Název typu nemovitosti (např. byt, dům, pozemek)
    type_code STRING NOT NULL, -- kód typu nemovitosti (např. "BYT", "DUM", "POZEMEK")
    description STRING, -- Popis typu nemovitosti
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_type IS 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu.';

COMMENT ON COLUMN realitky.cleaned.property_type.property_type_id IS 'Unikátní identifikátor typu nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_type.type_name IS 'Název typu nemovitosti (např. Byt, Dům, Pozemek).';
COMMENT ON COLUMN realitky.cleaned.property_type.type_code IS 'Kód typu nemovitosti (např. "BYT", "DUM", "POZEMEK").';
COMMENT ON COLUMN realitky.cleaned.property_type.description IS 'Popis typu nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_type.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_type.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_type.del_flag IS 'Příznak smazání záznamu.';

-- INSERT DATA INTO TABLE
INSERT INTO realitky.cleaned.property_type (type_name, type_code, description, ins_dt, upd_dt, del_flag)
VALUES
    ('Byt', 'BYT', 'Byt je samostatná obytná jednotka v budově, která může být součástí většího bytového domu nebo komplexu.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Dům', 'DUM', 'Dům je samostatná obytná budova, která může obsahovat jednu nebo více bytových jednotek.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Pozemek', 'POZEMEK', 'Pozemek je kus země, který může být využíván pro různé účely, jako je výstavba, zemědělství nebo rekreace.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Kancelář', 'KANCELAR', 'Kancelář je prostor určený pro administrativní činnost, obvykle v komerční budově.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Garáž', 'GARAZ', 'Garáž je uzavřený prostor určený pro parkování vozidel.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Sklad', 'SKLAD', 'Sklad je prostor určený pro uchovávání zboží nebo materiálu.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Chata', 'CHATA', 'Chata je malá obytná budova, obvykle umístěná v přírodě a využívaná pro rekreaci.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Pole', 'POLE', 'Pole je rozsáhlý kus země, obvykle využívaný pro zemědělské účely, jako je pěstování plodin nebo chov zvířat.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Zahrada', 'ZAHRADA', 'Zahrada je menší pozemek, obvykle u domu, určený pro pěstování rostlin a květin.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Průmyslový objekt', 'PRUMYSLOVY OBJEKT', 'Průmyslový objekt je budova nebo komplex budov určených pro průmyslovou výrobu nebo skladování.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Obchodní prostor', 'OBCHODNI PROSTOR', 'Obchodní prostor je komerční prostor určený pro maloobchodní nebo velkoobchodní činnost.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Restaurace', 'RESTAURACE', 'Restaurace je podnik poskytující stravovací služby, obvykle s možností posezení.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Hotel', 'HOTEL', 'Hotel je ubytovací zařízení poskytující pokoje a další služby pro hosty.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Komerční nemovitost', 'KOMERCNI NEMOVITOST', 'Komerční nemovitost zahrnuje budovy a pozemky určené pro podnikání, jako jsou kanceláře, obchody a sklady.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
    ('Rekreační objekt', 'REKREACNI OBJEKT', 'Rekreační objekt je nemovitost určená pro rekreaci, jako jsou chaty, chalupy nebo rekreační domy.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE);