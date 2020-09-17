/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableMaster]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT,
	@srecommend INT = 0 OUTPUT,
	@ReduceCredit MONEY = 0 OUTPUT
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
*/
BEGIN
	    
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int, @Now datetime
	set @startRun = getdate()

	Declare @roleid int, @CustID int, @Enabled bit

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled, @srecommend = srecommend, @ReduceCredit = credit
	FROM custinfo (nolock)
	WHERE username = @AccName

	PRINT  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--=============================
	--PERFORM BACKUP DATA MEMBERS
	--=============================

	SELECT @Now = current_timestamp

	--Copy Master'info to bodb_Customer 
	insert into DBARCCUST.bodb_Customer.dbo.customer_old(
		   [custid],[firstname],[lastname],[address] ,[postal],[city]
		  ,[state] ,[country]  ,[phone]   ,[mobilephone] ,[fax]
		  ,[email] ,[birthday] ,[refcode1],[refcode2],[remark]
		  ,[creatdate],[creator],[username],[currency],[userpwd]
		  ,[lastlogged],[pwdexpiry],[roleid],[mrecommend],[recommend]
		  ,[ugroup],[logincount],[on_sessionid],[site],[iplogin]
		  ,[important],[srecommend],[username2]
	)
	select [custid],[firstname],[lastname],[address] ,[postal],[city]
		  ,[state] ,[country]  ,[phone]   ,[mobilephone] ,[fax]
		  ,[email] ,[birthday] ,[refcode1],[refcode2],[remark]
		  ,[creatdate],[creator],[username],[currency],[userpwd]
		  ,[lastlogged],[pwdexpiry],[roleid],[mrecommend],[recommend]
		  ,[ugroup],[logincount],[on_sessionid],[site],[iplogin]
		  ,[important],[srecommend],[username2]
	from	customer (NOLOCK)
	where	custid = @custID

	--Copy master' custinfo to bodb_Customer 
	insert into DBARCCUST.bodb_Customer.dbo.custinfo_old(
		   [ArchiveDate],
			username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, 
						  VirtualMultiplier, maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11, maxpermatch12, 
						  maxpermatch99, Enabled, danger, DisableCasino, SyncCasino, danger2, 
						  danger3, DisableOutright, MaxPerMatch99MP, DisableNumber, maxpermatch161, 
						  MaxPerBall161,
						  Abnormal, DoubleCommLosing,
						  autosuspend2, HideKeno, DisableEsports, HideGoldDeluxe, DisableGoldDeluxe,  
						  DisableSuperLive, DisableColossusBet, HideColossusBet, 
						  LockUpd, MaxPerMatch1MP, BonusWalletFlag
	)
	select	@Now, 
			username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, 
						  VirtualMultiplier, maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11, maxpermatch12, 
						  maxpermatch99, Enabled, danger, DisableCasino, SyncCasino, danger2, 
						  danger3, DisableOutright, MaxPerMatch99MP, DisableNumber, maxpermatch161, 
						  MaxPerBall161,
						  Abnormal, DoubleCommLosing,
						  autosuspend2, HideKeno, DisableEsports, HideGoldDeluxe, DisableGoldDeluxe,  
						  DisableSuperLive, DisableColossusBet, HideColossusBet, 
						  LockUpd, MaxPerMatch1MP, BonusWalletFlag
	from	custinfo (nolock)
	where	custid = @CustID
	-----------------------------------------------------------------------------------------------------------
	EXEC DBA_Archive_Cust_SuperMaster @custid = @CustID, @stage = 2
	
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount2_DisableMaster AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1177,
		@TrackingValue = @LogSPData	,
		@duration = @duration
END