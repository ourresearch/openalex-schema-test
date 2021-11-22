--------------------------------------------------------
-- RelatedFieldOfStudy
--------------------------------------------------------
DROP TABLE IF EXISTS mag.RelatedFieldOfStudy;
CREATE UNLOGGED TABLE mag.RelatedFieldOfStudy(
    FieldOfStudyId1 BIGINT,
    Type1 TEXT,
    FieldOfStudyId2 BIGINT,
    Type2 TEXT,
    Rank FLOAT8
  );

\COPY mag.RelatedFieldOfStudy(FieldOfStudyId1, Type1, FieldOfStudyId2, Type2, Rank) FROM PROGRAM 'tail -n+2 input/advanced/RelatedFieldOfStudy.txt' null as '';

--CREATE INDEX idx_RelatedFieldOfStudy_FieldOfStudyId1 ON mag.RelatedFieldOfStudy(FieldOfStudyId1);
--CREATE INDEX idx_RelatedFieldOfStudy_FieldOfStudyId2 ON mag.RelatedFieldOfStudy(FieldOfStudyId2);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.RelatedFieldOfStudy;
\endif
