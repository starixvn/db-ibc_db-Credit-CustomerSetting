/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_DisabledAgents_NoBal]
AS
/*
	Task: Archive unused credit account for disabled agents with zero balances
	Created: Daniel@20191206
	Database: DBCUST.CustDB

	Revisions:
		- 20191206@Daniel: Created

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @CustIDs VARCHAR(MAX)
	DECLARE @batchCustIDs TABLE(custid INT)
	DECLARE @status varchar(200)
	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100)

	--if (@stage is null)
	--begin
	--	select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'
	--	select @stage = case @status 
	--		when 'Stage 1 - Running' then 1
	--		when 'Stage 2 - Running' then 2
	--		when 'Stage 3 - Running' then 3
	--		when 'Stage 4 - Running' then 4
	--		else 0 end
	--end

	WHILE(1=1)
	BEGIN
		SELECT @CustIDs = ''

		UPDATE TOP(3000) t
		SET IsFinished = 1
		OUTPUT INSERTED.recommend INTO @batchCustIDs
		FROM tmpCustArchived_DisabledAgents_NoBal t
		WHERE IsFinished = 0

		IF (@@ROWCOUNT < 3000) BREAK

		SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
		FROM @batchCustIDs		
	
		EXEC Acc_ExecRep_Cust_01 @CustIDs = @CustIDs
	
		DELETE @batchCustIDs
			
		WAITFOR DELAY '00:00:00.120'
		--IF (@ErrMsg <> '') BREAK
	END

	


	--------------------
	--declare @LogSPData varchar(2000)

	--Select @LogSPData = '<DBA_ArchiveAccount3_DelCustSetting AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
	--					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	--					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
	--					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'



	--EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	--	@UserID = @UserID,
	--	@CustID = @AgentID,
	--	@ActionID = 1500,
	--	@TrackingValue = @LogSPData	,
	--	@duration = @duration



END