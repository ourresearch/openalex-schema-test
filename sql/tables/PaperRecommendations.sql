--------------------------------------------------------
-- PaperRecommendations
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperRecommendations;
CREATE UNLOGGED TABLE mag.PaperRecommendations(
    PaperId BIGINT,
    RecommendedPaperId BIGINT,
    Score FLOAT8
  );

\COPY mag.PaperRecommendations(PaperId, RecommendedPaperId, Score) FROM PROGRAM 'tail -n+2 input/advanced/PaperRecommendations.txt' null as '';

--CREATE INDEX idx_PaperRecommendations_PaperId ON mag.PaperRecommendations(PaperId);
--CREATE INDEX idx_PaperRecommendations_RecommendedPaperId ON mag.PaperRecommendations(RecommendedPaperId);

