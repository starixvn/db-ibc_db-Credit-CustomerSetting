/*<info serverAlias="DBBACKUP2-custDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount4_DelCustInfoMaster]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
		Description: Archive Phas 2
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20210128@Winfred: Check exists bettype 20000 in bettrans [RedmineID: #149262]
			- 20210225@Winfred: Check exists bettype 20000 and matchid = 0 ( use clustered index ) in bettrans [RedmineID: #149262]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
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
		SELECT 1 FROM bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
		WHERE custid = @custid
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Cust info data of this Master have not been backed-up yet. Auto backup activated.', @ErrCode = 10
		print @ErrMsg
		--select @ErrMsg = ''
		EXEC dbo.DBA_ArchiveAccount4_BackupCustInfoMaster @AccName=@AccName, @ErrMsg = @ErrMsg
		--IF @ErrMsg <> '' return
	END
	
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custsub_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		INSERT INTO bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
		SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		FROM	custsub WITH (NOLOCK)
		WHERE	custid = @CustID
	END
	
	--Pre-check: Make sure @CustID not exists bettype 20000 in bettrans
	IF EXISTS(select 1 from bodb02.dbo.bettrans with (nolock) where custid = @CustID AND bettype = 20000 AND matchid = 0)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'This master exists bettype 20000 in bettrans!', @ErrCode = 11
		print @ErrMsg
		return
	END

	--===============================
	--PERFORM DELETE MEMBERS INFO
	--===============================

	Exec DBA_Archive_Cust_SuperMaster @CustID = @CustID, @stage = 4 
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount4_DelCustInfoMaster AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
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
    
