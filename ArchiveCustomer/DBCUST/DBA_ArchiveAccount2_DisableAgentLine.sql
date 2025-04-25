/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableAgentLine]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT,
	@srecommend INT = 0 OUTPUT,
	@mrecommend INT = 0 OUTPUT,
	@ReduceCredit MONEY = 0 OUTPUT,
	@ArchivedDate DATE = NULL
AS
/*
	Created: Daniel
	Date: 2018-03-05
	Task: Archive Acc (New) - sp for stage 2 - backup data & disable+clear credit of whole agent line 
	DB: DBCUST/CustDB
	
	Revisions:
		- 20180305@Daniel: clone fro old SP DBA_ArchiveAccount1_DisableAgentLine:
			+ Rename sp for stage No 2- start from 1 instead of 0
			+ support new custinfo columns

		- 20180822: Remove table custVirtuaRate
		- 20190917@Daniel: Remove inactive products - unused custinfo columns (#117439 - P2)
		- 20190929@Daniel: Involve more setting tables
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
		- 20200922@Helen: Remove old table [Redmine:130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20201109@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - Stage 2,3,4 - [Redmine:130032]
		- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20210128@Winfred: Check custinfo and backup agent [RedmineID: #149262]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
		- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
		- 20230620@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #179132]
		- 20231019@Helios: Customer Setting - Remove old Structure un Use [RedmineID: #193083]
		- 20241225@Eden: Archiving for Reward Wallet [RedmineID: #215534]
		- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061]    
		- 20250102@Eden: Archiving direct member [redmine: #215533] 

*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int, @Now datetime
set @startRun = getdate()

Declare @roleid int, @AgentID int, @Enabled bit
DECLARE @ProcessedDate DATETIME

SELECT @roleid = roleid, @AgentID = custid, @Enabled = Enabled, @srecommend = srecommend, @mrecommend = mrecommend--, @ReduceCredit = credit
FROM custinfo (nolock)
WHERE username = @AccName

if isnull(@AgentID,0) = 0 or @roleid NOT in (2)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Invalid Agent User Name', @ErrCode = 101
	print @ErrMsg
	return
END

if @Enabled = 0
BEGIN
	-- agent disabled before but some tables not backup in phase 1 yet
	EXEC dbo.DBA_ArchiveAccount2_BackupAgent @AccName = @AccName
	Select @ErrMsg = @AccName +':'+ 'This agent has been archived!!', @ErrCode = 101
	print @ErrMsg

	SET @ProcessedDate = GETDATE()

	EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
		@CustId = @AgentID,
		@RoleID = 2,
		@StageID = 2,
		@ProcessedDate = @ProcessedDate,
		@ArchivedDate = @ArchivedDate

	return
END


--==Check new created members
IF EXISTS(SELECT 1 FROM customer c WITH (NOLOCK) WHERE recommend = @AgentID AND creatdate >= DATEADD(mm, -4, GETDATE()))
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just created new members while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--==Check the status has changed
IF EXISTS(SELECT 1 FROM CustProductStatus cps WITH (NOLOCK) WHERE cps.CustID = @AgentID AND cps.CloseInfo = 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent has been reopened while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END
--== Check new active trans ==========================
DECLARE @IsActive BIT = 0
EXEC DBTXN.bodb02.dbo.[DBA_ArchiveAccount_CheckActiveSMA] @AccName = @AccName ,@IsActive = @IsActive OUTPUT

IF @IsActive = 1
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--Pre-check: Make sure cust info data not exist in DBRACCUST before backup
IF EXISTS(
	SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) 
	WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID)
	)
OR
	EXISTS(
	SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
	WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID)
	)
BEGIN
	-- agent disabled before but some tables not backup in phase 1 yet
	EXEC dbo.DBA_ArchiveAccount2_BackupAgent @AccName = @AccName
	Select @ErrMsg = @AccName +':'+ 'Backup data of this agent already exist. Please check!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

--BACKUP DATA Agent
EXEC [DBA_ArchiveAccount2_BackupAgent] @AccName = @AccName
--Backup Data Member
EXEC [DBA_ArchiveAccount2_BackupMember]  @AccName = @AccName
-----------------------------------------------------------------------------------------------------------

-- update enable = 0, credit = 0 for whole agent line (use new execRep SP)
--> Insert data for Cust_ArchiveAccount
SET @ProcessedDate = GETDATE()

EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
	@CustId = @AgentID,
	@RoleID = 2,
	@StageID = 2,
	@ProcessedDate = @ProcessedDate,
	@ArchivedDate = @ArchivedDate

SELECT @ReduceCredit = credit FROM custinfo (nolock) WHERE Custid = @AgentID

--Archive
EXEC dbo.[DBA_ArchiveAccount_SMALine] @CustID = @AgentID, @StageID = 2

----------------------------------------------------------------
print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

------------------
declare @LogSPData varchar(2000)

Select @LogSPData = '<DBA_ArchiveAccount2_DisableAgentLine AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @AgentID,
	@ActionID = 1178,
	@TrackingValue = @LogSPData	,
	@duration = @duration

GO