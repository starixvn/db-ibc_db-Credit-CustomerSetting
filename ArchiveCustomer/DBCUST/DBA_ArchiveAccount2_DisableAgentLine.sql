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
		- 20240614@Johnson: Scale out DBCUST [redmine: #199915]
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

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettrans with (nolock) where recommend = @AgentID and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.transfer with (nolock) where recommend = @AgentID AND bettype <> 20000 and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.translog with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransLC with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransRNG with (nolock) where recommend = @AgentID)
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
BEGIN
	-- agent disabled before but some tables not backup in phase 1 yet
	EXEC dbo.DBA_ArchiveAccount2_BackupAgent @AccName = @AccName
	Select @ErrMsg = @AccName +':'+ 'Backup data of this agent already exist. Please check!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID,@ErrMsg,2) 
	print @ErrMsg
	return
END

--Pre-check: Make sure cust info data not exist in DBRACCUST before backup
IF EXISTS(
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

--IF EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
--	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
--	)
--BEGIN
--	Select @ErrMsg = @AccName +':'+ 'Backup data - Virtual Settings of this agent already exist.', @ErrCode = 101
--	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
--	print @ErrMsg
--	RETURN
--	DELETE FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
--END

print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

--=============================
--PERFORM BACKUP DATA MEMBERS
--=============================

select @Now = current_timestamp

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
                      VirtualMultiplier, 0, 0, 0, 0, 0, 0, 0, 0, 
                      0, Enabled, danger, 0, 0, danger2, 
                      danger3, DisableOutright, 0, 0, 0, 
                      0,
                      Abnormal, DoubleCommLosing,
                      autosuspend2, 0, DisableEsports, 0, 0,  
                      DisableSuperLive, 1,1, 
                      LockUpd, 0, BonusWalletFlag
from	custinfo (nolock)
where	custid IN (	select custid from custinfo with (nolock) where recommend = @AgentID)

--Copy custSetting data to bodb_Customer before delete
insert into DBARCCUST.bodb_Customer.dbo.custSetting_old(
	custid, 
	bettype, 
	sporttype, 
	apositiontaking, 
	mpositiontaking, 
	spositiontaking, 
	alivepositiontaking, 
	mlivepositiontaking, 
	slivepositiontaking,
	playerdiscount, 
	discount, 
	adiscount, 
	sdiscount, 
	groupa, 
	groupb, 
	groupc, 
	groupd, 
	groupe, 
	groupf, 
	minbet, 
	maxbet, 
	autopositiontaking,
	autolivepositiontaking, 
	isautopositiontaking, 
	isautolivepositiontaking, 
	autompositiontaking, 
	autolivempositiontaking, 
	isautompositiontaking,
	isautolivempositiontaking 
)
select 	custid, 
		bettype, 
		sporttype, 
		apositiontaking, 
		mpositiontaking, 
		spositiontaking, 
		alivepositiontaking, 
		mlivepositiontaking, 
		slivepositiontaking,
		playerdiscount, 
		discount, 
		adiscount, 
		sdiscount, 
		groupa, 
		groupb, 
		groupc, 
		groupd, 
		groupe, 
		groupf, 
		0, 
		0, 
		autopositiontaking,
		autolivepositiontaking, 
		isautopositiontaking, 
		isautolivepositiontaking, 
		autompositiontaking, 
		autolivempositiontaking, 
		isautompositiontaking,
		isautolivempositiontaking  
from	custSetting (nolock) 
where	custid IN (	select custid from custinfo with (nolock) where recommend = @AgentID)

--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID)
	)
BEGIN
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID )
END	


--------- Involve more tables (new tables/DCS)

insert into DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Member_old(
	CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
) 
SELECT	CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
FROM	CustBetSetting3rd_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)			

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Member_old(
	CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
) 
SELECT	CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
FROM	CustDiscount3rd_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)	

insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
) 
SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
FROM	CustProductStatus WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Member_old(
	 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
) 
SELECT	 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
FROM	CustPTSetting3rd_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustSettingMode3rd_old(
	 CustID, IsGrouped
) 
SELECT	 CustID, IsGrouped
FROM	CustSettingMode3rd WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Member_old(
	 CustID, SportType, BetType, StakeLevelList, LastUpdated
) 
SELECT	CustID, SportType, BetType, StakeLevelList, LastUpdated
FROM	CustStakeLevel_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfo_Member_old(
	 CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
     ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
) 
SELECT CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
     ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
FROM	CustLoginInfo_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Member_old(
	CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
) 
SELECT CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
FROM	CustWinLossLimit_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

INSERT INTO DBARCCUST.bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
FROM	custsub WITH (NOLOCK)
WHERE	custid = @AgentID

--> MORE TABLES
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Agent_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch)
SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch
FROM CustBetSetting3rd_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old(CustID,SportType,BetType,Discount)
SELECT CustID,SportType,BetType,Discount
FROM CustDiscount3rd_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.custOverride_old(custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking)
SELECT custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking
FROM custOverride WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Agent_old(CustID,SportType,BetType,IsLive,IsAutoMasterPT,IsAutoSuperPT
	,SuperPT,MasterPT,AgentPT,AutoSuperPT,AutoMasterPT,MinPT,MaxPT)
SELECT CustID,SportType,BetType,IsLive,IsAutoMasterPT,IsAutoSuperPT
	,SuperPT,MasterPT,AgentPT,AutoSuperPT,AutoMasterPT,MinPT,MaxPT
FROM CustPTSetting3rd_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Agent_old(CustID,SportType,BetType,StakeLevelList)
SELECT CustID,SportType,BetType,StakeLevelList
FROM CustStakeLevel_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Agent_old(CustId,SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
SELECT CustId,SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset
FROM CustWinLossLimit_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.AgentCommRate_old(CustId,Sporttype,Bettype,CommRate)
SELECT CustId,Sporttype,Bettype,CommRate
FROM AgentCommRate WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBetSetting_Agent_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch
FROM CustBetSetting_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting_Agent_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch
FROM BetSetting_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTGroupSetting3rd_Member_old(AgentID,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT
	,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT)
SELECT AgentID,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT
	,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT
FROM CustPTGroupSetting3rd_Member WITH(NOLOCK)
WHERE AgentID = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustAgent_old(custid,MaxCredit,IsInternal,TransferOption,LimitPerIP,SelectedBetting
	,NicknameLoginOnly,site,creationRemark,IsMonitorPT)
SELECT custid,MaxCredit,IsInternal,TransferOption,LimitPerIP,SelectedBetting
	,NicknameLoginOnly,site,creationRemark,IsMonitorPT
FROM CustAgent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustLoginInfo_old(CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin,SecurityCode,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode
	,VerifyOTPCount,ClosedReason,FunctionInfo,ProtectionCode,IsProtectedMode)
SELECT CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin,SecurityCode,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode
,VerifyOTPCount,ClosedReason,FunctionInfo,ProtectionCode,IsProtectedMode
FROM CustLoginInfo WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustLoginInfoSub_old(SubAccID,CustID,OldUserPwd,PwdExpiry,LastChangedPwdDate,isFirstLogin,SecurityCode
	,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode,VerifyOTPCount,FunctionInfo,ProtectionCode)
SELECT SubAccID,CustID,OldUserPwd,PwdExpiry,LastChangedPwdDate,isFirstLogin,SecurityCode
	,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode,VerifyOTPCount,FunctionInfo,ProtectionCode
FROM CustLoginInfoSub WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustCommRate_old(CustId,Sporttype,Bettype,sdiscount,adiscount,discount,playerdiscount)
SELECT CustId,Sporttype,Bettype,sdiscount,adiscount,discount,playerdiscount
FROM CustCommRate WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBetSetting_Member_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch
FROM CustBetSetting_Member WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting_Member_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch
FROM BetSetting_Member WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

--#188850
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustMaxPayoutSetting_Member_old(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
SELECT CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
FROM CustMaxPayoutSetting_Member WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustMaxPayoutSetting_Agent_old(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
SELECT CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
FROM CustMaxPayoutSetting_Agent WITH(NOLOCK)
WHERE custid = @AgentID

INSERT INTO DBARCCUST.bodb_Customer.dbo.CustProfilePicture_old(CustId,ImageId,Modified)
SELECT CustId,ImageId,Modified
FROM bodb_Credit.dbo.CustProfilePicture WITH(NOLOCK)
WHERE custid = @AgentID
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

Exec Acc_ExecRep_Cust_00 @AgentID = @AgentID, @Type = 0

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