/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount3_BackupCustSetting]
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
		20200922@Helen: Remove old table [Redmine:130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]

*/
BEGIN    
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
		SELECT 1 FROM bodb_Customer.dbo.customer_old WITH(NOLOCK) 
		WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID)
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Backup data of this agent already exist. Please check!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID, @ErrMsg, 2) 
		print @ErrMsg
		return
	END

	IF EXISTS(SELECT 1 FROM bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID)
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Backup data - Virtual Settings of this agent already exist.', @ErrCode = 101
		--INSERT INTO [dbo].[CustArc_NewActive] (AgentID, ErrMsg) VALUES(@AgentID, @ErrMsg) 
		print @ErrMsg
		SELECT @ErrMsg = '' 
		--RETURN
		EXEC bodb_Customer.dbo.DBA_ArchiveAccount2_BackupCustSetting_DelVR @AgentID
		--DELETE FROM bodb_Customer.dbo.CustVirtualSetting_Old WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
	END

	print  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--=============================
	--PERFORM BACKUP DATA MEMBERS
	--=============================

	--Copy members'info to bodb_Customer 
	insert into bodb_Customer.dbo.customer_old(
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
	where	recommend = @AgentID

	--Copy agent+members' custinfo to bodb_Customer 
	insert into bodb_Customer.dbo.custinfo_old(
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
	where	recommend = @AgentID

	--Copy custSetting data to bodb_Customer before delete
	insert into bodb_Customer.dbo.custSetting_old(
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
	select 	cs.custid, 
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
	from	custSetting cs WITH(nolock) 
		INNER JOIN  custinfo ci with (nolock) ON ci.custid = cs.custID 
	where	ci.recommend = @AgentID

	--Copy custSetting3rd data to bodb_Customer 
	insert into bodb_Customer.dbo.custSetting3rd_old(
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
	SELECT	cs.[custid]
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
	FROM	CustSetting3rd cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID		

	--- copy DBTRANS.BODB02.dbo.CustSettingGame data to DB05.bodb_Customer.dbo.CustSettingGame_Old
	INSERT INTO bodb_Customer.dbo.CustSettingGame_Old(
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
	SELECT cs.CustID
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
	FROM [dbo].[CustSettingGame] cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	--- copy DBTRANS.BODB02.dbo.CustGameType data to DB05.bodb_Customer.dbo.CustGameType_Old
	INSERT INTO bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
	SELECT cs.CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
	FROM [dbo].CustGameType cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	INSERT INTO bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT cs.custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	


	--------- Involve more tables (new tables/DCS)

	insert into bodb_Customer.dbo.CustBetSetting3rd_Member_old(
		CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
	) 
	SELECT	cs.CustID, SportType, BetType, MinBet, MaxBet, cs.MaxPerMatch
	FROM	CustBetSetting3rd_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID		

--insert into bodb_Customer.dbo.CustCommRate_old(
--	CustID, SportType, BetType, sdiscount, adiscount, discount, playerdiscount
--) 
--SELECT	CustID, SportType, BetType, sdiscount, adiscount, discount, playerdiscount
--FROM	CustCommRate WITH (NOLOCK)
--WHERE	custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE roleid = 1 and recommend = @AgentID)
--	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustDiscount3rd_Member_old(
		CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	) 
	SELECT	cs.CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	FROM	CustDiscount3rd_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustProductStatus_old(
		 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	) 
	SELECT	 cs.CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	FROM	CustProductStatus cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustPTSetting3rd_Member_old(
		 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	) 
	SELECT	 cs.CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	FROM	CustPTSetting3rd_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustSettingMode3rd_old(
		 CustID, IsGrouped
	) 
	SELECT	 cs.CustID, IsGrouped
	FROM	CustSettingMode3rd cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustStakeLevel_Member_old(
		 CustID, SportType, BetType, StakeLevelList, LastUpdated
	) 
	SELECT	cs.CustID, SportType, BetType, StakeLevelList, LastUpdated
	FROM	CustStakeLevel_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustLoginInfo_Member_old(
		 CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	) 
	SELECT cs.CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	FROM	CustLoginInfo_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into bodb_Customer.dbo.CustWinLossLimit_Member_old(
		CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	) 
	SELECT cs.CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	FROM	CustWinLossLimit_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	------- custSub -------------------------------
	INSERT INTO bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM	custsub WITH (NOLOCK)
	WHERE	custid = @AgentID
	
	-----------------------------------------------------------------------------------------------------------


	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)
END	
    
