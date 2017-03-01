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
	[ExchangeID] [int] NOT NULL, 
	[StakeLevelList_LC] [varchar](100) NULL,
	[StakeLevelList_AllBet] [varchar](100) NULL
 CONSTRAINT [PK_tmpCustGameType] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [CustGameType_table]
) ON [CustGameType_table]

GO

CREATE TABLE #CodeCurrency (ID INT, Currency VARCHAR(1000) )

INSERT INTO #CodeCurrency (ID,Currency)
VALUES (1,'$US, NTD, US$, UT, Yen, IRR, EURO, SD$, GBP'),
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

INSERT INTO [dbo].[tmpCustGameType] ([CustID], [StakeLevelList_LC],[ExchangeID])
SELECT cs.custid, StakeLevelList_LC,ci.currency	
FROM CustGameType_LCS cs WITH(NOLOCK) --DBBingoAdmin.LiveCasinoAdmin.dbo.CustGameType
	INNER JOIN Customer ci WITH(NOLOCK) ON cs.custid = ci.custid
WHERE ci.currency = 20


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

UPDATE T1
	SET StakeLevelList_Allbet = T2.StakeLevelList_Allbet
FROM tmpCustGameType T1
	INNER JOIN #StakeLevel_PreMapping T2 ON T1.ExchangeID = T2.ExchangeID AND T1.StakeLevelList_LC = T2.StakeLevelList_LC
GO

DROP TABLE #CodeCurrency
DROP TABLE #ExchangeIDListPerCurrency
DROP TABLE #StakeLevel_PreMapping
