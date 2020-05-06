/*
	Creator:	@Daniel
	Job Name:	[Archive Credit Accounts - Stage 3: Clear Balance]
	Server:		DBTXN
	Revision:
		- 20190913@Daniel:	Initiate on GIT - [Redmine: #000000]
*/


USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Archive Credit Accounts - Stage 3: Clear Balance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Loop check Stage 3 Status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
	Task: Archive unused credit account - loop check status Archive stage 3 to execute step on DBTRANS
	Created: Daniel@20190519
	Database: DBTRANS.CustDB

	Usage: Check this query if it can complete successfully then stage 3 can run on DBTRANS (step clear balance), otherwise just wait or cancel the run.
*/

SET NOCOUNT ON

DECLARE @status varchar(200), @s_status varchar(200), @currentTime datetime


WHILE (1=1)
BEGIN
	select @status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = ''aa_Status''
	select @s_status = VValue from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = ''aa_Stmt_Status''
	
	select @currentTime = getdate()

	if DATEPART(dw, @currentTime) IN(1,2,5,6,7)
	begin
	-- GENERATE ERROR AND STOP CHECK
		RAISERROR (''* LOOP * Skip run.'', 16, 1)
		RETURN
	end

	if (@status = ''Stage 3 - Running'' AND @s_status = ''Stage 3 - Done'') BREAK

   --delay 1 minutes before next check
   WAITFOR DELAY ''000:01:00.000''
END

PRINT ''[Archive Credit Accounts - Stage 3 - Clear balances] is ready to run''
', 
		@database_name=N'CustDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run stage 3 - Clear balance', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ArchiveAccount_ClearBal', 
		@database_name=N'CustDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'On Tuesday and Wednesday', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=12, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190709, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'684b7095-47dd-410c-a857-21bbf5450e3b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

