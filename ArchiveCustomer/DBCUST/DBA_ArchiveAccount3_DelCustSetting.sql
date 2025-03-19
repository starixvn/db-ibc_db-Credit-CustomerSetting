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
		20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]

*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @roleid int, @AgentID int, @Enabled BIT, @CountDownline INT , @AutobackUp_Activated BIT = 0

SELECT @roleid = roleid, @AgentID = custid, @Enabled = Enabled
FROM custinfo (nolock)
WHERE username = @AccName

SELECT @CountDownline = (SELECT COUNT(1) FROM custInfo i WITH (NOLOCK) WHERE i.recommend = @AgentId AND i.roleid = 1)

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

IF	   NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.BetSetting_Agent_old WITH(NOLOCK) WHERE custid = @AgentID)
BEGIN
	SET @AutobackUp_Activated = 1
END

IF	   @CountDownline > 0
	AND NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.BetSetting_Member_old WITH(NOLOCK) WHERE custid IN (SELECT CustID FROM custInfo i WITH (NOLOCK) WHERE i.recommend = @AgentID))
BEGIN
	SET @AutobackUp_Activated = 1
END

IF @AutobackUp_Activated = 1
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Cust setting data of this agent have not been backed-up yet. Auto backup activated', @ErrCode = 10
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg, Roleid) VALUES(@AgentID,@ErrMsg, 2) 
	print @ErrMsg
	select @ErrMsg = ''
	EXEC dbo.DBA_ArchiveAccount3_BackupCustSetting @AccName=@AccName, @ErrMsg = @ErrMsg
	IF @ErrMsg <> '' return
END


--===============================
--PERFORM DELETE MEMBERS SETTINGS
--===============================

----just keep code 8 table Balance
--Exec Acc_ExecRep_Cust_00 @AgentID = @AgentID, @Type = 1 

--For archive Acc (New) - update/delete part in stage 1,2,3 
Exec Acc_ExecRep_Cust_03 @AgentID = @AgentID, @Type = 1 
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