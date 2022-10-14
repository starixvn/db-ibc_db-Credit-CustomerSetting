/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdateCustomerClass]  
	@custList	VARCHAR(MAX) = '',	
	@ErrCode 	INT = 0 OUTPUT,	
	@ErrMsg		VARCHAR(500) = '' OUTPUT
AS  
/*  

	Created: 20200901@Johnson   
	Task: Service update CustomerClass for custinfo
	DB: DBCUST/CustDB  

	Revisions:  		
		- 20200901@Johnson: Initial sp [redmine:#140809]
		- 20210420@Johnson: sync category for PA [redmine:#153617]
		- 20210607@Johnson: sync category PA for LAP [redmine:#155692]
		- 20220228@Johnson: add new category for good/bad robot[redmine:#167726]
		- 20220329@Johnson: Add new category/class for PA Probation [redmine:#170468]
		- 20220405@Johnson: Add OldCustomerClass column [redmine:#170182]
		- 20220630@Johnson: write log for LAP [redmine:#174357]
	Parameter's Explanation: 
		@custList = '<Root>
					<r id="100" c="10" t="1" />
					<r id="101" c="11" t="2" />
					<r id="102" c="12" t="3" />
					</Root>'
					
		id: custid
		c: customerClass
		t: category
		u: userid
*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @CategoryList VARCHAR(MAX),
			@startRun DATETIME, 
			@duration INT
	
	SELECT @startRun = GETDATE()

	SELECT @CategoryList = CAST((
						SELECT DISTINCT CustomerClass c 
						FROM CategoryConfig WITH(NOLOCK)
						WHERE CustomerClass IS NOT NULL
						FOR XML PATH('') , ROOT('Root')
						) AS VARCHAR(MAX))

	--import categroy for deposit customers
	CREATE TABLE #tblDep_CustClass (custid INT, CustomerClass SMALLINT, CategoryID SMALLINT, OldCustomerClass SMALLINT, isFinished BIT DEFAULT(0))
	DECLARE @tmp TABLE (custid INT, CustomerClass SMALLINT, CategoryID SMALLINT, OldCustomerClass SMALLINT)
	
	DECLARE @xml XML = CAST (@CustList as XML),
			@cnt INT
	
	INSERT INTO #tblDep_CustClass (custid, CustomerClass, CategoryID)
	SELECT t.c.value('@id[1]','int'),
		t.c.value('@c[1]','int'),
		t.c.value('@t[1]','int')
	FROM @xml.nodes('Root/r')as t(c)
		
	DELETE t
	FROM #tblDep_CustClass t
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
	WHERE ci.srecommend NOT IN (SELECT custid FROM Dep_Custsuper s WITH(NOLOCK))
	
	UPDATE t
	SET t.OldCustomerClass = ci.CustomerClass
	FROM #tblDep_CustClass t
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
		
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustList,
										@mode = 'CustomerClass',
										@CategoryList = @CategoryList	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsg = 'Update unsuccessfully'
		
		RETURN;
	END CATCH 
	
	WHILE (1=1)
	BEGIN
		DELETE @tmp
		
		UPDATE TOP (200) t
		SET isFinished = 1
		OUTPUT DELETED.custid, DELETED.CustomerClass, DELETED.CategoryID, DELETED.OldCustomerClass
		INTO @tmp(custid,CustomerClass,CategoryID,OldCustomerClass)
		FROM #tblDep_CustClass t
		WHERE isFinished = 0			
		
		IF @@ROWCOUNT = 0
			BREAK;
			
		INSERT INTO [Dep_CustCategoryHistory](custid,CategoryID,CustomerClass,CreatedDate,OldCustomerClass)
		SELECT custid, CategoryID, CustomerClass, GETDATE(), OldCustomerClass
		FROM @tmp
		WHERE CustomerClass IN (SELECT DISTINCT CustomerClass c 
								FROM CategoryConfig WITH(NOLOCK)
								WHERE CustomerClass IS NOT NULL)
			AND CategoryID > 0
		
		WAITFOR DELAY '0:0:1'
		
	END
	
	IF EXISTS (SELECT 1 FROM #tblDep_CustClass)
	BEGIN
		DECLARE @LogData NVARCHAR(MAX),
			@ActionID INT = 5566
		
		SELECT @LogData = 
		CAST((SELECT custid '@id', CustomerClass '@c', OldCustomerClass '@o'
			FROM #tblDep_CustClass
			FOR XML PATH('r'), ROOT('Root')) AS VARCHAR(MAX)
			)
		
		SELECT @Duration = DATEDIFF (MILLISECOND, @startRun, GETDATE())
			
		EXEC DBLOG.bodb_CustomerLog.[dbo].[WriteLog_UserLog_UserControl_Multiple] 
			@LogData = @LogData, 			
			@TypeID = 2, 
			@actionid = @ActionID, 
			@duration = @Duration
	END 
	
	DROP TABLE #tblDep_CustClass
END	