set hive.execution.engine=tez;

INSERT OVERWRITE TABLE Sales
SELECT 
	  SalesRecordID 	
	, StudentID 
	, BarID 	
	, SaleDate 	
	, QuantitySold 	
FROM Sales_RAW
;