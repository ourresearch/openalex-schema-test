--------------------------------------------------------
-- FieldOfStudyChildren
--------------------------------------------------------
DROP TABLE IF EXISTS mag.FieldOfStudyChildren;
CREATE UNLOGGED TABLE mag.FieldOfStudyChildren(
    FieldOfStudyId BIGINT,
    ChildFieldOfStudyId BIGINT
  );

\COPY mag.FieldOfStudyChildren(FieldOfStudyId, ChildFieldOfStudyId) FROM PROGRAM 'tail -n+2 input/advanced/FieldOfStudyChildren.txt' null as '';

--CREATE INDEX idx_FieldOfStudyChildren_FieldOfStudyId ON mag.FieldOfStudyChildren(FieldOfStudyId);
--CREATE INDEX idx_FieldOfStudyChildren_ChildFieldOfStudyId ON mag.FieldOfStudyChildren(ChildFieldOfStudyId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.FieldOfStudyChildren;
\endif
