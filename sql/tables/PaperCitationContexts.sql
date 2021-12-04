--------------------------------------------------------
-- PaperCitationContexts
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperCitationContexts;
CREATE UNLOGGED TABLE mag.PaperCitationContexts(
    PaperId BIGINT,
    PaperReferenceId BIGINT,
    CitationContext TEXT
  );

\COPY mag.PaperCitationContexts(PaperId, PaperReferenceId, CitationContext) FROM 'input/nlp/PaperCitationContexts.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;

--CREATE INDEX idx_PaperCitationContexts_PaperId ON mag.PaperCitationContexts(PaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperCitationContexts;
\endif
