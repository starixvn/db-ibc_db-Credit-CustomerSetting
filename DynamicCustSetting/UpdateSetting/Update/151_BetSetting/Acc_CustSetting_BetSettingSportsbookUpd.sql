/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSettingSportsbookUpd]
	@CustId			INT,
    @RoleId			INT,
	@XML				VARCHAR(MAX) = NULL,
	@GroupType			SMALLINT = 0 ,
	@Mode				VARCHAR(50) = 'SB_BetSetting'
AS
/*
    Created: 20240610@Johnson
    Task : Update sportsbook bet setting 
    DB: DBCust/CustDB
    
    Revisions:
		- 20240610@Johnson: Scale out DBCUST [redmine: #199915]
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Batch_Num INT, @SportbettypeCount INT
	DECLARE @iDoc INT
	CREATE TABLE #Agent(custid int, RoleID INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid int)
	CREATE TABLE #MemberTmpBatch(custid INT)
	
	IF (@GroupType = 151) OR (@Mode = 'SB_BetSetting')
	BEGIN		
		IF ISNULL(@XML,'') = ''
			RETURN

		DECLARE @NewMaxBet MONEY, @NewMaxPerNumber MONEY, @NewMaxPerMatch MONEY, @NewMaxPayoutPerMatch MONEY , @NewMinBet MONEY
		DECLARE @BetSetting TABLE(
				SportType         SMALLINT, 
				BetType           SMALLINT, 
				MinBet            MONEY, 
				MaxBet            MONEY, 
				MaxPerMatch       MONEY, 				
				MaxPayoutPerMatch MONEY
			);
	
		
		--Parse SB Bet Setting from XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @XML

		INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
		SELECT SportType        
			,BetType          
			,MinBet           
			,MaxBet           
			,MaxPerMatch      			
			,MaxPayoutPerMatch
		FROM OPENXML (@iDoc, '/Root/Row',1) 
		WITH (
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 		
			MaxPayoutPerMatch MONEY
		) AS Data

		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM BetSetting_Agent WITH(NOLOCK) WHERE CustID = @CustId

		IF @SportbettypeCount = 0
			SET @SportbettypeCount = 1

		SET @Batch_Num = 2000/@SportbettypeCount

		IF @RoleId = 4
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid IN(2,3) AND Enabled = 1
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid = 1 AND Enabled = 1					
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 2 AND Enabled = 1	
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 1 AND Enabled = 1
		END
		ELSE IF @RoleId = 2
		BEGIN
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE recommend = @CustId AND roleid = 1 AND Enabled = 1
		END
		
		IF @RoleId = 4
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@ROWCOUNT = 0 
					BREAK;

				-- This rule: Update BetSetting for :
				-- Sports of Soccer Call by SP Acc_CustomerUpd_BetSetting
				-- NumberGame & Happy5 Call by SP Acc_CustSetting_BetSetting23Upd
				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType NOT IN (43,44)
				AND ( (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
					OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
					OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)
					)
					
				-- This rule just Update BetSetting for E-Sports & Muay Thai
				UPDATE b
				SET 
					@NewMaxBet = CASE WHEN new.MaxBet < b.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < b.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MinBet = @NewMinBet,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType IN (43,44)
				AND (b.MinBet <> new.MinBet OR b.MaxBet <> new.MaxBet OR b.MaxPerMatch <> new.MaxPerMatch)
			END
		END
		
		IF @RoleId IN (3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@ROWCOUNT = 0 
					BREAK;

				-- This rule: Update BetSetting for :
				-- Sports of Soccer Call by SP Acc_CustomerUpd_BetSetting
				-- NumberGame & Happy5 Call by SP Acc_CustSetting_BetSetting23Upd
				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType NOT IN (43,44)
				AND (
					   (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
					OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
					OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)
				)

				-- This rule just Update BetSetting for E-Sports & Muay Thai
				UPDATE b
				SET 
					@NewMaxBet = CASE WHEN new.MaxBet < b.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < b.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MinBet = @NewMinBet,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType IN (43,44)
				AND (b.MinBet <> new.MinBet OR b.MaxBet <> new.MaxBet OR b.MaxPerMatch <> new.MaxPerMatch)
			END
		END
		
		IF @RoleId IN (2,3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTmpBatch

				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;
				
				-- This rule: Update BetSetting for :
				-- Sports of Soccer Call by SP Acc_CustomerUpd_BetSetting
				-- NumberGame & Happy5 Call by SP Acc_CustSetting_BetSetting23Upd
				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,					
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()				
				FROM dbo.BetSetting_Member b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType NOT IN (43,44)
				AND 
				(		   
						   (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)						
				)

				-- This rule just Update BetSetting for E-Sports & Muay Thai
				UPDATE b
				SET 
					@NewMaxBet = CASE WHEN new.MaxBet < b.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < b.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MinBet = @NewMinBet,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting_Member b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci
						ON b.custid = ci.custid
				WHERE 
				b.SportType IN (43,44)
				AND (b.MinBet <> new.MinBet OR b.MaxBet <> new.MaxBet OR b.MaxPerMatch <> new.MaxPerMatch)
		
			END
		END
		
	END		
END