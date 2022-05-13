/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet" viewers="" isFunction="0" isNested="1"></info>*/
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
		- 20220511@Tacy: Insert history of member bet setting [RedmineID: #170739]

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
	DECLARE @CustList VARCHAR(MAX), @ErrMsg VARCHAR(MAX)
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
	ELSE IF @Mode = 'BetSetting' -- Acc_CustSetting_BetLimitUpd settingtype 2
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN
		
		DECLARE @NewBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	into @NewBetLimitTbl
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewBetLimitTbl
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CAST(MaxPerMatch AS MONEY) AS MaxPerMatch
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15), MaxPerMatch VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewBetLimitTbl

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

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
			--downline_master_maxbet = min (@NEW_MAXPERMATCH, downline_master_maxbet)
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsm.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsm.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsm.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsm.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE bsm.MinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet,
					bsm.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewBetLimitTbl new ON bsm.sporttype = new.sporttype AND bsm.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_maxpermatch = min (downline_agent_maxpermatch, @NEW_MAXPERMATCH)
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)		
			--downline_agent_maxbet = min (@NEW_MAXPERMATCH, downline_agent_maxbet)	
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsa.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsa.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsa.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsa.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE bsa.MinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet,
					bsa.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimitTbl new ON bsa.sporttype = new.sporttype AND bsa.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid		
			END									
		END
		
		IF @RoleId IN (2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_maxpermatch = min (downline_member_maxpermatch, @NEW_MAXPERMATCH)
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)		
			--downline_member_maxbet = min (@NEW_MAXPERMATCH, downline_member_maxbet)	
			DECLARE @HistoryBetSettingTbl TABLE (
					CustID				INT
					, SportType			SMALLINT
					, BetType			SMALLINT
					, MaxBet			MONEY
					, MaxPerMatch		MONEY
					, UpdateTime		DATETIME
					)

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
					@NewMaxBet = CASE WHEN new.MaxBet < bsmem.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsmem.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsmem.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsmem.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE bsmem.MinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet,
					bsmem.MaxPerMatch = @NewMaxPerMatch
				OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
					INTO @HistoryBetSettingTbl
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimitTbl new ON bsmem.sporttype = new.sporttype AND bsmem.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid
				
				--insert Bet Setting history
				SET @CustList = (SELECT	CustID		AS '@CustID	',
										SportType	AS '@SportType',
										BetType		AS '@BetType',
										MaxBet		AS '@MaxBet',
										MaxPerMatch	AS '@MaxPerMatch',
										NULL		AS '@StakeLevelList',
										UpdateTime	AS '@UpdateTime'
							FROM @HistoryBetSettingTbl
							FOR XML PATH('r'), ROOT ('root'), TYPE
							)
		
				EXECUTE Task_DetectBet_CustMaxBetHistoryIns @CustList, @ErrMsg = @ErrMsg OUTPUT;

				IF @ErrMsg <> ''
					RETURN

				END
	END
	END
	ELSE IF @Mode = 'GameBetLimit' -- Acc_CustSetting_GameBetLimitUpd settingtype 9
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN

		DECLARE @NewGameBetLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerNumber		MONEY
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewGameBetLimitTbl
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CAST(MaxPerNumber AS MONEY) AS MaxPerNumber
		FROM OPENXML (@iDoc, '/ROOT/GameBetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15), MaxPerNumber VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewGameBetLimitTbl

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

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
			--downline_master_maxbet = min (@NEW_MAXPERNUMBER, downline_master_maxbet)
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsm.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsm.MaxBet END,
					@NewMaxPerNumber = CASE WHEN new.MaxPerNumber < bsm.MaxPerMatch AND new.MaxPerNumber > 0 THEN new.MaxPerNumber ELSE bsm.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerNumber < @NewMaxBet THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE bsm.MinBet END,				
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet,
					bsm.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewGameBetLimitTbl new ON bsm.sporttype = new.sporttype AND bsm.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_maxpermatch = min (downline_agent_maxpermatch, @NEW_MAXPERMATCH)
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)		
			--downline_agent_maxbet = min (@NEW_MAXPERMATCH, downline_agent_maxbet)			
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsa.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsa.MaxBet END,
					@NewMaxPerNumber = CASE WHEN new.MaxPerNumber < bsa.MaxPerMatch AND new.MaxPerNumber > 0 THEN new.MaxPerNumber ELSE bsa.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerNumber < @NewMaxBet THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE bsa.MinBet END,	
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet,
					bsa.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewGameBetLimitTbl new ON bsa.sporttype = new.sporttype AND bsa.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid											  
			END
		END
		
		IF @RoleID IN(2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_maxpermatch = min (downline_member_maxpermatch, @NEW_MAXPERMATCH)
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)	
			--downline_member_maxbet = min (@NEW_MAXPERMATCH, downline_member_maxbet)		
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsmem.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsmem.MaxBet END,
					@NewMaxPerNumber = CASE WHEN new.MaxPerNumber < bsmem.MaxPerMatch AND new.MaxPerNumber > 0 THEN new.MaxPerNumber ELSE bsmem.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerNumber < @NewMaxBet THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE bsmem.MinBet END,	
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet,
					bsmem.MaxPerMatch = @NewMaxPerNumber
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewGameBetLimitTbl new ON bsmem.sporttype = new.sporttype AND bsmem.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid
			END
		END
	END
	ELSE IF @Mode = 'GameBetSetting' -- Acc_CustSetting_GameBetSettingUpd settingtype 20
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN
		
		DECLARE @NewGameBetSetting TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewGameBetSetting
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewGameBetSetting

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

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
					@NewMaxBet = CASE WHEN new.MaxBet < bsm.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsm.MaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE bsm.MinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting new ON bsm.sporttype = new.sporttype AND bsm.bettype = new.bettype
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsa.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsa.MaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE bsa.MinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting new ON bsa.sporttype = new.sporttype AND bsa.bettype = new.bettype
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsmem.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsmem.MaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE bsmem.MinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK)
					INNER JOIN @NewGameBetSetting new ON bsmem.sporttype = new.sporttype AND bsmem.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid
			END
		END									  
	END
	ELSE IF @Mode = 'BetSetting16' -- Acc_CustSetting_BetSettingUpd settingtype 16
	BEGIN
		IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 OR dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0
			RETURN
		
		DECLARE @NewBetLimit16Tbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
		)

		IF @BetLimit IS NULL OR @BetLimit='' RETURN

		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit
	
		INSERT @NewBetLimit16Tbl
		SELECT SportType,BetType,
			CAST(MinBet AS MONEY) AS MinBet,
			CAST(MaxBet AS MONEY) AS MaxBet,
			CAST(MaxPerMatch AS MONEY) AS MaxPerMatch
		FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MinBet VARCHAR(15), MaxBet VARCHAR(15), MaxPerMatch VARCHAR(15))	
	
		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM @NewBetLimit16Tbl

		IF @SportbettypeCount = 0
			RETURN

		SET @BatchNo = 5000/@SportbettypeCount

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
			--downline_master_maxbet = min (@NEW_MAXPERMATCH, downline_master_maxbet)
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsm.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsm.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsm.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsm.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsm.MinBet THEN @NewMaxBet ELSE bsm.MinBet END,
					bsm.MinBet = @NewMinBet,
					bsm.MaxBet = @NewMaxBet,
					bsm.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsm WITH(ROWLOCK)
					INNER JOIN @NewBetLimit16Tbl new ON bsm.sporttype = new.sporttype AND bsm.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsm.custid = ci.custid
			END
		END
		
		IF @RoleID IN (3,4)
		BEGIN
			--downline_agent_maxbet = min (downline_agent_maxbet, @NEW_MAXBET)		
			--downline_agent_maxpermatch = min (downline_agent_maxpermatch, @NEW_MAXPERMATCH)
			--downline_agent_minbet = min (downline_agent_minbet, @NEW_MAXBET)		
			--downline_agent_maxbet = min (@NEW_MAXPERMATCH, downline_agent_maxbet)	
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsa.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsa.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsa.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsa.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsa.MinBet THEN @NewMaxBet ELSE bsa.MinBet END,
					bsa.MinBet = @NewMinBet,
					bsa.MaxBet = @NewMaxBet,
					bsa.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent bsa WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimit16Tbl new ON bsa.sporttype = new.sporttype AND bsa.bettype = new.bettype
					INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON bsa.custid = ci.custid		
			END									
		END
		
		IF @RoleId IN (2,3,4)
		BEGIN
			--downline_member_maxbet = min (downline_member_maxbet, @NEW_MAXBET)		
			--downline_member_maxpermatch = min (downline_member_maxpermatch, @NEW_MAXPERMATCH)
			--downline_member_minbet = min (downline_member_minbet, @NEW_MAXBET)		
			--downline_member_maxbet = min (@NEW_MAXPERMATCH, downline_member_maxbet)	
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
					@NewMaxBet = CASE WHEN new.MaxBet < bsmem.MaxBet AND new.MaxBet > 0 THEN new.MaxBet ELSE bsmem.MaxBet END,
					@NewMaxPerMatch = CASE WHEN new.MaxPerMatch < bsmem.MaxPerMatch AND new.MaxPerMatch > 0 THEN new.MaxPerMatch ELSE bsmem.MaxPerMatch END,
					@NewMaxBet = CASE WHEN @NewMaxPerMatch < @NewMaxBet THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMinBet = CASE WHEN @NewMaxBet < bsmem.MinBet THEN @NewMaxBet ELSE bsmem.MinBet END,
					bsmem.MinBet = @NewMinBet,
					bsmem.MaxBet = @NewMaxBet,
					bsmem.MaxPerMatch = @NewMaxPerMatch
				FROM dbo.CustBetSetting3rd_Member bsmem WITH(ROWLOCK, UPDLOCK)
					INNER JOIN @NewBetLimit16Tbl new ON bsmem.sporttype = new.sporttype AND bsmem.bettype = new.bettype
					INNER JOIN #MemberTmpBatch ci WITH(NOLOCK) ON bsmem.custid = ci.custid												  
			END
		END
	END
END