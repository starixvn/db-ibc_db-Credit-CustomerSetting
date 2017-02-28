ALTER PROCEDURE dbo.Acc_CustSetting_StakeLevelUpd 
		@CustID			INT
	,	@StakeLevel		VARCHAR(MAX)
	,	@SubAccID		INT				= 0
	,	@UserID			INT
	,	@IP				VARCHAR(50)		= ''
	,	@ErrCode		INT				= 0		OUTPUT
	,	@MsgType		INT				= 0		OUTPUT
	,	@ErrMsg			NVARCHAR(200)	= ''	OUTPUT
AS
/*
	Created: 20160115@Billy
	Task : Update Customer's Stake Level Settings - [Redmine: #51026]
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20160404@Billy: Integrate Group Stake Level Setting for DCS - [Redmine: #54994]
		- 20160704@Winnie: Fix bug copy member settting type =7 & =8
		- 20161005@Elodie: Update LastUpdated field - [Redmine: #54994]
	Param's Explanation:
		@StakeLevel:
		<ROOT>
				<StakeLevel
						SportType="211"
						BetType="2401" 
						StakeLevelList="1,2,3,4,5"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @iDoc INT;
	
	DECLARE @startRun					DATETIME
		,	@endRun						DATETIME
		,	@duration					INT;
		
	DECLARE @logSpData					NVARCHAR(MAX)
		,	@logSpData_Old				NVARCHAR(MAX)
		,	@xml						XML;

	DECLARE	@ProductID					TINYINT
		,	@ProductName				VARCHAR(50)
		,	@SettingLevel				TINYINT
		--,	@SettingType				SMALLINT;
		
	DECLARE @AgentID					INT
		,	@MasterID					INT
		,	@SuperID					INT
		,	@RoleID						INT;

	DECLARE	@StakeLevelExecRep			VARCHAR(MAX);

	CREATE TABLE	#tmpStake (
						ID				INT IDENTITY (1,1)
					,	SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelList	VARCHAR(200)
					,	PRIMARY KEY CLUSTERED (SportType, BetType)
					);

	CREATE TABLE	#StakeLevelList_Excluded (
						BetType				INT				NOT NULL
					,	StakeLevelList_old	VARCHAR(200)	NULL
					,	ExcludedLevel		VARCHAR(200)	NULL
					);

	CREATE TABLE #CustStakeLevelDownlines (
						CustID					INT 
					,	DirectUplineID			INT		
					,	RoleID					TINYINT
					,	BetType					INT
					,	StakeLevelList			VARCHAR(200)
					,	StakeLevelList_New		VARCHAR(200)
					,	StakeLevelList_Upline	VARCHAR(200)
					,	PRIMARY KEY CLUSTERED (CustID, BetType)
					);

	--Check if XML is null or empty
	IF	@StakeLevel IS NULL OR @StakeLevel = ''
		RETURN;

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= '';

	SET	@startRun = GETDATE();

	--Check disable user
	EXECUTE	dbo.Acc_CustomerSelCheckEnable 
				@custid			= @custid
			,	@ErrCode		= @ErrCode	OUTPUT
			,	@ErrMsg			= @ErrMsg	OUTPUT;

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101;
		RETURN;
	END;
	
	--Check belonging
	EXECUTE dbo.Age_CustomerSelCheckBelonging 
				@SessionCustID	= @UserID 
			,	@custid			= @CustID		
			,	@roleid			= @RoleID	OUTPUT;
	IF	@RoleID = 0
	BEGIN
		SET	@MsgType = 101;
		SET	@ErrCode = 101;
		SET	@ErrMsg = 'Users are not in the same line!';
		RETURN;
	END;

	--Get line information
	SELECT	@AgentID  = recommend
		,	@MasterID = mrecommend
		,	@SuperID  = srecommend
		,	@RoleID   = RoleID
	FROM	dbo.custInfo WITH (NOLOCK)
	WHERE	custid = @CustID;

	--Check Allowed downlines	
	EXECUTE dbo.Acc_CustomerSelCheckAllowedDownlines 
				@custid		= @custid
			,	@roleid		= @roleid
			,	@isExecRep	= 1
			,	@Language	= 'E'
			,	@ErrCode	= @ErrCode		OUTPUT
			,	@ErrMsg		= @ErrMsg		OUTPUT;

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101;
		RETURN;
	END;

	--Parse XML
	EXECUTE	sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel;

	INSERT INTO #tmpStake
		(	SportType   , BetType   , StakeLevelList)
	SELECT	ox.SportType, ox.BetType, ox.StakeLevelList
	FROM OPENXML (@iDoc, '/ROOT/StakeLevel', 1) 
	WITH (
		SportType		SMALLINT
	,	BetType			INT
	,	StakeLevelList	VARCHAR(200)	
	) AS ox;

	EXECUTE sp_xml_removedocument @iDoc;

	EXECUTE dbo.Acc_CustSetting_StakeLevelCheck 
				@CustID		= @CustID
			,	@RoleID		= @RoleID
			,	@AgentID	= @AgentID
			,	@MasterID	= @MasterID
			,	@SuperID	= @SuperID
			,	@StakeLevel	= @StakeLevel
			,	@ErrCode	= @ErrCode		OUTPUT
			,	@MsgType	= @MsgType		OUTPUT
			,	@ErrMsg		= @ErrMsg		OUTPUT;

	IF @ErrCode <> 0
		RETURN;

	-- Update Stake Level
	IF	@RoleID = 1
	BEGIN
		---- Only processing if being different
		--DELETE	ts
		--FROM		#tmpStake AS ts
		--INNER JOIN	dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)
		--		ON	ts.BetType = cslm.BetType
		--WHERE	cslm.CustID = @CustID 
		--	AND	ts.StakeLevelList = cslm.StakeLevelList;

		INSERT INTO	#StakeLevelList_Excluded (BetType, StakeLevelList_old, ExcludedLevel)
		SELECT	cslm.BetType
			,	cslm.StakeLevelList
			,	NULL
		FROM	dbo.CustStakeLevel_Member AS cslm WITH (NOLOCK)
		INNER JOIN	#tmpStake AS ts
				ON	ts.BetType = cslm.BetType
		WHERE	cslm.CustID = @CustID;

		-- Update current customer's stake level
		UPDATE	cslm	WITH(ROWLOCK,UPDLOCK)
		SET		cslm.StakeLevelList = ts.StakeLevelList
				, cslm.LastUpdated = GETDATE()
		FROM		dbo.CustStakeLevel_Member AS cslm
		INNER JOIN	#tmpStake ts
				ON	ts.BetType = cslm.BetType
		WHERE	cslm.CustID = @CustID;
	END;
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		---- Downline Processing: only processing if being different.
		--DELETE	ts
		--FROM		#tmpStake ts
		--INNER JOIN	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
		--		ON	ts.BetType = csla.BetType
		--WHERE	csla.CustID = @CustID 
		--	AND	ts.StakeLevelList = csla.StakeLevelList;

		INSERT INTO	#StakeLevelList_Excluded	-- Get excluded level compared with old 
		SELECT	csla.BetType
			,	csla.StakeLevelList	AS StakeLevelList_old 
			,	(
					SELECT	*
					FROM	dbo.f_StakeLevelcorrectString (csla.StakeLevelList, ts.StakeLevelList)
				)	AS ExcludedLevel
		FROM		dbo.CustStakeLevel_Agent	AS csla WITH (NOLOCK)
		INNER JOIN	#tmpStake					AS ts 
				ON	ts.BetType = csla.BetType
		WHERE csla.CustID = @CustID;
		
		-- Update current customer's stake level
		UPDATE	csla	WITH(ROWLOCK,UPDLOCK)
		SET		csla.StakeLevelList = ts.StakeLevelList
		FROM		dbo.CustStakeLevel_Agent AS csla
		INNER JOIN	#tmpStake ts
				ON	csla.BetType = ts.BetType
		WHERE	csla.CustID = @CustID;
		
		IF EXISTS (SELECT TOP(1) 1 FROM #tmpStake)
		BEGIN
			-- Starting Update downline process
			IF @RoleID = 4
			BEGIN
				INSERT INTO #CustStakeLevelDownlines (
								CustID
							,	DirectUplineID
							,	RoleID
							,	BetType
							,	StakeLevelList
							,	StakeLevelList_New
							,	StakeLevelList_Upline
							)
				SELECT			ci.custid				AS CustID
							,	CASE 
									WHEN ci.roleid = 3 THEN srecommend
									WHEN ci.roleid = 2 THEN mrecommend	
								END						AS DirectUplineID		
							,	ci.roleid				AS RoleID
							,	csla.BetType			AS BetType
							,	csla.StakeLevelList		AS StakeLevelList
							,	csla.StakeLevelList		AS StakeLevelList_New
							,	ts.StakeLevelList		AS StakeLevelList_Upline
				FROM		dbo.custInfo				AS ci	WITH(NOLOCK)
				INNER JOIN	dbo.CustStakeLevel_Agent	AS csla	WITH(NOLOCK) 
						ON	csla.CustID = ci.custid
				INNER JOIN	#tmpStake					AS ts 
						ON	ts.BetType = csla.BetType
				WHERE	ci.srecommend = @CustID 
					AND	ci.roleid IN (2, 3)
				UNION ALL
				SELECT			ci.custid				AS CustID
							,	ci.recommend			AS DirectUplineID		
							,	ci.roleid				AS RoleID
							,	cslm.BetType			AS BetType
							,	cslm.StakeLevelList		AS StakeLevelList
							,	cslm.StakeLevelList		AS StakeLevelList_New
							,	ts.StakeLevelList		AS StakeLevelList_Upline
				FROM		dbo.custInfo				AS ci	WITH(NOLOCK)
				INNER JOIN	dbo.CustStakeLevel_Member	AS cslm	WITH(NOLOCK) 
						ON	cslm.CustID = ci.custid
				INNER JOIN	#tmpStake					AS ts 
						ON	ts.BetType = cslm.BetType
				WHERE	ci.srecommend = @CustID 
					AND	ci.roleid = 1;
			END;
			ELSE IF @RoleID = 3
			BEGIN
				INSERT INTO #CustStakeLevelDownlines (
								CustID
							,	DirectUplineID
							,	RoleID
							,	BetType
							,	StakeLevelList
							,	StakeLevelList_New
							,	StakeLevelList_Upline
							)
				SELECT			ci.custid				AS CustID
							,	ci.mrecommend			AS DirectUplineID		
							,	ci.roleid				AS RoleID
							,	csla.BetType			AS BetType
							,	csla.StakeLevelList		AS StakeLevelList
							,	csla.StakeLevelList		AS StakeLevelList_New
							,	ts.StakeLevelList		AS StakeLevelList_Upline
				FROM		dbo.custInfo				AS ci	WITH(NOLOCK)
				INNER JOIN	dbo.CustStakeLevel_Agent	AS csla	WITH(NOLOCK) 
						ON	csla.CustID = ci.custid
				INNER JOIN	#tmpStake					AS ts 
						ON	ts.BetType = csla.BetType
				WHERE	ci.mrecommend = @CustID 
					AND	ci.roleid = 2
				UNION ALL
				SELECT			ci.custid				AS CustID
							,	ci.recommend			AS DirectUplineID		
							,	ci.roleid				AS RoleID
							,	cslm.BetType			AS BetType
							,	cslm.StakeLevelList		AS StakeLevelList
							,	cslm.StakeLevelList		AS StakeLevelList_New
							,	ts.StakeLevelList		AS StakeLevelList_Upline
				FROM		dbo.custInfo				AS ci	WITH(NOLOCK)
				INNER JOIN	dbo.CustStakeLevel_Member	AS cslm	WITH(NOLOCK) 
						ON	cslm.CustID = ci.custid
				INNER JOIN	#tmpStake					AS ts 
						ON	ts.BetType = cslm.BetType
				WHERE	ci.mrecommend = @CustID 
					AND	ci.roleid = 1;
			END;
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #CustStakeLevelDownlines (
								CustID
							,	DirectUplineID
							,	RoleID
							,	BetType
							,	StakeLevelList
							,	StakeLevelList_New
							,	StakeLevelList_Upline
							)
				SELECT			ci.custid				AS CustID
							,	ci.recommend			AS DirectUplineID		
							,	ci.roleid				AS RoleID
							,	cslm.BetType			AS BetType
							,	cslm.StakeLevelList		AS StakeLevelList
							,	cslm.StakeLevelList		AS StakeLevelList_New
							,	ts.StakeLevelList		AS StakeLevelList_Upline
				FROM		dbo.custInfo				AS ci WITH(NOLOCK)
				INNER JOIN	dbo.CustStakeLevel_Member	AS cslm WITH(NOLOCK) 
						ON	cslm.CustID = ci.custid
				INNER JOIN	#tmpStake					AS ts 
						ON	ts.BetType = cslm.BetType
				WHERE	ci.recommend = @CustID 
					AND	ci.roleid = 1;
			END;	
			
			-- Remove level excluded
			UPDATE	csld
			SET		csld.StakeLevelList_New = (SELECT * FROM dbo.f_StakeLevelcorrectString (csld.StakeLevelList, slle.ExcludedLevel))
			FROM		#CustStakeLevelDownlines AS csld
			INNER JOIN	#StakeLevelList_Excluded AS slle 
					ON	slle.BetType = csld.BetType
			WHERE	csld.StakeLevelList_New <> ''; 

			-- Correct downline --
				-- Update Downlines: Get lowest if Super/Master/Agent changed from none
			UPDATE	csld
			SET		csld.StakeLevelList_New = NULL
			FROM		#CustStakeLevelDownlines AS csld
			INNER JOIN	#StakeLevelList_Excluded AS slle
					ON	slle.BetType = csld.BetType
			WHERE	slle.StakeLevelList_old = '';
				
			UPDATE	csld
			SET		csld.StakeLevelList_New = sr.LowestStakeLevel
			FROM	#CustStakeLevelDownlines AS csld
			CROSS APPLY (
				SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
				FROM (
					SELECT	CAST(val AS INT) AS val
					FROM	dbo.strSplit(csld.StakeLevelList_Upline, ',')
				) AS ss
				INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
						ON	ss.val = sl.StakeLevelID
				ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
			) sr
			WHERE csld.StakeLevelList_New IS NULL;

				-- Update masters: Get lowest value of Super if master has no value
			IF	@RoleID = 4
			BEGIN
				UPDATE	csld
				SET		csld.StakeLevelList_New = sr.LowestStakeLevel
				FROM	#CustStakeLevelDownlines AS csld
				CROSS APPLY (
					SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
					FROM (
						SELECT	CAST(val AS INT) AS val
						FROM	dbo.strSplit(csld.StakeLevelList_Upline, ',')
					) AS ss
					INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
							ON	ss.val = sl.StakeLevelID
					ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
				) sr
				WHERE	csld.RoleID = 3
					AND	csld.StakeLevelList_New = '';
			END;

				-- Update agents: Get lowest value of Master if agent has no value
			IF	@RoleID = 4
			BEGIN
				UPDATE	csld
				SET		csld.StakeLevelList_New = sr.LowestStakeLevel
				FROM		#CustStakeLevelDownlines AS csld
				INNER JOIN	#CustStakeLevelDownlines AS csld_upline
						ON	csld.DirectUplineID = csld_upline.CustID
						AND	csld_upline.BetType = csld.BetType
						AND	csld_upline.StakeLevelList_New <> ''
				CROSS APPLY (
					SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
					FROM (
						SELECT	CAST(val AS INT) AS val
						FROM	dbo.strSplit(csld_upline.StakeLevelList_New, ',')
					) AS ss
					INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
							ON	ss.val = sl.StakeLevelID
					ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
				) sr
				WHERE	csld.RoleID = 2
					AND	csld.StakeLevelList_New = '';
			END;
			ELSE IF	@RoleID = 3
			BEGIN
				UPDATE	csld
				SET		csld.StakeLevelList_New = sr.LowestStakeLevel
				FROM	#CustStakeLevelDownlines AS csld
				CROSS APPLY (
					SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
					FROM (
						SELECT	CAST(val AS INT) AS val
						FROM	dbo.strSplit(csld.StakeLevelList_Upline, ',')
					) AS ss
					INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
							ON	ss.val = sl.StakeLevelID
					ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
				) sr
				WHERE	csld.RoleID = 2
					AND	csld.StakeLevelList_New = '';
			END;

				-- Update members: Get lowest value of Agent if member has no value
			IF	@RoleID IN (4, 3)
			BEGIN
				UPDATE	csld
				SET		csld.StakeLevelList_New = sr.LowestStakeLevel
				FROM		#CustStakeLevelDownlines AS csld
				INNER JOIN	#CustStakeLevelDownlines AS csld_upline
						ON	csld.DirectUplineID = csld_upline.CustID
						AND	csld_upline.BetType = csld.BetType
						AND	csld_upline.StakeLevelList_New <> ''
				CROSS APPLY (
					SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
					FROM (
						SELECT	CAST(val AS INT) AS val
						FROM	dbo.strSplit(csld_upline.StakeLevelList_New, ',')
					) AS ss
					INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
							ON	ss.val = sl.StakeLevelID
					ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
				) sr
				WHERE	csld.RoleID = 1
					AND	csld.StakeLevelList_New = '';
			END;
			ELSE IF	@RoleID = 2
			BEGIN
				UPDATE	csld
				SET		csld.StakeLevelList_New = sr.LowestStakeLevel
				FROM	#CustStakeLevelDownlines AS csld
				CROSS APPLY (
					SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
					FROM (
						SELECT	CAST(val AS INT) AS val
						FROM	dbo.strSplit(csld.StakeLevelList_Upline, ',')
					) AS ss
					INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
							ON	ss.val = sl.StakeLevelID
					ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
				) sr
				WHERE	csld.RoleID = 1
					AND	csld.StakeLevelList_New = '';
			END;
			
			-- No need to update if having the same value between old and new
			DELETE	#CustStakeLevelDownlines
			WHERE	StakeLevelList_New = StakeLevelList;
			
			-- Correct downlines via ExecRep
			ALTER TABLE #CustStakeLevelDownlines ADD ID INT IDENTITY (1,1);
			
			DECLARE @StartRow INT = 1, @MaxRow INT,@Threshold INT = 20000, @StopRow INT;
			
			SET @MaxRow = (SELECT MAX(ID) FROM #CustStakeLevelDownlines);
			
			IF	@Threshold >= @MaxRow
				SET	@Threshold = @MaxRow;
			
			SET @StopRow = @Threshold;
			
			IF EXISTS(SELECT TOP(1) 1 FROM #CustStakeLevelDownlines)
			BEGIN
				WHILE (0 = 0)
				BEGIN
					PRINT	@StartRow;
					PRINT	@StopRow;
					SET	@StakeLevelExecRep =	(
													SELECT	custid				AS CustID
														,	BetType				AS BetType
														,	StakeLevelList_new	AS StakeLevelList
													FROM	#CustStakeLevelDownlines
													WHERE	ID >= @StartRow 
														AND	ID <= @StopRow
													FOR XML RAW ('StakeLevel'), ROOT ('ROOT') 
												);
					
					-- Correct downlines via ExecRep
					EXECUTE	Acc_DynamicCustSetting3rd_02
								@CustID		= @CustID
							,	@RoleID		= @RoleID
							,	@StakeLevel	= @StakeLevelExecRep;
					
					IF	@StopRow = @MaxRow 
						BREAK;
					
					SET	@StartRow = @StopRow + 1;
					
					SET	@StopRow = 1 + @StopRow + @Threshold;
					
					IF	@StopRow >= @MaxRow
						SET	@StopRow = @MaxRow;
				END;
			END;
		END;
	END;

	------------------ START LOGGING ------------------

	-- Select ProductID and SettingLevel
	SELECT	@ProductID    = iq.ProductID
		,	@SettingLevel = iq.SettingLevel		
	FROM (	SELECT TOP(1) 
					psd.ProductID
				,	psd.SettingLevel
				,	psd.SettingType
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#tmpStake AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType IN (7, 8)
		 ) iq;

	-- Select ProductName
	SELECT	@ProductName = p.ProductName
	FROM	DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE	p.ProductID = @ProductID;

	-- Update log value
	IF	EXISTS (SELECT TOP 1 1
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#tmpStake AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType=7 )
	BEGIN
		UPDATE #StakeLevelList_Excluded
		SET	StakeLevelList_old = REPLACE(StakeLevelList_old, ',', ';');

		UPDATE #tmpStake
		SET StakeLevelList = REPLACE(StakeLevelList, ',', ';');

		WHILE 0 = 0
		BEGIN
			UPDATE	slle
			SET	slle.StakeLevelList_old = REPLACE(slle.StakeLevelList_old, sl.StakeLevelID, sl.StakeLevelValue)
			FROM		#StakeLevelList_Excluded AS slle
			CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
										,	CAST(sl.MinLabel AS VARCHAR(20)) + '-' + CAST(sl.MaxLabel AS VARCHAR(20)) AS StakeLevelValue
							FROM		dbo.strSplit(slle.StakeLevelList_old, ';') AS ss
							INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
									ON	ss.val = CAST(sl.StakeLevelID AS NVARCHAR(10))
							WHERE sl.GameGroupID=0
						) sl;

			IF	@@ROWCOUNT = 0
				BREAK;
		END;
	
		WHILE 0 = 0
		BEGIN
			UPDATE	ts
			SET	ts.StakeLevelList = REPLACE(ts.StakeLevelList, sl.StakeLevelID, sl.StakeLevelValue)
			FROM		#tmpStake AS ts
			CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
										,	CAST(sl.MinLabel AS VARCHAR(20)) + '-' + CAST(sl.MaxLabel AS VARCHAR(20)) AS StakeLevelValue
							FROM		dbo.strSplit(ts.StakeLevelList, ';') AS ss
							INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
									ON	ss.val = CAST(sl.StakeLevelID AS NVARCHAR(10))
							WHERE sl.GameGroupID=0
						) sl;

			IF	@@ROWCOUNT = 0
				BREAK;
		END;

		UPDATE #StakeLevelList_Excluded
		SET	StakeLevelList_old = REPLACE(StakeLevelList_old, ';', ',');

		UPDATE #tmpStake
		SET StakeLevelList = REPLACE(StakeLevelList, ';', ',');
	END;
	IF	EXISTS (SELECT TOP 1 1
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#tmpStake AS ts
					ON	ts.SportType = psd.SportType
					AND	ts.BetType = psd.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType=8 )
	BEGIN
		WHILE 0 = 0
		BEGIN
			UPDATE	slle
			SET	slle.StakeLevelList_old = REPLACE(slle.StakeLevelList_old, sl.StakeLevelID, sl.StakeLevelValue)
			FROM		#StakeLevelList_Excluded AS slle
			CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
										,	gg.GroupName AS StakeLevelValue
							FROM		dbo.strSplit(slle.StakeLevelList_old, ',') AS ss
							INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
									ON	ss.val = CAST(sl.StakeLevelID AS NVARCHAR(10))
							INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK)
									ON	gg.GameGroupID = sl.GameGroupID
						) sl;

			IF	@@ROWCOUNT = 0
				BREAK;
		END;
	
		WHILE 0 = 0
		BEGIN
			UPDATE	ts
			SET	ts.StakeLevelList = REPLACE(ts.StakeLevelList, sl.StakeLevelID, sl.StakeLevelValue)
			FROM		#tmpStake AS ts
			CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
										,	gg.GroupName AS StakeLevelValue
							FROM		dbo.strSplit(ts.StakeLevelList, ',') AS ss
							INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
									ON	ss.val = CAST(sl.StakeLevelID AS NVARCHAR(10))
							INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK)
									ON	gg.GameGroupID = sl.GameGroupID
						) sl;

			IF	@@ROWCOUNT = 0
				BREAK;
		END;

		UPDATE #StakeLevelList_Excluded
		SET	StakeLevelList_old = REPLACE(StakeLevelList_old, ',', ', ');

		UPDATE #tmpStake
		SET StakeLevelList = REPLACE(StakeLevelList, ',', ', ');
	END;

	-- Log old value
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	@ProductID				AS '@ProductID'
						,	slle.StakeLevelList_old	AS '@StakeLevelList'
					FROM	#StakeLevelList_Excluded	AS slle
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	ts.SportType			AS '@SportType'
						,	slle.StakeLevelList_old	AS '@StakeLevelList'
					FROM		#tmpStake AS ts
					INNER JOIN	#StakeLevelList_Excluded AS slle
							ON	slle.BetType = ts.BetType
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	slle.BetType			AS '@BetType'
						,	slle.StakeLevelList_old	AS '@StakeLevelList'
					FROM	#StakeLevelList_Excluded AS slle
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID'
			,	@ProductName					AS '@ProductName'
			,	@CustID							AS '@CustID'
			,	@UserID							AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName'
			,	@IP								AS '@IP'
			,	(
					SELECT	ts.SportType			AS '@SportType'
						,	slle.BetType			AS '@BetType'
						,	slle.StakeLevelList_old	AS '@StakeLevelList'
					FROM		#tmpStake AS ts
					INNER JOIN	#StakeLevelList_Excluded AS slle
							ON	slle.BetType = ts.BetType
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"');

	-- Log new updated value
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	@ProductID				AS '@ProductID'
						,	ts.StakeLevelList		AS '@StakeLevelList'
					FROM	#tmpStake AS ts
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	ts.SportType			AS '@SportType'
						,	ts.StakeLevelList		AS '@StakeLevelList'
					FROM	#tmpStake AS ts
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID							AS '@ProductID'
			,	@ProductName						AS '@ProductName'
			,	@CustID								AS '@CustID'
			,	@UserID								AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID)		AS '@SubAccName'
			,	@IP									AS '@IP'
			,	(
					SELECT	ts.BetType				AS '@BetType'
						,	ts.StakeLevelList		AS '@StakeLevelList'
					FROM	#tmpStake AS ts
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID'
			,	@ProductName					AS '@ProductName'
			,	@CustID							AS '@CustID'
			,	@UserID							AS '@UserID'
			,	dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName'
			,	@IP								AS '@IP'
			,	(
					SELECT	ts.SportType			AS '@SportType'
						,	ts.BetType				AS '@BetType'
						,	ts.StakeLevelList		AS '@StakeLevelList'
					FROM	#tmpStake AS ts
					FOR XML PATH('StakeLevel')
				,	TYPE
				)
		FOR XML PATH('Acc_CustSetting_StakeLevelUpd')
	,	TYPE
	);
	END;
	SET	@logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"');

	SELECT	@endRun	= GETDATE()
		,	@duration = DATEDIFF(MILLISECOND, @startRun, @endRun);

	BEGIN TRY
		EXECUTE	DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
					@UserID			= @UserID
				,	@CustID			= @CustID
				,	@ActionID		= 391
				,	@TrackingValue	= @logSpData
				,	@TrackingValue2	= @logSpData_Old
				,	@duration		= @duration;
	END TRY

	BEGIN CATCH
		EXECUTE	bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
					@UserID			= @UserID
				,	@CustID			= @CustID
				,	@ActionID		= 391
				,	@TrackingValue	= @logSpData
				,	@TrackingValue2	= @logSpData_Old
				,	@duration		= @duration;
	END CATCH;
END;

GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelUpd TO bodbadminNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelUpd TO bodbDownlineNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelUpd TO bodbExtAccNet;