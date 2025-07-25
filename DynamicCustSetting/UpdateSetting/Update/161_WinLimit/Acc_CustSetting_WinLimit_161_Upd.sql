/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_WinLimit_161_Upd] 
	  @CustID			INT
	, @Limit			VARCHAR(MAX)
	, @SubAccID			INT			= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @ErrCode			INT			= 0		OUTPUT
	, @MsgType			INT			= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''		OUTPUT
	, @SettingStatus		TINYINT		= 0
	, @GroupID			TINYINT		= 3
	, @GroupType		SMALLINT		= 161
AS
/*
	Created: 20250507@ELodie
	Task : Update Customer's Win Limits
	DB: DBCUST/CustDB
	Original:	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
	Param's Explanation:
	- @Limit:
		29: WinLimit
		'[
			{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2000"  , "IsAutoReset":"0" }

		]'

	- @SettingType: 29: WinLimit

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
		, MaxWinLimit		MONEY
		, IsAutoReset		BIT
		, Child_DisplayOrder	INT
		)
	DECLARE @NewLimitTbl TABLE (
		  ProductID			TINYINT		
		, SportType			SMALLINT
		, BetType			SMALLINT
		, SettingLevel		TINYINT
		, MaxWinLimit		MONEY 
		, IsAutoReset		BIT
		, IsLog				BIT DEFAULT 0
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
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
		
	-- Parse Data Json
	INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, IsAutoReset)
	SELECT SportType, BetType, MaxWinLimit, IsAutoReset
	FROM OPENJSON(@Limit)
	WITH 
		(
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	MONEY
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
	EXEC [dbo].[Acc_CustSetting_WinLimit_161_Check] 
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
		INSERT INTO @OldLimitTbl(SportType,BetType,MaxWinLimit,IsAutoReset)
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit		
			, wl.IsAutoReset			
		FROM dbo.CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.sporttype AND tmp.BetType = wl.bettype
		WHERE wl.custid = @CustID
		
		--update new settings
		UPDATE main
		SET main.MaxWinLimit = tmp.MaxWinLimit
			, main.IsAutoReset = tmp.IsAutoReset
			, RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustWinLossLimit_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (main.MaxWinLimit <> tmp.MaxWinLimit OR main.IsAutoReset <> tmp.IsAutoReset)
	END		
	
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
							IsAutoReset									AS '@IsAutoReset',
							t.SettingLevel								AS '@SettingLevel'
					FROM @OldLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('WinLimit'),
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
							IsAutoReset									AS '@IsAutoReset',
							t.SettingLevel								AS '@SettingLevel'
					FROM @NewLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('WinLimit'),
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

	SELECT @ActionID = 853

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper 
					  @UserID 			= @UserID
					, @CustID			= @CustID
					, @ActionID			= @ActionID
					, @TrackingValue	= @logSpData
					, @TrackingValue2	= @logSpData_Old
					, @duration			= @duration
	
	DROP TABLE #ProductSettingDetail
END

GO