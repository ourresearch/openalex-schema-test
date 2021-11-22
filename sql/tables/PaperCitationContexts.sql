--------------------------------------------------------
-- PaperCitationContexts
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperCitationContexts;
CREATE UNLOGGED TABLE mag.PaperCitationContexts(
    PaperId BIGINT,
    PaperReferenceId BIGINT,
    CitationContext TEXT
  );

\COPY mag.PaperCitationContexts(PaperId, PaperReferenceId, CitationContext) FROM PROGRAM 'tail -n+2 input/nlp/PaperCitationContexts.txt' null as '';

--CREATE INDEX idx_PaperCitationContexts_PaperId ON mag.PaperCitationContexts(PaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperCitationContexts;
\endif
