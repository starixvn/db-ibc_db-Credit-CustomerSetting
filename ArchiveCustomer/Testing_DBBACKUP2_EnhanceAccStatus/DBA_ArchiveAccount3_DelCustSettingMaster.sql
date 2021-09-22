/*<info serverAlias="DBBACKUP2-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_DelCustSettingMaster]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
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
	declare @duration int
	set @startRun = getdate()

	Declare @roleid int, @CustID int, @Enabled bit

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled
	FROM custinfo (nolock)
	WHERE username = @AccName

	if isnull(@CustID,0) = 0 or @roleid NOT IN (3)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Invalid Master User Name', @ErrCode = 101
		print @ErrMsg
		return
	END

	print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--===============================
	--PRE-CHECK BEFORE DELETE
	--===============================
	--Pre-check: Make sure cust setting data already backed-up in DBRACCUST
	IF NOT EXISTS(
		SELECT 1 FROM bodb_Customer.dbo.custsetting_old WITH(NOLOCK) 
		WHERE custid = @CustID 
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Cust setting data of this agent have not been backed-up yet. Auto backup activated', @ErrCode = 10
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,3) 
		print @ErrMsg
		select @ErrMsg = ''
		EXEC dbo.DBA_ArchiveAccount3_BackupCustSettingMaster @AccName=@AccName, @ErrMsg = @ErrMsg
		IF @ErrMsg <> '' return
	END

	--===============================
	--PERFORM DELETE MEMBERS SETTINGS
	--===============================

	Exec DBA_Archive_Cust_SuperMaster @CustID = @CustID, @stage = 3
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount3_DelCustSetting AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1500,
		@TrackingValue = @LogSPData	,
		@duration = @duration
END		
