--------------------------------------------------------
-- FieldOfStudyExtendedAttributes
--------------------------------------------------------
DROP TABLE IF EXISTS mag.FieldOfStudyExtendedAttributes;
CREATE UNLOGGED TABLE mag.FieldOfStudyExtendedAttributes(
    FieldOfStudyId BIGINT,
    AttributeType SMALLINT,
    AttributeValue TEXT
  );

\COPY mag.FieldOfStudyExtendedAttributes(FieldOfStudyId, AttributeType, AttributeValue) FROM program 'tail -n+2 input/advanced/FieldOfStudyExtendedAttributes.txt' null as '';

--CREATE INDEX idx_FieldOfStudyExtendedAttributes_FieldOfStudyId ON mag.FieldOfStudyExtendedAttributes(FieldOfStudyId);

