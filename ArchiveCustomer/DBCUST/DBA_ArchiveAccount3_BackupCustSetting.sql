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
		20200922@Helen: Remove old table [Redmine:130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
		- 20230620@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #179132]
		- 20231019@Helios: Customer Setting - Remove old Structure un Use [RedmineID: #193083]
		- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061] 

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
		SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) 
		WHERE custid IN(select custid from custinfo with (nolock) WHERE recommend = @AgentID)
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Backup data of this agent already exist. Please check!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@AgentID, @ErrMsg, 2) 
		print @ErrMsg
		return
	END

	IF EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE recommend = @AgentID)
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
	where	recommend = @AgentID

	--Copy agent+members' custinfo to bodb_Customer 
	insert into DBARCCUST.bodb_Customer.dbo.custinfo_old(
		   [ArchiveDate],
			username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, 
                      VirtualMultiplier, maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11, maxpermatch12, 
                      maxpermatch99, Enabled, danger, DisableCasino, SyncCasino, danger2, 
                      danger3, DisableOutright, MaxPerMatch99MP, DisableNumber, maxpermatch161, 
                      MaxPerBall161,
                      Abnormal, DoubleCommLosing,
                      autosuspend2, HideKeno, HideGoldDeluxe, DisableGoldDeluxe,  
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
                      autosuspend2, 0, 0, 0,  
                      DisableSuperLive, 1,1, 
                      LockUpd, 0, BonusWalletFlag
	from	custinfo (nolock)
	where	recommend = @AgentID

	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT cs.custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	


	--------- Involve more tables (new tables/DCS)
	insert into DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Member_old(
		CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	) 
	SELECT	cs.CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	FROM	CustDiscount3rd_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
		 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	) 
	SELECT	 cs.CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	FROM	CustProductStatus cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Member_old(
		 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	) 
	SELECT	 cs.CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	FROM	CustPTSetting3rd_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustSettingMode3rd_old(
		 CustID, IsGrouped
	) 
	SELECT	 cs.CustID, IsGrouped
	FROM	CustSettingMode3rd cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Member_old(
		 CustID, SportType, BetType, StakeLevelList, LastUpdated
	) 
	SELECT	cs.CustID, SportType, BetType, StakeLevelList, LastUpdated
	FROM	CustStakeLevel_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfo_Member_old(
		 CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	) 
	SELECT cs.CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	FROM	CustLoginInfo_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	insert into DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Member_old(
		CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	) 
	SELECT cs.CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	FROM	CustWinLossLimit_Member cs WITH(NOLOCK) 
		INNER JOIN  custinfo ci WITH (NOLOCK) ON ci.custid = cs.custID 
	WHERE	ci.recommend = @AgentID	

	------- custSub -------------------------------
	INSERT INTO DBARCCUST.bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM	custsub WITH (NOLOCK)
	WHERE	custid = @AgentID

	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old(CustID,SportType,BetType,Discount)
	SELECT CustID,SportType,BetType,Discount
	FROM CustDiscount3rd_Agent WITH(NOLOCK)
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
	FROM dbo.CustProfilePicture WITH(NOLOCK)
	WHERE custid = @AgentID
	
	--#201061
	--Agent & Downline
	INSERT INTO DBARCCUST.bodb_Customer.dbo.BetLimitControlCustSetting_old
	(
		CustID
		, BetLimitTypeID
		, MaxBet
		, MaxPerMatch
		, Mode
	)
	SELECT CustID
		, BetLimitTypeID
		, MaxBet
		, MaxPerMatch
		, Mode
	FROM dbo.BetLimitControlCustSetting WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE recommend = @AgentID)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRCustLockStatus_old (CustID, Type)
	SELECT CustID, Type
	FROM dbo.VRCustLockStatus WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE recommend = @AgentID)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRCustSetting_old
	(
		CustID
		, LevelID
		, ValueIDLIVE
		, ValueIDNonLIVE
	)
	SELECT CustID
		, LevelID
		, ValueIDLIVE
		, ValueIDNonLIVE
	FROM dbo.VRCustSetting WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE recommend = @AgentID)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRSettingManualUpdAcc_old	(SportType , CustID)
	SELECT SportType , CustID
	FROM dbo.VRSettingManualUpdAcc WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custInfo WITH (NOLOCK) WHERE recommend = @AgentID)

	-- Agent
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTTemplate_old
	(
		TemplateID
	    , custid
	    , TemplateName
	    , IsDefault
	)
	SELECT TemplateID
	    , custid
	    , TemplateName
	    , IsDefault
	FROM dbo.CustPTTemplate WITH(NOLOCK)
	WHERE custid = @AgentID

	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTTemplateDetail_old 
	(
		TemplateID
		, GroupID
		, SubGroupID
		, PT
	)
	SELECT 
		ptDetail.TemplateID
		, GroupID
		, SubGroupID
		, PT
	FROM dbo.CustPTTemplateDetail ptDetail WITH(NOLOCK)
	INNER JOIN dbo.CustPTTemplate pt WITH(NOLOCK) ON ptDetail.TemplateID = pt.TemplateID
	WHERE pt.custid = @AgentID

	INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting3rd_Agent_old
	(
		CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPerNumber
	)
	SELECT CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPerNumber
	FROM dbo.BetSetting3rd_Agent WITH(NOLOCK)
	WHERE CustID = @AgentID

	INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting_Agent_old
	(
		CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPayoutPerMatch
	)
	SELECT CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPayoutPerMatch
	FROM dbo.BetSetting_Agent WITH(NOLOCK)
	WHERE CustID = @AgentID

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRAgentAutoAdjustment_old
	(
		AgentID
		, Type
		, Status
		, VR0_Date
	)
	SELECT AgentID
		, Type
		, Status
		, VR0_Date
	FROM dbo.VRAgentAutoAdjustment WITH(NOLOCK)
	WHERE AgentID = @AgentID

	--Member
	INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting_Member_old
	(
		CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPayoutPerMatch
	)
	SELECT CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPayoutPerMatch
	FROM dbo.BetSetting_Member WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.BetSetting3rd_Member_old
	(
		CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPerNumber
	)
	SELECT CustID
		, SportType
		, BetType
		, MinBet
		, MaxBet
		, MaxPerMatch
		, MaxPerNumber
	FROM dbo.BetSetting3rd_Member WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustQRCode_old (custid)
	SELECT custid
	FROM dbo.CustQRCode WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.RobotList_old
	(
		custid
		, isActive
		, creator
		, createdate
		, lastmodifytime
		, lastmodifyuser
		, remark
	)	
	SELECT custid
		, isActive
		, creator
		, createdate
		, lastmodifytime
		, lastmodifyuser
		, remark
	FROM dbo.RobotList WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRCustAutoAdjustment_old
	(
		SportType
		, CustID
		, FirstBetDate
		, Status
	)
	SELECT SportType
		, CustID
		, FirstBetDate
		, Status
	FROM dbo.VRCustAutoAdjustment WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRMemberBigStake_old
	(
		CustID
		, Type
		, FirstBetDate
		, Status
	)
	SELECT CustID
		, Type
		, FirstBetDate
		, Status
	FROM dbo.VRMemberBigStake WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.WinLimit_CustGameMonitoring_History_old
	(
		  LogID
		, CustID
		, ProductID
		, WinlostDate
		, LevelID
		, MaxWinLimit
		, TotalWinAmt
		, WinAmt
		, ActionID
		, ModifiedDate
		, IsNotified
		, ModifiedBy
		, CreatedBy
		, MaxWinLimitSetting
		, TotalWinAmt_RM
		, GroupID
		, BettypeIDList
		, TransID
	)
	SELECT  LogID
		, CustID
		, ProductID
		, WinlostDate
		, LevelID
		, MaxWinLimit
		, TotalWinAmt
		, WinAmt
		, ActionID
		, ModifiedDate
		, IsNotified
		, ModifiedBy
		, CreatedBy
		, CAST(MaxWinLimitSetting AS VARCHAR(MAX)) AS MaxWinLimitSetting
		, TotalWinAmt_RM
		, GroupID
		, BettypeIDList
		, TransID
	FROM dbo.WinLimit_CustGameMonitoring_History WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.WinLimit_CustGameMonitoring_old
	(
		CustID
		, ProductID
		, WinlostDate
		, LevelID
		, MaxWinLimit
		, TotalWinAmt
		, WinAmt
		, ModifiedDate
		, IsNotified
		, ModifiedBy
		, CreatedBy
		, MaxWinLimitSetting
		, TotalWinAmt_RM
		, GroupID
		, BettypeIDList
	)
	SELECT CustID
		, ProductID
		, WinlostDate
		, LevelID
		, MaxWinLimit
		, TotalWinAmt
		, WinAmt
		, ModifiedDate
		, IsNotified
		, ModifiedBy
		, CreatedBy
		, CAST(MaxWinLimitSetting AS VARCHAR(MAX)) AS MaxWinLimitSetting
		, TotalWinAmt_RM
		, GroupID
		, BettypeIDList
	FROM dbo.WinLimit_CustGameMonitoring WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )

	INSERT INTO DBARCCUST.bodb_Customer.dbo.WinLimit_CustGameStatus_old
	(
		CustID
		, ProductID
		, BettypeID
		, IsBlockedPlaceBet
		, IsBlockedTransfer
		, ActionID
		, ModifiedDate
	)
	SELECT CustID
		, ProductID
		, BettypeID
		, IsBlockedPlaceBet
		, IsBlockedTransfer
		, ActionID
		, ModifiedDate
	FROM dbo.WinLimit_CustGameStatus WITH(NOLOCK)
	WHERE custid IN (SELECT custid FROM custinfo WITH(NOLOCK) WHERE roleid = 1 AND recommend = @AgentID )
	-----------------------------------------------------------------------------------------------------------


	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)
END	