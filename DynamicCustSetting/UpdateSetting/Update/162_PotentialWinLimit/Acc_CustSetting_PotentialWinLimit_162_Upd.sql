/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_PotentialWinLimit_162_Upd] 
	 @CustID			INT
	, @WinLimit			VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''	
	, @SettingStatus	TINYINT		    = 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(200)		= ''		OUTPUT
AS
/*
    Created by: 20250509@Johnson	
    Task: update Potential Win Limit for member
    DB: DBCUST.CustDB
    
    Revisions:
        - 20250509@Johnson: initial sp [redmine: #226060]
        - 20250701@Johnson: remove checking unchange for multiple update [redmine: #232037]
    Parameter's explaination:
        - @WinLimit:
		162: WinLimit
		'[
			{ "SportType":"0"  , "BetType":"0"  , "WinLimit":"0"  , "IsAutoReset":"1" }
		]'
*/  
BEGIN
    SET NOCOUNT ON

    DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData	NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml			XML
        , @SiteID		INT
		, @roleid		TINYINT
		, @Currency		INT
        , @SettingType INT = 30

    --Check if XML is null or empty
	IF @WinLimit IS NULL OR @WinLimit = ''
		RETURN

	SET @startRun = GETDATE()

    -- Select customer's information
	SELECT	@Currency   = c.currency		
		,	@SiteID	= s.siteid
		,	@roleid = c.roleid
	FROM	dbo.Customer AS c WITH(NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''    

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

    DECLARE @NewLimitTbl TABLE (
		  ProductID			TINYINT		
		, SportType			SMALLINT
		, BetType			INT
		, SettingLevel		TINYINT
		, WinLimit		    MONEY 		
		, IsAutoReset		BIT
		, IsLog			BIT DEFAULT 0
		, Child_DisplayOrder	INT
		)

	DECLARE @OldLimitTbl TABLE (
		  ProductID			TINYINT		
		, SportType			SMALLINT
		, BetType			INT
		, SettingLevel		TINYINT
		, WinLimit		    MONEY 		
		, IsAutoReset		BIT
		, IsLog			BIT DEFAULT 0
		, Child_DisplayOrder	INT
		)
	
	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(@SettingType,@SettingStatus,@SiteID,@Currency)
				
    -- Parse Data Json
	INSERT @NewLimitTbl (SportType, BetType, WinLimit, IsAutoReset)	
    SELECT SportType, BetType, WinLimit, IsAutoReset
    FROM OPENJSON(@WinLimit)
    WITH 
        (
            SportType		SMALLINT
            , BetType		INT
            , WinLimit		MONEY			
            , IsAutoReset	BIT
        ) AS WinLimit

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
	
	INSERT INTO @OldLimitTbl (SportType, BetType, WinLimit, IsAutoReset)
	SELECT cs.SportType, cs.BetType, cs.PotentialWinLimit, cs.IsAutoReset
	FROM dbo.CustPotentialWinLimit cs WITH(NOLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = cs.Sporttype AND tmp.Bettype = cs.Bettype
	WHERE custid = @CustID

    --update new settings
	UPDATE main
	SET main.PotentialWinLimit = tmp.WinLimit
		, main.IsAutoReset = tmp.IsAutoReset	
		, RepUpdateTime = dbo.f_GetDateTime2()
	FROM dbo.CustPotentialWinLimit main WITH(ROWLOCK,UPDLOCK)
	INNER JOIN @NewLimitTbl tmp ON tmp.SportType = main.sporttype AND tmp.BetType = main.bettype
	WHERE main.custid = @CustID
		AND (main.PotentialWinLimit <> tmp.WinLimit OR main.IsAutoReset <> tmp.IsAutoReset)
	
	--Start Logging
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
					SELECT	ProductID								AS '@ProductID',
							SportType								AS '@SportType',
							BetType									AS '@BetType',
							CASE	
								WHEN WinLimit = 0 THEN 'Unlimited' 
								ELSE CAST(WinLimit AS VARCHAR(20))
							END										AS '@WinLimit',
							IsAutoReset								AS '@IsAutoReset',
							t.SettingLevel							AS '@SettingLevel'
					FROM @OldLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('PotentialWinLimit'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)

	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID)	AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	ProductID								AS '@ProductID',
							SportType								AS '@SportType',
							BetType									AS '@BetType',
							CASE	
								WHEN WinLimit = 0 THEN 'Unlimited' 
								ELSE CAST(WinLimit AS VARCHAR(20))
							END										AS '@WinLimit',
							IsAutoReset								AS '@IsAutoReset',
							t.SettingLevel							AS '@SettingLevel'
					FROM @NewLimitTbl t
					ORDER BY Child_DisplayOrder
					FOR XML PATH('PotentialWinLimit'),
					TYPE
				)
		FOR XML PATH('ROOT'),
		TYPE
	)

	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)

	SELECT 
	  @endRun = GETDATE()
	, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	DECLARE @ActionID INT

	SELECT @ActionID = 854

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper 
					  @UserID = @UserID
					, @CustID			= @CustID
					, @ActionID			= @ActionID
					, @TrackingValue	= @logSpData
					, @TrackingValue2	= @logSpData_Old
					, @duration			= @duration
	
	DROP TABLE #ProductSettingDetail
END