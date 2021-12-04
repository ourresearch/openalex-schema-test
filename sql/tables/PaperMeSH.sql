--------------------------------------------------------
-- PaperMeSH
--------------------------------------------------------
DROP TABLE IF EXISTS mag.PaperMeSH;
CREATE UNLOGGED TABLE mag.PaperMeSH(
    PaperId BIGINT,
    DescriptorUI TEXT,
    DescriptorName TEXT,
    QualifierUI TEXT,
    QualifierName TEXT,
    IsMajorTopic BOOLEAN
  );

\COPY mag.PaperMeSH(PaperId, DescriptorUI, DescriptorName, QualifierUI, QualifierName, IsMajorTopic) FROM 'input/advanced/PaperMeSH.txt' null as '' DELIMITER E'\t' CSV HEADER QUOTE E'\b';

--CREATE INDEX idx_PaperMeSH_PaperId ON mag.PaperMeSH(PaperId);
--CREATE INDEX idx_PaperMeSH_DescriptorUI ON mag.PaperMeSH(DescriptorUI);
--CREATE INDEX idx_PaperMeSH_QualifierUI ON mag.PaperMeSH(QualifierUI);

SELECT :DROP_TABLE_AFTER_TEST = '1' as should_drop \gset
\if :should_drop
    DROP TABLE mag.PaperMeSH;
\endif
