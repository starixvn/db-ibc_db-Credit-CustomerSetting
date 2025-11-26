/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUdpDanger_JobExclusion]
	@CustList	VARCHAR(MAX) = '',
	@ErrCode	INT = 0	OUTPUT,
	@ErrMsg		NVARCHAR(200) = '' OUTPUT		
AS
/*
	Created: 20220802@Tacy
	Task : Update list Customers belong to Customer Class 8,9,10,131,86,96,106,132 to update saba danger level 13 [RedmineId: #175857]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20220802@Tacy: Create SP
		- 20221110@Tacy: LAP - Support Danger Level report, modify ActionID writelog [RedmineID: #179078]
		- 20251126@Winfred: Risk Control Upgrade SportType DataType [RedmineId: #245209]
	Parameter's Explanation:		
		- @CustList  =  '<Root>
							<r CustID="100" SportType="1" Action="1"/>
							<r CustID="100" SportType="2" Action="1"/>
							<r CustID="102" SportType="1" Action="-1"/>
						</Root>'
		- action: -1 ~ remove, <>-1 ~ insert
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @StartRun DATETIME, @Duration INT, @batchNo INT
	DECLARE @xml XML = NULL

	CREATE TABLE #tblCustOld (
			CustID		INT
		,	SportType	SMALLINT
		,	CreateDate	DATETIME
		,	RemoveDate	DATETIME
		,	Action		SMALLINT	
		,	PRIMARY KEY CLUSTERED (CustID, SportType)
	)

	CREATE TABLE #tblCustDangerOld (
			Custid				INT
		,	DangerLevel			BIGINT
		,	Soccer				TINYINT
		,	Basketball			TINYINT
		,	PRIMARY KEY CLUSTERED (CustID)
	)

	CREATE TABLE #tblCustList (
			CustID		INT
		,	SportType	SMALLINT
		,	Action		SMALLINT	
		,	PRIMARY KEY CLUSTERED (CustID, SportType)
	)

	CREATE TABLE #tblCustUpdate(
			CustID				INT 
		,	Soccer				TINYINT 
		,	Basketball			TINYINT
		,	UpdateSoccer		BIT
		,	UpdateBasketball	BIT
		,	PRIMARY KEY CLUSTERED (CustID)
	)

	SET @StartRun = GETDATE()
	
	--Check if XML is null or empty
	IF @CustList IS NULL OR @CustList=''
	BEGIN
		SET @ErrCode=101
		SET @ErrMsg='Customer list is invalid.'
		RETURN
	END

	SET @xml = CONVERT(XML, @CustList)

	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @xml

	INSERT INTO #tblCustList(CustID, SportType, Action)
	SELECT CustID, SportType, Action
	FROM OPENXML(@iDoc, '/Root/r', 1) WITH (
			CustID		INT
		,	SportType	SMALLINT
		,	Action		SMALLINT
	)
	
	EXEC sp_xml_removedocument @iDoc

	--Remove:
	DELETE cd
	OUTPUT deleted.CustID, deleted.SportType, GETDATE(), -1
		INTO #tblCustOld (CustID, SportType, RemoveDate, Action)
	FROM CustDangerJobExclusion cd WITH (ROWLOCK)
		INNER JOIN #tblCustList t ON t.CustID=cd.CustID AND t.SportType=cd.SportType
	WHERE t.Action=-1
	
	--Add new customer:
	INSERT INTO CustDangerJobExclusion(CustID, SportType, CreateDate)
	OUTPUT inserted.CustID, inserted.SportType, inserted.CreateDate, 1
		INTO #tblCustOld (CustID, SportType, CreateDate, Action)
	SELECT t.CustID, t.SportType, GETDATE()
	FROM #tblCustList t
		LEFT JOIN CustDangerJobExclusion cd WITH (NOLOCK) ON t.CustID=cd.CustID AND t.SportType=cd.SportType
	WHERE cd.CustID IS NULL AND t.Action=1

	--get dangerlevel old:
	INSERT INTO #tblCustDangerOld(custid,DangerLevel,Soccer,Basketball)
	SELECT custid, ISNULL(DangerLevel,0), soccer, basketball
	FROM custinfo c WITH(NOLOCK)
		CROSS APPLY dbo.f_GetDangerLevelInfo(ISNULL(DangerLevel,0)) t
	WHERE custid IN (SELECT DISTINCT custid FROM #tblCustList WHERE Action=1)

	--get dangerlevel update
	INSERT INTO #tblCustUpdate(CustID, Soccer, Basketball, UpdateSoccer, UpdateBasketball)
	SELECT DISTINCT 
		  cd.CustID
		, CASE WHEN sc.CustID IS NOT NULL THEN 13 END SoccerLevel
		, CASE WHEN bb.CustID IS NOT NULL THEN 13 END BasketballLevel
		, CASE WHEN sc.CustID IS NOT NULL THEN 1 ELSE 0 END UpdateSoccer
		, CASE WHEN bb.CustID IS NOT NULL THEN 1 ELSE 0 END UpdateBasketball
	FROM CustDangerJobExclusion cd WITH (NOLOCK)
		INNER JOIN #tblCustList t ON t.CustID=cd.CustID AND t.SportType=cd.SportType AND t.Action=1
		OUTER APPLY (SELECT TOP (1) t.CustID FROM #tblCustList t WHERE t.CustID=cd.CustID AND t.SportType=1 AND t.Action=1) sc
		OUTER APPLY (SELECT TOP (1) t.CustID FROM #tblCustList t WHERE t.CustID=cd.CustID AND t.SportType=2 AND t.Action=1) bb

	--Update Danger Level
	DECLARE @CustUpdate VARCHAR(MAX) 
	
	SELECT @CustUpdate = CAST((
		SELECT new.custid as '@id',
			dbo.f_GenerateDangerLevelInfo(DangerLevel,new.Soccer,new.Basketball,UpdateSoccer,UpdateBasketball) as '@value'
		FROM #tblCustUpdate new
			INNER JOIN #tblCustDangerOld old ON old.Custid=new.CustID
		FOR XML PATH('r'),ROOT('Root')
	) AS VARCHAR(MAX))
	
	DECLARE @ErrMsgLog VARCHAR(1000)
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustUpdate,										
										@mode = 'SabaDangerLevel'	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsgLog = ERROR_MESSAGE(),
			@ErrMsg = 'Update unsuccessfully'		
	END CATCH 

	--logging
	SELECT @batchNo = MAX(batchNo) + 1 
	FROM CustDangerLevelInfo WITH(NOLOCK)

	SELECT @batchNo = CASE WHEN @batchNo < (MAX(batchNo) + 1) THEN MAX(batchNo) + 1 ELSE @batchNo END
	FROM CustDangerWinlossInfo WITH(NOLOCK)

	SELECT @batchNo = ISNULL(@batchNo,1)

	INSERT INTO CustDangerLevelInfo(Custid,
									BatchNo,
									Soccer,
									Basketball,
									UpdateSoccer,
									UpdateBasketball,
									Status,
									Description,		
									CreatedDate)
	SELECT custid, @BatchNo, Soccer, Basketball, UpdateSoccer, UpdateBasketball, 
		CASE WHEN @ErrCode > 0 THEN 'fail' ELSE 'completed' END status,
		CASE WHEN @ErrMsgLog IS NOT NULL THEN @ErrMsgLog ELSE 'PA List' END Description,
		GETDATE() as CreatedDate
	FROM #tblCustUpdate t
	
	IF @ErrCode > 0
		RETURN;

	--WriteLog Add/Remove PA List, update DangerLevel
	DECLARE @LogSoccer		VARCHAR(MAX),	--1191
			@LogBasketball	VARCHAR(MAX),	--1192
			@LogAdd			VARCHAR(MAX),	--1189
			@LogRemove		VARCHAR(MAX)	--1190

	SELECT @LogAdd = CAST((
		SELECT	custid		AS '@CustID',
				SportType	AS '@SportType'
		FROM #tblCustOld t
		WHERE Action=1
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	

	SELECT @LogRemove = CAST((
		SELECT	custid		AS '@CustID',
				SportType	AS '@SportType'
		FROM #tblCustOld t
		WHERE Action=-1
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))

	SELECT @LogSoccer = CAST((
		SELECT	new.custid	as '@id',
				'0'			as '@sport',
				new.soccer	as '@newlevel',
				old.Soccer	as '@oldlevel',
				'NULL'		as '@wl',
				'1'			as '@IsPA'
		FROM #tblCustUpdate new
			INNER JOIN #tblCustDangerOld old ON old.Custid=new.CustID
		WHERE UpdateSoccer=1
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	
	
	SELECT @LogBasketball = CAST((
		SELECT	new.custid		as '@id',
				'1'				as '@sport',
				new.basketball	as '@newlevel',
				old.Basketball	as '@oldlevel',
				'NULL'			as '@wl',
				'1'				as '@IsPA'
		FROM #tblCustUpdate new
			INNER JOIN #tblCustDangerOld old ON old.Custid=new.CustID
		WHERE UpdateBasketball=1
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	

	SELECT @Duration = DATEDIFF (MILLISECOND, @StartRun, GETDATE())
	
	--log add 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT	
			@ActionId	= 1189,   
			@Log		= @LogAdd,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT
			@ActionId	= 1189,
			@Log		= @LogAdd,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration			
	END CATCH

	--log remove
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT	
			@ActionId	= 1190,   
			@Log		= @LogRemove,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT
			@ActionId	= 1190,
			@Log		= @LogRemove,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration			
	END CATCH
	
	--log update dangerlevel
	BEGIN TRY
		-- Log Soccer
		IF @LogSoccer IS NOT NULL OR @LogSoccer<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1191,
				@Log		= @LogSoccer,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			--LAP
			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogSoccer,	
				@ActionID = 1191,
				@Duration = @Duration,
				@UserID	= 10278938
		END

		--Log Basketball
		IF @LogBasketball IS NOT NULL OR @LogBasketball<>''
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1192,
				@Log		= @LogBasketball,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			EXEC DBLOG.bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogBasketball,	
				@ActionID = 1192,
				@Duration = @Duration,
				@UserID	= 10278938
		END
	END TRY
	BEGIN CATCH
		-- Log Soccer
		IF @LogSoccer IS NOT NULL OR @LogSoccer<>''
		BEGIN
			EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1191,
				@Log		= @LogSoccer,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			--LAP
			EXEC bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogSoccer,	
				@ActionID = 1191,
				@Duration = @Duration,
				@UserID	= 10278938
		END

		--Log Basketball
		IF @LogBasketball IS NOT NULL OR @LogBasketball<>''
		BEGIN
			EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
				@UserId		= 10278938,	--StarixIT	
				@ActionId	= 1192,
				@Log		= @LogBasketball,		
				@IP			= '125.227.140.97',	
				@Duration	= @Duration

			EXEC bodb_CustomerLog.dbo.Lrf_WriteLog_UserLog_UserControl_Multiple
				@LogData = @LogBasketball,	
				@ActionID = 1192,
				@Duration = @Duration,
				@UserID	= 10278938
		END
	END CATCH

	DROP TABLE #tblCustOld
	DROP TABLE #tblCustDangerOld
	DROP TABLE #tblCustList
	DROP TABLE #tblCustUpdate
END
GO