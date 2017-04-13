set hive.execution.engine=tez;

CREATE EXTERNAL TABLE IF NOT EXISTS Bar_RAW
(
	  BarID STRING	
	, BarNumber STRING
	, BarSize STRING	
	, BarFlavor STRING	
	, BarCost STRING	
	, BarSalePrice STRING	
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/Bar/Bar_RAW'
TBLPROPERTIES("skip.header.line.count"="1");