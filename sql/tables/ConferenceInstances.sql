--------------------------------------------------------
-- ConferenceInstances
--------------------------------------------------------
DROP TABLE IF EXISTS mag.ConferenceInstances;
CREATE UNLOGGED TABLE mag.ConferenceInstances(
    ConferenceInstanceId BIGINT PRIMARY KEY,
    NormalizedName TEXT,
    DisplayName TEXT,
    ConferenceSeriesId BIGINT,
    Location TEXT,
    OfficialUrl TEXT,
    StartDate DATE,
    EndDate DATE,
    AbstractRegistrationDate DATE,
    SubmissionDeadlineDate DATE,
    NotificationDueDate DATE,
    FinalVersionDueDate DATE,
    PaperCount BIGINT,
    PaperFamilyCount BIGINT,
    CitationCount BIGINT,
    Latitude FLOAT8,
    Longitude FLOAT8,
    CreatedDate DATE,
    geom geometry(POINT,4326)
  );

\COPY mag.ConferenceInstances(ConferenceInstanceId, NormalizedName, DisplayName, ConferenceSeriesId, Location, OfficialUrl, StartDate, EndDate, AbstractRegistrationDate, SubmissionDeadlineDate, NotificationDueDate, FinalVersionDueDate, PaperCount, PaperFamilyCount, CitationCount, Latitude, Longitude, CreatedDate) FROM 'input/mag/ConferenceInstances.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;

--CREATE INDEX idx_ConferenceInstances_NormalizedName ON mag.ConferenceInstances(NormalizedName);
--CREATE INDEX idx_ConferenceInstances_ConferenceSeriesId ON mag.ConferenceInstances(ConferenceSeriesId);
--CREATE INDEX idx_ConferenceInstances_Location ON mag.ConferenceInstances(Location);

UPDATE mag.ConferenceInstances
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude),4326);
--CREATE INDEX idx_ConferenceInstances_geom ON mag.ConferenceInstances USING gist(geom);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.ConferenceInstances;
\endif
