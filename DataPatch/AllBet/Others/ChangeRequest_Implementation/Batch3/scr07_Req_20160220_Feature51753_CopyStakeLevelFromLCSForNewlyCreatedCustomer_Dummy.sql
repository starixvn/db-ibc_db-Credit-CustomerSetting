/*
	Created: Helen
	Date: 20160829
	Task: copy stake level for newly created customers
	DB: DBCUST/CustDB
*/
--step 0: backup & copy stake level setting from LCS DB to DBTP for newly customers

DECLARE @StakeLevelList_2401_Lowest VARCHAR(100)= ''
		,@StakeLevelList_2402 VARCHAR(100)= ''
		
		,@currency INT
		,@custid INT
		,@uplineID INT
		,@roleid INT
		,@syncLiveCasino BIT
		,@max_custid INT
		,@max_custid2 INT
		,@srecommend INT
		
SELECT @max_custid = xxx
		
--step 1: copy settings for newly created customers

---- data preparation ----
CREATE TABLE #tmpCustGameType (
	[CustID] [int] NOT NULL PRIMARY KEY,
	[roleID] [int] ,
	[DirectUplineID] [int],
	[ExchangeID] [int] NOT NULL, 
	[StakeLevelList_LC] [varchar](100) NULL,
	[StakeLevelList_AllBet] [varchar](100) NULL
 )

------------- Dummy processing ----------------
CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	SyncLiveCasino BIT,
	currency INT
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	SyncLiveCasino BIT,
	currency INT
)
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT)	
--- get direct master
INSERT INTO #DirectMaster (CustID,roleid)
SELECT custid, roleid
FROM Customer with(nolock)
WHERE site IN ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=3 AND srecommend IN  (2,3,4,5,12,13,15)
	
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE site IN ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend IN  (2,3,4,5,12,13,15)

INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
SELECT custid, recommend,mrecommend,roleid
FROM Customer c WITH(NOLOCK)
WHERE custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	AND recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	AND roleid=1 AND srecommend IN (2,3,4,5,12,13,15) 
		
----------- For SMA  -----------
INSERT INTO #SMATemp (CustID,roleid,SyncLiveCasino,currency)
-- NO NEED TO ADD SUPER, it's added already
SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- Direct Master 
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
WHERE ci.custid > @max_custid 

UNION 
SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- Master of direct agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
WHERE ci.custid > @max_custid AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)
	
UNION 

SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- Agent of direct master
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
WHERE CI.roleid = 2
	AND ci.custid > @max_custid 
UNION ALL
SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- Direct Agent
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent D ON CI.custid = D.CustID 
WHERE ci.custid > @max_custid 

UNION 

SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- Master of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.mrecommend 
WHERE  ci.Enabled = 1 AND ci.custid > @max_custid 	AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)

UNION 
SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino,ci.currency -- agent of direct member
FROM custInfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember D ON CI.custid = D.recommend 
WHERE  ci.Enabled = 1 AND ci.custid > @max_custid 	
	
---------- For members ---------
INSERT INTO #MemberTemp (CustID, SyncLiveCasino,currency)
SELECT CI.custid, ci.SyncLiveCasino,ci.currency
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
WHERE CI.roleid = 1	AND ci.custid > @max_custid 
	
UNION 
SELECT CI.custid, ci.SyncLiveCasino,ci.currency
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
WHERE CI.roleid = 1 AND ci.custid > @max_custid 

UNION 
SELECT CI.custid, ci.SyncLiveCasino,ci.currency
FROM Custinfo CI WITH (NOLOCK)
	INNER JOIN #DirectMember M ON CI.custid = M.CustID
WHERE ci.custid > @max_custid 


-------------end of Dummy processing ----------------			
--- get list of new customers
CREATE TABLE #tmpCust (custid INT, roleid INT, syncLiveCasino BIT, currency INT)

INSERT INTO #tmpCust(custid, roleid, syncLiveCasino, currency)
SELECT custid, roleid, syncLiveCasino, currency
FROM #SMATemp
UNION ALL 
SELECT custid, 1, syncLiveCasino, currency
FROM #MemberTemp


INSERT INTO #tmpCustGameType ([CustID], [StakeLevelList_LC],[ExchangeID],roleID)
SELECT ci.custid, ISNULL (cs.StakeLevelList,'') AS StakeLevelList,ci.currency,CI.roleid	
FROM #tmpCust ci WITH(NOLOCK)
	LEFT JOIN DBBINGOADMIN.LiveCasinoAdmin.dbo.CustGameType cs WITH (NOLOCK) ON cs.custid = ci.custid AND cs.custid > @max_custid AND CS.GameTypeID = 108
	
	
CREATE TABLE #StakeLevel_PreMapping (ID INT IDENTITY (1,1),ExchangeID INT, StakeLevelList_LC VARCHAR(1000),StakeLevelList_Allbet VARCHAR (1000))

INSERT INTO #StakeLevel_PreMapping (StakeLevelList_LC,ExchangeID)
SELECT DISTINCT StakeLevelList_LC,ExchangeID
FROM #tmpCustGameType WITH (NOLOCK)

DECLARE @Index_Start INT  = 0, @ExchangeID INT
DECLARE @Index_Stop INT = (SELECT MAX(ID) FROM #StakeLevel_PreMapping)

DECLARE @v_str NVARCHAR(1000)

WHILE @Index_Start <= @Index_Stop
BEGIN 
	SELECT @v_str = StakeLevelList_LC,@ExchangeID = ExchangeID  FROM #StakeLevel_PreMapping WHERE ID =  @Index_Start 
	IF @v_str <> ''
	BEGIN
		SELECT @v_str = REPLACE(@v_str,StakeLevelID_LC, StakeLevelID_AllBet)
		FROM tmpStakeLevelMapping WITH (NOLOCK)
		WHERE ExchangeId = @ExchangeID
		
		UPDATE #StakeLevel_PreMapping SET StakeLevelList_Allbet = @v_str
		WHERE ID= @Index_Start
	END
	SET @Index_Start =  @Index_Start + 1
END

UPDATE T1
	SET StakeLevelList_Allbet = T2.StakeLevelList_Allbet
FROM #tmpCustGameType T1
	INNER JOIN #StakeLevel_PreMapping T2 ON T1.ExchangeID = T2.ExchangeID AND T1.StakeLevelList_LC = T2.StakeLevelList_LC

-- Lowest PROCESSING 
-- use this table to trace problem #CustList_ResetLowest
SELECT T1.CustID,T1.roleID
INTO #CustList_ResetLowest
FROM #tmpCustGameType T1 (NOLOCK)
	INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid AND CI.SyncLiveCasino = 1 AND CI.Enabled = 1
WHERE T1.StakeLevelList_AllBet = '' OR T1.StakeLevelList_AllBet IS NULL


UPDATE T1
	SET DirectUplineID = CASE WHEN ci.roleid = 1 THEN CI.recommend
								 WHEN ci.roleid = 2 THEN CI.mrecommend
								 WHEN ci.roleid = 3 THEN CI.srecommend
							ELSE 0 END 	 
FROM #tmpCustGameType T1
	INNER JOIN #CustList_ResetLowest T2 on T1.CustID = T2.CustID
	INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid

-- Process roleid = 4
UPDATE T1
	SET StakeLevelList_Allbet = STUFF(temp.StakeLevelID,1,1,'')
FROM #tmpCustGameType T1
	INNER JOIN custInfo CI WITH (NOLOCK) ON T1.CustID = CI.custid AND CI.Enabled = 1 AND CI.SyncLiveCasino = 1
	CROSS APPLY (SELECT ',' +  CONVERT(VARCHAR(10),SL.StakeLevelID) 
				FROM dbo.StakeLevel SL WITH(NOLOCK) 
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY MaxStake, MinStake
				FOR XML PATH ('')
				) AS temp (StakeLevelID)
WHERE CI.roleid = 4	

-- Process RoleID = 3
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM #tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM #tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 3 AND T1.DirectUplineID <> 0  

-- Process RoleID = 2
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM #tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM #tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 2 AND T1.DirectUplineID <> 0 	

-- Process RoleID = 1
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM #tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM #tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 1 AND T1.DirectUplineID <> 0 	


--Bettype 2402: Lowest VIP Bet limit
	
--Member Level
CREATE TABLE #CustStakeLevel_Member_2401 (CustID INT, SportType INT, BetType INT, StakeLevelList VARCHAR(100),ExchangeID INT,syncLiveCasino BIT)		
CREATE TABLE #CustStakeLevel_Agent_2401 (CustID INT, SportType INT, BetType INT, StakeLevelList VARCHAR(100), ExchangeID INT, syncLiveCasino BIT)		

INSERT INTO #CustStakeLevel_Member_2401(CustID, SportType, BetType, StakeLevelList,ExchangeID,syncLiveCasino)		
SELECT C.custid, 211, 2401, CASE WHEN c.syncLiveCasino = 1 THEN ISNULL(c1.StakeLevelList_Allbet,'') ELSE '' END AS StakeLevelList, C1.ExchangeID,C.syncLiveCasino
FROM #tmpCust c
	LEFT JOIN #tmpCustGameType C1 ON c.custid = c1.CustID
WHERE c.roleid = 1 AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Member sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2401)


INSERT INTO #CustStakeLevel_Agent_2401(CustID, SportType, BetType, StakeLevelList,ExchangeID,syncLiveCasino)		
SELECT C.custid, 211, 2401, CASE WHEN c.syncLiveCasino = 1 THEN ISNULL(c1.StakeLevelList_Allbet,'') ELSE '' END AS StakeLevelList, C1.ExchangeID,C.syncLiveCasino
FROM #tmpCust c
	LEFT JOIN #tmpCustGameType C1 ON c.custid = c1.CustID
WHERE c.roleid IN (2,3,4) AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Agent sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2401)


-- insert data 

INSERT INTO CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		
SELECT CustID, SportType, BetType, StakeLevelList
FROM (  SELECT CustID, SportType, BetType, StakeLevelList
		FROM #CustStakeLevel_Member_2401
		UNION ALL 
		SELECT c.custid, 211, 2402, CASE WHEN C.syncLiveCasino = 1 THEN CONVERT(VARCHAR(100),T1.StakeLevelList) ELSE '' END AS StakeLevelList
		FROM #tmpCust c
			CROSS APPLY (SELECT TOP 1 ISNULL(StakeLevelID ,'') AS StakeLevelList
						FROM dbo.StakeLevel sl WITH(NOLOCK) 
						WHERE sl.ExchangeId = c.currency AND GameTypeID = 2402 
					) AS T1
		WHERE c.roleid = 1 
		) AS tmp

WHERE  NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Member sk WITH (NOLOCK) WHERE sk.CustID = tmp.custid AND sk.SportType = 211 AND sk.BetType = tmp.BetType)

--SMA Level
INSERT INTO CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
SELECT CustID, SportType, BetType, StakeLevelList
FROM (  SELECT CustID, SportType, BetType, StakeLevelList
		FROM #CustStakeLevel_Agent_2401
		UNION ALL 
		SELECT c.custid, 211, 2402, CASE WHEN C.syncLiveCasino = 1 THEN CONVERT(VARCHAR(100),T1.StakeLevelList) ELSE '' END AS StakeLevelList
		FROM #tmpCust c
			CROSS APPLY (SELECT TOP 1 ISNULL(StakeLevelID ,'') AS StakeLevelList
						FROM dbo.StakeLevel sl WITH(NOLOCK) 
						WHERE sl.ExchangeId = c.currency AND GameTypeID = 2402 
					) AS T1
		WHERE c.roleid IN (2,3,4) 
		) AS tmp

WHERE  NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Agent sk WITH (NOLOCK) WHERE sk.CustID = tmp.custid AND sk.SportType = 211 AND sk.BetType = tmp.BetType)


DROP TABLE #CustStakeLevel_Agent_2401
DROP TABLE #CustStakeLevel_Member_2401

DROP TABLE #StakeLevel_PreMapping
DROP TABLE #tmpCust
DROP TABLE #tmpCustGameType
DROP TABLE #DirectAgent
DROP TABLE #DirectMaster
DROP TABLE #MemberTemp
DROP TABLE #SMATemp




