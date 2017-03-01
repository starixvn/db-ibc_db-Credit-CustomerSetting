/*
	Created: Helen
	Date: 20160824
	Task: Mapping stake level from LCS to AllBet for preparing AllBet settings
	DB: DBCUST.CustDB
	
	
	
*/ 

-------STEP 1: START OF DATA PREPARATION ----------------------------
------- 1.1 GET StakeLevel FROM LC ----------------------------
CREATE TABLE #tmpStakeLevel(
	[StakeLevelID] [int] NOT NULL PRIMARY KEY,
	[GameTypeID] [int] NOT NULL,
	[MinLabel] [nvarchar](50) NULL,
	[MaxLabel] [nvarchar](50) NULL,
	[MinStake] [decimal](19, 8) NULL,
	[MaxStake] [decimal](19, 8) NULL,
	[ExchangeId] [int] NULL,
 )


INSERT INTO #tmpStakeLevel
           (StakeLevelID
           ,[GameTypeID]
           ,[MinLabel]
           ,[MaxLabel]
           ,[MinStake]
           ,[MaxStake]
           ,[ExchangeId]
          )
SELECT t.StakeLevelID, 2401 AS GameTypeID,s.[MinLabel],s.[MaxLabel],s.[MinStake],s.[MaxStake],t.[ExchangeId]
FROM (           
		SELECT StakeLevelID, exchangeID, GameTypeID
		FROM DBBingoAdmin.LiveCasinoAdmin.dbo.gameTemplate gt with(nolock) 
			INNER JOIN DBBingoAdmin.LiveCasinoAdmin.dbo.gameStakeLevel gs with(nolock) ON gt.gameTemplateid = gs.gameTemplateid 
		WHERE gt.GameTypeid = 108 AND gt.gameTemplateid = 193 
			--AND exchangeID in (1,2,3,4,5,6,9,12,13,15,16,17,21,22,31,32,33,34,35,36,37,40,41,43,44,45,47,50,51,52,54,55,58,61,62,64,65,66,67,68)
		)t    
INNER JOIN DBBingoAdmin.LiveCasinoAdmin.dbo.stakeLevel s with(Nolock) on t.stakeLevelID = s.stakelevelID

------- 1.2 DATA EXCEL FILE PROCESSING  ----------------------------

CREATE TABLE #CodeCurrency (ID INT, Currency VARCHAR(1000) )

INSERT INTO #CodeCurrency (ID,Currency)
VALUES
(1,'$US, NTD, US$, UT, Yen, IRR, EURO, SD$, GBP'),
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



CREATE TABLE #StakeLevel_2401_final (GameTypeID INT,MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8), ExchangeId INT,Currency VARCHAR(100), StakeLevelID INT, ResourceID INT )
CREATE TABLE #StakeLevel_2402_final (GameTypeID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8), ExchangeId INT,Currency VARCHAR(100), StakeLevelID INT, ResourceID INT )

CREATE TABLE #StakeLevel_Result (ID INT IDENTITY,MappingID INT,GameTypeID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8), ExchangeId INT,Currency VARCHAR(100), StakeLevelID INT, ResourceID INT )

CREATE TABLE #StakeLEvel_LC_final (GameTypeID INT, MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50),ResourceID INT,ExchangeId INT,Currency VARCHAR(100))

CREATE TABLE #StakeLEvel_LC_DB (GameTypeID INT, MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50),ResourceID INT,ExchangeId INT,Currency VARCHAR(100),StakeLevelID INT)

CREATE TABLE #StakeLEvel_tmp_2401 (ID INT,MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8),ResourceID INT)
CREATE TABLE #StakeLEvel_tmp_2402 (ID INT,MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8),ResourceID INT)
CREATE TABLE #StakeLEvel_tmp_LC (ID INT,MappingID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50),ResourceID INT)

INSERT INTO #StakeLEvel_tmp_LC (MappingID,ID,MinLabel,MaxLabel,ResourceID)
VALUES
(1,1,'2.5','500',241),
(2,1,'10','1000',241),
(3,1,'50','2500',241),
(4,1,'100','5000',2),
(5,2,'10','1500',241),
(6,2,'50','5000',2),
(7,2,'250','10000',244),
(8,2,'500','25000',245),
(9,3,'5','1000',241),
(10,3,'25','2500',241),
(11,3,'100','5000',2),
(12,3,'250','10000',244),
(13,5,'2500','300000',74),
(14,5,'7500','750000',76),
(15,5,'25000','1000000',37),
(16,5,'75000','3000000',139),
(17,6,'50','10000',3),
(18,6,'250','25000',30),
(19,6,'1000','50000',44),
(20,6,'2500','100000',152),
(21,7,'25','3000',243),
(22,7,'75','7500',243),
(23,7,'250','10000',4),
(24,7,'750','30000',5),
(25,8,'25','3000',242),
(26,8,'75','7500',3),
(27,8,'250','10000',3),
(28,8,'750','30000',5),
(29,9,'100','20000',30),
(30,9,'500','50000',44),
(31,9,'2500','100000',8),
(32,9,'5000','250000',35),
(33,10,'2.5','300',39),
(34,10,'10','1000',53),
(35,10,'50','2500',181),
(36,10,'75','3000',182),
(37,11,'25','2500',241),
(38,11,'50','500',241),
(39,11,'1000','5000',2),
(40,11,'100','10000',244),
(41,11,'25000','1000000',245)


INSERT INTO #StakeLEvel_tmp_2401 (MappingID,ID,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
VALUES
(1,1,'25','2500',25,2500,241),
(2,1,'25','2500',25,2500,241),
(3,1,'25','2500',25,2500,241),
(4,1,'50','5000',50,5000,2),
(5,2,'25','2500',25,2500,241),
(6,2,'50','5000',50,5000,2),
(7,2,'250','10000',250,10000,244),
(8,2,'500','25000',500,25000,245),
(9,3,'25','2500',25,2500,241),
(10,3,'25','2500',25,2500,241),
(11,3,'50','5000',50,5000,2),
(12,3,'250','10000',250,10000,244),
(13,5,'3600','360000',3600,360000,74),
(14,5,'7200','720000',7200,720000,76),
(15,5,'10000','1000000',10000,1000000,37),
(16,5,'100000','3000000',100000,3000000,139),
(17,6,'100','10000',100,10000,3),
(18,6,'250','25000',250,25000,30),
(19,6,'500','50000',500,50000,44),
(20,6,'2000','100000',2000,100000,152),
(21,7,'70','7000',70,7000,243),
(22,7,'70','7000',70,7000,243),
(23,7,'200','20000',200,20000,4),
(24,7,'300','30000',300,30000,5),
(25,8,'40','4000',40,4000,242),
(26,8,'100','10000',100,10000,3),
(27,8,'100','10000',100,10000,3),
(28,8,'300','30000',300,30000,5),
(29,9,'250','25000',250,25000,30),
(30,9,'500','50000',500,50000,44),
(31,9,'1000','100000',1000,100000,8),
(32,9,'2500','250000',2500,250000,35),
(33,10,'5','500',5,500,39),
(34,10,'10','1000',10,1000,53),
(35,10,'100','3000',100,3000,181),
(36,10,'100','3000',100,3000,182),
(37,11,'25','2500',25,2500,241),
(38,11,'25','2500',25,2500,241),
(39,11,'50','5000',50,5000,2),
(40,11,'250','10000',250,10000,244),
(41,11,'500','25000',500,25000,245)


INSERT INTO #StakeLEvel_tmp_2402 (ID,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
VALUES
(1,'1000','20000',1000,20000,241),
(2,'2000','200000',2000,200000,241),
(3,'2000','200000',2000,200000,241),
(5,'1000000','20000000',1000000,20000000,74),
(6,'20000','1000000',20000,1000000,3),
(7,'10000','500000',10000,500000,243),
(8,'3000','300000',3000,300000,242),
(9,'20000','1000000',20000,1000000,30),
(10,'1000','20000',1000,20000,39),
(11,'1000','20000',1000,20000,241)



INSERT INTO #StakeLEvel_2401_final (GameTypeID,MappingID,ExchangeId,Currency,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
SELECT 2401 AS GameTypeID,T1.MappingID,T2.ExchangeID,T2.Currency
		,MinLabel =  (SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MinLabel,CHARINDEX('-',T1.MinLabel) + 1,LEN(T1.MinLabel)))),',','') AS MONEY), 1)) s(t))
		,MaxLable=(SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MaxLabel,CHARINDEX('-',T1.MaxLabel) + 1,LEN(T1.MaxLabel)))),',','') AS MONEY), 1)) s(t))
		,t1.MinStake,T1.MaxStake
		,T1.ResourceID	
FROM #StakeLEvel_tmp_2401 T1
	INNER JOIN #ExchangeIDListPerCurrency T2 ON T1.ID = T2.ID

INSERT INTO #StakeLEvel_LC_final(GameTypeID,MappingID,ExchangeId,Currency,MinLabel,MaxLabel,ResourceID)
SELECT 2401 AS GameTypeID,T1.MappingID,T2.ExchangeID,T2.Currency
		,MinLabel =  (SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MinLabel,CHARINDEX('-',T1.MinLabel) + 1,LEN(T1.MinLabel)))),',','') AS MONEY), 1)) s(t))
		,MaxLable=(SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MaxLabel,CHARINDEX('-',T1.MaxLabel) + 1,LEN(T1.MaxLabel)))),',','') AS MONEY), 1)) s(t))
		,T1.ResourceID	
FROM #StakeLEvel_tmp_LC T1
	INNER JOIN #ExchangeIDListPerCurrency T2 ON T1.ID = T2.ID

INSERT INTO #StakeLEvel_2402_final (GameTypeID,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
SELECT 2402 AS GameTypeID,T2.ExchangeID
		,MinLabel =  (SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MinLabel,CHARINDEX('-',T1.MinLabel) + 1,LEN(T1.MinLabel)))),',','') AS MONEY), 1)) s(t))
		,MaxLable=(SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T1.MaxLabel,CHARINDEX('-',T1.MaxLabel) + 1,LEN(T1.MaxLabel)))),',','') AS MONEY), 1)) s(t))
		,t1.MinStake,T1.MaxStake
		,T1.ResourceID	
FROM #StakeLEvel_tmp_2402 T1
	INNER JOIN #ExchangeIDListPerCurrency T2 ON T1.ID = T2.ID
ORDER BY T2.ExchangeID,t1.MinStake

INSERT INTO #StakeLEvel_LC_DB(GameTypeID,ExchangeId,Currency,MinLabel,MaxLabel,StakeLevelID)
SELECT 2401 AS GameTypeID,T.ExchangeID,T1.Currency
		,MinLabel =  (SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T.MinLabel,CHARINDEX('-',T.MinLabel) + 1,LEN(T.MinLabel)))),',','') AS MONEY), 1)) s(t))
		,MaxLable=(SELECT SUBSTRING(t, 0, CASE CHARINDEX('.00', t) WHEN 0 THEN LEN(t) ELSE CHARINDEX('.00', t) END)
		FROM (SELECT CONVERT(VARCHAR, CAST(REPLACE(LTRIM(RTRIM(SUBSTRING (T.MaxLabel,CHARINDEX('-',T.MaxLabel) + 1,LEN(T.MaxLabel)))),',','') AS MONEY), 1)) s(t))
		,t.StakeLevelID
FROM #ExchangeIDListPerCurrency T1
	INNER JOIN #tmpStakeLevel t (NOLOCK) on t.ExchangeId = T1.ExchangeID

INSERT INTO #StakeLevel_Result	(GameTypeID,MappingID,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID)
SELECT GameTypeID,MappingID,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID
FROM #StakeLEvel_2401_final
UNION ALL
SELECT GameTypeID,0,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake,ResourceID
FROM #StakeLEvel_2402_final

DECLARE @max_StakeLevelID INT = 0
SET @max_StakeLevelID = (SELECT MAX(StakeLevelID) FROM StakeLevel WITH (NOLOCK))

UPDATE T
	SET StakeLevelID = @max_StakeLevelID + ID
FROM #StakeLEvel_Result T
	
-------END OF STEP 1: START OF DATA PREPARATION ----------------------------

------- STEP 2: INSERT DATA ----------------------------
------- 2.1 StakeLevel, & temporary table for mapping named tmpStakeLevelMapping only run on DBCUST.CUSTDB ----------------------------

DELETE StakeLevel WHERE GameTypeID IN (2401,2402)

SET IDENTITY_INSERT StakeLevel ON

INSERT INTO StakeLevel (StakeLevelID,GameTypeID, MinLabel, MaxLabel, MinStake, MaxStake, ExchangeId, ResourceId)
SELECT StakeLevelID,GameTypeID, MinLabel, MaxLabel, MinStake, MaxStake, ExchangeId, ResourceId
FROM #StakeLEvel_Result


SET IDENTITY_INSERT StakeLevel OFF

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'tmpStakeLevelMapping' and TYPE = 'U')
    DROP TABLE tmpStakeLevelMapping

CREATE TABLE [dbo].tmpStakeLevelMapping(
	StakeLevelID_LC INT, GameTypeID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8)
	, ExchangeId INT,Currency VARCHAR(100), StakeLevelID_AllBet INT
 CONSTRAINT [PK_tmpStakeLevelMapping] PRIMARY KEY CLUSTERED 
(
	StakeLevelID_LC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [CustGameType_table]
) ON [CustGameType_table]

INSERT INTO tmpStakeLevelMapping (GameTypeID,StakeLevelID_LC,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake, StakeLevelID_AllBet)
SELECT 2401 AS GameTypeID, t.StakeLevelID AS StakeLevelID_LC,C.Currency,C.ExchangeID,BT_2401.MinLabel,BT_2401.MaxLabel,BT_2401.MinStake,BT_2401.MaxStake, BT_2401.StakeLevelID
FROM #ExchangeIDListPerCurrency c
	INNER JOIN #StakeLEvel_LC_DB t on t.ExchangeId =c.ExchangeID
	INNER JOIN #StakeLEvel_LC_final LC ON LC.ExchangeId = t.ExchangeId AND T.MinLabel = LC.MinLabel AND T.MaxLabel = LC.MaxLabel
	INNER JOIN #StakeLevel_Result BT_2401 ON BT_2401.ExchangeId = lc.ExchangeId AND BT_2401.MappingID = LC.MappingID AND BT_2401.GameTypeID = 2401
ORDER BY C.ExchangeID,BT_2401.MinStake
------- END OF 2.1 StakeLevel, only run on DBCUST.CUSTDB ---------------------

/*

---------------- DOUBLE CHECK MAPPING ......................
SELECT e.exchangeID, E.currency,O.StakeLevelID,GameTypeID,MinLabel,MaxLabel,MinStake,MaxStake
FROM #tmpStakeLevel O
	INNER JOIN EXCHANGE E (NOLOCK) ON O.ExchangeId = E.exchangeid and StakeLevelID = 1223
ORDER BY Currency,MinStake

SELECT currency,StakeLevelID_LC,GameTypeID,MinLabel,MaxLabel,MinStake,MaxStake,StakeLevelID_AllBet 
FROM tmpStakeLevelMapping 
where StakeLevelID_LC = 1223
ORDER BY Currency,MinStake

SELECT currency,StakeLevelID AS _Allbet,GameTypeID,MinLabel,MaxLabel,MinStake,MaxStake
FROM #StakeLevel_Result
WHERE GameTypeID = 2401 and StakeLevelID = 1223
ORDER BY Currency,MinStake

*/


DROP TABLE #CodeCurrency
DROP TABLE #ExchangeIDListPerCurrency
DROP TABLE #StakeLEvel_LC_DB
DROP TABLE #StakeLEvel_LC_final
DROP TABLE #StakeLEvel_tmp_2401
DROP TABLE #StakeLEvel_tmp_2402
DROP TABLE #StakeLEvel_tmp_LC
DROP TABLE #StakeLevel_2401_final
DROP TABLE #StakeLevel_2402_final
DROP TABLE #StakeLevel_Result
DROP TABLE #tmpStakeLevel
