CREATE TABLE IF NOT EXISTS cleaned.loan_simulation (
    loan_simulation_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES cleaned.client(client_id) ON DELETE CASCADE,
    property_id INT NOT NULL REFERENCES cleaned.property(property_id) ON DELETE CASCADE,
    simulation_date DATE NOT NULL, -- datum simulace
    loan_amount_czk DECIMAL(15, 2) NOT NULL, -- předpokládaná výše úvěru v CZK
    interest_rate_percent DECIMAL(5, 2) NOT NULL, -- úroková sazba v procentech
    loan_term_years INT NOT NULL, -- doba splácení v letech
    monthly_payment_czk DECIMAL(15, 2) NOT NULL, -- měsíční splátka v CZK
    total_loan_cost_czk DECIMAL(15, 2) NOT NULL, -- celkové náklady na úvěr v CZK
    ltv_percent DECIMAL(5, 2) CHECK (ltv_percent BETWEEN 0 AND 100), -- poměr LTV (Loan to Value)
    dti_ratio DECIMAL(5, 2) CHECK (dti_ratio >= 0), -- poměr DTI (Debt to Income)
    dsti_ratio DECIMAL(5, 2) CHECK (dsti_ratio >= 0), -- poměr DSTI (Debt Service to Income)
    fees_total_czk DECIMAL(15, 2) NOT NULL, -- celkové poplatky spojené s úvěrem v CZK
    interest_rate_risk_score DECIMAL(2, 1) CHECK (interest_rate_risk_score BETWEEN 1 AND 5), -- citlivost na změnu sazeb (1-5)
    collateral_value_risk_score DECIMAL(2, 1) CHECK (collateral_value_risk_score BETWEEN 1 AND 5), -- riziko poklesu hodnoty zástavy (1-5)
    overall_loan_risk_score DECIMAL(2, 1) CHECK (overall_loan_risk_score BETWEEN 1 AND 5), -- celkové rizikové skóre úvěru (1-5)
    scenario_type VARCHAR(20) CHECK (scenario_type IN ('optimistický', 'realistický', 'pesimistický')), -- typ scénáře
    scenario_details JSONB, -- specifika scénáře (např. očekávaný růst sazeb, pokles cen)
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE cleaned.loan_simulation IS 'Simulace hypotečního úvěru s detaily jako výše úvěru, úroková sazba, doba splácení a rizikové skóre.';