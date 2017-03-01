/*
	Created: Elodie
	Task: Fix Bug Dummy - WinLossLimit for All Bet from Live Casino
	DB: DBCUST/CustDB
	Date: 20170203
*/ 
USE CustDB
GO

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
WHERE srecommend IN (2,3,4,5,12,13,15) AND roleid = 1  AND Enabled = 1 
	
INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT custid, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (2,3,4,5,12,13,15) AND roleid IN (2,3,4) AND Enabled = 1 

--------------------------------------WinLossLimit-------------------------------------------------
--Master Level: 0 affected row 
UPDATE cs
SET cs.MaxWinLimit =  CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
						WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
						ELSE 0 END
		
	,cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
						WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
						ELSE 1 END 
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp master_tmp WITH (NOLOCK) ON ci.custid = master_tmp.custid 
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid 
	INNER JOIN CustWinLossLimit_Agent cs WITH (ROWLOCK, UPDLOCK) ON cs.CustId = ci.custid
WHERE ci.roleid = 3 AND cs.SportType = 211 AND cs.BetType = 2401
	AND (cs.MaxWinLimit IS NULL OR cs.IsAutoReset IS NULL)

--Agent Level: 5 affected rows 
UPDATE cs
SET cs.MaxWinLimit =  CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
							WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
							ELSE 0 END 
	,cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
							WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
							ELSE 1 END 
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp agent ON ci.custid = agent.CustID
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN CustWinLossLimit_Agent cs WITH (ROWLOCK, UPDLOCK) ON cs.CustId = ci.custid
WHERE ci.srecommend IN (2,3,4,5,12,13,15) AND ci.roleid = 2 
	AND cs.SportType = 211 AND cs.BetType = 2401
	AND (cs.MaxWinLimit IS NULL OR cs.IsAutoReset IS NULL)
	
--Member Level: 4776 affected rows
UPDATE cs
SET cs.MaxWinLimit =  CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
							WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
							WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
							ELSE 0 END 
	,cs.IsAutoReset = CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
							WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
							WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
							WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
							ELSE 1 END
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #MemberTemp member WITH (NOLOCK) ON ci.custid = member.custid
	INNER JOIN #SMATemp ai WITH (NOLOCK) ON ci.recommend = ai.custid
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	INNER JOIN CustWinLossLimit_Member cs WITH (ROWLOCK, UPDLOCK) ON cs.CustId = ci.custid
WHERE ci.srecommend IN (2,3,4,5,12,13,15) AND ci.roleid = 1 
	AND cs.SportType = 211 AND cs.BetType = 2401
	AND (cs.MaxWinLimit IS NULL OR cs.IsAutoReset IS NULL)
	
	
DROP TABLE #SMATemp
DROP TABLE #MemberTemp
