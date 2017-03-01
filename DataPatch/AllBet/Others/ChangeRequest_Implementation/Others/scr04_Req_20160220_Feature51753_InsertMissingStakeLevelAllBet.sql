/*
	Created: Helen
	Date: 20160824
	Task: Insert Stakelevel missing 
	DB: DBCUST.CustDB
	
	
*/ 

-------STEP 1: START OF DATA PREPARATION ----------------------------
------- 1.1 GET StakeLevel FROM LC ----------------------------

------- 1.2 DATA EXCEL FILE PROCESSING  ----------------------------

CREATE TABLE #CodeCurrency (ID INT, Currency VARCHAR(1000) )

INSERT INTO #CodeCurrency (ID,Currency)
VALUES
(1,'$US, NTD, US$, UT, Yen, IRR, EURO, SD$, GBP'),
(1,''),
(3,'RM'),
(7,'INH'),
(8,'IDD,IDR,IN, IND, DDD'),
(10,'MMK,MKK')

DELETE #CodeCurrency WHERE currency = ''

CREATE TABLE #ExchangeIDListPerCurrency (ID INT, ExchangeID INT, Currency VARCHAR(20) )
INSERT INTO #ExchangeIDListPerCurrency (ID,ExchangeID,Currency)
SELECT t.ID,cur.exchangeid,cur.currency as currency
FROM #CodeCurrency t
	OUTER APPLY (SELECT e.exchangeid AS exchangeid,e.currency
				FROM strSplit (t.Currency,',') AS T
					INNER JOIN DBCUST.CUSTDB.dbo.exchange e(NOLOCK) ON LTRIM(RTRIM(T.val)) =e.currency) AS cur


CREATE TABLE #StakeLevel_2401_final (ID INT IDENTITY,GameTypeID INT,MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8), ExchangeId INT,Currency VARCHAR(100), StakeLevelID INT, ResourceID INT )


CREATE TABLE #StakeLEvel_tmp_2401 (ID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8),ResourceID INT)

INSERT INTO #StakeLEvel_tmp_2401 (ID,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
VALUES
(1,'250','10000',250,10000,244),
(1,'500','25000',500,25000,245),
(3,'500','25000',500,25000,245),
(7,'250','25000',250,25000,30),
(8,'250','25000',250,25000,30),
(10,'50','1500',50,1500,181)


INSERT INTO #StakeLEvel_2401_final (GameTypeID,ExchangeId,Currency,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
SELECT 2401 AS GameTypeID,T2.ExchangeID,T2.Currency
		,MinLabel =  (SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MinLabel,CHARINDEX('-',T1.MinLabel) + 1,LEN(T1.MinLabel)))),',','') AS MONEY), 1)) s(t))
		,MaxLable=(SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MaxLabel,CHARINDEX('-',T1.MaxLabel) + 1,LEN(T1.MaxLabel)))),',','') AS MONEY), 1)) s(t))
		,t1.MinStake,T1.MaxStake
		,T1.ResourceID	
FROM #StakeLEvel_tmp_2401 T1
	INNER JOIN #ExchangeIDListPerCurrency T2 ON T1.ID = T2.ID

DECLARE @max_StakeLevelID INT = 0
SET @max_StakeLevelID = (SELECT MAX(StakeLevelID) FROM StakeLevel WITH (NOLOCK))

UPDATE T
	SET StakeLevelID = @max_StakeLevelID + ID
FROM #StakeLevel_2401_final T

-------END OF STEP 1: START OF DATA PREPARATION ----------------------------

------- STEP 2: INSERT DATA ----------------------------
------- 2.1 StakeLevel, & temporary table for mapping named tmpStakeLevelMapping only run on DBCUST.CUSTDB ----------------------------

SET IDENTITY_INSERT StakeLevel ON

INSERT INTO StakeLevel (StakeLevelID,GameTypeID, MinLabel, MaxLabel, MinStake, MaxStake, ExchangeId, ResourceId)
SELECT StakeLevelID,GameTypeID, MinLabel, MaxLabel, MinStake, MaxStake, ExchangeId, ResourceId
FROM #StakeLEvel_2401_final
ORDER BY ID
SET IDENTITY_INSERT StakeLevel OFF

DROP TABLE #CodeCurrency
DROP TABLE #ExchangeIDListPerCurrency
DROP TABLE #StakeLEvel_tmp_2401
DROP TABLE #StakeLevel_2401_final


