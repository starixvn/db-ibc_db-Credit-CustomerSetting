/*
	Created: Helen
	Task: fix Win/Loss Limit for direct agent of 3rd batch - [Redmine:68644]
	DB: DBCUST/CustDB
	Date: 20170119
*/ 
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

INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT custid, roleid, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino
FROM Custinfo WITH (NOLOCK)
WHERE custid IN (1265 -- wstb: roleid = 2
				,4177 -- roleid = 3
				,4 -- roleid = 4
				) 

	
INSERT INTO #MemberTemp (CustID, SyncLiveCasino, MaxWinLiveCasino, isAutoResetLiveCasino)
SELECT CI.custid, CI.SyncLiveCasino, CI.MaxWinLiveCasino, CI.isAutoResetLiveCasino
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #SMATemp T ON CI.recommend = t.CustID AND T.roleid = 2
WHERE CI.roleid = 1  AND Enabled = 1 AND CI.currency <> 20
		
--Agent Level
INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, 211, 2401	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,DefaultLossLimit AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #SMATemp agent ON ci.custid = agent.CustID
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	CROSS APPLY (SELECT ISNULL(DefaultLossLimit,0) AS DefaultLossLimit	FROM LossLimit_GlobalSetting GS WITH (NOLOCK) 
				WHERE GS.ProductId = 21 AND GS.ExchangeId = CI.currency) AS tmp
WHERE ci.roleid = 2 
	AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Agent CWL WITH (NOLOCK) WHERE CWL.CustId = CI.custid AND CWL.SportType = 211)

--Member Level
INSERT INTO CustWinLossLimit_Member(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT ci.custid, 211, 2401	
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
			WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
			ELSE 0 END AS MaxWinLimit
	,DefaultLossLimit AS MaxLossLimit 
	,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
			WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
			WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
			WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
			ELSE 1 END AS IsAutoReset
FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN #MemberTemp member WITH (NOLOCK) ON ci.custid = member.custid
	INNER JOIN #SMATemp ai WITH (NOLOCK) ON ci.recommend = ai.custid
	INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
	INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
	CROSS APPLY (SELECT ISNULL(DefaultLossLimit,0) AS DefaultLossLimit	FROM LossLimit_GlobalSetting GS WITH (NOLOCK) 
				WHERE GS.ProductId = 21 AND GS.ExchangeId = CI.currency) AS tmp
				
WHERE ci.roleid = 1 AND NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Member CWL WITH (NOLOCK) WHERE CWL.CustId = CI.custid AND CWL.SportType = 211)