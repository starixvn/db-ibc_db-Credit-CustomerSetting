/*
	Created: Helen 
	Task: Offer for 
	DB: DBCUST/CustDB
	Date: 20160317
	
	,11,22,31 --Site:INDO,755555,35
*/ 

/* -- 23: 222223; 21	733333
*/

SELECT * 
INTO tmp_ProductStatusSiteCurrency_backup
FROM ProductStatusSiteCurrency WITH (NOLOCK)
WHERE  SportType = 211 
