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

