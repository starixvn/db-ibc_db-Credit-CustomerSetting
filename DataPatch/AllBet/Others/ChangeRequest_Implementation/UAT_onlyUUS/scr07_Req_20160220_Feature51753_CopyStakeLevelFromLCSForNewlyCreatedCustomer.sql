/*
	Created: Elodie
	Date: 20160301
	Task: copy stake level for newly created customers
	DB: DBCUST/CustDB
*/
--step 0: backup & copy stake level setting from LCS DB to DBTP for newly customers

CREATE TABLE #supers (custid int, currency INT)

INSERT INTO #supers(custid,currency)
SELECT custid, currency
FROM Customer WITH(NOLOCK)
WHERE roleid = 4 	
	AND custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	-- UAT
	AND currency = 20

--step 1: copy settings for newly created customers
CREATE TABLE #tmpCust (custid INT, roleid INT, syncLiveCasino BIT, uplineID INT, srecommend INT, currency INT)

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

---- data preparation ----
CREATE TABLE #tmpCustGameType (
	[CustID] [int] NOT NULL PRIMARY KEY,
	[ExchangeID] [int] NOT NULL, 
	[StakeLevelList_LC] [varchar](100) NULL,
	[StakeLevelList_AllBet] [varchar](100) NULL
 )

CREATE TABLE #CodeCurrency (ID INT, Currency VARCHAR(1000) )

INSERT INTO #CodeCurrency (ID,Currency)
VALUES(1,'$US, NTD, US$, UT, Yen, IRR, EURO, SD$, GBP'),
(1,''),
(1,''),
(1,''),
(2,'HK$,HKK, RMB'),
(2,''),
(2,''),
(2,''),
(3,'RM'),
(3,''),
(3,''),
(3,''),
(5,'Won'),
(5,''),
(5,''),
(5,''),
(6,'TB, THB'),
(6,''),
(6,''),
(6,''),
(7,'INH'),
(7,''),
(7,''),
(7,''),
(8,'IDD,IDR,IN, IND, DDD'),
(8,''),
(8,''),
(8,''),
(9,'INR'),
(9,''),
(9,''),
(9,''),
(10,'MMK,MKK'),
(10,''),
(10,''),
(10,''),
(11,'UUS'),
(11,''),
(11,''),
(11,''),
(11,'')



DELETE #CodeCurrency WHERE currency = ''

CREATE TABLE #ExchangeIDListPerCurrency (ID INT, ExchangeID INT, Currency VARCHAR(20) )
INSERT INTO #ExchangeIDListPerCurrency (ID,ExchangeID,Currency)
SELECT t.ID,cur.exchangeid,cur.currency as currency
FROM #CodeCurrency t
	OUTER APPLY (SELECT e.exchangeid AS exchangeid,e.currency
				FROM strSplit (t.Currency,',') AS T
					INNER JOIN DBCUST.CUSTDB.dbo.exchange e(NOLOCK) ON LTRIM(RTRIM(T.val)) =e.currency) AS cur

INSERT INTO #tmpCustGameType ([CustID], [StakeLevelList_LC],[ExchangeID])
SELECT cs.custid, StakeLevelList,ci.currency	
FROM DBBingoAdmin.LiveCasinoAdmin.dbo.CustGameType cs WITH(NOLOCK) 
	INNER JOIN #tmpCust ci WITH(NOLOCK) ON cs.custid = ci.custid


CREATE TABLE #StakeLevel_PreMapping (ID INT IDENTITY (1,1),ExchangeID INT, StakeLevelList_LC VARCHAR(1000),StakeLevelList_Allbet VARCHAR (1000))

INSERT INTO #StakeLevel_PreMapping (StakeLevelList_LC,ExchangeID)
SELECT DISTINCT StakeLevelList_LC,ExchangeID
FROM #tmpCustGameType WITH (NOLOCK)

DECLARE @Index_Start INT  = 0
DECLARE @Index_Stop INT = (SELECT MAX(ID) FROM #StakeLevel_PreMapping)

DECLARE @v_str NVARCHAR(1000), @ExchangeID INT

WHILE @Index_Start <= @Index_Stop
BEGIN 
	SELECT @v_str = StakeLevelList_LC,@ExchangeID = ExchangeID  FROM #StakeLevel_PreMapping WHERE ID =  @Index_Start
	
	SELECT @v_str = REPLACE(@v_str,StakeLevelID_LC, StakeLevelID_AllBet)
	FROM tmpStakeLevelMapping WITH (NOLOCK)
	WHERE ExchangeId = @ExchangeID
	
	UPDATE #StakeLevel_PreMapping SET StakeLevelList_Allbet = @v_str
	WHERE ID= @Index_Start
	
	SET @Index_Start =  @Index_Start + 1
END

UPDATE T1
	SET StakeLevelList_Allbet = T2.StakeLevelList_Allbet
FROM #tmpCustGameType T1
	INNER JOIN #StakeLevel_PreMapping T2 ON T1.ExchangeID = T2.ExchangeID AND T1.StakeLevelList_LC = T2.StakeLevelList_LC

SELECT @max_custid = 100
		,@max_custid2 = 1001

INSERT INTO #tmpCust(custid, roleid, syncLiveCasino, currency)
SELECT DISTINCT ci.custid, roleid, syncLiveCasino, s.currency
FROM custinfo ci WITH(NOLOCK) 
	INNER JOIN #Supers s ON ci.srecommend = s.custid
WHERE ci.custid > @max_custid
	AND ci.custid <= @max_custid2
	
--Bettype 2402: Lowest VIP Bet limit
SET @StakeLevelList_2402 = (SELECT TOP 1 ISNULL(StakeLevelID ,'')
							FROM dbo.StakeLevel WITH(NOLOCK) 
							WHERE ExchangeId = @currency AND GameTypeID = 2402 )


SET @StakeLevelList_2401_Lowest = (SELECT TOP 1 ISNULL(StakeLevelID ,'')
									FROM dbo.StakeLevel WITH(NOLOCK) 
									WHERE ExchangeId = @currency AND GameTypeID = 2401 
									ORDER BY MaxStake, MinStake
								  )	
	
--Member Level
INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		

SELECT C.custid, 211, 2401, CASE WHEN c.syncLiveCasino = 1 THEN ISNULL(StakeLevelList_Allbet,@StakeLevelList_2401_Lowest) ELSE '' END AS StakeLevelList
FROM #tmpCust c
	LEFT JOIN #tmpCustGameType C1 ON c.custid = c1.CustID
WHERE c.roleid = 1 AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Member sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2401)
UNION ALL 

SELECT c.custid, 211, 2402, CASE WHEN C.syncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
FROM #tmpCust c
WHERE c.roleid = 1 AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Member sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2402)

--SMA Level
INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
SELECT C.custid, 211, 2401, CASE WHEN c.syncLiveCasino = 1 THEN ISNULL(StakeLevelList_Allbet,@StakeLevelList_2401_Lowest) ELSE '' END AS StakeLevelList
FROM #tmpCust c
	LEFT JOIN #tmpCustGameType C1 ON c.custid = c1.CustID
WHERE c.roleid IN (2,3,4) AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Agent sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2401)

UNION ALL 

SELECT c.custid, 211, 2402, CASE WHEN C.syncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
FROM #tmpCust c
WHERE c.roleid IN (2,3,4) AND NOT EXISTS ( SELECT 1 FROM CustStakeLevel_Agent sk WITH (NOLOCK) WHERE sk.CustID = c.custid AND sk.SportType = 211 AND sk.BetType = 2402)




