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
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]

	Param:
		+ @stage: input stage 1 or 2, 3 to send message
*/
BEGIN

	SET NOCOUNT ON
	
	DECLARE @status varchar(200)

	CREATE TABLE #tmpMasterSuper(CustId INT, Username VARCHAR(30), GroupLevelName VARCHAR(10), RoleId INT) --Include Super

	INSERT #tmpMasterSuper (CustId, Username, GroupLevelName, RoleId)
	SELECT t.custid, c.username, t.GroupLevelName, t.RoleId
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.custid = t.custid
	WHERE StageID = @stage

	DECLARE @MasterList VARCHAR(MAX)
	DECLARE @SMList VARCHAR(MAX)

	-- assign elements into XML format
	SET @MasterList = (
		SELECT 	
			CustId	AS '@MasterID'
			,Username AS '@UserName'
		FROM #tmpMasterSuper
		WHERE RoleId = 3
		FOR XML PATH ('Master'),root ('ROOT')
		)

	SET @SMList = (
		SELECT 	
			CustId	AS '@CustId'
			,Username AS '@UserName'
			,GroupLevelName  AS '@GroupLevelName'
		FROM #tmpMasterSuper
		FOR XML PATH ('SM'),root ('ROOT')
		)
	
	if (@stage is null)
	begin
		select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'
		select @stage = case @status when 'Stage 1 - Running' then 1 when 'Stage 2 - Running' then 2 else 0 end
	end
	
	if (@stage in(11)) EXEC DBMSG.bodb_message.dbo.DBA_Archive_PrivateMessageForMasterAcc @MasterList = @MasterList, @stage = @stage
	if (@stage in(1,2,3)) EXEC DBMSG.bodb_message.dbo.DBA_Archive_PrivateMessageForSuperMaster @SMList = @SMList, @stage = @stage

END