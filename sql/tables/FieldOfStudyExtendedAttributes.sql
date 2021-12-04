--------------------------------------------------------
-- FieldOfStudyExtendedAttributes
--------------------------------------------------------
DROP TABLE IF EXISTS mag.FieldOfStudyExtendedAttributes;
CREATE UNLOGGED TABLE mag.FieldOfStudyExtendedAttributes(
    FieldOfStudyId BIGINT,
    AttributeType SMALLINT,
    AttributeValue TEXT
  );

\COPY mag.FieldOfStudyExtendedAttributes(FieldOfStudyId, AttributeType, AttributeValue) FROM 'input/advanced/FieldOfStudyExtendedAttributes.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;

--CREATE INDEX idx_FieldOfStudyExtendedAttributes_FieldOfStudyId ON mag.FieldOfStudyExtendedAttributes(FieldOfStudyId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.FieldOfStudyExtendedAttributes;
\endif
