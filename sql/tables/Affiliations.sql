--------------------------------------------------------
-- affiliations
--------------------------------------------------------

DROP TABLE IF EXISTS mag.affiliations;
CREATE UNLOGGED TABLE mag.affiliations(
    AffiliationId BIGINT PRIMARY KEY,
    Rank INT,
    NormalizedName TEXT,
    DisplayName TEXT,
    GridId TEXT,
    RorId TEXT,
    OfficialPage TEXT,
    WikiPage TEXT,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    Iso3166Code TEXT,
    Latitude FLOAT8,
    Longitude FLOAT8,
    CreatedDate DATE,
    UpdatedDate timestamp without time zone,
    geom geometry(POINT,4326)
  );

\COPY mag.affiliations(AffiliationId, Rank, NormalizedName, DisplayName, GridId, RorId, OfficialPage, WikiPage, PaperCount, PaperFamilyCount, CitationCount, Iso3166Code, Latitude, Longitude, CreatedDate, UpdatedDate) FROM PROGRAM 'tail -n+2 input/mag/Affiliations.txt' null as '';

--CREATE INDEX idx_affiliations_NormalizedName ON mag.affiliations(NormalizedName);
--CREATE INDEX idx_affiliations_GridId ON mag.affiliations(GridId);
--CREATE INDEX gidx_affiliations_NormalizedName ON mag.affiliations USING GIN(NormalizedName gin_trgm_ops);

UPDATE mag.affiliations
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude),4326);
--CREATE INDEX idx_affiliations_geom ON mag.affiliations USING gist(geom);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.Affiliations;
\endif
