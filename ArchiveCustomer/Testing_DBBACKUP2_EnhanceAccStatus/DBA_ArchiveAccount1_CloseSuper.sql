/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount1_CloseSuper]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT,
	@ProcessedDate DATETIME = NULL,
	@ArchivedDate DATE = NULL
AS
/*
		Description: Close an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
			- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210614@Eden: All sites - Dormant SMA Account List [RedmineID: #155969]
*/
BEGIN    
	SET NOCOUNT ON
	
	-- simulate run date based on test data version
	declare @currentDate smalldatetime 
	select @currentDate = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_TestDate'
	
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = getdate()

	DECLARE @roleid int, @SuperID int, @Closed bit, @ClosedReason tinyint

	SELECT @roleid = roleid, @SuperID = custid
	FROM custinfo (nolock)
	WHERE username = @AccName

	SELECT @Closed = CASE WHEN cps.CloseInfo > 0 THEN 1 ELSE 0 END
	FROM CustProductStatus cps WITH (NOLOCK)
	WHERE cps.CustID = @SuperID

	if ISNULL(@SuperID,0) = 0 or @roleid NOT IN (4)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'Invalid Super User Name', @ErrCode = 101
		PRINT @ErrMsg
		RETURN
	END

	SELECT @ClosedReason = ClosedReason FROM CustLoginInfo l WITH(NOLOCK) WHERE custid = @SuperID

	if @Closed = 1 AND @ClosedReason = 4
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super has been archived!!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg, 4) 	
		PRINT @ErrMsg

		EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
			@CustId = @SuperID,
			@RoleID = 4,
			@StageID = 1,
			@ProcessedDate = @ProcessedDate,
			@ArchivedDate = @ArchivedDate

		RETURN
	END

	--== Check new created members ==========================

	IF EXISTS(SELECT 1 FROM dbo.customer WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid IN (1,2,3) AND creatdate >= DATEADD(mm, -3, GETDATE()))
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super just created new members while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	--== Check new active trans ==========================

	IF EXISTS(select 1 from bodb02.dbo.bettrans WITH (NOLOCK) WHERE recommend IN (SELECT custid FROM custdb.dbo.custinfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid = 2)
			 AND bettype < 19999 and custid <> 0)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(select 1 from bodb02.dbo.translog WITH (NOLOCK) WHERE recommend IN (SELECT custid FROM custdb.dbo.custinfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid = 2))
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(SELECT 1 FROM bodb02.dbo.bettransLC WITH (NOLOCK) WHERE recommend IN (SELECT custid FROM custdb.dbo.custinfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid = 2))
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(SELECT 1 FROM bodb02.dbo.bettransRNG with (nolock) where recommend IN (SELECT custid FROM custdb.dbo.custinfo WITH(NOLOCK) WHERE srecommend = @SuperID AND roleid = 2))
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This super just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	--backup data for later rollback for this stage
	INSERT INTO bodb_Customer.dbo.CustBackupClosed(
		[ArchiveDate],
		[custid],
		[closed],
		[reject],
		[credit],
		[SuspendInfo],
		[CloseInfo],
		[ClosedReason]
	)
	SELECT	
		GETDATE(), 
		c.[custid],
		c.[closed],
		c.[reject],
		c.[credit],
		cps.SuspendInfo,
		cps.CloseInfo,
		cl.ClosedReason
	FROM custinfo c WITH (NOLOCK)
		INNER JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = c.custid
		LEFT JOIN CustLoginInfo cl WITH (NOLOCK) ON cl.CustID = c.custid
	WHERE c.custid = @SuperID
		AND NOT EXISTS (SELECT TOP 1 1 FROM bodb_Customer.dbo.CustBackupClosed WITH (NOLOCK) WHERE custid = c.custid)

	--close super
	EXEC DBA_Archive_Cust_SuperMaster @custid = @SuperID, @stage = 1

	DECLARE @IsOverwrite BIT

	IF @Closed = 0
		SET @IsOverwrite = 1
	ELSE 
		SET @IsOverwrite = 0

	EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
		@CustId = @SuperID,
		@RoleID = 4,
		@StageID = 1,
		@ProcessedDate = @ProcessedDate,
		@ArchivedDate = @ArchivedDate,
		@IsOverwrite = @IsOverwrite
	
	------------------
	DECLARE @LogSPData VARCHAR(5000), @LogSPDataOld varchar(5000), @ActionID INT

	IF  @Closed = 1
	BEGIN
		SET @ActionID = 1181 -- only change reason

		SELECT @LogSPDataOld = '<DBA_ArchiveAccount1_CloseSuper ' +
		'Reason="'+ coalesce(cast(@ClosedReason as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'

		SELECT @LogSPData = '<DBA_ArchiveAccount1_CloseSuper ' +
		'Reason="4" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'

	END
	ELSE
	BEGIN
		SET @ActionID = 1176

		SELECT @LogSPData = '<DBA_ArchiveAccount1_CloseSuper AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'
	END

	SET @endRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@endRun)

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @SuperID,
		@ActionID = @ActionID,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @LogSPDataOld,
		@duration = @duration
END


    
