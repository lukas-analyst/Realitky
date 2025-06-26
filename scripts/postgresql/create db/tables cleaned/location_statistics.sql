CREATE TABLE IF NOT EXISTS cleaned.location_statistics(
    location_statistic_id SERIAL PRIMARY KEY,
    district_code VARCHAR(20) NOT NULL, -- kód okresu/městské části (propojení s cleaned.property.address_district_code)
    year INT NOT NULL, -- rok statistiky
    population INT, -- počet obyvatel
    average_income_czk DECIMAL(15, 2), -- průměrný příjem na obyvatele
    unemployment_rate DECIMAL(5, 2), -- míra nezaměstnanosti v procentech
    crime_rate_per100000 INT, -- počet trestných činů na 100 000 obyvatel
    avg_property_price_sqm_czk DECIMAL(15, 2), -- průměrná cena nemovitosti za m² v CZK
    avg_rental_price_sqm_czk DECIMAL(15, 2), -- průměrná cena pronájmu za m² v CZK
    infrastructure_score INT, -- skóre infrastruktury (škála 1-10)
    future_development_impact INT, -- dopad budoucího rozvoje (škála 1-10)
    environmental_quality_score INT, -- skóre kvality životního prostředí (škála 1-10)
    source_csu TEXT, -- zdroj dat ČSÚ nebo jiný relevantní zdroj
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.location_statistics IS 'Statistické údaje o lokalitách, jako jsou okresy a městské části, včetně demografických a ekonomických ukazatelů.';