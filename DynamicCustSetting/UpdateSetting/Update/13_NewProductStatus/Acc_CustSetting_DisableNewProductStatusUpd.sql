/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductStatusUpd] 
	  @CustID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @SystemID			TINYINT
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20170125@Elodie
	Task : Update enabled status
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20170307@Elodie: Apply New Direction of enabling status for 3rd party products [RedmineID: #72336]
		- 20170417@Elodie: Notify downline when upline enable FW's status [RedmineID: #73073]
		- 20170613@Elodie: Change logic to get HasDownlines and IsDisableDownline value [RedmineID:#78225]
		- 20180112@Elodie: Remove IsDisableDownline value [RedmineID:#87328]

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"						
				/>
		</ROOT>
	Example: 
		DECLARE @p3 int
		SET @p3=0
		DECLARE @p4 nvarchar(200)
		SET @p4=N''
		DECLARE @p5 int
		SET @p5=0
		EXEC Acc_CustSetting_DisableNewProductStatusUpd @UserID=169368,@IP='202.78.231.34',@MsgType=@p3 output,@ErrMsg=@p4 output,@ErrCode=@p5 output,@IsDisabled='<ROOT><ProductStatus SportType="212" BetType="4001" IsDisabled="1"/></ROOT>',@CustID=1176070, @SystemID = 1
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
		, @EnableOnly		BIT = 1
		, @ActionID			INT

	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))

	DECLARE @AgentID	INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
	
	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	CREATE TABLE #NewDisableStatTbl (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		)
	CREATE TABLE #OldDisableStatTbl  (
		SportType		SMALLINT
		, BetType		SMALLINT
		, IsDisabled	BIT
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

	--Parse XML
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsDisabled

	INSERT INTO #NewDisableStatTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			)
	
	EXEC sp_xml_removedocument @iDoc

	--Check Allowed downlines	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1) AND @SystemID <> 2 AND @RoleID <> 1
	BEGIN
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

	END

	--Validate new disabled status
	EXEC [dbo].[Acc_CustSetting_DisableNewProductStatusCheck] 
		@IsDisabled = @IsDisabled
		, @RoleID	= @RoleID
		, @AgentID	= @AgentID
		, @MasterID = @MasterID
		, @SuperID	= @SuperID
		, @SystemID = @SystemID
		, @ErrCode	= @ErrCode	OUTPUT
		, @MsgType	= @MsgType  OUTPUT
		, @ErrMsg	= @ErrMsg	OUTPUT

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
			
	UPDATE CustProductStatus
		SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
	WHERE CustID = @CustID
	
	SELECT TOP 1 @ProductID = ps.ProductID
	FROM #NewDisableStatTbl dis 
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
	WHERE ps.SettingType = 13

	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
	BEGIN
		SET @xmlStrHidden = (
			SELECT (
					SELECT psp.bitmapOrder	AS '@b'
						, 0	AS '@s'
					FROM ProductStatusProfile psp (NOLOCK)
						INNER JOIN ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
					WHERE ps.ProductID = @ProductID AND ps.SettingType = 13
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)
		UPDATE CustProductStatus WITH (ROWLOCK,UPDLOCK)
		SET bitmapIsHidden =(SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
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
						,IsDisabled AS '@IsDisabled'
						,1 AS '@UpdateAllMasters'
						,1 AS '@UpdateAllAgents'
						,1 AS '@UpdateAllMembers'
						,1 AS '@DisableAllMasters'
						,1 AS '@DisableAllAgents'
						,1 AS '@DisableAllMembers'
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
			IF @ProductID = 24 --Fishing World
			BEGIN
				EXEC DBONUSER.On_User.dbo.Age_MessageNoticeDownlineUpdStatus @CustID = @CustID, @TypeID = 3, @isViewed = 1
			END
			
			EXEC dbo.[Acc_DynamicCustomerInfo_04] @CustID = @CustID
							, @RoleID			= @RoleID
							, @IsDisabled_XML	= @IsDisabled_Downline_tmp
							, @Action			= 'NewProductStatus'
		END
	END

	--START LOGGING			
	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#OldDisableStatTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 13	
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

	--Get ActionID
	SELECT @EnableOnly = 0
	FROM #NewDisableStatTbl
	WHERE IsDisabled = 1

	INSERT INTO @LogAction (ActionID)
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = 'Acc_CustSetting_DisableNewProductStatusUpd' AND ld.ProductID = @ProductID AND ld.Level = @RoleID
		AND ((l.ActionID BETWEEN 60500 AND 64999 AND @RoleID = 4)
			OR (l.ActionID BETWEEN 65500 AND 69999 AND ((@RoleID = 4 AND @EnableOnly = 0) OR @RoleID = 3))
			OR (l.ActionID BETWEEN 70500 AND 74999 AND ((@RoleID IN (4,3) AND @EnableOnly = 0) OR @RoleID = 2))
			OR (l.ActionID BETWEEN 75500 AND 79999 AND ((@RoleID IN (4,3,2) AND @EnableOnly = 0) OR @RoleID = 1)))

	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustID							AS '@CustID',
					@UserID							AS '@UserID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@IP								AS '@IP',
					(
						SELECT	@ProductID			AS '@ProductID',
								IsDisabled			AS '@IsDisabled'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								IsDisabled			AS '@IsDisabled'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
			TYPE
		)
	END
	
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustID							AS '@CustID',
					@UserID							AS '@UserID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@IP								AS '@IP',
					(
						SELECT	@ProductID			AS '@ProductID',
								IsDisabled			AS '@IsDisabled'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								IsDisabled			AS '@IsDisabled'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)	
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK

		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
				, @CustID			= @CustID
				, @ActionID			= @ActionID
				, @TrackingValue	= @logSpData
				, @TrackingValue2	= @logSpData_Old
				, @duration			= @duration
		END TRY

		BEGIN CATCH
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
				, @CustID			= @CustID
				, @ActionID			= @ActionID
				, @TrackingValue	= @logSpData
				, @TrackingValue2	= @logSpData_Old
				, @duration			= @duration
		END CATCH
	END

	DROP TABLE #NewDisableStatTbl
	DROP TABLE #OldDisableStatTbl
END
GO
