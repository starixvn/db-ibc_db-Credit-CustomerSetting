ALTER PROCEDURE	[dbo].[Acc_CustSetting_SyncGameStatusUpd_Multiple] 
	@CustIDs		VARCHAR(MAX)	= NULL
,	@IsSynced		BIT				= 1
,	@ProductID		TINYINT
,	@UserID			INT
,	@IP				VARCHAR(50)		= ''
,	@ErrCode		INT				= 0		OUTPUT
,	@ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT

AS
/*  
	Created: Elodie  
	Date: 20160801
	DB: DBCUST/CustDB
	Task: Update synchronize status multiple on a game 
    
	Revisions:
			
	Parameters Explanation:  

	Example: 
		EXEC Acc_CustSetting_SyncGameStatusUpd_Multiple @CustIDs = '5106,6525,8921', @IsSynced = 1, @ProductID = 23, @UserID = 8, @IP = "192.168.56.1"
	
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
		,	@CustID			INT

	CREATE TABLE	#CustList (CustID INT PRIMARY KEY, IsFinished BIT DEFAULT(0))

	CREATE TABLE	#NewSyncStatTbl (
						SportType	SMALLINT
					,	BetType		SMALLINT
					)
	CREATE TABLE	#OldSyncStatTbl  (
						CustID		INT
					,	SportType	SMALLINT
					,	BetType		SMALLINT
					,	IsSynced	BIT
					)

	SET	@startRun = GETDATE()

	INSERT INTO #CustList(CustID)
	SELECT val AS CustID
	FROM strSplit(@CustIDs, ',')

	INSERT INTO	#NewSyncStatTbl (
					SportType
				,	BetType
				)
	SELECT			psd.SportType
				,	psd.BetType
	FROM	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
	WHERE	psd.ProductID = @ProductID
		AND	psd.SettingType = 11

	INSERT INTO #OldSyncStatTbl (CustID,SportType,BetType,IsSynced)
	SELECT	stt.CustID
		,	psp.SportType
		,	psp.BetType
		,	(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) AS IsSynced
	FROM	#NewSyncStatTbl tmp
		INNER JOIN	ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND	tmp.BetType = psp.Bettype
		CROSS APPLY	dbo.CustProductStatus stt WITH (NOLOCK) 
	WHERE EXISTS (SELECT 1 FROM #CustList WHERE CustID = stt.CustID)
	
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
		UPDATE cs 
		SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced)))	
		FROM CustProductStatus cs WITH (NOLOCK)
			INNER JOIN #CustList c ON c.CustID = cs.CustID
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

	SELECT @endRun = GETDATE()
			, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	-- write log for summary info
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustIDs						AS '@CustID',
					@UserID							AS '@UserID',
					@IP								AS '@IP',
					(
						SELECT	@ProductID			AS '@ProductID',
								@IsSynced			AS '@IsSynced'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
			TYPE
		)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustIDs						AS '@CustID',
					@UserID							AS '@UserID',
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								@IsSynced			AS '@IsSynced'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
			TYPE
		)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustIDs						AS '@CustID',
					@UserID							AS '@UserID',
					@IP								AS '@IP',
					(
						SELECT	BetType				AS '@BetType',
								@IsSynced			AS '@IsSynced'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
			TYPE
		)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
			SELECT	@ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@CustIDs						AS '@CustID',
					@UserID							AS '@UserID',
					@IP								AS '@IP',
					(
						SELECT	SportType			AS '@SportType',
								BetType				AS '@BetType',
								@IsSynced			AS '@IsSynced'
						FROM #NewSyncStatTbl
						FOR XML PATH('ProductStatus'),
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
			TYPE
		)
	END
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= 0
			, @ActionID			= 1160
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= NULL
			, @duration			= @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= 0
			, @ActionID			= 1160
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= NULL
			, @duration			= @duration
	END CATCH
	
	-- write log for each CustID
	WHILE (1 = 1)
	BEGIN
		UPDATE TOP (1) #CustList
		SET isfinished = 1
			,@CustID = custid	
		WHERE isfinished = 0
	
		IF @@ROWCOUNT = 0 BREAK
			
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
									IsSynced			AS '@IsSynced'
							FROM #OldSyncStatTbl
							WHERE CustID = @CustID
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									IsSynced			AS '@IsSynced'
							FROM #OldSyncStatTbl
							WHERE CustID = @CustID
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									IsSynced			AS '@IsSynced'
							FROM #OldSyncStatTbl
							WHERE CustID = @CustID
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									IsSynced			AS '@IsSynced'
							FROM #OldSyncStatTbl
							WHERE CustID = @CustID
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									@IsSynced			AS '@IsSynced'
							FROM #NewSyncStatTbl
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									@IsSynced			AS '@IsSynced'
							FROM #NewSyncStatTbl
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									@IsSynced			AS '@IsSynced'
							FROM #NewSyncStatTbl
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
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
									@IsSynced			AS '@IsSynced'
							FROM #NewSyncStatTbl
							FOR XML PATH('ProductStatus'),
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SyncGameStatusUpd_Multiple'),
				TYPE
			)
		END
		SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
				, @CustID			= @CustID
				, @ActionID			= 1160
				, @TrackingValue	= @logSpData
				, @TrackingValue2	= @logSpData_Old
				, @duration			= @duration
		END TRY

		BEGIN CATCH
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
				, @CustID			= @CustID
				, @ActionID			= 1160
				, @TrackingValue	= @logSpData
				, @TrackingValue2	= @logSpData_Old
				, @duration			= @duration
		END CATCH
	END
	
	DROP TABLE #NewSyncStatTbl
	DROP TABLE #OldSyncStatTbl
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncGameStatusUpd_Multiple] TO [bodbadminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_SyncGameStatusUpd_Multiple] TO [vnteam]