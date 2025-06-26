CREATE TABLE IF NOT EXISTS cleaned.client (
    client_id SERIAL PRIMARY KEY,
    income_monthly_net_czk DECIMAL(15, 2) NOT NULL, -- měsíční čistý příjem klienta v CZK
    expenses_monthly_czk DECIMAL(15, 2) NOT NULL, -- měsíční výdaje bez nákladů na bydlení v CZK
    existing_debt_monthly_czk DECIMAL(15, 2) NOT NULL, -- měsíční splátky stávajících úvěrů v CZK
    existing_debt_total_czk DECIMAL(15, 2) NOT NULL, -- celkové závazky klienta v CZK
    number_of_dependents INT NOT NULL, -- počet vyživovaných osob
    employment_stability_score INT CHECK (employment_stability_score BETWEEN 1 AND 5) NOT NULL, -- stabilita zaměstnání (1-5)
    credit_history_score INT CHECK (credit_history_score BETWEEN 1 AND 5), -- skóre kreditní historie (1-5), může být NULL
    own_funds_czk DECIMAL(15, 2) NOT NULL, -- vlastní prostředky klienta k dispozici v CZK
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.client IS 'Základní údaje o klientech, včetně příjmů, výdajů, stávajících závazků a skóre stability zaměstnání a kreditní historie.';