/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CustSetting_DisableNewProductSyncStatusUpd] 
	@CustID			INT
,	@IsSynced		BIT				= 1
,	@ProductID		TINYINT
,	@UserID			INT
,	@SubAccID		INT				= 0
,	@IP				VARCHAR(50)		= ''
,   @SettingStatus TINYINT = 0
AS
/*  
	Created: Elodie  
	Date: 20170613
	DB: DBCUST/CustDB
	Task: Update synchronize status on a product (Setting Type 13, 21)
    
	Revisions:
		- 20170919@Johnson: fix the unsynchronized setting (settingType = 13), do not update sync for downlines [Redmine: #72973]	
		- 20200708@Eden: Minimize UM Time - Lock updating customer settings [#136464]	
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	Parameters Explanation:  
	
 */
BEGIN
	SET NOCOUNT ON

	DECLARE	@startRun		DATETIME
		,	@endRun			DATETIME
		,	@duration		INT
		
	DECLARE	@logSpData		NVARCHAR(MAX)
		,	@logSpData_Old	NVARCHAR(MAX)
		,	@xml			XML
				
	DECLARE	@ProductName	VARCHAR(50)
		,	@SettingLevel	TINYINT

	CREATE TABLE	#NewSyncStatTbl (
						SportType			SMALLINT
					,	BetType				SMALLINT
					)
	CREATE TABLE	#OldSyncStatTbl  (
						SportType			SMALLINT
					,	BetType				SMALLINT
					,	IsSynced			BIT					
					)

	SET	@startRun = GETDATE()

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	INSERT INTO	#NewSyncStatTbl (
					SportType
				,	BetType
				)
	SELECT			psd.SportType
				,	psd.BetType
	FROM	#ProductSettingDetail AS psd WITH (NOLOCK)
	WHERE	psd.ProductID = @ProductID
		AND	psd.SettingType IN(13,21)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #NewSyncStatTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType IN(13,21)
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM #NewSyncStatTbl)
	BEGIN
		RETURN
	END
	
	--Get old disabled status			
	INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced)
	SELECT	psp.SportType
		,	psp.BetType
		,	dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced			
	FROM		#NewSyncStatTbl tmp
	INNER JOIN	dbo.ProductStatusProfile PSP WITH (NOLOCK) 
			ON	tmp.SportType = psp.Sporttype 
			AND	tmp.BetType = psp.Bettype
	INNER JOIN	dbo.CustProductStatus stt WITH (NOLOCK) 
			ON	stt.CustID = @CustID
		

	--IF NOT EXISTS (
	--		SELECT TOP 1 1
	--		FROM #OldSyncStatTbl stt
	--		WHERE stt.IsSynced <> @IsSynced
	--		)
	--	RETURN

	--Update main table
	
	DECLARE @xmlStrSynced XML
	
	SET @xmlStrSynced =(
			SELECT (
					SELECT psp.bitmapOrder	AS '@b', @IsSynced	AS '@s'
					FROM ProductStatusProfile psp WITH (NOLOCK)
						JOIN #NewSyncStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)
	
	UPDATE CustProductStatus
		SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
	WHERE CustID = @CustID
			
	--START LOGGING		

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		#ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#OldSyncStatTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType IN(13,21)	-- Product Status
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
								IsSynced			AS '@IsSynced'								
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								IsSynced			AS '@IsSynced'								
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								IsSynced			AS '@IsSynced'								
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								IsSynced			AS '@IsSynced'							
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced'						
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced'							
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced'							
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced'								
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableNewProductSyncStatusUpd'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1162
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1162
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH

	DROP TABLE #NewSyncStatTbl
	DROP TABLE #OldSyncStatTbl
	DROP TABLE #ProductSettingDetail
END
GO