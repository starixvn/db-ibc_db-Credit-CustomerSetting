/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount1_CloseAgentLine]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT,
	@ProcessedDate DATETIME = NULL,
	@ArchivedDate DATE = NULL
AS
    
SET NOCOUNT ON

-- simulate run date based on test data version
declare @currentDate smalldatetime 
select @currentDate = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_TestDate'

/*Description: Close an Agent
Create date: 20180126
Original SP: 
DB: DBCUST/CustDB
Revisions:    
	- 20180126@Daniel: cloned from DBA_ArchiveAccount0_CloseAgent & change:
	  + add close all downline members (use execRep)
	- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]  
	- 20200911@Helen: Fix stage 1 - M0 - [Redmine:130032]  
	- 20210203@Eden: NAP/Alpha & EXT - Mark ClosedReason = 4 for satisfied archiving accounts of stage 1 [RedmineID: #149450]
	- 20210524@Tina: Lock account & indirect close account [redmine: #148600]

*/

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @roleid int, @AgentID int, @Closed bit, @ClosedReason tinyint

SELECT @roleid = roleid, @AgentID = custid
FROM custinfo (nolock)
WHERE username = @AccName

SELECT @Closed = CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END
FROM CustProductStatus cps WITH (NOLOCK)
WHERE cps.CustID = @AgentID

if isnull(@AgentID,0) = 0 or @roleid NOT in (2)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Invalid Agent User Name', @ErrCode = 101
	print @ErrMsg
	return
END

SELECT @ClosedReason = ClosedReason FROM CustLoginInfo l WITH(NOLOCK) WHERE custid = @AgentID

if @Closed = 1 AND @ClosedReason = 4
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent has been archived!!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 	
	print @ErrMsg

	EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
		@CustId = @AgentID,
		@RoleID = 2,
		@StageID = 1,
		@ProcessedDate = @ProcessedDate,
		@ArchivedDate = @ArchivedDate

	return
END

--== Check new created members ==========================

IF EXISTS(select 1 from dbo.customer with (nolock) where recommend = @AgentID AND roleid = 1 AND creatdate >= DATEADD(mm, -3, @currentDate))
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just created new members while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--== Check new active trans ==========================

IF EXISTS(select 1 from bodb02.dbo.bettrans with (nolock) where recommend = @AgentID AND bettype <> 20000 and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from bodb02.dbo.translog with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from bodb02.dbo.bettransLC with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from bodb02.dbo.bettransRNG with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END


--backup data for later rollback for this stage
insert into bodb_Customer.dbo.CustBackupClosed(
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
	@currentdate, 
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
WHERE c.custid = @AgentID
	AND NOT EXISTS (SELECT TOP 1 1 FROM bodb_Customer.dbo.CustBackupClosed WITH (NOLOCK) WHERE custid = c.custid)
--insert for member
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
	@currentdate, 
	c.[custid],
	c.[closed],
	c.[reject],
	c.[credit],
	cps.SuspendInfo,
	cps.CloseInfo,
	cl.ClosedReason
FROM custinfo c with (nolock)
	INNER JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = c.custid
	LEFT JOIN CustLoginInfo_Member cl WITH (NOLOCK) ON cl.CustID = c.custid
WHERE c.recommend = @AgentID AND roleid = 1
	AND NOT EXISTS (SELECT TOP 1 1 FROM bodb_Customer.dbo.CustBackupClosed WITH (NOLOCK) WHERE custid = c.custid)



--close whole line using ExecRep
EXEC dbo.Acc_ExecRep_Cust_00 @AgentID = @AgentID, @Type = -1

--> Insert data for Cust_ArchiveAccount
DECLARE @IsOverwrite BIT

IF @Closed = 0
	SET @IsOverwrite = 1
ELSE 
	SET @IsOverwrite = 0

EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
	@CustId = @AgentID,
	@RoleID = 2,
	@StageID = 1,
	@ProcessedDate = @ProcessedDate,
	@ArchivedDate = @ArchivedDate,
	@IsOverwrite = @IsOverwrite

------------------
declare @LogSPData varchar(5000), @LogSPDataOld varchar(5000), @ActionID INT 

IF  @Closed = 1
BEGIN
	SET @ActionID = 1179 -- only change reason

	Select @LogSPDataOld = '<DBA_ArchiveAccount1_CloseAgentLine ' +
	'Reason="'+ coalesce(cast(@ClosedReason as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'

	Select @LogSPData = '<DBA_ArchiveAccount1_CloseAgentLine ' +
	'Reason="4" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'
END
ELSE
BEGIN
	SET @ActionID = 1115

	Select @LogSPData = '<DBA_ArchiveAccount1_CloseAgentLine AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" />'
END

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = @ActionID,
	@TrackingValue = @LogSPData,
	@TrackingValue2 = @LogSPDataOld,
	@duration = @duration

GO
