--------------------------------------------------------
-- PaperFieldsOfStudy
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperFieldsOfStudy;
CREATE UNLOGGED TABLE mag.PaperFieldsOfStudy(
    PaperId BIGINT,
    FieldOfStudyId BIGINT,
    Score FLOAT8,
    AlgorithmVersion INT
  );

\COPY mag.PaperFieldsOfStudy(PaperId, FieldOfStudyId, Score, AlgorithmVersion) FROM PROGRAM 'tail -n+2 input/advanced/PaperFieldsOfStudy.txt' null as '';

--CREATE INDEX idx_PaperFieldsOfStudy_PaperId ON mag.PaperFieldsOfStudy(PaperId);
--CREATE INDEX idx_PaperFieldsOfStudy_FieldOfStudyId ON mag.PaperFieldsOfStudy(FieldOfStudyId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperFieldsOfStudy;
\endif
