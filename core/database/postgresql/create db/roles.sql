-- ROLE 1: Pro Python skripty (vkládání a update, žádné mazání)
CREATE ROLE py_writer LOGIN PASSWORD 'silne_heslo';
COMMENT ON ROLE py_writer IS 'Role pro Python skripty: vkládání a aktualizace dat ve schématech raw, parsed, cleaned.';

-- ROLE 2: Pro běžné uživatele (čtení a export dat)
CREATE ROLE data_reader LOGIN PASSWORD 'bezpecne_heslo';
COMMENT ON ROLE data_reader IS 'Role pro uživatele: pouze čtení a export dat ze všech schémat.';

-- ROLE 3: Pro reporting (čtení pouze ze schématu merged)
CREATE ROLE report_reader LOGIN PASSWORD 'report_heslo';
COMMENT ON ROLE report_reader IS 'Role pro reporting: pouze čtení dat ze schématu merged.';

-- RAW, PARSED, CLEANED: zápis pro py_writer, čtení pro data_reader, report_reader nemá přístup
GRANT USAGE, SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA raw TO py_writer;
GRANT USAGE, SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA parsed TO py_writer;
GRANT USAGE, SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA cleaned TO py_writer;

GRANT USAGE, SELECT ON ALL TABLES IN SCHEMA raw TO data_reader;
GRANT USAGE, SELECT ON ALL TABLES IN SCHEMA parsed TO data_reader;
GRANT USAGE, SELECT ON ALL TABLES IN SCHEMA cleaned TO data_reader;

-- Merged: pouze čtení pro report_reader
GRANT USAGE, SELECT ON ALL TABLES IN SCHEMA merged TO report_reader;

-- Automatické udělení práv na nové tabulky
ALTER DEFAULT PRIVILEGES IN SCHEMA raw    GRANT SELECT, INSERT, UPDATE ON TABLES TO py_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA parsed GRANT SELECT, INSERT, UPDATE ON TABLES TO py_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA cleaned GRANT SELECT, INSERT, UPDATE ON TABLES TO py_writer;

ALTER DEFAULT PRIVILEGES IN SCHEMA raw    GRANT SELECT ON TABLES TO data_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA parsed GRANT SELECT ON TABLES TO data_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA cleaned GRANT SELECT ON TABLES TO data_reader;

ALTER DEFAULT PRIVILEGES IN SCHEMA merged GRANT SELECT ON TABLES TO report_reader;