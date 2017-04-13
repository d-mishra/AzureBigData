set hive.execution.engine=tez;

INSERT OVERWRITE TABLE Bar
SELECT 
	  BarID 	
	, BarNumber 
	, BarSize 	
	, BarFlavor 	
	, CAST(BarCost AS DECIMAL(4,2))
	, CAST(BarSalePrice AS DECIMAL(4,2))	
FROM Bar_RAW
;