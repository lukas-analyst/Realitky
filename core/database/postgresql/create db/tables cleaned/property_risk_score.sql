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

COMMENT ON TABLE cleaned.property_risk_score IS 'Rizikové skóre nemovitostí včetně jednotlivých komponent a celkového hodnocení.';
COMMENT ON COLUMN cleaned.property_risk_score.property_risk_id IS 'Unikátní identifikátor rizikového skóre.';
COMMENT ON COLUMN cleaned.property_risk_score.property_id IS 'Reference na nemovitost (FK na cleaned.property).';
COMMENT ON COLUMN cleaned.property_risk_score.calculation_date IS 'Datum výpočtu rizikového skóre.';
COMMENT ON COLUMN cleaned.property_risk_score.market_risk_score IS 'Tržní riziko (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.location_risk_score IS 'Riziko lokality (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.structural_risk_score IS 'Strukturální riziko (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.legal_risk_score IS 'Právní riziko (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.liquidity_risk_score IS 'Likviditní riziko (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.overall_property_risk_score IS 'Celkové rizikové skóre nemovitosti (1-5).';
COMMENT ON COLUMN cleaned.property_risk_score.risk_factors_description IS 'Popis faktorů ovlivňujících rizikové skóre (JSON format).';
COMMENT ON COLUMN cleaned.property_risk_score.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN cleaned.property_risk_score.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN cleaned.property_risk_score.del_flag IS 'Příznak smazání záznamu.';