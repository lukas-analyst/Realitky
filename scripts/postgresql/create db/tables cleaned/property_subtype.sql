CREATE TABLE IF NOT EXISTS cleaned.property_subtype (
    property_subtype_id SERIAL PRIMARY KEY,
    subtype_name VARCHAR(50) NOT NULL, -- název podtypu nemovitosti (např. 2+kk, řadový dům, pole, kancelář)
    description TEXT, -- popis podtypu nemovitosti
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.property_subtype IS 'Podtypy nemovitostí, jako jsou 2+kk byty, řadové domy, pole a kanceláře, včetně jejich popisu a odkazu na typ nemovitosti.';