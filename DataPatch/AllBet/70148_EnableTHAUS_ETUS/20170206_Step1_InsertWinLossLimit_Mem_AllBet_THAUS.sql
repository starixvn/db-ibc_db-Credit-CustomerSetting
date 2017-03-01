/*
Created: 20170206@Elodie
Task : Insert WinLossLimit of AllBet
DB:  DBCUST/CustDB
*/

USE CustDB
GO

--SELECT * from custAccount with (Nolock)
--where custid = 11746260 -- THAUS

SELECT ca.custid 
INTO #super
FROM custAccount ca with (Nolock)
	INNER JOIN custInfo ci with (Nolock) on ci.custid = ca.custid
WHERE groupID = 515 AND roleid = 4

SELECT ci.custid, ci.recommend
INTO #MemList
FROM custInfo ci WITH (NOLOCK)
	INNER JOIN #super s ON ci.srecommend = s.custid 
WHERE roleid = 1 and Enabled = 1

SELECT c.custid, c.recommend
INTO #MissWinLossMem
FROM #MemList c
WHERE NOT EXISTS (SELECT 1 FROM CustWinLossLimit_Member WHERE custid = c.custid AND SportType = 211)

INSERT INTO dbo.CustWinLossLimit_Member (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
SELECT c.CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset        
FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
	INNER JOIN #MissWinLossMem c ON cs.CustId = c.recommend
WHERE cs.SportType = 211 