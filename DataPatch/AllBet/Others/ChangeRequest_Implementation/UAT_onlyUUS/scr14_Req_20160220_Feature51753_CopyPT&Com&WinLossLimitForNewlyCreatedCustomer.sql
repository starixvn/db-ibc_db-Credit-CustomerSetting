/*
	Created: Helen
	Task: Copy PT & Comm & WinLossLimit for newly created customer
	DB: DBCUST/CustDB
	Date: 20150626
*/ 

DECLARE @maxcustid INT, @exchangeid INT
	
SELECT @maxcustid = xxx
	
CREATE TABLE #supers (custid int,exchangeid INT)
	
INSERT INTO #supers(custid,exchangeid)
SELECT ci.custid,ci.currency
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	-- UAT 
	AND ci.currency = 20
	-- Production

CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
VALUES
(162, 1101, 211	, 2401, 0, 1), --PT
(162, 1101, 211	, 2401, 0, 3), --Comm
(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,	
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,	
	roleid TINYINT
)
	
INSERT INTO #MemberTemp (CustID)
SELECT custid
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid = 1  AND Enabled = 1 AND custid > @maxcustid
	
	
INSERT INTO #SMATemp (CustID, roleid)
SELECT custid, roleid
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid IN (2,3,4) AND Enabled = 1 AND custid > @maxcustid 

DECLARE @MaxPT TINYINT, @MaxComm DECIMAL(9,8)
SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1
SELECT @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 3


--------------------------------------WinLossLimit-------------------------------------------------
--SuperLevel
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE WHEN ci.SyncLiveCasino = 0 THEN 0 ELSE MaxWinLiveCasino END AS MaxWinLimit
	,ISNULL(gbs.DefaultLossLimit,0) AS MaxLossLimit 
	,CASE WHEN ci.SyncLiveCasino = 0 THEN 1 ELSE isAutoResetLiveCasino END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp tmpci WITH (NOLOCK) ON ci.custid = tmpci.custid
	INNER JOIN #supers S ON CI.srecommend = S.custid
	INNER JOIN LossLimit_GlobalSetting gbs WITH (NOLOCK) ON gbs.ProductId = 21 AND gbs.ExchangeId = s.exchangeid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 4 AND dest.SettingType = 6 
									
--Master Level
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,ISNULL(gbs.DefaultLossLimit,0) AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)	
	INNER JOIN #SMATemp tmpci WITH (NOLOCK) ON ci.custid = tmpci.custid
	INNER JOIN custInfo si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN #supers S ON CI.srecommend = S.custid
	INNER JOIN LossLimit_GlobalSetting gbs WITH (NOLOCK) ON gbs.ProductId = 21 AND gbs.ExchangeId = s.exchangeid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 3 AND dest.SettingType = 6 

--Agent Level
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,ISNULL(gbs.DefaultLossLimit,0) AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp tmpci WITH (NOLOCK) ON ci.custid = tmpci.custid
	INNER JOIN custInfo mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN custInfo si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN #supers S ON CI.srecommend = S.custid
	INNER JOIN LossLimit_GlobalSetting gbs WITH (NOLOCK) ON gbs.ProductId = 21 AND gbs.ExchangeId = s.exchangeid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 2 AND dest.SettingType = 6
	
--Member Level
INSERT INTO CustWinLossLimit_Member(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, dest.tSportType, dest.tBetType	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
			WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,ISNULL(gbs.DefaultLossLimit,0) AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
			WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp tmpci WITH (NOLOCK) ON ci.custid = tmpci.custid
	INNER JOIN custInfo ai WITH (NOLOCK) ON ci.recommend = ai.custid
	INNER JOIN custInfo mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN custInfo si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN #supers S ON CI.srecommend = S.custid
	INNER JOIN LossLimit_GlobalSetting gbs WITH (NOLOCK) ON gbs.ProductId = 21 AND gbs.ExchangeId = s.exchangeid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 1 AND dest.SettingType = 6 
	
--------------------------------------PT Setting-------------------------------------------------	
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
	,93
FROM dbo.CustSettingGame cs WITH(NOLOCK) 
	INNER JOIN dbo.custOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
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
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
DECLARE @apos SMALLMONEY,
		@mpos SMALLMONEY
	
UPDATE cs
SET cs.MinPT = @MaxPT
FROM dbo.CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE MinPT > @MaxPT		
	
UPDATE cs
SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	cs.AgentPT = @apos,
	@mpos = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END,
	cs.MasterPT = @mpos,
	cs.SuperPT = CASE WHEN @apos + @mpos + cs.SuperPT > @MaxPT THEN @MaxPT - @mpos -@apos ELSE cs.SuperPT END
FROM  CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > @MaxPT
		
UPDATE cs
SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	cs.AgentPT = @apos,
	cs.MasterPT = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.MasterPT + cs.AgentPT > @MaxPT	AND roleid = 2
	
UPDATE cs
SET @mpos = CASE WHEN cs.MasterPT > @MaxPT THEN @MaxPT ELSE cs.MasterPT END,
	cs.MasterPT = @mpos,
	cs.SuperPT = CASE WHEN cs.SuperPT + @mpos > @MaxPT THEN @MaxPT - @mpos ELSE cs.SuperPT END 		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.MasterPT + cs.SuperPT > @MaxPT	AND roleid = 3
		
UPDATE cs
SET cs.SuperPT = CASE WHEN cs.SuperPT > @MaxPT THEN @MaxPT ELSE cs.SuperPT END 		
FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #supers ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.SuperPT > @MaxPT	

--------------------------------------Commission Setting-------------------------------------------------		
--Agent Level
INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
SELECT cs.custid, dest.tsporttype, dest.tbettype, 
		CASE	WHEN roleid = 4 THEN cs.sdiscount
				WHEN roleid = 3 THEN cs.adiscount
				WHEN roleid = 2 THEN cs.discount END
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
		 
--Member Level
INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
SELECT cs.custid, dest.tsporttype, dest.tbettype, cs.PlayerDiscount, cs.discount, cs.adiscount, cs.sdiscount
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType

--adjust commission Super = [0; 0.007]	
--correct for super level

UPDATE cs
SET cs.Discount = @MaxComm
FROM  CustDiscount3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
WHERE cs.Discount > @MaxComm
		
UPDATE cs
SET cs.SuperDiscount = CASE WHEN cs.SuperDiscount > @MaxComm THEN @MaxComm ELSE cs.SuperDiscount END,
	cs.MasterDiscount = CASE WHEN cs.MasterDiscount > cs.SuperDiscount THEN cs.SuperDiscount ELSE cs.MasterDiscount END,
	cs.AgentDiscount = CASE WHEN cs.AgentDiscount > cs.MasterDiscount THEN cs.MasterDiscount ELSE cs.AgentDiscount END,
	cs.PlayerDiscount = CASE WHEN cs.PlayerDiscount > cs.AgentDiscount THEN cs.AgentDiscount ELSE cs.PlayerDiscount END
FROM dbo.CustDiscount3rd_Member cs WITH(UPDLOCK, ROWLOCK)
	INNER JOIN #MemberTemp ci ON cs.CustID = ci.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType		
WHERE cs.SuperDiscount > @MaxComm 
	OR cs.MasterDiscount > cs.SuperDiscount 
	OR cs.AgentDiscount > cs.MasterDiscount 
	OR cs.PlayerDiscount > cs.AgentDiscount
		  
DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType	