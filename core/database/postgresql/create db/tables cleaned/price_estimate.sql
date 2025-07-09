CREATE TABLE IF NOT EXISTS cleaned.price_estimate (
    estimate_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL REFERENCES cleaned.property(property_id) ON DELETE CASCADE,
    estimate_date DATE NOT NULL, -- datum odhadu ceny
    estimated_sale_price_czk DECIMAL(15, 2), -- odhadovaná prodejní cena v CZK
    estimated_rent_price_czk DECIMAL(15, 2), -- odhadovaná cena pronájmu v CZK
    prediction_model_version TEXT, -- verze modelu predikce
    confidence_interval_lower_czk DECIMAL(15, 2), -- dolní mez intervalu spolehlivosti
    confidence_interval_upper_czk DECIMAL(15, 2), -- horní mez intervalu spolehlivosti
    key_factors_contributing JSONB, -- klíčové faktory ovlivňující cenu (např. {'plocha': +100000, 'lokalita': -50000})
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.price_estimate IS 'Odhady cen nemovitostí, včetně odhadované prodejní a nájemní ceny, verze modelu predikce a klíčových faktorů ovlivňujících cenu.';