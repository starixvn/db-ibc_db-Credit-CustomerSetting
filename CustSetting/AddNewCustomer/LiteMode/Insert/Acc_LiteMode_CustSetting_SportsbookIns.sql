/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_SportsbookIns]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,
	@roleid INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	
	--Bet Setting
	@SettingType26 VARCHAR(MAX)= '', --SB
	
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
	
AS
/*
	Created: 20230525@Johnson	
	Scale out DBCUST- add rep in-house tables setting
	DB: DBCUST/custDB
	
	Revisions:
		- 20240607@Johnson: scale out DBCUST [redmine: #199915]
		
*/
BEGIN
	SET NOCOUNT ON;
		
	CREATE TABLE #SportBettypeFilter26 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
	
	DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 			
			MaxPayoutPerMatch MONEY		
			PRIMARY KEY(sporttype, Bettype)
		);
		
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
				T.c.query('.').value('(R/@MaxPayout)[1]', 'money') AS MaxPayoutPerMatch
			FROM  @xml.nodes('/Root/R') T(c)   
		END
				
		BEGIN TRY
			IF @roleid IN (3,2)
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
			SELECT @ErrCode = 26			
				
			IF @roleid > 1
			BEGIN
				DELETE BetSetting_Agent WITH (ROWLOCK)
				OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],SYSDATETIME()
				INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
				WHERE custID = @custid
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE BetSetting_Member WITH (ROWLOCK)
				OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],SYSDATETIME()
				INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
				WHERE custID = @custid
			END
			RETURN	
		END CATCH
END
		
	