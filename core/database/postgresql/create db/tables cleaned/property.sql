CREATE TABLE IF NOT EXISTS cleaned.property (
    property_id SERIAL PRIMARY KEY, -- Unikátní identifikátor nemovitosti

    property_name VARCHAR(255) NOT NULL DEFAULT('XNA'), -- Název nemovitosti (např. "Prodej bytu 2+kk v Praze")
    address_street VARCHAR(255) NOT NULL DEFAULT('XNA'), -- Ulice
    ruian_code VARCHAR(20) NOT NULL DEFAULT('XNA'), -- Kód RÚIAN (pro propojení s demografickými daty ČSÚ)
    address_city VARCHAR(100) NOT NULL DEFAULT('XNA'), -- Město/obec
    address_state VARCHAR(100) NOT NULL DEFAULT('XNA'), -- Kraj/stát
    address_postal_code VARCHAR(20) NOT NULL DEFAULT('XNA'), -- PSČ
    address_district_code VARCHAR(20) DEFAULT('XNA'), -- Kód městské části/okresu (pro propojení s demografickými daty ČSÚ)
    address_latitude DECIMAL(9, 6) NOT NULL DEFAULT(-1), -- Zeměpisná šířka
    address_longitude DECIMAL(9, 6) NOT NULL DEFAULT(-1), -- Zeměpisná délka

    property_type_id INT NOT NULL DEFAULT(-1), -- Byt, dům, pozemek, komerční (FK na cleaned.property_type)
    property_subtype_id INT NOT NULL DEFAULT(-1), -- 2+kk, řadový, pole, kancelář (FK na cleaned.property_subtype)
    property_number_of_floors INT NOT NULL DEFAULT(-1), -- Počet podlaží (pro domy)
    property_floor_number INT NOT NULL DEFAULT(-1), -- Číslo podlaží (pro byty)
    property_location VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Centrum, předměstí, klidná část (FK na cleaned.property_location)
    property_construction_type VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Panel, cihla, dřevo, smýšené (FK na cleaned.property_construction_type)

    area_total_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Celková užitá/zastavěná plocha v m²
    area_land_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Plocha pozemku v m² (pro domy/pozemky)
    number_of_rooms INT NOT NULL DEFAULT(-1), -- Počet místností
    construction_year INT NOT NULL DEFAULT(-1), -- Rok výstavby
    last_reconstruction_year INT NOT NULL DEFAULT(-1), -- Rok poslední větší rekonstrukce
    energy_class_penb CHAR(1) NOT NULL DEFAULT('X'), -- Energetická třída (A-G)
    property_condition VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Stav nemovitosti (novostavba, dobrý, standard, k rekonstrukci, špatný)

    property_parking VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Na pozemku, ulici, parkovací stání (FK na cleaned.property_parking)
    property_heating VARCHAR(50) NOT NULL DEFAULT('XNA'), -- ID vytápění (FK na cleaned.property_heating)
    property_electricity VARCHAR(50) NOT NULL DEFAULT('XNA'), -- 220V, 380V,  (FK na cleaned.property_electricity)
    property_accessibility_id VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Asfalt, dlažba (FK na cleaned.property_accessibility)

    property_balcony_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Plocha balkonu v m² (pokud je přítomen)
    property_terrace_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Plocha terasy v m² (pokud je přítomna)
    property_garden_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Plocha zahrady v m² (pokud je přítomna)
    property_cellar_sqm DECIMAL(10, 2) NOT NULL DEFAULT(-1), -- Plocha sklepa v m² (pokud je přítomen)
    property_elevator BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomen výtah (TRUE/FALSE)
    property_canalization BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomna kanalizace (TRUE/FALSE)
    property_water_supply BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomna vodovodní přípojka (TRUE/FALSE)
    property_air_conditioning BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomna klimatizace (TRUE/FALSE)
    property_gas BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomen plyn (TRUE/FALSE)
    property_internet BOOLEAN NOT NULL DEFAULT(false), -- Zda je přítomen internet (TRUE/FALSE)

    furnishing_level VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Částečně zařízeno, nezařízeno, plně zařízeno, null
    ownership_type VARCHAR(50) NOT NULL DEFAULT('XNA'), -- Osobní, družstevní, obecní, státní, jiný
    is_active_listing BOOLEAN NOT NULL DEFAULT TRUE, -- Zda je nemovitost aktuálně inzerována
    source_url VARCHAR(255) NOT NULL, -- URL na inzerát
    description TEXT NOT NULL DEFAULT('XNA'), -- Popis nemovitosti

    ins_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL DEFAULT FALSE -- Příznak smazání záznamu
);

COMMENT ON TABLE cleaned.property IS 'Základní informace o nemovitostech.';

COMMENT ON COLUMN cleaned.property.property_id IS 'Unikátní identifikátor nemovitosti.';
COMMENT ON COLUMN cleaned.property.property_name IS 'Název nemovitosti (např. Prodej bytu 2+kk v Praze).';
COMMENT ON COLUMN cleaned.property.address_street IS 'Ulice.';
COMMENT ON COLUMN cleaned.property.ruian_code IS 'Kód RÚIAN (propojení s demografickými daty ČSÚ).';
COMMENT ON COLUMN cleaned.property.address_city IS 'Město/obec.';
COMMENT ON COLUMN cleaned.property.address_state IS 'Kraj/stát.';
COMMENT ON COLUMN cleaned.property.address_postal_code IS 'PSČ.';
COMMENT ON COLUMN cleaned.property.address_district_code IS 'Kód městské části/okresu.';
COMMENT ON COLUMN cleaned.property.address_latitude IS 'Zeměpisná šířka.';
COMMENT ON COLUMN cleaned.property.address_longitude IS 'Zeměpisná délka.';
COMMENT ON COLUMN cleaned.property.property_type_id IS 'Typ nemovitosti (FK na cleaned.property_type).';
COMMENT ON COLUMN cleaned.property.property_subtype_id IS 'Podtyp nemovitosti (FK na cleaned.property_subtype).';
COMMENT ON COLUMN cleaned.property.property_number_of_floors IS 'Počet podlaží (pro domy).';
COMMENT ON COLUMN cleaned.property.property_floor_number IS 'Číslo podlaží (pro byty).';
COMMENT ON COLUMN cleaned.property.property_location IS 'Lokalita (FK na cleaned.property_location).';
COMMENT ON COLUMN cleaned.property.property_construction_type IS 'Konstrukční typ (FK na cleaned.property_construction_type).';
COMMENT ON COLUMN cleaned.property.area_total_sqm IS 'Celková užitá/zastavěná plocha v m².';
COMMENT ON COLUMN cleaned.property.area_land_sqm IS 'Plocha pozemku v m².';
COMMENT ON COLUMN cleaned.property.number_of_rooms IS 'Počet místností.';
COMMENT ON COLUMN cleaned.property.construction_year IS 'Rok výstavby.';
COMMENT ON COLUMN cleaned.property.last_reconstruction_year IS 'Rok poslední větší rekonstrukce.';
COMMENT ON COLUMN cleaned.property.energy_class_penb IS 'Energetická třída (A-G).';
COMMENT ON COLUMN cleaned.property.property_condition IS 'Stav nemovitosti.';
COMMENT ON COLUMN cleaned.property.property_parking IS 'Parkování (FK na cleaned.property_parking).';
COMMENT ON COLUMN cleaned.property.property_heating IS 'Vytápění (FK na cleaned.property_heating).';
COMMENT ON COLUMN cleaned.property.property_electricity IS 'Elektřina (FK na cleaned.property_electricity).';
COMMENT ON COLUMN cleaned.property.property_accessibility_id IS 'Přístupnost (FK na cleaned.property_accessibility).';
COMMENT ON COLUMN cleaned.property.property_balcony_sqm IS 'Plocha balkonu v m².';
COMMENT ON COLUMN cleaned.property.property_terrace_sqm IS 'Plocha terasy v m².';
COMMENT ON COLUMN cleaned.property.property_garden_sqm IS 'Plocha zahrady v m².';
COMMENT ON COLUMN cleaned.property.property_cellar_sqm IS 'Plocha sklepa v m².';
COMMENT ON COLUMN cleaned.property.property_elevator IS 'Zda je přítomen výtah.';
COMMENT ON COLUMN cleaned.property.property_canalization IS 'Zda je přítomna kanalizace.';
COMMENT ON COLUMN cleaned.property.property_water_supply IS 'Zda je přítomna vodovodní přípojka.';
COMMENT ON COLUMN cleaned.property.property_air_conditioning IS 'Zda je přítomna klimatizace.';
COMMENT ON COLUMN cleaned.property.property_gas IS 'Zda je přítomen plyn.';
COMMENT ON COLUMN cleaned.property.property_internet IS 'Zda je přítomen internet.';
COMMENT ON COLUMN cleaned.property.furnishing_level IS 'Úroveň vybavení.';
COMMENT ON COLUMN cleaned.property.ownership_type IS 'Typ vlastnictví.';
COMMENT ON COLUMN cleaned.property.is_active_listing IS 'Zda je nemovitost aktuálně inzerována.';
COMMENT ON COLUMN cleaned.property.source_url IS 'URL na inzerát.';
COMMENT ON COLUMN cleaned.property.description IS 'Popis nemovitosti.';
COMMENT ON COLUMN cleaned.property.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN cleaned.property.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN cleaned.property.del_flag IS 'Příznak smazání záznamu.';

-- Indexy pro rychlé vyhledávání a filtrování
CREATE INDEX IF NOT EXISTS idx_property_city ON cleaned.property(address_city);
CREATE INDEX IF NOT EXISTS idx_property_type ON cleaned.property(property_type_id);
CREATE INDEX IF NOT EXISTS idx_property_active ON cleaned.property(is_active_listing);
CREATE INDEX IF NOT EXISTS idx_property_ruian ON cleaned.property(ruian_code);
CREATE INDEX IF NOT EXISTS idx_property_latlon ON cleaned.property(address_latitude, address_longitude);