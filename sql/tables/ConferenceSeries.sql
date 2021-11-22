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

\COPY mag.ConferenceSeries(ConferenceSeriesId, Rank, NormalizedName, DisplayName, PaperCount, PaperFamilyCount, CitationCount, CreatedDate) FROM PROGRAM 'tail -n+2 input/mag/ConferenceSeries.txt' null as '';

--CREATE INDEX idx_ConferenceSeries_NormalizedName ON mag.ConferenceSeries(NormalizedName);

