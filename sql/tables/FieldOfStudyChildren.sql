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

