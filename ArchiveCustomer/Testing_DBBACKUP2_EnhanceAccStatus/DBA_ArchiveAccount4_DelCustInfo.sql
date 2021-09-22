/*<info serverAlias="DBBACKUP2-custDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount4_DelCustInfo]
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
		- 20180320@Daniel: rename SP to count stage from 1 => No. 4 for this stage
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - Delete custinfo for DBPRO - [Redmine:130032]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]

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
	SELECT 1 FROM bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
	WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID)
	)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Cust info data of this agent have not been backed-up yet. Auto backup activated.', @ErrCode = 10
	print @ErrMsg
	--select @ErrMsg = ''
	EXEC dbo.DBA_ArchiveAccount4_BackupCustInfo @AccName=@AccName, @ErrMsg = @ErrMsg
	--IF @ErrMsg <> '' return
END

IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custsub_old WITH(NOLOCK) 
				WHERE	custid = @AgentID
		)
BEGIN
	INSERT INTO bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM	custsub WITH (NOLOCK)
	WHERE	custid = @AgentID
END
--===============================
--PERFORM DELETE MEMBERS INFO
--===============================

DECLARE @CustIDs VARCHAR(MAX) = ''

SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
FROM custinfo with (nolock) where recommend = @AgentID	

--EXEC DBPRO.bodb02.dbo.DBA_ArchiveAccount4_DelCustInfo_ForDBPRO @CustIDs = @CustIDs

Exec Acc_ExecRep_Cust_00 @AgentID = @AgentID, @Type = 2 
----------------------------------------------------------------
print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

------------------
declare @LogSPData varchar(2000)

Select @LogSPData = '<DBA_ArchiveAccount4_DelCustInfo AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = 1500,
	@TrackingValue = @LogSPData	,
	@duration = @duration
    
