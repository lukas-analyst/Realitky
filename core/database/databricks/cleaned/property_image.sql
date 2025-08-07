-- DROP TABLE realitky.cleaned.property_image;

CREATE TABLE IF NOT EXISTS realitky.cleaned.property_images 
(
    property_img_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    property_id STRING NOT NULL,
    img_link STRING NOT NULL,
    img_number STRING NOT NULL,
    src_web STRING NOT NULL,
    ins_dt TIMESTAMP NOT NULL,
    ins_process_id STRING,
    upd_dt TIMESTAMP NOT NULL,
    upd_process_id STRING,
    del_flag BOOLEAN NOT NULL
)
USING DELTA
PARTITIONED BY (src_web)
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true',
    'delta.logRetentionDuration' = 'interval 30 days',
    'delta.deletedFileRetentionDuration' = 'interval 30 days'
);

-- Table comment
COMMENT ON TABLE realitky.cleaned.property_images IS 'Tabulka obsahující odkazy na obrázky nemovitostí.';

-- Column comments
COMMENT ON COLUMN realitky.cleaned.property_images.property_img_id IS 'Unikátní identifikátor obrázku.';
COMMENT ON COLUMN realitky.cleaned.property_images.property_id IS 'ID nemovitosti, ke které obrázek patří.';
COMMENT ON COLUMN realitky.cleaned.property_images.img_link IS 'Odkaz na obrázek nemovitosti.';
COMMENT ON COLUMN realitky.cleaned.property_images.img_number IS 'Číslo obrázku (např. 1, 2, 3 atd.).';
COMMENT ON COLUMN realitky.cleaned.property_images.src_web IS 'Zdrojový web, ze kterého obrázek pochází (např. bezrealitky.cz, sreality.cz).';
COMMENT ON COLUMN realitky.cleaned.property_images.ins_dt IS 'Datum a čas vložení záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_images.ins_process_id IS 'ID procesu, který vložil záznam.';
COMMENT ON COLUMN realitky.cleaned.property_images.upd_dt IS 'Datum a čas poslední aktualizace záznamu.';
COMMENT ON COLUMN realitky.cleaned.property_images.upd_process_id IS 'ID procesu, který naposledy aktualizoval záznam.';
COMMENT ON COLUMN realitky.cleaned.property_images.del_flag IS 'Příznak smazání záznamu (TRUE = záznam je smazán, FALSE = záznam je aktivní).';