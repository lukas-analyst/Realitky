-- DROP TABLE realitky.cleaned.property_h;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_h (
    -- Historické klíče
    property_h_id BIGINT GENERATED ALWAYS AS IDENTITY,
    property_id STRING NOT NULL,
    
    property_name STRING NOT NULL,
    
    address_street STRING NOT NULL,
    ruian_code STRING NOT NULL,
    address_city STRING NOT NULL,
    address_state STRING NOT NULL,
    address_postal_code STRING NOT NULL,
    address_district_code STRING,
    address_latitude DECIMAL(9,6) NOT NULL,
    address_longitude DECIMAL(9,6) NOT NULL,
    
    property_type_id BIGINT NOT NULL,
    property_subtype_id BIGINT NOT NULL,
    
    property_number_of_floors SMALLINT NOT NULL,
    property_floor_number SMALLINT NOT NULL,
    property_location_id BIGINT NOT NULL,
    property_construction_type_id BIGINT NOT NULL,
    
    area_total_sqm DECIMAL(10,2) NOT NULL,
    area_land_sqm DECIMAL(10,2) NOT NULL,
    number_of_rooms SMALLINT NOT NULL,
    
    construction_year SMALLINT NOT NULL,
    last_reconstruction_year SMALLINT NOT NULL,
    energy_class_penb STRING NOT NULL,
    property_condition STRING NOT NULL,
    
    property_parking_id BIGINT NOT NULL,
    property_heating_id BIGINT NOT NULL,
    property_electricity_id BIGINT NOT NULL,
    property_accessibility_id BIGINT NOT NULL,
    
    property_balcony SMALLINT NOT NULL,
    property_terrace SMALLINT NOT NULL,
    property_cellar SMALLINT NOT NULL,
    property_elevator SMALLINT NOT NULL,
    
    property_canalization STRING NOT NULL,
    property_water_supply_id BIGINT NOT NULL,
    property_air_conditioning STRING NOT NULL,
    property_gas_id BIGINT NOT NULL,
    property_internet SMALLINT NOT NULL,
    
    furnishing_level STRING NOT NULL,
    ownership_type STRING NOT NULL,
    is_active_listing BOOLEAN NOT NULL,
    source_url STRING NOT NULL,
    description STRING NOT NULL,
    
    src_web STRING NOT NULL,
    ins_dt TIMESTAMP NOT NULL,
    ins_process_id STRING NOT NULL,
    upd_dt TIMESTAMP NOT NULL,
    upd_process_id STRING NOT NULL,
    del_flag BOOLEAN NOT NULL,
    
    valid_from TIMESTAMP NOT NULL, -- Datum začátku platnosti záznamu
    valid_to TIMESTAMP NOT NULL, -- Datum konce platnosti záznamu (31.12.2999)
    is_current BOOLEAN NOT NULL
);

COMMENT ON TABLE realitky.cleaned.property_h IS 'Historická tabulka pro sledování změn nemovitostí. Implementuje SCD Type 2 s úplnou historií všech změn.';

COMMENT ON COLUMN realitky.cleaned.property_h.property_h_id IS 'Surrogate key pro historickou tabulku (auto-increment).';
COMMENT ON COLUMN realitky.cleaned.property_h.property_id IS 'Business key - původní ID nemovitosti z hlavní tabulky.';
COMMENT ON COLUMN realitky.cleaned.property_h.valid_from IS 'Datum začátku platnosti záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_h.valid_to IS 'Datum konce platnosti záznamu (NULL = aktuální).';
COMMENT ON COLUMN realitky.cleaned.property_h.is_current IS 'Příznak aktuálního záznamu (TRUE = aktuální, FALSE = historický).';
COMMENT ON COLUMN realitky.cleaned.property_h.ins_process_id IS 'ID ETL procesu/job run ID, který záznam vložil.';
COMMENT ON COLUMN realitky.cleaned.property_h.upd_process_id IS 'ID ETL procesu, který záznam aktualizoval.';
COMMENT ON COLUMN realitky.cleaned.property_h.property_name IS 'Název nemovitosti (např. "Prodej bytu 2+kk v Praze").';
COMMENT ON COLUMN realitky.cleaned.property_h.address_street IS 'Ulice.';
COMMENT ON COLUMN realitky.cleaned.property_h.ruian_code IS 'Kód RÚIAN (pro propojení s demografickými daty ČSÚ).';
COMMENT ON COLUMN realitky.cleaned.property_h.address_city IS 'Město/obec.';
COMMENT ON COLUMN realitky.cleaned.property_h.address_state IS 'Kraj/stát.';
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
COMMENT ON COLUMN realitky.cleaned.property_h.ins_dt IS 'Datum vložení záznamu (z původní tabulky).';
COMMENT ON COLUMN realitky.cleaned.property_h.upd_dt IS 'Datum poslední aktualizace záznamu (z původní tabulky).';
COMMENT ON COLUMN realitky.cleaned.property_h.del_flag IS 'Příznak smazání záznamu.';

SELECT * FROM realitky.cleaned.property_h