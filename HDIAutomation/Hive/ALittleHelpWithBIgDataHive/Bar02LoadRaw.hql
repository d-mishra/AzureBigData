set hive.execution.engine=tez;

LOAD DATA INPATH 'wasbs:///data/Bar/' INTO TABLE Bar_RAW;