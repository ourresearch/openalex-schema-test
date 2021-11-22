--------------------------------------------------------
-- PaperReferences
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperReferences;
CREATE UNLOGGED TABLE mag.PaperReferences(
    PaperId BIGINT,
    PaperReferenceId BIGINT
  );

\COPY mag.PaperReferences(PaperId, PaperReferenceId) FROM PROGRAM 'tail -n+2 input/mag/PaperReferences.txt' null as '';

--CREATE INDEX idx_PaperReferences_PaperId ON mag.PaperReferences(PaperId);
--CREATE INDEX idx_PaperReferences_PaperReferenceId ON mag.PaperReferences(PaperReferenceId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperReferences;
\endif
