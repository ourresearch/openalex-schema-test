--------------------------------------------------------
-- PaperRecommendations
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperRecommendations;
CREATE UNLOGGED TABLE mag.PaperRecommendations(
    PaperId BIGINT,
    RecommendedPaperId BIGINT,
    Score FLOAT8
  );

\COPY mag.PaperRecommendations(PaperId, RecommendedPaperId, Score) FROM 'input/advanced/PaperRecommendations.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_PaperRecommendations_PaperId ON mag.PaperRecommendations(PaperId);
--CREATE INDEX idx_PaperRecommendations_RecommendedPaperId ON mag.PaperRecommendations(RecommendedPaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperRecommendations;
\endif
