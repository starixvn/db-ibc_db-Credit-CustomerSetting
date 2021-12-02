/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount3_BackupCustSettingMaster]
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
		SELECT 1 FROM bodb_Customer.dbo.customer_old WITH(NOLOCK) 
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
	where	custid = @CustID

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
	where	custid = @CustID

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
	where	custid = @CustID

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
	WHERE	custid = @CustID		

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
	INSERT INTO bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
	SELECT CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
	FROM [dbo].CustGameType WITH(NOLOCK)
	WHERE custid = @CustID

	--- copy DBTRANS.BODB02.dbo.CustVirtualSetting data to DB05.bodb_Customer.dbo.CustVirtualSetting_Old
	INSERT INTO bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
	SELECT custid, seqNo, bitmapVirtual
	FROM [dbo].CustVirtualSetting WITH(NOLOCK)
	WHERE custid = @CustID


	--------- Involve more tables (new tables/DCS)
	INSERT INTO bodb_Customer.dbo.CustProductStatus_old(
		 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	) 
	SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, CloseInfo, Locked
	FROM	CustProductStatus WITH (NOLOCK)
	WHERE	custid = @CustID
	
	------- custSub -------------------------------
	INSERT INTO bodb_Customer.dbo.custsub_old (subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted)
	SELECT subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
	FROM	custsub WITH (NOLOCK)
	WHERE	custid = @CustID
	-----------------------------------------------------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)
	
END	
    
