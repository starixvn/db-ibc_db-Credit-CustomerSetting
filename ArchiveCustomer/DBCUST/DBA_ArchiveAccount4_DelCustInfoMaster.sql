/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_DelCustInfoMaster]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT,
	@RoleID_Tmp TINYINT = 3
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
			- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
			- 20230613@Eden : Archive super level 789y (Stage 3 and Stage 4) [Redmine: #183447]
			- 20240905@Eden : Scale out DBCUST - Delete data custinfomini [redmine: #210077]
			- 20241007@Helios : Scale out DBCUST - Delete data custinfomini - remove call link Server DBGLOB [redmine: #210077]
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
		Select @ErrMsg = @AccName +':'+ 'Invalid '+ @Level +' User Name', @ErrCode = 101

		print @ErrMsg
		return
	END

	print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--===============================
	--PRE-CHECK BEFORE DELETE
	--===============================
	--Pre-check: Make sure cust setting data already backed-up in DBRACCUST
	IF	   NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE custid = @CustID)
		OR NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE custid = @CustID)
	BEGIN
		PRINT @AccName +':'+ 'Cust info data of this '+ @Level +' have not been backed-up yet. Auto backup activated.'
		--BACKUP DATA Agent
		EXEC [DBA_ArchiveAccount2_BackupAgent] @AccName = @AccName
		--Backup Data Member
		EXEC [DBA_ArchiveAccount2_BackupMember]  @AccName = @AccName
	END
	
	--Pre-check: Make sure @CustID not exists bettype 20000 in transfer
	IF EXISTS(select 1 from DBACC.bodb02.dbo.transfer with (nolock) where custid = @CustID AND bettype = 20000)
	BEGIN	
		Select @ErrMsg = @AccName +':'+ 'This ' + @Level + ' exists bettype 20000 in transfer!', @ErrCode = 11
		print @ErrMsg
		return
	END

	--===============================
	--PERFORM DELETE MEMBERS INFO
	--===============================

	DECLARE @CustIDs VARCHAR(MAX) = ''
	SELECT @CustIDs = CAST(@custid AS VARCHAR(10)) + ','

	IF @roleid = 3
	BEGIN
		SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
		FROM custinfo with (nolock) 
		WHERE mrecommend = @CustID 
			AND recommend = -3 
			AND roleid = 1
	END
	ELSE IF @roleid = 4
	BEGIN
		SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
		FROM custinfo with (nolock) 
		WHERE srecommend = @CustID 
			AND recommend = -4
			AND roleid = 1
	END

	--just keep code 8 table Balance
	Exec Acc_ExecRep_Cust_00 @CustIDs = @CustIDs

	--For archive Acc (New) - update/delete part in stage 1,2,3 
	EXEC dbo.[DBA_ArchiveAccount_SMALine] @CustID = @CustID, @StageID = 4

	--Delete custinfomini
	EXEC DBGLOB.GlobCustDB.dbo.[DBA_ArchiveAccount4_DelCustInfoMini] @CustIDs = @CustIDs
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount4_DelCustInfoMaster AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
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