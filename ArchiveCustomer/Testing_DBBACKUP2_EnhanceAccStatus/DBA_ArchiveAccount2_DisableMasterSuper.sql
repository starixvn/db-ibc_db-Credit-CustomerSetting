/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount2_DisableMasterSuper]
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
*/
BEGIN
	    
	SET NOCOUNT ON
	
	-- simulate run date based on test data version
	declare @currentDate smalldatetime 
	select @currentDate = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_TestDate'

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
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.customer_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
	
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
		WHERE custid = @CustID
	END
	--Copy agent+members' custinfo to bodb_Customer 
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custinfo_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
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
		WHERE custid = @CustID
	END
	--Copy custSetting data to bodb_Customer before delete
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custSetting_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
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
		WHERE custid = @CustID
	END
	--Copy custSetting3rd data to bodb_Customer 
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custSetting3rd_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
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
		WHERE custid = @CustID
	END
	--- copy DBTRANS.BODB02.dbo.CustSettingGame data to DB05.bodb_Customer.dbo.CustSettingGame_Old
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.CustSettingGame_Old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
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
	END
	--- copy DBTRANS.BODB02.dbo.CustGameType data to DB05.bodb_Customer.dbo.CustGameType_Old
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.CustGameType_Old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		INSERT INTO bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
		SELECT CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
		FROM [dbo].CustGameType WITH(NOLOCK)
		WHERE custid = @CustID
	END

	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.CustVirtualSetting_Old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		INSERT INTO bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
		SELECT custid, seqNo, bitmapVirtual
		FROM [dbo].CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @CustID
	END	
	--------- Involve more tables (new tables/DCS)
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.CustProductStatus_old WITH(NOLOCK) 
				WHERE	custid = @CustID
		)
	BEGIN
		insert into bodb_Customer.dbo.CustProductStatus_old(
			 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
		) 
		SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo
		FROM	CustProductStatus WITH (NOLOCK)
		where	custid = @CustID
	END
	
	------- custSub -------------------------------
	IF NOT EXISTS(SELECT 1 FROM bodb_Customer.dbo.custsub_old WITH(NOLOCK) 
			WHERE	custid = @CustID
	)
	BEGIN
		INSERT INTO bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
		SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		FROM	custsub WITH (NOLOCK)
		WHERE	custid = @CustID
	END
	-----------------------------------------------------------------------------------------------------------
	--> Insert data for Cust_ArchiveAccount - Master/Super
	BEGIN
		DECLARE @ProcessedDate DATETIME  = @currentDate

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
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
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
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
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
    
