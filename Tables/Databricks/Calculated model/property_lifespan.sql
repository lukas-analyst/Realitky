-- DROP TABLE realitky.calculated.property_lifespan;

CREATE TABLE IF NOT EXISTS realitky.calculated.property_lifespan (
    property_id BIGINT NOT NULL, -- Identifikátor nemovitosti (odkaz na cleaned.property)
    
    open_date DATE NOT NULL, -- První den, kdy byl inzerát zaznamenán
    sold_date DATE,          -- Den, kdy se inzerát poprvé stal neaktivním (is_active_listing = false)

    reactivated_count INT NOT NULL,      -- Kolikrát byl inzerát znovu aktivován (počet aktivních období - 1)
    active_days INT NOT NULL,            -- Celkový počet aktivních dní napříč všemi aktivními intervaly
    active_days_expected INT NOT NULL,   -- Očekávané aktivní dny

    src_web VARCHAR(255) NOT NULL,
    ins_dt TIMESTAMP NOT NULL,
    upd_dt TIMESTAMP NOT NULL,
    ins_process_id BIGINT,
    upd_process_id BIGINT,
    del_flag BOOLEAN NOT NULL
)
USING DELTA
TBLPROPERTIES (
    'desc' = 'Výpočtová tabulka životnosti inzerátů (open_date → sold_date) s reaktivacemi a metadaty.',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.deletedFileRetentionDuration' = 'interval 7 days',
    'delta.logRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.calculated.property_lifespan IS 'Životnost inzerátu: open_date, sold_date, reaktivace a aktivní dny.';

-- Column comments
COMMENT ON COLUMN realitky.calculated.property_lifespan.property_id IS 'Identifikátor nemovitosti (odkaz na cleaned.property).';

COMMENT ON COLUMN realitky.calculated.property_lifespan.open_date IS 'První den, kdy byl inzerát zaznamenán.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.sold_date IS 'Den, kdy se inzerát poprvé stal neaktivním (is_active_listing = false).';

COMMENT ON COLUMN realitky.calculated.property_lifespan.reactivated_count IS 'Počet reaktivací (počet aktivních období minus 1).';
COMMENT ON COLUMN realitky.calculated.property_lifespan.active_days IS 'Součet aktivních dnů napříč všemi aktivními intervaly.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.active_days_expected IS 'Očekávané aktivní dny';

COMMENT ON COLUMN realitky.calculated.property_lifespan.src_web IS 'Zdrojový web, ze kterého inzerát pochází.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.ins_dt IS 'Datum vložení záznamu.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.upd_dt IS 'Datum poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.ins_process_id IS 'ID procesu, který záznam vložil.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.upd_process_id IS 'ID procesu, který záznam aktualizoval.';
COMMENT ON COLUMN realitky.calculated.property_lifespan.del_flag IS 'Příznak logického smazání.';
