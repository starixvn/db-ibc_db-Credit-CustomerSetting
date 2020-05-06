/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_DisabledAgents_NoBal_Delete]
AS
/*
	Task: Archive unused credit account for disabled agents with zero balances - Delete data in main DB (after backup)
	Created: Daniel@20191206
	Database: DBCUST.CustDB

	Revisions:
		- 20191206@Daniel: Created

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @CustIDs VARCHAR(MAX)
	DECLARE @batchCustIDs TABLE(custid INT)

	UPDATE [tmpCustArchived_DisabledAgents_NoBal] set isfinished = 0

	WHILE(1=1)
	BEGIN
		SELECT @CustIDs = ''

		UPDATE TOP(3000) t
		SET IsFinished = 1
		OUTPUT INSERTED.recommend INTO @batchCustIDs
		FROM tmpCustArchived_DisabledAgents_NoBal t
		WHERE IsFinished = 0

		IF (@@ROWCOUNT = 0) BREAK

		SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
		FROM @batchCustIDs		
	
		EXEC Acc_ExecRep_Cust_01 @CustIDs = @CustIDs

		EXEC DBLOG.bodb_CustomerLog.dbo.[WriteLog_UserLog_RunSP_MultiCust] 
			  @UserID = 360418
			, @CustIDList = @CustIDs
			, @NewPT_XML = ''
			, @OldPT_XML = ''
			, @SPName = 'Task_ArchiveAccount_DisabledAgents_NoBal_Delete'
			, @Doing = 'Archive disabled Agents have zero balances'
			, @ActionID = 1500
	
		DELETE @batchCustIDs
			
		WAITFOR DELAY '00:00:00.100'
		--IF (@ErrMsg <> '') BREAK
	END
END