CREATE TABLE IF NOT EXISTS cleaned.cadastre_encumbrance (
    encumbrance_id SERIAL PRIMARY KEY,
    cadastre_id INT NOT NULL REFERENCES cleaned.cadastre(cadastre_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- zástavní právo, věcné břemeno, exekuce, překupní právo, jiné
    description TEXT, -- popis zástavního práva nebo věcného břemene
    encumbrance_value DECIMAL(15, 2), -- hodnota zástavy (pokud je k dispozici)
    date_recorded DATE NOT NULL, -- datum registrace v katastru
    date_removed DATE, -- datum odstranění (pokud bylo odstraněno)
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.cadastre_encumbrance IS 'Záznamy o zástavních právech a věcných břemenech spojených s nemovitostmi v katastru.';