--------------------------------------------------------
-- ConferenceSeries
--------------------------------------------------------
DROP TABLE IF EXISTS mag.ConferenceSeries;
CREATE UNLOGGED TABLE mag.ConferenceSeries(
    ConferenceSeriesId BIGINT PRIMARY KEY,
    Rank INT,
    NormalizedName TEXT,
    DisplayName TEXT,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    CreatedDate DATE
  );

\COPY mag.ConferenceSeries(ConferenceSeriesId, Rank, NormalizedName, DisplayName, PaperCount, PaperFamilyCount, CitationCount, CreatedDate) FROM 'input/mag/ConferenceSeries.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_ConferenceSeries_NormalizedName ON mag.ConferenceSeries(NormalizedName);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.ConferenceSeries;
\endif
