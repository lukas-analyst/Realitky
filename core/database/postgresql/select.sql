-- RAW data
select * from raw.bezrealitky order by id;
select * from raw.remax order by id;
select * from raw.sreality order by id;
select * from raw.bidli order by id;
select * from raw.century21 order by id;
select * from raw.idnes order by id;

-- Parsed data
SELECT * FROM parsed.bezrealitky;
SELECT * FROM parsed.bidli;
SELECT * FROM parsed.century21;
SELECT * FROM parsed.idnes;
SELECT * FROM parsed.remax;
SELECT * FROM parsed.sreality;

-- Cleaned data
SELECT * FROM cleaned.transaction;
SELECT * FROM cleaned.property_type;
SELECT * FROM cleaned.property_subtype;
SELECT * FROM cleaned.macroeconomics;
SELECT * FROM cleaned.location_statistics;
SELECT * FROM cleaned.cadastre;
SELECT * FROM cleaned.cadstre_encumbered;
SELECT * FROM cleaned.client;
SELECT * FROM cleaned.loan_simulation;
SELECT * FROM cleaned.price_estimate;
SELECT * FROM cleaned.property_risk_score;
