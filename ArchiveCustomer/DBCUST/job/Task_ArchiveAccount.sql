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
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		
	Param:
		+ @stage: input stage to run archive
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @status varchar(200), @GroupLevelName VARCHAR(10) = '' 
	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100), @roleid_tmp INT, @S1M1_username NVARCHAR(100)
	CREATE TABLE #ReduceCredit (CustId INT,RoleID TINYINT,GroupLevelName VARCHAR(10), srecommend INT,Credit MONEY, ReduceCredit MONEY DEFAULT(0), IsFinished BIT DEFAULT(0))
	CREATE TABLE #ArchiveMasterSuper_tmp (CustID INT, RoleID TINYINT, GroupLevelName VARCHAR(10),username NVARCHAR(100), IsFinished BIT DEFAULT(0))
		
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
		--Step 1.1: Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		--Step 1.2. Loop through list to execute sp for each agent
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
			
		END
		
		--Step 1.3 Gen List Super Master into tmpCustGroupLevelArchived before closing if there is any agent reactive after step 1.2 
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		--Step 1.4 Close S1, M1
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
		WHERE ar.GroupLevelName IN ('S1','M1','M0')
		ORDER BY ar.Roleid
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @roleid_tmp = roleid
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				IF @roleid_tmp = 3
				BEGIN
					EXEC dbo.DBA_ArchiveAccount1_CloseMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT
				END
				ELSE IF @roleid_tmp = 4
				BEGIN
					EXEC dbo.DBA_ArchiveAccount1_CloseSuper @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT
				END
				
				SET @msg = 'Stage 1 - Done Close M0,M1,S1: ' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		--Step 1.5 Re-Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
	END
	ELSE IF(@stage = 2)
	BEGIN
		
		DECLARE @srecommend INT
			, @mrecommend INT
			, @ReduceCredit MONEY = 0
			, @OldCredit MONEY = 0
			, @LogData VARCHAR(500)
			, @custid INT
			, @NewCredit MONEY = 0
			, @username NVARCHAR(MAX)
			, @recommend INT

		INSERT INTO #ReduceCredit (CustId,srecommend,RoleID,Credit)
		SELECT DISTINCT c.custid, c.srecommend, 3,credit
		FROM dbo.tmpCustArchived t WITH (NOLOCK)
			INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.username= t.Master
		WHERE t.IsFinished = 0
			AND c.roleid = 3
		UNION ALL
		SELECT DISTINCT c.custid, c.custid, 4,credit
		FROM dbo.tmpCustArchived t WITH (NOLOCK)
			INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.username= t.Super
		WHERE t.IsFinished = 0
			AND c.roleid = 4
		
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent, @recommend = recommend FROM tmpCustArchived WITH (NOLOCK) WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount2_DisableAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT, @srecommend = @srecommend OUTPUT, @mrecommend = @mrecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT
	
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent
			
			IF @ErrMsg = ''
			BEGIN
				UPDATE #ReduceCredit
					SET ReduceCredit = ReduceCredit + @ReduceCredit
				WHERE CustId IN (@srecommend, @mrecommend)

				--Writelog clear given credit for Agent
				SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@agent, SPACE(1))  

				BEGIN TRY
					EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
						@UserID = 360418,
						@CustID = @recommend,
						@Doing = @LogData,
						@OldValue = @ReduceCredit,
						@NewValue = 0,
						@IP = '100.100.100.100',
						@ActionID = 1222
				END TRY
				BEGIN CATCH
					SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

					EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
						@UserID = 360418,
						@CustID = @recommend,
						@Doing = @LogData,
						@OldValue = @ReduceCredit,
						@NewValue = 0,
						@IP = '100.100.100.100',
						@ActionID = 1222
				END CATCH
			END
	
			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.120'
			--IF (@ErrMsg <> '') BREAK
		END

		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		-- Disable M0, M1, S1
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
		WHERE ar.GroupLevelName IN ('S1','M1','M0')
		ORDER BY ar.Roleid
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @roleid_tmp = roleid
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				IF @roleid_tmp = 3
				BEGIN
					EXEC dbo.DBA_ArchiveAccount2_DisableMaster @AccName = @S1M1_username,@srecommend = @srecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT, @ErrMsg = @ErrMsg OUTPUT
					
					IF @ErrMsg = ''
					BEGIN
						UPDATE #ReduceCredit
							SET ReduceCredit = ReduceCredit + @ReduceCredit
						WHERE CustId = @srecommend
					END
					
				END
				ELSE IF @roleid_tmp = 4
				BEGIN
					EXEC dbo.DBA_ArchiveAccount2_DisableSuper @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT
				END
				
				SET @msg = 'Stage 1 - Done Disable M0, M1,S1: ' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
		END
		--Reduce SMA Credit
		UPDATE R
			SET GroupLevelName = a.GroupLevelName
		FROM #ReduceCredit r
			INNER JOIN tmpCustGroupLevelArchived a WITH (NOLOCK) ON r.CustId = a.custid	
			
		IF EXISTS (SELECT TOP(1) 1 FROM #ReduceCredit WHERE ReduceCredit <> 0)
		BEGIN
			
			WHILE(1=1)
			BEGIN
				UPDATE TOP (1) t
				SET t.IsFinished = 1
					, @custid = t.CustId
					, @ReduceCredit = t.ReduceCredit
					, @GroupLevelName = t.GroupLevelName
				FROM #ReduceCredit t
				WHERE IsFinished = 0
					AND ReduceCredit <> 0
		
				IF @@ROWCOUNT = 0 
					BREAK
				
				SELECT	@username = username,
						@OldCredit = Credit
				FROM	dbo.custInfo WITH (NOLOCK)
				WHERE	custid = @custid

				SET @NewCredit = CASE WHEN @GroupLevelName IN ('M0','M1','S1') THEN 0 ELSE @OldCredit - @ReduceCredit END
				
				UPDATE c
					SET c.credit = @NewCredit
				FROM dbo.custInfo c WITH (ROWLOCK, UPDLOCK)
				WHERE c.custid = @custid	

				--Writelog
				SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@username, SPACE(1))  

				BEGIN TRY
					EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
						@UserID = 360418,
						@CustID = @CustID,
						@Doing = @LogData,
						@OldValue = @OldCredit,
						@NewValue = @NewCredit,
						@IP = '100.100.100.100',
						@ActionID = 1222
				END TRY
				BEGIN CATCH
					SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

					EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
						@UserID = 360418,
						@CustID = @CustID,
						@Doing = @LogData,
						@OldValue = @OldCredit,
						@NewValue = @NewCredit,
						@IP = '100.100.100.100',
						@ActionID = 1222
				END CATCH
			END
		END
	END
	ELSE IF(@stage = 3)
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
			
		END
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		-- Delete M1
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
		WHERE ar.GroupLevelName IN ('M1','M0')
		ORDER BY ar.Roleid
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @roleid_tmp = roleid
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC dbo.DBA_ArchiveAccount3_DelCustSettingMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT
				
				SET @msg = 'Stage 1 - Done Delete Setting M0,M1 ' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
	END
	ELSE IF(@stage = 4)
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
		
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		-- Delete M1
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
		WHERE ar.GroupLevelName IN ('M1','M0')
		ORDER BY ar.Roleid
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @roleid_tmp = roleid
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC dbo.DBA_ArchiveAccount4_DelCustInfoMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT
				
				SET @msg = 'Stage 1 - Done Delete Setting M0,M1 ' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
	END

	DROP TABLE #ReduceCredit
	DROP TABLE #ArchiveMasterSuper_tmp
END	
