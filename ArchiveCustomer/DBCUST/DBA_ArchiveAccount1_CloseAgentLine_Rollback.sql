/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount1_CloseAgentLine_Rollback]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created by: Daniel
	Date: 2018-02-22
	Task: Archive Acc (New) - sp for ROLLING BACK stage 1 - Open (closed = 0) for the whole agent line 
	DB: DBCUST/CustDB
	
	Revisions:
		20180222@Daniel: Created

*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int, @Now datetime
set @startRun = getdate()

Declare @roleid int, @AgentID int, @closed bit

SELECT @roleid = roleid, @AgentID = custid, @closed = closed
FROM custinfo (nolock)
WHERE username = @AccName

if isnull(@AgentID,0) = 0 or @roleid NOT in (2)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Invalid Agent User Name', @ErrCode = 101
	print @ErrMsg
	return
END

if @closed = 0
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent was NOT closed or was opened BACK already!!', @ErrCode = 102
	print @ErrMsg
	return
END

print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

--================================
--PERFORM OPEN BACK
--================================

DECLARE @batch TABLE(custid INT, closed BIT)

SELECT custid, closed INTO #tmp
FROM DBARCCUST.bodb_Customer.dbo.CustBackupClosed WITH(NOLOCK)
WHERE custid IN (select custid from custinfo with (nolock) WHERE recommend = @AgentID)

WHILE (1 = 1)
BEGIN
	DELETE TOP (1000) #tmp OUTPUT DELETED.custid, DELETED.closed INTO @batch

	IF @@ROWCOUNT = 0 BREAK

	UPDATE ci WITH (ROWLOCK, UPDLOCK)
	SET closed = b.closed
	FROM custinfo ci INNER JOIN @batch b ON ci.custid = b.custid
	
	DELETE FROM @Batch

	WAITFOR DELAY '000:00:00.200'
END

DROP TABLE #tmp



----------------------------------------------------------------
print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

--------------------
declare @LogSPData varchar(2000)

Select @LogSPData = '<DBA_ArchiveAccount1_CloseAgentLine_Rollback AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
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