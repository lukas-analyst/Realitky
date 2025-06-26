CREATE TABLE IF NOT EXISTS cleaned.property_risk_score (
    property_risk_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL REFERENCES cleaned.property(property_id) ON DELETE CASCADE,
    calculation_date DATE NOT NULL, -- datum výpočtu rizikového skóre
    market_risk_score DECIMAL(2, 1) CHECK (market_risk_score BETWEEN 1 AND 5), -- tržní riziko (1-5)
    location_risk_score DECIMAL(2, 1) CHECK (location_risk_score BETWEEN 1 AND 5), -- riziko lokality (1-5)
    structural_risk_score DECIMAL(2, 1) CHECK (structural_risk_score BETWEEN 1 AND 5), -- strukturální riziko (1-5)
    legal_risk_score DECIMAL(2, 1) CHECK (legal_risk_score BETWEEN 1 AND 5), -- právní riziko (1-5)
    liquidity_risk_score DECIMAL(2, 1) CHECK (liquidity_risk_score BETWEEN 1 AND 5), -- likviditní riziko (1-5)
    overall_property_risk_score DECIMAL(2, 1) CHECK (overall_property_risk_score BETWEEN 1 AND 5), -- celkové rizikové skóre nemovitosti (1-5)
    risk_factors_description JSONB, -- popis faktorů ovlivňujících rizikové skóre
    ins_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    del_flag BOOLEAN DEFAULT FALSE
);