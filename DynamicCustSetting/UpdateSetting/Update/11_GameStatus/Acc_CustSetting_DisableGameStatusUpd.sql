ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableGameStatusUpd] 
	  @CustID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160801@Elodie
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:

	Revisions:

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"
						IsDisabledDownline="1"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
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
		, IsDisabledDownline	BIT
		)
	CREATE TABLE #OldDisableStatTbl  (
		SportType		SMALLINT
		, BetType		SMALLINT
		, IsDisabled	BIT
		, IsDisabledDownline	BIT
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
			, IsDisabledDownline	BIT
			)
	
	EXEC sp_xml_removedocument @iDoc

	
	--Validate new disabled status
	EXEC [dbo].[Acc_CustSetting_DisableGameStatusCheck] 
		@IsDisabled = @IsDisabled
		, @RoleID	= @RoleID
		, @AgentID	= @AgentID
		, @MasterID = @MasterID
		, @SuperID	= @SuperID
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN
	
	--Get old disabled status
	DECLARE @downlines BIT  = 0, @Upline INT 
	
	IF @roleid = 4
	BEGIN		
		IF EXISTS (SELECT 1
						FROM custinfo WITH (NOLOCK)
						WHERE srecommend = @CustID	AND roleid = 3
						)
			SET @downlines = 1
			
		INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT	psp.SportType,
				psp.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled,
				CASE 	
					WHEN @downlines = 0	THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))
					ELSE ISNULL((	SELECT TOP 1 1
									FROM dbo.custInfo ci WITH (NOLOCK)
										INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
										OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
										OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
									WHERE srecommend = @CustID	AND roleid = 3
										AND IsSynced.value = 1
										AND IsDisabled.value = 1
									), 0) END AS IsDisabledDownline
		
		FROM #NewDisableStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
				
	END
	ELSE IF @roleid = 3
	BEGIN
	
		IF EXISTS (	SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE mrecommend = @CustID	AND roleid = 2
					)
			SET @downlines = 1	
		
		INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT	psp.SportType,
				psp.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled,
				CASE 	
					WHEN @downlines = 0	THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))
					ELSE ISNULL((	SELECT TOP 1 1
									FROM dbo.custInfo ci WITH (NOLOCK)
										INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
										OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
										OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
									WHERE mrecommend = @CustID	AND roleid = 2
										AND IsSynced.value = 1
										AND IsDisabled.value = 1
									), 0) END AS IsDisabledDownline
		
		FROM #NewDisableStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
				 
	END 	
	ELSE IF @roleid = 2
	BEGIN
	
		IF EXISTS (	SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE recommend = @CustID AND roleid = 1
					)
			SET @downlines = 1	
		
		INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT	psp.SportType,
				psp.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled,
				CASE 
					WHEN @downlines = 0	THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))
						ELSE ISNULL((
								SELECT TOP 1 1
								FROM dbo.custInfo ci WITH (NOLOCK)
									INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
									OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
									OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
								WHERE recommend = @CustID AND roleid = 1
									AND IsSynced.value = 1
									AND IsDisabled.value = 1
								), 0) END AS IsDisabledDownline
		
		FROM #NewDisableStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
				 
	END 
	ELSE IF @roleid = 1
	BEGIN
	
		INSERT INTO #OldDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
		SELECT	psp.SportType,
				psp.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled,
				0 IsDisabledDownline
		FROM #NewDisableStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
			
	END
		
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
	
	
	DECLARE @bitmapOrderHidden INT
	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
	BEGIN
		
		SET @xmlStrHidden = (
			SELECT (
					SELECT psp.bitmapOrder	AS '@b'
						, 0	AS '@s'
					FROM ProductStatusProfile psp (NOLOCK)
						JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
					WHERE TMP.IsDisabled = 0
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
	IF @RoleID <> 1 AND EXISTS (
			SELECT TOP 1 1
			FROM #NewDisableStatTbl
			WHERE IsDisabled = 1
				OR (
						IsDisabled				= 0
						AND IsDisabledDownline	= 0
					)
			)
	BEGIN		
		
		EXEC dbo.[Acc_DynamicCustomerInfo_04] 
			@CustID = @CustID
			, @RoleID			= @RoleID
			, @IsDisabled_XML	= @IsDisabled
			, @Action = 'GameStatus'
	
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
				AND psd.SettingType = 11	-- Game Status
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #OldDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
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
								IsDisabled			AS '@IsDisabled',
								IsDisabledDownline	AS '@IsDisabledDownline'
						FROM #NewDisableStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableGameStatusUpd'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1158
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1158
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH
	DROP TABLE #NewDisableStatTbl
	DROP TABLE #OldDisableStatTbl
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableGameStatusUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableGameStatusUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableGameStatusUpd] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DisableGameStatusUpd] TO [vnteam]
