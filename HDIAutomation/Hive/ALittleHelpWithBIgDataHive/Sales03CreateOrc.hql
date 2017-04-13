set hive.execution.engine=tez;

CREATE EXTERNAL TABLE IF NOT EXISTS Sales
(
	  SalesRecordID STRING	
	, StudentID STRING
	, BarID STRING	
	, SaleDate STRING	
	, QuantitySold INT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/Sales';