--------------------------------------------------------
-- PaperExtendedAttributes
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperExtendedAttributes;
CREATE UNLOGGED TABLE mag.PaperExtendedAttributes(
    PaperId BIGINT,
    AttributeType SMALLINT,
    AttributeValue TEXT
  );
\COPY mag.PaperExtendedAttributes(PaperId, AttributeType, AttributeValue) FROM 'input/mag/PaperExtendedAttributes.txt' WITH CSV delimiter E'\t'  ESCAPE '\' QUOTE E'\b'  null as '' HEADER;
-- '

--CREATE INDEX idx_PaperExtendedAttributes_PaperId ON mag.PaperExtendedAttributes(PaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperExtendedAttributes;
\endif
