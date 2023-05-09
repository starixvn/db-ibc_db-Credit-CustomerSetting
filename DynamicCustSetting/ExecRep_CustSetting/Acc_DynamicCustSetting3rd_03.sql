/*<info serverAlias="DBCust-CustDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_03]
	 @DirectCustID INT
	,@Maxcustid INT
	,@Target VARCHAR(20)
	,@XMLConfig VARCHAR(MAX) = NULL
	,@StepID TINYINT = 0
AS
/*
	Created: 20210716@Eden
	Task : Flexible Initializing Customer Setting
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20210716@Eden: Flexible Initializing Customer Setting - [Redmine: #156667]
		- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]

	Param's Explanation:
		@StepID = :
			1: Delete existing customer setting
			2: Insert customer setting
*/
BEGIN
	SET NOCOUNT ON;
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME IN ('DBCUST','SITDBCUST','TESTDBCUST','DB-60\DevDBcust','DBSPARE','DBBACKUP2')) RETURN -- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME NOT IN ('DBCUST','SITDBCUST','TESTDBCUST','DB-60\DevDBcust','DBSPARE','DBBACKUP2')) RETURN -- run at dbcust only

	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('Customer') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('StakeLevel') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('ProductSettingDetail') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting_Member') = 0 RETURN


	CREATE TABLE #TempConfig(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SettingType] [tinyint],
		[IsDefault] [bit],
		[CopyFromSportType] [smallint],
		[CopyFromBetType] [smallint],
		[DefaultValueSuper] [decimal](11,8),
		[DefaultValueMaster] [decimal](11,8),
		[DefaultValueAgent] [decimal](11,8),
		[DefaultValueMember] [decimal](11,8),
		[SpecialRequirement] [varchar](MAX),
		[SettingName] [varchar](30),
		[ProductID] [TINYINT],
		[HaveWinLimit] BIT, -- 0 : Only Loss Limit
		[HaveMaxPerMatch] BIT, -- 0: Not use MaxPerMatch
		[HaveMaxPerNumber] BIT -- 0: Not use HaveMaxPerNumber
	)
	
	DECLARE @DocHandler INT	
	IF ISNULL(@XMLConfig,'') <> ''
	BEGIN
		-- For read xml					
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @XMLConfig
		INSERT INTO #TempConfig (
			 SportType
			,BetType
			,IsLive
			,SettingType
			,IsDefault
			,CopyFromSportType
			,CopyFromBetType
			,DefaultValueSuper
			,DefaultValueMaster
			,DefaultValueAgent
			,DefaultValueMember
			,SpecialRequirement
			,SettingName
		)
		SELECT Data.SportType
			,Data.BetType
			,Data.IsLive
			,Data.SettingType
			,Data.IsDefault
			,Data.CopyFromSportType
			,Data.CopyFromBetType
			,Data.DefaultValueSuper
			,Data.DefaultValueMaster
			,Data.DefaultValueAgent
			,Data.DefaultValueMember
			,Data.SpecialRequirement
			,Data.SettingName
		FROM OPENXML (@DocHandler, '/ROOT/R',1) 
		WITH (
			[SportType] [smallint],
			[BetType] [smallint],
			[IsLive] [bit],
			[SettingType] [tinyint],
			[IsDefault] [bit],
			[CopyFromSportType] [smallint],
			[CopyFromBetType] [smallint],
			[DefaultValueSuper] [decimal](11,8),
			[DefaultValueMaster] [decimal](11,8),
			[DefaultValueAgent] [decimal](11,8),
			[DefaultValueMember] [decimal](11,8),
			[SpecialRequirement] [varchar](MAX),
			[SettingName] [varchar](30)
		) AS Data

		EXEC sp_xml_removedocument @DocHandler
		-- end read xml	
	END	
	
	UPDATE t
	SET t.SettingName = 'Bet Setting Game',
		t.HaveMaxPerMatch = 1,
		t.HaveMaxPerNumber = CASE WHEN t.SportType = 161 THEN 1 ELSE 0 END
	FROM #TempConfig t
		INNER JOIN ProductSettingDetail p WITH(NOLOCK) 
			ON t.SportType = p.SportType AND t.BetType = p.BetType
	WHERE t.SettingName = 'Bet Setting'
		AND p.SettingType IN (23)
		AND p.SubType = 2

	-->don't set Max per match for settingtype 20
	UPDATE t
	SET t.HaveMaxPerMatch = CASE WHEN t.SettingType = 20 THEN 0 ELSE 1 END
	FROM #TempConfig t
	WHERE t.SettingName = 'Bet Setting'

	-->don't set Win Limit for settingtype 12
	UPDATE t
	SET t.HaveWinLimit = CASE WHEN t.SettingType = 12 THEN 0 ELSE 1 END,
		t.DefaultValueSuper = CASE WHEN t.SettingType = 12 THEN NULL ELSE t.DefaultValueSuper END
	FROM #TempConfig t
	WHERE t.SettingName = 'Win Loss Limit'

	UPDATE t
	SET t.ProductID = p.ProductID
	FROM #TempConfig t WITH(NOLOCK)
		INNER JOIN ProductSettingDetail p WITH(NOLOCK) 
			ON t.SportType = p.SportType AND t.BetType = p.BetType
	
	CREATE TABLE #MemberTemp(CustID INT PRIMARY KEY CLUSTERED, srecommend INT, mrecommend INT, recommend INT, IsFinished BIT DEFAULT 0)
	CREATE TABLE #MemberTemp_Batch(CustID INT PRIMARY KEY CLUSTERED, srecommend INT, mrecommend INT, recommend INT)
	CREATE TABLE #SMATemp(CustID INT PRIMARY KEY CLUSTERED, roleid TINYINT)
	CREATE TABLE #CustSettingTmp(CustID INT, Sporttype SMALLINT, Bettype SMALLINT,IsLive BIT)
	CREATE TABLE #CustSettingTmpBatch(CustID INT, Sporttype SMALLINT, Bettype SMALLINT,IsLive BIT)
	CREATE TABLE #tmpSTList (Sporttype INT, BettypeID INT, StakeLevelList VARCHAR(500),Min_StakeLevel VARCHAR(10))
	CREATE TABLE #DummyAcc(custid INT PRIMARY KEY, RoleID INT)

	DECLARE @DirectCustRoleID TINYINT
	DECLARE @DummySuper INT, @DummyMaster INT, @DummyAgent INT

	--> Get Dummy uplines if they are enabled (need to be initialized setting)
	SELECT  @DirectCustRoleID = c.roleid,
			@DummySuper = CASE WHEN c.roleid IN(1,2,3) AND up.roleid = 4 THEN up.custid ELSE @DummySuper END,
			@DummyMaster = CASE WHEN c.roleid IN(1,2) AND up.roleid = 3 THEN up.custid ELSE @DummyMaster END,
			@DummyAgent = CASE WHEN c.roleid = 1 AND up.roleid = 2 THEN up.custid ELSE @DummyAgent END
	FROM custInfo c WITH(NOLOCK) 
		INNER JOIN custinfo Up WITH(NOLOCK) 
			ON up.custID IN (c.srecommend,c.mrecommend,c.recommend) 
			AND up.Enabled = 1
	WHERE c.custid = @DirectCustID

	INSERT INTO #DummyAcc(custid,RoleID)
	SELECT @DummySuper, 4 WHERE @DummySuper IS NOT NULL UNION ALL
	SELECT @DummyMaster, 3 WHERE @DummyMaster IS NOT NULL UNION ALL
	SELECT @DummyAgent, 2 WHERE @DummyAgent IS NOT NULL
	
	IF @DirectCustRoleID = 4
	BEGIN
		INSERT INTO #MemberTemp (CustID,srecommend,mrecommend,recommend)
		SELECT custid,srecommend,mrecommend,recommend
		FROM Custinfo WITH (NOLOCK)
		WHERE srecommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE srecommend = @DirectCustID AND roleid IN (2,3,4) AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 3
	BEGIN
		INSERT INTO #MemberTemp (CustID,srecommend,mrecommend,recommend)
		SELECT custid,srecommend,mrecommend,recommend
		FROM Custinfo WITH (NOLOCK)
		WHERE mrecommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE mrecommend = @DirectCustID AND roleid IN (2,3) AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 2
	BEGIN
		INSERT INTO #MemberTemp (CustID,srecommend,mrecommend,recommend)
		SELECT custid,srecommend,mrecommend,recommend
		FROM Custinfo WITH (NOLOCK)
		WHERE recommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE recommend = @DirectCustID AND roleid = 2 AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 1
	BEGIN
		INSERT INTO #MemberTemp (CustID,srecommend,mrecommend,recommend)
		SELECT custid,srecommend,mrecommend,recommend
		FROM Custinfo WITH (NOLOCK)
		WHERE custid = @DirectCustID AND roleid = 1 AND Enabled = 1 AND custid <= @maxcustid
	END

	DECLARE @currency INT, @CurrentDTS DATETIME = GETDATE()
	DECLARE @BatchNum INT = 5000
	DECLARE @SportBettypeCount INT
	DECLARE @BatchNum_Ins INT

	SELECT @SportBettypeCount = COUNT (1) 
	FROM (SELECT DISTINCT SportType,bettype,IsLive FROM #TempConfig) t

	SELECT @BatchNum_Ins = @BatchNum/@SportBettypeCount --Max row for each insert batch  <= @BatchNum

	SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @DirectCustID

	IF @StepID = 1 --Delete existing customer setting
	BEGIN
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Position Taking')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype,IsLive)
			SELECT s.CustID,s.SportType,s.BetType,s.IsLive
			FROM CustPTSetting3rd_Agent s WITH(NOLOCK)
				INNER JOIN #TempConfig t 
					ON s.SportType = t.SportType 
					AND s.BetType = t.BetType 
					AND s.IsLive = t.IsLive
				INNER JOIN #SMATemp m 
					ON s.CustID = m.CustID
			WHERE t.SettingName = 'Position Taking' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
					,deleted.IsLive 
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype,IsLive)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustPTSetting3rd_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
						AND s.IsLive = t.IsLive
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype,IsLive)
			SELECT s.CustID,s.SportType,s.BetType,s.IsLive
			FROM CustPTSetting3rd_Member s WITH(NOLOCK)
				INNER JOIN #TempConfig t 
					ON s.SportType = t.SportType 
					AND s.BetType = t.BetType 
					AND s.IsLive = t.IsLive
				INNER JOIN #MemberTemp m 
					ON s.CustID = m.CustID
			WHERE t.SettingName = 'Position Taking'

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
					,deleted.IsLive 
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype,IsLive)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustPTSetting3rd_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
						AND s.IsLive = t.IsLive
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype,IsLive)
			SELECT s.AgentID,s.SportType,s.BetType,s.IsLive
			FROM CustPTGroupSetting3rd_Member s WITH(NOLOCK)
				INNER JOIN #TempConfig t 
					ON s.SportType = t.SportType 
					AND s.BetType = t.BetType 
					AND s.IsLive = t.IsLive
				INNER JOIN #SMATemp m 
					ON s.AgentID = m.CustID
					AND m.roleid = 2
			WHERE t.SettingName = 'Position Taking'

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
					,deleted.IsLive 
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype,IsLive)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustPTGroupSetting3rd_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.AgentID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
						AND s.IsLive = t.IsLive
			END
		END
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustBetSetting3rd_Agent s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #SMATemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Bet Setting' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustBetSetting3rd_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustBetSetting3rd_Member s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #MemberTemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Bet Setting' 

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustBetSetting3rd_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END
		END
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting Game')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustBetSetting_Agent s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #SMATemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Bet Setting Game' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustBetSetting_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustBetSetting_Member s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #MemberTemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Bet Setting Game' 

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustBetSetting_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END
		END
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustDiscount3rd_Agent s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #SMATemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Commission' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustDiscount3rd_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustDiscount3rd_Member s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #MemberTemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Commission' 

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustDiscount3rd_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END
		END
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustWinLossLimit_Agent s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #SMATemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Win Loss Limit' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustWinLossLimit_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustWinLossLimit_Member s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #MemberTemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Win Loss Limit' 

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustWinLossLimit_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END
		END
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Stake Level')
		BEGIN
			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustStakeLevel_Agent s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #SMATemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Stake Level' 

			--Delete Agent Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustStakeLevel_Agent s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END

			INSERT INTO #CustSettingTmp(CustID,Sporttype,Bettype)
			SELECT s.CustID,s.SportType,s.BetType
			FROM CustStakeLevel_Member s WITH(NOLOCK)
					INNER JOIN #TempConfig t 
						ON s.SportType = t.SportType 
						AND s.BetType = t.BetType 
					INNER JOIN #MemberTemp m 
						ON s.CustID = m.CustID
			WHERE t.SettingName = 'Stake Level' 

			--Delete Member Setting
			WHILE 1 = 1
			BEGIN 
				TRUNCATE TABLE #CustSettingTmpBatch

				DELETE TOP(@BatchNum) t
				OUTPUT deleted.custid
					,deleted.Sporttype
					,deleted.Bettype
				INTO #CustSettingTmpBatch(custid,Sporttype,Bettype)
				FROM #CustSettingTmp t

				IF @@ROWCOUNT = 0
					BREAK

				DELETE s
				FROM CustStakeLevel_Member s WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustSettingTmpBatch t 
						ON s.CustID = t.CustID
						AND s.SportType = t.SportType 
						AND s.BetType = t.BetType
			END
		END
	END
	IF @StepID = 2 --Insert customer setting
	BEGIN
		-----------------------PT--------------------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Position Taking' AND IsDefault = 0)
		BEGIN

			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb 
				SET	 SuperPT		=	C.SuperPT
					,MasterPT		=	C.MasterPT
					,AgentPT		=	C.AgentPT
					,IsAutoMasterPT	=	C.IsAutoMasterPT
					,AutoMasterPT	=	C.AutoMasterPT
					,IsAutoSuperPT	=	C.IsAutoSuperPT
					,AutoSuperPT	=	C.AutoSuperPT
					,MinPT			=	C.MinPT
					,MaxPT			=	C.MaxPT
				FROM dbo.CustPTSetting3rd_Agent C WITH(NOLOCK) 
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustPTSetting3rd_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Position Taking'
					 AND t.IsDefault = 0

				INSERT INTO dbo.CustPTSetting3rd_Agent(	
					[CustID]
					,[SportType]
					,[BetType]
					,[IsLive]
					,[SuperPT]
					,[MasterPT]
					,[AgentPT]
					,[IsAutoMasterPT]
					,[AutoMasterPT]
					,[IsAutoSuperPT]
					,[AutoSuperPT]
					,[MinPT]
					,[MaxPT]
				)
				SELECT 
					 C.custid
					,t.SportType
					,t.BetType
					,C.IsLive
					,C.SuperPT
					,C.MasterPT
					,C.AgentPT
					,C.IsAutoMasterPT
					,C.AutoMasterPT
					,C.IsAutoSuperPT
					,C.AutoSuperPT
					,C.MinPT
					,C.MaxPT
				FROM dbo.CustPTSetting3rd_Agent C WITH(NOLOCK) 
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustPTSetting3rd_Agent cb WITH(NOLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Position Taking'
					 AND t.IsDefault = 0
					 AND cb.CustID IS NULL

				--Dummy Agent
				UPDATE cb
				SET  SuperPT			=	C.SuperPT
					,MasterPT			=	C.MasterPT
					,AgentPT			=	C.AgentPT
					,IsAutoMasterPT		=	C.IsAutoMasterPT
					,AutoMasterPT		=	C.AutoMasterPT
					,IsAutoSuperPT		=	C.IsAutoSuperPT
					,AutoSuperPT		=	C.AutoSuperPT
				FROM dbo.CustPTGroupSetting3rd_Member C WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.AgentID AND ci.RoleID = 2
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustPTGroupSetting3rd_Member cb WITH(ROWLOCK,UPDLOCK)
						ON c.AgentID = cb.AgentID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Position Taking'
					 AND t.IsDefault = 0

				INSERT INTO dbo.CustPTGroupSetting3rd_Member(	
					[AgentID]
					,[SportType]
					,[BetType]
					,[IsLive]
					,[SuperPT]
					,[MasterPT]
					,[AgentPT]
					,[IsAutoMasterPT]
					,[AutoMasterPT]
					,[IsAutoSuperPT]
					,[AutoSuperPT]
				)
				SELECT 
					 C.AgentID
					,t.SportType
					,t.BetType
					,C.IsLive
					,C.SuperPT
					,C.MasterPT
					,C.AgentPT
					,C.IsAutoMasterPT
					,C.AutoMasterPT
					,C.IsAutoSuperPT
					,C.AutoSuperPT
				FROM dbo.CustPTGroupSetting3rd_Member C WITH(NOLOCK) 
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.AgentID AND ci.RoleID = 2
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustPTGroupSetting3rd_Member cb WITH(NOLOCK)
						ON c.AgentID = cb.AgentID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Position Taking'
					 AND t.IsDefault = 0
					 AND cb.AgentID IS NULL
			END

			--SMA Level
			INSERT INTO dbo.CustPTSetting3rd_Agent(	
				[CustID]
				,[SportType]
				,[BetType]
				,[IsLive]
				,[SuperPT]
				,[MasterPT]
				,[AgentPT]
				,[IsAutoMasterPT]
				,[AutoMasterPT]
				,[IsAutoSuperPT]
				,[AutoSuperPT]
				,[MinPT]
				,[MaxPT]
			)
			SELECT 
				 C.custid
				,t.SportType
				,t.BetType
				,C.IsLive
				,C.SuperPT
				,C.MasterPT
				,C.AgentPT
				,C.IsAutoMasterPT
				,C.AutoMasterPT
				,C.IsAutoSuperPT
				,C.AutoSuperPT
				,C.MinPT
				,C.MaxPT
			FROM dbo.CustPTSetting3rd_Agent C WITH(NOLOCK) 
				INNER JOIN #SMATemp ci 
					ON ci.custid = C.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Position Taking'
				 AND t.IsDefault = 0

			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				INSERT INTO dbo.CustPTSetting3rd_Member(		
					 [custid]
					,[sporttype]
					,[bettype]
					,[islive]
					,[superPT]
					,[masterPT]
					,[agentPT]
					,[IsAutoMasterPT]
					,[AutoMasterPT]
					,[IsAutoSuperPT]
					,[AutoSuperPT]
				)
				SELECT 
					 C.custid
					,t.SportType
					,t.BetType
					,C.IsLive
					,C.SuperPT
					,C.MasterPT
					,C.AgentPT
					,C.IsAutoMasterPT
					,C.AutoMasterPT
					,C.IsAutoSuperPT
					,C.AutoSuperPT
				FROM dbo.CustPTSetting3rd_Member C WITH(NOLOCK) 
					INNER JOIN #MemberTemp_Batch ci 
						ON ci.custid = C.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
				WHERE t.SettingName = 'Position Taking'
					 AND t.IsDefault = 0
			END

			--Group PT 
			INSERT INTO dbo.CustPTGroupSetting3rd_Member(	
				[AgentID]
				,[SportType]
				,[BetType]
				,[IsLive]
				,[SuperPT]
				,[MasterPT]
				,[AgentPT]
				,[IsAutoMasterPT]
				,[AutoMasterPT]
				,[IsAutoSuperPT]
				,[AutoSuperPT]
			)
			SELECT 
				 C.AgentID
				,t.SportType
				,t.BetType
				,C.IsLive
				,C.SuperPT
				,C.MasterPT
				,C.AgentPT
				,C.IsAutoMasterPT
				,C.AutoMasterPT
				,C.IsAutoSuperPT
				,C.AutoSuperPT
			FROM dbo.CustPTGroupSetting3rd_Member C WITH(NOLOCK) 
				INNER JOIN #SMATemp ci 
					ON ci.custid = C.AgentID
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Position Taking'
				 AND t.IsDefault = 0
		END

		-----------------------Bet Setting-----------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting' AND IsDefault = 0)
		BEGIN
			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb
				SET	  MinBet = c.MinBet
					, MaxBet = c.MaxBet
					, MaxPerMatch = CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE 0 END
				FROM dbo.CustBetSetting3rd_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustBetSetting3rd_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Bet Setting'
					 AND t.IsDefault = 0

				INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
				SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE 0 END
				FROM dbo.CustBetSetting3rd_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustBetSetting3rd_Agent cb WITH(NOLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Bet Setting'
					 AND t.IsDefault = 0
					 AND cb.CustID IS NULL
			END

			--SMA level
			INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
			SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
				, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE 0 END
			FROM dbo.CustBetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN #SMATemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Bet Setting'
				 AND t.IsDefault = 0

			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
				SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE 0 END
				FROM dbo.CustBetSetting3rd_Member c WITH(NOLOCK)
					INNER JOIN #MemberTemp_Batch ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
				WHERE t.SettingName = 'Bet Setting'
					 AND t.IsDefault = 0
			END
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting Game' AND IsDefault = 0)
		BEGIN
			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb
				SET	  MinBet = c.MinBet
					, MaxBet = c.MaxBet
					, MaxPerMatch = c.MaxPerMatch
					, MaxPerNumber = CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
				FROM dbo.CustBetSetting_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustBetSetting_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Bet Setting Game'
					 AND t.IsDefault = 0

				INSERT INTO dbo.CustBetSetting_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch,MaxPerNumber)
				SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet, c.MaxPerMatch
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
				FROM dbo.CustBetSetting_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustBetSetting_Agent cb WITH(NOLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Bet Setting Game'
					 AND t.IsDefault = 0
					 AND cb.CustID IS NULL
			END

			--SMA level
			INSERT INTO dbo.CustBetSetting_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber)
			SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet, c.MaxPerMatch
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.CustBetSetting_Agent c WITH(NOLOCK)
				INNER JOIN #SMATemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Bet Setting Game'
				 AND t.IsDefault = 0

			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustBetSetting_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber)
				SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet, c.MaxPerMatch
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
				FROM dbo.CustBetSetting_Member c WITH(NOLOCK)
					INNER JOIN #MemberTemp_Batch ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
				WHERE t.SettingName = 'Bet Setting Game'
					 AND t.IsDefault = 0
			END
		END
		-----------------------Commission------------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission' AND IsDefault = 0)
		BEGIN
			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb 
				SET Discount = c.Discount	
				FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustDiscount3rd_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 0

				INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
				SELECT c.CustID, t.SportType, t.BetType, c.Discount	
				FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci 
						ON ci.custid = C.CustID
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustDiscount3rd_Agent cb WITH(NOLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 0
					AND cb.CustID IS NULL
			END

			--SMA level
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT c.CustID, t.SportType, t.BetType, c.Discount	
			FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
				INNER JOIN #SMATemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 0
			
			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
				SELECT c.CustID, t.SportType, t.BetType, c.PlayerDiscount, c.AgentDiscount, c.MasterDiscount, c.SuperDiscount 
				FROM dbo.CustDiscount3rd_Member c WITH(NOLOCK)
					INNER JOIN #MemberTemp_Batch ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 0
			END
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission' AND IsDefault = 1)
		BEGIN
			--Normal Super level
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper	
			FROM #SMATemp ci
				CROSS JOIN #TempConfig t 
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
				AND ci.roleid = 4

			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA level
				UPDATE cb 
				SET Discount= t.DefaultValueSuper	
				FROM #DummyAcc ci
					CROSS JOIN #TempConfig t 
					INNER JOIN CustDiscount3rd_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON ci.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 1

				INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
				SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper	
				FROM #DummyAcc ci
					CROSS JOIN #TempConfig t 
					LEFT JOIN CustDiscount3rd_Agent cb WITH(NOLOCK)
						ON ci.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 1
					AND cb.CustID IS NULL

				--Direct Master/Agent level
				INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
				SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper	
				FROM #SMATemp ci
					CROSS JOIN #TempConfig t 
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 1
					AND ci.roleid IN (2,3)
					AND ci.CustID = @DirectCustID
			END

			--Master level 
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueMaster	
			FROM #SMATemp ci
				CROSS JOIN #TempConfig t 
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
				AND ci.roleid = 3
				AND ci.CustID <> @DirectCustID

			--Agent level 
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueAgent	
			FROM #SMATemp ci
				CROSS JOIN #TempConfig t 
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
				AND ci.roleid = 2
				AND ci.CustID <> @DirectCustID

			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
				SELECT ci.CustID, t.SportType, t.BetType
					, CASE WHEN @DirectCustRoleID = 1 THEN t.DefaultValueSuper ELSE t.DefaultValueMember END
					, CASE WHEN @DirectCustRoleID IN (1,2) THEN t.DefaultValueSuper ELSE t.DefaultValueAgent END
					, CASE WHEN @DirectCustRoleID IN (1,2,3) THEN t.DefaultValueSuper ELSE t.DefaultValueMaster END
					, t.DefaultValueSuper
				FROM #MemberTemp_Batch ci
					CROSS JOIN #TempConfig t 
				WHERE t.SettingName = 'Commission' 
					AND t.IsDefault = 1
			END
		END

		-----------------------Win Loss Limit--------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit' AND IsDefault = 0)
		BEGIN

			IF @DirectCustRoleID <> 4
			BEGIN
				-- Dummy SMA
				UPDATE cb 
				SET   MaxWinLimit = CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
					, MaxLossLimit = c.MaxLossLimit
					, IsAutoReset = c.IsAutoReset	
				FROM dbo.CustWinLossLimit_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					INNER JOIN CustWinLossLimit_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 0

				INSERT INTO dbo.CustWinLossLimit_Agent(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
				SELECT c.CustID, t.SportType, t.BetType
					, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
					, c.MaxLossLimit, c.IsAutoReset	
				FROM dbo.CustWinLossLimit_Agent c WITH(NOLOCK)
					INNER JOIN #DummyAcc ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
					LEFT JOIN CustWinLossLimit_Agent cb WITH(NOLOCK)
						ON c.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 0
					AND cb.CustID IS NULL
			END

			--SMA level
			INSERT INTO dbo.CustWinLossLimit_Agent(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT c.CustID, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, c.MaxLossLimit, c.IsAutoReset	
			FROM dbo.CustWinLossLimit_Agent c WITH(NOLOCK)
				INNER JOIN #SMATemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 0
	
			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustWinLossLimit_Member(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
				SELECT c.CustID, t.SportType, t.BetType
					, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
					, c.MaxLossLimit, c.IsAutoReset
				FROM dbo.CustWinLossLimit_Member c WITH(NOLOCK)
					INNER JOIN #MemberTemp_Batch ci  
						ON c.CustID = ci.custid
					INNER JOIN #TempConfig t 
						ON c.SportType = t.CopyFromSportType 
						AND c.BetType = t.CopyFromBetType
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 0
			END
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit' AND IsDefault = 1)
		BEGIN
			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb 
				SET	  cb.MaxWinLimit = t.DefaultValueSuper
					, cb.MaxLossLimit = g.DefaultLossLimit
					, cb.IsAutoReset = t.SpecialRequirement	
				FROM #DummyAcc ci
					CROSS JOIN #TempConfig t
					INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
						ON g.ProductId = t.ProductID 
						AND g.ExchangeId = @currency
					INNER JOIN CustWinLossLimit_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON ci.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 1

				INSERT INTO dbo.CustWinLossLimit_Agent(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
				SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper, g.DefaultLossLimit, t.SpecialRequirement	
				FROM #DummyAcc ci
					CROSS JOIN #TempConfig t
					INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
						ON g.ProductId = t.ProductID 
						AND g.ExchangeId = @currency
					LEFT JOIN CustWinLossLimit_Agent cb WITH(NOLOCK)
						ON ci.CustID = cb.CustID
						AND t.SportType = cb.SportType
						AND t.BetType = cb.BetType
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 1
					AND cb.CustID IS NULL
			END
			
			--SMA level
			INSERT INTO dbo.CustWinLossLimit_Agent(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper, g.DefaultLossLimit, t.SpecialRequirement	
			FROM #SMATemp ci 
				CROSS JOIN #TempConfig t
				INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
					ON g.ProductId = t.ProductID 
					AND g.ExchangeId = @currency
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 1

			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustWinLossLimit_Member(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
				SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper, g.DefaultLossLimit, t.SpecialRequirement	
				FROM #MemberTemp_Batch ci 
					CROSS JOIN #TempConfig t
					INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
						ON g.ProductId = t.ProductID 
						AND g.ExchangeId = @currency
				WHERE t.SettingName = 'Win Loss Limit' 
					AND t.IsDefault = 1
			END
		END

		-----------------------Stake Level-----------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Stake Level' AND IsDefault = 1)
		BEGIN
			INSERT INTO #tmpSTList(Sporttype, BettypeID, StakelevelList, Min_StakeLevel)
			SELECT DISTINCT t.SportType,t.BetType
				, CAST (STUFF (STL, 1,1, '') AS VARCHAR(500)) as StakeLevelList
				, CAST (M.StakeLevelID AS VARCHAR(10)) as Min_StakeLevel
			FROM #TempConfig t
				CROSS APPLY (SELECT ',' + CAST(StakeLevelID AS VARCHAR(10))
							FROM StakeLevel S WITH (NOLOCK)
							WHERE S.GameTypeID = t.BetType AND S.ExchangeId = @Currency
							FOR XML PATH ('') 
							) AS A(STL)
				CROSS APPLY (SELECT TOP 1 StakeLevelID
							FROM StakeLevel S WITH (NOLOCK)
								LEFT JOIN GameGroup gg WITH(NOLOCK) 
									ON s.GameGroupID = gg.GameGroupID
							WHERE S.GameTypeID = t.BetType AND S.ExchangeId = @Currency
							ORDER BY s.MaxStake ASC, s.MinStake ASC, gg.GroupName ASC
							) AS M
			WHERE t.SettingName = 'Stake Level' AND t.IsDefault = 1

			IF @DirectCustRoleID <> 4
			BEGIN
				--Dummy SMA
				UPDATE cb 
				SET cb.StakeLevelList =  tb.StakeLevelList
				FROM  #tmpSTList tb
					CROSS JOIN #DummyAcc t
					INNER JOIN CustStakeLevel_Agent cb WITH(ROWLOCK,UPDLOCK)
						ON t.CustID = cb.CustID
						AND tb.SportType = cb.SportType
						AND tb.BettypeID = cb.BetType

				INSERT INTO dbo.CustStakeLevel_Agent ([CustID],[SportType],[BetType],[StakeLevelList]) 
				SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.StakeLevelList
				FROM  #tmpSTList tb
					CROSS JOIN #DummyAcc t
					LEFT JOIN CustStakeLevel_Agent cb WITH(NOLOCK)
						ON t.CustID = cb.CustID
						AND tb.SportType = cb.SportType
						AND tb.BettypeID = cb.BetType
				WHERE cb.CustID IS NULL
			END

			--SMA Level
			INSERT INTO dbo.CustStakeLevel_Agent ([CustID],[SportType],[BetType],[StakeLevelList]) 
			SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.StakeLevelList
			FROM  #tmpSTList tb
				CROSS JOIN  #SMATemp t
			
			--Member Level
			UPDATE #MemberTemp SET IsFinished = 0

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTemp_Batch

				UPDATE TOP(@BatchNum_Ins) #MemberTemp 
				SET IsFinished = 1
				OUTPUT deleted.CustID,deleted.srecommend,deleted.mrecommend,deleted.recommend INTO #MemberTemp_Batch(CustID,srecommend,mrecommend,recommend)
				WHERE IsFinished = 0

				IF @@ROWCOUNT = 0
					BREAK;

				--Member Level
				INSERT INTO dbo.CustStakeLevel_Member ([CustID],[SportType],[BetType],[StakeLevelList],LastUpdated) 
				SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.Min_StakeLevel,@CurrentDTS
				FROM  #tmpSTList tb
					CROSS JOIN  #MemberTemp_Batch t
			END
		END
	END

	DROP TABLE #TempConfig
	DROP TABLE #MemberTemp
	DROP TABLE #SMATemp
	DROP TABLE #CustSettingTmp
	DROP TABLE #CustSettingTmpBatch
	DROP TABLE #tmpSTList
	DROP TABLE #MemberTemp_Batch
	DROP TABLE #DummyAcc
END
GO