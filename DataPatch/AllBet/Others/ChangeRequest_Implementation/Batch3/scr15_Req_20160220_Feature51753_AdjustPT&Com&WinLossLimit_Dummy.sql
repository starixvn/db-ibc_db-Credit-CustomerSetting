/*
	Created: Helen
	Task: Adjust PT & Comm & WinLossLimit 
	DB: DBCUST/CustDB
	Date: 20160317
*/ 

CREATE TABLE #supers (custid int)
	
INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
	-- Production
	AND ci.custid IN (2,3,4,5,12,13,15)-- dummy account
	)	
	
	
CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
VALUES
(162, 1101, 211	, 2401, 0, 1), --PT
(162, 1101, 211	, 2401, 0, 3), --Comm
(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	SyncLiveCasino BIT,
	MaxWinLiveCasino SMALLMONEY,
	isAutoResetLiveCasino BIT
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	SyncLiveCasino BIT,
	MaxWinLiveCasino SMALLMONEY,
	isAutoResetLiveCasino BIT
)

CREATE TABLE #CustListTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		SyncLiveCasino BIT
	)

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
	and roleid=3 AND srecommend in (2,3,4,5,12,13,15)
		
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE SITE in ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')

	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend in (2,3,4,5,12,13,15)

INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
SELECT custid, recommend,mrecommend,roleid
FROM Customer c WITH(NOLOCK)
WHERE custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
AND recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
AND roleid=1 AND srecommend IN (2,3,4,5,12,13,15) 

----------- For SMA  -----------
INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT ci.custid, ci.roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino -- Direct Master 
FROM custInfo CI (NOLOCK)
WHERE CI.CUSTID IN (2,3,4,5,12,13,15) 

INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT ci.custid, ci.roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino -- Direct Master 
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
UNION 
SELECT DISTINCT ci.custid, ci.roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino -- Master of direct agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
WHERE CI.custid NOT IN (4174,4178,4300,8619,4177,4183) -- under this master having direct agent of 7555555			

UNION 

SELECT ci.custid, ci.roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino -- Agent of direct master
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
WHERE CI.roleid = 2 
			
UNION 
SELECT ci.custid, ci.roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino -- Direct Agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.CustID 

UNION 

SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.MaxWinLiveCasino, ci.isAutoResetLiveCasino -- Master of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.mrecommend 
WHERE  ci.Enabled = 1 AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)

UNION 
SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.MaxWinLiveCasino, ci.isAutoResetLiveCasino -- agent of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.recommend 
WHERE  ci.Enabled = 1 
	
		
---------- For members ---------
INSERT INTO #MemberTemp (CustID, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT ci.custid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
WHERE CI.roleid = 1	

UNION 
SELECT ci.custid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
WHERE CI.roleid = 1 
-- Direct member
UNION 

SELECT ci.custid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember M ON CI.custid = M.CustID


-------------END of Dummny Processing----------------------------

DECLARE @MaxPT TINYINT, @MaxComm DECIMAL(9,8)
SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1
SELECT @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 3
--------------------------------------WinLossLimit-------------------------------------------------
--SuperLevel
UPDATE cs		
SET cs.MaxWinLimit = MaxWinLiveCasino,
	cs.IsAutoReset = isAutoResetLiveCasino
FROM CustWinLossLimit_Agent cs WITH (NOLOCK)
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON cs.SportType = dest.tSportType AND cs.BetType = dest.tBetType AND dest.SettingType = 6 
	INNER JOIN #SMATemp ci WITH (NOLOCK) ON ci.custid = cs.CustId 
WHERE ci.roleid = 4 AND ci.SyncLiveCasino = 1
	AND (cs.MaxWinLimit <> ci.MaxWinLiveCasino OR cs.IsAutoReset <> ci.isAutoResetLiveCasino)
								
--Master Level
UPDATE cs		
SET cs.MaxWinLimit = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
							WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END,
	cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
							WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END
FROM CustWinLossLimit_Agent cs WITH (NOLOCK)
	INNER JOIN #SMATemp master WITH (NOLOCK) ON master.CustID = cs.CustId 
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustId 
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.CustId 
WHERE ci.roleid = 3
	AND (cs.MaxWinLimit <> CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
								WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END 
		OR cs.IsAutoReset <> CASE	WHEN ci.SyncLiveCasino = 1 THEN ci.isAutoResetLiveCasino
									WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END)

--Agent Level
UPDATE cs		
SET cs.MaxWinLimit = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
							WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END,
	cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
							WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END
FROM CustWinLossLimit_Agent cs WITH (NOLOCK)
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON cs.SportType = dest.tSportType AND cs.BetType = dest.tBetType AND dest.SettingType = 6 
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustId 
	INNER JOIN #SMATemp agent WITH (NOLOCK) ON cs.CustId = agent.CustId 
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.CustId 
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid
WHERE ci.roleid = 2
	AND (cs.MaxWinLimit <> CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
								WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
								WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END
		OR cs.IsAutoReset <> CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
									WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
									WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END)
										
--Member Level
UPDATE cs		
SET cs.MaxWinLimit = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
							WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
							WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END,
	cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
							WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
							WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END
FROM dbo.CustWinLossLimit_Member cs WITH (NOLOCK)
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON cs.SportType = dest.tSportType AND cs.BetType = dest.tBetType AND dest.SettingType = 6 
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustId 
	INNER JOIN #MemberTemp member WITH (NOLOCK) ON ci.custid = member.custid
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.CustId 
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid
	INNER JOIN #SMATemp ai WITH (NOLOCK) ON ci.recommend = ai.custid
WHERE ci.roleid = 1
	AND (cs.MaxWinLimit <> CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
								WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
								WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
								WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino END
		OR cs.IsAutoReset <> CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
									WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
									WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
									WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino END)	

--------------------------------------PT Setting-------------------------------------------------	
--Update PT for different settings (not adjust for line super who take pt LCS more than 93%)
--AGENT LEVEL
UPDATE cs1
SET cs1.SuperPT = cs2.spositiontaking * 100,
	cs1.MasterPT = cs2.mpositiontaking * 100,
	cs1.AgentPT = cs2.apositiontaking * 100,
	cs1.IsAutoMasterPT = cs2.isautompositiontaking,
	cs1.AutoMasterPT = cs2.autompositiontaking * 100,
	cs1.IsAutoSuperPT = cs2.isautopositiontaking,
	cs1.AutoSuperPT = cs2.autopositiontaking * 100,
	cs1.MinPT = co.minpositiontaking * 100
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Agent cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs1.CustID = co.CustID AND co.Sporttype = cs2.Sporttype AND co.Bettype = cs2.Bettype
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid IN (2,3,4) AND ci.Enabled = 1
	AND ci.srecommend IN (SELECT s.custid 
						FROM #supers s 
							INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
						WHERE spositiontaking <= @MaxPT
						) 
	AND (cs1.SuperPT <> (cs2.spositiontaking * 100) OR
			
			(ci.roleid <> 4 AND cs1.MasterPT <> (cs2.mpositiontaking * 100)) OR -- not adjust m4,a4
			
			(ci.roleid <> 4 AND cs1.AgentPT  <> (cs2.apositiontaking  * 100)) OR --  not adjust m4,a4
			
			cs1.IsAutoMasterPT <> cs2.isautompositiontaking OR
			cs1.AutoMasterPT <> (cs2.autompositiontaking * 100) OR
			cs1.IsAutoSuperPT <> cs2.isautopositiontaking OR
			cs1.AutoSuperPT <> (cs2.autopositiontaking * 100) OR
			cs1.MinPT <> co.minpositiontaking * 100)

--MEMBER LEVEL
UPDATE cs1
SET cs1.SuperPT = cs2.spositiontaking * 100,
	cs1.MasterPT = cs2.mpositiontaking * 100,
	cs1.AgentPT = cs2.apositiontaking * 100,
	cs1.IsAutoMasterPT = cs2.isautompositiontaking,
	cs1.AutoMasterPT = cs2.autompositiontaking * 100,
	cs1.IsAutoSuperPT = cs2.isautopositiontaking,
	cs1.AutoSuperPT = cs2.autopositiontaking * 100
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Member cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 1 AND ci.Enabled = 1
	AND ci.srecommend IN (SELECT s.custid 
						FROM #supers s 
							INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
						WHERE spositiontaking <= @MaxPT
						) 
	AND (cs1.SuperPT <> (cs2.spositiontaking * 100) OR
			cs1.MasterPT <> (cs2.mpositiontaking * 100) OR
			cs1.AgentPT <> (cs2.apositiontaking * 100) OR
			cs1.IsAutoMasterPT <> cs2.isautompositiontaking OR
			cs1.AutoMasterPT <> (cs2.autompositiontaking * 100) OR
			cs1.IsAutoSuperPT <> cs2.isautopositiontaking OR
			cs1.AutoSuperPT <> (cs2.autopositiontaking * 100))

--------------------------------------Commission Setting-------------------------------------------------		
--Update Comm for different settings (not adjust for line super who take comm LCS more than 0.0007)
--Super Level
UPDATE cs1
SET cs1.Discount = cs2.sdiscount
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustDiscount3rd_Agent cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 4 AND ci.Enabled = 1
	AND ci.custid IN (	SELECT s.custid 
							FROM #supers s 
								INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
							WHERE cs.sdiscount <= @MaxComm) 
	AND cs1.Discount <> cs2.sdiscount
	AND CI.SyncLiveCasino = 1

--Master Level
UPDATE cs1
SET cs1.Discount = cs2.adiscount
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustDiscount3rd_Agent cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 3 AND ci.Enabled = 1
	AND ci.srecommend IN (	SELECT s.custid 
							FROM #supers s 
								INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
							WHERE cs.sdiscount <= @MaxComm
							) 
	AND cs1.Discount <> cs2.adiscount
	AND CI.SyncLiveCasino = 1
--Agent Level
UPDATE cs1
SET cs1.Discount = cs2.discount
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustDiscount3rd_Agent cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 2 AND ci.Enabled = 1
	AND ci.srecommend IN (	SELECT s.custid 
							FROM #supers s 
								INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
							WHERE cs.sdiscount <= @MaxComm
							) 
	AND cs1.Discount <> cs2.discount
	AND CI.SyncLiveCasino = 1
	
--Member Level
UPDATE cs1
SET cs1.SuperDiscount = cs2.sdiscount,
	cs1.MasterDiscount = cs2.adiscount,
	cs1.AgentDiscount = cs2.discount,
	cs1.PlayerDiscount = cs2.playerdiscount
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustDiscount3rd_Member cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 1 AND ci.Enabled = 1
	AND ci.srecommend IN (	SELECT s.custid 
							FROM #supers s 
								INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
							WHERE cs.sdiscount <= @MaxComm
							) 
	AND (cs1.SuperDiscount <> cs2.sdiscount OR
			cs1.MasterDiscount <> cs2.adiscount OR
			cs1.AgentDiscount <> cs2.discount OR
			cs1.PlayerDiscount <> cs2.playerdiscount)
	AND CI.SyncLiveCasino = 1		
			

UPDATE cs1
	SET SuperDiscount = super.Discount ,
		MasterDiscount = master.Discount ,
		AgentDiscount =  Agent.Discount ,
		PlayerDiscount = 0 
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustDiscount3rd_Member cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID 
	INNER JOIN CustDiscount3rd_Agent super WITH (NOLOCK) ON super.CustID = CI.srecommend AND CS1.SportType = SUPER.SportType AND cs1.BetType=SUPER.BetType
	INNER JOIN CustDiscount3rd_Agent master WITH (NOLOCK) ON master.CustID = CI.mrecommend AND CS1.SportType = master.SportType AND cs1.BetType=master.BetType
	INNER JOIN CustDiscount3rd_Agent agent WITH (NOLOCK) ON agent.CustID = CI.recommend AND CS1.SportType = agent.SportType AND cs1.BetType=agent.BetType
	
WHERE ci.roleid = 1 AND ci.Enabled = 1
	AND ci.srecommend IN (	SELECT s.custid 
							FROM #supers s 
								INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
							WHERE cs.sdiscount <= @MaxComm
							) 
	AND (cs1.SuperDiscount <> super.Discount OR
			cs1.MasterDiscount <> master.Discount OR
			cs1.AgentDiscount <> Agent.Discount OR
			cs1.PlayerDiscount <> 0)
	AND cs1.SportType = 211 AND cs1.BetType = 2401
	AND CI.SyncLiveCasino = 0
	

UPDATE cs1
	SET SuperDiscount = super.Discount ,
		MasterDiscount = master.Discount ,
		AgentDiscount =  Agent.Discount 
		
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN #supers S WITH (NOLOCK) ON ci.srecommend = s.custid
	INNER JOIN dbo.CustDiscount3rd_Member cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustDiscount3rd_Agent super WITH (NOLOCK) ON super.CustID = CI.srecommend AND CS1.SportType = SUPER.SportType AND cs1.BetType=SUPER.BetType
	INNER JOIN CustDiscount3rd_Agent master WITH (NOLOCK) ON master.CustID = CI.mrecommend AND CS1.SportType = master.SportType AND cs1.BetType=master.BetType
	INNER JOIN CustDiscount3rd_Agent agent WITH (NOLOCK) ON agent.CustID = CI.recommend AND CS1.SportType = agent.SportType AND cs1.BetType=agent.BetType
WHERE ci.roleid = 1 AND ci.Enabled = 1
	AND (cs1.SuperDiscount <> super.Discount OR
			cs1.MasterDiscount <> master.Discount OR
			cs1.AgentDiscount <> Agent.Discount 
			)
	AND CS1.SportType = 211 AND CS1.BetType = 2401
	AND CI.SyncLiveCasino = 1
		
DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType	