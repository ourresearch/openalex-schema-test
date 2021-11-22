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


