/*
	Created: Elodie 
	Task: Insert CanSee BetRadarVS for batch 1
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
USE CustDB
GO

--Import sites which offered BetRadarVS
SELECT siteid
INTO #OfferedSites
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0
	AND s.siteid IN (1)

UPDATE ps
SET ps.IsLaunched = 1
FROM dbo.ProductLaunchedSiteCurrency ps WITH (ROWLOCK,UPDLOCK)
	INNER JOIN #OfferedSites s ON s.siteid = ps.SiteID
WHERE SportType = 190


