ALTER PROCEDURE	[dbo].[Acc_CustSetting_SyncStatusUpd] 
	@CustID			INT
,	@IsSynced		BIT				= 1
,	@ProductID		TINYINT
,	@UserID			INT
,	@SubAccID		INT				= 0
,	@IP				VARCHAR(50)		= ''
AS
/*  
	Created: Elodie  
	Date: 20160215 
	DB: DBCUST/CustDB
	Task: Update synchronize status on a product 
    
	Revisions:
			- 20160425@Winnie: Fix bug #56577 [NAP] Log IsSyncedDownline is not changed
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
		
	DECLARE	@AgentID		INT
		,	@MasterID		INT
		,	@SuperID		INT
		,	@RoleID			INT
	
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
					,	IsSyncedDownline	BIT
					)

	SET	@startRun = GETDATE()

	--Get line information
	SELECT	@AgentID = ci.recommend
		,	@MasterID = ci.mrecommend
		,	@SuperID = ci.srecommend
		,	@RoleID	= ci.roleid
	FROM	dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.custid = @CustID
	
	INSERT INTO	#NewSyncStatTbl (
					SportType
				,	BetType
				)
	SELECT			psd.SportType
				,	psd.BetType
	FROM	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
	WHERE	psd.ProductID = @ProductID
		AND	psd.SettingType = 4

	--Get old disabled status
	DECLARE @downlines BIT  = 0
	
	IF @roleid = 4
	BEGIN		
		IF EXISTS (SELECT 1 FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)
			SET @downlines = 1
			
		INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced,IsSyncedDownline)
		SELECT	psp.SportType
			,	psp.BetType
			,	dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
			,	CASE WHEN @downlines = 0	
						THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),0)
						ELSE ISNULL	((
									SELECT	TOP 1 0
									FROM		dbo.custInfo ci WITH (NOLOCK)
									INNER JOIN	dbo.CustProductStatus cps_temp 
											ON	ci.custid = cps_temp.CustID
									WHERE	srecommend = @CustID
										--AND	roleid = 3
										AND	dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
								), 1)
				END AS IsSyncedDownline
		FROM		#NewSyncStatTbl tmp
		INNER JOIN	ProductStatusProfile PSP WITH (NOLOCK) 
				ON	tmp.SportType = psp.Sporttype 
				AND	tmp.BetType = psp.Bettype
		INNER JOIN	dbo.CustProductStatus stt WITH (NOLOCK) 
				ON	stt.CustID = @CustID
				
	END
	ELSE IF @roleid = 3
	BEGIN
	
		IF EXISTS (SELECT 1
						FROM custinfo WITH (NOLOCK)
						WHERE mrecommend = @CustID	AND roleid = 2
						)
			SET @downlines = 1	
		
		INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced,IsSyncedDownline)
		SELECT	psp.SportType
			,	psp.BetType
			,	dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
			,	CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),0)
					ELSE ISNULL((
							SELECT TOP 1 0
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE mrecommend = @CustID	--AND roleid = 2
								AND dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
							), 1)
								
				 END AS IsSyncedDownline
		
		FROM #NewSyncStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
				 
	END 	
	ELSE IF @roleid = 2
	BEGIN
	
		IF EXISTS (SELECT 1
						FROM custinfo WITH (NOLOCK)
						WHERE recommend = @CustID AND roleid = 1
						)
			SET @downlines = 1	
		
		INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced,IsSyncedDownline)
		SELECT psp.SportType
			, psp.BetType
			, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
			
			, CASE 	
						WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),0)
						ELSE ISNULL((
								SELECT TOP 1 0
								FROM dbo.custInfo ci WITH (NOLOCK)
									INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
								WHERE recommend = @CustID	--AND roleid = 1
									AND dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
								), 1)
								
				 END AS IsSyncedDownline
		
		FROM #NewSyncStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
				 
	END 
	ELSE IF @roleid = 1
	BEGIN
	
		INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced,IsSyncedDownline)
		SELECT psp.SportType
			, psp.BetType
			, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
			
			, 0 IsSyncedDownline
		
		FROM #NewSyncStatTbl tmp
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND tmp.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @CustID
			
	END

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
	
	--call execrept to update downline
	IF @RoleID <> 1 
	BEGIN
				EXECUTE	dbo.[Acc_DynamicCustomerInfo_03] 
					@CustID			= @CustID
				,	@IsSynced       = @IsSynced
				,	@RoleID			= @RoleID
				,	@ProductID		= @ProductID
	
	END
	
	--START LOGGING		

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	#OldSyncStatTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 4	-- Product Status
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
								IsSynced			AS '@IsSynced',
								IsSyncedDownline	AS '@IsSyncedDownline'
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								IsSynced			AS '@IsSynced',
								IsSyncedDownline	AS '@IsSyncedDownline'
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								IsSynced			AS '@IsSynced',
								IsSyncedDownline	AS '@IsSyncedDownline'
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								IsSynced			AS '@IsSynced',
								IsSyncedDownline	AS '@IsSyncedDownline'
						FROM #OldSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced',
								@IsSynced			AS '@IsSyncedDownline'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced',
								@IsSynced			AS '@IsSyncedDownline'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced',
								@IsSynced			AS '@IsSyncedDownline'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
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
								@IsSynced			AS '@IsSynced',
								@IsSynced			AS '@IsSyncedDownline'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncStatusUpd'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1153
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1153
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH

	DROP TABLE #NewSyncStatTbl
	DROP TABLE #OldSyncStatTbl
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusUpd] TO [bodbExtAccNet]