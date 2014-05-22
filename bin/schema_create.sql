CREATE TABLE IF NOT EXISTS "dummy_table" (
    "dummy_table_id"     smallserial    NOT NULL,
    "title"              varchar(20)    NOT NULL DEFAULT '',
    "number"             integer        NOT NULL DEFAULT '',
    PRIMARY KEY ("dummy_table_id")
);