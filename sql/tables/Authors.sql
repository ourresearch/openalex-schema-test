--------------------------------------------------------
-- Authors
--------------------------------------------------------
DROP TABLE IF EXISTS mag.Authors;
CREATE UNLOGGED TABLE mag.Authors(
    AuthorId BIGINT PRIMARY KEY,
    Rank INT,
    NormalizedName TEXT,
    DisplayName TEXT,
    Orcid TEXT,
    LastKnownAffiliationId BIGINT,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    CreatedDate DATE,
    UpdatedDate timestamp without time zone
  );

\COPY mag.Authors(AuthorId, Rank, NormalizedName, DisplayName, Orcid, LastKnownAffiliationId, PaperCount, PaperFamilyCount, CitationCount, CreatedDate, UpdatedDate) FROM 'input/mag/Authors.txt' DELIMITER E'\t' CSV HEADER QUOTE E'\b' null as '';

--CREATE INDEX idx_Authors_NormalizedName ON mag.Authors(NormalizedName);
--CREATE INDEX idx_Authors_LastKnownAffiliationId ON mag.Authors(LastKnownAffiliationId);
-- CREATE INDEX gidx_Authors_NormalizedName ON mag.Authors USING GIN(NormalizedName gin_trgm_ops);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.Authors;
\endif
