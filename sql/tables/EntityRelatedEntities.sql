--------------------------------------------------------
-- EntityRelatedEntities
--------------------------------------------------------
DROP TABLE IF EXISTS mag.EntityRelatedEntities;
CREATE UNLOGGED TABLE mag.EntityRelatedEntities(
    EntityId BIGINT,
    EntityType TEXT,
    RelatedEntityId BIGINT,
    RelatedEntityType TEXT,
    RelatedType SMALLINT,
    Score FLOAT8
  );

\COPY mag.EntityRelatedEntities(EntityId, EntityType, RelatedEntityId, RelatedEntityType, RelatedType, Score) FROM PROGRAM 'tail -n+2 input/advanced/EntityRelatedEntities.txt' null as '';

--CREATE INDEX idx_EntityRelatedEntities_EntityId ON mag.EntityRelatedEntities(EntityId);
--CREATE INDEX idx_EntityRelatedEntities_RelatedEntityId ON mag.EntityRelatedEntities(RelatedEntityId);

