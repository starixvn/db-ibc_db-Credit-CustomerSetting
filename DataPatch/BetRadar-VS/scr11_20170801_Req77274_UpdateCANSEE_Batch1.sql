/*
	Created: Elodie 
	Task: Insert CanSee BetRadarVS for batch 1
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
USE CustDB
GO

DELETE FROM ProductLaunchedSiteCurrency WHERE SportType IN (190)

INSERT INTO ProductLaunchedSiteCurrency (SportType, Currency, SiteID, IsLaunched, IsTest)
SELECT 190 AS SportType, 0 AS Currency, s.siteid AS SiteID, 0 AS IsLaunched, 0 AS IsTest
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0

--Import sites which offered BetRadarVS
SELECT siteid
INTO #OfferedSites
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0
	AND s.site IN ('755555', 'Koribc', 'Indo', '733333')

UPDATE ps
SET ps.IsLaunched = 1
FROM dbo.ProductLaunchedSiteCurrency ps WITH (ROWLOCK,UPDLOCK)
	INNER JOIN #OfferedSites s ON s.siteid = ps.SiteID
WHERE SportType = 190

SELECT *
FROM ProductLaunchedSiteCurrency WITH (NOLOCK)
WHERE SportType = 190

