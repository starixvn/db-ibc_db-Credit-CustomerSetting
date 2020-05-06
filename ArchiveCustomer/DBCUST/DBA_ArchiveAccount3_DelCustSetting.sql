/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_DelCustSetting]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created by: Daniel
	Date: 2016-02-18
	Original: DBA_ArchiveAccount1_UpdateMove (keep code del setting only)
	Task: Delete custsetting data 
	DB: DBCUST/CustDB
	
	Revisions:
		20180320@Daniel: rename SP to count stage from 1 => No. 3 for this stage

*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @roleid int, @AgentID int, @Enabled bit

SELECT @roleid = roleid, @AgentID = custid, @Enabled = Enabled
FROM custinfo (nolock)
WHERE username = @AccName

if isnull(@AgentID,0) = 0 or @roleid NOT in (2)
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
	SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custsetting_old WITH(NOLOCK) 
	WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID AND roleid = 1)
	)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Cust setting data of this agent have not been backed-up yet. Auto backup activated', @ErrCode = 10
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID,@ErrMsg) 
	print @ErrMsg
	select @ErrMsg = ''
	EXEC dbo.DBA_ArchiveAccount3_BackupCustSetting @AccName=@AccName, @ErrMsg = @ErrMsg
	IF @ErrMsg <> '' return
END


--===============================
--PERFORM DELETE MEMBERS SETTINGS
--===============================

Exec Acc_ExecRep_Cust_00 @AgentID = @AgentID, @Type = 1 
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

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = 1500,
	@TrackingValue = @LogSPData	,
	@duration = @duration