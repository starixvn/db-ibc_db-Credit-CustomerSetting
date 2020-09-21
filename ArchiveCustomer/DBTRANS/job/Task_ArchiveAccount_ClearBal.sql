/*<info serverAlias="DBTXN-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_ClearBal]
AS
/*
	Task: Archive unused credit account - step 3: clear balance
	Creator:	@Daniel
	Date: 20190708
	Database: DBTRANS.custdb

	Revisions:
		- 20190708@Daniel: Created
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @agent varchar(50), @ErrMsg VARCHAR(150), @msg VARCHAR(100)
	
	
	DECLARE @recommend int, @mrecommend int, @srecommend int, 
		@currency int, @actualrate float, @currencyName nvarchar(10),
		@agentname varchar(50), @mastername varchar(50), @supername varchar(50)
		
	if exists(select 1 from DBACC.bodb02.dbo.SystemSettings with(nolock) where VName = 'aa_Status' AND VValue IN ('Stage 3 - Running','Stage 3 - Done'))
	BEGIN
		-- from member to agent
		WHILE(1=1)
		BEGIN
			
			EXEC DBA_ArchiveAccount_GenMasterSuperGroupLevel @StageId = 3
			
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
		
		CREATE TABLE #MasterToSuper_Transfer (srecommend INT, mrecommend INT,superName VARCHAR (50), masterName VARCHAR(50)
					, currency INT,currencyName nvarchar(10), actualrate float, Isfinished BIT DEFAULT 0
					)
		
		INSERT INTO #AgentToMaster_Transfer (recommend, mrecommend,srecommend,agentName, masterName, currency,currencyName, actualrate)
		SELECT ci.custid,ci.mrecommend,ci.srecommend, ci.username, t.Master, ci.currency, e.currency,e.actualrate 
		FROM dbo.tmpCustArchived t WITH (NOLOCK)
			INNER JOIN dbo.CustInfo CI WITH (NOLOCK) ON t.recommend = CI.custid
			INNER JOIN dbo.exchange e ON e.exchangeid = ci.currency
				
		WHILE(1=1)
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
					, @actualrate = @actualrate
					, @currencyName = currencyName
			FROM #AgentToMaster_Transfer t 
			WHERE IsFinished = 0	
			
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
			
			SET @msg = 'Stage 3 - Done transfer agent to master: ' + @agentName + CHAR(13)
			RAISERROR(@msg, 0, 0) WITH NOWAIT	
			
			WAITFOR DELAY '00:00:00.010'
			
		END
		return
		-- Master transfer to Super
		INSERT INTO #MasterToSuper_Transfer (srecommend, mrecommend,superName, masterName, currency,currencyName, actualrate)
		SELECT super.custid,ar.custid, super.username,ci.username, ci.currency, e.currency,e.actualrate 
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN dbo.CustInfo CI WITH (NOLOCK) ON ar.custid = CI.custid
			INNER JOIN dbo.custInfo super WITH (NOLOCK) ON super.custid = ci.srecommend AND super.roleid = 4
			INNER JOIN dbo.exchange e ON e.exchangeid = ci.currency
		WHERE ar.GroupLevelName = 'M1' AND ar.roleid = 3	
		
		IF EXISTS (SELECT TOP (1) 1 FROM #MasterToSuper_Transfer)
		BEGIN
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
						, @actualrate = @actualrate
						, @currencyName = currencyName
				FROM #MasterToSuper_Transfer t 
				WHERE IsFinished = 0	
				
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
				
				WAITFOR DELAY '00:00:00.010'
				
			END
		END
	END
	DROP TABLE #AgentToMaster_Transfer
	DROP TABLE #MasterToSuper_Transfer
END