/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_DelCustSettingMaster]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT,
	@RoleID_Tmp TINYINT = 3
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20230613@Eden : Archive super level 789y (Stage 3 and Stage 4) [Redmine: #183447]
			- 20250102@Eden: Archiving direct member [redmine: #215533] 
*/
BEGIN    
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	Declare @roleid int, @CustID int, @Enabled bit, @Level varchar(10)
	SELECT @Level = CASE WHEN @RoleID_Tmp = 3 THEN 'Master' ELSE  'Super' END

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled
	FROM custinfo (nolock)
	WHERE username = @AccName

	if isnull(@CustID,0) = 0 or @roleid <> @RoleID_Tmp
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Invalid ' + @Level + ' User Name', @ErrCode = 101
		print @ErrMsg
		return
	END

	print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--===============================
	IF	   NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE custid = @CustID)
		OR NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE custid = @CustID)
	BEGIN
		PRINT @AccName +':'+ 'Cust setting data of this ' + @Level + ' have not been backed-up yet. Auto backup activated'
		--BACKUP DATA Agent
		EXEC [DBA_ArchiveAccount2_BackupAgent] @AccName = @AccName
		--Backup Data Member
		EXEC [DBA_ArchiveAccount2_BackupMember]  @AccName = @AccName
	END
	--===============================
	--PERFORM DELETE MEMBERS SETTINGS
	--===============================
	EXEC dbo.[DBA_ArchiveAccount_SMALine] @CustID = @CustID, @StageID = 3
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount3_DelCustSettingMaster AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
						'Level="'+ coalesce(cast(@Level as varchar(50)),space(1)) + '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1500,
		@TrackingValue = @LogSPData	,
		@duration = @duration
END		