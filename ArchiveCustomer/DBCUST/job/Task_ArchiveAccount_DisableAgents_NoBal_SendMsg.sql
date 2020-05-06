/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_DisableAgents_NoBal_SendMsg]
AS
/*
	Task: Archive unused credit account - Delete disabled agents with no balance - Send message to upline masters
	Created: Daniel@20191216
	Database: DBCUST.CustDB

	Revisions:
	- 20191216@Daniel: Created


*/
BEGIN

	SET NOCOUNT ON
	
	CREATE TABLE #tmpMaster(MasterID INT, Username VARCHAR(30))

	INSERT #tmpMaster
	SELECT DISTINCT NULL MasterID, master Username FROM tmpCustArchived_DisabledAgents_NoBal

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
	
	EXEC DBMSG.bodb_message.dbo.DBA_Archive_PrivateMessageForMasterAcc @MasterList = @MasterList, @stage = 11
END