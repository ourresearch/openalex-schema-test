--------------------------------------------------------
-- Papers
--------------------------------------------------------
DROP TABLE IF EXISTS mag.Papers;
CREATE UNLOGGED TABLE mag.Papers(
    PaperId BIGINT PRIMARY KEY,
    Rank INT,
    Doi TEXT,
    DocType TEXT,
    Genre TEXT,
    IsParatext BOOLEAN,
    PaperTitle TEXT,
    OriginalTitle TEXT,
    BookTitle TEXT,
    Year SMALLINT,
    Date DATE,
    OnlineDate DATE,
    Publisher TEXT,
    JournalId BIGINT,
    ConferenceSeriesId BIGINT,
    ConferenceInstanceId BIGINT,
    Volume TEXT,
    Issue TEXT,
    FirstPage TEXT,
    LastPage TEXT,
    ReferenceCount BIGINT,
    CitationCount BIGINT,
    EstimatedCitation BIGINT,
    OriginalVenue TEXT,
    FamilyId BIGINT,
    FamilyRank INT,
    DocSubTypes TEXT,
    OaStatus TEXT,
    BestUrl TEXT,
    BestFreeUrl TEXT,
    BestFreeVersion TEXT,
    DoiLower TEXT,
    CreatedDate DATE,
    UpdatedDate timestamp without time zone
  );

\! tr -d '\000' < input/mag/Papers.txt > input/mag/Papers_.txt

\COPY mag.Papers(PaperId, Rank, Doi, DocType, Genre, IsParatext, PaperTitle, OriginalTitle, BookTitle, Year, Date, OnlineDate, Publisher, JournalId, ConferenceSeriesId, ConferenceInstanceId, Volume, Issue, FirstPage, LastPage, ReferenceCount, CitationCount, EstimatedCitation, OriginalVenue, FamilyId, FamilyRank, DocSubTypes, OaStatus, BestUrl, BestFreeUrl, BestFreeVersion, DoiLower, CreatedDate, UpdatedDate) FROM PROGRAM 'tail -n+2 input/mag/Papers_.txt' NULL as '';

--CREATE INDEX idx_Papers_PaperTitle ON mag.Papers(PaperTitle);
--CREATE INDEX idx_Papers_OriginalTitle ON mag.Papers(OriginalTitle);
--CREATE INDEX idx_Papers_BookTitle ON mag.Papers(BookTitle);
--CREATE INDEX idx_Papers_Year ON mag.Papers(Year);
--CREATE INDEX idx_Papers_JournalId ON mag.Papers(JournalId);
--CREATE INDEX idx_Papers_FamilyId ON mag.Papers(FamilyId);
--CREATE INDEX gidx_Papers_PaperTitle ON  mag.Papers USING GIN(PaperTitle gin_trgm_ops);
--CREATE INDEX gidx_Papers_BookTitle ON  mag.Papers USING GIN(BookTitle gin_trgm_ops);


