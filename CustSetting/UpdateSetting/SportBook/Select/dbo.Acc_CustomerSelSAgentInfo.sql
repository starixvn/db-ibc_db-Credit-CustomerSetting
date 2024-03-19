/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelSAgentInfo] 
	@CustID int, @Site VARCHAR(50) = ''
AS
/*
Created by: []
Date: []
Task: Super create Master or edit Multiple Master AT AGENT SITE
DB: DBCUST.CustDB
Original: agentsite\account\addnewmember.asp
Revisions:
	- 20090336@PhuongDoan: remove '_1' in SP name
	- 20090901@Shifu: add IsInternal	
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100803@Henry: grant execute permission to [bodbExtAccNet,wsv_xnap]
	- 20100828@Henry: Add Mix Parlay Mixed Sports & Number Game
	- 20101027@Lukas: Add max per ball (number game)
	- 20110727@Lukas: (Number Game)
				- Add more bettypes: Warrior, Next Combo, Number Group
				- Remove Dead ball Over/Under
	- 20120327@Dan: uncomment the block of code that return the max username (don't know who has commented it)
	- 20120726@Johnson: suggest new username
	- 20130121@Dan: call to DBAGE/bodb_AGE for Age_CustomerSelSuggestUsername sp because moving this SP to bodb_AGE 
	- 20131017@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20131029@Elodie: Put link server DBAGE [Redmine:#7261]	
	- 20140701@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181123@Helen: DB053.bodb_AGE/BODB02 & DB052.bodb_Summary Migration [Redmine: 104770]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]	
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20230310@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
*/
BEGIN
	SET NOCOUNT ON

	Declare @UserName varchar(50), @UplineUserName varchar(50),@Ssuspended bit, @IsInternal bit
	Declare @MinBet_Max money, @MaxBet_Min money,
			@MinBetv2_Max money, @MaxBetv2_Min money,
			@MinBetv3_Max money, @MaxBetv3_Min money,
			@MinBetv5_Max money, @MaxBetv5_Min money,
			@MinBetv8_Max money, @MaxBetv8_Min money,
			@MinBetv10_Max money, @MaxBetv10_Min money,
			@MinBetv11_Max money, @MaxBetv11_Min money,
			@MinBetv99_Max money, @MaxBetv99_Min money,
			@MinBetv99MP_Max money,
			@MaxBetv99MP_Min money,
			@MaxPerMatchv99MP_Min money,
			@MaxPerMatchv99MP_Max money,
		
			@MinBetv1MP_Max money,
			@MaxBetv1MP_Min money,
			@MaxPerMatchv1MP_Min money,
		@MaxPerMatchv1MP_Max money,			
		
			@MaxPerMatch_Min money,
			@MaxPerMatchv2_Min money,
			@MaxPerMatchv3_Min money,
			@MaxPerMatchv5_Min money,
			@MaxPerMatchv8_Min money,
			@MaxPerMatchv10_Min money,
			@MaxPerMatchv11_Min money,		
			@MaxPerMatchv99_Min money,
		
			@maxdownline smallmoney,

			@MaxPerMatch_Max money,
			@MaxPerMatchv2_Max money,
			@MaxPerMatchv3_Max money,
			@MaxPerMatchv5_Max money,
			@MaxPerMatchv8_Max money,
			@MaxPerMatchv10_Max money,
			@MaxPerMatchv11_Max money,
			@MaxPerMatchv99_Max money,
			--Max Payout Per Match
			@MaxPayoutPerMatch_max money = 0,
			@MaxPayoutPerMatchv2_max money = 0,
			@MaxPayoutPerMatchv3_max money = 0,
			@MaxPayoutPerMatchv5_max money = 0,
			@MaxPayoutPerMatchv8_max money = 0,
			@MaxPayoutPerMatchv10_max money = 0,
			@MaxPayoutPerMatchv11_max money = 0,
			@MaxPayoutPerMatchv99_max money = 0,
			@MaxPayoutPerMatchv99mp_max money = 0,
			@MaxPayoutPerMatchv1mp_max money = 0,

			--- Saba soccer
			@MinBetv1saba_Max            MONEY = 0, 
			@MaxBetv1saba_Min            MONEY = 0, 
			@MaxPerMatchv1saba_Min       MONEY = 0, 
			@MaxPerMatchv1saba_Max       MONEY = 0, 
			@MaxPayoutPerMatchv1saba_max MONEY = 0,
			--- Saba Basketball
			@MinBetv2saba_Max            MONEY = 0, 
			@MaxBetv2saba_Min            MONEY = 0, 
			@MaxPerMatchv2saba_Min       MONEY = 0, 
			@MaxPerMatchv2saba_Max       MONEY = 0, 
			@MaxPayoutPerMatchv2saba_max MONEY = 0,
		
			@Credit_AllOtherMaster money, @Credit_SAg money, @Credit_MAg_Max money,
			@AllowedCurr bit,
			@CurrencyID int, 
			@srecommend INT = 0
		
	Select @Credit_AllOtherMaster = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where srecommend = @CustID and RoleID = 3
	select @Credit_SAg = isnull(credit, 0), @CurrencyID=ci.currency ,@srecommend = srecommend,@UplineUserName = username from CustInfo as ci with (NOLOCK) where CustID = @CustID
	SELECT @Ssuspended = CASE WHEN cps.SuspendInfo > 0 THEN 1 ELSE 0 END FROM CustProductStatus cps WITH (NOLOCK) WHERE CustID = @CustID
	Select @IsInternal = isnull(IsInternal, 0) from custsuper with (NOLOCK) where CustID = @CustId
	if @CustID <= 100
	BEGIN
		--Set unlimited for dummy super
		select @Credit_MAg_Max = 10000000000
	END
	ELSE
	BEGIN
		select @Credit_MAg_Max = @Credit_SAg - @Credit_AllOtherMaster
	END

	--Get BetSetting limit
	EXEC Age_CustomerSelMinMaxLimit @custid = @custid, @IsCreatedDowline = 1,
		@MinBet_Max = @MinBet_Max output, @MaxBet_Min = @MaxBet_Min output, @MaxPerMatch_Min = @MaxPerMatch_Min output, @MaxPerMatch_Max = @MaxPerMatch_Max output,
		@MinBetv2_Max = @MinBetv2_Max output, @MaxBetv2_Min = @MaxBetv2_Min output, @MaxPerMatchv2_Min = @MaxPerMatchv2_Min output, @MaxPerMatchv2_Max = @MaxPerMatchv2_Max output,
		@MinBetv3_Max = @MinBetv3_Max output, @MaxBetv3_Min = @MaxBetv3_Min output, @MaxPerMatchv3_Min = @MaxPerMatchv3_Min output, @MaxPerMatchv3_Max = @MaxPerMatchv3_Max output,
		@MinBetv5_Max = @MinBetv5_Max output, @MaxBetv5_Min = @MaxBetv5_Min output, @MaxPerMatchv5_Min = @MaxPerMatchv5_Min output, @MaxPerMatchv5_Max = @MaxPerMatchv5_Max output,
		@MinBetv8_Max = @MinBetv8_Max output, @MaxBetv8_Min = @MaxBetv8_Min output, @MaxPerMatchv8_Min = @MaxPerMatchv8_Min output, @MaxPerMatchv8_Max = @MaxPerMatchv8_Max output,
		@MinBetv10_Max = @MinBetv10_Max output, @MaxBetv10_Min = @MaxBetv10_Min output, @MaxPerMatchv10_Min = @MaxPerMatchv10_Min output, @MaxPerMatchv10_Max = @MaxPerMatchv10_Max output,
		@MinBetv11_Max = @MinBetv11_Max output, @MaxBetv11_Min = @MaxBetv11_Min output, @MaxPerMatchv11_Min = @MaxPerMatchv11_Min output, @MaxPerMatchv11_Max = @MaxPerMatchv11_Max output,
		@MinBetv99_Max = @MinBetv99_Max output, @MaxBetv99_Min = @MaxBetv99_Min output, @MaxPerMatchv99_Min = @MaxPerMatchv99_Min output, @MaxPerMatchv99_Max = @MaxPerMatchv99_Max output,		
		@MinBetv99MP_Max = @MinBetv99MP_Max output, @MaxBetv99MP_Min = @MaxBetv99MP_Min output, @MaxPerMatchv99MP_Min = @MaxPerMatchv99MP_Min output, @MaxPerMatchv99MP_Max = @MaxPerMatchv99MP_Max output,
		@MinBetv1MP_Max = @MinBetv1MP_Max output, @MaxBetv1MP_Min = @MaxBetv1MP_Min output, @MaxPerMatchv1MP_Min = @MaxPerMatchv1MP_Min output, @MaxPerMatchv1MP_Max = @MaxPerMatchv1MP_Max output,
		@MaxPayoutPerMatch_max      = @MaxPayoutPerMatch_max      OUTPUT,
		@MaxPayoutPerMatchv2_max    = @MaxPayoutPerMatchv2_max    OUTPUT,
		@MaxPayoutPerMatchv3_max    = @MaxPayoutPerMatchv3_max    OUTPUT,
		@MaxPayoutPerMatchv5_max    = @MaxPayoutPerMatchv5_max    OUTPUT,
		@MaxPayoutPerMatchv8_max    = @MaxPayoutPerMatchv8_max    OUTPUT,
		@MaxPayoutPerMatchv10_max   = @MaxPayoutPerMatchv10_max   OUTPUT,
		@MaxPayoutPerMatchv11_max   = @MaxPayoutPerMatchv11_max   OUTPUT,
		@MaxPayoutPerMatchv99_max   = @MaxPayoutPerMatchv99_max   OUTPUT,
		@MaxPayoutPerMatchv99mp_max = @MaxPayoutPerMatchv99mp_max OUTPUT,
		@MaxPayoutPerMatchv1mp_max  = @MaxPayoutPerMatchv1mp_max  OUTPUT,
		--saba
		@MinBetv1saba_Max = @MinBetv1saba_Max output, @MaxBetv1saba_Min = @MaxBetv1saba_Min output, @MaxPerMatchv1saba_Min = @MaxPerMatchv1saba_Min output, 
		@MaxPerMatchv1saba_Max = @MaxPerMatchv1saba_Max output, @MaxPayoutPerMatchv1saba_max = @MaxPayoutPerMatchv1saba_max OUTPUT,
		@MinBetv2saba_Max = @MinBetv2saba_Max output, @MaxBetv2saba_Min = @MaxBetv2saba_Min output, @MaxPerMatchv2saba_Min = @MaxPerMatchv2saba_Min output, 
		@MaxPerMatchv2saba_Max = @MaxPerMatchv2saba_Max output, @MaxPayoutPerMatchv2saba_max = @MaxPayoutPerMatchv2saba_max OUTPUT

	-- Myanmar Odds

	DECLARE @discountMyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0
	DECLARE @SiteAgent NVARCHAR(50), @SiteLabel VARCHAR(50)

	SELECT @SiteAgent = c.site, @SiteLabel=s.SiteLabel 
	FROM customer c WITH(NOLOCK) 
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @srecommend

	-- For direct Master
	 IF @srecommend > 100 -- get site FROM upline IF not direct master
		 BEGIN
			   SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@SiteAgent)
		 END
		 ELSE
		 BEGIN
		   		-- For Direct Master
				SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)
		 END
	
	IF @IsMyanmarOdds = 1
		SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1)

	/*
	Select @Username = max(username) from customer with (nolock) where srecommend = @custid and roleid = 3
	--print @username
	if isnumeric(right(@username,2)) = 1
	BEGIN
		if convert(int, right(@username, 2)) < 99
		BEGIN
			select @username = right('00' + convert(varchar(2), convert(int, right(@username, 2)) + 1),2)
		END
		else
		BEGIN
			select @UserName = '01'
		END
	END
	else
	BEGIN
		select @UserName = '01'
	END
	*/

	EXEC dbo.Age_CustomerSelSuggestUsername @prefix = @uplineusername,@custid = @custid, @roleid = 4, @seqname = @username output

	Select 
		@UserName as NewUserName,
		@Ssuspended as suspended,
		@Credit_MAg_Max as Credit_Max,		
		@AllowedCurr AS AllowedCurr,
		@IsInternal as IsInternal,	
		--------------------------------
		--Get m4,, to check m3<=m4 on the web
		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_3_max,
		max(case when cs.bettype = 4 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_4_max,
		max(case when cs.bettype = 5 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_5_max,
		max(case when cs.bettype = 6 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_6_max,
		max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_8_max,
		max(case when cs.bettype = 9 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_9_max,
		max(case when cs.bettype = 10 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_10_max,
		max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_9999_max,

		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_1_max,
		max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_3_max,
		max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_8_max,

		max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_3_max,
		max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_8_max,
		--max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9_max,	
		max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_20_max,
		max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9999_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_3_max,	
		max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_20_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_3_max,	
		max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_20_max,
		max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_9999_max,	
	
		max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_1_max,	
		max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_3_max,	
		max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_20_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_3_max,	
		max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_20_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_1_max,	
		max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_20_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3_max,	
		max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9_max,
		max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20_max,
		max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9999_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_3,
		max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_4,
		max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_5,
		max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_6,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_8,
		max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_9,
		max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_10,
		max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as spositiontaking_9999,

		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_1,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_3,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as slivepositiontaking_8,

		max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_3,
		max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_8,
		--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_9,
		max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2spositiontaking_9999,
	
		max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3spositiontaking_20,
	
		max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5spositiontaking_9999,
	
		max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_1,
		max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8spositiontaking_20,
	
		max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10spositiontaking_20,
	
		max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11spositiontaking_1,
		max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11spositiontaking_20,

		max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_3,
		max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_9,
		max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99spositiontaking_9999,
	
	--	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.discount else 0 end) as discount,
		max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
		max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
	
		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
		max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	
		-- For MyanmarOdds
		ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
		ISNULL(@discountMyanmarOdds,0) AS discountMyanmarOdds,
	
		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_3,
		max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_4,
		max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_5,
		max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_6,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_8,
		max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_9,
		max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v11spositiontaking_10,
		max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_10,
		max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_spositiontaking_9999,

		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_1,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_3,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_slivepositiontaking_8,

		max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_3,
		max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_7,
		max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_8,
		--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_9,
		max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v2spositiontaking_9999,
	
		max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v3spositiontaking_20,

		max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v5spositiontaking_9999,

		max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_1,
		max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v8spositiontaking_20,

		max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_3,
		max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v10spositiontaking_20,

		max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v11spositiontaking_1,
		max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v11spositiontaking_20,

		max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_1,
		max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_2,
		max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_3,
		max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_9,
		max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_20,
		max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as auto_v99spositiontaking_9999,
		
		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_3_max,
		max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_4_max,
		max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_5_max,
		max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_6_max,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_8_max,
		max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_9_max,
		max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11mspositiontaking_10_max,
		max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_10_max,
		max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as mspositiontaking_9999_max,

		max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_1_max,
		max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_3_max,
		max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end) as mslivepositiontaking_8_max,

		max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_3_max,
		max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_7_max,
		max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_8_max,
		--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_9_max,
		max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_20_max,
		max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v2mspositiontaking_9999_max,

		max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_3_max,
		max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v3mspositiontaking_20_max,

		max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_3_max,
		max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_20_max,
		max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v5mspositiontaking_9999_max,

		max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_1_max,
		max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_3_max,
		max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v8mspositiontaking_20_max,

		max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_3_max,
		max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v10mspositiontaking_20_max,

		max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11mspositiontaking_1_max,
		max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v11mspositiontaking_20_max,
	
		max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_1_max,
		max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_2_max,
		max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_3_max,
		max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_9_max,
		max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_20_max,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end) as v99mspositiontaking_9999_max,			
		
		max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_3_min,
		max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_4_min,
		max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_5_min,
		max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_6_min,
		max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_7_min,
		max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_8_min,
		max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_9_min,
		max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mspositiontaking_10_min,
		max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_10_min,
		max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end) as mspositiontaking_9999_min,

		max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_1_min,
		max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_3_min,
		max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_7_min,
		max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mslivepositiontaking_8_min,

		max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_3_min,
		max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_7_min,
		max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_8_min,
		--max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_9_min,
		max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_20_min,
		max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mspositiontaking_9999_min,
	
		max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_3_min,
		max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mspositiontaking_20_min,
	
		max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_3_min,
		max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_20_min,
		max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mspositiontaking_9999_min,
	
		max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_1_min,
		max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_3_min,
		max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mspositiontaking_20_min,
	
		max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_3_min,
		max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mspositiontaking_20_min,
	
		max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mspositiontaking_1_min,
		max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mspositiontaking_20_min,
	
		max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_1_min,
		max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_2_min,
		max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_3_min,
		max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_9_min,
		max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_20_min,
		max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mspositiontaking_9999_min,
	
		@SiteAgent AS Site,
		@SiteLabel AS SiteLabel,
		IsNull(@MinBet_Max, 0) as MinBet_Max,
		IsNull(@MaxBet_Min, 0) as MaxBet_Min,
		IsNull(@MaxPerMatch_Min, 0) as MaxPerMatch_Min,
		IsNull(@MaxPerMatch_Max, 0) as MaxPerMatch_Max,
	
		IsNull(@MinBetv2_Max, 0) as MinBetv2_Max,	
		IsNull(@MaxBetv2_Min, 0) as MaxBetv2_Min,	
		IsNull(@MaxPerMatchv2_Min, 0) as MaxPerMatchv2_Min,	
		IsNull(@MaxPerMatchv2_Max, 0) as MaxPerMatchv2_Max,	
	
		IsNull(@MinBetv3_Max, 0) as MinBetv3_Max,	
		IsNull(@MaxBetv3_Min, 0) as MaxBetv3_Min,	
		IsNull(@MaxPerMatchv3_Min, 0) as MaxPerMatchv3_Min,	
		IsNull(@MaxPerMatchv3_Max, 0) as MaxPerMatchv3_Max,

		IsNull(@MinBetv5_Max, 0) as MinBetv5_Max,	
		IsNull(@MaxBetv5_Min, 0) as MaxBetv5_Min,	
		IsNull(@MaxPerMatchv5_Min, 0) as MaxPerMatchv5_Min,	
		IsNull(@MaxPerMatchv5_Max, 0) as MaxPerMatchv5_Max,

		IsNull(@MinBetv8_Max, 0) as MinBetv8_Max,	
		IsNull(@MaxBetv8_Min, 0) as MaxBetv8_Min,	
		IsNull(@MaxPerMatchv8_Min, 0) as MaxPerMatchv8_Min,	
		IsNull(@MaxPerMatchv8_Max, 0) as MaxPerMatchv8_Max,

		IsNull(@MinBetv10_Max, 0) as MinBetv10_Max,	
		IsNull(@MaxBetv10_Min, 0) as MaxBetv10_Min,	
		IsNull(@MaxPerMatchv10_Min, 0) as MaxPerMatchv10_Min,	
		IsNull(@MaxPerMatchv10_Max, 0) as MaxPerMatchv10_Max,

		IsNull(@MinBetv11_Max, 0) as MinBetv11_Max,	
		IsNull(@MaxBetv11_Min, 0) as MaxBetv11_Min,	
		IsNull(@MaxPerMatchv11_Min, 0) as MaxPerMatchv11_Min,	
		IsNull(@MaxPerMatchv11_Max, 0) as MaxPerMatchv11_Max,

		IsNull(@MinBetv99_Max, 0) as MinBetv99_Max,	
		IsNull(@MaxBetv99_Min, 0) as MaxBetv99_Min,	
		IsNull(@MaxPerMatchv99_Min, 0) as MaxPerMatchv99_Min,	
		IsNull(@MaxPerMatchv99_Max, 0) as MaxPerMatchv99_Max,
	
		IsNull(@MinBetv99MP_Max, 0) as MinBetv99MP_Max,	
		IsNull(@MaxBetv99MP_Min, 0) as MaxBetv99MP_Min,	
		IsNull(@MaxPerMatchv99MP_Min, 0) as MaxPerMatchv99MP_Min,	
		IsNull(@MaxPerMatchv99MP_Max, 0) as MaxPerMatchv99MP_Max,
	
		IsNull(@MinBetv1MP_Max, 0) as MinBetv1MP_Max,	
		IsNull(@MaxBetv1MP_Min, 0) as MaxBetv1MP_Min,	
		IsNull(@MaxPerMatchv1MP_Min, 0) as MaxPerMatchv1MP_Min,	
		IsNull(@MaxPerMatchv1MP_Max, 0) as MaxPerMatchv1MP_Max,
		
		--> MaxMaxPayoutPerMatch
		@MaxPayoutPerMatch_max AS MaxPayoutPerMatch_max, 
		@MaxPayoutPerMatchv2_max AS MaxPayoutPerMatchv2_max, 
		@MaxPayoutPerMatchv3_max AS MaxPayoutPerMatchv3_max, 
		@MaxPayoutPerMatchv5_max AS MaxPayoutPerMatchv5_max, 
		@MaxPayoutPerMatchv8_max AS MaxPayoutPerMatchv8_max, 
		@MaxPayoutPerMatchv10_max AS MaxPayoutPerMatchv10_max, 
		@MaxPayoutPerMatchv11_max AS MaxPayoutPerMatchv11_max, 
		@MaxPayoutPerMatchv99_max AS MaxPayoutPerMatchv99_max, 
		@MaxPayoutPerMatchv99mp_max AS MaxPayoutPerMatchv99mp_max, 
		@MaxPayoutPerMatchv1mp_max AS MaxPayoutPerMatchv1mp_max,
		--saba
		ISNULL(@MinBetv1saba_Max			,0)	AS MinBetv1saba_Max,
		ISNULL(@MaxBetv1saba_Min			,0)	AS MaxBetv1saba_Min,
		ISNULL(@MaxPerMatchv1saba_Min 		,0)	AS MaxPerMatchv1saba_Min ,
		ISNULL(@MaxPerMatchv1saba_Max 		,0)	AS MaxPerMatchv1saba_Max ,
		ISNULL(@MaxPayoutPerMatchv1saba_max	,0) AS MaxPayoutPerMatchv1saba_max,
		ISNULL(@MinBetv2saba_Max			,0)	AS MinBetv2saba_Max,
		ISNULL(@MaxBetv2saba_Min			,0)	AS MaxBetv2saba_Min,
		ISNULL(@MaxPerMatchv2saba_Min 		,0)	AS MaxPerMatchv2saba_Min ,
		ISNULL(@MaxPerMatchv2saba_Max 		,0)	AS MaxPerMatchv2saba_Max ,
		ISNULL(@MaxPayoutPerMatchv2saba_max	,0)	AS MaxPayoutPerMatchv2saba_max
	From 
		CustSetting as cs with (NOLOCK)
		LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
	Where cs.CustID = @CustID
END
GO