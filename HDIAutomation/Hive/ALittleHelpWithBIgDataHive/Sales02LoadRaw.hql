set hive.execution.engine=tez;

LOAD DATA INPATH 'wasbs:///data/Sales/' INTO TABLE Sales_RAW;