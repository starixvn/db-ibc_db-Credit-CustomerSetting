/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatus_160_Upd] 
	  @CustID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @GroupID			TINYINT		= 3
	, @GroupType		TINYINT		= 160
	, @ErrCode			INT			= 0		OUTPUT
	, @MsgType			INT			= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''		OUTPUT
	, @SettingStatus		TINYINT		= 0
AS
/*
	Created: 20240216@Helios
	Task : Update enabled status on NAP & ExtNAP
	DB: DBCUST/CustDB
	Original:
		Acc_Admin_DisableNewProductStatusUpd

	Revisions:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
		- 20241125@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]	
	Param's Explanation:
	@IsDisabled
		[
			{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" }, 
			{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" }, 
			{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" }, 
			{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" }		
		]
	Example:
		DECLARE @p3 int
		SET @p3=0
		DECLARE @p4 nvarchar(MAX)
		SET @p4=N''
		DECLARE @p5 int
		SET @p5=0
		EXEC Acc_Admin_DisableNewProductStatus_160_Upd @UserID=169368,@IP='202.78.231.34',@MsgType=@p3 output,@ErrMsg=@p4 output,@ErrCode=@p5 output,
		@IsDisabled='<ROOT><ProductStatus SportType="212" BetType="4001" IsDisabled="0" UpdateAllMasters="1" UpdateAllAgents="1" UpdateAllMembers="1" DisableAllMasters="1" DisableAllAgents="1" DisableAllMembers="1"/></ROOT>',@CustID=1176070
		SELECT @p3, @p4, @p5
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		, @WriteLogMaster	BIT = 0
		, @WriteLogAgent	BIT = 0
		, @WriteLogMember	BIT = 0
		, @ActionID			INT
		, @UpdateAllMasters	BIT = 0
		, @UpdateAllAgents  BIT = 0
		, @UpdateAllMembers BIT = 0

	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))

	DECLARE @AgentID	INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
		, @SiteID		SMALLINT
		, @Currency		TINYINT
	
	CREATE TABLE #NewDisableStatTbl (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, UpdateAllMasters		BIT
		, UpdateAllAgents			BIT
		, UpdateAllMembers		BIT
		, DisableAllMasters		BIT
		, DisableAllAgents		BIT
		, DisableAllMembers		BIT
		, RealProductId			TINYINT
		)
	CREATE TABLE #OldDisableStatTbl  (
		  SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, UpdateAllMasters		BIT
		, UpdateAllAgents			BIT
		, UpdateAllMembers		BIT
		, DisableAllMasters		BIT
		, DisableAllAgents		BIT
		, DisableAllMembers		BIT
		)

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	--Check if XML is null or empty
	IF @IsDisabled IS NULL
		OR @IsDisabled = ''
		RETURN

	SET @startRun = GETDATE()

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
		, @currency = currency
		, @siteid   = s.siteid
	FROM dbo.Customer  c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
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

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,RealProductID)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,RealProductID 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	-- Parse Data Json
	INSERT INTO #NewDisableStatTbl (SportType, BetType, IsDisabled, UpdateAllMasters, UpdateAllAgents, UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers)
	SELECT SportType, BetType, IsDisabled, UpdateAllMasters, UpdateAllAgents, UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers
	FROM OPENJSON(@IsDisabled)
	WITH 
		(	SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents			BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
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
	
	SELECT TOP 1 @UpdateAllMasters =  1 FROM #NewDisableStatTbl WHERE UpdateAllMasters = 1
	SELECT TOP 1 @UpdateAllAgents =  1 FROM #NewDisableStatTbl WHERE UpdateAllAgents = 1
	SELECT TOP 1 @UpdateAllMembers =  1 FROM #NewDisableStatTbl WHERE UpdateAllMembers = 1

	--Check Allowed downlines	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE UpdateAllMasters = 1 OR UpdateAllAgents = 1 OR UpdateAllMembers = 1) AND @RoleID <> 1
	BEGIN
		EXEC dbo.Acc_AdminCheckAllowedDownlinesByLevel 
				@custid				= @custid
			,	@roleid				= @roleid
			,	@isExecRep			= 1
			,	@UpdateAllMasters	= @UpdateAllMasters
			,	@UpdateAllAgents	= @UpdateAllAgents
			,	@UpdateAllMembers	= @UpdateAllMembers
			,	@Language			= 'E'
			,	@ErrCode			= @ErrCode	OUTPUT
			,	@ErrMsg				= @ErrMsg	OUTPUT

		IF @ErrCode > 0
		BEGIN
			SET @MsgType = 101
			RETURN
		END
	END

	--Validate new disabled status
	EXEC [dbo].[Acc_Admin_DisableNewProductStatus_160_Check] 
		  @IsDisabled	= @IsDisabled
		, @RoleID		= @RoleID
		, @AgentID		= @AgentID
		, @MasterID		= @MasterID
		, @SuperID		= @SuperID
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT
		, @GroupID		= @GroupID
		, @GroupType	= @GroupType
		, @siteid		= @siteid
		, @Currency		= @Currency
		, @CustID		= @CustID
		, @SettingStatus  = @SettingStatus

	

	IF @ErrCode <> 0
		RETURN
	
	
	--Get old disabled status
	DECLARE @downlines BIT  = 0
	
	INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled,UpdateAllMasters,UpdateAllAgents,UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers)
	SELECT psp.SportType
		, psp.BetType
		, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled
		, tmp.UpdateAllMasters
		, tmp.UpdateAllAgents
		, tmp.UpdateAllMembers
		, tmp.DisableAllMasters
		, tmp.DisableAllAgents
		, tmp.DisableAllMembers			
	FROM #NewDisableStatTbl tmp
		INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID

	--If status did not be changed than return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM #NewDisableStatTbl tmp
				INNER JOIN #OldDisableStatTbl stt ON tmp.SportType	= stt.SportType	AND tmp.BetType = stt.BetType
			WHERE tmp.IsDisabled <> stt.IsDisabled OR tmp.UpdateAllMasters = 1 OR tmp.UpdateAllAgents = 1 OR tmp.UpdateAllMembers = 1
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
			
	UPDATE CustProductStatus
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
					WHERE ps.SettingType IN ( 13, 4, 21) AND ps.RealProductId IN (SELECT DISTINCT RealProductId FROM #NewDisableStatTbl WHERE IsDisabled = 0)
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)

		UPDATE CustProductStatus WITH (ROWLOCK,UPDLOCK)
		SET bitmapIsHidden =(SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	,
			RepUpdateTime = dbo.f_GetDateTime2()
		WHERE CustID = @CustID
		
	END
	
	--call execrept to update downline
	DECLARE @IsDisabled_Downline XML
	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE UpdateAllMasters = 1 OR UpdateAllAgents = 1 OR UpdateAllMembers = 1) AND @RoleID <> 1
	BEGIN		
		SET @IsDisabled_Downline = (
				SELECT (
						SELECT 
							SportType AS '@SportType'
							,BetType AS '@BetType'
							,IsDisabled AS '@IsDisabled'
							,UpdateAllMasters AS '@UpdateAllMasters'
							,UpdateAllAgents AS '@UpdateAllAgents'
							,UpdateAllMembers AS '@UpdateAllMembers'
							,DisableAllMasters AS '@DisableAllMasters'
							,DisableAllAgents AS '@DisableAllAgents'
							,DisableAllMembers AS '@DisableAllMembers'
						FROM #NewDisableStatTbl
						WHERE UpdateAllMasters = 1 OR UpdateAllAgents = 1 OR UpdateAllMembers = 1
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
			--	IF (@RoleID = 4 AND EXISTS (	SELECT 1
			--								FROM custinfo WITH (NOLOCK)
			--								WHERE srecommend = @CustID AND roleid = 1
			--								))
			--		OR (@RoleID = 3 AND EXISTS (SELECT 1
			--									FROM custinfo WITH (NOLOCK)
			--									WHERE mrecommend = @CustID AND roleid = 1
			--									))
			--		OR (@RoleID = 2 AND EXISTS (SELECT 1
			--									FROM custinfo WITH (NOLOCK)
			--									WHERE recommend = @CustID AND roleid = 1
			--									))
			--		SET @downlines = 1

			--	IF @downlines = 1
			--	BEGIN
			--		IF EXISTS (	SELECT TOP 1 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0 AND UpdateAllMembers = 1 AND DisableAllMembers = 0) --enable member downline
			--			EXEC dbo.Age_MessageNoticeDownlineUpd_Wrapper @CustID = @CustID, @UserID = @UserID, @TypeID = 3, @IsDisabled = @IsDisabled_Downline_tmp
			--		IF EXISTS (SELECT TOP 1 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1) --disable downline
			--			EXEC dbo.Age_MessageNoticeDownlineUpdStatus_Wrapper @CustID = @CustID, @TypeID = 3, @isViewed = 1
			--	END
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
	SELECT @WriteLogMaster = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllMasters = 1

	SELECT @WriteLogAgent = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllAgents = 1

	SELECT @WriteLogMember = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllMembers= 1

	
	IF @RoleId = 4
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 60541
		UNION SELECT 65582
		UNION SELECT 70627
		UNION SELECT 75660
	END
	IF @RoleId = 3
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 75661
		UNION SELECT 70628
		UNION SELECT 65583
	END
	IF @RoleId = 2
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 70629
		UNION SELECT 75662
	END
	IF @RoleId = 1
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 75663
	END


	--INSERT INTO @LogAction (ActionID)
	--SELECT l.ActionID
	--FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
	--	INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	--WHERE l.SPName = @SPName AND ld.ProductID = @ProductID AND ld.Level = @RoleID
	--	AND ((l.ActionID BETWEEN 60500 AND 64999 AND @RoleID = 4)
	--		OR (l.ActionID BETWEEN 65500 AND 69999 AND ((@RoleID = 4 AND @WriteLogMaster = 1) OR @RoleID = 3))
	--		OR (l.ActionID BETWEEN 70500 AND 74999 AND ((@RoleID IN (4,3) AND @WriteLogAgent = 1) OR @RoleID = 2))
	--		OR (l.ActionID BETWEEN 75500 AND 79999 AND ((@RoleID IN (4,3,2) AND @WriteLogMember = 1) OR @RoleID = 1)))

	-- Log Old Collect
	SET @xml = (
		SELECT	
				@CustID						AS '@CustID',
				@GroupID						AS '@GroupID',
				@IP							AS '@IP',
				(
					SELECT	
							psd.ProductID		AS '@ProductID',
							psd.SportType		AS '@SportType',
							psd.BetType			AS '@BetType',
							psd.SettingLevel		AS '@SettingLevel',
							IsDisabled			AS '@IsDisabled',
							UpdateAllMasters		AS '@UpdateAllMasters',
							DisableAllMasters		AS '@DisableAllMasters',
							UpdateAllAgents		AS '@UpdateAllAgents',
							DisableAllAgents		AS '@DisableAllAgents',
							UpdateAllMembers		AS '@UpdateAllMembers',
							DisableAllMembers		AS '@DisableAllMembers'
					FROM #OldDisableStatTbl od
					INNER JOIN #ProductSettingDetail psd ON od.SportType = psd.SportType AND od.BetType = psd.BetType
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
					@IP								AS '@IP',
					(
						SELECT	
								@GroupID				AS '@GroupID',
								psd.ProductID			AS '@ProductID',
								psd.SportType			AS '@SportType',
								psd.BetType				AS '@BetType',
								psd.SettingLevel			AS '@SettingLevel',
								IsDisabled				AS '@IsDisabled',
								UpdateAllMasters			AS '@UpdateAllMasters',
								DisableAllMasters			AS '@DisableAllMasters',
								UpdateAllAgents			AS '@UpdateAllAgents',
								DisableAllAgents			AS '@DisableAllAgents',
								UpdateAllMembers			AS '@UpdateAllMembers',
								DisableAllMembers			AS '@DisableAllMembers'
						FROM #NewDisableStatTbl nd
						INNER JOIN #ProductSettingDetail psd ON nd.SportType = psd.SportType AND nd.BetType = psd.BetType
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
			EXEC Acc_WriteLog_UserLog_RunSP_Wrapper 
				  @UserID			= @UserID
				, @CustID			= @CustID
				, @ActionID			= @ActionID
				, @TrackingValue		= @logSpData
				, @TrackingValue2		= @logSpData_Old
				, @duration			= @duration
		END TRY

		BEGIN CATCH
			EXEC Acc_WriteLog_UserLog_RunSP_Wrapper 
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
