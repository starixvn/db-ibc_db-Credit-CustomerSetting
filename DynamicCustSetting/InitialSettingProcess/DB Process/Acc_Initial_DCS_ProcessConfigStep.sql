/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_ProcessConfigStep]
	@ConfigID INT,
	@StepID TINYINT,
	@MaxCustID INT = NULL
AS
/*
	Created: 20210713@Eden
	Task : Process initial Step on main DB
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 
	- 20220927@Eden: Adjust UM config - block add new mode [Redmine: #178245] 
	- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20240520@Eden: Unify RNG Games [redmine: #204358]   

	Parameter Definition
		StepID = :
			4: Insert setting for new customers
			5: Enable status for new customers
			6: Adjust setting
			7: Adjust status
			8: Disable status headline
			....

	Example: 
	EXEC [Acc_Initial_DCS_ProcessConfigStep]
		@ConfigID = 4
		,@StepID = 4
		,@MaxCustID = 1000000000
	
	*/
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE #Supers(SuperID INT PRIMARY KEY, Site VARCHAR(10))
	DECLARE @Site VARCHAR(MAX), @Currency VARCHAR(MAX)
	DECLARE @TBL_site TABLE(SiteID INT,Site VARCHAR(10) PRIMARY KEY)
	DECLARE @TBL_Currency TABLE(Currency INT PRIMARY KEY)

	SELECT @Site = Site, @Currency = Currency
	FROM Initial_ProductConfig WITH(NOLOCK)
	WHERE ConfigID = @ConfigID
		AND Status = 1 --Running

	--> Get List of Site/Currency by config
	INSERT INTO @TBL_site(SiteID,Site)
	SELECT DISTINCT s.siteid, s.site
	FROM Site s WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Site,',') t ON s.siteid = t.value OR @Site = '0'
	WHERE s.isActive = 1
		AND s.isLicensee = 0
		AND s.siteid NOT IN (329)--CN88

	INSERT INTO @TBL_Currency(Currency)
	SELECT DISTINCT e.ExchangeId
	FROM exchange e WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Currency,',') t ON e.ExchangeId = t.value OR @Currency = '0'
	WHERE e.IsActive = 1

	CREATE TABLE #DirectAcc( CustID INT PRIMARY KEY, srecommend INT, mrecommend INT, recommend INT, RoleID TINYINT, currency INT)
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_recommend ON #DirectAcc(recommend)
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_mrecommend ON #DirectAcc(mrecommend) 
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_srecommend ON #DirectAcc(srecommend)  

	INSERT INTO #Supers(SuperID,Site)
	SELECT ci.CustID,c.site
	FROM Initial_Customer ci WITH(NOLOCK) 
		INNER JOIN customer c WITH(NOLOCK) ON ci.CustID = c.custid
	WHERE ci.RoleID = 4

	INSERT INTO #Supers(SuperID,Site)
	SELECT ci.custid, ci.site
	FROM customer ci WITH (NOLOCK) 
		INNER JOIN @TBL_Currency ex ON ci.currency = ex.Currency
		INNER JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
		INNER JOIN custInfo c WITH(NOLOCK) ON c.custid = ci.custid
	WHERE ci.roleid = 4  
		AND ci.username NOT LIKE '3rdSuper%'
		AND cs.isinternal = 0
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.Enabled = 1
		AND ci.custID > @MaxCustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID,currency)
	SELECT ci.CustID,c.srecommend,c.mrecommend,c.recommend,c.roleid,c.currency
	FROM Initial_Customer ci WITH(NOLOCK) 
		INNER JOIN customer c WITH(NOLOCK) ON ci.CustID = c.custid
	WHERE ci.RoleID IN (1,2,3)

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID,currency)
	SELECT d.CustID
		,c.srecommend
		,c.mrecommend
		,c.recommend
		,c.roleid
		,c.currency
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustAgent ca WITH(NOLOCK) ON ca.custid = c.recommend AND ca.IsInternal = 0
	WHERE c.roleid = 1
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND c.custid > @MaxCustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID,currency)
	SELECT d.CustID
		,c.srecommend
		,c.mrecommend
		,0
		,c.roleid
		,c.currency
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustAgent ca WITH(NOLOCK) ON ca.custid = c.custid AND ca.IsInternal = 0
	WHERE c.roleid = 2
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.custid NOT IN ( SELECT recommend FROM #DirectAcc)
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND c.custid > @MaxCustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID,currency)
	SELECT d.CustID
		,c.srecommend
		,0
		,0
		,c.roleid
		,c.currency
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustMaster cm WITH(NOLOCK) ON cm.custid = c.custid AND cm.IsInternal = 0
	WHERE c.roleid = 3
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.custid NOT IN ( SELECT mrecommend FROM #DirectAcc)
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND c.custid > @MaxCustID

	-->remove dummy Supers
	DELETE t
	FROM #Supers t
	WHERE EXISTS (SELECT TOP 1 1 FROM #DirectAcc WHERE t.SuperID = srecommend)

	DELETE t
	FROM #Supers t
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM @TBL_site s WHERE t.Site = s.Site)

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
		[bitmapOrder] [tinyint],
		[bitmapOrder_Source] [tinyint],
		[IsFinished] [bit] default 0,
		[ProductID] [TINYINT],
		[CopyFrom_ProductID] [TINYINT],
		[HaveWinLimit] BIT DEFAULT 1, -- 0 : Only Loss Limit
		[HaveMaxPerMatch] BIT DEFAULT 1, -- 0: Not use MaxPerMatch
		[HaveMaxPerNumber] BIT DEFAULT 0 -- 0: Not use HaveMaxPerNumber
	)

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
		,tp.SettingName
	FROM Initial_ProductConfig_Detail Data WITH(NOLOCK)
		INNER JOIN ProductSettingType tp WITH(NOLOCK) ON data.SettingType = tp.SettingType
	WHERE data.ConfigID = @ConfigID

	--> Update default Values for status
	UPDATE t
	SET t.DefaultValueSuper = CASE WHEN t.DefaultValueSuper = 1 THEN 0 ELSE 1 END,
		t.DefaultValueMaster = CASE WHEN t.DefaultValueMaster = 1 THEN 0 ELSE 1 END,
		t.DefaultValueAgent = CASE WHEN t.DefaultValueAgent = 1 THEN 0 ELSE 1 END,
		t.DefaultValueMember = CASE WHEN t.DefaultValueMember = 1 THEN 0 ELSE 1 END
	FROM #TempConfig t
	WHERE t.SettingName = 'Product Status'

	UPDATE t
	SET t.HaveMaxPerNumber = CASE WHEN p.SubType = 2 THEN 1 ELSE 0 END
	FROM #TempConfig t
		INNER JOIN ProductSettingProfile p WITH(NOLOCK) 
			ON t.SportType = p.SportType AND t.BetType = p.BetType
	WHERE t.SettingName = 'Bet Setting'
		AND p.SettingType IN (23)
	
	---->don't set Max per match for settingtype 20
	--UPDATE t
	--SET t.HaveMaxPerMatch = CASE WHEN t.SettingType = 20 THEN 0 ELSE 1 END
	--FROM #TempConfig t
	--WHERE t.SettingName = 'Bet Setting'

	-->don't set Win Limit for settingtype 12
	UPDATE t
	SET t.HaveWinLimit = CASE WHEN t.SettingType = 12 THEN 0 ELSE 1 END,
		t.DefaultValueSuper = CASE WHEN t.SettingType = 12 THEN NULL ELSE t.DefaultValueSuper END
	FROM #TempConfig t
	WHERE t.SettingName = 'Win Loss Limit'

	IF @StepID IN(5,7,8) -- Enable Status/Adjust status
	BEGIN
		DELETE FROM #TempConfig WHERE ISNULL(SettingName,'') <> 'Product Status'

		--> Get bitmapOrder
		UPDATE t
		SET t.bitmapOrder = p.bitmapOrder,
			t.bitmapOrder_Source = pS.bitmapOrder
		FROM #TempConfig t
			INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
				ON t.SportType = p.Sporttype
				AND t.BetType = p.Bettype
			LEFT JOIN ProductStatusProfile pS WITH(NOLOCK) 
				ON t.CopyFromSportType = pS.Sporttype
				AND t.CopyFromBetType = pS.Bettype
				AND t.IsDefault = 0
		WHERE t.SettingName = 'Product Status'

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE BitMapOrder IS NULL AND SettingName = 'Product Status')
			RETURN

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE bitmapOrder_Source IS NULL AND IsDefault = 0  AND SettingName = 'Product Status')
			RETURN

		IF EXISTS(  SELECT 1 
					FROM #TempConfig 
					WHERE (DefaultValueSuper IS NULL 
							OR DefaultValueMaster IS NULL 
							OR DefaultValueAgent IS NULL 
							OR DefaultValueMember IS NULL)
						AND IsDefault = 1
						AND SettingName = 'Product Status'
					)
			RETURN
	END

	UPDATE t
	SET t.ProductID = p.ProductID
	FROM #TempConfig t WITH(NOLOCK)
		INNER JOIN ProductSettingProfile p WITH(NOLOCK) 
			ON t.SportType = p.SportType AND t.BetType = p.BetType

	UPDATE t
	SET t.CopyFrom_ProductID = p.ProductID
	FROM #TempConfig t WITH(NOLOCK)
		INNER JOIN ProductSettingProfile p WITH(NOLOCK) 
			ON t.CopyFromSportType = p.SportType AND t.CopyFromBetType = p.BetType
	
	CREATE TABLE #MemberTemp(CustID INT PRIMARY KEY CLUSTERED, srecommend INT, mrecommend INT, recommend INT,Currency INT, IsFinished bit default 0)
	CREATE TABLE #SMATemp(CustID INT PRIMARY KEY CLUSTERED, roleid TINYINT, Currency INT, IsFinished bit default 0)
	CREATE TABLE #CustSettingTmp(CustID INT, Sporttype SMALLINT, Bettype SMALLINT,IsLive BIT)
	CREATE TABLE #CustSettingTmpBatch(CustID INT, Sporttype SMALLINT, Bettype SMALLINT,IsLive BIT)
	CREATE TABLE #tmpSTList (Sporttype INT, BettypeID INT, currency INT, StakeLevelList VARCHAR(500),Min_StakeLevel VARCHAR(10))
	CREATE TABLE #CustTempBatch(CustID INT)

	----TEMP TABLE FOR ADJUST----
	CREATE TABLE #SMAList_PT (custid INT, Sporttype SMALLINT, Bettype SMALLINT, IsLive BIT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY, MinPositionTaking SMALLMONEY, MaxPositionTaking SMALLMONEY)
	CREATE TABLE #MemberList_PT (custid INT, Sporttype SMALLINT, Bettype SMALLINT, IsLive BIT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY)	
	CREATE TABLE #Super_WrongPT (custid INT, Sporttype SMALLINT, Bettype SMALLINT, IsLive BIT)
	CREATE TABLE #AgentGroupPT (AgentID INT, Sporttype SMALLINT, Bettype SMALLINT, IsLive BIT, SuperPT TINYINT, MasterPT TINYINT, AgentPT TINYINT, IsAutoMasterPT BIT, AutoMasterPT TINYINT, IsAutoSuperPT BIT, AutoSuperPT TINYINT)

	CREATE TABLE #SMAList_BetSetting (custid INT, Sporttype SMALLINT, Bettype SMALLINT, Minbet MONEY, MaxBet MONEY, MaxPerMatch MONEY)
	CREATE TABLE #MemberList_BetSetting (custid INT, Sporttype SMALLINT, Bettype SMALLINT, Minbet MONEY, MaxBet MONEY, MaxPerMatch MONEY)
	
	CREATE TABLE #SMAList_BetSettingGame (custid INT, Sporttype SMALLINT, Bettype SMALLINT, Minbet MONEY, MaxBet MONEY, MaxPerMatch MONEY, MaxPerNumber MONEY)
	CREATE TABLE #MemberList_BetSettingGame (custid INT, Sporttype SMALLINT, Bettype SMALLINT, Minbet MONEY, MaxBet MONEY, MaxPerMatch MONEY, MaxPerNumber MONEY)

	CREATE TABLE #SMAList_CommSetting (custid INT, Sporttype SMALLINT, Bettype SMALLINT, Discount DECIMAL(9,8))
	CREATE TABLE #MemberList_CommSetting (custid INT, Sporttype SMALLINT, Bettype SMALLINT, SuperDiscount DECIMAL(9,8), MasterDiscount DECIMAL(9,8), AgentDiscount DECIMAL(9,8), PlayerDiscount DECIMAL(9,8))

	CREATE TABLE #SMAList_WL (custid INT, Sporttype SMALLINT, Bettype SMALLINT, MaxWinLimit MONEY, MaxLossLimit MONEY, IsAutoReset BIT)
	CREATE TABLE #MemberList_WL(custid INT, Sporttype SMALLINT, Bettype SMALLINT, MaxWinLimit MONEY,MaxLossLimit MONEY, IsAutoReset BIT)

	CREATE TABLE #Custlist_Status (custid INT, bitmapOrder tinyint, IsDisabled BIT)
	CREATE TABLE #CustList_Status_Batch(custid INT, IsDisabled BIT)

	CREATE TABLE #DummyAcc(custid INT PRIMARY KEY, RoleID INT, currency INT, IsFinished bit default 0)
	-----------------------

	INSERT INTO #MemberTemp (CustID,srecommend,mrecommend,recommend,Currency)
	SELECT custid,srecommend,mrecommend,recommend,currency
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend IN (SELECT SuperID FROM #Supers)
		AND roleid = 1  AND Enabled = 1 AND custid > @maxcustid
	UNION ALL
	SELECT custid,srecommend,mrecommend,recommend,currency
	FROM Custinfo WITH (NOLOCK)
	WHERE mrecommend IN (SELECT t.CustID FROM #DirectAcc t WHERE t.roleid = 3)
		AND roleid = 1  AND Enabled = 1 AND custid > @maxcustid
	UNION ALL
	SELECT custid,srecommend,mrecommend,recommend,currency
	FROM Custinfo WITH (NOLOCK)
	WHERE recommend IN (SELECT t.CustID FROM #DirectAcc t WHERE t.roleid = 2)
		AND roleid = 1  AND Enabled = 1 AND custid > @maxcustid
	UNION ALL
	SELECT custid,srecommend,mrecommend,recommend,currency
	FROM Custinfo WITH (NOLOCK)
	WHERE custid IN (SELECT t.CustID FROM #DirectAcc t WHERE t.roleid = 1)
		AND roleid = 1  AND Enabled = 1 AND custid > @maxcustid
	
	INSERT INTO #SMATemp (CustID, roleid, currency)
	SELECT custid, roleid, currency
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend IN (SELECT SuperID FROM #Supers)
		AND roleid IN (2,3,4) AND Enabled = 1 AND custid > @maxcustid
	UNION ALL
	SELECT custid, roleid, currency
	FROM Custinfo WITH (NOLOCK)
	WHERE mrecommend IN (SELECT t.CustID FROM #DirectAcc t WHERE t.roleid = 3)
		AND roleid IN (2,3) AND Enabled = 1 AND custid > @maxcustid
	UNION ALL
	SELECT custid, roleid, currency
	FROM Custinfo WITH (NOLOCK)
	WHERE custid IN (SELECT t.CustID FROM #DirectAcc t WHERE t.roleid = 2)
		AND roleid = 2 AND Enabled = 1 AND custid > @maxcustid

	--Insert dummy accs
	INSERT INTO #DummyAcc(custid,RoleID,currency)
	SELECT srecommend,4,currency
	FROM #DirectAcc t
	WHERE t.srecommend <> 0
	UNION 
	SELECT mrecommend,3,currency
	FROM #DirectAcc t
	WHERE t.mrecommend <> 0
	UNION 
	SELECT recommend,2,currency
	FROM #DirectAcc t
	WHERE t.recommend <> 0

	DECLARE @CurrentDTS DATETIME = GETDATE()
	DECLARE @BatchNum INT = 5000
	DECLARE @BitMapOrder TINYINT, @BitMapOrder_S TINYINT
	DECLARE @IsDisableSuper BIT, @IsDisableMaster BIT,  @IsDisableAgent BIT,  @IsDisableMember BIT  
	
	IF @StepID = 4 --Insert setting for new customers
	BEGIN
		-----------Update UMConfig.BeginTime = current Datetime-----------------------------
		IF @Currency <> '20'
		BEGIN
			UPDATE u
			SET u.BeginTime = @CurrentDTS
			FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
				LEFT JOIN ProductSettingType st WITH(NOLOCK)
					ON u.SettingType = st.SettingType
				CROSS APPLY (	SELECT TOP 1 t.SportType
								FROM #TempConfig t 
								WHERE u.SportType IN (t.CopyFromSportType,t.SportType,0)
									AND u.BetType IN (t.CopyFromBetType,t.BetType,0)
									AND (st.SettingName = t.SettingName OR u.SettingType = 0)
									AND u.ProductID IN( t.ProductID,t.CopyFrom_ProductID)
					) tmp
			WHERE u.FunctionType = 1
				AND u.EndTime >= @CurrentDTS
				AND u.BeginTime >= @CurrentDTS
				AND u.SuperID = 0

			UPDATE u
			SET u.BeginTime = @CurrentDTS
			FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
			WHERE u.FunctionType = 2
				AND u.EndTime >= @CurrentDTS
				AND u.BeginTime >= @CurrentDTS
				AND u.SuperID = 0
		END
		ELSE --@Currency = 20
		BEGIN
			UPDATE u
			SET u.BeginTime = @CurrentDTS
			FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
				LEFT JOIN ProductSettingType st WITH(NOLOCK)
					ON u.SettingType = st.SettingType
				CROSS APPLY (	SELECT TOP 1 t.SportType
								FROM #TempConfig t 
								WHERE u.SportType IN (t.CopyFromSportType,t.SportType,0)
									AND u.BetType IN (t.CopyFromBetType,t.BetType,0)
									AND (st.SettingName = t.SettingName OR u.SettingType = 0)
									AND u.ProductID IN( t.ProductID,t.CopyFrom_ProductID)
					) tmp
			WHERE u.FunctionType = 1
				AND u.EndTime >= @CurrentDTS
				AND u.BeginTime >= @CurrentDTS
				AND u.SuperID = 0
				AND u.Currency = 20

			UPDATE u
			SET u.BeginTime = @CurrentDTS
			FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
			WHERE u.FunctionType = 2
				AND u.EndTime >= @CurrentDTS
				AND u.BeginTime >= @CurrentDTS
				AND u.SuperID = 0
				AND u.Currency = 20
		END

		----------START : DELETE REDUDANT SETTING------------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Position Taking')
		BEGIN
			DELETE c
			FROM CustPTSetting3rd_Agent c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
					AND c.IsLive = tc.IsLive
			WHERE tc.SettingName = 'Position Taking'
				AND c.CustID > @MaxCustID

			DELETE c
			FROM CustPTSetting3rd_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #MemberTemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
					AND c.IsLive = tc.IsLive
			WHERE tc.SettingName = 'Position Taking'
				AND c.CustID > @MaxCustID

			DELETE c
			FROM CustPTGroupSetting3rd_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.AgentID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
					AND c.IsLive = tc.IsLive
			WHERE tc.SettingName = 'Position Taking'
				AND c.AgentID > @MaxCustID
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting')
		BEGIN
			DELETE c
			OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
			INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
			FROM BetSetting3rd_Agent c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Bet Setting'
				AND c.CustID > @MaxCustID

			DELETE c
			OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
			INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
			FROM BetSetting3rd_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #MemberTemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Bet Setting'
				AND c.CustID > @MaxCustID
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission')
		BEGIN
			DELETE c
			FROM CustDiscount3rd_Agent c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Commission'
				AND c.CustID > @MaxCustID

			DELETE c
			FROM CustDiscount3rd_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #MemberTemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Commission'
				AND c.CustID > @MaxCustID
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit')
		BEGIN
			DELETE c
			FROM CustWinLossLimit_Agent c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Win Loss Limit'
				AND c.CustID > @MaxCustID

			DELETE c
			FROM CustWinLossLimit_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #MemberTemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Win Loss Limit'
				AND c.CustID > @MaxCustID
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Stake Level')
		BEGIN
			DELETE c
			FROM CustStakeLevel_Agent c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #SMATemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Stake Level'
				AND c.CustID > @MaxCustID

			DELETE c
			FROM CustStakeLevel_Member c WITH(ROWLOCK, UPDLOCK)
				INNER JOIN #MemberTemp t ON c.CustID = t.CustID
				INNER JOIN #TempConfig tc 
					ON c.SportType = tc.SportType 
					AND c.BetType = tc.BetType
			WHERE tc.SettingName = 'Stake Level'
				AND c.CustID > @MaxCustID
		END
		----------END : DELETE REDUDANT SETTING------------------------------------------

		---------------------------------------START : INSERT SETTING--------------------
		-----------------------PT--------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Position Taking' AND IsDefault = 0)
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
				INNER JOIN #MemberTemp ci 
					ON ci.custid = C.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Position Taking'
				 AND t.IsDefault = 0

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

		-----------------------Bet Setting--------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting' AND IsDefault = 0)
		BEGIN
			--Dummy SMA
			UPDATE cb
			SET	  MinBet = c.MinBet
				, MaxBet = c.MaxBet
				, MaxPerMatch = CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
				, MaxPerNumber = CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
				, RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN #DummyAcc ci 
					ON ci.custid = C.CustID
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
				INNER JOIN BetSetting3rd_Agent cb WITH(ROWLOCK,UPDLOCK)
					ON c.CustID = cb.CustID
					AND t.SportType = cb.SportType
					AND t.BetType = cb.BetType
			WHERE t.SettingName = 'Bet Setting'
				 AND t.IsDefault = 0

			INSERT INTO dbo.BetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber,RepUpdateTime)
			SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
					, dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN #DummyAcc ci 
					ON ci.custid = C.CustID
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
				LEFT JOIN BetSetting3rd_Agent cb WITH(NOLOCK)
					ON c.CustID = cb.CustID
					AND t.SportType = cb.SportType
					AND t.BetType = cb.BetType
			WHERE t.SettingName = 'Bet Setting'
				 AND t.IsDefault = 0
				 AND cb.CustID IS NULL
			
			--SMA level
			INSERT INTO dbo.BetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber,RepUpdateTime)
			SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
					, dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN #SMATemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Bet Setting'
				 AND t.IsDefault = 0
	
			--Member Level
			INSERT INTO dbo.BetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber,RepUpdateTime)
			SELECT c.CustID, t.SportType, t.BetType, c.MinBet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
					, dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Member c WITH(NOLOCK)
				INNER JOIN #MemberTemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Bet Setting'
				 AND t.IsDefault = 0
		END

		-----------------------Commission---------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission' AND IsDefault = 0)
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
			INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
			SELECT c.CustID, t.SportType, t.BetType, c.PlayerDiscount, c.AgentDiscount, c.MasterDiscount, c.SuperDiscount 
			FROM dbo.CustDiscount3rd_Member c WITH(NOLOCK)
				INNER JOIN #MemberTemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 0
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
				AND ci.CustID IN (SELECT CustID FROM #DirectAcc WHERE CustID > @MaxCustID)

			--Master level 
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueMaster	
			FROM #SMATemp ci
				CROSS JOIN #TempConfig t 
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
				AND ci.roleid = 3
				AND ci.CustID NOT IN (SELECT CustID FROM #DirectAcc WHERE CustID > @MaxCustID)

			--Agent level 
			INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueAgent	
			FROM #SMATemp ci
				CROSS JOIN #TempConfig t 
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
				AND ci.roleid = 2
				AND ci.CustID NOT IN (SELECT CustID FROM #DirectAcc WHERE CustID > @MaxCustID)

			--Member Level
			INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
			SELECT ci.CustID, t.SportType, t.BetType
				, CASE WHEN dp.DirectMember IS NOT NULL 
						THEN t.DefaultValueSuper ELSE t.DefaultValueMember END
				, CASE WHEN dp.DirectMember IS NOT NULL OR da.DirectAgent IS NOT NULL 
						THEN t.DefaultValueSuper ELSE t.DefaultValueAgent END
				, CASE WHEN dp.DirectMember IS NOT NULL OR da.DirectAgent IS NOT NULL OR dm.DirectMaster IS NOT NULL 
						THEN t.DefaultValueSuper ELSE t.DefaultValueMaster END
				, t.DefaultValueSuper
			FROM #MemberTemp ci
				CROSS JOIN #TempConfig t 
				OUTER APPLY (SELECT TOP 1 1 AS DirectMaster FROM #DirectAcc D WITH (NOLOCK) WHERE ci.mrecommend = D.CustID) dm
				OUTER APPLY (SELECT TOP 1 1 AS DirectAgent FROM #DirectAcc D WITH (NOLOCK) WHERE ci.recommend = D.CustID) da
				OUTER APPLY (SELECT TOP 1 1 AS DirectMember FROM #DirectAcc D WITH (NOLOCK) WHERE ci.CustID = D.CustID) dp
			WHERE t.SettingName = 'Commission' 
				AND t.IsDefault = 1
		END

		-----------------------Win Loss Limit-----
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit' AND IsDefault = 0)
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
			INSERT INTO dbo.CustWinLossLimit_Member(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT c.CustID, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, c.MaxLossLimit, c.IsAutoReset
			FROM dbo.CustWinLossLimit_Member c WITH(NOLOCK)
				INNER JOIN #MemberTemp ci  
					ON c.CustID = ci.custid
				INNER JOIN #TempConfig t 
					ON c.SportType = t.CopyFromSportType 
					AND c.BetType = t.CopyFromBetType
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 0
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit' AND IsDefault = 1)
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
					AND g.ExchangeId = ci.currency
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
					AND g.ExchangeId = ci.currency
				LEFT JOIN CustWinLossLimit_Agent cb WITH(NOLOCK)
					ON ci.CustID = cb.CustID
					AND t.SportType = cb.SportType
					AND t.BetType = cb.BetType
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 1
				AND cb.CustID IS NULL
			
			--SMA level
			INSERT INTO dbo.CustWinLossLimit_Agent(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper, g.DefaultLossLimit, t.SpecialRequirement	
			FROM #SMATemp ci 
				CROSS JOIN #TempConfig t
				INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
					ON g.ProductId = t.ProductID 
					AND ci.Currency = g.ExchangeId
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 1
	
			--Member Level
			INSERT INTO dbo.CustWinLossLimit_Member(CustID, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT ci.CustID, t.SportType, t.BetType, t.DefaultValueSuper, g.DefaultLossLimit, t.SpecialRequirement	
			FROM #MemberTemp ci 
				CROSS JOIN #TempConfig t
				INNER JOIN LossLimit_GlobalSetting g WITH(NOLOCK) 
					ON g.ProductId = t.ProductID 
					AND ci.Currency = g.ExchangeId
			WHERE t.SettingName = 'Win Loss Limit' 
				AND t.IsDefault = 1
		END

		-----------------------Stake Level--------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Stake Level' AND IsDefault = 1)
		BEGIN
			INSERT INTO #tmpSTList(Sporttype, BettypeID, Currency, StakelevelList, Min_StakeLevel)
			SELECT DISTINCT t.SportType,t.BetType,cu.Currency
				, CAST (STUFF (STL, 1,1, '') AS VARCHAR(500)) as StakeLevelList
				, CAST (M.StakeLevelID AS VARCHAR(10)) as Min_StakeLevel
			FROM #TempConfig t
				CROSS APPLY @TBL_Currency cu
				CROSS APPLY (SELECT ',' + CAST(StakeLevelID AS VARCHAR(10))
							FROM StakeLevel S WITH (NOLOCK)
							WHERE S.GameTypeID = t.BetType AND S.ExchangeId = cu.Currency
							FOR XML PATH ('') 
							) AS A(STL)
				CROSS APPLY (SELECT TOP 1 StakeLevelID
							FROM StakeLevel S WITH (NOLOCK)
								LEFT JOIN GameGroup gg WITH(NOLOCK) 
									ON s.GameGroupID = gg.GameGroupID
							WHERE S.GameTypeID = t.BetType AND S.ExchangeId = cu.Currency
							ORDER BY s.MaxStake ASC, s.MinStake ASC, gg.GroupName ASC
							) AS M
			WHERE t.SettingName = 'Stake Level' AND t.IsDefault = 1

			--Dummy SMA
			UPDATE cb 
			SET cb.StakeLevelList =  tb.StakeLevelList
			FROM  #tmpSTList tb
				INNER JOIN #DummyAcc t ON tb.currency = t.currency
				INNER JOIN CustStakeLevel_Agent cb WITH(ROWLOCK,UPDLOCK)
					ON t.CustID = cb.CustID
					AND tb.SportType = cb.SportType
					AND tb.BettypeID = cb.BetType

			INSERT INTO dbo.CustStakeLevel_Agent ([CustID],[SportType],[BetType],[StakeLevelList]) 
			SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.StakeLevelList
			FROM  #tmpSTList tb
				INNER JOIN #DummyAcc t ON tb.currency = t.currency
				LEFT JOIN CustStakeLevel_Agent cb WITH(NOLOCK)
					ON t.CustID = cb.CustID
					AND tb.SportType = cb.SportType
					AND tb.BettypeID = cb.BetType
			WHERE cb.CustID IS NULL
			
			--SMA Level
			INSERT INTO dbo.CustStakeLevel_Agent ([CustID],[SportType],[BetType],[StakeLevelList]) 
			SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.StakeLevelList
			FROM  #tmpSTList tb
				INNER JOIN  #SMATemp t ON tb.currency = t.Currency

			--Member Level
			INSERT INTO dbo.CustStakeLevel_Member ([CustID],[SportType],[BetType],[StakeLevelList],LastUpdated) 
			SELECT t.custid, tb.Sporttype, tb.BettypeID, tb.Min_StakeLevel,@CurrentDTS
			FROM  #tmpSTList tb
				INNER JOIN  #MemberTemp t ON tb.currency = t.Currency
		END
		---------------------------------------END : INSERT SETTING----------------------
	END

	IF @StepID = 5 --Enable status for new customers
	BEGIN
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Product Status' AND IsDefault = 0)
		BEGIN
			UPDATE #TempConfig SET IsFinished = 0

			WHILE 1 = 1
			BEGIN 
				UPDATE TOP (1) t
				SET t.IsFinished = 1,
					@BitMapOrder = t.bitmapOrder,
					@BitMapOrder_S = t.bitmapOrder_Source
				FROM #TempConfig t
				WHERE t.IsFinished = 0
					AND t.IsDefault = 0
					AND t.SettingName = 'Product Status'

				IF @@ROWCOUNT = 0
					BREAK

				UPDATE #SMATemp SET IsFinished = 0
				UPDATE #MemberTemp SET IsFinished = 0
				UPDATE #DummyAcc SET IsFinished = 0

				--Dummy SMA Dummy
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #DummyAcc t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap	
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END
				
				--SMA level
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #SMATemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap	
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END

				--Member level
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #MemberTemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap	
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END
			END
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Product Status' AND IsDefault = 1)
		BEGIN
			UPDATE #TempConfig SET IsFinished = 0

			WHILE 1 = 1
			BEGIN 
				UPDATE TOP (1) t
				SET t.IsFinished = 1,
					@BitMapOrder = t.bitmapOrder,
					@IsDisableSuper = t.DefaultValueSuper,
					@IsDisableMaster = t.DefaultValueMaster,
					@IsDisableAgent = t.DefaultValueAgent,
					@IsDisableMember = t.DefaultValueMember
				FROM #TempConfig t
				WHERE t.IsFinished = 0
					AND t.IsDefault = 1

				IF @@ROWCOUNT = 0
					BREAK

				UPDATE #MemberTemp SET IsFinished = 0

				--Super level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid = 4
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis

				--Dummy SMA
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #DummyAcc ci ON ci.custid = cs.CustID
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis

				--Direct Master/Agent Level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid IN (2,3)
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis
				WHERE cs.CustID IN (SELECT custid FROM #DirectAcc)

				--Master level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid = 3
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableMaster) as Dis
				WHERE cs.CustID NOT IN (SELECT custid FROM #DirectAcc)

				--Agent level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid = 2
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableAgent) as Dis
				WHERE cs.CustID NOT IN (SELECT custid FROM #DirectAcc)

				--Member level
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #MemberTemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					--Direct Member level
					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap	
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis
					WHERE cs.CustID IN (SELECT CustID FROM #DirectAcc)

					--Member level
					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap	
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableMember) as Dis
					WHERE cs.CustID NOT IN (SELECT CustID FROM #DirectAcc)
				END
			END
		END
	END

	IF @StepID = 6 --Adjust Setting
	BEGIN
		--------------------------------------PT Setting-------------------------------------------------
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Position Taking' AND IsDefault = 0)
		BEGIN
			--AGENT LEVEL
			INSERT INTO #SMAList_PT (custid, Sporttype, Bettype, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking
									, IsAutoPositionTaking, AutoPositionTaking, MinPositionTaking, MaxPositionTaking)
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT, C.IsAutoMasterPT, C.AutoMasterPT
					, C.IsAutoSuperPT, C.AutoSuperPT, C.MinPT, C.MaxPT
			FROM dbo.CustPTSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = c.custid
				INNER JOIN #supers s WITH (NOLOCK) ON CI.srecommend = s.SuperID
				INNER JOIN dbo.CustPTSetting3rd_Agent csa WITH (NOLOCK) ON C.custid = csa.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid IN (2,3,4) AND Enabled = 1
					AND (  C.SuperPT <> csa.SuperPT
						OR C.MasterPT  <> csa.MasterPT
						OR C.AgentPT <> csa.AgentPT
						OR C.IsAutoMasterPT <> csa.IsAutoMasterPT
						OR C.AutoMasterPT  <> csa.AutoMasterPT
						OR C.IsAutoSuperPT <> csa.IsAutoSuperPT
						OR C.AutoSuperPT  <> csa.AutoSuperPT
						OR C.MinPT  <> csa.MinPT
						OR C.MaxPT <> csa.MaxPT
						)
			UNION ALL -- direct master
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT, C.IsAutoMasterPT, C.AutoMasterPT
					, C.IsAutoSuperPT, C.AutoSuperPT, C.MinPT, C.MaxPT
			FROM dbo.CustPTSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = c.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON CI.mrecommend = s.CustID AND s.roleid = 3
				INNER JOIN dbo.CustPTSetting3rd_Agent csa WITH (NOLOCK) ON C.custid = csa.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid IN (2,3) AND Enabled = 1
					AND (  C.SuperPT <> csa.SuperPT
						OR C.MasterPT  <> csa.MasterPT
						OR C.AgentPT <> csa.AgentPT
						OR C.IsAutoMasterPT <> csa.IsAutoMasterPT
						OR C.AutoMasterPT  <> csa.AutoMasterPT
						OR C.IsAutoSuperPT <> csa.IsAutoSuperPT
						OR C.AutoSuperPT  <> csa.AutoSuperPT
						OR C.MinPT  <> csa.MinPT
						OR C.MaxPT <> csa.MaxPT
						)
			UNION ALL -- direct agent
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT, C.IsAutoMasterPT, C.AutoMasterPT
					, C.IsAutoSuperPT, C.AutoSuperPT, C.MinPT, C.MaxPT
			FROM dbo.CustPTSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = c.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.roleid = 2
				INNER JOIN dbo.CustPTSetting3rd_Agent csa WITH (NOLOCK) ON C.custid = csa.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid = 2 AND Enabled = 1
					AND (  C.SuperPT <> csa.SuperPT
						OR C.MasterPT  <> csa.MasterPT
						OR C.AgentPT <> csa.AgentPT
						OR C.IsAutoMasterPT <> csa.IsAutoMasterPT
						OR C.AutoMasterPT  <> csa.AutoMasterPT
						OR C.IsAutoSuperPT <> csa.IsAutoSuperPT
						OR C.AutoSuperPT  <> csa.AutoSuperPT
						OR C.MinPT  <> csa.MinPT
						OR C.MaxPT <> csa.MaxPT
						)

			--MEMBER LEVEL
			INSERT INTO #MemberList_PT (custid, Sporttype, Bettype, SPositionTaking, MPositionTaking, APositionTaking
										, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking)
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTSetting3rd_Member C WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = c.custid 
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid = 1 AND Enabled = 1
					AND (  C.SuperPT <> csm.SuperPT
						OR C.MasterPT <> csm.MasterPT
						OR C.AgentPT<> csm.AgentPT
						OR C.IsAutoMasterPT <> csm.IsAutoMasterPT
						OR C.AutoMasterPT  <> csm.AutoMasterPT
						OR C.IsAutoSuperPT <> csm.IsAutoSuperPT
						OR C.AutoSuperPT <> csm.AutoSuperPT
						)
			UNION ALL --Direct master
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTSetting3rd_Member C WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = c.custid 
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid = 1 AND Enabled = 1
					AND (  C.SuperPT <> csm.SuperPT
						OR C.MasterPT <> csm.MasterPT
						OR C.AgentPT<> csm.AgentPT
						OR C.IsAutoMasterPT <> csm.IsAutoMasterPT
						OR C.AutoMasterPT  <> csm.AutoMasterPT
						OR C.IsAutoSuperPT <> csm.IsAutoSuperPT
						OR C.AutoSuperPT <> csm.AutoSuperPT
						)
			UNION ALL --Direct agent
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTSetting3rd_Member C WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.recommend = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = c.custid 
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid = 1 AND Enabled = 1
					AND (  C.SuperPT <> csm.SuperPT
						OR C.MasterPT <> csm.MasterPT
						OR C.AgentPT<> csm.AgentPT
						OR C.IsAutoMasterPT <> csm.IsAutoMasterPT
						OR C.AutoMasterPT  <> csm.AutoMasterPT
						OR C.IsAutoSuperPT <> csm.IsAutoSuperPT
						OR C.AutoSuperPT <> csm.AutoSuperPT
						)
			UNION ALL --Direct member
			SELECT C.custid, t.SportType, t.BetType, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTSetting3rd_Member C WITH(NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 1
				INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = c.custid 
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
				WHERE ci.roleid = 1 AND Enabled = 1
					AND (  C.SuperPT <> csm.SuperPT
						OR C.MasterPT <> csm.MasterPT
						OR C.AgentPT<> csm.AgentPT
						OR C.IsAutoMasterPT <> csm.IsAutoMasterPT
						OR C.AutoMasterPT  <> csm.AutoMasterPT
						OR C.IsAutoSuperPT <> csm.IsAutoSuperPT
						OR C.AutoSuperPT <> csm.AutoSuperPT
						)
	
			--Group PT
			INSERT INTO #AgentGroupPT (AgentID, Sporttype, Bettype, IsLive, SuperPT, MasterPT, AgentPT
										, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT)
			SELECT C.AgentID, t.SportType, t.BetType, C.IsLive, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTGroupSetting3rd_Member C WITH (NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.AgentID
				INNER JOIN #supers s WITH (NOLOCK) ON CI.srecommend = S.SuperID
				INNER JOIN dbo.CustPTGroupSetting3rd_Member csa WITH (NOLOCK) ON C.AgentID = csa.AgentID
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2) AND Enabled = 1
				AND(   C.SuperPT		<> csa.SuperPT				
					OR C.MasterPT		<> csa.MasterPT	
					OR C.AgentPT		<> csa.AgentPT
					OR C.IsAutoMasterPT	<> csa.IsAutoMasterPT
					OR C.AutoMasterPT	<> csa.AutoMasterPT
					OR C.IsAutoSuperPT	<> csa.IsAutoSuperPT
					OR C.AutoSuperPT	<> csa.AutoSuperPT
					)
			UNION ALL--direct master
			SELECT C.AgentID, t.SportType, t.BetType, C.IsLive, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTGroupSetting3rd_Member C WITH (NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.AgentID
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON CI.mrecommend = S.CustID AND s.roleID = 3
				INNER JOIN dbo.CustPTGroupSetting3rd_Member csa WITH (NOLOCK) ON C.AgentID = csa.AgentID
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2) AND Enabled = 1
				AND(   C.SuperPT		<> csa.SuperPT				
					OR C.MasterPT		<> csa.MasterPT	
					OR C.AgentPT		<> csa.AgentPT
					OR C.IsAutoMasterPT	<> csa.IsAutoMasterPT
					OR C.AutoMasterPT	<> csa.AutoMasterPT
					OR C.IsAutoSuperPT	<> csa.IsAutoSuperPT
					OR C.AutoSuperPT	<> csa.AutoSuperPT
					)
			UNION ALL--direct agent
			SELECT C.AgentID, t.SportType, t.BetType, C.IsLive, C.SuperPT, C.MasterPT, C.AgentPT
				, C.IsAutoMasterPT, C.AutoMasterPT, C.IsAutoSuperPT, C.AutoSuperPT
			FROM dbo.CustPTGroupSetting3rd_Member C WITH (NOLOCK)
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = C.AgentID
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON CI.custid = S.CustID AND s.roleID = 2
				INNER JOIN dbo.CustPTGroupSetting3rd_Member csa WITH (NOLOCK) ON C.AgentID = csa.AgentID
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2) AND Enabled = 1
				AND(   C.SuperPT		<> csa.SuperPT				
					OR C.MasterPT		<> csa.MasterPT	
					OR C.AgentPT		<> csa.AgentPT
					OR C.IsAutoMasterPT	<> csa.IsAutoMasterPT
					OR C.AutoMasterPT	<> csa.AutoMasterPT
					OR C.IsAutoSuperPT	<> csa.IsAutoSuperPT
					OR C.AutoSuperPT	<> csa.AutoSuperPT
					)

			--Wrong PT
			INSERT INTO #Super_WrongPT (custid, Sporttype, Bettype)
			SELECT csa.custid, t.SportType, t.BetType
			FROM dbo.CustPTSetting3rd_Agent csa WITH(NOLOCK)
				INNER JOIN #supers s WITH (NOLOCK) ON s.SuperID = csa.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Position Taking' AND t.IsDefault = 0
			WHERE ( csa.MasterPT > csa.SuperPT
					OR csa.AgentPT > csa.MasterPT
					OR csa.AgentPT > csa.SuperPT
				  )

			--Adjust data
			UPDATE csa
			SET	csa.SuperPT = C.spositiontaking 
				,csa.MasterPT =  C.mpositiontaking 
				,csa.AgentPT = C.apositiontaking
				,csa.IsAutoMasterPT = C.isautompositiontaking
				,csa.AutoMasterPT = C.autompositiontaking
				,csa.IsAutoSuperPT = C.isautopositiontaking 
				,csa.AutoSuperPT = C.autopositiontaking
				,csa.MinPT = C.minpositiontaking
				,csa.MaxPT = C.MaxPositionTaking
			FROM dbo.CustPTSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMAList_PT C WITH(NOLOCK) ON csa.custid = C.custid AND csa.SportType = c.Sporttype AND csa.BetType = c.Bettype
	
			UPDATE csm
			SET	csm.SuperPT = C.spositiontaking 
				,csm.MasterPT =  C.mpositiontaking 
				,csm.AgentPT = C.apositiontaking
				,csm.IsAutoMasterPT = C.isautompositiontaking
				,csm.AutoMasterPT = C.autompositiontaking
				,csm.IsAutoSuperPT = C.isautopositiontaking 
				,csm.AutoSuperPT = C.autopositiontaking
			FROM dbo.CustPTSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberList_PT C WITH (NOLOCK) ON C.custid = csm.custid AND csm.SportType = c.Sporttype AND csm.BetType = c.Bettype

			UPDATE CSA
			SET CSA.SuperPT		= C.SuperPT		
				,CSA.MasterPT		= C.MasterPT	
				,CSA.AgentPT			= C.AgentPT
				,CSA.IsAutoMasterPT	= C.IsAutoMasterPT
				,CSA.AutoMasterPT	= C.AutoMasterPT
				,CSA.IsAutoSuperPT	= C.IsAutoSuperPT
				,	CSA.AutoSuperPT		= C.AutoSuperPT
			FROM CustPTGroupSetting3rd_Member CSA WITH (UPDLOCK,ROWLOCK)
				INNER JOIN #AgentGroupPT C WITH (NOLOCK) ON CSA.AgentID = C.AgentID AND csa.SportType = c.Sporttype AND csa.BetType = c.Bettype
		
			DECLARE @MasterPT SMALLMONEY
			--Adjust m4 = s4 if m4 > s4; a4 = new_m4 if a4 > new_m4
			UPDATE csa
			SET	@MasterPT = CASE WHEN csa.MasterPT > csa.SuperPT THEN csa.SuperPT ELSE csa.MasterPT END,
				csa.MasterPT = @MasterPT,
				csa.AgentPT = CASE	WHEN csa.AgentPT > @MasterPT THEN @MasterPT ELSE csa.AgentPT END
			FROM dbo.CustPTSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #Super_WrongPT cs WITH(NOLOCK) ON csa.custid = cs.custid AND csa.SportType = cs.Sporttype AND csa.BetType = cs.Bettype
		END
		--------------------------------------Commission Setting-------------------------------------------------		
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Commission' AND IsDefault = 0)
		BEGIN
			--Agent Level
			INSERT INTO #SMAList_CommSetting (custid, Sporttype, Bettype, Discount)
			SELECT C.custid, t.Sporttype, t.Bettype, C.Discount
			FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.CustDiscount3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3,4) AND Enabled = 1
				AND c.Discount <> csa.Discount
			UNION ALL --Direct master
			SELECT C.custid, t.Sporttype, t.Bettype, C.Discount
			FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.CustDiscount3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3) AND Enabled = 1
				AND c.Discount <> csa.Discount
			UNION ALL --Direct agent
			SELECT C.custid, t.Sporttype, t.Bettype, C.Discount
			FROM dbo.CustDiscount3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.CustDiscount3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 2 AND Enabled = 1
				AND c.Discount <> csa.Discount

			--Member Level
			INSERT INTO #MemberList_CommSetting (custid, Sporttype, Bettype, SuperDiscount, MasterDiscount, AgentDiscount, PlayerDiscount)
			SELECT C.custid, t.Sporttype, t.Bettype, C.SuperDiscount, C.MasterDiscount, C.AgentDiscount, C.PlayerDiscount
			FROM dbo.CustDiscount3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.CustDiscount3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND ( C.SuperDiscount<> csm.SuperDiscount
					OR C.MasterDiscount <> csm.MasterDiscount
					OR C.AgentDiscount	 <> csm.AgentDiscount			
					OR C.PlayerDiscount <> csm.PlayerDiscount
					)
			UNION ALL --Direct Master
			SELECT C.custid, t.Sporttype, t.Bettype, C.SuperDiscount, C.MasterDiscount, C.AgentDiscount, C.PlayerDiscount
			FROM dbo.CustDiscount3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.CustDiscount3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND ( C.SuperDiscount<> csm.SuperDiscount
					OR C.MasterDiscount <> csm.MasterDiscount
					OR C.AgentDiscount	 <> csm.AgentDiscount			
					OR C.PlayerDiscount <> csm.PlayerDiscount
					)
			UNION ALL --Direct agent
			SELECT C.custid, t.Sporttype, t.Bettype, C.SuperDiscount, C.MasterDiscount, C.AgentDiscount, C.PlayerDiscount
			FROM dbo.CustDiscount3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.recommend = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.CustDiscount3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND ( C.SuperDiscount<> csm.SuperDiscount
					OR C.MasterDiscount <> csm.MasterDiscount
					OR C.AgentDiscount	 <> csm.AgentDiscount			
					OR C.PlayerDiscount <> csm.PlayerDiscount
					)
			UNION ALL --Direct member
			SELECT C.custid, t.Sporttype, t.Bettype, C.SuperDiscount, C.MasterDiscount, C.AgentDiscount, C.PlayerDiscount
			FROM dbo.CustDiscount3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 1
				INNER JOIN dbo.CustDiscount3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Commission' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND ( C.SuperDiscount<> csm.SuperDiscount
					OR C.MasterDiscount <> csm.MasterDiscount
					OR C.AgentDiscount	 <> csm.AgentDiscount			
					OR C.PlayerDiscount <> csm.PlayerDiscount
					)

			UPDATE csa
			SET csa.Discount = cs.Discount       
			FROM dbo.CustDiscount3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMAList_CommSetting cs WITH(NOLOCK) ON cs.custid = csa.CustID AND csa.SportType = cs.Sporttype AND csa.BetType = cs.Bettype

			UPDATE csm
			SET csm.SuperDiscount = cs.SuperDiscount,       
				csm.MasterDiscount = cs.MasterDiscount,   
				csm.AgentDiscount = cs.AgentDiscount,
				csm.PlayerDiscount = cs.PlayerDiscount
			FROM dbo.CustDiscount3rd_Member csm WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberList_CommSetting cs WITH(NOLOCK) ON cs.custid = csm.CustID AND csm.SportType = cs.Sporttype AND csm.BetType = cs.Bettype
		END
		---------------------------------------Winloss Setting-------------------------------------------------	
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Win Loss Limit' AND IsDefault = 0)	
		BEGIN
			--Agent Level
			INSERT INTO #SMAList_WL (CustId, Sporttype, Bettype, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Agent C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.CustWinLossLimit_Agent csa WITH(NOLOCK) ON csa.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3,4) AND Enabled = 1
				AND (C.MaxLossLimit <> csa.MaxLossLimit
					OR (C.MaxWinLimit <> csa.MaxWinLimit AND t.HaveWinLimit = 1)
					OR C.IsAutoReset <> csa.IsAutoReset
					)
			UNION ALL --direct master
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Agent C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.CustWinLossLimit_Agent csa WITH(NOLOCK) ON csa.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3) AND Enabled = 1
				AND (C.MaxLossLimit <> csa.MaxLossLimit
					OR (C.MaxWinLimit <> csa.MaxWinLimit AND t.HaveWinLimit = 1)
					OR C.IsAutoReset <> csa.IsAutoReset
					)
			UNION ALL --direct agent
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Agent C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.CustWinLossLimit_Agent csa WITH(NOLOCK) ON csa.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid = 2 AND Enabled = 1
				AND (C.MaxLossLimit <> csa.MaxLossLimit
					OR (C.MaxWinLimit <> csa.MaxWinLimit AND t.HaveWinLimit = 1)
					OR C.IsAutoReset <> csa.IsAutoReset
					)

			--Member Level
			INSERT INTO #MemberList_WL (CustId, Sporttype, Bettype, MaxWinLimit, MaxLossLimit, IsAutoReset)
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.CustWinLossLimit_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
					AND (C.MaxLossLimit <> csm.MaxLossLimit
						OR (C.MaxWinLimit <> csm.MaxWinLimit AND t.HaveWinLimit = 1)
						OR C.IsAutoReset <> csm.IsAutoReset
						)
			UNION ALL --direct master
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.CustWinLossLimit_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
					AND (C.MaxLossLimit <> csm.MaxLossLimit
						OR (C.MaxWinLimit <> csm.MaxWinLimit AND t.HaveWinLimit = 1)
						OR C.IsAutoReset <> csm.IsAutoReset
						)
			UNION ALL --direct agent
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.recommend = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.CustWinLossLimit_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
					AND (C.MaxLossLimit <> csm.MaxLossLimit
						OR (C.MaxWinLimit <> csm.MaxWinLimit AND t.HaveWinLimit = 1)
						OR C.IsAutoReset <> csm.IsAutoReset
						)
			UNION ALL --direct member
			SELECT ci.custid, t.SportType, t.BetType
				, CASE WHEN t.HaveWinLimit = 1 THEN c.MaxWinLimit ELSE NULL END
				, C.MaxLossLimit, C.IsAutoReset
			FROM dbo.CustWinLossLimit_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 1
				INNER JOIN dbo.CustWinLossLimit_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Win Loss Limit' AND t.IsDefault = 0
					AND C.bettype = t.CopyFromBetType AND C.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
					AND (C.MaxLossLimit <> csm.MaxLossLimit
						OR (C.MaxWinLimit <> csm.MaxWinLimit AND t.HaveWinLimit = 1)
						OR C.IsAutoReset <> csm.IsAutoReset
						)

			UPDATE csa
			SET csa.MaxWinLimit = cs.MaxWinLimiT,csa.MaxLossLimit = cs.MaxLossLimit, csa.IsAutoReset = cs.IsAutoReset     
			FROM dbo.CustWinLossLimit_Agent csa WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMAList_WL cs WITH(NOLOCK) ON cs.custid = csa.CustID AND csa.SportType = cs.Sporttype AND csa.BetType = cs.Bettype

			UPDATE csm
			SET csm.MaxWinLimit = cs.MaxWinLimit,csm.MaxLossLimit = cs.MaxLossLimit, csm.IsAutoReset = cs.IsAutoReset
			FROM dbo.CustWinLossLimit_Member csm WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberList_WL cs WITH(NOLOCK) ON cs.custid = csm.CustID AND csm.SportType = cs.Sporttype AND csm.BetType = cs.Bettype
		END	

		---------------------------------------Bet Setting-------------------------------------------------	
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Bet Setting' AND IsDefault = 0)
		BEGIN
			--Agent Level
			INSERT INTO #SMAList_BetSettingGame (custid, Sporttype, Bettype, Minbet, MaxBet, MaxPerMatch, MaxPerNumber)
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.BetSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3,4) AND Enabled = 1
				AND (c.MinBet <> csa.MinBet
					OR c.MaxBet <> csa.MaxBet
					OR (c.MaxPerMatch <> csa.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csa.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)
			UNION ALL --direct master
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				INNER JOIN dbo.BetSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid IN (2,3) AND Enabled = 1
				AND (c.MinBet <> csa.MinBet
					OR c.MaxBet <> csa.MaxBet
					OR (c.MaxPerMatch <> csa.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csa.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)
			UNION ALL --direct agent
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Agent c WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 2
				INNER JOIN dbo.BetSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
				INNER JOIN #TempConfig t 
					ON csa.SportType = t.SportType AND csa.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 2 AND Enabled = 1
				AND (c.MinBet <> csa.MinBet
					OR c.MaxBet <> csa.MaxBet
					OR (c.MaxPerMatch <> csa.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csa.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)

			--Member Level
			INSERT INTO #MemberList_BetSettingGame (custid, Sporttype, Bettype, Minbet, MaxBet, MaxPerMatch, MaxPerNumber)
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				INNER JOIN dbo.BetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND (c.MinBet <> csm.MinBet
					OR c.MaxBet <> csm.MaxBet
					OR (c.MaxPerMatch <> csm.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csm.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)
			UNION ALL --direct master
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.roleid = 3
				INNER JOIN dbo.BetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND (c.MinBet <> csm.MinBet
					OR c.MaxBet <> csm.MaxBet
					OR (c.MaxPerMatch <> csm.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csm.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)
			UNION ALL --direct agent
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.recommend = s.CustID AND s.roleid = 2
				INNER JOIN dbo.BetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND (c.MinBet <> csm.MinBet
					OR c.MaxBet <> csm.MaxBet
					OR (c.MaxPerMatch <> csm.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csm.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)
			UNION ALL --direct member
			SELECT C.custid, t.Sporttype, t.Bettype, c.Minbet, c.MaxBet
					, CASE WHEN t.HaveMaxPerMatch = 1 THEN c.MaxPerMatch ELSE NULL END
					, CASE WHEN t.HaveMaxPerNumber = 1 THEN c.MaxPerNumber ELSE NULL END
			FROM dbo.BetSetting3rd_Member C WITH(NOLOCK) 
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.roleid = 1
				INNER JOIN dbo.BetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = C.custid
				INNER JOIN #TempConfig t 
					ON csm.SportType = t.SportType AND csm.BetType = t.BetType AND t.SettingName = 'Bet Setting' AND t.IsDefault = 0
					AND c.bettype = t.CopyFromBetType AND c.SportType = t.CopyFromSportType
			WHERE ci.roleid = 1 AND Enabled = 1
				AND (c.MinBet <> csm.MinBet
					OR c.MaxBet <> csm.MaxBet
					OR (c.MaxPerMatch <> csm.MaxPerMatch AND t.HaveMaxPerMatch = 1)
					OR (c.MaxPerNumber <> csm.MaxPerNumber AND t.HaveMaxPerNumber = 1)
					)

			UPDATE csa
			SET csa.MinBet = cs.Minbet,       
				csa.MaxBet = cs.MaxBet,   
				csa.MaxPerMatch = cs.MaxPerMatch, 
				csa.MaxPerNumber = cs.MaxPerNumber,
				csa.RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMAList_BetSettingGame cs WITH(NOLOCK) ON cs.custid = csa.CustID AND csa.SportType = cs.Sporttype AND csa.BetType = cs.Bettype

			UPDATE csm
			SET csm.MinBet = cs.Minbet,       
				csm.MaxBet = cs.MaxBet,   
				csm.MaxPerMatch = cs.MaxPerMatch, 
				csm.MaxPerNumber = cs.MaxPerNumber,
				csm.RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.BetSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberList_BetSettingGame cs WITH(NOLOCK) ON cs.custid = csm.CustID AND csm.SportType = cs.Sporttype AND csm.BetType = cs.Bettype
		END
	END

	IF @StepID = 7 --Adjust Status
	BEGIN
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Product Status' AND IsDefault = 0)
		BEGIN
			INSERT INTO #Custlist_Status(custid,bitmapOrder,IsDisabled)
			SELECT c.CustID,t.bitmapOrder,isDisabled_S.value
			FROM dbo.CustProductStatus C WITH(NOLOCK)
				CROSS JOIN #TempConfig t
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsDisabled, t.bitmapOrder) as isDisabled
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsHidden, t.bitmapOrder) as isHidden
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #supers s WITH (NOLOCK) ON ci.srecommend = s.SuperID
				--INNER JOIN dbo.CustProductStatus csm WITH(NOLOCK) ON csm.custid = C.custid
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(c.bitmapIsDisabled, t.bitmapOrder_Source) as isDisabled_S
			WHERE ci.roleid IN (1,2,3,4) AND Enabled = 1
				AND t.SettingName = 'Product Status' AND t.IsDefault = 0
				AND (isDisabled.value <> isDisabled_S.value OR isHidden.value <> 0)
			UNION ALL --direct master
			SELECT c.CustID,t.bitmapOrder,isDisabled_S.value
			FROM dbo.CustProductStatus C WITH(NOLOCK)
				CROSS JOIN #TempConfig t
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsDisabled, t.bitmapOrder) as isDisabled
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsHidden, t.bitmapOrder) as isHidden
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.mrecommend = s.CustID AND s.RoleID = 3
				--INNER JOIN dbo.CustProductStatus csm WITH(NOLOCK) ON csm.custid = C.custid
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(c.bitmapIsDisabled, t.bitmapOrder_Source) as isDisabled_S
			WHERE ci.roleid IN (1,2,3) AND Enabled = 1
				AND t.SettingName = 'Product Status' AND t.IsDefault = 0
				AND (isDisabled.value <> isDisabled_S.value OR isHidden.value <> 0)
			UNION ALL --direct agent
			SELECT c.CustID,t.bitmapOrder,isDisabled_S.value
			FROM dbo.CustProductStatus C WITH(NOLOCK)
				CROSS JOIN #TempConfig t
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsDisabled, t.bitmapOrder) as isDisabled
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsHidden, t.bitmapOrder) as isHidden
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.recommend = s.CustID AND s.RoleID = 2
				--INNER JOIN dbo.CustProductStatus csm WITH(NOLOCK) ON csm.custid = C.custid
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(c.bitmapIsDisabled, t.bitmapOrder_Source) as isDisabled_S
			WHERE ci.roleid IN (1,2) AND Enabled = 1
				AND t.SettingName = 'Product Status' AND t.IsDefault = 0
				AND (isDisabled.value <> isDisabled_S.value OR isHidden.value <> 0)
			UNION ALL --direct member
			SELECT c.CustID,t.bitmapOrder,isDisabled_S.value
			FROM dbo.CustProductStatus C WITH(NOLOCK)
				CROSS JOIN #TempConfig t
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsDisabled, t.bitmapOrder) as isDisabled
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(C.bitmapIsHidden, t.bitmapOrder) as isHidden
				INNER JOIN custInfo ci WITH(NOLOCK) ON C.CustID = ci.custid
				INNER JOIN #DirectAcc s WITH (NOLOCK) ON ci.custid = s.CustID AND s.RoleID = 1
				--INNER JOIN dbo.CustProductStatus csm WITH(NOLOCK) ON csm.custid = C.custid
				CROSS APPLY dbo.f_CustSetting_ProductStatusSel(c.bitmapIsDisabled, t.bitmapOrder_Source) as isDisabled_S
			WHERE ci.roleid = 1 AND Enabled = 1
				AND t.SettingName = 'Product Status' AND t.IsDefault = 0
				AND (isDisabled.value <> isDisabled_S.value OR isHidden.value <> 0)

			BEGIN
				UPDATE #TempConfig SET IsFinished = 0

				WHILE 1 = 1
				BEGIN 
					UPDATE TOP (1) t
					SET t.IsFinished = 1,
						@BitMapOrder = t.bitmapOrder
					FROM #TempConfig t
					WHERE t.IsFinished = 0
						AND t.IsDefault = 0
						AND t.SettingName = 'Product Status'

					IF @@ROWCOUNT = 0
						BREAK

					WHILE 1 = 1
					BEGIN
						TRUNCATE TABLE #CustList_Status_Batch

						DELETE TOP(@BatchNum) t
						OUTPUT deleted.custid,deleted.IsDisabled INTO #CustList_Status_Batch(custid,IsDisabled)
						FROM #Custlist_Status t
						WHERE t.bitmapOrder = @BitMapOrder

						IF @@ROWCOUNT = 0
							BREAK

						UPDATE cs
						SET cs.bitmapIsHidden = hid.NewBitmap,
							bitmapIsDisabled = dis.NewBitmap	
						FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
							INNER JOIN #CustList_Status_Batch ci ON cs.CustID = ci.CustID
							CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
							CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,ci.IsDisabled) as Dis
					END
				END
			END
		END
	END

	CREATE TABLE #CustomerTemp (CustID INT, RoleID INT)
	CREATE TABLE #HeadlineSBOnly (CustID INT, Groupid INT)
	CREATE TABLE #CustList_ST (custid INT)
	CREATE TABLE #CustList_Updated (custid INT)
	CREATE TABLE #tmp_ExcludeHeadline (custid INT)
	DECLARE @HeadLineList VARCHAR(MAX)

	IF @StepID = 8 --Disable status headline
	BEGIN
		UPDATE #TempConfig SET IsFinished = 0

		WHILE 1 = 1
		BEGIN 
			UPDATE TOP (1) t
			SET t.IsFinished = 1,
				@BitMapOrder = t.bitmapOrder,
				@HeadLineList = t.SpecialRequirement
			FROM #TempConfig t
			WHERE t.IsFinished = 0
				AND t.SettingName = 'Product Status'

			IF @@ROWCOUNT = 0
				BREAK

			TRUNCATE TABLE #CustomerTemp
			TRUNCATE TABLE #HeadlineSBOnly
			TRUNCATE TABLE #CustList_ST
			TRUNCATE TABLE #CustList_Updated
			TRUNCATE TABLE #tmp_ExcludeHeadline

			INSERT INTO #tmp_ExcludeHeadline(custid)
			SELECT value
			FROM STRING_SPLIT(@HeadLineList,',') 
			WHERE value <> ''

			INSERT INTO #HeadlineSBOnly (CustID, Groupid)
			SELECT c.custid, groupid  
			FROM custinfo c WITH (NOLOCK)
				INNER JOIN CustGroupHeadline cs with (nolock) on cs.custid=c.custid
				INNER JOIN #tmp_ExcludeHeadline t ON c.custid = t.custid

			INSERT INTO #CustomerTemp (CustID, RoleID)
			SELECT  c.custid, c.roleid
			FROM customer c WITH (NOLOCK )
				INNER JOIN custinfo cu WITH (NOLOCK) ON cu.custid=c.custid
				INNER JOIN custAccount ca WITH (NOLOCK) ON ca.custid=c.custid
				INNER JOIN #HeadlineSBOnly t ON t.GroupID=ca.groupID
				INNER JOIN [site] s WITH (NOLOCK ) ON c.[site] = s.[site]
			WHERE c.username NOT LIKE '3rdSuper%'
				AND s.islicensee = 0
				AND cu.[enabled] = 1
				
			--Super
			INSERT INTO #CustList_ST (custid)
			SELECT CS.CustID
			FROM dbo.CustProductStatus cs WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
				INNER JOIN #CustomerTemp s WITH (NOLOCK) ON ci.srecommend = s.custid AND s.RoleID = 4
			WHERE ci.Enabled = 1

			--Master
			INSERT INTO #CustList_ST (custid)
			SELECT CS.CustID
			FROM dbo.CustProductStatus cs WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
				INNER JOIN #CustomerTemp m WITH (NOLOCK) ON ci.mrecommend = m.CustID AND m.RoleID = 3
			WHERE ci.Enabled = 1

			--Agent
			INSERT INTO #CustList_ST (custid)
			SELECT CS.CustID
			FROM dbo.CustProductStatus cs WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
				INNER JOIN #CustomerTemp m WITH (NOLOCK) ON ci.recommend = m.CustID AND m.RoleID = 2
			WHERE ci.Enabled = 1

			--Member
			INSERT INTO #CustList_ST (custid)
			SELECT CS.CustID
			FROM dbo.CustProductStatus cs WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
				INNER JOIN #CustomerTemp m WITH (NOLOCK) ON ci.custid = m.CustID AND m.RoleID = 1
			WHERE ci.[Enabled] = 1

			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #CustList_Updated
		
				DELETE TOP (@BatchNum) t
				OUTPUT deleted.custid INTO #CustList_Updated(custid)
				FROM #CustList_ST t
				
				IF @@ROWCOUNT = 0
					BREAK	

				UPDATE cs
				SET cs.bitmapIsHidden = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitmapOrder,0)),
					bitmapIsDisabled = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitmapOrder,1)) 	
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #CustList_Updated CI WITH(NOLOCK) ON cs.CustID = ci.CustID
			END
		END
	END

	DROP TABLE #TempConfig
	DROP TABLE #MemberTemp
	DROP TABLE #SMATemp
	DROP TABLE #CustSettingTmp
	DROP TABLE #CustSettingTmpBatch
	DROP TABLE #tmpSTList
	DROP TABLE #CustTempBatch
	DROP TABLE #AgentGroupPT
	DROP TABLE #MemberList_BetSetting
	DROP TABLE #MemberList_CommSetting 
	DROP TABLE #MemberList_PT
	DROP TABLE #MemberList_WL
	DROP TABLE #SMAList_BetSetting
	DROP TABLE #SMAList_CommSetting
	DROP TABLE #SMAList_PT
	DROP TABLE #SMAList_WL
	DROP TABLE #Super_WrongPT
	DROP TABLE #Supers
	DROP TABLE #Custlist_Status
	DROP TABLE #CustList_Status_Batch
	DROP TABLE #CustList_ST
	DROP TABLE #CustomerTemp
	DROP TABLE #CustList_Updated
	DROP TABLE #HeadlineSBOnly
	DROP TABLE #tmp_ExcludeHeadline
	DROP TABLE #DirectAcc
	DROP TABLE #DummyAcc
	DROP TABLE #MemberList_BetSettingGame
	DROP TABLE #SMAList_BetSettingGame
END
GO


