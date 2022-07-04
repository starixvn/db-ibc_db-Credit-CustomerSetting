/*<info serverAlias="DBLog-bodb_CustomerLog" executers="bodbAdminNet" viewers="" selecters=""></info>*/

ALTER PROCEDURE [dbo].[WriteLog_UserLog_UserControl_Multiple]
	@LogData NVARCHAR(MAX),	
	@TypeID tinyint=0,
	@ActionID int=NULL,
	@Duration int = NULL
AS
/*
	Created: 20220701@Johnson
	Task : Write Log when update customerclass for deposit customers	
	DB: DBLog/bodb_CustomerLog

	Revisions :
		- 20220701@Johnson: initial sp [redmine:#174357]
	
	Parameter Explanation:
		@LogData = '<Root>
						<r id="1" c="1" o="8" />
						<r id="2" c="3" o="10" />
					</Root>'
		id: custid, c: customerclass, o: OldCustomerClass			
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblLog (custid INT PRIMARY KEY, CustomerClass SMALLINT, OldCustomerClass SMALLINT)
	DECLARE @xmlData XML = CAST(@LogData as XML)
	
	INSERT INTO #tblLog(custid,CustomerClass,OldCustomerClass)	
	SELECT t.c.value('@id','INT')	AS custid		
		,t.c.value('@c', 'SMALLINT')	AS CustomerClass
		,t.c.value('@o', 'SMALLINT')	AS OldCustomerClass		
	FROM @XmlData.nodes ('Root/r') t(c)
	OPTION (OPTIMIZE FOR (@XmlData = NULL))
	
	DECLARE @LogActionDetailId INT = 38,
		@UserID INT = 10278938 --starixIT
	
	INSERT INTO  dbo.UserLog_UserControl
           ([CustID]
           ,[LogDate]
           ,[UserID]
           ,[TypeID]
		   ,[ActionID]
           ,[Duration]
           ,[Doing])
	SELECT custid, 
		GETDATE(),
		@UserID,
		@TypeID,
		@ActionID,
		@Duration,
		CAST(@LogActionDetailId AS VARCHAR(10)) + ' - ' + ISNULL(CAST(CustomerClass as VARCHAR(10)),'') + ' - ' + ISNULL(CAST(OldCustomerClass as VARCHAR(10)),'') as Doing 
    FROM #tblLog
	
	DROP TABLE #tblLog
END			
GO