/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_WinLossLimit_155_Upd] 
	  @CustID			INT
	, @Limit			VARCHAR(MAX)
	, @SourceUsername		VARCHAR(50)		= NULL
	, @SubAccID			INT			= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @isSearchAndCopy	BIT			= 0
	, @ErrCode			INT			= 0		OUTPUT
	, @MsgType			INT			= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''		OUTPUT
	, @SettingStatus		TINYINT		= 0
	, @GroupID			TINYINT		= 3
	, @GroupType		SMALLINT		= 155
AS
/*
	Created: 20240216@Helios
	Task : Update Customer's Win Loss Limits
	DB: DBCUST/CustDB
	Original:	
	Revisions:
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
	- 20240521@Helios: Unify RNG Games [Redmine: #204358]
	- 20241203@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684] 
	- 20250324@Johnson: change datatype for ExchangeID[redmine: #221098]
	Param's Explanation:
	- @Limit:
		22: WinLossLimit
		'[
			{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }

		]'
	- @SettingType: 6,22: WinLossLimit
					8: WinLimit
					12: LossLimit

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData	NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml		XML
		
	DECLARE @AgentID		INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
		, @SiteID		INT
		, @Currency		INT
		
	DECLARE @OldLimitTbl TABLE (
		  ProductID			TINYINT
		, SportType			SMALLINT
		, BetType			SMALLINT
		, SettingLevel		TINYINT
		, MaxWinLimit		SMALLMONEY
		, MaxLossLimit		MONEY
		, IsAutoReset		BIT
		, Child_DisplayOrder	INT
		)
	DECLARE @NewLimitTbl TABLE (
		  ProductID			TINYINT		
		, SportType			SMALLINT
		, BetType			SMALLINT
		, SettingLevel		TINYINT
		, MaxWinLimit		SMALLMONEY 
		, MaxLossLimit		MONEY 
		, IsAutoReset		BIT
		, IsLog			BIT DEFAULT 0
		, Child_DisplayOrder	INT
		)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[Child_DisplayOrder] [INT]
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
	,	@ErrCode		= @ErrCode OUTPUT
	,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

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

	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
		,	@SiteID	= s.siteid
	FROM	dbo.Customer AS c WITH(NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	
	-- Parse Data Json
	INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	FROM OPENJSON(@Limit)
	WITH 
		(
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	SMALLMONEY
			, MaxLossLimit	MONEY
			, IsAutoReset	BIT
		) AS Limit
	
	
	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewLimitTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer 

	IF NOT EXISTS( SELECT 1 FROM @NewLimitTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	--Validate new bet settings
	EXEC [dbo].[Acc_CustSetting_WinLossLimit_155_Check] 
		 @CustID		= @CustID
		, @RoleID		= @RoleID
		, @AgentID		= @AgentID
		, @MasterID		= @MasterID
		, @SuperID		= @SuperID
		, @Limit		= @Limit
		, @GroupID	      = @GroupID
		, @GroupType      = @GroupType
		, @SettingStatus	= @SettingStatus
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	DECLARE @Limit_XML VARCHAR(MAX)

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
			-- Call From Acc_CustSetting_DCSSettingCopyInsertMember
			SET @Limit_XML = (SELECT SportType		AS '@SportType',
									BetType			AS '@BetType',
									MaxWinLimit		AS '@MaxWinLimit',
									MaxLossLimit	AS '@MaxLossLimit',
									IsAutoReset		AS '@IsAutoReset'
							FROM @NewLimitTbl
							FOR XML PATH('r'), ROOT ('root')
							)
			EXECUTE Acc_DynamicCustomerInfo_01 
						@CustID	 = @CustID,
						@SettingList = @Limit_XML,
						@SettingType = 22
		END
		ELSE
		BEGIN
			--update new settings
			UPDATE main
			SET main.MaxWinLimit = tmp.MaxWinLimit
				, main.IsAutoReset = tmp.IsAutoReset
				, main.MaxLossLimit = tmp.MaxLossLimit
				, RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
			WHERE main.custid = @CustID
				AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset OR main.MaxLossLimit <> tmp.MaxLossLimit)
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

		--update new settings
		UPDATE main
		SET main.MaxWinLimit = tmp.MaxWinLimit
			, main.IsAutoReset = tmp.IsAutoReset
			, main.MaxLossLimit = tmp.MaxLossLimit
			, RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustWinLossLimit_Agent main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset OR main.MaxLossLimit <> tmp.MaxLossLimit)
	END

	-- Call From Acc_CustSetting_DCSSettingCopyInsertMember
	SET @Limit_XML = (SELECT SportType		AS '@SportType',
							BetType			AS '@BetType',
							MaxWinLimit		AS '@MaxWinLimit',
							MaxLossLimit	AS '@MaxLossLimit',
							IsAutoReset		AS '@IsAutoReset'
					FROM @NewLimitTbl
					FOR XML PATH('Limit'), ROOT ('ROOT')
					)


	EXEC dbo.Acc_DynamicCustSetting3rd_00 
		 @CustId = @CustId
		,@RoleId = @RoleId
		,@Limit_XML = @Limit_XML
		,@SettingType=22
	
	--START LOGGING

	UPDATE tmp
		SET   tmp.SettingLevel = psd.SettingLevel,
			tmp.ProductID = psd.ProductID,
			tmp.Child_DisplayOrder = psd.Child_DisplayOrder
	FROM @NewLimitTbl tmp
		INNER JOIN #ProductSettingDetail psd
			ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType

	UPDATE tmp
		SET   tmp.SettingLevel = psd.SettingLevel,
			tmp.ProductID = psd.ProductID,
			tmp.Child_DisplayOrder = psd.Child_DisplayOrder
	FROM @OldLimitTbl tmp
		INNER JOIN #ProductSettingDetail psd
			ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType

	-- Log Old Data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@GroupID									AS '@GroupID',
							ProductID									AS '@ProductID',
							SportType									AS '@SportType',
							BetType									AS '@BetType',
							CASE	
								WHEN MaxWinLimit = 0 THEN 'Unlimited' 
								ELSE CAST(MaxWinLimit AS VARCHAR(20))
							END										AS '@MaxWinLimit',
							CASE	
								WHEN MaxLossLimit = 0 THEN 'Unlimited'
								ELSE CAST(MaxLossLimit AS VARCHAR(20))
							END										AS '@MaxLossLimit',
							IsAutoReset									AS '@IsAutoReset',
							t.SettingLevel								AS '@SettingLevel'
					FROM @OldLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('WinLossLimit'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)

	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log New Data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@GroupID									AS '@GroupID',
							ProductID									AS '@ProductID',
							SportType									AS '@SportType',
							BetType									AS '@BetType',
							CASE	
								WHEN MaxWinLimit = 0 THEN 'Unlimited' 
								ELSE CAST(MaxWinLimit AS VARCHAR(20))
							END										AS '@MaxWinLimit',
							CASE	
								WHEN MaxLossLimit = 0 THEN 'Unlimited'
								ELSE CAST(MaxLossLimit AS VARCHAR(20))
							END										AS '@MaxLossLimit',
							IsAutoReset									AS '@IsAutoReset',
							t.SettingLevel								AS '@SettingLevel'
					FROM @NewLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('WinLossLimit'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)

	SET @logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)

	SELECT 
	  @endRun = GETDATE()
	, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	DECLARE @ActionID INT

	SELECT @ActionID = 852

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper 
					  @UserID = @UserID
					, @CustID			= @CustID
					, @ActionID			= @ActionID
					, @TrackingValue		= @logSpData
					, @TrackingValue2		= @logSpData_Old
					, @duration			= @duration
	
	DROP TABLE #ProductSettingDetail
END

GO