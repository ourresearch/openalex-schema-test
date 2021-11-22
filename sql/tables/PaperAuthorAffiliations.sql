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

\COPY mag.PaperAuthorAffiliations(PaperId, AuthorId, AffiliationId, AuthorSequenceNumber, OriginalAuthor, OriginalAffiliation) FROM PROGRAM 'tail -n+2 input/mag/PaperAuthorAffiliations.txt' NULL as '';

--CREATE INDEX idx_PaperAuthorAffiliations_PaperId ON mag.PaperAuthorAffiliations(PaperId);
--CREATE INDEX idx_PaperAuthorAffiliations_AuthorId ON mag.PaperAuthorAffiliations(AuthorId);
--CREATE INDEX idx_PaperAuthorAffiliations_AffiliationId ON mag.PaperAuthorAffiliations(AffiliationId);

