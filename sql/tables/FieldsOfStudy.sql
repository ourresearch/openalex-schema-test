--------------------------------------------------------
-- FieldsOfStudy
--------------------------------------------------------
DROP TABLE IF EXISTS mag.FieldsOfStudy;
CREATE UNLOGGED TABLE mag.FieldsOfStudy(
    FieldOfStudyId BIGINT PRIMARY KEY,
    Rank INT,
    NormalizedName TEXT,
    DisplayName TEXT,
    MainType TEXT,
    Level SMALLINT,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    CreatedDate DATE
  );

\COPY mag.FieldsOfStudy(FieldOfStudyId, Rank, NormalizedName, DisplayName, MainType, Level, PaperCount, PaperFamilyCount, CitationCount, CreatedDate) FROM PROGRAM 'tail -n+2 input/advanced/FieldsOfStudy.txt' null as '';

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.FieldsOfStudy;
\endif
