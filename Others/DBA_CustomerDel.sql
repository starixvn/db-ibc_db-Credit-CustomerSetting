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

	DELETE CustSuper WHERE custid = @custid	
	DELETE CustMaster WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 3)
	DELETE CustAgent WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)
	--delete subacc
	DELETE custsub WHERE custid IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid in(4,3,2))
	
	-- delete licensee superid
	DELETE Dep_CustSuper WHERE custid = @custid		

	--insert downline custids into @tmp_custID	
	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE srecommend = @custid
		
	--Delete cust login info
	DELETE CustLoginInfo WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE CustLoginInfo_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustLoginInfoSub WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustAllowList WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustDirect WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.custAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustGroupHeadline WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustNoComm WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTP WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTPDetail WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBAActive WHERE custid IN (SELECT custID FROM @tmp_custID)	

	--Delete setting credit
	DELETE custsetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE custoverride WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustSettingMode3rd WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE CustPTGroupSetting3rd_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	

	--Delete setting deposit	
	DELETE Dep_CustProductSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE Dep_CustSetting_AGCasino WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustSettingMode WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBetSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Member WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)
	DELETE dbo.Dep_CustDiscountGroupSetting_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	
	DELETE dbo.Dep_CustPTGroupSetting_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE srecommend = @custid and roleid = 2)	
	DELETE Dep_LicenseeProductSetting WHERE custid = @custid

	DELETE custinfo WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE customer WHERE custid IN (SELECT custID FROM @tmp_custID)		
	
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
	DELETE CustMaster WHERE custid = @custid
	DELETE CustAgent WHERE custid in (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)
	--delete subacc
	DELETE custsub where custid in (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid in(3,2))

	--insert downline custids into @tmp_custID
	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE mrecommend = @custid
	
	--Delete cust login info
	DELETE CustLoginInfo WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE CustLoginInfo_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustLoginInfoSub WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustAllowList WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustDirect WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.custAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustGroupHeadline WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustNoComm WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTP WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTPDetail WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBAActive WHERE custid IN (SELECT custID FROM @tmp_custID)

	--Delete setting credit
	DELETE custsetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE custoverride WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	--DCS table
	DELETE dbo.CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustSettingMode3rd WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE CustPTGroupSetting3rd_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)	

	--Delete setting deposit
	DELETE Dep_CustProductSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE Dep_CustSetting_AGCasino WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustSettingMode WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBetSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Member WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)
	DELETE dbo.Dep_CustDiscountGroupSetting_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)		
	DELETE dbo.Dep_CustPTGroupSetting_Member WHERE AgentID IN (SELECT custid FROM customer WITH (NOLOCK) WHERE mrecommend = @custid and roleid = 2)	

	DELETE custinfo WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE customer WHERE custid IN (SELECT custID FROM @tmp_custID)	
	
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
	DELETE CustAgent WHERE custid = @custid
	--delete subacc
	DELETE custsub WHERE custid = @custid	 

	DELETE @tmp_custID
	INSERT INTO @tmp_custID
	SELECT custID FROM customer WITH (NOLOCK) WHERE recommend = @custid
	
	--Delete cust login info
	DELETE CustLoginInfo WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE CustLoginInfo_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustLoginInfoSub WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE dbo.CustDirectAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustAllowList WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Acc_CustDirect WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.BetTradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.TradeCust WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Cust12Bet WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.custAccount WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustGroupHeadline WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustNoComm WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTP WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustOTPDetail WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustRequestGame WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBAActive WHERE custid IN (SELECT custID FROM @tmp_custID)

	--Delete setting credit
	DELETE custsetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE custoverride WHERE custid IN (SELECT custID FROM @tmp_custID)
	
	--DCS table
	DELETE dbo.CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustPTSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustSettingMode3rd WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustWinLossLimit_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustVirtualSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustBetSetting3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.CustDiscount3rd_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)	

	DELETE CustPTGroupSetting3rd_Member WHERE AgentID = @custid

	--Delete setting deposit
	DELETE Dep_CustProductSetting WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE Dep_CustSetting_AGCasino WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustSettingGame WHERE custid IN (SELECT custID FROM @tmp_custID)

	--DCS table
	DELETE dbo.Dep_CustProductStatus WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustPTSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustSettingMode WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustStakeLevel_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustDiscountSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)	
	DELETE dbo.Dep_CustBetSetting_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSetting_Member WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Agent WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE dbo.Dep_CustBetSettingGame_Member WHERE custid IN (SELECT custID FROM @tmp_custID)

	DELETE dbo.Dep_CustBetSettingGameGroup_Member WHERE AgentID = @custid
	DELETE dbo.Dep_CustDiscountGroupSetting_Member WHERE AgentID = @custid	
	DELETE dbo.Dep_CustPTGroupSetting_Member WHERE AgentID = @custid

	DELETE custinfo WHERE custid IN (SELECT custID FROM @tmp_custID)
	DELETE customer WHERE custid IN (SELECT custID FROM @tmp_custID)

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
	DELETE CustLoginInfo_Member WHERE custid = @custid	

	DELETE dbo.CustDirectAccount WHERE custid = @custid		
	DELETE dbo.Acc_CustAllowList WHERE custid = @custid	
	DELETE dbo.Acc_CustDirect WHERE custid = @custid	
	DELETE dbo.Cust12Bet WHERE custid = @custid	
	DELETE dbo.custAccount WHERE custid = @custid	
	DELETE dbo.CustGroupHeadline WHERE custid = @custid	
	DELETE dbo.CustNoComm WHERE custid = @custid	
	DELETE dbo.CustRequestGame WHERE custid = @custid	
	DELETE dbo.CustVirtualSetting WHERE custid = @custid
	DELETE dbo.Dep_CustBAActive WHERE custid = @custid

	--Delete setting credit
	DELETE custsetting WHERE custid = @custid
	
	--DCS table
	DELETE dbo.CustProductStatus WHERE custid = @custid
	DELETE dbo.CustPTSetting3rd_Member WHERE custid = @custid
	DELETE dbo.CustSettingMode3rd WHERE custid = @custid
	DELETE dbo.CustStakeLevel_Member WHERE custid = @custid
	DELETE dbo.CustWinLossLimit_Member WHERE custid = @custid
	DELETE dbo.CustVirtualSetting WHERE custid = @custid
	DELETE dbo.CustBetSetting3rd_Member WHERE custid = @custid
	DELETE dbo.CustDiscount3rd_Member WHERE custid = @custid

	--Delete setting deposit
	DELETE Dep_CustProductSetting WHERE custid = @custid
	DELETE Dep_CustSetting_AGCasino WHERE custid = @custid

	DELETE dbo.Dep_CustSettingGame WHERE custid = @custid

	--DCS table
	DELETE dbo.Dep_CustProductStatus WHERE custid = @custid
	DELETE dbo.Dep_CustPTSetting_Member WHERE custid = @custid
	DELETE dbo.Dep_CustSettingMode WHERE custid = @custid
	DELETE dbo.Dep_CustStakeLevel_Member WHERE custid = @custid
	DELETE dbo.Dep_CustDiscountSetting_Member WHERE custid = @custid
	DELETE dbo.Dep_CustBetSetting_Member WHERE custid = @custid
	DELETE dbo.Dep_CustBetSettingGame_Member WHERE custid = @custid

	DELETE custinfo WHERE custid = @custid
	DELETE customer WHERE custid = @custid
		
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