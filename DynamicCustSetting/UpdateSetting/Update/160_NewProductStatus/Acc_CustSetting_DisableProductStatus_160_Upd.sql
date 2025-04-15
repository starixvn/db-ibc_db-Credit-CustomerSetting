/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_DisableProductStatus_160_Upd] 
	  @CustID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)			= ''
	, @SystemID			TINYINT
	, @GroupID			TINYINT			= 3
	, @GroupType		TINYINT			= 160
	, @SettingStatus		TINYINT			= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)		= ''		OUTPUT
AS
/*
	Created: 20240216@Helios
	Task : Update enabled status product Live & RNG Casino
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DisableNewProductStatusUpd

	Revisions:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
		- 20241203@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20250325@Johnson: change datatype for ExchangeID[redmine: #221098]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
	Param's Explanation:
	- @IsDisabled
		'[
			{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
			{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
			{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
			{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
		]'
	Example: 
		DECLARE @p3 int
		SET @p3=0
		DECLARE @p4 nvarchar(200)
		SET @p4=N''
		DECLARE @p5 int
		SET @p5=0
		EXEC Acc_CustSetting_DisableProductStatus_160_Upd @UserID=169368,@IP='202.78.231.34',@MsgType=@p3 output,@ErrMsg=@p4 output,@ErrCode=@p5 output,
		@IsDisabled='[
					{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
					{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
				]',@CustID=1176070, @SystemID = 1,@GroupID=3 , @GroupType = 160 ,@SettingStatus=3
		SELECT @p3, @p4, @p5
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old		NVARCHAR(MAX)
		, @xml			XML
		, @EnableOnly		BIT = 1
		, @ActionID			INT

	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))

	DECLARE @AgentID		INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
		, @SiteID		SMALLINT
		, @Currency		INT


	CREATE TABLE #NewDisableStatTbl (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, RealProductId			TINYINT
		)
	CREATE TABLE #OldDisableStatTbl  (
		SportType		SMALLINT
		, BetType		SMALLINT
		, IsDisabled	BIT
		)

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg	= ''
		
	--Check if XML is null or empty
	IF @IsDisabled IS NULL OR @IsDisabled = ''
		RETURN

	SET @startRun = GETDATE()

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid	= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg	= @ErrMsg OUTPUT

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

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		, @currency = currency
		, @siteid   = s.siteid
	FROM dbo.Customer  c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE custid = @CustID
	
		CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[RealProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	INSERT INTO #ProductSettingDetail (SettingType,SportType,BetType,IsLive,ProductID,SettingLevel,RealProductID)
	SELECT SettingType,SportType,BetType,IsLive,ProductID,SettingLevel,RealProductID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	
	-- Parse Data Json
	INSERT INTO #NewDisableStatTbl (SportType, BetType, IsDisabled)
	SELECT SportType, BetType, IsDisabled
	FROM OPENJSON(@IsDisabled)
	WITH 
		(
			SportType			SMALLINT	
		    , BetType			SMALLINT
		    , IsDisabled			BIT
		) AS DisabledProductStatus

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #NewDisableStatTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM #NewDisableStatTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')
	
		RETURN
	END
	
	--Check Allowed downlines	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1) AND @SystemID <> 2 AND @RoleID <> 1
	BEGIN
		EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
				@custid		= @custid
			,	@roleid		= @roleid
			,	@isExecRep		= 1
			,	@Language		= 'E'
			,	@ErrCode		= @ErrCode	OUTPUT
			,	@ErrMsg		= @ErrMsg	OUTPUT

		IF @ErrCode > 0
		BEGIN
			SET @MsgType = 101
			RETURN
		END

	END

	--Validate new disabled status
	EXEC [dbo].[Acc_CustSetting_DisableProductStatus_160_Check] 
		  @CustID		= @CustID
		, @RoleID		= @RoleID
		, @AgentID		= @AgentID
		, @MasterID		= @MasterID
		, @SuperID		= @SuperID
		, @IsDisabled	= @IsDisabled
		, @SystemID		= @SystemID
		, @GroupID		= @GroupID
		, @GroupType	= @GroupType
		, @SettingStatus  = @SettingStatus
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN
	
	INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled)
	SELECT psp.SportType
		, psp.BetType
		, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled			
	FROM #NewDisableStatTbl tmp
		INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID	
	
	--If status did not be changed than return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM #NewDisableStatTbl tmp
				INNER JOIN #OldDisableStatTbl stt ON tmp.SportType	= stt.SportType	AND tmp.BetType = stt.BetType
			WHERE tmp.IsDisabled <> stt.IsDisabled
			)
		RETURN

	--Update main table

	DECLARE @xmlStrDisabled XML
	DECLARE @xmlStrHidden XML
	
	SET @xmlStrDisabled =(
			SELECT (
					SELECT psp.bitmapOrder	AS '@b'
						, tmp.IsDisabled	AS '@s'
					FROM ProductStatusProfile psp WITH (NOLOCK)
						JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
	
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)
			
	UPDATE CustProductStatus WITH (ROWLOCK,UPDLOCK)
		SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
			RepUpdateTime = dbo.f_GetDateTime2()
	WHERE CustID = @CustID
	
	UPDATE ns 
	SET ns.RealProductId = ps.RealProductId
	FROM #NewDisableStatTbl ns
		INNER JOIN #ProductSettingDetail ps ON ns.Sporttype = ps.SportType AND ns.Bettype = ps.BetType

	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
	BEGIN
		SET @xmlStrHidden = (
			SELECT (
					SELECT psp.bitmapOrder	AS '@b'
						, 0	AS '@s'
					FROM ProductStatusProfile psp (NOLOCK)
						INNER JOIN #ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
						LEFT JOIN #NewDisableStatTbl ns ON psp.Sporttype = ns.SportType AND psp.Bettype = ns.BetType
					WHERE ps.SettingType = 21 AND ps.RealProductId IN (SELECT DISTINCT RealProductId FROM #NewDisableStatTbl WHERE IsDisabled = 0)
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)

		UPDATE CustProductStatus WITH (ROWLOCK,UPDLOCK)
		SET bitmapIsHidden =(SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
			RepUpdateTime = dbo.f_GetDateTime2()
		WHERE CustID = @CustID
		
	END
	
	--call execrept to update downline when disable status
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1) AND @SystemID <> 2 AND @RoleID <> 1
	BEGIN		
		DECLARE @IsDisabled_Downline XML
	
		SET @IsDisabled_Downline = (
				SELECT (
					SELECT 
						SportType AS '@SportType'
						,BetType AS '@BetType'
						,IsDisabled AS '@IsDisabled_XML'
						,1 AS '@UpdateAllMasters'
						,1 AS '@UpdateAllAgents'
						,1 AS '@UpdateAllMembers'
						,1 AS '@DisableAllMasters'
						,1 AS '@DisableAllAgents'
						,1 AS '@DisableAllMembers'
						,1 AS '@UpdateAllSuperDirectMembers'
						,1 AS '@UpdateAllMasterDirectMembers'
						,1 AS '@DisableAllSuperDirectMembers'
						,1 AS '@DisableAllMasterDirectMembers'
					FROM #NewDisableStatTbl
					WHERE IsDisabled = 1
					FOR XML PATH('ProductStatus')
						, TYPE
					)
			FOR XML PATH('ROOT')
				, TYPE
			)
	
		DECLARE @IsDisabled_Downline_tmp VARCHAR(MAX)		
	
		SET @IsDisabled_Downline_tmp = CONVERT(VARCHAR(MAX),@IsDisabled_Downline)
	
		IF @IsDisabled_Downline_tmp <> '<ROOT/>'
		BEGIN		
			-- This SP don't affected Fishing World so comment this code
			--IF @ProductID = 24 --Fishing World
			--BEGIN
			--	EXEC dbo.Age_MessageNoticeDownlineUpdStatus_Wrapper @CustID = @CustID, @TypeID = 3, @isViewed = 1
			--END
			
			EXEC dbo.[Acc_DynamicCustomerInfo_04] 
							  @CustID			= @CustID
							, @RoleID			= @RoleID
							, @IsDisabled_XML		= @IsDisabled_Downline_tmp
							, @Action			= 'NewProductStatus'
							, @SettingStatus		= @SettingStatus
		END
	END

	--START LOGGING			

	--Get ActionID
	SELECT @EnableOnly = 0
	FROM #NewDisableStatTbl
	WHERE IsDisabled = 1
	
	IF @RoleId = 4
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 60540
		UNION SELECT 65580
		UNION SELECT 70624
		UNION SELECT 75664
	END
	IF @RoleId = 3
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 75665
		UNION SELECT 70625
		UNION SELECT 65581
	END
	IF @RoleId = 2
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 70626
		UNION SELECT 75666
	END
	IF @RoleId = 1
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 75667
	END
	
	-- Log Old Collect
	SET @xml = (
				SELECT	
						@CustID							AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						(
							SELECT	
									@GroupID				AS '@GroupID',
									psd.ProductID			AS '@ProductID',
									psd.SportType			AS '@SportType',
									psd.BetType				AS '@BetType',
									psd.SettingLevel			AS '@SettingLevel',
									ds.IsDisabled			AS '@IsDisabled'
							FROM #OldDisableStatTbl ds
							INNER JOIN #ProductSettingDetail psd ON ds.SportType = psd.SportType AND ds.BetType = psd.BetType
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('ROOT'),
				TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log New Collect
	SET @xml = (
				SELECT	
						@CustID							AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						(
							SELECT	
									@GroupID				AS '@GroupID',
									psd.ProductID			AS '@ProductID',
									psd.SportType			AS '@SportType',
									psd.BetType				AS '@BetType',
									psd.SettingLevel			AS '@SettingLevel',
									ds.IsDisabled			AS '@IsDisabled'
							FROM #NewDisableStatTbl ds
							INNER JOIN #ProductSettingDetail psd ON ds.SportType = psd.SportType AND ds.BetType = psd.BetType
							FOR XML PATH('ProductStatus'),
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

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)	
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK

		BEGIN TRY

			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				  @UserID			= @UserID
				, @CustID			= @CustID
				, @ActionID			= @ActionID
				, @TrackingValue		= @logSpData
				, @TrackingValue2		= @logSpData_Old
				, @duration			= @duration
		END TRY

		BEGIN CATCH

			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				  @UserID			= @UserID
				, @CustID			= @CustID
				, @ActionID			= @ActionID
				, @TrackingValue		= @logSpData
				, @TrackingValue2		= @logSpData_Old
				, @duration			= @duration
		END CATCH
	END

	DROP TABLE #NewDisableStatTbl
	DROP TABLE #OldDisableStatTbl
	DROP TABLE #ProductSettingDetail
END
GO