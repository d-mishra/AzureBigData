set hive.execution.engine=tez;

CREATE EXTERNAL TABLE IF NOT EXISTS Sales_RAW
(
	  SalesRecordID STRING	
	, StudentID STRING
	, BarID STRING	
	, SaleDate STRING	
	, QuantitySold INT			
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/Sales/Sales_RAW'
TBLPROPERTIES("skip.header.line.count"="1");