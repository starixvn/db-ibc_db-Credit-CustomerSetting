/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
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
		- 20200907@Helen: Fix bug on sending message [Redmine: #130032]
		- 20200929@Helen: Phase 1 - Stage 3 - No Sending message [Redmine: #130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]

	Param:
		+ @stage: input stage 1 or 2, 3 to send message
*/
BEGIN

	SET NOCOUNT ON
	
	DECLARE @status varchar(200)
	DECLARE @SMList VARCHAR(MAX)
	
	CREATE TABLE #tmpMasterSuper(CustId INT, Username VARCHAR(30), GroupLevelName VARCHAR(10), RoleId INT) --Include Super

	IF (@stage IS NULL)
	BEGIN
		SELECT @status = VValue from bodb02.dbo.SystemSettings WITH(NOLOCK) WHERE VName = 'aa_Status'
		SELECT @stage = CASE @status 
							WHEN 'Stage 1 - Running' then 1 
							WHEN 'Stage 2 - Running' then 2 
							WHEN 'Stage 3 - Running' then 3 
							ELSE 0 
						END
	END
	
	IF @stage IN (1,2,3)
	BEGIN
		INSERT #tmpMasterSuper (CustId, Username, GroupLevelName, RoleId)
		SELECT t.custid, c.username, t.GroupLevelName, t.RoleId
		FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
			INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.custid = t.custid
		WHERE StageID = @stage
			AND 1 =  CASE WHEN StageID = 1 AND GroupLevelName IN ('M2','S2','S3') THEN 1
					WHEN StageID = 2 AND GroupLevelName IN ('M2','S2','S3') THEN 1
					WHEN StageID = 3 AND GroupLevelName IN ('M2','S2') THEN 1
				ELSE 0 END

		SET @SMList = (
			SELECT 	
				CustId	AS '@CustId'
				,Username AS '@UserName'
				,GroupLevelName  AS '@GroupLevelName'
			FROM #tmpMasterSuper
			FOR XML PATH ('SM'),root ('ROOT')
			)
		
		EXEC bodb_message.dbo.DBA_Archive_PrivateMessageForSuperMaster @SMList = @SMList, @stage = @stage
	END
	
	DROP TABLE #tmpMasterSuper
	
END