CREATE TABLE IF NOT EXISTS cleaned.macroeconomics (
    macro_id SERIAL PRIMARY KEY,
    date DATE NOT NULL, -- datum ukazatele
    cnb_interest_rate DECIMAL(5, 2), -- Repo sazba ČNB
    pribor_3m DECIMAL(5, 2), -- 3měsíční PRIBOR
    inflation_rate DECIMAL(5, 2), -- Míra inflace v procentech
    gdp_growth_rate DECIMAL(5, 2), -- Růst HDP v procentech
    average_mortgage_rate DECIMAL(5, 2), -- Celorepublikový průměr hypotečních sazeb
    mortgage_volume_czk DECIMAL(15, 2), -- Celkový objem poskytnutých hypoték v CZK
    source_cnb TEXT, -- Zdroj dat ČNB nebo jiný relevantní zdroj
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.macroeconomics IS 'Makroekonomické ukazatele jako repo sazba ČNB, míra inflace, růst HDP a průměrné hypoteční sazby.';