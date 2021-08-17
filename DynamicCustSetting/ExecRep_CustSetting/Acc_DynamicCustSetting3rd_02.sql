/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_02]
	@CustID		INT,
	@RoleID		INT,
	@StakeLevel	VARCHAR(MAX) = NULL,
	@BetLimit	VARCHAR(MAX) = NULL,
	@Mode		VARCHAR(20) = 'StakeLevel'
AS
/*
	Created: 20160121@Billy
	Task : Update Customer's Stake Level Settings - [Redmine: #51026]
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20161005@Elodie: Update LastUpdated field - [Redmine: #54994]
		- 20210727@Elodie: Adjust downline's betsetting [Redmine: #158073]
	Param's Explanation:
		@StakeLevel:
		<ROOT>
				<StakeLevel 
						CustID="12345"
						BetType="2401" 
						StakeLevelList="1,2,3,4,5"
				/>
		</ROOT>
*/
BEGIN
	SET NOCOUNT ON
	DECLARE	@iDoc INT, @BatchNo INT, @SportbettypeCount INT
	DECLARE @NewMinBet MONEY, @NewMaxBet MONEY, @NewMaxPerMatch	MONEY, @NewMaxPerNumber MONEY
	CREATE TABLE #Agent(custid INT, RoleID INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid INT)
	CREATE TABLE #MemberTmpBatch(custid INT)

	IF @Mode = 'StakeLevel'
	BEGIN
		IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0
			RETURN
		IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0
			RETURN

		CREATE TABLE #StakeLevel (
				CustID			INT
			,	BetType			INT
			,	StakeLevelList	VARCHAR(200)
			,	PRIMARY KEY CLUSTERED (CustID, BetType)
		)

		-- Read XML
		EXECUTE sys.sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel

		INSERT INTO	#StakeLevel
			(	CustID   , BetType   , StakeLevelList)
		SELECT	ox.CustID, ox.BetType, ox.StakeLevelList
		FROM	OPENXML(@iDoc, '/ROOT/StakeLevel', 1)
				WITH (
					CustID			INT
				,	BetType			INT
				,	StakeLevelList	VARCHAR(200)
				) AS ox

		EXECUTE sys.sp_xml_removedocument @iDoc

		UPDATE csla
		SET	csla.StakeLevelList = sl.StakeLevelList
		FROM		dbo.CustStakeLevel_Agent AS csla WITH(ROWLOCK,UPDLOCK)
		INNER JOIN	#StakeLevel AS sl
				ON	sl.CustID  = csla.CustID
				AND	sl.BetType = csla.BetType

		UPDATE cslm
		SET	cslm.StakeLevelList = sl.StakeLevelList
			, cslm.LastUpdated = GETDATE()
		FROM		dbo.CustStakeLevel_Member AS cslm WITH(ROWLOCK,UPDLOCK)
		INNER JOIN	#StakeLevel AS sl
				ON	sl.CustID = cslm.CustID
				AND	sl.BetType = cslm.BetType

		DROP TABLE #StakeLevel
	END
	ELSE IF @Mode = 'BetSetting'
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN
		
		DECLARE @NewBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, IsSpecial			BIT
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewBetLimitTbl
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CAST(MaxPerMatch AS MONEY) AS MaxPerMatch,
			0 AS IsSpecial
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15), MaxPerMatch VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewBetLimitTbl

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

		--Updating upline to 0/0.1/0.1/0.1 shall update downlines to 0/0.1/0.1/0.1
		UPDATE @NewBetLimitTbl SET IsSpecial = 1 WHERE MinBet = 0 AND MaxBet < 1 AND MaxPerMatch < 1

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

		IF @RoleID=4
		BEGIN
			--downline_master_maxbet = min (downline_master_maxbet, @NEW_MAXBET)
			--downline_master_maxpermatch = min (downline_master_maxpermatch, @NEW_MAXPERMATCH)
			--downline_master_minbet = min (downline_master_minbet, @NEW_MAXBET)
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE bsm
				SET
					@NewMinBet = bsm.MinBet,
					@NewMaxBet = bsm.MaxBet,
					@NewMaxPerMatch = bsm.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsm.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 0 AND fil.MaxPerMatch < bsm.MaxPerMatch THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 1 THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet,
					bsm.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewBetLimitTbl fil ON bsm.sporttype = fil.sporttype AND bsm.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_maxpermatch = min (downline_agent_maxpermatch, @NEW_MAXPERMATCH)
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)			
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@ROWCOUNT = 0 
					BREAK;				
			
				UPDATE bsa
				SET
					@NewMinBet = bsa.MinBet,
					@NewMaxBet = bsa.MaxBet,
					@NewMaxPerMatch = bsa.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsa.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 0 AND fil.MaxPerMatch < bsa.MaxPerMatch THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 1 THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet,
					bsa.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimitTbl fil ON bsa.sporttype = fil.sporttype AND bsa.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid		
			END									
		END
		
		IF @RoleId IN (2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_maxpermatch = min (downline_member_maxpermatch, @NEW_MAXPERMATCH)
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)		
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;
										
				UPDATE bsmem
				SET
					@NewMinBet = bsmem.MinBet,
					@NewMaxBet = bsmem.MaxBet,
					@NewMaxPerMatch = bsmem.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsmem.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 0 AND fil.MaxPerMatch < bsmem.MaxPerMatch THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerMatch = CASE WHEN IsSpecial = 1 THEN fil.MaxPerMatch ELSE @NewMaxPerMatch END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet,
					bsmem.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimitTbl fil ON bsmem.sporttype = fil.sporttype AND bsmem.bettype = fil.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid												  
		END
	END
	END
	ELSE IF @Mode = 'GameBetLimit'
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN

		DECLARE @NewGameBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerNumber		MONEY
			, IsSpecial			BIT
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewGameBetLimitTbl
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CAST(MaxPerNumber AS MONEY) AS MaxPerNumber,
			0 AS IsSpecial
		FROM OPENXML (@iDoc, '/ROOT/GameBetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15), MaxPerNumber VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewGameBetLimitTbl

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

		--Updating upline to 0/0.1/0.1/0.1 shall update downlines to 0/0.1/0.1/0.1
		UPDATE @NewGameBetLimitTbl SET IsSpecial = 1 WHERE MinBet = 0 AND MaxBet < 1 AND MaxPerNumber < 1

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

		IF @RoleID=4
		BEGIN
			--downline_master_maxbet = min (downline_master_maxbet, @NEW_MAXBET)
			--downline_master_maxpernumber = min (downline_master_maxpernumber, @NEW_MAXPERNUMBER)
			--downline_master_minbet = min (downline_master_minbet, @NEW_MAXBET)
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE bsm
				SET
					@NewMinBet = bsm.MinBet,
					@NewMaxBet = bsm.MaxBet,
					@NewMaxPerNumber = bsm.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsm.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 0 AND fil.MaxPerNumber < bsm.MaxPerMatch THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 1 THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet,
					bsm.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewGameBetLimitTbl fil ON bsm.sporttype = fil.sporttype AND bsm.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_maxpermatch = min (downline_agent_maxpermatch, @NEW_MAXPERMATCH)
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)				
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@ROWCOUNT = 0 
					BREAK;		
								
				UPDATE bsa
				SET
					@NewMinBet = bsa.MinBet,
					@NewMaxBet = bsa.MaxBet,
					@NewMaxPerNumber = bsa.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsa.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 0 AND fil.MaxPerNumber < bsa.MaxPerMatch THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 1 THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet,
					bsa.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewGameBetLimitTbl fil ON bsa.sporttype = fil.sporttype AND bsa.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid											  
			END
		END
		
		IF @RoleID IN(2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_maxpermatch = min (downline_member_maxpermatch, @NEW_MAXPERMATCH)
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)		
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;
												
				UPDATE bsmem
				SET
					@NewMinBet = bsmem.MinBet,
					@NewMaxBet = bsmem.MaxBet,
					@NewMaxPerNumber = bsmem.MaxPerMatch,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsmem.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 0 AND fil.MaxPerNumber < bsmem.MaxPerMatch THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMaxPerNumber = CASE WHEN IsSpecial = 1 THEN fil.MaxPerNumber ELSE @NewMaxPerNumber END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet,
					bsmem.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewGameBetLimitTbl fil ON bsmem.sporttype = fil.sporttype AND bsmem.bettype = fil.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid
			END
		END
	END
	ELSE IF @Mode = 'GameBetSetting'
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN
		
		DECLARE @NewGameBetSetting TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, IsSpecial			BIT
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewGameBetSetting
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			0 AS IsSpecial
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewGameBetSetting

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

		--Updating upline to 0/0.1/0.1/0.1 shall update downlines to 0/0.1/0.1/0.1
		UPDATE @NewGameBetSetting SET IsSpecial = 1 WHERE MinBet = 0 AND MaxBet < 1

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

		IF @RoleID=4
		BEGIN
			--downline_master_maxbet = min (downline_master_maxbet, @NEW_MAXBET)
			--downline_master_minbet = min (downline_master_minbet, @NEW_MAXBET)
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE bsm
				SET
					@NewMinBet = bsm.MinBet,
					@NewMaxBet = bsm.MaxBet,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsm.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting fil ON bsm.sporttype = fil.sporttype AND bsm.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END												 
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)		
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@ROWCOUNT = 0 
					BREAK;		
										
				UPDATE bsa
				SET
					@NewMinBet = bsa.MinBet,
					@NewMaxBet = bsa.MaxBet,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsa.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting fil ON bsa.sporttype = fil.sporttype AND bsa.bettype = fil.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid
			END											 
		END
		
		IF @RoleID IN (2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTmpBatch
				DELETE TOP (@BatchNo) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;
														
				UPDATE bsmem
				SET
					@NewMinBet = bsmem.MinBet,
					@NewMaxBet = bsmem.MaxBet,
					@NewMaxBet = CASE WHEN IsSpecial = 0 AND fil.MaxBet < bsmem.MaxBet THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 0 AND @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE @NewMinBet END,
					@NewMaxBet = CASE WHEN IsSpecial = 1 THEN fil.MaxBet ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN IsSpecial = 1 THEN fil.MinBet ELSE @NewMinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting fil ON bsmem.sporttype = fil.sporttype AND bsmem.bettype = fil.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid
				END
			END									  
		END
END