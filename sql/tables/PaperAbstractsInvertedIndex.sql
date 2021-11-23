--------------------------------------------------------
-- PaperAbstractsInvertedIndex
--------------------------------------------------------

DROP TABLE IF EXISTS mag.PaperAbstractsInvertedIndex;
CREATE UNLOGGED TABLE mag.PaperAbstractsInvertedIndex(
    PaperId BIGINT PRIMARY KEY,
    IndexedAbstract JSONB
  );

\COPY mag.PaperAbstractsInvertedIndex(PaperId, IndexedAbstract) FROM PROGRAM 'awk FNR-1 input/nlp/PaperAbstractsInvertedIndex.txt* | sed "s/\\\\\\+u0000//g"' null as '';

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperAbstractsInvertedIndex;
\endif
