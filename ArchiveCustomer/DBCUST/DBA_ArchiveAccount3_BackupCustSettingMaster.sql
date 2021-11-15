/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_BackupCustSettingMaster]
	@AccName varchar(50),
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@ErrCode int = 0 OUTPUT
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
*/
BEGIN  
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int, @Now datetime
	set @startRun = getdate()

	Declare @roleid int, @CustID int, @Enabled bit

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled
	FROM custinfo (nolock)
	WHERE username = @AccName

	if isnull(@CustID,0) = 0 or @roleid NOT in (3)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Invalid Master User Name', @ErrCode = 101
		print @ErrMsg
		return
	END

	--Pre-check: Make sure cust info data not exist in DBRACCUST before backup
	IF EXISTS(
		SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) 
		WHERE custid = @CustID
		)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'Backup data of this Master already exist. Please check!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg, Roleid) VALUES(@CustID, @ErrMsg,3) 
		PRINT @ErrMsg
		RETURN
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
	where	custid = @CustID

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
						  0, Enabled, danger, DisableCasino, SyncCasino, danger2, 
						  danger3, DisableOutright, 0, DisableNumber, 0, 
						  0,
						  Abnormal, DoubleCommLosing,
						  autosuspend2, HideKeno, DisableEsports, HideGoldDeluxe, DisableGoldDeluxe,  
						  DisableSuperLive, DisableColossusBet, HideColossusBet, 
						  LockUpd, 0, BonusWalletFlag   
	from	custinfo (nolock)
	where	custid = @CustID

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
	where	custid = @CustID

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
		   ,0
		   ,0
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
	WHERE	custid = @CustID		

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
	WHERE custid = @CustID

	--- copy DBTRANS.BODB02.dbo.CustGameType data to DB05.bodb_Customer.dbo.CustGameType_Old
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
	SELECT CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
	FROM [dbo].CustGameType WITH(NOLOCK)
	WHERE custid = @CustID

	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting WITH(NOLOCK)
	WHERE custid = @CustID


	--------- Involve more tables (new tables/DCS)
	INSERT INTO DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
		 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	) 
	SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	FROM	CustProductStatus WITH (NOLOCK)
	WHERE	custid = @CustID
	
	------- custSub -------------------------------
	INSERT INTO DBARCCUST.bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM	custsub WITH (NOLOCK)
	WHERE	custid = @CustID

	--> MORE TABLES
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Agent_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch)
		SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch
		FROM CustBetSetting3rd_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old(CustID,SportType,BetType,Discount)
		SELECT CustID,SportType,BetType,Discount
		FROM CustDiscount3rd_Agent WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custOverride_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.custOverride_old(custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking)
		SELECT custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking
		FROM custOverride WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custOverride3rd_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.custOverride3rd_old(custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking)
		SELECT custid,bettype,sporttype,minpositiontaking,maxpositiontaking,minlivepositiontaking,maxlivepositiontaking
		FROM custOverride3rd WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustOverrideGame_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustOverrideGame_old(CustID,Bettype,Sporttype,minpositiontaking)
		SELECT CustID,Bettype,Sporttype,minpositiontaking
		FROM CustOverrideGame WITH(NOLOCK)
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

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.AgentCommRate_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.AgentCommRate_old(CustId,Sporttype,Bettype,CommRate)
		SELECT CustId,Sporttype,Bettype,CommRate
		FROM AgentCommRate WITH(NOLOCK)
		WHERE custid = @CustID

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustBetSetting_Agent_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustBetSetting_Agent_old(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch
		FROM CustBetSetting_Agent WITH(NOLOCK)
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

	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.CustMaster_old WITH(NOLOCK) WHERE custid = @CustID)
		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustMaster_old(custid,DisableAutoMPT,IsInternal,TransferOption,LimitPerIP,SelectedBetting
			,NicknameLoginOnly,creationRemark,IsAllDayBalTransfer)
		SELECT custid,DisableAutoMPT,IsInternal,TransferOption,LimitPerIP,SelectedBetting
			,NicknameLoginOnly,creationRemark,IsAllDayBalTransfer
		FROM CustMaster WITH(NOLOCK)
		WHERE custid = @CustID
	-----------------------------------------------------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)
	
END	