CREATE TABLE IF NOT EXISTS cleaned.cadastre (
    cadastre_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL REFERENCES cleaned.property(property_id) ON DELETE CASCADE,
    parcel_number VARCHAR(50) NOT NULL, -- číslo parcely
    building_number VARCHAR(50), -- číslo popisné/ev. (pokud existuje)
    unit_number VARCHAR(50), -- číslo jednotky (pokud existuje)
    land_registry_sheet_id VARCHAR(50), -- list vlastnictví (LV) - kód listu vlastnictví
    ecumbrances_count INT DEFAULT 0, -- počet zástavních práv a věcných břemen
    last_update_date DATE NOT NULL, -- datum poslední aktualizace v katastru
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.cadastre IS 'Data z katastru nemovitostí.';