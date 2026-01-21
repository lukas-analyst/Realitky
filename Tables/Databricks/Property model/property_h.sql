-- DROP TABLE realitky.cleaned.property_h;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_h (
    property_h_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Surrogate key pro historickou tabulku
    property_id STRING NOT NULL, -- ID nemovitosti (FK na property)
    property_name STRING NOT NULL, -- Název nemovitosti (např. "Prodej bytu 2+kk v Praze")
    
    address_street STRING NOT NULL, -- Ulice
    address_house_number STRING NOT NULL, -- Číslo popisné/číslo orientační
    ruian_code STRING NOT NULL, -- Kód RÚIAN (pro propojení s demografickými daty ČSÚ)
    address_city STRING NOT NULL, -- Město/obec
    address_state STRING NOT NULL, -- Kraj
    address_country_code STRING NOT NULL, -- Stát (kód)
    address_postal_code STRING NOT NULL, -- PSČ
    address_district_code STRING, -- Kód městské části/okresu (pro propojení s demografickými daty ČSÚ)
    address_latitude DECIMAL(9,6) NOT NULL, -- Zeměpisná šířka
    address_longitude DECIMAL(9,6) NOT NULL, -- Zeměpisná délka
    
    property_type_id BIGINT NOT NULL, -- Byt, dům, pozemek, komerční (FK na property_type)
    property_subtype_id BIGINT NOT NULL, -- 2+kk, řadový, pole, kancelář (FK na property_subtype)
    
    property_number_of_floors SMALLINT NOT NULL, -- Počet podlaží (pro domy)
    property_floor_number SMALLINT NOT NULL, -- Číslo podlaží (pro byty)
    property_location_id BIGINT NOT NULL, -- Typ lokality (FK na property_location)
    property_construction_type_id BIGINT NOT NULL, -- Typ konstrukce (panel, cihla, dřevostavba) (FK na property_construction_type)
    
    area_total_sqm DECIMAL(10,2) NOT NULL, -- Celková užitá/zastavěná plocha v m²
    area_land_sqm DECIMAL(10,2) NOT NULL, -- Plocha pozemku v m² (pro domy/pozemky)
    number_of_rooms SMALLINT NOT NULL, -- Počet místností
    
    construction_year SMALLINT NOT NULL, -- Rok výstavby
    last_reconstruction_year SMALLINT NOT NULL, -- Rok poslední větší rekonstrukce
    energy_class_penb STRING NOT NULL, -- Energetická třída (A-G)
    property_condition STRING NOT NULL, -- Stav nemovitosti (novostavba, dobrý, standard, k rekonstrukci, špatný)
    
    property_parking_id BIGINT NOT NULL, -- Typ parkování (FK na property_parking)
    property_heating_id BIGINT NOT NULL, -- ID vytápění (FK na property_heating)
    property_electricity_id BIGINT NOT NULL, -- ID elektrické energie (FK na property_electricity)
    property_accessibility_id BIGINT NOT NULL, -- Typ přístupové cesty (FK na property_accessibility)
    
    property_balcony SMALLINT NOT NULL, -- Plocha balkonu v m² (pokud je přítomen)
    property_terrace SMALLINT NOT NULL, -- Plocha terasy v m² (pokud je přítomna)
    property_cellar SMALLINT NOT NULL, -- Plocha sklepa v m² (pokud je přítomen)
    property_elevator SMALLINT NOT NULL, -- Zda je přítomen výtah (TRUE/FALSE)
    
    property_canalization STRING NOT NULL, -- Typ kanalizace
    property_water_supply_id BIGINT NOT NULL, -- Typ vody na pozemku (FK na property_water_supply)
    property_air_conditioning STRING NOT NULL, -- Typ klimatizace
    property_gas_id BIGINT NOT NULL, -- Typ plynu (FK na property_gas)
    property_internet SMALLINT NOT NULL, -- Zda je přítomen internet (TRUE/FALSE)
    
    furnishing_level STRING NOT NULL, -- Částečně zařízeno, nezařízeno, plně zařízeno, null
    ownership_type STRING NOT NULL, -- Osobní, družstevní, obecní, státní, jiný
    is_active_listing BOOLEAN NOT NULL, -- Zda je nemovitost aktuálně inzerována
    source_url STRING NOT NULL, -- URL na inzerát
    description STRING NOT NULL, -- Popis nemovitosti
    
    src_web STRING NOT NULL, -- Zdrojová webová stránka (např. Sreality, Bezrealitky)
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    ins_process_id STRING NOT NULL, -- ID procesu, který vložil záznam (pro sledování původu dat)
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    upd_process_id STRING NOT NULL, -- ID procesu, který naposledy aktualizoval záznam (pro sledování původu dat)
    del_flag BOOLEAN NOT NULL, -- Příznak smazání záznamu

    valid_from DATE NOT NULL, -- Datum a čas, od kdy je záznam platný
    valid_to DATE, -- Datum a čas, do kdy je záznam platný
    current_flag BOOLEAN NOT NULL -- Příznak, zda je záznam aktuální (TRUE/FALSE)
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Historizační tabulka pro nemovitosti. Obsahuje všechny důležité údaje o nemovitostech včetně adres, charakteristik a vybavení, s verzováním záznamů.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days',
    'delta.checkpointRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_h IS 'Historizační tabulka pro nemovitosti. Obsahuje všechny důležité údaje o nemovitostech včetně adres, charakteristik a vybavení, s verzováním záznamů.';

COMMENT ON COLUMN realitky.cleaned.property_h.property_h_id IS 'Surrogate key pro historickou tabulku (auto-increment).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_id IS 'ID nemovitosti (FK na property).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_name IS 'Název nemovitosti (např. "Prodej bytu 2+kk v Praze").';
COMMENT ON COLUMN realitky.cleaned.property_h.address_street IS 'Ulice.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_house_number IS 'Číslo popisné/číslo orientační.';
COMMENT ON COLUMN realitky.cleaned.property_h.ruian_code IS 'Kód RÚIAN (pro propojení s demografickými daty ČSÚ).';
COMMENT ON COLUMN realitky.cleaned.property_h.address_city IS 'Město/obec.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_state IS 'Kraj.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_country_code IS 'Stát (kód).';
COMMENT ON COLUMN realitky.cleaned.property_h.address_postal_code IS 'PSČ.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_district_code IS 'Kód městské části/okresu (pro propojení s demografickými daty ČSÚ).';
COMMENT ON COLUMN realitky.cleaned.property_h.address_latitude IS 'Zeměpisná šířka.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_longitude IS 'Zeměpisná délka.';
COMMENT ON COLUMN realitky.cleaned.property_h.property_type_id IS 'Byt, dům, pozemek, komerční (FK na property_type).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_subtype_id IS '2+kk, řadový, pole, kancelář (FK na property_subtype).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_number_of_floors IS 'Počet podlaží (pro domy).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_floor_number IS 'Číslo podlaží (pro byty).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_location_id IS 'Typ lokality (FK na property_location).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_construction_type_id IS 'Typ konstrukce (panel, cihla, dřevostavba) (FK na property_construction_type).';
COMMENT ON COLUMN realitky.cleaned.property_h.area_total_sqm IS 'Celková užitá/zastavěná plocha v m².';
COMMENT ON COLUMN realitky.cleaned.property_h.area_land_sqm IS 'Plocha pozemku v m² (pro domy/pozemky).';
COMMENT ON COLUMN realitky.cleaned.property_h.number_of_rooms IS 'Počet místností.';
COMMENT ON COLUMN realitky.cleaned.property_h.construction_year IS 'Rok výstavby.';
COMMENT ON COLUMN realitky.cleaned.property_h.last_reconstruction_year IS 'Rok poslední větší rekonstrukce.';
COMMENT ON COLUMN realitky.cleaned.property_h.energy_class_penb IS 'Energetická třída (A-G).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_condition IS 'Stav nemovitosti (novostavba, dobrý, standard, k rekonstrukci, špatný).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_parking_id IS 'Typ parkování (FK na property_parking).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_heating_id IS 'ID vytápění (FK na property_heating).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_electricity_id IS 'ID elektrické energie (FK na property_electricity).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_accessibility_id IS 'Typ přístupové cesty (FK na property_accessibility).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_balcony IS 'Plocha balkonu v m² (pokud je přítomen).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_terrace IS 'Plocha terasy v m² (pokud je přítomna).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_cellar IS 'Plocha sklepa v m² (pokud je přítomen).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_elevator IS 'Zda je přítomen výtah (TRUE/FALSE).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_canalization IS 'Typ kanalizace.';
COMMENT ON COLUMN realitky.cleaned.property_h.property_water_supply_id IS 'Typ vody na pozemku (FK na property_water_supply).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_air_conditioning IS 'Typ klimatizace.';
COMMENT ON COLUMN realitky.cleaned.property_h.property_gas_id IS 'Typ plynu (FK na property_gas).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_internet IS 'Zda je přítomen internet (TRUE/FALSE).';
COMMENT ON COLUMN realitky.cleaned.property_h.furnishing_level IS 'Částečně zařízeno, nezařízeno, plně zařízeno, null.';
COMMENT ON COLUMN realitky.cleaned.property_h.ownership_type IS 'Osobní, družstevní, obecní, státní, jiný.';
COMMENT ON COLUMN realitky.cleaned.property_h.is_active_listing IS 'Zda je nemovitost aktuálně inzerována.';
COMMENT ON COLUMN realitky.cleaned.property_h.source_url IS 'URL na inzerát.';
COMMENT ON COLUMN realitky.cleaned.property_h.description IS 'Popis nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_h.src_web IS 'Zdrojová webová stránka (např. Sreality, Bezrealitky).';
COMMENT ON COLUMN realitky.cleaned.property_h.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_h.ins_process_id IS 'ID procesu, který vložil záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.cleaned.property_h.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_h.upd_process_id IS 'ID procesu, který naposledy aktualizoval záznam (pro sledování původu dat).';
COMMENT ON COLUMN realitky.cleaned.property_h.del_flag IS 'Příznak smazání záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_h.valid_from IS 'Datum a čas, od kdy je záznam platný.';
COMMENT ON COLUMN realitky.cleaned.property_h.valid_to IS 'Datum a čas, do kdy je záznam platný.';
COMMENT ON COLUMN realitky.cleaned.property_h.current_flag IS 'Příznak, zda je záznam aktuální (TRUE/FALSE).';

SELECT * FROM realitky.cleaned.property_h;