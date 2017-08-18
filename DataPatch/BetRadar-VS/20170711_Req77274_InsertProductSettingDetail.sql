/*
	Created: 20170601@Elodie
	Task: Insert product profile for BetRadar VS and Inspired VS
	DB: DBCUST/CustDB
*/

-- BEGIN STEP 1: DEPLOY THIS SCRIPT ON DBCUST/CustDB	 --
-----------------------------------------------------------
USE CustDB
GO

DECLARE @SettingStatus TINYINT, @ProductID INT, @MaxPT TINYINT, @MaxDiscount DECIMAL(9,8), @IsSync BIT, @IsHidden BIT, @IsDisabled BIT, @BitmapOrder TINYINT, @IntervalValue DECIMAL(19,8)
SELECT @SettingStatus = 1 --0: Production, 1: UAT, 2: Hide
SELECT @ProductID = 5
SELECT @IsSync = 1
SELECT @IsHidden = 0
SELECT @IsDisabled = 0
SELECT @BitmapOrder = 10
SELECT @MaxPT = 90
--SELECT @MaxDiscount = 0.1
--SELECT @IntervalValue = NULL

--PT Setting
INSERT INTO	dbo.ProductSettingDetail
		(	SettingType, SportType	, BetType	, IsLive, ProductID		, MaxPT	, MaxDiscount	, IsSync	, IsHidden	, IsDisabled	, SettingLevel, DisplayOrder, SettingStatus, IntervalValue)
VALUES	
--PT	
		(	1          , 180		, 1201		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 181		, 1231		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 182		, 1231		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 183		, 1231		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 184		, 1231		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 185		, 1231		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 186		, 1220		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 190		, 2701		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
	,	(	1          , 191		, 2701		, 0     , @ProductID	, @MaxPT, NULL			, NULL		, NULL		, NULL			, 2           , 3           , @SettingStatus, NULL)
--Status Setting																																				
	,	(	13          , 180		, 1201		, 0     , @ProductID	, NULL	, NULL			, @IsSync	, @IsHidden	, @IsDisabled	, 1           , 1           , @SettingStatus, NULL)
--BetSetting																																				
	,	(	2          , 180		, 1201		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 181		, 1231		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 182		, 1231		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 183		, 1231		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 184		, 1231		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 185		, 1231		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 186		, 1220		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 190		, 2701		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 191		, 2701		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)
	,	(	2          , 199		, 2799		, 0     , @ProductID	, NULL	, NULL			, NULL		, NULL		, NULL			, 2           , 2           , @SettingStatus, NULL)


-- BEGIN STEP 2: DEPLOY THIS SCRIPT ON DBCUST/CustDB	 --
-----------------------------------------------------------

INSERT INTO	dbo.ProductStatusProfile(Sporttype, Bettype, bitmapOrder)
VALUES	(180, 1201, @BitmapOrder)

INSERT INTO dbo.ProductSettingSystemDisplay
        ( SystemID ,
          ProductID ,
          SettingType ,
          DisplayMode
        )
SELECT 5,@ProductID,13,3
UNION ALL 
SELECT 5,@ProductID,1,3

INSERT INTO dbo.ProductBetSetting (Sporttype, Bettype, Currency, MinBet, IsDep, MaxBet, MaxPerMatch, DefaultMinBet, DefaultMaxBet, DefaultMaxPerMatch)
SELECT ps.Sporttype, ps.Bettype, e.exchangeid, 0, 0, 0, 0, NULL, NULL, NULL
FROM dbo.ProductSettingDetail ps WITH (NOLOCK)
	OUTER APPLY dbo.exchange e WITH (NOLOCK)
WHERE ProductID = 5 AND SettingType = 2 
	
INSERT INTO ProductLaunchedSiteCurrency (SportType, Currency, SiteID, IsLaunched, IsTest)
SELECT 180 AS SportType, 0 AS Currency, s.siteid AS SiteID, 1 AS IsLaunched, 1 AS IsTest
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0
UNION
SELECT 190 AS SportType, 0 AS Currency, s.siteid AS SiteID, 0 AS IsLaunched, 1 AS IsTest
FROM dbo.Site s WITH(NOLOCK)
WHERE s.isActive = 1 AND s.isLicensee = 0

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



