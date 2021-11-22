--------------------------------------------------------
-- PaperAbstractsInvertedIndex
--------------------------------------------------------

DROP TABLE IF EXISTS mag.PaperAbstractsInvertedIndex;
CREATE UNLOGGED TABLE mag.PaperAbstractsInvertedIndex(
    PaperId BIGINT PRIMARY KEY,
    IndexedAbstract JSONB
  );

\COPY mag.PaperAbstractsInvertedIndex(PaperId, IndexedAbstract) FROM PROGRAM 'awk FNR-1 input/nlp/PaperAbstractsInvertedIndex.txt*' null as '';

