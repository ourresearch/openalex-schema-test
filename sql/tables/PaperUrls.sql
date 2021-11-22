--------------------------------------------------------
-- PaperUrls
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperUrls;
CREATE UNLOGGED TABLE mag.PaperUrls(
    PaperId BIGINT,
    SourceType SMALLINT,
    SourceUrl TEXT,
    LanguageCode TEXT,
    UrlForLandingPage TEXT,
    UrlForPdf TEXT,
    HostType TEXT,
    Version TEXT,
    License TEXT,
    RepositoryInstitution TEXT,
    OaiPmhId TEXT
  );

\COPY mag.PaperUrls(PaperId, SourceType, SourceUrl, LanguageCode, UrlForLandingPage, UrlForPdf, HostType, Version, License, RepositoryInstitution, OaiPmhId) FROM PROGRAM 'tail -n+2 input/mag/PaperUrls.txt' delimiter E'\t' null as '';

--CREATE INDEX idx_PaperUrls_PaperId ON mag.PaperUrls(PaperId);

