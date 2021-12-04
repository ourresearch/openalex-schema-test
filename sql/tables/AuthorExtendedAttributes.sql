--------------------------------------------------------
-- AuthorExtendedAttributes
--------------------------------------------------------

DROP TABLE IF EXISTS mag.authorextendedattributes;
CREATE UNLOGGED TABLE mag.authorextendedattributes(
    AuthorId BIGINT,
    AttributeType SMALLINT,
    AttributeValue TEXT
  );

\COPY mag.authorextendedattributes(AuthorId, AttributeType, AttributeValue) FROM 'input/mag/AuthorExtendedAttributes.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_authorextendedattributes_AuthorId ON mag.authorextendedattributes(AuthorId);
--CREATE INDEX idx_authorextendedattributes_AttributeValue ON mag.authorextendedattributes(AttributeValue);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.authorextendedattributes;
\endif
