/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_BackupCustSetting]
	@AccName varchar(50),
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created by: Daniel
	Date: 2016-04-12
	Task: backup data  of whole agent line 
	DB: DBCUST/CustDB
	
	Revisions:
		20180320@Daniel: rename SP to count stage from 1 => No. 3 for this stage
		20180520@Daniel: Remove table custVirtualRate
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

IF EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
	)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'Backup data - Virtual Settings of this agent already exist.', @ErrCode = 101
	--INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
	print @ErrMsg
	SELECT @ErrMsg = '' 
	--RETURN
	EXEC DBARCCUST.bodb_Customer.dbo.DBA_ArchiveAccount2_BackupCustSetting_DelVR @AgentID
	--DELETE FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
END

print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

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
where	custid IN (	select custid from custinfo with (nolock) where roleid = 1 and recommend = @AgentID)

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
from	custSetting (nolock) 
where	custid IN (	select custid from custinfo with (nolock) where roleid = 1 and recommend = @AgentID)

--Copy custSetting3rd data to bodb_Customer 
insert into DBARCCUST.bodb_Customer.dbo.custSetting3rd_old(
	 [custid]
	,[bettype]
	,[sporttype]
	,[apositiontaking]
	,[mpositiontaking]
	,[spositiontaking]
	,[playerdiscount]
	,[discount]
	,[adiscount]
	,[sdiscount]
	,[minbet]
	,[maxbet]
	,[autopositiontaking]
	,[isautopositiontaking]
	,[autompositiontaking]
	,[isautompositiontaking]
	,[alivepositiontaking]
      ,[mlivepositiontaking]
      ,[slivepositiontaking]
      ,[autolivepositiontaking]
      ,[isautolivepositiontaking]
      ,[autolivempositiontaking]
      ,[isautolivempositiontaking]
) 
SELECT	[custid]
	   ,[bettype]
	   ,[sporttype]
	   ,[apositiontaking]
	   ,[mpositiontaking]
	   ,[spositiontaking]
	   ,[playerdiscount]
	   ,[discount]
	   ,[adiscount]
	   ,[sdiscount]
	   ,[minbet]
	   ,[maxbet]
	   ,[autopositiontaking]
	   ,[isautopositiontaking]
	   ,[autompositiontaking]
	   ,[isautompositiontaking]
	   ,[alivepositiontaking]
      ,[mlivepositiontaking]
      ,[slivepositiontaking]
      ,[autolivepositiontaking]
      ,[isautolivepositiontaking]
      ,[autolivempositiontaking]
      ,[isautolivempositiontaking]
FROM	CustSetting3rd WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)		

--- copy DBTRANS.BODB02.dbo.CustSettingGame data to DB05.bodb_Customer.dbo.CustSettingGame_Old
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustSettingGame_Old(
			CustID
			,Bettype
			,Sporttype
			,apositiontaking
			,mpositiontaking
			,spositiontaking
			,playerdiscount
			,discount
			,adiscount
			,sdiscount
			,autopositiontaking
			,isautopositiontaking
			,autompositiontaking
			,isautompositiontaking)
SELECT CustID
		,Bettype
		,Sporttype
		,apositiontaking
		,mpositiontaking
		,spositiontaking
		,playerdiscount
		,discount
		,adiscount
		,sdiscount
		,autopositiontaking
		,isautopositiontaking
		,autompositiontaking
		,isautompositiontaking
FROM [dbo].[CustSettingGame] WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)

--- copy DBTRANS.BODB02.dbo.CustGameType data to DB05.bodb_Customer.dbo.CustGameType_Old
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
SELECT CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
FROM [dbo].CustGameType WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)

--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
SELECT custid, seqNo, bitmapVirtual
FROM [dbo].CustVirtualSetting WITH(NOLOCK)
WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)


--------- Involve more tables (new tables/DCS)

insert into DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Member_old(
	CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
) 
SELECT	CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
FROM	CustBetSetting3rd_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)		

insert into DBARCCUST.bodb_Customer.dbo.CustCommRate_old(
	CustID, SportType, BetType, sdiscount, adiscount, discount, playerdiscount
) 
SELECT	CustID, SportType, BetType, sdiscount, adiscount, discount, playerdiscount
FROM	CustCommRate WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

insert into DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Member_old(
	CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
) 
SELECT	CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
FROM	CustDiscount3rd_Member WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)	

insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo
) 
SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo
FROM	CustProductStatus WITH (NOLOCK)
WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)

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

-----------------------------------------------------------------------------------------------------------


print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)