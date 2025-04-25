/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_DelCustInfo]
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
		- 20240905@Eden : Scale out DBCUST - Delete data custinfomini [redmine: #210077]
		- 20241007@Helios : Scale out DBCUST - Delete data custinfomini - remove call link Server DBGLOB [redmine: #210077]
		- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]
		- 20250102@Eden: Archiving direct member [redmine: #215533] 
*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @roleid int, @AgentID int

SELECT @roleid = roleid, @AgentID = custid
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
IF	   NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE custid = @AgentID)
	OR NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE custid = @AgentID)
BEGIN
	PRINT @AccName +':'+ 'Cust info data of this Agent have not been backed-up yet. Auto backup activated.'
	--BACKUP DATA Agent
	EXEC [DBA_ArchiveAccount2_BackupAgent] @AccName = @AccName
	--Backup Data Member
	EXEC [DBA_ArchiveAccount2_BackupMember]  @AccName = @AccName
END
--===============================
--PERFORM DELETE MEMBERS INFO
--===============================

DECLARE @CustIDs VARCHAR(MAX) = ''

SELECT @CustIDs = @CustIDs + cast(custid AS VARCHAR(10)) + ','
FROM custinfo with (nolock) where recommend = @AgentID	

--just keep code 8 table Balance
Exec Acc_ExecRep_Cust_00 @CustIDs = @CustIDs

--For archive Acc (New) - update/delete part in stage 1,2,3 
EXEC dbo.[DBA_ArchiveAccount_SMALine] @CustID = @AgentID, @StageID = 4

--Delete custinfomini
EXEC DBGLOB.GlobCustDB.dbo.[DBA_ArchiveAccount4_DelCustInfoMini] @CustIDs = @CustIDs
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

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = 1500,
	@TrackingValue = @LogSPData	,
	@duration = @duration