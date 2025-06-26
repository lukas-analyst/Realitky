CREATE TABLE IF NOT EXISTS cleaned.transaction (
    transaction_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL REFERENCES cleaned.property(property_id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- prodej, pronájem
    transaction_date DATE NOT NULL,
    price_czk DECIMAL(15, 2) NOT NULL, -- prodejní cena, nebo měsíční pronájem
    price_per_sqm_czk DECIMAL(10, 2), -- cena za m² v CZK (vypočítané)
    source TEXT, -- katastr, realitivni_portal, vlastni_sber,
    listing_duration_days INT, -- doba, po kterou byla nemovitost na trhu
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.transaction IS 'Ukládá historické prodejní a pronájemní ceny.';