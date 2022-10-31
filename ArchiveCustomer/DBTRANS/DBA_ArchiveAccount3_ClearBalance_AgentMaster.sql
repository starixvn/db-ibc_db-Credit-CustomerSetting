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
			- 20201109@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - Stage 2,3,4 - [Redmine:130032]
			- 20210817@Elodie: Change data type of Refno  to bigint instead [Redmine: #160262]
			- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
			- 20220907@Eden: Scale out DBTrans [RedmineID: #158293]
*/
AS
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	print  'Start:' + convert(varchar(50), getdate(), 113)

	Declare @refno bigint, @TransID bigint, @TransID2 bigint, @Now datetime, @Enabled bit, @AgentBalance MONEY
	
	IF EXISTS(select 1 from dbo.transfer with (nolock) where Recommend = @recommend AND bettype < 20000)
	BEGIN
		Select @ErrMsg = @agentname +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@recommend, 2) 
		print @ErrMsg
		return
	END

	--==========================================================
	--CREATING TEMP TABLES
	--==========================================================
	print @agentname +':'+ 'Temp Table Done:' + convert(varchar(50), getdate(), 113)	

	SET @AgentBalance =  (Select ISNULL(SUM(awinlost + comm + winlost - actual_stake), 0) as AgentBalance
							FROM transfer WITH (NOLOCK)
							WHERE recommend = @recommend
							)  
	IF @AgentBalance = 0 
		RETURN
		 
	SET @Now = CURRENT_TIMESTAMP
	--------------------------START:Agent-Master-------------------------------
		
	print @agentname +':'+ 'Agent-Master-->Agent:' + @agentname + ' ' + cast(@AgentBalance as varchar(30))

	EXEC Get_Refno_Transid @RefNo = @RefNo OUTPUT
	EXEC Get_Bettrans_TransID @TransID = @TransID OUTPUT
	EXEC Get_Bettrans_TransID @TransID = @TransID2 OUTPUT

	IF (@AgentBalance > 0) 
	BEGIN
		-- insert master
		INSERT INTO transfer 
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES (@TransId, @UserID, @mrecommend, @mastername, @refno, @Now, 21004, 'For Delete Account - From Customer::'+@agentname, @AgentBalance, 0, 
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @mrecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			DELETE transfer WITH(ROWLOCK,UPDLOCK) WHERE TransId = @TransID
			return
		END
		
		-- insert agent
		INSERT INTO transfer
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransID2, @UserID, @recommend, @agentname, @refno, @Now, 21004, 'For Delete Account - To Customer::'+ @mastername, 0, @AgentBalance,
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			@recommend, @MRecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			DELETE transfer WITH(ROWLOCK,UPDLOCK) WHERE TransId IN (@TransID, @TransID2)
			
			return
		END			
		
	END
	ELSE if (@AgentBalance<0) 
	BEGIN
		SET @AgentBalance = abs(@AgentBalance) 
		-- insert for master			
		INSERT INTO transfer 
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName, 
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransID, @UserID, @mrecommend, @mastername, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - To Customer::'+ @agentname, 0, @AgentBalance,
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			0, @mrecommend, @srecommend, 0, 0,'')
		if @@Error <> 0
		BEGIN
			RaisError (@ErrMsg, 16, 1)
			DELETE transfer WITH(ROWLOCK,UPDLOCK) WHERE TransId = @TransID
			return
		END
		-- insert for agent
		INSERT INTO transfer
		   (TransId, creator, custid, username, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			statusID, winlostdate, currency, actualrate, currencyName,
			recommend, mrecommend, srecommend, scomm, swinlost,ip)
		VALUES 
		   (@TransID2, @UserID, @recommend, @agentname, @refno, CURRENT_TIMESTAMP, 21004, 'For Delete Account - From Customer::'+ @mastername, @AgentBalance, 0,
			131, convert(nvarchar(10), @Now,120), @currency, @actualrate, @currencyName,
			@recommend, @MRecommend, @srecommend, 0, 0,'')
		
		if @@Error <> 0
		BEGIN
			RAISERROR (@ErrMsg, 16, 1)
			DELETE transfer WITH(ROWLOCK,UPDLOCK) WHERE TransId IN (@TransID, @TransID2)
			RETURN
		END
		
	END	
	--------------------------END:Agent-Master-------------------------------	
END