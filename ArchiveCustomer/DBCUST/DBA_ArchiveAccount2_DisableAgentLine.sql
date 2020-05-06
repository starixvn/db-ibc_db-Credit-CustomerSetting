/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableAgentLine]
	@AccName varchar(50),
	@UserID int = 360418,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
	Created: Daniel
	Date: 2018-03-05
	Task: Archive Acc (New) - sp for stage 2 - backup data & disable+clear credit of whole agent line 
	DB: DBCUST/CustDB
	
	Revisions:
		20180305@Daniel: clone fro old SP DBA_ArchiveAccount1_DisableAgentLine:
		 + Rename sp for stage No 2- start from 1 instead of 0
		 + support new custinfo columns

		20180822: Remove table custVirtuaRate
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

if @Enabled = 0
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent has been archived!!', @ErrCode = 101
	print @ErrMsg
	return
END


--==Check new created members
IF EXISTS(SELECT 1 FROM customer c WITH (NOLOCK) WHERE recommend = @AgentID AND creatdate >= DATEADD(mm, -4, GETDATE()))
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just created new members while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID,@ErrMsg) 
	print @ErrMsg
	return
END

--== Check new active trans ==========================

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettrans with (nolock) where recommend = @AgentID AND bettype <> 20000 and custid <> 0)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.translog with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransLC with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
	print @ErrMsg
	return
END

IF EXISTS(select 1 from DBTXN.bodb02.dbo.bettransRNG with (nolock) where recommend = @AgentID)
BEGIN
	Select @ErrMsg = @AccName +':'+ 'This agent just got active trans while processing!', @ErrCode = 101
	INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
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
IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
	)
BEGIN
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
END	


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

-- update enable = 0, credit = 0 for whole agent line (use new execRep SP)
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
	@ActionID = 1500,
	@TrackingValue = @LogSPData	,
	@duration = @duration