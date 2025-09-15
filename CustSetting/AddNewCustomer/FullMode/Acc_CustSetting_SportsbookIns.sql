/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_SportsbookIns]
	@custid INT,
	@roleid TINYINT,
	@siteID SMALLINT=0,
	@currency SMALLINT=0,	
	@SettingType26 VARCHAR(MAX)= '', --Bet Setting
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
AS
/*
	Created: 20240606@Johnson
	Task: Add settings by rep in-house
	DB: DBCUST/CustDB
	
	Revisions:
		- 20240606@Johnson: Scale out dbcust [redmine:#199915]
		- 20250915@Johnson: Max Payout Per Match - Change to Max Win [redmine: #236447]	
*/
BEGIN
	SET NOCOUNT ON;
	
	--Bet Setting	
	DECLARE @BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY		
		PRIMARY KEY(sporttype, Bettype)
	);
	CREATE TABLE #SportBettypeFilter26 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)

	INSERT INTO #SportBettypeFilter26(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
	SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (26)

	DECLARE @xml XML 

	IF ISNULL(@SettingType26,'') <> ''
	BEGIN			
		SELECT @xml = CONVERT(XML,@SettingType26)

		INSERT INTO @BetSetting(SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch, 
			MaxPayoutPerMatch)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
			T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
			T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
			T.c.query('.').value('(R/@MaxWin)[1]', 'money') AS MaxPayoutPerMatch
		FROM  @xml.nodes('/Root/R') T(c)   
	END
		
	BEGIN TRY
		IF @roleid IN (4,3,2)
		BEGIN 
			INSERT INTO BetSetting_Agent(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch,RepUpdateTime)
			SELECT @custid
				,cs.SportType        
				,cs.BetType          
				,MinBet           
				,MaxBet           
				,MaxPerMatch     				    
				,MaxPayoutPerMatch
				,SYSDATETIME()
			FROM @BetSetting cs
				INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		END
		ELSE IF @roleid = 1
		BEGIN
			INSERT INTO BetSetting_Member(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch,RepUpdateTime)
			SELECT @custid
				,cs.SportType        
				,cs.BetType          
				,MinBet           
				,MaxBet           
				,MaxPerMatch 
				,MaxPayoutPerMatch
				,SYSDATETIME()
			FROM @BetSetting cs
				INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		END
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100
		
		IF @roleid IN (4,3,2)
		BEGIN 
			DELETE BetSetting_Agent WITH (ROWLOCK)
			OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],SYSDATETIME()
			INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
			WHERE custID = @custid
		END
		ELSE IF @roleid IN (1)
		BEGIN 
			DELETE BetSetting_Member WITH (ROWLOCK)
			OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],SYSDATETIME()
			INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
			WHERE custID = @custid
		END
	END CATCH 	
END	