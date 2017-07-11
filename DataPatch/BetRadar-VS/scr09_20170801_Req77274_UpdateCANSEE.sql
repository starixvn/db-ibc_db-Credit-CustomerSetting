/*
	Created: Elodie 
	Task: Insert CanSee for BetRadarVS and Inspired VS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
USE CustDB
GO

DELETE FROM ProductLaunchedSiteCurrency WHERE SportType IN (180,190)

INSERT INTO ProductLaunchedSiteCurrency (SportType, Currency, SiteID, IsLaunched, IsTest)
SELECT 180 AS SportType, 0 AS Currency, s.siteid AS SiteID, 1 AS IsLaunched, 0 AS IsTest
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0
UNION
SELECT 190 AS SportType, 0 AS Currency, s.siteid AS SiteID, 0 AS IsLaunched, 0 AS IsTest
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0

