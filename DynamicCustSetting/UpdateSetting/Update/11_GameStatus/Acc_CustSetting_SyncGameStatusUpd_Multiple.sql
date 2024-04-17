/*<info serverAlias="DBCust-CustDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	Acc_CustSetting_SyncGameStatusUpd_Multiple
	@CustIDs		VARCHAR(MAX)	= NULL
,	@IsSynced		BIT				= 1
,	@ProductID		TINYINT
,	@UserID			INT
,	@IP				VARCHAR(50)		= ''
,	@ErrCode		INT				= 0		OUTPUT
,	@ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
,	@SettingStatus  TINYINT = 0

AS
/*  
	Created: Elodie  
	Date: 20160801
	DB: DBCUST/CustDB
	Task: Update synchronize status multiple on a game 
    
	Revisions:
		- 20200608@Johnson: enable product NG2 when update sync [redmine:#135489] 	
		- 20220613@Elodie: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831]  
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]

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

	CREATE TABLE	#CustList (CustID INT PRIMARY KEY, roleid TINYINT, srecommend INT, mrecommend INT, recommend INT, xmlStrDisabled XML,  IsFinished BIT DEFAULT(0))
		
	CREATE TABLE	#NewSyncStatTbl (
						SportType	SMALLINT
					,	BetType		SMALLINT
					)
	CREATE TABLE	#OldSyncStatTbl  (
						CustID		INT
					,	SportType	SMALLINT
					,	BetType		SMALLINT
					,	IsSynced	BIT
					,	isDisabled 	BIT
					,	IsDisabled_new BIT 
					)

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

	SET	@startRun = GETDATE()

	INSERT INTO #CustList(CustID)
	SELECT value AS CustID
	FROM string_split(@CustIDs, ',')
	WHERE value <> ''

	INSERT INTO	#NewSyncStatTbl (SportType,	BetType)
	SELECT SportType, BetType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus)

	INSERT INTO #OldSyncStatTbl (CustID,SportType,BetType,IsSynced,isDisabled)
	SELECT	stt.CustID
		,	psp.SportType
		,	psp.BetType
		,	(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) AS IsSynced
		,	(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
	FROM	#NewSyncStatTbl tmp
		INNER JOIN	ProductStatusProfile PSP WITH (NOLOCK) ON tmp.SportType = psp.Sporttype AND	tmp.BetType = psp.Bettype
		CROSS APPLY	dbo.CustProductStatus stt WITH (NOLOCK) 
	WHERE EXISTS (SELECT 1 FROM #CustList WHERE CustID = stt.CustID)
		
	DECLARE @xmlStrSynced XML
	
	UPDATE c
	SET recommend = ci.recommend,
		mrecommend = ci.mrecommend,
		srecommend = ci.srecommend,				
		roleid = ci.roleid				
	FROM #CustList c
		INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
	
	--roleid = 4
	IF EXISTS (SELECT 1 FROM #CustList WHERE roleid = 4)
	BEGIN
		UPDATE stt
		SET isDisabled_new = 0
		FROM #OldSyncStatTbl stt
			INNER JOIN #CustList c ON stt.custid = c.custid
		WHERE c.roleid = 4	
	END
	
	--roleid = 3
	IF EXISTS (SELECT 1 FROM #CustList WHERE roleid = 3)
	BEGIN
		UPDATE stt
		SET isDisabled_new = CASE WHEN uplineNew.custid IS NOT NULL THEN uplineNew.isDisabled_new 
								ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(upline.bitmapIsDisabled, PSP.bitmapOrder)) END
		FROM #OldSyncStatTbl stt
			INNER JOIN #CustList c ON stt.custid = c.custid
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON stt.SportType = psp.Sporttype AND	stt.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus upline WITH (NOLOCK) ON upline.custid = c.srecommend
			LEFT JOIN #OldSyncStatTbl UplineNew ON UplineNew.custid = c.srecommend
		WHERE c.roleid = 3	
	END
	
	--roleid = 2
	IF EXISTS (SELECT 1 FROM #CustList WHERE roleid = 2)
	BEGIN
		UPDATE stt
		SET isDisabled_new = CASE WHEN uplineNew.custid IS NOT NULL THEN uplineNew.isDisabled_new 
								ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(upline.bitmapIsDisabled, PSP.bitmapOrder)) END
		FROM #OldSyncStatTbl stt
			INNER JOIN #CustList c ON stt.custid = c.custid
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON stt.SportType = psp.Sporttype AND	stt.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus upline WITH (NOLOCK) ON upline.custid = c.mrecommend
			LEFT JOIN #OldSyncStatTbl UplineNew ON UplineNew.custid = c.mrecommend
		WHERE c.roleid = 2
	END
	
	--roleid = 1
	IF EXISTS (SELECT 1 FROM #CustList WHERE roleid = 1)
	BEGIN
		UPDATE stt
		SET isDisabled_new = CASE WHEN uplineNew.custid IS NOT NULL THEN uplineNew.isDisabled_new 
								ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(upline.bitmapIsDisabled, PSP.bitmapOrder)) END
		FROM #OldSyncStatTbl stt
			INNER JOIN #CustList c ON stt.custid = c.custid
			INNER JOIN ProductStatusProfile PSP WITH (NOLOCK) ON stt.SportType = psp.Sporttype AND	stt.BetType = psp.Bettype
			INNER JOIN dbo.CustProductStatus upline WITH (NOLOCK) ON upline.custid = c.recommend
			LEFT JOIN #OldSyncStatTbl UplineNew ON UplineNew.custid = c.recommend
		WHERE c.roleid = 1
	END
	
	UPDATE c
	SET xmlStrDisabled = (
			SELECT (
					SELECT psp.bitmapOrder	AS '@b', 
						t.isDisabled AS '@s'
					FROM ProductStatusProfile psp WITH (NOLOCK)
						JOIN #NewSyncStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						CROSS APPLY (SELECT isDisabled_new as isDisabled 
									FROM #OldSyncStatTbl stt 
									WHERE stt.custid = c.custid
										AND stt.SportType = tmp.SportType 
										AND stt.Bettype = tmp.Bettype
									)t							
					FOR XML PATH('r')
						, TYPE
					)
			FOR XML PATH('root')
				, TYPE
			)
	FROM #CustList c		
	
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
		SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSynced))),
			bitmapIsDisabled = CASE WHEN @IsSynced = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),xmlStrDisabled)))
									ELSE bitmapIsDisabled END
		FROM CustProductStatus cs WITH (UPDLOCK,ROWLOCK)
			INNER JOIN #CustList c ON c.CustID = cs.CustID
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100, @ErrMsg = 'Update Sync Status Failed'
	END CATCH
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
									IsSynced			AS '@IsSynced',
									isDisabled			AS '@IsDisabled'
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
									IsSynced			AS '@IsSynced',
									isDisabled			AS '@IsDisabled'
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
									IsSynced			AS '@IsSynced',
									isDisabled			AS '@IsDisabled'
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
									IsSynced			AS '@IsSynced',
									isDisabled			AS '@IsDisabled'									
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
									@IsSynced			AS '@IsSynced',
									isDisabled_new		AS '@IsDisabled'
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
									@IsSynced			AS '@IsSynced',
									isDisabled_new		AS '@IsDisabled'
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
									@IsSynced			AS '@IsSynced',
									isDisabled_new		AS '@IsDisabled'
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
									@IsSynced			AS '@IsSynced',
									isDisabled_new		AS '@IsDisabled'
							FROM #OldSyncStatTbl
							WHERE CustID = @CustID
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
