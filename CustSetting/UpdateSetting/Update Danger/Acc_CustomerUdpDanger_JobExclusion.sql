/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUdpDanger_JobExclusion]
	@CustList	VARCHAR(MAX) = '',
	@ErrMsg		NVARCHAR(200) = '' OUTPUT	
AS
SET NOCOUNT ON
/*
	Created: 20220802@Tacy
	Task : Update list Customers belong to Customer Class 8,9,10,131 to update saba danger level 13 [RedmineId: #175857]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20220802@Tacy: Create SP

	Parameter's Explanation:		
		- @CustList  =  '<Root>
							<r custid="100" categoryid="52" action="-1"/>
							<r custid="101" categoryid="58" action="1"/>
							<r custid="102" categoryid="54" action="1"/>
						</Root>'
		- action: -1 ~ remove, <>-1 ~ insert
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @StartRun DATETIME, @Duration INT, @LogDataNew VARCHAR(500), @LogDataOld VARCHAR(500)
	DECLARE @xml XML = NULL

	CREATE TABLE #tblCustCategoryOld (
			CustID		INT
		,	CategoryID	INT
		,	CreateDate	DATETIME
		,	RemoveDate	DATETIME
		,	Action		VARCHAR(5)	
		,	PRIMARY KEY CLUSTERED (CustID)
	)

	CREATE TABLE #tblCustUpd (
			CustID		INT
		,	CategoryID	INT
		,	Action		VARCHAR(5)	
		,	PRIMARY KEY CLUSTERED (CustID)
	)

	SET @StartRun = GETDATE()
	
	--Check if XML is null or empty
	IF @CustList IS NULL OR @CustList=''
	BEGIN
		SET @ErrMsg='Customer list is invalid.'
		RETURN
	END

	SET @xml = CONVERT(XML, @CustList)

	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @xml

	INSERT INTO #tblCustUpd(CustID, CategoryID, Action)
	SELECT CustID, CategoryID, Action
	FROM OPENXML(@iDoc, '/root/r', 1) WITH (
			CustID		INT
		,	CategoryID	INT
		,	Action		VARCHAR(5)
		)
	
	EXEC sp_xml_removedocument @iDoc

	--Remove:
	DELETE cd
	OUTPUT deleted.CustID, deleted.CategoryID, GETDATE(), '-1'
		INTO #tblCustCategoryOld (CustID, CategoryID, RemoveDate, Action)
	FROM CustDangerJobExclusion cd WITH (ROWLOCK)
		INNER JOIN #tblCustUpd t ON t.CustID=cd.CustID
	WHERE t.Action='-1'
	
	--Insert new customer:
	INSERT INTO CustDangerJobExclusion(CustID, CategoryID, CreateDate)
	OUTPUT inserted.CustID, inserted.CategoryID, inserted.CreateDate, '1'
		INTO #tblCustCategoryOld (CustID, CategoryID, CreateDate, Action)
	SELECT t.CustID, t.CategoryID, GETDATE()
	FROM #tblCustUpd t
		LEFT JOIN CustDangerJobExclusion cd WITH (NOLOCK) ON t.CustID=cd.CustID
	WHERE t.CustID IS NULL AND t.Action='1'

	--update dangerlevel=13
	UPDATE c
	SET c.DangerLevel=13
	FROM custInfo c WITH (UPDLOCK, ROWLOCK)
		INNER JOIN CustDangerJobExclusion cd WITH (NOLOCK)
				ON c.custid=cd.CustID
	WHERE c.DangerLevel<>13

	--WRITE LOG
	DECLARE @LogAdd		VARCHAR(MAX), 
			@LogRemove	VARCHAR(MAX)

	SELECT @LogAdd = CAST((
		SELECT	custid		AS '@CustID',
				CategoryID	AS '@CategoryID',
				CreateDate	AS '@CreateDate'
		FROM #tblCustCategoryOld t
		WHERE Action='1'
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	

	SELECT @LogRemove = CAST((
		SELECT	custid		AS '@CustID',
				CategoryID	AS '@CategoryID',
				RemoveDate	AS '@RemoveDate'
		FROM #tblCustCategoryOld t
		WHERE Action='-1'
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))
	
	SELECT @Duration = DATEDIFF (MILLISECOND, @StartRun, GETDATE())
	
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
	
	DROP TABLE #tblCustCategoryOld
	DROP TABLE #tblCustUpd
END
GO