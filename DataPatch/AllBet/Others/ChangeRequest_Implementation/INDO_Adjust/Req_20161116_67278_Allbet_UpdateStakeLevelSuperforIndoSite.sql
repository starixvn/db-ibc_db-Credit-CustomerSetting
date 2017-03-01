/*
	Created: Helen
	Date: 20161116
	Task: INDO - All supers have stakelevel 250 - 25,000 unchecked
	Redmine: https://nexdev.net/issues/67278
	
	DB: DBCUST/CustDB
	
*/  
USE CustDB
GO

CREATE TABLE #SuperAndDirectMasterAgent (custID INT PRIMARY KEY, ExchangeID INT)
CREATE TABLE #currency_tmp (ExchangeID INT)
CREATE TABLE #currency_StakelevelList (ExchangeID INT, StakeLevelList VARCHAR(100))

-- list of super, direct master/agent need to be updated
INSERT INTO #SuperAndDirectMasterAgent (custID,ExchangeID)
SELECT ci.custid,ci.currency AS ExchangeID
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site = 'INDO' --in ('INDO','755555','Koribc')
		AND ci.srecommend <> 72
		and ci.currency <> 20
		) OR custid in (1038826,58969, 60809, 118211,15,4183) -- direct Master/agent
-- get currencies
INSERT INTO #currency_tmp (ExchangeID)
SELECT DISTINCT ExchangeID 
FROM #SuperAndDirectMasterAgent

-- get stakelevelist of each currency
INSERT INTO #currency_StakelevelList (ExchangeID,StakeLevelList)
SELECT s.exchangeID, STUFF(tmp.StakeLevelList,1,1,'')  AS StakeLevelList
FROM #currency_tmp s
	CROSS APPLY (SELECT TOP 100 ',' + CONVERT(VARCHAR(10),t.StakeLevelID)
					 FROM StakeLevel T (NOLOCK)
					 WHERE T.ExchangeId = s.exchangeID AND T.GameTypeID = 2401
					 ORDER BY T.MaxStake, T.MinStake
					 FOR XML PATH ('')
					 ) tmp (StakeLevelList)
				 		
-------------------- update stakelevel: Offer ALL STAKELEVEL FOR SUPER AND DIRECT MASTER/AGENT ----------------------------
UPDATE 	T
	SET StakeLevelList = SLL.stakelevelList
FROM CustStakeLevel_Agent T (ROWLOCK)
	INNER JOIN #SuperAndDirectMasterAgent S ON T.CustID = S.custID
	INNER JOIN #currency_StakelevelList SLL ON SLL.exchangeID = S.ExchangeID
WHERE T.SportType = 211 AND T.BetType = 2401

DROP TABLE #SuperAndDirectMasterAgent
DROP TABLE #currency_StakelevelList
DROP TABLE #currency_tmp