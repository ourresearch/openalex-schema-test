--------------------------------------------------------
-- PaperReferences
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperReferences;
CREATE UNLOGGED TABLE mag.PaperReferences(
    PaperId BIGINT,
    PaperReferenceId BIGINT
  );

\COPY mag.PaperReferences(PaperId, PaperReferenceId) FROM 'input/mag/PaperReferences.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_PaperReferences_PaperId ON mag.PaperReferences(PaperId);
--CREATE INDEX idx_PaperReferences_PaperReferenceId ON mag.PaperReferences(PaperReferenceId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperReferences;
\endif
