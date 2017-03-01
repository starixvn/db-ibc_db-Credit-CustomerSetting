/*
	Created: Helen
	Date: 20160824
	Task: Mapping stake level from LCS to AllBet for preparing AllBet settings
	DB: DB06/DBTP/DBMNL/DBCUST@MNL/DB06@MNL	
	
*/ 
------- 2.2 StakeLevel, only run on DB06/DBTP/DBMNL/DBCUST@MNL/DB06@MNL ----------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'tmpStakeLevelMapping' and TYPE = 'U')
    DROP TABLE tmpStakeLevelMapping
GO  

TRUNCATE TABLE tmpStakeLevelMapping
GO

CREATE TABLE [dbo].tmpStakeLevelMapping(
	StakeLevelID_LC INT, GameTypeID INT, MinLabel NVARCHAR(50), MaxLabel NVARCHAR(50), MinStake DECIMAL (19,8), MaxStake DECIMAL (19,8)
	, ExchangeId INT,Currency VARCHAR(100), StakeLevelID_AllBet INT
 CONSTRAINT [PK_tmpStakeLevelMapping] PRIMARY KEY CLUSTERED 
(
	StakeLevelID_LC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [CustGameType_table]
) ON [CustGameType_table]

INSERT INTO tmpStakeLevelMapping (StakeLevelID_LC,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake, StakeLevelID_AllBet)
SELECT StakeLevelID_LC,Currency,ExchangeId,MinLabel,MaxLabel,MinStake,MaxStake, StakeLevelID_AllBet
FROM DBCUST.CUSTDB.tmpStakeLevelMapping WITH (NOLOCK)
------- END OF 2.2 StakeLevel, only run on DB06/DBTP/DBMNL/DBCUST@MNL/DB06@MNL ----------------------------






