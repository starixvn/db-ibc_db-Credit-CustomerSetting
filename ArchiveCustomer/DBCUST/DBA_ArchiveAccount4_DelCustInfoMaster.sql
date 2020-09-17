/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_DelCustInfoMaster]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created by: Daniel
	Date: 2016-03-10
	Original:
	Task: Delete custsetting data 
	DB: DBCUST/CustDB
	
	Revisions:
		20180320@Daniel: rename SP to count stage from 1 => No. 4 for this stage

*/
    
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
	Select @ErrMsg = @AccName +':'+ 'Invalid Agent User Name', @ErrCode = 101
	print @ErrMsg
	return
END

print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

--===============================
--PRE-CHECK BEFORE DELETE
--===============================
--Pre-check: Make sure cust setting data already backed-up in DBRACCUST
IF NOT EXISTS(
	SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
	WHERE custid = @custid
	)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Cust info data of this agent have not been backed-up yet. Auto backup activated.', @ErrCode = 10
	print @ErrMsg
	--select @ErrMsg = ''
	EXEC dbo.DBA_ArchiveAccount4_BackupCustInfoMaster @AccName=@AccName, @ErrMsg = @ErrMsg
	--IF @ErrMsg <> '' return
END


--===============================
--PERFORM DELETE MEMBERS INFO
--===============================

Exec DBA_Archive_Cust_SuperMaster @CustID = @CustID, @stage = 4 
----------------------------------------------------------------
print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

------------------
declare @LogSPData varchar(2000)

Select @LogSPData = '<DBA_ArchiveAccount4_DelCustInfoSuperMaster AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
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