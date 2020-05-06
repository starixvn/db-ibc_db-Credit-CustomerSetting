/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [Task_ArchiveAccount_DisabledAgents_NoBal_Backup]
AS
/*
	Task: Archive unused credit account for disabled agents with zero balances - Backup data
	Created: Daniel@20191206
	Database: DBCUST.CustDB

	Revisions:
		- 20191206@Daniel: Created

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @batchCustIDs TABLE(custid INT)
	DECLARE @Now DATETIME = current_timestamp

	WHILE(1=1)
	BEGIN

		UPDATE TOP(3000) t
		SET IsFinished = 1
		OUTPUT INSERTED.recommend INTO @batchCustIDs
		FROM tmpCustArchived_DisabledAgents_NoBal t
		WHERE IsFinished = 0

		IF (@@ROWCOUNT = 0) BREAK

		--start copy data to bodb_Customer 
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
		where	custid IN(select custid from @batchCustIDs)

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
		where	custid IN(select custid from @batchCustIDs)

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
		where	custid IN(select custid from @batchCustIDs)

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
		WHERE	custid IN(select custid from @batchCustIDs)		

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
		WHERE custid IN(select custid from @batchCustIDs)


		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustGameType_Old(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
		SELECT CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled
		FROM [dbo].CustGameType WITH(NOLOCK)
		WHERE custid IN(select custid from @batchCustIDs)

		INSERT INTO DBARCCUST.bodb_Customer.dbo.CustVirtualSetting_Old(custid, seqNo, bitmapVirtual)
		SELECT custid, seqNo, bitmapVirtual
		FROM [dbo].CustVirtualSetting WITH(NOLOCK)
		WHERE custid IN(select custid from @batchCustIDs)

		--------- Involve more tables (new tables/DCS)

		insert into DBARCCUST.bodb_Customer.dbo.custSub_Old(
			subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		) 
		SELECT	subaccid, custid, username, userpwd, PageAccess, createdate, firstname, lastname, closed, LoginCount, UserName2, NicknameLoginOnly, IsAllDownline, IsDeleted
		FROM	custSub WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfoSub_Old(
			SubAccID, CustID, OldUserPwd, PwdExpiry, LastChangedPwdDate, isFirstLogin, SecurityCode, LastChangedSecurityCodeDate, SecurityCodeCount, isLocked, isForcedChangeSecurityCode, VerifyOTPCount
		) 
		SELECT	SubAccID, CustID, OldUserPwd, PwdExpiry, LastChangedPwdDate, isFirstLogin, SecurityCode, LastChangedSecurityCodeDate, SecurityCodeCount, isLocked, isForcedChangeSecurityCode, VerifyOTPCount
		FROM	CustLoginInfoSub WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustLoginInfo_Old(
					CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCode, LastChangedSecurityCodeDate, SecurityCodeCount, isLocked, isForcedChangeSecurityCode, VerifyOTPCount, ClosedReason
		) 
		SELECT	CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCode, LastChangedSecurityCodeDate, SecurityCodeCount, isLocked, isForcedChangeSecurityCode, VerifyOTPCount, ClosedReason
		FROM	CustLoginInfo WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustAgent_Old(
			custid, MaxCredit, IsInternal, TransferOption, LimitPerIP, SelectedBetting, NicknameLoginOnly, site, creationRemark, IsMonitorPT
		) 
		SELECT	custid, MaxCredit, IsInternal, TransferOption, LimitPerIP, SelectedBetting, NicknameLoginOnly, site, creationRemark, IsMonitorPT
		FROM	CustAgent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.custOverride_Old(
			custid, bettype, sporttype, minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking
		) 
		SELECT	custid, bettype, sporttype, minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking
		FROM	custOverride WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.custOverride3rd_old(
			custid, bettype, sporttype, minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking
		) 
		SELECT	custid, bettype, sporttype, minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking
		FROM	custOverride3rd WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustOverrideGame_old(
			custid, bettype, sporttype, minpositiontaking
		) 
		SELECT	custid, bettype, sporttype, minpositiontaking
		FROM	CustOverrideGame WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustBetSetting3rd_Agent_old(
			CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
		) 
		SELECT	CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch
		FROM	CustBetSetting3rd_Agent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.AgentCommRate_old(
			CustID, SportType, BetType, CommRate
		) 
		SELECT	CustID, SportType, BetType, CommRate
		FROM	AgentCommRate WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustDiscount3rd_Agent_old(
			CustID, SportType, BetType, Discount
		) 
		SELECT	CustID, SportType, BetType, Discount
		FROM	CustDiscount3rd_Agent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)	

		insert into DBARCCUST.bodb_Customer.dbo.CustProductStatus_old(
			 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo
		) 
		SELECT	 CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo
		FROM	CustProductStatus WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustPTSetting3rd_Agent_old(
			 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT, MinPT, MaxPT
		) 
		SELECT	 CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT, MinPT, MaxPT
		FROM	CustPTSetting3rd_Agent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustPTGroupSetting3rd_Member_old(
			  AgentID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
		) 
		SELECT	 AgentID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT
		FROM	CustPTGroupSetting3rd_Member WITH (NOLOCK)
		WHERE	agentid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustStakeLevel_Agent_old(
			 CustID, SportType, BetType, StakeLevelList
		) 
		SELECT	CustID, SportType, BetType, StakeLevelList
		FROM	CustStakeLevel_Agent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustWinLossLimit_Agent_old(
			CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
		) 
		SELECT CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM	CustWinLossLimit_Agent WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		insert into DBARCCUST.bodb_Customer.dbo.CustWinLimit_old(
			CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit
		) 
		SELECT CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit
		FROM	CustWinLimit WITH (NOLOCK)
		WHERE	custid IN(select custid from @batchCustIDs)

		--End copy data to bodb_Customer -------------------------------------------------------------------------------------------------------
	
		DELETE @batchCustIDs
			
	END

	





END