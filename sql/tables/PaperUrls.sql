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

\COPY mag.PaperUrls(PaperId, SourceType, SourceUrl, LanguageCode, UrlForLandingPage, UrlForPdf, HostType, Version, License, RepositoryInstitution, OaiPmhId) FROM 'input/mag/PaperUrls.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_PaperUrls_PaperId ON mag.PaperUrls(PaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperUrls;
\endif
