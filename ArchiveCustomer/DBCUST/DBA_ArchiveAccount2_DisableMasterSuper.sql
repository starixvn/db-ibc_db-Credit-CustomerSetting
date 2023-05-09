/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableMasterSuper]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT,
	@srecommend INT = 0 OUTPUT,
	@ReduceCredit MONEY = 0 OUTPUT,
	@ArchivedDate DATE = NULL
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210614@Eden: All sites - Dormant SMA Account List [RedmineID: #155969]
			- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
			- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
			- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
*/
BEGIN
	    
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int, @Now datetime
	set @startRun = getdate()

	Declare @roleid int, @CustID int, @Enabled bit

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled, @srecommend = srecommend, @ReduceCredit = credit
	FROM custinfo (nolock)
	WHERE username = @AccName

	PRINT  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--=============================
	--PERFORM BACKUP DATA MEMBERS
	--=============================

	SELECT @Now = current_timestamp
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
	--Copy agent+members' custinfo to bodb_Customer 
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
                      DisableSuperLive, DisableColossusBet, HideColossusBet, 
                      LockUpd, 0, BonusWalletFlag
		from	custinfo (nolock)
		WHERE custid = @CustID
	END
	--Copy custSetting data to bodb_Customer before delete
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custSetting_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
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
	
	------- custSub -------------------------------
	IF NOT EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custsub_old WITH(NOLOCK) 
			WHERE	custid = @CustID
	)
	BEGIN
		INSERT INTO DBARCCUST.bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
		SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		FROM	custsub WITH (NOLOCK)
		WHERE	custid = @CustID
	END

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
	--> Insert data for Cust_ArchiveAccount - Master/Super
	BEGIN
		DECLARE @ProcessedDate DATETIME  = GETDATE()

		EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
			@CustId = @CustID,
			@RoleID = @roleid,
			@StageID = 2,
			@ProcessedDate = @ProcessedDate,
			@ArchivedDate = @ArchivedDate
	END

	EXEC DBA_Archive_Cust_SuperMaster @custid = @CustID, @stage = 2
	
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount2_DisableMasterSuper AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	IF @Enabled = 1
	BEGIN
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1177,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END
	--Writelog clear given credit for Master
	DECLARE @LogData VARCHAR(500) = ''
	SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@AccName, SPACE(1))  
	IF @ReduceCredit <> 0
	BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END TRY
		BEGIN CATCH
			SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END CATCH
	END	
END