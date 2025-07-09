-- RAW: Surová data
CREATE SCHEMA IF NOT EXISTS raw;
COMMENT ON SCHEMA raw IS 'Surová nascrapovaná data z realitních webů.';

-- PARSED: Rozparsovaná data
CREATE SCHEMA IF NOT EXISTS parsed;
COMMENT ON SCHEMA parsed IS 'Rozparsovaná data do jednotlivých sloupců.';

-- CLEANED: Vyčištěná a normalizovaná data
CREATE SCHEMA IF NOT EXISTS cleaned;
COMMENT ON SCHEMA cleaned IS 'Vyčištěná, atomizovaná a normalizovaná data.';

-- MERGED: Agregovaná/reportovací data
CREATE SCHEMA IF NOT EXISTS merged;
COMMENT ON SCHEMA merged IS 'Agregovaná data pro reporting a dashboardy.';