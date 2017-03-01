/*
	Created by: Helen
	Created Date: 20160831
	Task: https://nexdev.net/issues/63325
	
	DB: DBCUST/CUSTDB
*/
DELETE FROM ProductStatusSiteCurrency 
WHERE SportType = 211

INSERT INTO ProductStatusSiteCurrency (SportType,BetType,SiteID, Currency, IsHidden,IsDisabled)
SELECT 211,2401,siteid, 0,1,1
FROM Site (NOLOCK)
WHERE siteID NOT IN (22,11,35)-- INDO: 11; 755555:22;  Koribc: 35
	AND isLicensee = 0
	

UNION ALL

SELECT 211,2402,siteid, 0,1,1
FROM Site (NOLOCK)
WHERE siteID NOT IN (22,11,35)-- INDO: 11; 755555:22;  Koribc: 35
	AND isLicensee = 0

