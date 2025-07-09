CREATE TABLE IF NOT EXISTS public.etl_log (
    log_id SERIAL PRIMARY KEY,
    script_name TEXT NOT NULL,
    run_start TIMESTAMPTZ NOT NULL DEFAULT now(),
    run_end TIMESTAMPTZ,
    status TEXT NOT NULL, -- např. 'OK', 'ERROR'
    message TEXT,
    row_count INT,
    source_file TEXT,
    created_by TEXT DEFAULT current_user
);

COMMENT ON TABLE public.etl_log IS 'Logovací tabulka pro běh ETL skriptů a monitoring pipeline.';
COMMENT ON COLUMN public.etl_log.script_name IS 'Název spouštěného skriptu nebo procesu.';
COMMENT ON COLUMN public.etl_log.run_start IS 'Čas začátku běhu.';
COMMENT ON COLUMN public.etl_log.run_end IS 'Čas konce běhu.';
COMMENT ON COLUMN public.etl_log.status IS 'Výsledek běhu (OK/ERROR).';
COMMENT ON COLUMN public.etl_log.message IS 'Detailní zpráva nebo chyba.';
COMMENT ON COLUMN public.etl_log.row_count IS 'Počet zpracovaných řádků.';
COMMENT ON COLUMN public.etl_log.source_file IS 'Zdrojový soubor (např. JSON/CSV).';
COMMENT ON COLUMN public.etl_log.created_by IS 'Uživatel, který záznam vytvořil.';