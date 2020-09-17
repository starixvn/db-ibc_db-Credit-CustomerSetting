/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount1_CloseSuper]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT
AS
/*
		Description: Close an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
*/
BEGIN    
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = getdate()

	DECLARE @roleid int, @SuperID int, @Enabled bit, @Closed bit

	SELECT @roleid = roleid, @SuperID = custid, @Enabled = Enabled, @Closed = Closed
	FROM custinfo (nolock)
	WHERE username = @AccName

	if ISNULL(@SuperID,0) = 0 or @roleid NOT IN (4)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'Invalid master User Name', @ErrCode = 101
		PRINT @ErrMsg
		RETURN
	END

	if @Enabled = 0
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master has been archived!!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg, 4) 	
		PRINT @ErrMsg
		RETURN
	END

	if @Closed = 1
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master has already been CLOSED!!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 	
		PRINT @ErrMsg
		RETURN
	END

	--== Check new created members ==========================

	IF EXISTS(SELECT 1 FROM dbo.customer WITH (NOLOCK) WHERE srecommend = @SuperID AND roleid = 1 AND creatdate >= DATEADD(mm, -3, GETDATE()))
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master just created new members while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	--== Check new active trans ==========================

	IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettrans WITH (NOLOCK) WHERE srecommend = @SuperID AND bettype <> 20000 and custid <> 0)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(select 1 from DBTXN.bodb02.dbo.translog WITH (NOLOCK) WHERE srecommend = @SuperID)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(SELECT 1 FROM DBTXN.bodb02.dbo.bettransLC WITH (NOLOCK) WHERE srecommend = @SuperID)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	IF EXISTS(SELECT 1 FROM DBTXN.bodb02.dbo.bettransRNG with (nolock) where srecommend = @SuperID)
	BEGIN
		SELECT @ErrMsg = @AccName +':'+ 'This master just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,roleid) VALUES(@SuperID,@ErrMsg,4) 
		PRINT @ErrMsg
		RETURN
	END

	--backup data for later rollback for this stage
	insert into DBARCCUST.bodb_Customer.dbo.CustBackupClosed(
		[ArchiveDate],
		[custid],
		[closed],
		[reject],
		[credit]
	)
	SELECT	
		GetDate(), 
		[custid],
		[closed],
		[reject],
		[credit]
	FROM	custinfo c WITH (NOLOCK)
	WHERE	custid = @SuperID
		AND NOT EXISTS (select top 1 1 from DBARCCUST.bodb_Customer.dbo.CustBackupClosed with (nolock) where custid = c.custid)

	--close super
	EXEC DBA_Archive_Cust_SuperMaster @custid = @SuperID, @stage = 1
	
	------------------
	DECLARE @LogSPData VARCHAR(5000)

	SELECT @LogSPData = '<DBA_ArchiveAccount1_CloseSuper AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'

	SET @endRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@endRun)

	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @SuperID,
		@ActionID = 1176,
		@TrackingValue = @LogSPData,
		@duration = @duration
END

