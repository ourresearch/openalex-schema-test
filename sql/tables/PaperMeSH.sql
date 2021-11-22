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

\COPY mag.PaperMeSH(PaperId, DescriptorUI, DescriptorName, QualifierUI, QualifierName, IsMajorTopic) FROM PROGRAM 'tail -n+2 input/advanced/PaperMeSH.txt' null as '';

--CREATE INDEX idx_PaperMeSH_PaperId ON mag.PaperMeSH(PaperId);
--CREATE INDEX idx_PaperMeSH_DescriptorUI ON mag.PaperMeSH(DescriptorUI);
--CREATE INDEX idx_PaperMeSH_QualifierUI ON mag.PaperMeSH(QualifierUI);
