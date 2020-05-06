/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount]
	@stage tinyint = NULL
AS
/*
	Task: Archive unused credit account - Main step
	Created: Daniel@20190519
	Database: DBCUST.CustDB

	Revisions:
		- 20190519@Daniel: Created
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
	Param:
		+ @stage: input stage to run archive
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @status varchar(200)
	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100)

	if (@stage is null)
	begin
		select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'
		select @stage = case @status 
			when 'Stage 1 - Running' then 1
			when 'Stage 2 - Running' then 2
			when 'Stage 3 - Running' then 3
			when 'Stage 4 - Running' then 4
			else 0 end
	end

	if(@stage = 1)
	BEGIN
		--2. Loop through list to execute sp for each agent
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount1_CloseAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT
	
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent
	
			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.120'
			--IF (@ErrMsg <> '') BREAK
		END
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
	END
	else if(@stage = 2)
	BEGIN
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount2_DisableAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT
	
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent
	
			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.120'
			--IF (@ErrMsg <> '') BREAK
		END
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
	END
	else if(@stage = 3)
	BEGIN
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount3_DelCustSetting @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT

			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent

			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.280'
			--IF (@ErrMsg <> '') BREAK
		END
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
	END
	else if(@stage = 4)
	BEGIN
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount4_DelCustInfo @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT
	
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent
	
			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.180'
			--IF (@ErrMsg <> '') BREAK
		END
	END
END