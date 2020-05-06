/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_UpdStatus]
AS
/*
	Task: Archive unused credit account - step update status
	Created: Daniel@20190519
	Database: DBCUST.CustDB

	Revisions:
	- 20190519@Daniel: Created

	Param:
		+ @stage: input stage to run archive
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @status varchar(200), @LastRunDate VARCHAR(200)

	select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'

	if (@status like '%Running')
		select @status = REPLACE(@status, 'Running', 'Done')
	else if (@status = 'Stage 1 - Done')
		select @status = 'Stage 2 - Running'
	else if (@status = 'Stage 2 - Done')
		select @status = 'Stage 3 - Running'
	else if (@status = 'Stage 3 - Done')
		select @status = 'Stage 4 - Running'
	else if (@status = 'Stage 4 - Done')
		select @status = 'Stage 1 - Running'

	EXEC DBACC.bodb02.dbo.Task_UpdSystemSetting @VValue = @status, @VName = 'aa_Status'

	if (@status like '%Done')
	begin
		select @LastRunDate = CONVERT(varchar(10), getdate(),120)	
		EXEC DBACC.bodb02.dbo.Task_UpdSystemSetting @VValue = @LastRunDate, @VName = 'aa_LastRunDate'
	end
END