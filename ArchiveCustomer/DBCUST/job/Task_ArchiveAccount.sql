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
		- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20210128@Winfred: Archiving min credit accounts process for Master & Agent levels [RedmineID: #149262]
		- 20210302@Eden: Just process SMA(s) stage 2, 3, 4 when they processed stage 1  [RedmineID: #149262]
		- 20210316@Helen: ArchivedMasterAgent_Stage3 for stage 3, backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
		- 20210617@Eden: Enhance the archiving account process on Stage 4 [RedmineID: #157123]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210614@Eden: All sites - Dormant SMA Account List [RedmineID: #155969]
		- 20210810@Eden: Edit stage 1 to resume when archive Agent Process [RedmineID: #155969]
		- 20220620@Johnson: define temp table to avoid dump db [redmine:#174035]
		- 20230623@Eden: Rearrange Stage 1 processing order for master/super level [Redmine: #188850]
		- 20230613@Eden : Archive super level 789y (Stage 3 and Stage 4) [Redmine: #183447]
		- 20250102@Eden : Archiving direct member [redmine: #215533] 
	Param:
		+ @stage: input stage to run archive
*/
BEGIN

	SET NOCOUNT ON
	
	DECLARE @srecommend INT
			, @mrecommend INT
			, @ReduceCredit MONEY = 0
			, @OldCredit MONEY = 0
			, @LogData VARCHAR(500)
			, @NewCredit MONEY = 0
			, @RealDownlineCredit MONEY = 0
			, @username NVARCHAR(MAX)
			, @recommend INT
			, @ArchivedDate	DATE = GETDATE() --keep time stamp for Cust_ArchiveAccount
			, @ProcessedDate DATETIME 
			, @ArchivedCustID INT
			, @IsOverwrite	BIT
			, @Tmp_srecommend INT

	DECLARE @status varchar(200), @GroupLevelName VARCHAR(10) = ''
	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100), @roleid_tmp INT, @S1M1_username NVARCHAR(100)
	CREATE TABLE #ReduceCredit (CustId INT,RoleID TINYINT,GroupLevelName VARCHAR(10), srecommend INT, ReduceCredit MONEY DEFAULT(0), IsFinished BIT DEFAULT(0))
	CREATE TABLE #DirectAcc_IgnoreReduceCredit(custid INT)
	CREATE TABLE #Master_IgnoredReduceCredit (custid INT, srecommend INT, ReduceCredit MONEY)
	CREATE TABLE #ArchiveMasterSuper_tmp (CustID INT, RoleID TINYINT, GroupLevelName VARCHAR(10),username NVARCHAR(100)
					, IsFinished BIT DEFAULT(0),srecommend INT)
		
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

	IF @stage IN (1,2,3,4) -- get List Supers, Masters whose direct member is active
	BEGIN
		TRUNCATE TABLE Tmp_ActiveDirectMembers
	
		INSERT INTO Tmp_ActiveDirectMembers(mrecommend,srecommend)
		SELECT mrecommend, srecommend 
		FROM OPENQUERY (DBACC, '	SELECT DISTINCT 
											  CASE WHEN ci.mrecommend < 0 THEN NULL ELSE ci.mrecommend END AS mrecommend
											, ci.srecommend
									FROM bodb_report.dbo.tempCustID t WITH(NOLOCK)
										INNER JOIN bodb02.dbo.custinfo ci WITH(NOLOCK) 
											ON t.CustID = ci.custid 
											AND ci.recommend IN(-3,-4)')
	END

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
			SELECT @ProcessedDate = GETDATE()

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
			SELECT @ProcessedDate = GETDATE()

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
		
		--Step 1.4 Close S1, M1, M0
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username, srecommend)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username, ci.srecommend
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
		WHERE ar.GroupLevelName IN ('M1','M0','S1')
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				SELECT @ProcessedDate = GETDATE()
				
				SELECT TOP (1) 
					  @S1M1_username = username
					, @roleid_tmp = roleid
					, @GroupLevelName = GroupLevelName
					, @ArchivedCustID = CustID
					, @Tmp_srecommend = srecommend
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0
				ORDER BY t.roleid, t.GroupLevelName DESC
				
				IF (@@ROWCOUNT = 0) BREAK

				UPDATE #ArchiveMasterSuper_tmp 
				SET IsFinished = 1
				WHERE CustID = @ArchivedCustID
				
				IF @roleid_tmp = 3
				BEGIN
					EXEC dbo.DBA_ArchiveAccount1_CloseMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT, @ArchivedDate = @ArchivedDate, @ProcessedDate = @ProcessedDate

					IF ISNULL(@ErrMsg,'') != '' AND @ErrMsg NOT LIKE '%archived%' 
					BEGIN
						IF EXISTS(	SELECT 1 
									FROM tmpCustArchived WITH(NOLOCK) 
									WHERE [Master] = @S1M1_username 
										AND ( ISNULL(ErrMsg,'') = '' OR ErrMsg LIKE '%archived%')
								) -- Master exist agent was archived
						BEGIN
							UPDATE t
							SET t.GroupLevelName = 'M2'
							FROM tmpCustGroupLevelArchived t WITH(ROWLOCK,UPDLOCK)
							WHERE t.GroupLevelName = 'M1'
								AND t.custid = @ArchivedCustID
						END
						ELSE -- remove master from archived list
						BEGIN
							DELETE t
							FROM tmpCustGroupLevelArchived t WITH(ROWLOCK,UPDLOCK)
							WHERE t.custid = @ArchivedCustID
						END

						-- Delete M0 under super line if not archived yet (skip if M0 was archived)
						DELETE m0
						FROM #ArchiveMasterSuper_tmp t 
							INNER JOIN tmpCustGroupLevelArchived m0 WITH(ROWLOCK,UPDLOCK)
								ON t.CustID = m0.custid
						WHERE t.srecommend = @Tmp_srecommend
							AND t.GroupLevelName = 'M0'
							AND t.IsFinished = 0

						DELETE t
						FROM #ArchiveMasterSuper_tmp t 
						WHERE t.srecommend = @Tmp_srecommend
							AND t.GroupLevelName = 'M0'
							AND t.IsFinished = 0

						--Update Super label
						UPDATE s
						SET GroupLevelName = CASE 
								WHEN mar.GroupLevelName  IN ('M0','M1') THEN 'S2'
								WHEN mar.GroupLevelName  IN ('M2') THEN 'S3'
								ELSE NULL
							END
						FROM tmpCustGroupLevelArchived s WITH(ROWLOCK,UPDLOCK)
							OUTER APPLY	( 
									SELECT TOP 1 m.GroupLevelName 
									FROM tmpCustGroupLevelArchived m WITH(NOLOCK)
										INNER JOIN custinfo mci WITH(NOLOCK) 
											ON mci.custid = m.custid 
											AND mci.srecommend = @Tmp_srecommend
											AND m.Roleid = 3
											AND mci.roleid = 3
									ORDER BY m.GroupLevelName
								) mar
						WHERE s.CustID = @Tmp_srecommend

						--Remove if Super not in (S1, S2, S3)
						DELETE t
						FROM tmpCustGroupLevelArchived t  WITH(ROWLOCK,UPDLOCK)
						WHERE t.custid = @Tmp_srecommend
							AND GroupLevelName IS NULL

						-- remove super from process list (super not S1)
						DELETE t
						FROM #ArchiveMasterSuper_tmp t 
						WHERE t.custid = @Tmp_srecommend
					END
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
		INSERT INTO #DirectAcc_IgnoreReduceCredit (custid)
		SELECT DISTINCT c.custid
		FROM customer c WITH(NOLOCK)
			CROSS APPLY dbo.f_CustSetting_GetHeadLineFromCustID (c.custid) sp
			INNER JOIN dbo.f_CustSetting_GetArchiveHeadline_IgnoreReduceCredit () h ON sp.HeadlineID = h.headlineID 
							
		INSERT INTO #ReduceCredit (CustId,srecommend,RoleID)
		SELECT c.custid, c.srecommend, 3 
		FROM (SELECT DISTINCT Master FROM dbo.tmpCustArchived  WITH (NOLOCK)  WHERE IsFinished = 0) AS t
			CROSS APPLY (SELECT custid,srecommend,credit FROM dbo.custInfo c1 WITH (NOLOCK) WHERE c1.username= t.Master and c1.roleid = 3) AS c
		
		INSERT INTO #ReduceCredit (CustId,srecommend,RoleID)
		SELECT c.custid, c.custid, 4
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
				SELECT @ErrMsg = '', @ReduceCredit = 0
				SELECT @ProcessedDate = GETDATE()

				SELECT TOP (1) 
					  @S1M1_username = username
					, @roleid_tmp = roleid
					, @GroupLevelName = GroupLevelName
					, @ArchivedCustID = CustID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0
				ORDER BY t.roleid, t.GroupLevelName DESC
				
				IF (@@ROWCOUNT = 0) BREAK

				UPDATE #ArchiveMasterSuper_tmp 
				SET IsFinished = 1
				WHERE CustID = @ArchivedCustID
				
				EXEC dbo.DBA_ArchiveAccount2_DisableMasterSuper @AccName = @S1M1_username,@srecommend = @srecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT, @ErrMsg = @ErrMsg OUTPUT,@ArchivedDate = @ArchivedDate
				
				SELECT @Tmp_srecommend = @srecommend

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
								CROSS APPLY (SELECT	ReduceCredit FROM #ReduceCredit WHERE CustId = @ArchivedCustID) AS t	
							WHERE CustId = @srecommend
						END
					END	
				END	

				IF @roleid_tmp = 3 AND  ISNULL(@ErrMsg,'') != '' AND @ErrMsg NOT LIKE '%archived%' 
				BEGIN
					IF EXISTS(	SELECT 1 
								FROM tmpCustArchived WITH(NOLOCK) 
								WHERE [Master] = @S1M1_username 
									AND ( ISNULL(ErrMsg,'') = '' OR ErrMsg LIKE '%archived%')
							) -- Master exist agent was archived
					BEGIN
						UPDATE t
						SET t.GroupLevelName = 'M2'
						FROM tmpCustGroupLevelArchived t WITH(ROWLOCK,UPDLOCK)
						WHERE t.GroupLevelName = 'M1'
							AND t.custid = @ArchivedCustID
					END
					ELSE -- remove master from archived list
					BEGIN
						DELETE t
						FROM tmpCustGroupLevelArchived t WITH(ROWLOCK,UPDLOCK)
						WHERE t.custid = @ArchivedCustID
					END

					-- Delete M0 under super line if not archived yet (skip if M0 was archived)
					DELETE m0
					FROM #ArchiveMasterSuper_tmp t 
						INNER JOIN tmpCustGroupLevelArchived m0 WITH(ROWLOCK,UPDLOCK)
							ON t.CustID = m0.custid
					WHERE t.srecommend = @Tmp_srecommend
						AND t.GroupLevelName = 'M0'
						AND t.IsFinished = 0

					DELETE t
					FROM #ArchiveMasterSuper_tmp t 
					WHERE t.srecommend = @Tmp_srecommend
						AND t.GroupLevelName = 'M0'
						AND t.IsFinished = 0

					--Update Super label
					UPDATE s
					SET GroupLevelName = CASE 
							WHEN mar.GroupLevelName  IN ('M0','M1') THEN 'S2'
							WHEN mar.GroupLevelName  IN ('M2') THEN 'S3'
							ELSE NULL
						END
					FROM tmpCustGroupLevelArchived s WITH(ROWLOCK,UPDLOCK)
						OUTER APPLY	( 
								SELECT TOP 1 m.GroupLevelName 
								FROM tmpCustGroupLevelArchived m WITH(NOLOCK)
									INNER JOIN custinfo mci WITH(NOLOCK) 
										ON mci.custid = m.custid 
										AND mci.srecommend = @Tmp_srecommend
										AND m.Roleid = 3
										AND mci.roleid = 3
								ORDER BY m.GroupLevelName
							) mar
					WHERE s.CustID = @Tmp_srecommend

					--Remove if Super not in (S1, S2, S3)
					DELETE t
					FROM tmpCustGroupLevelArchived t  WITH(ROWLOCK,UPDLOCK)
					WHERE t.custid = @Tmp_srecommend
						AND GroupLevelName IS NULL

					-- remove super from process list (super not S1)
					DELETE t
					FROM #ArchiveMasterSuper_tmp t 
					WHERE t.custid = @Tmp_srecommend
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

		-- Do not reduce credit of masters and supers if supers are direct accounts of K9 headline
		DELETE r
		FROM #ReduceCredit r
			INNER JOIN #DirectAcc_IgnoreReduceCredit d 
				ON r.srecommend = d.custid

		-- Do not reduce credit of masters who are direct accounts of K9 headline
		DELETE r
		OUTPUT deleted.CustId,deleted.srecommend,deleted.ReduceCredit
		INTO #Master_IgnoredReduceCredit(custid,srecommend,ReduceCredit)
		FROM #ReduceCredit r
			INNER JOIN #DirectAcc_IgnoreReduceCredit d 
				ON r.CustId = d.custid
		WHERE r.RoleID = 3

		--Reduce Supers Credit ignore whose masters are direct accounts of K9 headline
		UPDATE s
		SET s.ReduceCredit = s.ReduceCredit - ISNULL(m.ReduceCredit,0)
		FROM #ReduceCredit s
			INNER JOIN #Master_IgnoredReduceCredit m 
				ON s.CustId = m.srecommend 
		WHERE s.RoleID = 4

		IF EXISTS (SELECT TOP(1) 1 FROM #ReduceCredit WHERE ReduceCredit <> 0)
		BEGIN
			
			WHILE(1=1)
			BEGIN
				UPDATE t
				SET t.IsFinished = 1
					, @ArchivedCustID = t.CustId
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
				WHERE	custid = @ArchivedCustID
				
				IF @roleid_tmp = 3 
				BEGIN
					SELECT @RealDownlineCredit = ISNULL((	SELECT SUM(credit) 
															FROM dbo.custInfo WITH (NOLOCK) 
															WHERE mrecommend = @ArchivedCustID 
																AND (roleid  = 2 
																		OR (RoleID = 1 AND recommend = -3)
																	)
														),0)
				END
				ELSE
				BEGIN
					SET @RealDownlineCredit = ISNULL((SELECT SUM(credit) FROM	dbo.custInfo WITH (NOLOCK) WHERE srecommend = @ArchivedCustID AND roleid  = 3),0)
					SELECT @RealDownlineCredit = ISNULL((	SELECT SUM(credit) 
															FROM dbo.custInfo WITH (NOLOCK) 
															WHERE srecommend = @ArchivedCustID 
																AND (roleid  = 3 
																		OR (RoleID = 1 AND recommend = -4)
																	)
														),0)
				END
				SET @RealDownlineCredit = CASE WHEN 0 < @RealDownlineCredit THEN @RealDownlineCredit ELSE 0 END

				SET @NewCredit = CASE WHEN @OldCredit - @ReduceCredit < @RealDownlineCredit THEN @RealDownlineCredit
									  ELSE @OldCredit - @ReduceCredit END

				UPDATE c
				SET c.credit = @NewCredit,
					c.RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo c WITH (ROWLOCK, UPDLOCK)
				WHERE c.custid = @ArchivedCustID	

				--Writelog
				SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@username, SPACE(1))  

				BEGIN TRY
					EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
						@UserID = 360418,
						@CustID = @ArchivedCustID,
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
						@CustID = @ArchivedCustID,
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
			SELECT @ProcessedDate = GETDATE()

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

		-- Delete S1,S0 789y Site (Some Headline)
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.customer ci WITH (NOLOCK)  ON ar.custid = ci.custid
			INNER JOIN dbo.Site s WITH(NOLOCK) ON s.site = ci.site AND s.SiteLabel = '789y'
			CROSS APPLY dbo.f_CustSetting_GetHeadLineFromCustID (ar.custid) sp
			--INNER JOIN dbo.f_CustSetting_GetArchiveHeadline () h ON sp.HeadlineID = h.headlineID 
		WHERE ar.GroupLevelName IN ('S1','S0')
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				SELECT @ProcessedDate = GETDATE()
				
				SELECT TOP (1)
						  @S1M1_username = username
						, @GroupLevelName = GroupLevelName
						, @ArchivedCustID = t.CustID
						, @roleid_tmp = t.RoleID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				ORDER BY t.RoleID
				
				IF (@@ROWCOUNT = 0) BREAK
			
				EXEC dbo.DBA_ArchiveAccount3_DelCustSettingMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT, @roleid_tmp = @roleid_tmp

				--> Insert data for Cust_ArchiveAccount
				IF ISNULL(@ErrMsg,'') = '' AND @roleid_tmp IN (3,4)
					EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
						@CustId = @ArchivedCustID,
						@RoleID = @roleid_tmp,
						@StageID = @stage,
						@ProcessedDate = @ProcessedDate,
						@ArchivedDate = @ArchivedDate
				
				SET @msg = 'Stage 3 - Done Delete Setting for '+ @GroupLevelName + ':' + @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	

				UPDATE #ArchiveMasterSuper_tmp 
				SET IsFinished = 1
				WHERE CustID = @ArchivedCustID
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
		PRINT 'ArchivedMasterAgent_Stage3: Begin'
		-- insert data for table ArchivedMasterAgent_Stage3 - tw will refer to delete data for Casino DB
		TRUNCATE TABLE ArchivedMasterAgent_Stage3
		CREATE TABLE #Masterlist_Stage3(custid INT)
		CREATE TABLE #AgentList_Stage3(custid INT)
		CREATE TABLE #SuperList_Stage3(custid INT)
		
		INSERT INTO #Masterlist_Stage3(custid)
		SELECT DISTINCT ar.custid
		FROM tmpCustGroupLevelArchived ar WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount ca WITH (NOLOCK) ON ar.custid = ca.CustID AND ca.ArchivedDate = @ArchivedDate AND ca.StageID = 3
		WHERE GroupLevelName IN ('M1','M0')
			
		INSERT INTO #AgentList_Stage3(custid)
		SELECT DISTINCT ar.recommend AS CustID		
		FROM tmpCustArchived ar WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount ca WITH (NOLOCK) ON ar.recommend = ca.CustID AND ca.ArchivedDate = @ArchivedDate AND ca.StageID = 3
		WHERE IsFinished = 1 AND ISNULL(ErrMsg,'') = ''

		INSERT INTO #SuperList_Stage3(custid)
		SELECT DISTINCT ar.custid
		FROM tmpCustGroupLevelArchived ar WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount ca WITH (NOLOCK) ON ar.custid = ca.CustID AND ca.ArchivedDate = @ArchivedDate AND ca.StageID = 3
		WHERE GroupLevelName IN ('S1','S0')

		INSERT INTO ArchivedMasterAgent_Stage3(CustID,username,Level)
		SELECT s.CustID,
			c.username,
			'Agent' AS [Level]
		FROM #AgentList_Stage3 s 
			INNER JOIN custInfo c WITH(NOLOCK) ON s.CustID = c.custid
		WHERE c.roleid = 2
			AND c.Enabled = 0
			AND NOT EXISTS( SELECT 1 FROM #Masterlist_Stage3 WHERE custid = c.mrecommend)
			AND NOT EXISTS( SELECT 1 FROM #SuperList_Stage3 WHERE custid = c.srecommend)
		UNION ALL 
		SELECT s.CustID,
			c.username,
			'Master' AS [Level]
		FROM #Masterlist_Stage3 s 
			INNER JOIN custInfo c WITH(NOLOCK) ON s.CustID = c.custid
		WHERE c.roleid = 3
			AND c.Enabled = 0
			AND NOT EXISTS( SELECT 1 FROM #SuperList_Stage3 WHERE custid = c.srecommend)
		UNION ALL 
		SELECT s.CustID,
			c.username,
			'Super' AS [Level]
		FROM #SuperList_Stage3 s 
			INNER JOIN custInfo c WITH(NOLOCK) ON s.CustID = c.custid
		WHERE c.roleid = 4
			AND c.Enabled = 0
		
		DROP TABLE #AgentList_Stage3
		DROP TABLE #Masterlist_Stage3
		DROP TABLE #SuperList_Stage3

		Print 'ArchivedMasterAgent_Stage3: END'

	END
	ELSE IF(@stage = 4)
	BEGIN
		--Gen List Super Master into tmpCustGroupLevelArchived
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = @stage
		
		WHILE(1=1)
		BEGIN
			SELECT @ProcessedDate = GETDATE()
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

		-- Delete S1,S0 789y Site (Some Headline)
		INSERT INTO #ArchiveMasterSuper_tmp (CustID, GroupLevelName, RoleID, username)
		SELECT ar.custid, ar.GroupLevelName, ar.Roleid, ci.username
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.customer ci WITH (NOLOCK)  ON ar.custid = ci.custid
			INNER JOIN dbo.Site s WITH(NOLOCK) ON s.site = ci.site AND s.SiteLabel = '789y'
			CROSS APPLY dbo.f_CustSetting_GetHeadLineFromCustID (ar.custid) sp
			--INNER JOIN dbo.f_CustSetting_GetArchiveHeadline () h ON sp.HeadlineID = h.headlineID 
		WHERE ar.GroupLevelName IN ('S1','S0')
		
		IF EXISTS (SELECT TOP (1) 1 FROM #ArchiveMasterSuper_tmp)
		BEGIN
			WHILE(1=1)
			BEGIN
				SELECT @ErrMsg = ''
				SELECT @ProcessedDate = GETDATE()
				
				SELECT TOP (1)
					  @S1M1_username = username
					, @GroupLevelName = GroupLevelName
					, @ArchivedCustID = t.CustID
					, @roleid_tmp = t.RoleID
				FROM #ArchiveMasterSuper_tmp t 
				WHERE IsFinished = 0	
				ORDER BY t.RoleID
				
				IF (@@ROWCOUNT = 0) BREAK
			
				EXEC dbo.DBA_ArchiveAccount4_DelCustInfoMaster @AccName = @S1M1_username, @ErrMsg = @ErrMsg OUTPUT , @roleid_tmp = @roleid_tmp

				-->Update data from Cust_ArchiveAccount		
				IF ISNULL(@ErrMsg,'') = '' AND @roleid_tmp IN(3,4)
					EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
						@CustId = @ArchivedCustID,
						@RoleID = @roleid_tmp,
						@StageID = @stage,
						@ProcessedDate = @ProcessedDate,
						@ArchivedDate = @ArchivedDate
				
				SET @msg = 'Stage 4 - Done Delete Customer Information for ' + @GroupLevelName +':'+  @S1M1_username + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	

				UPDATE #ArchiveMasterSuper_tmp 
				SET IsFinished = 1
				WHERE CustID = @ArchivedCustID
				
				WAITFOR DELAY '00:00:00.010'
				
			END
			
		END
		
	END

	DROP TABLE #ReduceCredit
	DROP TABLE #ArchiveMasterSuper_tmp
	DROP TABLE #DirectAcc_IgnoreReduceCredit
	DROP TABLE #Master_IgnoredReduceCredit
	
END	
