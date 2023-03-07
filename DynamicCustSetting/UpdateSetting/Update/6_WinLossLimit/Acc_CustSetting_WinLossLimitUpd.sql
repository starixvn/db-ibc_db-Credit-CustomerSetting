/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLossLimitUpd] 
	  @CustID		INT
	, @Limit		VARCHAR(MAX)
	, @SettingType	SMALLINT		= 6
	, @SourceUsername VARCHAR(50) = NULL
	, @SubAccID		INT				= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
	, @isSearchAndCopy	BIT				= 0
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20160108@Elodie
	Task : Update Customer's Win Loss Limits
	DB: DBCUST/CustDB
	Original:	
	Revisions:
			- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
			- 20200708@Eden: Minimize UM Time - Lock updating customer settings [#136464]
			- 20210906@Johnson: write log SourceUsername [redmine:#158174]
			- 20211007@Johnson: write log by product incase update multiple super[redmine:#162853]
			- 20220808@Tacy: update member's WinLossLimit by execrep when using Search & Copy New member function [RedmineID: #176225]
			- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]

	Param's Explanation:
	- @Limit:
		6: WinLossLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxWinLimit="2" 
						MaxLossLimit="20000" 
						IsAutoReset="0" 
				/>
		</ROOT>

		8: WinLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxWinLimit="2" 
						IsAutoReset="0" 
				/>
		</ROOT>

		12: LossLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxLossLimit="20000" 
						IsAutoReset="0" 
				/>
		</ROOT>

	- @SettingType: 6,22: WinLossLimit
					8: WinLimit
					12: LossLimit

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT
		
	DECLARE @OldLimitTbl TABLE (
		ProductID			TINYINT
		, SportType			SMALLINT
		, BetType			SMALLINT
		, SettingLevel		TINYINT
		, MaxWinLimit		SMALLMONEY
		, MaxLossLimit		MONEY
		, IsAutoReset		BIT
		)
	DECLARE @NewLimitTbl TABLE (
		ProductID			TINYINT		
		, SportType			SMALLINT
		, BetType			SMALLINT
		, SettingLevel		TINYINT
		, MaxWinLimit		SMALLMONEY 
		, MaxLossLimit		MONEY 
		, IsAutoReset		BIT
		, IsLog				BIT DEFAULT 0
		)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	--Check if XML is null or empty
	IF @Limit IS NULL OR @Limit = ''
		RETURN

	SET @startRun = GETDATE()

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
	,	@ErrCode	= @ErrCode OUTPUT
	,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Check belonging
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END
	
	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
		@custid		= @custid
	,	@roleid		= @roleid
	,	@isExecRep	= 1
	,	@Language	= 'E'
	,	@ErrCode	= @ErrCode	OUTPUT
	,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Limit

	IF @SettingType IN(6,22)
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxWinLimit	SMALLMONEY
							, MaxLossLimit	MONEY
							, IsAutoReset	BIT
							)
	END

	IF @SettingType = 8
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxWinLimit, 0 AS MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxWinLimit	SMALLMONEY
							, IsAutoReset	BIT
							)
	END

	IF @SettingType = 12
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, 0 AS MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxLossLimit	MONEY
							, IsAutoReset	BIT
							)
	END
	EXEC sp_xml_removedocument @iDoc

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewLimitTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = @SettingType
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @NewLimitTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	--Validate new bet settings
	EXEC [dbo].[Acc_CustSetting_WinLossLimitCheck] 
		@CustID	= @CustID
		, @RoleID		= @RoleID
		, @AgentID		= @AgentID
		, @MasterID		= @MasterID
		, @SuperID		= @SuperID
		, @Limit		= @Limit
		, @SettingType  = @SettingType
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	IF @RoleID = 1
	BEGIN
		--get old settings
		INSERT INTO @OldLimitTbl(SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset			
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.sporttype AND tmp.BetType = wl.bettype
		WHERE wl.custid = @CustID

		IF @isSearchAndCopy=1
		BEGIN
			IF @SettingType IN(6,22)
				SET @Limit = (SELECT SportType		AS '@SportType',
									BetType			AS '@BetType',
									MaxWinLimit		AS '@MaxWinLimit',
									MaxLossLimit	AS '@MaxLossLimit',
									IsAutoReset		AS '@IsAutoReset'
							FROM @NewLimitTbl
							FOR XML PATH('r'), ROOT ('root')
							)

			IF @SettingType = 12
				SET @Limit = (SELECT SportType		AS '@SportType',
									BetType			AS '@BetType',
									MaxLossLimit	AS '@MaxLossLimit',
									IsAutoReset		AS '@IsAutoReset'
							FROM @NewLimitTbl
							FOR XML PATH('r'), ROOT ('root')
							)

			EXECUTE Acc_DynamicCustomerInfo_01 
						@CustID=@CustID,
						@SettingList=@Limit,
						@SettingType=@SettingType
		END
		ELSE
		BEGIN
			IF @SettingType IN(6,22)
				--update new settings
				UPDATE main
				SET main.MaxWinLimit = tmp.MaxWinLimit
					, main.IsAutoReset = tmp.IsAutoReset
					, main.MaxLossLimit = tmp.MaxLossLimit
				FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
				INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
				WHERE main.custid = @CustID
					AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset OR main.MaxLossLimit <> tmp.MaxLossLimit)

			IF @SettingType = 8
				--update new settings
				UPDATE main
				SET main.MaxWinLimit = tmp.MaxWinLimit
					, main.IsAutoReset = tmp.IsAutoReset
				FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
				INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
				WHERE main.custid = @CustID
					AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset)

			IF @SettingType = 12
				--update new settings
				UPDATE main
				SET main.MaxLossLimit = tmp.MaxLossLimit
					, main.IsAutoReset = tmp.IsAutoReset
				FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
				INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
				WHERE main.custid = @CustID
					AND (main.MaxLossLimit <> tmp.MaxLossLimit OR main.IsAutoReset <> tmp.IsAutoReset)
		END
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		--get old settings
		INSERT INTO @OldLimitTbl(SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset			
		FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.sporttype AND tmp.BetType = wl.bettype
		WHERE wl.custid = @CustID

		IF @SettingType IN(6,22)
			--update new settings
			UPDATE main
			SET main.MaxWinLimit = tmp.MaxWinLimit
				, main.IsAutoReset = tmp.IsAutoReset
				, main.MaxLossLimit = tmp.MaxLossLimit
			FROM dbo.CustWinLossLimit_Agent main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
			WHERE main.custid = @CustID
				AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset OR main.MaxLossLimit <> tmp.MaxLossLimit)

		IF @SettingType = 8
			--update new settings
			UPDATE main
			SET main.MaxWinLimit = tmp.MaxWinLimit
				, main.IsAutoReset = tmp.IsAutoReset
			FROM dbo.CustWinLossLimit_Agent main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
			WHERE main.custid = @CustID
				AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset)

		IF @SettingType = 12
			--update new settings
			UPDATE main
			SET main.MaxLossLimit = tmp.MaxLossLimit
				, main.IsAutoReset = tmp.IsAutoReset
			FROM dbo.CustWinLossLimit_Agent main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
			WHERE main.custid = @CustID
				AND (main.MaxLossLimit <> tmp.MaxLossLimit OR main.IsAutoReset <> tmp.IsAutoReset)
	END

	EXEC dbo.Acc_DynamicCustSetting3rd_00 
		 @CustId = @CustId
		,@RoleId = @RoleId
		,@Limit_XML = @Limit
		,@SettingType=@SettingType
	
	--START LOGGING
	UPDATE tmp
	SET tmp.ProductID = psd.ProductID,
		tmp.SettingLevel = psd.SettingLevel
	FROM #ProductSettingDetail AS psd WITH(NOLOCK)
		INNER JOIN	@NewLimitTbl AS tmp ON psd.SportType = tmp.SportType AND psd.BetType = tmp.BetType
	WHERE	psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			AND psd.SettingType = @SettingType			
	
	UPDATE tmp
	SET tmp.ProductID = psd.ProductID,
		tmp.SettingLevel = psd.SettingLevel
	FROM #ProductSettingDetail AS psd WITH(NOLOCK)
		INNER JOIN	@OldLimitTbl AS tmp ON psd.SportType = tmp.SportType AND psd.BetType = tmp.BetType
	WHERE	psd.ProductID IS NOT NULL
			AND	psd.SettingLevel IS NOT NULL
			AND psd.SettingType = @SettingType	
			
	WHILE (1=1)
	BEGIN
		SELECT TOP (1) @ProductID = ProductID, 
			@SettingLevel = SettingLevel
		FROM @NewLimitTbl t
		WHERE IsLog = 0
			AND ProductID IS NOT NULL
			AND SettingLevel IS NOT NULL
			
		IF @@ROWCOUNT = 0 
			BREAK;
			
		-- Select ProductName
		SELECT @ProductName = p.ProductName
		FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
		WHERE p.ProductID = @ProductID

		IF @SettingType IN(6,22)
		BEGIN
			-- Log old data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel	
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

			-- Log new updated data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		END

		IF @SettingType = 8
		BEGIN
				-- Log old data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

			-- Log new updated data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxWinLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxWinLimit AS VARCHAR(20))
									END					AS '@MaxWinLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('WinLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		END

		IF @SettingType = 12
		BEGIN
				-- Log old data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @OldLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

			-- Log new updated data
			IF @SettingLevel = 1			-- Product setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	@ProductID			AS '@ProductID',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 2		-- SportType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 3		-- BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	BetType				AS '@BetType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							WHERE ProductID = @ProductID
								AND SettingLevel = @SettingLevel
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			ELSE IF @SettingLevel = 4		-- SportType BetType setting level
			BEGIN
				SET @xml = (
				SELECT	@ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@CustID							AS '@CustID',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						CASE WHEN @SourceUsername IS NOT NULL THEN @SourceUsername END AS '@SourceUsername',
						@IP								AS '@IP',
						(
							SELECT	SportType			AS '@SportType',
									BetType				AS '@BetType',
									CASE	WHEN MaxLossLimit = 0 THEN 'Unlimited'
											ELSE CAST(MaxLossLimit AS VARCHAR(20))
									END					AS '@MaxLossLimit',
									IsAutoReset			AS '@IsAutoReset'
							FROM @NewLimitTbl
							FOR XML PATH('LossLimit'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_WinLossLimitUpd'),
				TYPE
			)
			END
			SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		END

		SELECT @logSpData_Old = LogStr 
		FROM f_CustSetting_FormatLog (@logSpData_Old)
		SELECT @logSpData = LogStr 
		FROM f_CustSetting_FormatLog (@logSpData)

		SELECT @endRun = GETDATE()
			, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

		IF(@SettingType=12)
		BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
							@UserID = @UserID
							, @CustID			= @CustID
							, @ActionID			= 851
							, @TrackingValue	= @logSpData
							, @TrackingValue2	= @logSpData_Old
							, @duration			= @duration
		END TRY
		BEGIN CATCH
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
							@UserID = @UserID
							, @CustID			= @CustID
							, @ActionID			= 851
							, @TrackingValue	= @logSpData
							, @TrackingValue2	= @logSpData_Old
							, @duration			= @duration
		END CATCH
		END
		ELSE
		BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
							@UserID = @UserID
							, @CustID			= @CustID
							, @ActionID			= 850
							, @TrackingValue	= @logSpData
							, @TrackingValue2	= @logSpData_Old
							, @duration			= @duration
		END TRY
		BEGIN CATCH
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
							@UserID = @UserID
							, @CustID			= @CustID
							, @ActionID			= 850
							, @TrackingValue	= @logSpData
							, @TrackingValue2	= @logSpData_Old
							, @duration			= @duration
		END CATCH
		END
		
		UPDATE @NewLimitTbl 
		SET IsLog = 1
		WHERE ProductID = @ProductID
			AND SettingLevel = @SettingLevel
	END	

	DROP TABLE #ProductSettingDetail
END

GO