/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/ 
CREATE PROCEDURE [Task_ArchiveAccount]
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
		- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20210128@Winfred: Archiving min credit accounts process for Master & Agent levels [RedmineID: #149262]
		- 20210302@Eden: Just process SMA(s) stage 2, 3, 4 when they processed stage 1  [RedmineID: #149262]
		- 20210316@Helen: ArchivedMasterAgent_Stage3 for stage 3, backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
		- 20210617@Eden: Enhance the archiving account process on Stage 4 [RedmineID: #157123]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210614@Eden: All sites - Dormant SMA Account List [RedmineID: #155969]
		- 20210810@Eden: Edit stage 1 to resume when archive Agent Process [RedmineID: #155969]		
	Param:
		+ @stage: input stage to run archive
*/
BEGIN

	SET NOCOUNT ON
	
	-- simulate run date based on test data version
	declare @currentDate smalldatetime 
	select @currentDate = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_TestDate'
	
	DECLARE @srecommend INT
			, @mrecommend INT
			, @ReduceCredit MONEY = 0
			, @OldCredit MONEY = 0
			, @LogData VARCHAR(500)
			, @custid INT
			, @NewCredit MONEY = 0
			, @RealDownlineCredit MONEY = 0
			, @username NVARCHAR(MAX)
			, @recommend INT
			, @ArchivedDate	DATE = @currentdate --keep time stamp for Cust_ArchiveAccount
			, @ProcessedDate DATETIME 
			, @ArchivedCustID INT
			, @IsOverwrite	BIT

	DECLARE @status varchar(200), @GroupLevelName VARCHAR(10) = '' 
	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100), @roleid_tmp INT, @S1M1_username NVARCHAR(100)
	CREATE TABLE #ReduceCredit (CustId INT,RoleID TINYINT,GroupLevelName VARCHAR(10), srecommend INT,Credit MONEY, ReduceCredit MONEY DEFAULT(0), IsFinished BIT DEFAULT(0))
	CREATE TABLE #ArchiveMasterSuper_tmp (CustID INT, RoleID TINYINT, GroupLevelName VARCHAR(10),username NVARCHAR(100), IsFinished BIT DEFAULT(0))
		
	if (@stage is null)
	begin
		select @status = VValue from bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status'
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
		DECLARE @TmpClosedAgent TABLE (recommend INT)

		UPDATE t
		SET  ErrMsg = t.Agent +':'+ 'This agent has been archived!!' 
			,IsFinished = 1
		OUTPUT deleted.recommend INTO @TmpClosedAgent (recommend)
		FROM tmpCustArchived t (ROWLOCK)
			INNER JOIN custinfo ci (NOLOCK) ON ci.custid = t.recommend
			INNER JOIN CustLoginInfo l WITH(NOLOCK) ON ci.custid = l.CustID
			INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = ci.CustID
		WHERE cps.CloseInfo > 0 
			AND l.ClosedReason = 4
			AND IsFinished = 0

		--> Insert data for Cust_ArchiveAccount
		WHILE(1=1)
		BEGIN
			SELECT @ProcessedDate = @currentdate

			SELECT TOP (1) @recommend = t.recommend 
			FROM @TmpClosedAgent t

			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
				@CustId = @recommend,
				@RoleID = 2,
				@StageID = @stage,
				@ProcessedDate = @ProcessedDate,
				@ArchivedDate = @ArchivedDate
	
			DELETE 
			FROM @TmpClosedAgent
			WHERE recommend = @recommend	
		END
			
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT @ProcessedDate = @currentdate

			SELECT TOP 1 @agent = Agent, @recommend = recommend 
			FROM tmpCustArchived 
			WHERE IsFinished = 0	

			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount1_CloseAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT, @ArchivedDate = @ArchivedDate, @ProcessedDate = @ProcessedDate
	
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
				SELECT @ProcessedDate = @currentdate
				
				UPDATE TOP (1) t
				SET  IsFinished = 1
					, @S1M1_username = username
					, @roleid_tmp = roleid
					, @GroupLevelName = GroupLevelName
					, @ArchivedCustID = CustID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				IF @roleid_tmp = 3
				BEGIN
					EXEC dbo.DBA_ArchiveAccount1_CloseMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT, @ArchivedDate = @ArchivedDate, @ProcessedDate = @ProcessedDate
					
				END
				ELSE IF @roleid_tmp = 4
				BEGIN
					EXEC dbo.DBA_ArchiveAccount1_CloseSuper @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT, @ArchivedDate = @ArchivedDate, @ProcessedDate = @ProcessedDate
				END
				
				SET @msg = 'Stage 1 - Done Close ' + @GroupLevelName + ':' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
	END
	ELSE IF(@stage = 2)
	BEGIN
							
		INSERT INTO #ReduceCredit (CustId,srecommend,RoleID,Credit)
		SELECT c.custid, c.srecommend, 3 ,credit
		FROM (SELECT DISTINCT Master FROM dbo.tmpCustArchived  WITH (NOLOCK)  WHERE IsFinished = 0) AS t
			CROSS APPLY (SELECT custid,srecommend,credit FROM dbo.custInfo c1 WITH (NOLOCK) WHERE c1.username= t.Master and c1.roleid = 3) AS c
		
		INSERT INTO #ReduceCredit (CustId,srecommend,RoleID,Credit)
		SELECT c.custid, c.custid, 4,credit
		FROM (SELECT DISTINCT super FROM dbo.tmpCustArchived  WITH (NOLOCK)  WHERE IsFinished = 0) AS t
			CROSS APPLY (SELECT custid,credit FROM dbo.custInfo c1 WITH (NOLOCK) WHERE c1.username= t.Super and c1.roleid = 4) AS c 
		
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''

			SELECT TOP (1) @agent = Agent, @recommend = recommend 
			FROM tmpCustArchived a WITH (NOLOCK) 
			WHERE IsFinished = 0

			IF (@@ROWCOUNT = 0) BREAK
		
			EXEC dbo.DBA_ArchiveAccount2_DisableAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT, @srecommend = @srecommend OUTPUT, @mrecommend = @mrecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT,@ArchivedDate = @ArchivedDate
			
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent

			IF @ErrMsg = ''
			BEGIN
				IF @ReduceCredit <>  0
				BEGIN
					UPDATE #ReduceCredit
						SET ReduceCredit = ReduceCredit + @ReduceCredit
					WHERE CustId IN (@srecommend, @mrecommend)

					--Writelog clear given credit for Agent
					SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@agent, SPACE(1))  

					BEGIN TRY
						EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
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
			END
	
			SET @msg = 'Stage 2 - Done Agent Level ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.120'
			--IF (@ErrMsg <> '') BREAK
		END

		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage

		
		
		-- Processing for M0, M1, S1
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
				SELECT @ProcessedDate = @currentdate
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @roleid_tmp = roleid
						, @GroupLevelName = GroupLevelName
						, @custid = custid
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC dbo.DBA_ArchiveAccount2_DisableMasterSuper @AccName = @S1M1_username,@srecommend = @srecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT, @ErrMsg = @ErrMsg OUTPUT,@ArchivedDate = @ArchivedDate
				
				PRINT 'DBA_ArchiveAccount2_DisableMasterSuper' + @ErrMsg
				
				IF @ErrMsg = ''
				BEGIN
					IF @ReduceCredit <> 0
					BEGIN
						IF @roleid_tmp = 3
						BEGIN
							UPDATE r
								SET ReduceCredit = r.ReduceCredit + @ReduceCredit - t.ReduceCredit
							FROM #ReduceCredit r
								CROSS APPLY (SELECT	ReduceCredit FROM #ReduceCredit WHERE CustId = @custid) AS t	
							WHERE CustId = @srecommend
						END
					END	
				END	
				
				SET @msg = 'Stage 2 - Done Disable ' + @GroupLevelName + ':'+ @S1M1_username +   CHAR(13) 
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
		END
		--Reduce SMA Credit, remove M0, M1, S1
		DELETE r
		FROM #ReduceCredit r
			INNER JOIN dbo.tmpCustGroupLevelArchived a WITH (NOLOCK) ON r.CustId = a.custid	
		WHERE a.GroupLevelName IN ('M0','M1','S1')	

		IF EXISTS (SELECT TOP(1) 1 FROM #ReduceCredit WHERE ReduceCredit <> 0)
		BEGIN
			
			WHILE(1=1)
			BEGIN
				UPDATE t
				SET t.IsFinished = 1
					, @custid = t.CustId
					, @ReduceCredit = t.ReduceCredit
					, @GroupLevelName = t.GroupLevelName
					, @roleid_tmp = t.RoleID
				FROM #ReduceCredit t
				WHERE T.CustId IN (SELECT TOP 1 CustId FROM #ReduceCredit  WHERE  IsFinished = 0
									AND ReduceCredit <> 0
									ORDER BY RoleID ASC )

		
				IF @@ROWCOUNT = 0 
					BREAK
				
				SELECT	@username = username,
						@OldCredit = Credit
				FROM	dbo.custInfo WITH (NOLOCK)
				WHERE	custid = @custid
				
				IF @roleid_tmp = 3 
				BEGIN
					SET @RealDownlineCredit = ISNULL((SELECT SUM(credit) FROM	dbo.custInfo WITH (NOLOCK) WHERE mrecommend = @custid AND roleid  = 2),0)
				END
				ELSE
				BEGIN
					SET @RealDownlineCredit = ISNULL((SELECT SUM(credit) FROM	dbo.custInfo WITH (NOLOCK) WHERE srecommend = @custid AND roleid  = 3),0)
				END
				SET @RealDownlineCredit = CASE WHEN 0 < @RealDownlineCredit THEN @RealDownlineCredit ELSE 0 END

				SET @NewCredit = CASE WHEN @OldCredit - @ReduceCredit < @RealDownlineCredit THEN @RealDownlineCredit
									  ELSE @OldCredit - @ReduceCredit END

				UPDATE c
					SET c.credit = @NewCredit
				FROM dbo.custInfo c WITH (ROWLOCK, UPDLOCK)
				WHERE c.custid = @custid	

				--Writelog
				SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@username, SPACE(1))  

				BEGIN TRY
					EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
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
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = ''
			SELECT @ProcessedDate = @currentdate

			SELECT TOP 1 @agent = Agent, @recommend = recommend
			FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount3_DelCustSetting @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT

			--> Insert data for Cust_ArchiveAccount
			IF ISNULL(@ErrMsg,'') = ''
				EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
					@CustId = @recommend,
					@RoleID = 2,
					@StageID = @stage,
					@ProcessedDate = @ProcessedDate,
					@ArchivedDate = @ArchivedDate

			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent

			SET @msg = 'Stage 3 - Done Agent Level: ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.280'
			
		END
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		-- Delete M1, M0
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
				SELECT @ProcessedDate = @currentdate
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @GroupLevelName = GroupLevelName
						, @ArchivedCustID = t.CustID
						, @roleid_tmp = t.RoleID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC dbo.DBA_ArchiveAccount3_DelCustSettingMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT

				--> Insert data for Cust_ArchiveAccount
				IF ISNULL(@ErrMsg,'') = '' AND @roleid_tmp = 3
					EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
						@CustId = @ArchivedCustID,
						@RoleID = 3,
						@StageID = @stage,
						@ProcessedDate = @ProcessedDate,
						@ArchivedDate = @ArchivedDate
				
				SET @msg = 'Stage 3 - Done Delete Setting for '+ @GroupLevelName + ':' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
		PRINT 'ArchivedMasterAgent_Stage3: Begin'
		-- insert data for table ArchivedMasterAgent_Stage3 - tw will refer to delete data for Casino DB
		TRUNCATE TABLE ArchivedMasterAgent_Stage3
		
		SELECT DISTINCT ar.custid 
		INTO #Masterlist_Stage3
		FROM tmpCustGroupLevelArchived ar WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount ca WITH (NOLOCK) ON ar.custid = ca.CustID AND ca.ArchivedDate = @ArchivedDate
		WHERE GroupLevelName IN ('M1','M0')
			
		SELECT DISTINCT ar.recommend AS CustID
		INTO #AgentList_Stage3
		FROM tmpCustArchived ar WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount ca WITH (NOLOCK) ON ar.recommend = ca.CustID AND ca.ArchivedDate = @ArchivedDate
		WHERE IsFinished = 1 AND ISNULL(ErrMsg,'') = ''

		INSERT INTO ArchivedMasterAgent_Stage3(CustID,username,Level)
		SELECT s.CustID,
			c.username,
			'Agent' AS [Level]
		FROM #AgentList_Stage3 s 
			INNER JOIN custInfo c WITH(NOLOCK) ON s.CustID = c.custid
		WHERE c.roleid = 2
			AND c.Enabled = 0
			AND NOT EXISTS( SELECT 1 FROM #Masterlist_Stage3 WHERE custid = c.mrecommend)
		UNION ALL 
		SELECT s.CustID,
			c.username,
			'Master' AS [Level]
		FROM #Masterlist_Stage3 s 
			INNER JOIN custInfo c WITH(NOLOCK) ON s.CustID = c.custid
		WHERE c.roleid = 3
			AND c.Enabled = 0
		
		DROP TABLE #AgentList_Stage3
		DROP TABLE #Masterlist_Stage3
		
		Print 'ArchivedMasterAgent_Stage3: END'

	END
	ELSE IF(@stage = 4)
	BEGIN
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		WHILE(1=1)
		BEGIN
			SELECT @ProcessedDate = @currentdate
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent, @recommend = recommend
			FROM tmpCustArchived 
			WHERE IsFinished = 0	

			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC dbo.DBA_ArchiveAccount4_DelCustInfo @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT

			-->Update data from Cust_ArchiveAccount		
			IF ISNULL(@ErrMsg,'') = ''
				EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
					@CustId = @recommend,
					@RoleID = 2,
					@StageID = @stage,
					@ProcessedDate = @ProcessedDate,
					@ArchivedDate = @ArchivedDate
	
			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent
	
			SET @msg = 'Stage 4 - Done Delete Customer Information for Agents: ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.180'
			--IF (@ErrMsg <> '') BREAK
		END
		
		-- Delete Setting for M1, M0
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
				SELECT @ProcessedDate = @currentdate
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @S1M1_username = username
						, @GroupLevelName = GroupLevelName
						, @ArchivedCustID = t.CustID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC dbo.DBA_ArchiveAccount4_DelCustInfoMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT

				-->Update data from Cust_ArchiveAccount		
				IF ISNULL(@ErrMsg,'') = ''
					EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
						@CustId = @ArchivedCustID,
						@RoleID = 3,
						@StageID = @stage,
						@ProcessedDate = @ProcessedDate,
						@ArchivedDate = @ArchivedDate
				
				SET @msg = 'Stage 4 - Done Delete Customer Information for ' + @GroupLevelName +':'+  @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
	END

	DROP TABLE #ReduceCredit
	DROP TABLE #ArchiveMasterSuper_tmp
	
END	

    
