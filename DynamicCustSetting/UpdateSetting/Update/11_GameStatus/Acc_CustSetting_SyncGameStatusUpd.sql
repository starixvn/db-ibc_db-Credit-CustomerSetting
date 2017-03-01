ALTER PROCEDURE	[dbo].[Acc_CustSetting_SyncGameStatusUpd] 
	@CustID			INT
,	@IsSynced		BIT				= 1
,	@ProductID		TINYINT
,	@UserID			INT
,	@SubAccID		INT				= 0
,	@IP				VARCHAR(50)		= ''
,	@ErrCode		INT				= 0		OUTPUT
,	@ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT

AS
/*  
	Created: Elodie  
	Date: 20160801
	DB: DBCUST/CustDB
	Task: Update synchronize status on a game 
    
	Revisions:
			
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
		AND	psd.SettingType = 11

	INSERT INTO #OldSyncStatTbl (SportType,BetType,IsSynced)
	SELECT	psp.SportType
		,	psp.BetType
		,	(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) AS IsSynced
	FROM	#NewSyncStatTbl tmp
		INNER JOIN	ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND	tmp.BetType = psp.Bettype
		INNER JOIN	dbo.CustProductStatus stt WITH (NOLOCK) ON	stt.CustID = @CustID
	
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
	BEGIN TRY
		UPDATE CustProductStatus
			SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
		WHERE CustID = @CustID
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100, @ErrMsg = 'Update Sync Status Failed'
	END CATCH
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
				AND psd.SettingType = 11 -- Game Status
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
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
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1159
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1159
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH

	DROP TABLE #NewSyncStatTbl
	DROP TABLE #OldSyncStatTbl
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncGameStatusUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncGameStatusUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncGameStatusUpd] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_SyncGameStatusUpd] TO [vnteam]