/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_BackupAgent]
	@AccName VARCHAR(50)
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20210128@Winfred: Check custinfo and backup agent [RedmineID: #149262]
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

	Declare @CustID int

	SELECT @CustID = custid
	FROM custinfo (nolock)
	WHERE username = @AccName

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
	
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
		WHERE custid = @CustID
	END
	
	
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
	
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
		select CAST(current_timestamp as datetime), 
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
		WHERE custid = @CustID
	END
	
	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
		SELECT custid, seqNo, bitmapVirtual
		FROM [dbo].CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @CustID
	END	
	--------- Involve more tables (new tables/DCS)
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustProductStatus_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
			 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
		) 
		SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
		FROM	CustProductStatus WITH (NOLOCK)
		where	custid = @CustID
	END
	
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custsub_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		INSERT INTO DBARCCUST.bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
		SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		FROM	custsub WITH (NOLOCK)
		WHERE	custid = @CustID
	END

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old(CustID,SportType,BetType,Discount)
		SELECT CustID,SportType,BetType,Discount
		FROM CustDiscount3rd_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Agent_old(CustID,SportType,BetType,IsLive,IsAutoMasterPT,IsAutoSuperPT
			,SuperPT,MasterPT,AgentPT,AutoSuperPT,AutoMasterPT,MinPT,MaxPT)
		SELECT CustID,SportType,BetType,IsLive,IsAutoMasterPT,IsAutoSuperPT
			,SuperPT,MasterPT,AgentPT,AutoSuperPT,AutoMasterPT,MinPT,MaxPT
		FROM CustPTSetting3rd_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Agent_old(CustID,SportType,BetType,StakeLevelList)
		SELECT CustID,SportType,BetType,StakeLevelList
		FROM CustStakeLevel_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Agent_old(CustId,SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset)
		SELECT CustId,SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset
		FROM CustWinLossLimit_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustPTGroupSetting3rd_Member_old WITH(NOLOCK) WHERE AgentID = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustPTGroupSetting3rd_Member_old(AgentID,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT
			,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT)
		SELECT AgentID,SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT
			,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT
		FROM CustPTGroupSetting3rd_Member WITH(NOLOCK)
		WHERE AgentID = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustAgent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustAgent_old(custid,MaxCredit,IsInternal,TransferOption,LimitPerIP,SelectedBetting
			,NicknameLoginOnly,site,creationRemark,IsMonitorPT)
		SELECT custid,MaxCredit,IsInternal,TransferOption,LimitPerIP,SelectedBetting
			,NicknameLoginOnly,site,creationRemark,IsMonitorPT
		FROM CustAgent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustLoginInfo_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustLoginInfo_old(CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin,SecurityCode,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode
			,VerifyOTPCount,ClosedReason,FunctionInfo,ProtectionCode,IsProtectedMode)
		SELECT CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin,SecurityCode,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode
		,VerifyOTPCount,ClosedReason,FunctionInfo,ProtectionCode,IsProtectedMode
		FROM CustLoginInfo WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustLoginInfoSub_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustLoginInfoSub_old(SubAccID,CustID,OldUserPwd,PwdExpiry,LastChangedPwdDate,isFirstLogin,SecurityCode
			,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode,VerifyOTPCount,FunctionInfo,ProtectionCode)
		SELECT SubAccID,CustID,OldUserPwd,PwdExpiry,LastChangedPwdDate,isFirstLogin,SecurityCode
			,LastChangedSecurityCodeDate,SecurityCodeCount,isForcedChangeSecurityCode,VerifyOTPCount,FunctionInfo,ProtectionCode
		FROM CustLoginInfoSub WITH(NOLOCK)
		WHERE custid = @CustID

	--#188850
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustMaxPayoutSetting_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustMaxPayoutSetting_Agent_old(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
		FROM CustMaxPayoutSetting_Agent WITH(NOLOCK)
		WHERE custid = @CustID

IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustProfilePicture_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustProfilePicture_old(CustId,ImageId,Modified)
		SELECT CustId,ImageId,Modified
		FROM dbo.CustProfilePicture WITH(NOLOCK)
		WHERE custid = @CustID

	--#201061
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.BetLimitControlCustSetting_old WITH(NOLOCK) WHERE custid = @CustID)
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
	WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustPTTemplate_old WITH(NOLOCK) WHERE custid = @CustID)
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
	WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustPTTemplateDetail_old ptDetail WITH(NOLOCK)
				     INNER JOIN DBARCCUST.bodb_Customer.dbo.CustPTTemplate_old pt WITH(NOLOCK) ON ptDetail.TemplateID = pt.TemplateID 
		        WHERE pt.custid = @CustID)
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
	WHERE pt.custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.VRAgentAutoAdjustment_old WITH(NOLOCK) WHERE AgentID = @CustID)
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
	WHERE AgentID = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.VRCustLockStatus_old WITH(NOLOCK) WHERE custid = @CustID)
	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRCustLockStatus_old (CustID, Type)
	SELECT CustID, Type
	FROM dbo.VRCustLockStatus WITH(NOLOCK)
	WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.VRCustSetting_old WITH(NOLOCK) WHERE custid = @CustID)
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
	WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.VRSettingManualUpdAcc_old WITH(NOLOCK) WHERE custid = @CustID)
	INSERT INTO DBARCCUST.bodb_Customer.dbo.VRSettingManualUpdAcc_old	(SportType , CustID)
	SELECT SportType , CustID
	FROM dbo.VRSettingManualUpdAcc WITH(NOLOCK)
	WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.BetSetting3rd_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
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
	WHERE CustID = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.BetSetting_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
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
	WHERE CustID = @CustID
			
END