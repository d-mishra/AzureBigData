set hive.execution.engine=tez;

CREATE EXTERNAL TABLE IF NOT EXISTS Bar
(
	  BarID STRING	
	, BarNumber STRING
	, BarSize STRING	
	, BarFlavor STRING	
	, BarCost DECIMAL(4,2)	
	, BarSalePrice DECIMAL(4,2)	
)
STORED AS ORC
LOCATION '/user/hive/warehouse/Bar';