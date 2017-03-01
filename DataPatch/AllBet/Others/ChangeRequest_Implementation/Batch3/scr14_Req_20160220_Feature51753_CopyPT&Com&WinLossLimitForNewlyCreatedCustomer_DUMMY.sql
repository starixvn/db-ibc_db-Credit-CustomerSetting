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
WHERE ci.custid IN (2,3,4,5,12,13,15)

CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
VALUES
(162, 1101, 211	, 2401, 0, 1), --PT
(162, 1101, 211	, 2401, 0, 3), --Comm
(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED
	,SyncLiveCasino BIT	
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,	
	roleid TINYINT
)
------------STARTING Dummy Processing
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT)			
--- get direct master
INSERT INTO #DirectMaster (CustID,roleid)
SELECT custid, roleid
FROM Customer with(nolock)
WHERE SITE in ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')

	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=3 AND srecommend IN (2,3,4,5,12,13,15)

--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE site in ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')

	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend IN (2,3,4,5,12,13,15)

INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
SELECT custid, recommend,mrecommend,roleid
FROM Customer c WITH(NOLOCK)
WHERE custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	AND recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	AND roleid=1 AND srecommend IN (2,3,4,5,12,13,15) 
		
			
----------- For SMA  -----------
INSERT INTO #SMATemp (CustID,roleid)
-- NO NEED TO ADD SUPER, it's added already
SELECT custid, 4
FROM #supers
UNION 
SELECT CI.CustID,CI.roleid -- Direct Master 
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
WHERE ci.custid > @maxcustid 

UNION 

SELECT DISTINCT CI.CustID,CI.roleid -- Master of direct agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
WHERE ci.custid > @maxcustid AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)
	
UNION 

SELECT CI.CustID,CI.roleid -- Agent of direct master
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
WHERE CI.roleid = 2
	AND ci.custid > @maxcustid 
UNION 
SELECT CI.CustID,CI.roleid -- Direct Agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.CustID 
WHERE ci.custid > @maxcustid 

UNION 

SELECT DISTINCT CI.CustID,CI.roleid -- Master of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.mrecommend 
WHERE  ci.Enabled = 1 AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183) AND ci.custid > @maxcustid 

UNION 
SELECT DISTINCT CI.CustID,CI.roleid -- agent of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.recommend 
WHERE  ci.Enabled = 1 AND ci.custid > @maxcustid 
	
---------- For members ---------
INSERT INTO #MemberTemp (CustID,SyncLiveCasino)
SELECT CI.custid,ci.SyncLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
WHERE CI.roleid = 1	AND ci.custid > @maxcustid 
	
UNION 
SELECT CI.custid, ci.SyncLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
WHERE CI.roleid = 1 AND ci.custid > @maxcustid 

UNION 
SELECT CI.custid, ci.SyncLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember M ON CI.custid = M.CustID
WHERE ci.custid > @maxcustid
-------------END of Dummny Processing----------------------------

DECLARE @MaxPT TINYINT, @MaxComm DECIMAL(9,8)
SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1
SELECT @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 3
--------------------------------------WinLossLimit-------------------------------------------------
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
	AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent A WITH (NOLOCK) WHERE A.CustId =CI.custid AND a.SportType = 211 )

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
	AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent A WITH (NOLOCK) WHERE A.CustId =CI.custid AND a.SportType = 211 )
	
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
	INNER JOIN #MemberTemp tmpci WITH (NOLOCK) ON ci.custid = tmpci.custid
	INNER JOIN custInfo ai WITH (NOLOCK) ON ci.recommend = ai.custid
	INNER JOIN custInfo mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN custInfo si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN #supers S ON CI.srecommend = S.custid
	INNER JOIN LossLimit_GlobalSetting gbs WITH (NOLOCK) ON gbs.ProductId = 21 AND gbs.ExchangeId = s.exchangeid
	CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
WHERE ci.roleid = 1 AND dest.SettingType = 6 
	AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Member A WITH (NOLOCK) WHERE A.CustId =CI.custid AND a.SportType = 211 )
	
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
WHERE 	NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId =cs.custid AND a.SportType = 211 )
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
WHERE NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId =cs.custid AND a.SportType = 211 )
	
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

--Update m4 = s4, a4 = s4 
UPDATE CustPTSetting3rd_Agent
	SET  [MasterPT] = [SuperPT],
		[AgentPT] = [SuperPT]
WHERE SportType = 211 AND BetType = 2401
	AND Custid IN (SELECT CustID FROM #SMATemp WHERE roleid = 4)

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
WHERE NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId =cs.custid AND a.SportType = 211 )		 
--Member Level
INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
SELECT cs.custid, dest.tsporttype, dest.tbettype
	, cs.PlayerDiscount 
	, cs.discount
	, cs.adiscount 
	, cs.sdiscount
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
WHERE ci.SyncLiveCasino = 1	AND NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId =cs.custid AND a.SportType = 211 )		 	

INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
SELECT cs.custid, dest.tsporttype, dest.tbettype
	, 0 AS PlayerDiscount
	, Agent.Discount
	, master.Discount
	, super.Discount 
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
	INNER JOIN custInfo member WITH (NOLOCK) ON member.CustID = cs.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	INNER JOIN CustDiscount3rd_Agent super WITH (NOLOCK) ON super.CustID = member.srecommend AND SUPER.SportType = dest.tSportType AND super.BetType = dest.tBetType
	INNER JOIN CustDiscount3rd_Agent master WITH (NOLOCK) ON master.CustID = member.mrecommend AND master.SportType = dest.tSportType AND master.BetType = dest.tBetType
	INNER JOIN CustDiscount3rd_Agent agent WITH (NOLOCK) ON agent.CustID = member.recommend AND agent.SportType = dest.tSportType AND agent.BetType = dest.tBetType
WHERE ci.SyncLiveCasino = 0	AND NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId =cs.custid AND a.SportType = 211 )		 	

--adjust commission Super 
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
DROP TABLE #supers