/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_BackupCustInfo]
	@AccName varchar(50),
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created by: Daniel
	Date: 2016-04-26
	Task: backup customer, custinfo data  of whole agent line 
	DB: DBCUST/CustDB

	Revisions:
		20180320@Daniel: 
			+rename SP to count stage from 1 => No. 4 for this stage
			+support more columns custinfo
		20190917@Daniel: Remove inactive products - unused custinfo columns (#117439 - P2)
		20190929@Daniel: Involve more setting tables

*/
    
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int, @Now datetime
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

--Pre-check: Make sure cust info data not exist in DBRACCUST before backup
IF EXISTS(
	SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) 
	WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID AND roleid = 1)
	)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Backup data of this agent already exist. Please check!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
	print @ErrMsg
	return
END

print  @AccName +':'+ 'START backup cust info data:' + convert(varchar(50), getdate(), 113)

--=============================
--PERFORM BACKUP DATA MEMBERS
--=============================

--Copy members'info to bodb_Customer 
insert into DBARCCUST.bodb_Customer.dbo.customer_old(
	   [custid],[firstname],[lastname],[address] ,[postal],[city]
      ,[state] ,[country]  ,[phone]   ,[mobilephone] ,[fax]
      ,[email] ,[birthday] ,[refcode1],[refcode2],[remark]
      ,[creatdate],[creator],[username],[currency],[userpwd]
      ,[lastlogged],[pwdexpiry],[roleid],[mrecommend],[recommend]
      ,[ugroup],[logincount],[on_sessionid],[site],[iplogin]
      ,[important],[srecommend],[username2]
)
select [custid],[firstname],[lastname],[address] ,[postal],[city]
      ,[state] ,[country]  ,[phone]   ,[mobilephone] ,[fax]
      ,[email] ,[birthday] ,[refcode1],[refcode2],[remark]
      ,[creatdate],[creator],[username],[currency],[userpwd]
      ,[lastlogged],[pwdexpiry],[roleid],[mrecommend],[recommend]
      ,[ugroup],[logincount],[on_sessionid],[site],[iplogin]
      ,[important],[srecommend],[username2]
from	customer (nolock)
where	custid IN (	select custid from custinfo with (nolock) where recommend = @AgentID)

--Copy agent+members' custinfo to bodb_Customer 
insert into DBARCCUST.bodb_Customer.dbo.custinfo_old(
	   [ArchiveDate],
		username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, 
                      VirtualMultiplier, maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11, maxpermatch12, 
                      maxpermatch99, Enabled, danger, DisableCasino, SyncCasino, danger2, 
                      danger3, DisableOutright, MaxPerMatch99MP, DisableNumber, maxpermatch161,  
                      MaxPerBall161,
                      Abnormal, DoubleCommLosing, 
                      autosuspend2, HideKeno, DisableEsports, HideGoldDeluxe, DisableGoldDeluxe,  
                      DisableSuperLive, DisableColossusBet, HideColossusBet,  
                      LockUpd, MaxPerMatch1MP, BonusWalletFlag
)
select	@Now, 
		username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, 
                      VirtualMultiplier, maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11, maxpermatch12, 
                      maxpermatch99, Enabled, danger, DisableCasino, SyncCasino, danger2, 
                      danger3, DisableOutright, MaxPerMatch99MP, DisableNumber, maxpermatch161, 
                      MaxPerBall161,
                      Abnormal, DoubleCommLosing,
                      autosuspend2, HideKeno, DisableEsports, HideGoldDeluxe, DisableGoldDeluxe,  
                      DisableSuperLive, DisableColossusBet, HideColossusBet, 
                      LockUpd, MaxPerMatch1MP, BonusWalletFlag 
from	custinfo (nolock)
where	custid IN (	select custid from custinfo with (nolock) where recommend = @AgentID)


--------- Involve more tables (new tables/DCS)

insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfo_Member_old(
	 CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
     ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
) 
SELECT CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
     ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
FROM	CustLoginInfo_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)


print  @AccName +':'+ 'END Backup cust info:' + convert(varchar(50), getdate(), 113) 