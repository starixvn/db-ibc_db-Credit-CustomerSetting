/*
	Created: Elodie
	Task: Adjust PT & Comm & WinLossLimit 
	DB: DBCUST/CustDB
	Date: 20160317
*/ 

CREATE TABLE #supers (custid int)
	
INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	-- UAT 
	AND ci.currency = 20

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
	
INSERT INTO #MemberTemp (CustID, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT custid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid = 1  AND Enabled = 1
	
	
INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT custid, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid IN (2,3,4) AND Enabled = 1

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
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON cs.SportType = dest.tSportType AND cs.BetType = dest.tBetType AND dest.SettingType = 6 
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
						WHERE spositiontaking <= @MaxPT) 
	AND (cs1.SuperPT <> (cs2.spositiontaking * 100) OR
			cs1.MasterPT <> (cs2.mpositiontaking * 100) OR
			cs1.AgentPT <> (cs2.apositiontaking * 100) OR
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
	INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs1.CustID = co.CustID AND co.Sporttype = cs2.Sporttype AND co.Bettype = cs2.Bettype
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs2.bettype = dest.fBetType AND cs2.sporttype = dest.fSportType AND cs1.SportType = dest.tSportType AND cs1.BetType = dest.tBetType
WHERE ci.roleid = 1 AND ci.Enabled = 1
	AND ci.srecommend IN (SELECT s.custid 
						FROM #supers s 
							INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
						WHERE spositiontaking <= @MaxPT) 
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
							WHERE cs.sdiscount <= @MaxComm) 
	AND cs1.Discount <> cs2.adiscount
	
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
							WHERE cs.sdiscount <= @MaxComm) 
	AND cs1.Discount <> cs2.discount
							 
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
							WHERE cs.sdiscount <= @MaxComm) 
	AND (cs1.SuperDiscount <> cs2.sdiscount OR
			cs1.MasterDiscount <> cs2.adiscount OR
			cs1.AgentDiscount <> cs2.discount OR
			cs1.PlayerDiscount <> cs2.playerdiscount)

DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType	