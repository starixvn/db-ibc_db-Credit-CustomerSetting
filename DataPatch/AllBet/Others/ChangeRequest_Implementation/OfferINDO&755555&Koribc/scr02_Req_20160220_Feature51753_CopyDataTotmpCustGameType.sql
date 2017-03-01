/*
	Created: Helen
	Date: 20160824
	Task: prepare data for tmpCustGameType
	DB: DBCUST/06/TP/MNL.bodb02	
*/ 
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'tmpCustGameType' and TYPE = 'u')
    DROP TABLE tmpCustGameType
GO  
CREATE TABLE [dbo].[tmpCustGameType](
	[CustID] [int] NOT NULL,
	[roleID] [int] ,
	[DirectUplineID] [int],
	[ExchangeID] [int] NOT NULL, 
	[StakeLevelList_LC] [varchar](100) NULL,
	[StakeLevelList_AllBet] [varchar](100) NULL,
	[StakeLevelListUpline_AllBet] [varchar](100) NULL
 CONSTRAINT [PK_tmpCustGameType] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [CustGameType_table]
) ON [CustGameType_table]

GO

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

CREATE TABLE #supers (custid int)

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.site in ('INDO','755555','Koribc')
		AND ci.custid <> 72)
		OR ci.custid IN (2,4,13,15)
		
INSERT INTO [dbo].[tmpCustGameType] ([CustID], [StakeLevelList_LC],[ExchangeID],roleID)
SELECT cs.custid, cs.StakeLevelList_LC,ci.currency,ci.roleid	
FROM CustGameType_LCS cs WITH(NOLOCK) --DBBingoAdmin.LiveCasinoAdmin.dbo.CustGameType
	INNER JOIN Customer ci WITH(NOLOCK) ON cs.custid = ci.custid
	INNER JOIN #ExchangeIDListPerCurrency  tmp ON tmp.ExchangeID = ci.currency
	INNER JOIN #supers s (nolock) on ci.srecommend = s.custid	


GO

CREATE TABLE #StakeLevel_PreMapping (ID INT IDENTITY (1,1),ExchangeID INT, StakeLevelList_LC VARCHAR(1000),StakeLevelList_Allbet VARCHAR (1000))

INSERT INTO #StakeLevel_PreMapping (StakeLevelList_LC,ExchangeID)
SELECT DISTINCT StakeLevelList_LC,ExchangeID
FROM tmpCustGameType WITH (NOLOCK)

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

SELECT t1.*,t2.*
INTO #tmpStakeLevelMapping_DuplicateProcess
FROM #StakeLevel_PreMapping t1 (NOLOCK)
	CROSS APPLY (SELECT val,COUNT(*) as count_duplicate
				 FROM strSplit (t1.StakeLevelList_Allbet,',')
				 GROUP BY val
				 HAVING COUNT(*) > 1
				 ) as t2
WHERE T1.StakeLevelList_Allbet IS NOT NULL
				 

IF EXISTS (SELECT 1 FROM #tmpStakeLevelMapping_DuplicateProcess)
BEGIN
	
	UPDATE Temp
		SET StakeLevelList_Allbet = STUFF(t2.StakelevelList,1,1,'') 
	FROM #StakeLevel_PreMapping Temp
		INNER JOIN #tmpStakeLevelMapping_DuplicateProcess T1 ON TEMP.ExchangeID = T1.ExchangeID AND TEMP.StakeLevelList_Allbet=T1.StakeLevelList_Allbet 
		CROSS APPLY (SELECT ','+t.VAL 
					 FROM ( SELECT DISTINCT val 
							from strSplit (t1.StakeLevelList_Allbet,',')
						  ) as t
					 FOR XML PATH ('')	  
					 ) as t2 (StakelevelList)
		WHERE T1.StakeLevelList_Allbet IS NOT NULL			 
END
-- Update mapping
UPDATE T1
	SET StakeLevelList_Allbet = T2.StakeLevelList_Allbet
FROM tmpCustGameType T1
	INNER JOIN #StakeLevel_PreMapping T2 ON T1.ExchangeID = T2.ExchangeID AND T1.StakeLevelList_LC = T2.StakeLevelList_LC

-- Update StakelevelistUpline in case of not having stakelavel

-- use this table to trace problem #CustList_ResetLowest
SELECT T1.CustID,T1.roleID
INTO #CustList_ResetLowest
FROM tmpCustGameType T1 (NOLOCK)
	INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid AND CI.SyncLiveCasino = 1 AND CI.Enabled = 1
WHERE T1.StakeLevelList_AllBet = '' OR T1.StakeLevelList_AllBet IS NULL


UPDATE T1
	SET DirectUplineID = CASE WHEN ci.roleid = 1 THEN CI.recommend
								 WHEN ci.roleid = 2 THEN CI.mrecommend
								 WHEN ci.roleid = 3 THEN CI.srecommend
							ELSE 0 END 	 
FROM tmpCustGameType T1
	INNER JOIN #CustList_ResetLowest T2 on T1.CustID = T2.CustID
	INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid
	
-- Process roleid = 4
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM tmpCustGameType T1
	INNER JOIN custInfo CI WITH (NOLOCK) ON T1.CustID = CI.custid AND CI.Enabled = 1 AND CI.SyncLiveCasino = 1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM dbo.StakeLevel SL WITH(NOLOCK) 
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY MaxStake, MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND CI.roleid = 4	

-- Process RoleID = 3
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 3 AND T1.DirectUplineID <> 0  

-- Process RoleID = 2
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 2 AND T1.DirectUplineID <> 0 	

-- Process RoleID = 1
UPDATE T1
	SET StakeLevelList_Allbet = CONVERT(VARCHAR(100),temp.StakeLevelID)
FROM tmpCustGameType T1
	CROSS APPLY (SELECT TOP 1  SL.StakeLevelID 
				FROM strSplit ((SELECT ISNULL(T2.StakeLevelList_AllBet,-1)  
								FROM tmpCustGameType T2 WITH (NOLOCK) 
								WHERE T2.custid = t1.DirectUplineID),',') tmp 
					INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
				WHERE SL.ExchangeId = T1.ExchangeID AND GameTypeID = 2401
				ORDER BY SL.MaxStake, SL.MinStake) AS temp
WHERE (T1.StakeLevelList_LC = '' OR T1.StakeLevelList_LC IS NULL ) AND T1.roleID = 1 AND T1.DirectUplineID <> 0 	


/*

select * from tmpCustGameType (nolock) where custid in (20972758,20717186)

select t1.*
from tmpCustGameType t1 (nolock)
	inner join #CustList_ResetLowest t2 on t1.CustID = t2.CustID and t1.roleID = 1
where t1.StakeLevelList_Allbet = '' or t1. StakeLevelList_Allbet is null	

select ci.custid,ci.roleid,ci.username, ci.mrecommend,ci.srecommend,ci.SyncLiveCasino,ci.Enabled,c.site,ci.Closed 
from custinfo ci (nolock)  
	inner join customer c (nolock) on ci.custid = c.custid
where ci.custid in (28142,28142,12040,28142,2,30676,31216,36034,15622)
order by ci.roleid desc 

DROP TABLE #CustList_ResetLowest
DROP TABLE #CodeCurrency
DROP TABLE #ExchangeIDListPerCurrency
DROP TABLE #StakeLevel_PreMapping
DROP TABLE #Supers
DROP TABLE #tmpStakeLevelMapping_DuplicateProcess
*/