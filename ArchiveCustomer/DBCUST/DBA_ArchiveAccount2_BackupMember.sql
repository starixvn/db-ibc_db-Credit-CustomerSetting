/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_BackupMember]
	@AccName VARCHAR(50)
AS
/*
		Description: Back up direct Member under SMA setting when before them
		Created: 20250102@Eden
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20250102@Eden: Archiving direct member [redmine: #215533] 
*/
BEGIN
	    
	SET NOCOUNT ON

	Declare @CustID int, @Roleid TINYINT, @Now DATETIME2
	CREATE TABLE #temp_DirectMember (custid INT PRIMARY KEY)

	SELECT @CustID = custid, @Roleid = Roleid
	FROM custinfo (nolock)
	WHERE username = @AccName

	IF @roleid = 4
	BEGIN
		INSERT INTO #temp_DirectMember(custid)
		SELECT DISTINCT custid
		FROM dbo.custinfo WITH (NOLOCK)
		WHERE srecommend = @CustID AND roleid = 1 AND recommend = -4
	END
	ELSE IF @roleid = 3
	BEGIN
		INSERT INTO #temp_DirectMember(custid)
		SELECT DISTINCT custid
		FROM dbo.custinfo WITH (NOLOCK)
		WHERE mrecommend = @CustID AND roleid = 1 AND recommend = -3
	END
	ELSE IF @roleid = 2
	BEGIN
		INSERT INTO #temp_DirectMember(custid)
		SELECT DISTINCT custid
		FROM dbo.custinfo WITH (NOLOCK)
		WHERE recommend = @CustID AND roleid = 1 
	END
	ELSE 
	BEGIN
		RETURN
	END

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
	where	custid IN (select custid from #temp_DirectMember)

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
	where	custid IN (select custid from #temp_DirectMember)


	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
		WHERE custid IN (select custid from #temp_DirectMember)
		)
	BEGIN
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
		SELECT custid, seqNo, bitmapVirtual
		FROM [dbo].CustVirtualSetting WITH(NOLOCK)
		WHERE custid IN (select custid from #temp_DirectMember)
	END	


	--------- Involve more tables (new tables/DCS)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Member_old(
		CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	) 
	SELECT	CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount
	FROM	CustDiscount3rd_Member WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)	

	insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
		 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
	) 
	SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
	FROM	CustProductStatus WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)

	insert into DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Member_old(
		 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	) 
	SELECT	 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
	FROM	CustPTSetting3rd_Member WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)

	insert into DBARCCUST.bodb_Customer.dbo.CustSettingMode3rd_old(
		 CustID, IsGrouped
	) 
	SELECT	 CustID, IsGrouped
	FROM	CustSettingMode3rd WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)


	insert into DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Member_old(
		 CustID, SportType, BetType, StakeLevelList, LastUpdated
	) 
	SELECT	CustID, SportType, BetType, StakeLevelList, LastUpdated
	FROM	CustStakeLevel_Member WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)

	insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfo_Member_old(
		 CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	) 
	SELECT CustID, SecurityCode, IP, LastChangedID, LastChangedDate, OddsType, LayoutMode, BetStake, DefaultLanguage, OddsSort, BetterOdds, ShowLiveCasino, SportSort, CusStake1, CusStake2, 
		 ShowScoreMap, ShowBanner, AutoRefresh, MarketType, AutoRefreshMatch, MobileOthersType, gesture, failedcount, lastlogged, OddsColorStyle, ClosedReason, notify, recommendation
	FROM	CustLoginInfo_Member WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)

	insert into DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Member_old(
		CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	) 
	SELECT CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	FROM	CustWinLossLimit_Member WITH (NOLOCK)
	WHERE	custid IN (select custid from #temp_DirectMember)

	--#188850
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustMaxPayoutSetting_Member_old(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
	SELECT CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
	FROM CustMaxPayoutSetting_Member WITH(NOLOCK)
	WHERE custid IN (select custid from #temp_DirectMember)

	--#201061
	--Role Agent/Member
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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRCustLockStatus_old (CustID, Type)
	SELECT CustID, Type
	FROM dbo.VRCustLockStatus WITH(NOLOCK)
	WHERE custid IN (select custid from #temp_DirectMember)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRSettingManualUpdAcc_old	(SportType , CustID)
	SELECT SportType , CustID
	FROM dbo.VRSettingManualUpdAcc WITH(NOLOCK)
	WHERE custid IN (select custid from #temp_DirectMember)

	--Role Member
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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	SELECT 
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
		, CAST(MaxWinLimitSetting AS VARCHAR(MAX)) AS MaxWinLimitSetting
		, TotalWinAmt_RM
		, GroupID
		, BettypeIDList
		, TransID
	FROM dbo.WinLimit_CustGameMonitoring_History WITH(NOLOCK)
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustQRCode_old (custid)
	SELECT custid
	FROM dbo.CustQRCode WITH(NOLOCK)
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)

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
	WHERE custid IN (select custid from #temp_DirectMember)
END
GO