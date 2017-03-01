/*
	Created: Helen 
	Task: Offer for 
	DB: DBCUST/CustDB
	Date: 20160317
*/ 

/*-- INDO: 11; 755555:22;  Koribc: 35
*/
-- TW - control member for place bet
/*
DELETE ProductLaunchedSiteCurrency WHERE sporttype = 211 
go

INSERT INTO ProductLaunchedSiteCurrency (SiteID, Currency,SportType,IsLaunched,IsTest)
VALUES 
	-- INDO: 11
	(11,47,211,1,1)
	,(11,33,211,1,1)
	,(11,34,211,1,1)
	,(11,15,211,1,1)
	,(11,22,211,1,1)
	-- 755555:22
	,(22,43,211,1,1)
	--Koribc: 35
	, (35,45,211,1,1)
	-- Currenyc YNG for  INDO, KORIBC,755555
	, (1,72,211,1,1)
	, (11,72,211,1,1)
	, (22,72,211,1,1)
	, (35,72,211,1,1)
	-- UUS BestOdd
	, (1,20,211,1,1)
*/


UPDATE ProductLaunchedSiteCurrency SET IsLaunched = 0 
WHERE SportType = 211