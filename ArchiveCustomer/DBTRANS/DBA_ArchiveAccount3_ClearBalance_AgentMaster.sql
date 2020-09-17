/*<info serverAlias="DBTXN-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_ClearBalance_AgentMaster]
	@recommend INT = 0,
	@agentname varchar(50) = '',	
	@mrecommend INT = 0,
	@srecommend INT = 0,
	@mastername VARCHAR (50) = '',
	@actualrate float = 0,
	@currencyName nvarchar(10),
	@currency int = 0,
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
/*
		Description: Close an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBTXN/bodb02
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
*/
AS
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	print  'Start:' + convert(varchar(50), getdate(), 113)

	Declare @refno bigint, @grefno int, @Now datetime, @Enabled bit, @AgentBalance MONEY

	--==========================================================
	--CREATING TEMP TABLES
	--==========================================================
	print @agentname +':'+ 'Temp Table Done:' + convert(varchar(50), getdate(), 113)	

	SET @AgentBalance =  (Select ISNULL(SUM(awinlost + comm + winlost - actual_stake), 0) as AgentBalance
							FROM bettrans WITH (NOLOCK)
							WHERE recommend = @recommend
							)  

	IF @AgentBalance = 0 
		RETURN
		 
	SET @Now = CURRENT_TIMESTAMP
	--------------------------START:Agent-Master-------------------------------
		
	print @agentname +':'+ 'Agent-Master-->Agent:' + @agentname + ' ' + cast(@AgentBalance as varchar(30))

	UPDATE ref with (rowlock, UPDLOCK)  SET   @grefno=transcode=transcode+1
	WHERE  refid='acc'
	if @@Error <> 0
	BEGIN
		delete bettrans where refno = @refno and matchid = 0
		return
	END
	select @refno=200000000000+@grefno

	IF (@AgentBalance > 0) 
	BEGIN
		-- insert master
		INSERT INTO bettrans 
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES (0, @UserID, @mrecommend, @mastername, @refno, @Now, 21004, 'For Delete Account - From Customer::'+@agentname, @AgentBalance, 0, 
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @mrecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			return
		END
		
		-- insert agent
		INSERT INTO bettrans
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @recommend, @agentname, @refno, @Now, 21004, 'For Delete Account - To Customer::'+ @mastername, 0, @AgentBalance,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			@recommend, @MRecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			
			return
		END			
		
	END
	ELSE if (@AgentBalance<0) 
	BEGIN
		SET @AgentBalance = abs(@AgentBalance) 
		-- insert for master			
		INSERT INTO bettrans 
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, statusID, ruben, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @mrecommend, @mastername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - To Customer::'+ @agentname, 0, @AgentBalance,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @mrecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			delete bettrans where refno = @refno and matchid = 0
			return
		END
		-- insert for agent
		INSERT INTO bettrans
		   (matchid, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status,statusID, ruben, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (0, @UserID, @recommend, @agentname, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - From Customer::'+ @mastername, @AgentBalance, 0,
			@refno, 'Completed',131, 1, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			@recommend, @MRecommend, @srecommend, 0, 0,'')
		
		if @@Error <> 0
		BEGIN
			RAISERROR (@ErrMsg, 16, 1)
			DELETE bettrans where refno = @refno and matchid = 0
			RETURN
		END
		
	END	
		
		
	--------------------------END:Agent-Master-------------------------------	
	print @agentname +':'+ 'Master cursor Done:' + convert(varchar(50), getdate(), 113)
	------------------
	declare @LogSPData varchar(5000)

	Select @LogSPData = '<DBA_ArchiveAccount3_ClearBalance_AgentMaster AccName="'+ coalesce(cast(@agentname as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'
						
	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)
						
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @recommend,
		@ActionID = 1502,
		@TrackingValue = @LogSPData,
		@duration = @duration

END