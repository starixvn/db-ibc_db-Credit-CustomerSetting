/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatusUpd] 
	  @CustID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20180118@Elodie
	Task : Update enabled status on NAP & ExtNAP
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20180118@Elodie: Update enable status on NAP & ExtNAP [RedmineID:#87328]

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"	
						UpdateAllMasters="1"					
						UpdateAllAgents="1"
						UpdateAllMembers="1"
						DisableAllMasters="0"
						DisableAllAgents="0"
						DisableAllMembers="0"
				/>
		</ROOT>
	Example:
		DECLARE @p3 int
		SET @p3=0
		DECLARE @p4 nvarchar(200)
		SET @p4=N''
		DECLARE @p5 int
		SET @p5=0
		EXEC Acc_Admin_DisableNewProductStatusUpd @UserID=169368,@IP='202.78.231.34',@MsgType=@p3 output,@ErrMsg=@p4 output,@ErrCode=@p5 output,@IsDisabled='<ROOT><ProductStatus SportType="212" BetType="4001" IsDisabled="0" UpdateAllMasters="1" UpdateAllAgents="1" UpdateAllMembers="1" DisableAllMasters="1" DisableAllAgents="1" DisableAllMembers="1"/></ROOT>',@CustID=1176070
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
	
	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	CREATE TABLE #NewDisableStatTbl (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, UpdateAllMasters		BIT
		, UpdateAllAgents		BIT
		, UpdateAllMembers		BIT
		, DisableAllMasters		BIT
		, DisableAllAgents		BIT
		, DisableAllMembers		BIT
		)
	CREATE TABLE #OldDisableStatTbl  (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, UpdateAllMasters		BIT
		, UpdateAllAgents		BIT
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
			, UpdateAllMasters		BIT
			, UpdateAllAgents		BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
			)
	
	EXEC sp_xml_removedocument @iDoc

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
	EXEC [dbo].[Acc_Admin_DisableNewProductStatusCheck] 
		@IsDisabled = @IsDisabled
		, @RoleID	= @RoleID
		, @AgentID	= @AgentID
		, @MasterID = @MasterID
		, @SuperID	= @SuperID
		, @ErrCode	= @ErrCode	OUTPUT
		, @MsgType	= @MsgType  OUTPUT
		, @ErrMsg	= @ErrMsg	OUTPUT

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
						LEFT JOIN #NewDisableStatTbl ns ON psp.Sporttype = ns.SportType AND psp.Bettype = ns.BetType
					WHERE ps.SettingType = 13 AND
						((ps.ProductID = @ProductID AND ps.ProductID <> 41)
							OR (ps.ProductID = 41 AND ns.IsDisabled = 0))
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
			IF @ProductID = 24 --Fishing World
			BEGIN
				IF (@RoleID = 4 AND EXISTS (	SELECT 1
											FROM custinfo WITH (NOLOCK)
											WHERE srecommend = @CustID AND roleid = 1
											))
					OR (@RoleID = 3 AND EXISTS (SELECT 1
												FROM custinfo WITH (NOLOCK)
												WHERE mrecommend = @CustID AND roleid = 1
												))
					OR (@RoleID = 2 AND EXISTS (SELECT 1
												FROM custinfo WITH (NOLOCK)
												WHERE recommend = @CustID AND roleid = 1
												))
					SET @downlines = 1

				IF @downlines = 1
				BEGIN
					IF EXISTS (	SELECT TOP 1 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0 AND UpdateAllMembers = 1 AND DisableAllMembers = 0) --enable member downline
						EXEC DBONUSER.On_User.dbo.Age_MessageNoticeDownlineUpd @CustID = @CustID, @UserID = @UserID, @TypeID = 3, @IsDisabled = @IsDisabled_Downline_tmp
					IF EXISTS (SELECT TOP 1 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1) --disable downline
						EXEC DBONUSER.On_User.dbo.Age_MessageNoticeDownlineUpdStatus @CustID = @CustID, @TypeID = 3, @isViewed = 1
				END
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
	SELECT @WriteLogMaster = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllMasters = 1

	SELECT @WriteLogAgent = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllAgents = 1

	SELECT @WriteLogMember = 1
	FROM #NewDisableStatTbl
	WHERE UpdateAllMembers= 1

	INSERT INTO @LogAction (ActionID)
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = 'Acc_Admin_DisableNewProductStatusUpd' AND ld.ProductID = @ProductID AND ld.Level = @RoleID
		AND ((l.ActionID BETWEEN 60500 AND 64999 AND @RoleID = 4)
			OR (l.ActionID BETWEEN 65500 AND 69999 AND ((@RoleID = 4 AND @WriteLogMaster = 1) OR @RoleID = 3))
			OR (l.ActionID BETWEEN 70500 AND 74999 AND ((@RoleID IN (4,3) AND @WriteLogAgent = 1) OR @RoleID = 2))
			OR (l.ActionID BETWEEN 75500 AND 79999 AND ((@RoleID IN (4,3,2) AND @WriteLogMember = 1) OR @RoleID = 1)))

	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustID							AS '@CustID',
					@UserID							AS '@UserID',
					@IP								AS '@IP',
					(
						SELECT	@ProductID			AS '@ProductID',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	@ProductID			AS '@ProductID',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								BetType				AS '@BetType',
								IsDisabled			AS '@IsDisabled',
								UpdateAllMasters	AS '@UpdateAllMasters',
								DisableAllMasters	AS '@DisableAllMasters',
								UpdateAllAgents		AS '@UpdateAllAgents',
								DisableAllAgents	AS '@DisableAllAgents',
								UpdateAllMembers	AS '@UpdateAllMembers',
								DisableAllMembers	AS '@DisableAllMembers'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_Admin_DisableNewProductStatusUpd'),
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
