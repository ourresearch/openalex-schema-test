--------------------------------------------------------
-- Journals
--------------------------------------------------------
DROP TABLE IF EXISTS mag.Journals;
CREATE UNLOGGED TABLE mag.Journals(
    JournalId BIGINT  PRIMARY KEY,
    Rank INT,
    NormalizedName TEXT,
    DisplayName TEXT,
    Issn TEXT,
    Issns TEXT,
    IsOa BOOLEAN,
    IsInDoaj BOOLEAN,
    Publisher TEXT,
    Webpage TEXT,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    CreatedDate DATE,
    UpdatedDate timestamp without time zone
  );

\COPY mag.Journals(JournalId, Rank, NormalizedName, DisplayName, Issn, Issns, IsOa, IsInDoaj, Publisher, Webpage, PaperCount, PaperFamilyCount, CitationCount, CreatedDate, UpdatedDate) FROM 'input/mag/Journals.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_Journals_NormalizedName ON mag.Journals(NormalizedName);
--CREATE INDEX idx_Journals_Issn ON mag.Journals(Issn);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.Journals;
\endif
