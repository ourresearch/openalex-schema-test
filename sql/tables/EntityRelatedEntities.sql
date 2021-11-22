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

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.EntityRelatedEntities;
\endif
