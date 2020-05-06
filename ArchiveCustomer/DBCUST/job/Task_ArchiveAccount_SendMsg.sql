/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_SendMsg]
	@stage tinyint = NULL
AS
/*
	Task: Archive unused credit account - Send message to masters for stage 1,2
	Created: Daniel@20190519
	Database: DBCUST.CustDB

	Revisions:
	- 20190519@Daniel: Created

	Param:
		+ @stage: input stage 1 or 2 to send message
*/
BEGIN

	SET NOCOUNT ON
	
	DECLARE @status varchar(200)

	CREATE TABLE #tmpMaster(MasterID INT, Username VARCHAR(30))

	INSERT #tmpMaster
	SELECT DISTINCT NULL MasterID, master Username FROM tmpCustArchived WHERE ErrMsg = ''

	UPDATE b SET b.MasterID = c.custid
	FROM #tmpMaster b INNER JOIN dbo.custinfo c with (nolock) on b.username = c.username
	WHERE c.roleid = 3

	DECLARE @MasterList VARCHAR(MAX)

	-- assign elements into XML format
	SET @MasterList = (
		SELECT 	
			MasterID	AS '@MasterID'
			,Username AS '@UserName'
		FROM #tmpMaster
		FOR XML PATH ('Master'),root ('ROOT')
		)
	
	if (@stage is null)
	begin
		select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'
		select @stage = case @status when 'Stage 1 - Running' then 1 when 'Stage 2 - Running' then 2 else 0 end
	end
	
	if (@stage in(1, 2, 11)) EXEC DBMSG.bodb_message.dbo.DBA_Archive_PrivateMessageForMasterAcc @MasterList = @MasterList, @stage = @stage
END