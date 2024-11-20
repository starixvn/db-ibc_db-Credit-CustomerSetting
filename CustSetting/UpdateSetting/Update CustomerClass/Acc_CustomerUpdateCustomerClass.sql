/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdateCustomerClass]  
	@custList	VARCHAR(MAX) = '',		
	@Mode	 	INT = 1 ,	
	@ErrCode 	INT = 0 OUTPUT,	
	@ErrMsg		VARCHAR(MAX) = '' OUTPUT
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
		- 20221128@Johnson: dont write log when cc not change [redmine:#180957]
		- 20230803@Winfred: LAP - Player Segmentation - Add Risk Level's last update time [redmine:#191101]
		- 20240522@Johnson: CC Log - Change value from negative number to empty [redmine:#205427]
		- 20240716@Johnson: Apply In-house Replication for Customer Setting [redmine:#207025]
		- 20241008@Winfred: [CTS] - Customer Classification - Classify Agent [redmine:#185799]
	Parameter's Explanation: 
		@Mode = 2 : SMA , 1 : Member
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
			@duration INT, 
			@ModifiedDate DATETIME

	SELECT @startRun = GETDATE() , @ModifiedDate = GETDATE()

	SELECT @CategoryList = CAST((
						SELECT DISTINCT CustomerClass c 
						FROM CategoryConfig WITH(NOLOCK)
						WHERE CustomerClass IS NOT NULL
						FOR XML PATH('') , ROOT('Root')
						) AS VARCHAR(MAX))

	--import categroy for deposit customers
	CREATE TABLE #tblDep_CustClass (custid INT, CustomerClass INT, CategoryID INT, OldCustomerClass INT, isFinished BIT DEFAULT(0))
	DECLARE @tmp TABLE (custid INT, CustomerClass INT, CategoryID INT, OldCustomerClass INT)
	DECLARE @tmpExists TABLE (custid INT)
	
	DECLARE @xml XML = CAST (@CustList as XML),
			@cnt INT

	INSERT INTO #tblDep_CustClass (custid, CustomerClass, CategoryID)
	SELECT t.c.value('@id[1]','int'),
		t.c.value('@c[1]','int'),
		t.c.value('@t[1]','int')
	FROM @xml.nodes('Root/r')as t(c)
		
	IF @Mode = 2
	BEGIN
		CREATE TABLE #tblCustClass (custid INT, CustomerClass INT, CategoryID INT, CustomerClassOld INT, CategoryIDOld INT, isFinished BIT DEFAULT(0))
		DECLARE @tmpAgent TABLE (custid INT, CustomerClass INT, CategoryID INT, CustomerClassOld INT, CategoryIDOld INT)
		
		INSERT INTO #tblCustClass(custid, CustomerClass, CategoryID, CustomerClassOld, CategoryIDOld)
		SELECT custid, NULLIF(a.customerclass,-1), a.CategoryID , kq.CustomerClass AS CustomerClassOld, kq.CategoryID AS CategoryIDOld
		FROM #tblDep_CustClass a
			OUTER APPLY (SELECT TOP 1 CustomerClass, CategoryID FROM CustomerClassSetting_Agent WITH(NOLOCK) WHERE a.custID = CustID AND SportType = 0) kq
		WHERE EXISTS (SELECT TOP 1 1 FROM custInfo b WITH(NOLOCK) WHERE a.custid  = b.custid AND roleid > 1) ;
		 
		WHILE (1=1)
		BEGIN
			UPDATE TOP (2000) t
			SET isFinished = 1
			OUTPUT DELETED.custid, DELETED.CustomerClass, DELETED.CategoryID, DELETED.CustomerClassOld, DELETED.CategoryIDOld
			INTO @tmpAgent(custid, CustomerClass, CategoryID, CustomerClassOld, CategoryIDOld)
			FROM #tblCustClass t
			WHERE isFinished = 0
			
			SELECT @cnt = @@ROWCOUNT
			
			MERGE CustomerClassSetting_Agent as Target
			USING @tmpAgent as Source ON Target.custid = Source.custid AND Target.SportType = 0
			WHEN MATCHED 
			THEN UPDATE SET ModifiedDate = GETDATE(), RepUpdateTime = [dbo].[f_GetDateTime2](), CategoryID = Source.CategoryID, CustomerClass = Source.CustomerClass
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (custid, SportType, CategoryID,CustomerClass,ModifiedDate,RepUpdateTime)
			VALUES(custid,0, CategoryID,CustomerClass,GETDATE(),[dbo].[f_GetDateTime2]());	
						
			IF EXISTS ( SELECT 1 FROM sys.tables WHERE Name='CustCategoryHistory')
			BEGIN
				INSERT INTO CustCategoryHistory(custid,CategoryID,CustomerClass,OldCustomerClass, OldCategoryID , CreatedDate)
				SELECT custid,a.CategoryID,a.CustomerClass,CustomerClassOld,CategoryIDOld, GETDATE()
				FROM @tmpAgent a
				WHERE (CustomerClass IN (SELECT DISTINCT CustomerClass FROM CategoryConfig WITH(NOLOCK) WHERE CustomerClass IS NOT NULL))
					AND CategoryID > 0
			END

			IF @cnt < 2000
				BREAK;
				
			DELETE @tmpAgent
		END
		DROP TABLE #tblCustClass
	END

	DELETE t
	OUTPUT DELETED.custid
	INTO @tmpExists(custid)
	FROM #tblDep_CustClass t
	WHERE NOT EXISTS (SELECT TOP 1 1 from custinfo WITH(NOLOCK) where CustID = t.CustID)

	IF EXISTS (SELECT TOP 1 1 FROM @tmpExists)
	BEGIN
		SELECT @ErrCode = 200,
			@ErrMsg = STRING_AGG(CustID,',') WITHIN GROUP (ORDER BY CustID)
		FROM @tmpExists
	END

	DELETE t
	FROM #tblDep_CustClass t
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
	WHERE ci.srecommend NOT IN (SELECT custid FROM Dep_Custsuper s WITH(NOLOCK))
	
	UPDATE t
	SET t.OldCustomerClass = ci.CustomerClass
	FROM #tblDep_CustClass t
		INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
	
	DELETE FROM #tblDep_CustClass 
	WHERE OldCustomerClass = CustomerClass

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
			
		INSERT INTO [Dep_CustCategoryHistory](custid,CategoryID,CustomerClass,CreatedDate,OldCustomerClass,RepUpdateTime)
		SELECT custid, CategoryID, CustomerClass, @ModifiedDate, OldCustomerClass, dbo.f_GetDateTime2()
		FROM @tmp
		WHERE CustomerClass IN (SELECT DISTINCT CustomerClass c 
								FROM CategoryConfig WITH(NOLOCK)
								WHERE CustomerClass IS NOT NULL)
			AND CategoryID > 0
		
		UPDATE c 
		SET c.ModifiedDate = @ModifiedDate,
			c.CategoryID = t.CategoryID,
			c.CustomerClass = t.CustomerClass,
			c.OldCustomerClass = t.OldCustomerClass,
			c.RepUpdateTime = dbo.f_GetDateTime2()
		FROM Dep_CustomerClass c WITH(UPDLOCK)
			INNER JOIN @tmp t ON c.CustID = t.custid

		INSERT INTO [Dep_CustomerClass](custid,CategoryID,CustomerClass,ModifiedDate,OldCustomerClass,RepUpdateTime)
		SELECT custid, CategoryID, CustomerClass, @ModifiedDate, OldCustomerClass, dbo.f_GetDateTime2()
		FROM @tmp c
		WHERE NOT EXISTS (SELECT TOP 1 1 from Dep_CustomerClass WITH(NOLOCK) where CustID = c.CustID)
		
		WAITFOR DELAY '0:0:1'
		
	END
	
	IF EXISTS (SELECT 1 FROM #tblDep_CustClass)
	BEGIN
		DECLARE @LogData NVARCHAR(MAX),
			@ActionID INT = 5566
		
		SELECT @LogData = 
		CAST((SELECT custid '@id', NULLIF(CustomerClass,-1) '@c', NULLIF(OldCustomerClass,-1) '@o'
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