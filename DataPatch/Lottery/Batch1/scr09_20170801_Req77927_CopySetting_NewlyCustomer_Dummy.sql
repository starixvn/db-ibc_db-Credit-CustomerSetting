/*
	Created: Elodie
	Task: Copy Setting for newly created customer
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
PRINT N'Step 9: Start on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.';  

DECLARE @MaxCustID INT, @fSportType SMALLINT, @fBetType SMALLINT
	
SELECT @MaxCustID = xxx
	
CREATE TABLE #OfferedSite (site VARCHAR(10))
INSERT INTO #OfferedSite (site)
VALUES  ('755555'), ('Indo'), ('KORIBC'), ('733333'), ('222223'), ('222225'), ('222227')

CREATE TABLE #DummySupers (custid int)

INSERT INTO #DummySupers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid IN (2,3,4,5,12,13,15) -- dummy account
				          
CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	currency INT
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	currency INT
)
	
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT,currency INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT,currency INT)
CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT,currency INT)			
--- get direct master
INSERT INTO #DirectMaster (CustID,roleid,currency)
SELECT ci.custid, ci.roleid,c.currency
FROM Customer ci with(nolock)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
	AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	AND ci.roleid=3 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND c.Enabled=1
		
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid,currency)
SELECT ci.custid, ci.mrecommend,ci.roleid,c.currency
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
	AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	and ci.roleid = 2 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND c.Enabled=1

INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid,currency)
SELECT c.custid, c.recommend,c.mrecommend,c.roleid,c.currency
FROM Customer c WITH(NOLOCK)
INNER JOIN Customer ca (nolock) on c.recommend=ca.custid 
INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid=c.custid
WHERE EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ca.site)
	AND EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	AND c.roleid=1 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND ci.Enabled=1

----------- For SMA  -----------
INSERT INTO #SMATemp (CustID,RoleID,currency)
-----------------------Master--------------------------------------
SELECT d.CustID, 3, currency -- Direct Master 
FROM #DirectMaster d
WHERE d.CustID > @MaxCustID	
UNION 
SELECT DISTINCT d.mrecommend, 3, currency -- Master of direct agent
FROM #DirectAgent d
WHERE d.mrecommend > @MaxCustID
UNION 
SELECT DISTINCT d.mrecommend, 3, currency -- Master of direct member
FROM #DirectMember D 	
WHERE d.mrecommend > @MaxCustID
UNION 
-----------------------Agent--------------------------------------
SELECT ci.CustID,2, ci.currency -- Agent of direct master
FROM custInfo ci WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON ci.mrecommend = d.CustID 
WHERE ci.roleid = 2 AND ci.Enabled=1 AND ci.custid > @maxcustid 
UNION
SELECT DISTINCT d.recommend, 2, currency -- agent of direct member
FROM #DirectMember D 	
WHERE d.recommend > @MaxCustID
UNION 
SELECT d.CustID, 2, currency -- Direct Agent
FROM #DirectAgent D
WHERE d.CustID > @MaxCustID	
	 	
---------- For members ---------
INSERT INTO #MemberTemp (CustID, currency)
SELECT  ci.custid, ci.currency -- member of direct master
FROM Custinfo ci WITH (NOLOCK)
	INNER JOIN #DirectMaster m ON ci.mrecommend = m.CustID
WHERE ci.roleid = 1	AND ci.custid > @maxcustid AND ci.Enabled = 1 			
UNION ALL -- member of direct agent
SELECT  ci.custid, ci.currency
FROM Custinfo ci WITH (NOLOCK)
	INNER JOIN #DirectAgent a ON ci.recommend = a.CustID
WHERE ci.roleid = 1 AND ci.custid > @maxcustid AND ci.Enabled = 1 			
-- Direct member		
UNION ALL
SELECT ci.custid, currency
FROM #DirectMember ci
WHERE ci.CustID > @MaxCustID

DECLARE @ProductID TINYINT = 28
CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
SELECT	202, 1501, SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (1,6)

INSERT INTO #DestinationSportBetType
SELECT	202, 15, SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (2)

DECLARE @MaxPT TINYINT--, @MaxComm DECIMAL(9,8), @Currency INT
SELECT TOP 1 @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 1
--SELECT TOP 1 @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 3
	
--------------------------------------PT Setting-------------------------------------------------	
SELECT TOP (1) @fBetType = fBetType, @fSportType = fSportType 
FROM #DestinationSportBetType		
WHERE SettingType = 1

--AGENT LEVEL
INSERT INTO dbo.CustPTSetting3rd_Agent
	(	[CustID]
		,[SportType]
		,[BetType]
		,[IsLive]
		,[SuperPT]
		,[MasterPT]
		,[AgentPT]
		,[IsAutoMasterPT]
		,[AutoMasterPT]
		,[IsAutoSuperPT]
		,[AutoSuperPT]
		,[MinPT]
		,[MaxPT])
SELECT 
	cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
	,cs.spositiontaking  *100
	,cs.mpositiontaking  *100
	,cs.apositiontaking  *100
	,cs.isautompositiontaking
	,cs.autompositiontaking *100
	,cs.isautopositiontaking 
	,cs.autopositiontaking  *100
	,co.minpositiontaking  *100
	,@MaxPT
FROM dbo.custSettingGame cs WITH(NOLOCK) 
	INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	CROSS APPLY #DestinationSportBetType dest
WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType
	AND dest.SettingType = 1
	
--MEMBER LEVEL
INSERT INTO dbo.CustPTSetting3rd_Member
	(	[custid]
		,	[sporttype]
		,	[bettype]
		,	[islive]
		,	[superPT]
		,	[masterPT]
		,	[agentPT]
		,	[IsAutoMasterPT]
		,	[AutoMasterPT]
		,	[IsAutoSuperPT]
		,	[AutoSuperPT])
SELECT 
	cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
	,cs.spositiontaking  *100
	,cs.mpositiontaking  *100
	,cs.apositiontaking  *100
	,cs.isautompositiontaking
	,cs.autompositiontaking *100
	,cs.isautopositiontaking 
	,cs.autopositiontaking  *100
FROM dbo.custSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	CROSS APPLY #DestinationSportBetType dest
WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType
	AND dest.SettingType = 1
	
--------------------------------------Bet Setting-------------------------------------------------		
SELECT TOP (1) @fBetType = fBetType, @fSportType = fSportType 
FROM #DestinationSportBetType		
WHERE SettingType = 2

--Agent Level
INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType			
FROM dbo.CustGameType cs WITH(NOLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	CROSS APPLY #DestinationSportBetType dest
WHERE cs.GameTypeID = @fBetType
	AND dest.SettingType = 2

--Member Level
INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType					
FROM dbo.CustGameType cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	CROSS APPLY #DestinationSportBetType dest
WHERE cs.GameTypeID = @fBetType
	AND dest.SettingType = 2
	
--------------------------------------Win Loss Limit-------------------------------------------------		
--Agent Level
INSERT INTO dbo.CustWinLossLimit_Agent (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tsporttype, dest.tbettype, 0, cs.DefaultLossLimit, 1
FROM #SMATemp ci WITH(NOLOCK) 
	INNER JOIN dbo.LossLimit_GlobalSetting cs WITH(NOLOCK) ON ci.currency = cs.ExchangeId
	CROSS APPLY #DestinationSportBetType dest WITH(NOLOCK) 	
WHERE dest.SettingType = 6 AND cs.ProductId = @ProductID

--Member Level
INSERT INTO dbo.CustWinLossLimit_Member (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tsporttype, dest.tbettype, 0, cs.DefaultLossLimit, 1
FROM #MemberTemp ci WITH(NOLOCK) 
	INNER JOIN dbo.LossLimit_GlobalSetting cs WITH(NOLOCK) ON ci.currency = cs.ExchangeId
	CROSS APPLY #DestinationSportBetType dest WITH(NOLOCK) 
WHERE dest.SettingType = 6 AND cs.ProductId = @ProductID

/*******************************CUST PRODUCTSTATUS TABLE*******************************/	
DECLARE @BitmapOrder TINYINT = 11

UPDATE cs
SET cs.bitmapIsHidden = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitmapOrder,0)),
	bitmapIsDisabled = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitmapOrder,0)) 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON cs.CustID = ci.CustID

UPDATE cs
SET cs.bitmapIsHidden = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitmapOrder,0)),	
	--Should update disabled = 1 for newly member
	cs.bitmapIsDisabled = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitmapOrder,1)) 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.CustID

DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType		

PRINT N'Step 9: End on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.'; 