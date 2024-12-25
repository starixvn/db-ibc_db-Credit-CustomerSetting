/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount1_CloseAgentLine]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT,
	@ProcessedDate DATETIME = NULL,
	@ArchivedDate DATE = NULL
AS
    
SET NOCOUNT ON

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
	- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
	- 20230623@Eden: Enhance backup [Redmine: #188850]
	- 20241225@Eden: Archiving for Reward Wallet [RedmineID: #215534]

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

IF EXISTS(select 1 from dbo.customer with (nolock) where recommend = @AgentID AND roleid = 1 AND creatdate >= DATEADD(mm, -3, GETDATE()))
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just created new members while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--== Check new active trans ==========================

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettrans with (nolock) where recommend = @AgentID and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.transfer with (nolock) where recommend = @AgentID AND bettype <> 20000 and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.translog with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransLC with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransRNG with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(
			SELECT 1 
			FROM DBTXN.bodb02.dbo.SabaWalletTicket with (nolock) 
			WHERE recommend = @AgentID 
				and custid <> 0
				AND WinlostDate >= CONVERT(DATE,DATEADD(mm,-2,GETDATE()))
			)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (custid, ErrMsg,roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--backup data for later rollback for this stage

CREATE TABLE #tempbackup(
	[ArchiveDate] DATETIME,
	[custid] INT,
	[credit] MONEY,
	[SuspendInfo] TINYINT,
	[CloseInfo] TINYINT,
	[ClosedReason] TINYINT
)

INSERT INTO #tempbackup(
	[ArchiveDate],
	[custid],
	[credit],
	[SuspendInfo],
	[CloseInfo],
	[ClosedReason]
)
SELECT	
	GetDate(), 
	c.[custid],
	c.[credit],
	cps.SuspendInfo,
	cps.CloseInfo,
	cl.ClosedReason
FROM custinfo c WITH (NOLOCK)
	INNER JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = c.custid
	LEFT JOIN CustLoginInfo cl WITH (NOLOCK) ON cl.CustID = c.custid
WHERE c.custid = @AgentID
UNION ALL
SELECT	
	GetDate(), 
	c.[custid],
	c.[credit],
	cps.SuspendInfo,
	cps.CloseInfo,
	cl.ClosedReason
FROM custinfo c with (nolock)
	INNER JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = c.custid
	LEFT JOIN CustLoginInfo_Member cl WITH (NOLOCK) ON cl.CustID = c.custid
WHERE c.recommend = @AgentID AND roleid = 1

DELETE t 
FROM #tempbackup t 
WHERE EXISTS (SELECT TOP 1 1 FROM DBARCCUST.bodb_Customer.dbo.CustBackupClosed WITH (NOLOCK) WHERE custid = t.custid)

--insert backup
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBackupClosed(
	[ArchiveDate],
	[custid],
	[credit],
	[SuspendInfo],
	[CloseInfo],
	[ClosedReason]
)
SELECT	
	[ArchiveDate],
	[custid],
	[credit],
	[SuspendInfo],
	[CloseInfo],
	[ClosedReason]
FROM #tempbackup

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

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = @ActionID,
	@TrackingValue = @LogSPData,
	@TrackingValue2 = @LogSPDataOld,
	@duration = @duration

DROP TABLE #tempbackup

GO

