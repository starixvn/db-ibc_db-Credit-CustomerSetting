/*<info serverAlias="DBBACKUP2-custDB_DBTRANS" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [Task_ArchiveAccount_ClearBal]
AS
/*
	Task: Archive unused credit account - step 3: clear balance
	Creator:	@Daniel
	Date: 20190708
	Database: DBTRANS.custdb

	Revisions:
		- 20190708@Daniel: Created
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
		- 20201105@Helen: Phase 2&3 - Include transfer A1, A0, M1, M0 to upline [Redmine: #130032]
		- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20200128@Winfred: Check startrun when log master / Super [RedmineID: #149262]
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100)
	
	
	DECLARE @recommend int, @mrecommend int, @srecommend int, 
		@currency int, @actualrate float, @currencyName nvarchar(10),
		@agentname varchar(50), @mastername varchar(50), @supername varchar(50)
		, @custid_tmp INT, @username_tmp VARCHAR(50)
		, @ErrMsg_tmp nvarchar(200) = '' 
		, @ErrCode int = 0 
		
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	DECLARE @UserID int = 360418
	SET @startRun = GETDATE()
	
	if exists(select 1 from bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status' AND VValue IN ('Stage 3 - Running','Stage 3 - Done'))
	BEGIN
		-- from member to agent
		EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = 3
		
		WHILE(1=1)
		BEGIN
			
			SELECT @ErrMsg = ''
			SELECT TOP 1 @agent = Agent FROM tmpCustArchived WHERE IsFinished = 0	
			IF (@@ROWCOUNT = 0) BREAK
	
			EXEC bodb02.dbo.DBA_ArchiveAccount3_ClearBalance @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT

			UPDATE tmpCustArchived 
			SET ErrMsg = @ErrMsg, IsFinished = 1
			WHERE Agent = @agent

			SET @msg = 'Done agent ' + @agent + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.180'
			--IF (@ErrMsg <> '') BREAK
		END
		
		-- from agent to master
		CREATE TABLE #AgentToMaster_Transfer (recommend INT, mrecommend INT,srecommend INT, agentName VARCHAR (50), masterName VARCHAR(50)
					, currency INT,currencyName nvarchar(10), actualrate float, Isfinished BIT DEFAULT 0
					)
		CREATE TABLE #Master_tmp (CustID INT,username VARCHAR(50), Isfinished BIT DEFAULT 0)
		CREATE TABLE #MasterToSuper_Transfer (srecommend INT, mrecommend INT,superName VARCHAR (50), masterName VARCHAR(50)
					, currency INT,currencyName nvarchar(10), actualrate float, Isfinished BIT DEFAULT 0
					)
		CREATE TABLE #Super_tmp (CustID INT, username VARCHAR(50),Isfinished BIT DEFAULT 0)
		
		INSERT INTO #AgentToMaster_Transfer (recommend, mrecommend,srecommend,agentName, masterName, currency,currencyName, actualrate)
		SELECT ci.custid,ci.mrecommend,ci.srecommend, ci.username, t.Master, ci.currency, e.currency,e.actualrate 
		FROM dbo.tmpCustArchived t WITH (NOLOCK)
			INNER JOIN custdb.dbo.CustInfo CI WITH (NOLOCK) ON t.recommend = CI.custid
			INNER JOIN custdb.dbo.exchange e ON e.exchangeid = ci.currency
		ORDER BY ci.mrecommend
		
		INSERT INTO #Master_tmp (CustID,username)
		SELECT DISTINCT mrecommend, masterName
		FROM #AgentToMaster_Transfer 
		
		WHILE(1=1)
		BEGIN
			SELECT @ErrMsg = '', @ErrMsg_tmp = ''
			
			UPDATE TOP (1) t
				SET  IsFinished = 1
					, @custid_tmp = Custid 
					, @username_tmp = username
			FROM #Master_tmp t 
			WHERE IsFinished = 0	
			
			IF (@@ROWCOUNT = 0) BREAK
			
			SET @startRun = GETDATE()	
			
			WHILE (1=1)
			BEGIN
				SELECT @ErrMsg = ''
				
				UPDATE TOP (1) t
					SET  IsFinished = 1
						, @recommend = recommend
						, @mrecommend = mrecommend
						, @srecommend  = srecommend
						, @agentName = agentName
						, @masterName = masterName
						, @currency = currency
						, @actualrate = actualrate
						, @currencyName = currencyName
				FROM #AgentToMaster_Transfer t 
				WHERE IsFinished = 0 AND t.mrecommend = @custid_tmp	
			
				IF (@@ROWCOUNT = 0) BREAK
				
				EXEC bodb02.dbo.DBA_ArchiveAccount3_ClearBalance_AgentMaster @recommend = @recommend,
					@agentname = @agentname,	
					@mrecommend  = @mrecommend,
					@srecommend  = @srecommend,
					@mastername  = @mastername,
					@actualrate  = @actualrate,
					@currencyName = @currencyName,
					@currency  = @currency,
					@ErrMsg = @ErrMsg OUTPUT
				
				SET @ErrMsg_tmp = @ErrMsg_tmp + @ErrMsg
				
				SET @msg = 'Stage 3 - Done transfer agent to master: ' + @agentName + CHAR(13)
				RAISERROR(@msg, 0, 0) WITH NOWAIT	
				
				WAITFOR DELAY '00:00:00.010'
			END
			
			------------------
			declare @LogSPData varchar(5000)

			Select @LogSPData = '<DBA_ArchiveAccount3_ClearBalance_AgentMaster AccName="'+ coalesce(cast(@username_tmp as varchar(50)),space(1))+ '" ' +
								'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
								'ErrMsg="'+ coalesce(cast(@ErrMsg_tmp as varchar(400)),space(1))+ '" ' +
								'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'
								
			set @endRun = getdate()
			set @duration  = datediff (millisecond,@startRun,@endRun)
								
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @UserID,
				@CustID = @custid_tmp,
				@ActionID = 1503,
				@TrackingValue = @LogSPData,
				@duration = @duration
			
		END
		
		-- Master transfer to Super
		INSERT INTO #MasterToSuper_Transfer (srecommend, mrecommend,superName, masterName, currency,currencyName, actualrate)
		SELECT super.custid,ar.custid, super.username,ci.username, ci.currency, e.currency,e.actualrate 
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN custdb.dbo.CustInfo CI WITH (NOLOCK) ON ar.custid = CI.custid
			INNER JOIN custdb.dbo.custInfo super WITH (NOLOCK) ON super.custid = ci.srecommend AND super.roleid = 4
			INNER JOIN custdb.dbo.exchange e ON e.exchangeid = ci.currency
		WHERE ar.GroupLevelName IN ('M1','M0') AND ar.roleid = 3	
		
		INSERT INTO #Super_tmp(CustID,username)
		SELECT DISTINCT srecommend, superName
		FROM #MasterToSuper_Transfer 
		
		IF EXISTS (SELECT TOP (1) 1 FROM #MasterToSuper_Transfer)
		BEGIN
			WHILE (1=1)
			BEGIN
				SELECT @ErrMsg = '', @ErrMsg_tmp = ''
				
				UPDATE TOP (1) t
				SET  IsFinished = 1
					, @custid_tmp = Custid 
					, @username_tmp = username
				FROM #Super_tmp t 
				WHERE IsFinished = 0	
				
				IF (@@ROWCOUNT = 0) BREAK
			
				SET @startRun = GETDATE()	
				
				WHILE(1=1)
				BEGIN
					SELECT @ErrMsg = ''
					
					UPDATE TOP (1) t
						SET  IsFinished = 1
							, @srecommend = srecommend
							, @mrecommend = mrecommend
							, @mastername = masterName
							, @supername = supername
							, @currency = currency
							, @actualrate = actualrate
							, @currencyName = currencyName
					FROM #MasterToSuper_Transfer t 
					WHERE IsFinished = 0 AND t.srecommend = @custid_tmp	
					
					IF (@@ROWCOUNT = 0) BREAK
					
					EXEC bodb02.dbo.DBA_ArchiveAccount3_ClearBalance_MasterSuper @mrecommend = @mrecommend,
						@srecommend  = @srecommend,
						@mastername  = @mastername,
						@supername = @supername,	
						@actualrate  = @actualrate,
						@currencyName = @currencyName,
						@currency  = @currency,
						@ErrMsg = @ErrMsg OUTPUT
					
					SET @msg = 'Stage 3 - Done transfer master to super: ' + @mastername + CHAR(13)
					RAISERROR(@msg, 0, 0) WITH NOWAIT	
					
					SET @ErrMsg_tmp = @ErrMsg_tmp + @ErrMsg
					
					WAITFOR DELAY '00:00:00.010'
					
				END
				------------------
				SELECT @LogSPData = '<DBA_ArchiveAccount3_ClearBalance_MasterSuper AccName="'+ coalesce(cast(@username_tmp as varchar(50)),space(1))+ '" ' +
									'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
									'ErrMsg="'+ coalesce(cast(@ErrMsg_tmp as varchar(400)),space(1))+ '" ' +
									'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'
									
				SET @endRun = getdate()
				SET @duration  = datediff (millisecond,@startRun,@endRun)
									
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
					@UserID = @UserID,
					@CustID = @custid_tmp,
					@ActionID = 1504,
					@TrackingValue = @LogSPData,
					@duration = @duration
			END	
		END
	END
	DROP TABLE #AgentToMaster_Transfer
	DROP TABLE #MasterToSuper_Transfer
	
END
    
