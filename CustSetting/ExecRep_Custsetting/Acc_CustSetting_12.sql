/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_12]
	@CustId			INT,
    @RoleId			INT,
	@XML			VARCHAR(MAX) = NULL,
	@Mode			VARCHAR(50)='MaxPayout'
AS
/*
    Created: 20210518@Winfred
    Task : Update Parlay Max Payout 
    DB: DBCust/CustDB
    
    Revisions:
		- 20210518@Winfred: Update Parlay Max Payout for SMA  [RedmineID:#154104]
		- 20210813@Eden: Enhance - Update Parlay Max Payout for downlines by batch  [RedmineID:#160135]
		- 20210816@Eden: Max Payout Per Match [redmine: #158073]
		- 20220516@Tacy: Insert history of member bet setting: Number Game, Happy5 [RedmineID: #170739]
		- 20220716@Tacy: HotFix - Error when update big line NG/Happy5/Keno bet setting [RedmineID: #175836]

    Param's Explanation:
            
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustList	VARCHAR(MAX),
			@ErrMsg		NVARCHAR(MAX)

	DECLARE @Batch_Num INT, @SportbettypeCount INT
	DECLARE @iDoc INT
	CREATE TABLE #Agent(custid int, RoleID INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid int)
	CREATE TABLE #MemberTmpBatch(custid INT)

	CREATE TABLE #History_BetSetting(
				CustID		INT,
				SportType   SMALLINT, 
				BetType     SMALLINT, 
				MaxBet      MONEY, 
				MaxPerMatch	MONEY, 
				UpdateTime	DATETIME
			)

    -- check existing tables
	IF (@Mode='MaxPayout')
	BEGIN
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 0 RETURN
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 0 RETURN
		IF dbo.f_CheckRepTable('MaxPayoutGlobalSetting') = 0 RETURN
		
		DECLARE @NewMaxPayoutTbl TABLE (
				  SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)
		IF @XML IS NULL OR @XML='' RETURN
		
		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT
			, @XML

		INSERT @NewMaxPayoutTbl (SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
		FROM OPENXML(@iDoc, '/ROOT/MaxPayoutLimit', 1) WITH (
				SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)

		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM CustMaxPayoutSetting_Agent WITH(NOLOCK) WHERE CustID = @CustId

		IF @SportbettypeCount = 0
			SET @SportbettypeCount = 1

		SET @Batch_Num = 5000/@SportbettypeCount

		IF @RoleId = 4
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid IN(2,3)	
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid = 1					
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 2	
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 1
		END
		ELSE IF @RoleId = 2
		BEGIN
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE recommend = @CustId AND roleid = 1
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

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
				FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #AgentTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
						) 
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

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
				FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #AgentTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
						) 
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

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
				FROM dbo.CustMaxPayoutSetting_Member mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #MemberTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 > tmp.ComboOver6)) 
						) 
			END
		END
	END
	ELSE IF (@Mode='SB_BetSetting')
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting_Agent') = 0 RETURN
		IF dbo.f_CheckRepTable('CustBetSetting_Member') = 0 RETURN
		
		IF ISNULL(@XML,'') = ''
			RETURN

		DECLARE @NewMaxBet MONEY, @NewMaxPerNumber MONEY, @NewMaxPerMatch MONEY, @NewMaxPayoutPerMatch MONEY
		DECLARE @BetSetting TABLE(
				SportType         SMALLINT, 
				BetType           SMALLINT, 
				MinBet            MONEY, 
				MaxBet            MONEY, 
				MaxPerMatch       MONEY, 
				MaxPerNumber      MONEY, 
				MaxPayoutPerMatch MONEY
			);

		--Parse SB Bet Setting from XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @XML

		INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT SportType        
			,BetType          
			,MinBet           
			,MaxBet           
			,MaxPerMatch      
			,MaxPerNumber     
			,MaxPayoutPerMatch
		FROM OPENXML (@iDoc, '/Root/Row',1) 
		WITH (
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY, 
			MaxPayoutPerMatch MONEY
		) AS Data

		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM CustBetSetting_Agent WITH(NOLOCK) WHERE CustID = @CustId

		IF @SportbettypeCount = 0
			SET @SportbettypeCount = 1

		SET @Batch_Num = 5000/@SportbettypeCount

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

		--downline_maxbet = min (downline_maxbet, @NEW_MAXBET,@NEW_MAXPERMATCH,@NEW_MAXPERBALL)
		--downline_maxpermatch = min (downline_maxpermatch, @NEW_MAXPERMATCH,@NEW_MAXPAYOUTPERMATCH)
		--downline_maxpayoutpermatch = min (downline_maxpayoutpermatch, @NEW_MAXPAYOUTPERMATCH)
		--downline_maxperball = min (downline_maxperball, @NEW_MAXPERBALL,@NEW_MAXPERMATCH)
		--downline_minbet = min (downline_minbet, @NEW_MAXBET)

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

				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch
				FROM dbo.CustBetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE ( (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0))
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

				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch
				FROM dbo.CustBetSetting_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci
						ON b.custid = ci.custid
				WHERE ( (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0))
			END
		END

		IF @RoleId IN (2,3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #History_BetSetting
				TRUNCATE TABLE #MemberTmpBatch

				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					@NewMaxPayoutPerMatch = CASE WHEN (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0) THEN new.MaxPayoutPerMatch ELSE b.MaxPayoutPerMatch END,
					--
					@NewMaxPerMatch = CASE WHEN @NewMaxPerMatch > @NewMaxPayoutPerMatch THEN @NewMaxPayoutPerMatch ELSE @NewMaxPerMatch END,
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.MaxPayoutPerMatch = @NewMaxPayoutPerMatch
				OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
					INTO #History_BetSetting
				FROM dbo.CustBetSetting_Member b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting new ON b.sporttype = new.sporttype AND b.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci
						ON b.custid = ci.custid
				WHERE ( (b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPayoutPerMatch > new.MaxPayoutPerMatch AND new.MaxPayoutPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0))

				--Insert history bet setting
				DELETE hbs
				FROM #History_BetSetting hbs
					INNER JOIN @BetSetting bs ON bs.SportType=hbs.SportType
												AND bs.BetType=hbs.BetType
				WHERE hbs.SportType NOT IN (161, 164) OR
					(bs.MaxBet=hbs.MaxBet
						AND bs.MaxPerMatch=hbs.MaxPerMatch)

				IF EXISTS (SELECT 1 FROM #History_BetSetting)
				BEGIN
					SET @CustList = (SELECT CustID		AS '@CustID',
											SportType	AS '@SportType',
											BetType		AS '@BetType',
											MaxBet		AS '@MaxBet',
											MaxPerMatch	AS '@MaxPerMatch',
											'NULL'		AS '@StakeLevelList',
											UpdateTime	AS '@UpdateTime'
									 FROM #History_BetSetting
									 FOR XML PATH ('r'), ROOT ('root')
									 )

					EXECUTE Acc_DynamicCustSetting3rd_08 @CustList=@CustList, @ErrMsg = @ErrMsg OUTPUT;

					IF @ErrMsg <> ''
						RETURN
				END
			END
		END
	END

	DROP TABLE #Agent
	DROP TABLE #AgentTmpBatch
	DROP TABLE #Member
	DROP TABLE #MemberTmpBatch
	DROP TABLE #History_BetSetting
END