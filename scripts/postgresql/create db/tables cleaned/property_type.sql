CREATE TABLE IF NOT EXISTS cleaned.property_type (
    property_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL, -- název typu nemovitosti (např. byt, dům, pozemek)
    description TEXT, -- popis typu nemovitosti
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.property_type IS 'Typy nemovitostí, jako jsou byty, domy a pozemky, včetně jejich popisu.';