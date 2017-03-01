DECLARE @maxcustid INT, @exchangeid INT
	
SELECT @maxcustid = xxx

CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
VALUES
(162, 1101, 211	, 2401, 0, 1), --PT
(162, 1101, 211	, 2401, 0, 3), --Comm
(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,srecommend INT,SyncLiveCasino BIT, exchangeid int	
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,srecommend INT,SyncLiveCasino BIT,	exchangeid int,
	roleid TINYINT
)


CREATE TABLE #supers (custid int,exchangeid INT)

INSERT INTO #MemberTemp (CustID,SyncLiveCasino,srecommend,exchangeid)
SELECT custid,SyncLiveCasino,srecommend,currency
FROM Custinfo WITH (NOLOCK)
WHERE custid in (23778555,23714661,23714129,23714176,24499896,24499845,23713930,24499954,23714100,23714123,23714566,24499948,23714077,23714160,23714265,24499635,23714542,23714792,23714092,24499115,24499458,24499083,24499707,24499022,23943934,24499654,23714087,23714138,23714954,23714639,23714937,23714088,23715324,24499121,24499623,24499304,23714871,23714705,24499591,23714809,24499493,23714107)
	
INSERT INTO #SMATemp (CustID, roleid,SyncLiveCasino,srecommend,exchangeid)
SELECT custid, roleid,SyncLiveCasino,srecommend,currency
FROM Custinfo WITH (NOLOCK)
WHERE custid in (3984944,3987484,4076665,116927,329715,332513,354863,357411,363655,363661,370327,371735,378211,385970,390642,23715065,23729783,23733083,23714571,13044498,13053168,23715144,23719280,23714708)

INSERT INTO #supers (custid,exchangeid)
SELECT srecommend,exchangeid
FROM #MemberTemp
UNION 
SELECT srecommend,exchangeid
FROM #SMATemp


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
WHERE ci.roleid = 4 AND dest.SettingType = 6 AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent A WITH (NOLOCK) WHERE A.CustId = CI.custid AND A.SportType = 211)
									
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
WHERE ci.roleid = 3 AND dest.SettingType = 6 AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent A WITH (NOLOCK) WHERE A.CustId = CI.custid AND A.SportType = 211)

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
WHERE ci.roleid = 2 AND dest.SettingType = 6 AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent A WITH (NOLOCK) WHERE A.CustId = CI.custid AND A.SportType = 211)
	
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
WHERE ci.roleid = 1 AND dest.SettingType = 6 AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Member A WITH (NOLOCK) WHERE A.CustId = CI.custid AND A.SportType = 211)
	
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
WHERE NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Agent A WITH (NOLOCK) WHERE A.CustId = CS.custid AND A.SportType = 211)
	
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
WHERE NOT EXISTS (SELECT 1 FROM CustPTSetting3rd_Member A WITH (NOLOCK) WHERE A.CustId = CS.custid AND A.SportType = 211)
	
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
	CASE	WHEN roleid = 4 THEN (CASE WHEN CI.SyncLiveCasino = 1 THEN cs.sdiscount ELSE 0 END)
					WHEN roleid = 3 THEN (CASE WHEN CI.SyncLiveCasino = 1 THEN cs.adiscount ELSE 0 END)
					WHEN roleid = 2 THEN (CASE WHEN CI.SyncLiveCasino = 1 THEN cs.discount ELSE 0 END)
			END
FROM dbo.CustSettingGame cs WITH(NOLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
WHERE NOT EXISTS (SELECT 1 FROM CustDiscount3rd_Agent A WITH (NOLOCK) WHERE A.CustId = CS.custid AND A.SportType = 211)		 
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
WHERE ci.SyncLiveCasino = 1	AND NOT EXISTS (SELECT 1 FROM CustDiscount3rd_Member A WITH (NOLOCK) WHERE A.CustId = CS.custid AND A.SportType = 211)		 

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
WHERE ci.SyncLiveCasino = 0	AND NOT EXISTS (SELECT 1 FROM CustDiscount3rd_Member A WITH (NOLOCK) WHERE A.CustId = CS.custid AND A.SportType = 211)		 
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
DROP TABLE #supers