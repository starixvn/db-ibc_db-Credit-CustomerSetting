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
	Parameter's Explanation: 
		@custList = '<Root>
					<r id="100" c="10" t="1" />
					<r id="101" c="11" t="2" />
					<r id="102" c="12" t="3" />
					</Root>'
*/
BEGIN
	SET NOCOUNT ON 
	
	BEGIN TRY	
		EXEC Acc_CustomerInfo_Execrep_03 @CustList = @CustList,
										@mode = 'CustomerClass'	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 100,
			@ErrMsg = 'Update unsuccessfully'
		
		RETURN;
	END CATCH 
	
	--import categroy for deposit customers
	CREATE TABLE #tblDep_CustClass (custid INT, CustomerClass SMALLINT, CategoryID SMALLINT, isFinished BIT DEFAULT(0))
	DECLARE @tmp TABLE (custid INT, CustomerClass SMALLINT, CategoryID SMALLINT)
	
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
	
		
	WHILE (1=1)
	BEGIN
		DELETE @tmp
		
		UPDATE TOP (200) t
		SET isFinished = 1
		OUTPUT DELETED.custid, DELETED.CustomerClass, DELETED.CategoryID
		INTO @tmp(custid,CustomerClass,CategoryID)
		FROM #tblDep_CustClass t
		WHERE isFinished = 0			
		
		IF @@ROWCOUNT = 0
			BREAK;
			
		INSERT INTO [Dep_CustCategoryHistory](custid,CategoryID,CustomerClass,CreatedDate)
		SELECT custid, CategoryID, CustomerClass, GETDATE()
		FROM @tmp
		WHERE CustomerClass BETWEEN 8 AND 13
			AND CategoryID > 0
		
		WAITFOR DELAY '0:0:1'
		
	END
	
	DROP TABLE #tblDep_CustClass
END	