
/*
	Created: Helen 
	Task: Offer for 
	DB: DBCUST/CustDB
	Date: 20161130
	
 -- 23: 222223; 21	733333
*/ 

INSERT INTO ProductLaunchedSiteCurrency (SiteID,Currency,SportType,IsLaunched,IsTest)

SELECT 21,E.exchangeid,211,1,0
FROM exchange e WITH (NOLOCK) 
WHERE e.exchangeid IN (1,2,5,13,67) --  SD$,RM,HK$,RMB,HKK

UNION ALL

SELECT 23,E.exchangeid,211,1,0
FROM exchange e WITH (NOLOCK) 
WHERE e.exchangeid IN (2,5,67) -- RM,HK$,HKK	
			