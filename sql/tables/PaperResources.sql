--------------------------------------------------------
-- PaperResources
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperResources;
CREATE UNLOGGED TABLE mag.PaperResources(
    PaperId BIGINT,
    ResourceType SMALLINT,
    ResourceUrl TEXT,
    SourceUrl TEXT,
    RelationshipType SMALLINT
  );

\COPY mag.PaperResources(PaperId, ResourceType, ResourceUrl, SourceUrl, RelationshipType) FROM PROGRAM 'tail -n+2 input/mag/PaperResources.txt' null as '';


--CREATE INDEX idx_PaperResources_PaperId ON mag.PaperResources(PaperId);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperResources;
\endif
