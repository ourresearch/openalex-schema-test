--------------------------------------------------------
-- PaperAuthorAffiliations
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperAuthorAffiliations;
CREATE UNLOGGED TABLE mag.PaperAuthorAffiliations(
    PaperId BIGINT,
    AuthorId BIGINT,
    AffiliationId BIGINT,
    AuthorSequenceNumber SMALLINT,
    OriginalAuthor TEXT,
    OriginalAffiliation TEXT
  );

\COPY mag.PaperAuthorAffiliations(PaperId, AuthorId, AffiliationId, AuthorSequenceNumber, OriginalAuthor, OriginalAffiliation) FROM 'input/mag/PaperAuthorAffiliations.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_PaperAuthorAffiliations_PaperId ON mag.PaperAuthorAffiliations(PaperId);
--CREATE INDEX idx_PaperAuthorAffiliations_AuthorId ON mag.PaperAuthorAffiliations(AuthorId);
--CREATE INDEX idx_PaperAuthorAffiliations_AffiliationId ON mag.PaperAuthorAffiliations(AffiliationId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperAuthorAffiliations;
\endif
