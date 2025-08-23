CREATE TABLE IF NOT EXISTS realitky.cleaned.property_risk_score (
    property_risk_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Unikátní identifikátor rizikového skóre
    property_id BIGINT NOT NULL, -- Reference na property_id (FK constraint handled at application level)
    
    calculation_date DATE NOT NULL, -- Datum výpočtu rizikového skóre
    market_risk_score DECIMAL(2, 1), -- Tržní riziko (1-5)
    location_risk_score DECIMAL(2, 1), -- Riziko lokality (1-5)
    structural_risk_score DECIMAL(2, 1), -- Strukturální riziko (1-5)
    legal_risk_score DECIMAL(2, 1), -- Právní riziko (1-5)
    liquidity_risk_score DECIMAL(2, 1), -- Likviditní riziko (1-5)
    overall_property_risk_score DECIMAL(2, 1), -- Celkové rizikové skóre nemovitosti (1-5)
    risk_factors_description STRING, -- Popis faktorů ovlivňujících rizikové skóre (JSON as STRING)
    
    ins_dt TIMESTAMP NOT NULL, -- Datum vložení záznamu
    upd_dt TIMESTAMP NOT NULL, -- Datum poslední aktualizace záznamu
    del_flag BOOLEAN NOT NULL -- Příznak smazání záznamu
)
USING DELTA
TBLPROPERTIES (
    'description' = 'Rizikové skóre nemovitostí včetně jednotlivých komponent a celkového hodnocení',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

COMMENT ON TABLE realitky.cleaned.property_risk_score IS 'Rizikové skóre nemovitostí včetně jednotlivých komponent a celkového hodnocení.';

COMMENT ON COLUMN realitky.cleaned.property_risk_score.property_risk_id IS 'Unikátní identifikátor rizikového skóre.';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.property_id IS 'Reference na nemovitost (FK na cleaned.property).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.calculation_date IS 'Datum výpočtu rizikového skóre.';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.market_risk_score IS 'Tržní riziko (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.location_risk_score IS 'Riziko lokality (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.structural_risk_score IS 'Strukturální riziko (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.legal_risk_score IS 'Právní riziko (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.liquidity_risk_score IS 'Likviditní riziko (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.overall_property_risk_score IS 'Celkové rizikové skóre nemovitosti (1-5).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.risk_factors_description IS 'Popis faktorů ovlivňujících rizikové skóre (JSON format).';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_risk_score.del_flag IS 'Příznak smazání záznamu.';

-- Note: Data validation constraints (CHECK clauses) should be handled at application level
-- Example validation in ETL process:
/*
-- Validate risk scores are between 1 and 5
WHERE market_risk_score BETWEEN 1 AND 5
  AND location_risk_score BETWEEN 1 AND 5
  AND structural_risk_score BETWEEN 1 AND 5
  AND legal_risk_score BETWEEN 1 AND 5
  AND liquidity_risk_score BETWEEN 1 AND 5
  AND overall_property_risk_score BETWEEN 1 AND 5
*/
