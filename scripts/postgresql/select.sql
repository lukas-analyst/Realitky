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
SELECT * FROM cleaned.bezrealitky;
SELECT * FROM cleaned.bidli;
SELECT * FROM cleaned.century21;
SELECT * FROM cleaned.idnes;
SELECT * FROM cleaned.remax;
SELECT * FROM cleaned.sreality;
