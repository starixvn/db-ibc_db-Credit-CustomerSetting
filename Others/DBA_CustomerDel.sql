/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0"></info>*/ 
  ALTER PROCEDURE [dbo].[DBA_CustomerDel]
	@username VARCHAR(30),
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg VARCHAR(200) = '' OUTPUT
AS
/*
	Created: 
	Task : Delete Customer
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20090527@Kiwi: add checking for Casino
		- 20091203@Kiwi: Delete customer from CustSetting3rd and CustOverride3rd.
		- 20111028@Sophia: Delete Balance table
		- 20121015@Dan: Delete Live casino Balance table 
		- 20130108@Lukas: delete data in Dep_custsetting, custsettingGame, P2PGameSetting 
		- 20130306@Jim: change link server
		- 20131108@Elodie: Splitting bodb02 into CustDB (Move delete balance's customer to DBA_CustomerDel_Balance)
		- 20141022@Lukas: delete data in table custgameType
		- 20150622@Daniel: Separated custDB to server DBCUST
		- 20170419@Helen: Hotfix Missing Setting 
		- 20171225@Elodie: Delete customer from setting tables of DCS
		- 20190327@Daniel: Migrate bodb_Licensee to DBCUST: Remove linked server DBLIC for deleting data in bodb_Licensee
		- 20190906@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20220301@Eden: Deposit - Sportsbook - Revise customer settings [Redmine: #167898] 
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230620@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #188096]
		- 20230414@Eden: Scale out DBTRANS for Credit [Redmine: #181595]
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20240527@Tacy: Delete data in Dep_ChargeInfoSetting [RedmineID: #201239]
		- 20240726@Johnson: Scale out DBCUST for SB Bet settings [redmine: #199915]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20240726@Johnson: Apply In-house Replication for Deposit Customer Setting [redmine:#207025]
		- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
		- 20241125@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20250220@Johnson: remove CustRequestGame [RedmineID: #212684]
		- 20250220@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]

	Param's Explanation:
		@username: pass the username of customer you want to delete.

	Notes: Call sp on siteDB first to delete Balance, delete Bet ticket (if exists)
		EXEC bodb02.dbo.DBA_CustomerDel_Balance @custid = @custid, @roleid = @roleid, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT
		EXEC bodb02.dbo.DBA_CustomerDel_Bets @srecommend = @custid ( roleID = 4)
*/		
DECLARE @roleid INT, @custid INT
SELECT @roleid = 0 

SELECT	@roleid=roleid, 
		@custid = custid
FROM customer WITH (NOLOCK)
WHERE username = @username

IF @@ROWCOUNT = 0
	SELECT	@roleid=roleid, 
			@custid = custid
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE username = @username

IF @roleid = 0
	SELECT @ErrMsg = N'USERNAME not existed!'
	

DECLARE @tmp_custID TABLE (CustID int)

if @roleid = 4
BEGIN
	IF EXISTS (SELECT 1 FROM DBTXN.bodb02.dbo.bettrans WITH (NOLOCK) WHERE srecommend = @custid)
	BEGIN
		SELECT @ErrMsg = N'Got bettrans already. Cannot delete.', @ErrCode = 100
		RETURN
	END

	DELETE CustSuper 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustSuper_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid	
	
	DELETE CustMaster 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustMaster_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 3)
	
	DELETE CustAgent
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustAgent_Del_Inhouse(custid,RepUpdateTime)	
	WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)
	
	--delete subacc
	DELETE custsub 
	OUTPUT DELETED.subaccid, dbo.f_GetDateTime2()
	INTO custsub_Del_Inhouse(subaccid,RepUpdateTime)	
	WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid in(4,3,2))
	
	-- delete licensee superid
	DELETE Dep_CustSuper 
	OUTPUT DELETED.custid, SYSDATETIME()
	INTO Dep_CustSuper_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid		

	--insert downline custids into @tmp_custID	
	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE srecommend = @custid
		
	--Delete cust login info
	DELETE CustLoginInfo WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE CustLoginInfo_Member WITH (ROWLOCK)   
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Member_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustLoginInfoSub WITH (ROWLOCK)    
		OUTPUT DELETED.SubAccID, dbo.f_GetDateTime2()
		INTO dbo.CustLoginInfoSub_Del_Inhouse(SubAccID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustDirectAccount_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.Acc_CustAllowList WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustAllowList_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.Acc_CustDirect WITH (ROWLOCK) 
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustDirect_Del_InHouse(custid, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.custAccount WITH (ROWLOCK)
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.custAccount_Del_Inhouse(custid, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustGroupHeadline WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustGroupHeadline_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustNoComm WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustNoComm_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustOTP WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, DELETED.SubAccId, dbo.f_GetDateTime2()
		INTO CustOTP_Del_Inhouse(CustID, SubAccId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustOTPDetail WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, DELETED.SubAccId, DELETED.LastVerifiedDate, DELETED.DeviceId, dbo.f_GetDateTime2()
		INTO CustOTPDetail_Del_Inhouse(CustID, SubAccId, LastVerifiedDate, DeviceId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	--DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBAActive 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustBAActive_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	--DCS table
	DELETE dbo.CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustProductStatus_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Agent_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Member_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustSettingMode3rd 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustSettingMode3rd_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.BetSetting3rd_Agent 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.BetSetting3rd_Member 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE CustPTGroupSetting3rd_Member 
	OUTPUT DELETED.AgentID, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTGroupSetting3rd_Member_Del_Inhouse(AgentID,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	
	
	DELETE BetSetting_Agent WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	
	DELETE BetSetting_Member WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	--Inhouse Tables
	--DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE c
	OUTPUT deleted.custid, deleted.seqNo, [dbo].[f_GetDateTime2]() 
	INTO CustVirtualSetting_Del_Inhouse(custid,seqNo,RepUpdateTime)
	FROM CustVirtualSetting c WITH(ROWLOCK) 
	WHERE custid IN (SELECT custID FROM @tmp_custID)

		
	--Delete setting deposit	
	DELETE Dep_CustProductSetting 
	OUTPUT DELETED.custid, DELETED.ProductID,dbo.f_GetDateTime2()
	INTO Dep_CustProductSetting_Del_InHouse(custid,ProductID,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE Dep_CustSetting_AGCasino 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSetting_AGCasino_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustSettingGame_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustProductStatus_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Member_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustSettingMode 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSettingMode_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBetSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGameGroup_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)
	
	DELETE dbo.Dep_CustDiscountGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	
	
	DELETE dbo.Dep_CustPTGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	
	
	DELETE Dep_LicenseeProductSetting 
	OUTPUT DELETED.custid, DELETED.ProductSettingID, dbo.f_GetDateTime2()
	INTO Dep_LicenseeProductSetting_Del_InHouse(custid,ProductSettingID,RepUpdateTime)
	WHERE custid = @custid

	UPDATE Dep_ChargeInfoSetting 
	SET	RepUpdateTime = dbo.f_GetDateTime2(),
		IsDeleted = 1
	WHERE custid = @custid

	DELETE custinfo 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO custinfo_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE customer 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO customer_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)		
	
	IF @@ERROR <> 0
	BEGIN	
		SELECT @ErrMsg = N'Delete customer failed.', @ErrCode = 101
		RETURN
	END
END

if @roleid = 3
BEGIN
	IF EXISTS (SELECT 1 FROM DBTXN.bodb02.dbo.bettrans WITH (NOLOCK) WHERE mrecommend = @custid)
	BEGIN
		SELECT @ErrMsg = N'Got bettrans already. Cannot delete.', @ErrCode = 100
		RETURN
	END
	DELETE CustMaster 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustMaster_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE CustAgent 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustAgent_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid in (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)
	--delete subacc
	DELETE custsub 
	OUTPUT DELETED.subaccid, dbo.f_GetDateTime2()
	INTO custsub_Del_Inhouse(subaccid,RepUpdateTime)
	WHERE custid in (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid in(3,2))

	--insert downline custids into @tmp_custID
	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE mrecommend = @custid
	
	--Delete cust login info
	DELETE CustLoginInfo WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustLoginInfo_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE CustLoginInfo_Member WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustLoginInfo_Member_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustLoginInfoSub WITH (ROWLOCK)   
		OUTPUT DELETED.SubAccID, dbo.f_GetDateTime2()
		INTO dbo.CustLoginInfoSub_Del_InHouse(SubAccID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustDirectAccount_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Acc_CustAllowList WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustAllowList_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Acc_CustDirect WITH (ROWLOCK) 
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustDirect_Del_InHouse(custid, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.custAccount WITH (ROWLOCK)
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.custAccount_Del_Inhouse(custid, RepUpdateTime) 
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustGroupHeadline WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustGroupHeadline_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustNoComm WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustNoComm_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustOTP WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, DELETED.SubAccId, dbo.f_GetDateTime2()
		INTO CustOTP_Del_Inhouse(CustID, SubAccId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustOTPDetail WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, DELETED.SubAccId, DELETED.LastVerifiedDate, DELETED.DeviceId, dbo.f_GetDateTime2()
		INTO CustOTPDetail_Del_Inhouse(CustID, SubAccId, LastVerifiedDate, DeviceId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	--DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBAActive 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustBAActive_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	
	--DCS table
	DELETE dbo.CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustProductStatus_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Agent_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Member_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustSettingMode3rd 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustSettingMode3rd_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.BetSetting3rd_Agent 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.BetSetting3rd_Member 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE CustPTGroupSetting3rd_Member 
	OUTPUT DELETED.AgentID, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTGroupSetting3rd_Member_Del_Inhouse(AgentID,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)	
	
	DELETE BetSetting_Agent WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	
	DELETE BetSetting_Member WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	--Inhouse Tables
	--DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE c
	OUTPUT deleted.custid, deleted.seqNo, [dbo].[f_GetDateTime2]() 
	INTO CustVirtualSetting_Del_Inhouse(custid,seqNo,RepUpdateTime)
	FROM CustVirtualSetting c WITH(ROWLOCK) 
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	
	--Delete setting deposit
	DELETE Dep_CustProductSetting 
	OUTPUT DELETED.custid, DELETED.ProductID,dbo.f_GetDateTime2()
	INTO Dep_CustProductSetting_Del_InHouse(custid,ProductID,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE Dep_CustSetting_AGCasino 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSetting_AGCasino_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustSettingGame_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustProductStatus_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Member_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustSettingMode 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSettingMode_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBetSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGameGroup_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)
	
	DELETE dbo.Dep_CustDiscountGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)		
	
	DELETE dbo.Dep_CustPTGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)	
	
	DELETE custinfo 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO custinfo_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE customer 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO customer_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
		
	IF @@ERROR <> 0
	BEGIN	
		select @ErrMsg = N'Delete customer failed.', @ErrCode = 102
		RETURN
	END
END

if @roleid = 2
BEGIN	
	IF EXISTS (SELECT 1 FROM DBTXN.bodb02.dbo.bettrans WITH (NOLOCK) WHERE recommend = @custid)
	BEGIN
		SELECT @ErrMsg = N'Got bettrans already. Cannot delete.', @ErrCode = 100
		RETURN
	END
	DELETE CustAgent 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustAgent_Del_Inhouse(custid,RepUpdateTime)	
	WHERE custid = @custid
	--delete subacc
	DELETE custsub 
	OUTPUT DELETED.subaccid, dbo.f_GetDateTime2()
	INTO custsub_Del_Inhouse(subaccid,RepUpdateTime)	
	WHERE custid = @custid	 

	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE recommend = @custid
	
	--Delete cust login info
	DELETE CustLoginInfo WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE CustLoginInfo_Member WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Member_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustLoginInfoSub WITH (ROWLOCK)
		OUTPUT DELETED.SubAccID, dbo.f_GetDateTime2()
		INTO dbo.CustLoginInfoSub_Del_Inhouse(SubAccID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustDirectAccount_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Acc_CustAllowList WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustAllowList_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Acc_CustDirect WITH (ROWLOCK) 
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustDirect_Del_InHouse(custid, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.custAccount WITH (ROWLOCK)
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.custAccount_Del_Inhouse(custid, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustGroupHeadline WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustGroupHeadline_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustNoComm WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustNoComm_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustOTP WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, DELETED.SubAccId, dbo.f_GetDateTime2()
		INTO CustOTP_Del_Inhouse(CustID, SubAccId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.CustOTPDetail WITH (ROWLOCK)
		OUTPUT DELETED.CustID, DELETED.SubAccId, DELETED.LastVerifiedDate, DELETED.DeviceId, dbo.f_GetDateTime2()
		INTO CustOTPDetail_Del_Inhouse(CustID, SubAccId, LastVerifiedDate, DeviceId, RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	--DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBAActive 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustBAActive_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	--DCS table
	DELETE dbo.CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustProductStatus_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Agent_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustPTSetting3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Member_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustSettingMode3rd 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustSettingMode3rd_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustWinLossLimit_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.CustDiscount3rd_Agent 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Agent_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.BetSetting3rd_Agent 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.BetSetting3rd_Member 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE CustPTGroupSetting3rd_Member 
	OUTPUT DELETED.AgentID, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTGroupSetting3rd_Member_Del_Inhouse(AgentID,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID = @custid
	
	DELETE BetSetting_Agent WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	
	DELETE BetSetting_Member WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE custID IN (SELECT custID FROM @tmp_custID)
	--Inhouse Tables
	--DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE c
	OUTPUT deleted.custid, deleted.seqNo, [dbo].[f_GetDateTime2]() 
	INTO CustVirtualSetting_Del_Inhouse(custid,seqNo,RepUpdateTime)
	FROM CustVirtualSetting c WITH(ROWLOCK) 
	WHERE custid IN (SELECT custID FROM @tmp_custID)

		
	--Delete setting deposit
	DELETE Dep_CustProductSetting 
	OUTPUT DELETED.custid, DELETED.ProductID,dbo.f_GetDateTime2()
	INTO Dep_CustProductSetting_Del_InHouse(custid,ProductID,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE Dep_CustSetting_AGCasino 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSetting_AGCasino_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustSettingGame_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustProductStatus_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustPTSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Member_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustSettingMode 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSettingMode_Del_InHouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustDiscountSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
	DELETE dbo.Dep_CustBetSetting_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Agent 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Agent_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE dbo.Dep_CustBetSettingGame_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGameGroup_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID = @custid
	
	DELETE dbo.Dep_CustDiscountGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,RepUpdateTime)
	WHERE AgentID = @custid	
	
	DELETE dbo.Dep_CustPTGroupSetting_Member 
	OUTPUT DELETED.AgentID, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTGroupSetting_Member_Del_InHouse(AgentID,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE AgentID = @custid

	DELETE custinfo 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO custinfo_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	DELETE customer 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO customer_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid IN (SELECT custID FROM @tmp_custID)

	IF @@ERROR <> 0
	BEGIN	
		SELECT @ErrMsg = N'Delete customer failed.', @ErrCode = 103
		RETURN
	END	
END

IF @roleid = 1
BEGIN
	IF EXISTS (SELECT 1 FROM DBTXN.bodb02.dbo.bettrans WITH (NOLOCK) WHERE custid = @custid)
	BEGIN
		SELECT @ErrMsg = N'Got bettrans already. Cannot delete.', @ErrCode = 100
		RETURN
	END
	--Delete cust login info
	DELETE CustLoginInfo_Member WITH (ROWLOCK)   
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustLoginInfo_Member_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid = @custid	

	DELETE dbo.CustDirectAccount WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustDirectAccount_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid = @custid		
	
	DELETE dbo.Acc_CustAllowList WITH (ROWLOCK)  
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustAllowList_Del_InHouse(CustID, RepUpdateTime)
	WHERE custid = @custid	
	
	DELETE dbo.Acc_CustDirect WITH (ROWLOCK) 
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.Acc_CustDirect_Del_InHouse(custid, RepUpdateTime)
	WHERE custid = @custid	

	DELETE dbo.Cust12Bet WHERE custid = @custid	
	
	DELETE dbo.custAccount WITH (ROWLOCK)
		OUTPUT DELETED.custid, dbo.f_GetDateTime2()
		INTO dbo.custAccount_Del_Inhouse(custid, RepUpdateTime)
	WHERE custid = @custid	
	
	DELETE dbo.CustGroupHeadline WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustGroupHeadline_Del_Inhouse(CustID, RepUpdateTime)
	WHERE custid = @custid	

	DELETE dbo.CustNoComm WITH (ROWLOCK) 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO dbo.CustNoComm_Del_Inhouse(CustID, RepUpdateTime) 
	WHERE custid = @custid	

	--DELETE dbo.CustRequestGame WHERE custid = @custid	
	
	DELETE dbo.Dep_CustBAActive 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustBAActive_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	--DCS table
	DELETE dbo.CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustProductStatus_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.CustPTSetting3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO CustPTSetting3rd_Member_Del_Inhouse(custid,SportType,Bettype,IsLive,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.CustSettingMode3rd 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO CustSettingMode3rd_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustStakeLevel_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.CustWinLossLimit_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustWinLossLimit_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.CustBetSetting3rd_Member WHERE custid = @custid
	
	DELETE dbo.CustDiscount3rd_Member 
	OUTPUT DELETED.custid, DELETED.SportType, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO CustDiscount3rd_Member_Del_Inhouse(custid,SportType,Bettype,RepUpdateTime)
	WHERE custid = @custid

	DELETE dbo.BetSetting3rd_Member 
	OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
	INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid
	
	--Inhouse Tables
	--DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @custid

	DELETE c
	OUTPUT deleted.custid, deleted.seqNo, [dbo].[f_GetDateTime2]() 
	INTO CustVirtualSetting_Del_Inhouse(custid,seqNo,RepUpdateTime)
	FROM CustVirtualSetting c WITH(ROWLOCK) 
	WHERE custid = @custid
		
	DELETE BetSetting_Member WITH (ROWLOCK)
	OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],dbo.f_GetDateTime2()
	INTO [BetSetting_Member_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
	WHERE  custid = @custid
	
	--Delete setting deposit
	DELETE Dep_CustProductSetting 
	OUTPUT DELETED.custid, DELETED.ProductID,dbo.f_GetDateTime2()
	INTO Dep_CustProductSetting_Del_InHouse(custid,ProductID,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE Dep_CustSetting_AGCasino 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSetting_AGCasino_Del_InHouse(custid,RepUpdateTime)
	WHERE custid = @custid

	DELETE dbo.Dep_CustSettingGame 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustSettingGame_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid

	--DCS table
	DELETE dbo.Dep_CustProductStatus 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustProductStatus_Del_InHouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.Dep_CustPTSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, DELETED.IsLive, dbo.f_GetDateTime2()
	INTO Dep_CustPTSetting_Member_Del_InHouse(custid,Sporttype,Bettype,IsLive,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.Dep_CustSettingMode
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO Dep_CustSettingMode_Del_InHouse(custid,RepUpdateTime)
	WHERE custid = @custid

	DELETE dbo.Dep_CustStakeLevel_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustStakeLevel_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid

	DELETE dbo.Dep_CustDiscountSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustDiscountSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid

	DELETE dbo.Dep_CustBetSetting_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSetting_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE dbo.Dep_CustBetSettingGame_Member 
	OUTPUT DELETED.custid, DELETED.Sporttype, DELETED.Bettype, dbo.f_GetDateTime2()
	INTO Dep_CustBetSettingGame_Member_Del_InHouse(custid,Sporttype,Bettype,RepUpdateTime)
	WHERE custid = @custid

	DELETE custinfo 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO custinfo_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
	
	DELETE customer 
	OUTPUT DELETED.custid, dbo.f_GetDateTime2()
	INTO customer_Del_Inhouse(custid,RepUpdateTime)
	WHERE custid = @custid
		
	IF @@ERROR <> 0
	BEGIN	
		SELECT @ErrMsg = N'Delete customer failed.', @ErrCode = 104
		RETURN
	END
	
	--delete licensee customer on bodb_licensee
	EXEC bodb_licensee.dbo.DBA_LicenseeCustomerDel 
		@custid = @custid, 
		@roleid = @roleid,
		@ErrCode  = @ErrCode OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT

	IF @ErrCode <> 0 
	BEGIN 
		SELECT @ErrCode = @ErrCode, @ErrMsg = @ErrMsg
		RETURN
	END
	
END

PRINT @username + ' - '+ @ErrMsg