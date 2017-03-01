/*
Created: 20170213@Elodie
Task : Insert WinLossLimit of AllBet for ETUS
DB:  DBCUST/CustDB
*/

USE CustDB
GO

SELECT custid
INTO #super
FROM DBAGE.bodb_age.dbo.Acc_custgroup WITH (NOLOCK)
WHERE groupname = 'accyen789' -- Super list of admin ET789

SELECT ci.custid, ci.recommend
INTO #MemList
FROM custInfo ci WITH (NOLOCK)
	INNER JOIN #super s ON ci.srecommend = s.custid 
WHERE roleid = 1 and Enabled = 1

SELECT c.custid, c.recommend
INTO #MissWinLossMem
FROM #MemList c
WHERE NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Member WHERE custid = c.custid AND SportType = 211)

--32 affected rows
INSERT INTO dbo.CustWinLossLimit_Member (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT c.CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset        
FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
	INNER JOIN #MissWinLossMem c ON cs.CustId = c.recommend
WHERE cs.SportType = 211 