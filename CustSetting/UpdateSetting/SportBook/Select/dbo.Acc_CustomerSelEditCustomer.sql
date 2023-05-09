/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditCustomer]
	@CustID int
AS
--Original:???
--AGENT SITE
--Agent edit member
/*
Created: 
Task : Agent edit member
DB: DBCUST.CustDB

Revisions:
    - 20090317@Phuc: disable FI, HR 	
    - @PphuongDoan: remove '_1' on the SP name
    - 20090407@Lee: add 2 return fields for casino
    - 20090515@PhuongDao: Add 1x2 Commission 
    - 20090521@PhuongDao: Get maxcredit from custAgent 
    - 20090630@Phuc: auto master PT on member level.
    - 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100729@Shifu: Grant execute for bodbExAccNet
	- 20100830@Henry: Add Mix Parlay Mixed Sports & Number Game
	- 20101028@Lukas: Add max per ball (number game)
	- 20110119@Johnson: separate to get setting from custsetting and custsetting3rd
    - 20110801@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20120503@Dan: return DisableLiveCasino
	- 20120912@Johnson: check a1_max with m4
	- 20130614@Johnson: correct a1_max for soccer				
	- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161012@Elodie: Get more currency field - [Redmine: #60809]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170420@Helen:  Add Extra information for Direct Accounts, for NAP only - [Redmine:72339]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190308@Elodie: add nolock for select statement 
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20230310@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
• @CustID: member ID
*/
BEGIN

Declare @MinBet_Max money, @MaxBet_Min money, @MaxPerMatch_Min money, @MaxPerMatch_Max money,
		@MinBetv2_Max money, @MaxBetv2_Min money, @MaxPerMatchv2_Min money, @MaxPerMatchv2_Max money,
		@MinBetv3_Max money, @MaxBetv3_Min money, @MaxPerMatchv3_Min money, @MaxPerMatchv3_Max money,
		@MinBetv5_Max money, @MaxBetv5_Min money, @MaxPerMatchv5_Min money, @MaxPerMatchv5_Max money,
		@MinBetv8_Max money, @MaxBetv8_Min money, @MaxPerMatchv8_Min money, @MaxPerMatchv8_Max money,
		@MinBetv10_Max money, @MaxBetv10_Min money, @MaxPerMatchv10_Min money, @MaxPerMatchv10_Max money,
		@MinBetv11_Max money, @MaxBetv11_Min money, @MaxPerMatchv11_Min money, @MaxPerMatchv11_Max money,
		@MinBetv99_Max money, @MaxBetv99_Min money, @MaxPerMatchv99_Min money, @MaxPerMatchv99_Max money,
		@MinBetv99MP_Max money, @MaxBetv99MP_Min money, @MaxPerMatchv99MP_Min money, @MaxPerMatchv99MP_Max money,
		@MinBetv1MP_Max money, @MaxBetv1MP_Min money, @MaxPerMatchv1MP_Min money, @MaxPerMatchv1MP_Max money,		
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
		
	@ap_1 smallmoney,@ap_2 smallmoney,@ap_3 smallmoney,@ap_4 smallmoney,@ap_5 smallmoney,@ap_6 smallmoney,@ap_7 smallmoney,@ap_8 smallmoney,@ap_9 smallmoney,@ap_10 smallmoney,@ap_9999 smallmoney,
	@alp_1 smallmoney,@alp_3 smallmoney,@alp_7 smallmoney,@alp_8 smallmoney,
	
	@v2ap_1 smallmoney,@v2ap_2 smallmoney,@v2ap_3 smallmoney,@v2ap_7 smallmoney,@v2ap_8 smallmoney,@v2ap_20 smallmoney,@v2ap_9999 smallmoney,
	@v3ap_1 smallmoney,@v3ap_2 smallmoney,@v3ap_3 smallmoney,@v3ap_20 smallmoney,
	@v5ap_1 smallmoney,@v5ap_2 smallmoney,@v5ap_3 smallmoney,@v5ap_20 smallmoney,@v5ap_9999 smallmoney,
	@v8ap_1 smallmoney,@v8ap_3 smallmoney,@v8ap_20 smallmoney,
	@v10ap_1 smallmoney,@v10ap_2 smallmoney,@v10ap_3 smallmoney,@v10ap_20 smallmoney,
	@v11ap_1 smallmoney,@v11ap_20 smallmoney,
	@v99ap_1 smallmoney,@v99ap_2 smallmoney,@v99ap_3 smallmoney,@v99ap_9 smallmoney,@v99ap_20 smallmoney,@v99ap_9999 smallmoney,	
	
	@cs_ap_1 smallmoney,@cs_ap_2 smallmoney,@cs_ap_3 smallmoney,@cs_ap_4 smallmoney,@cs_ap_5 smallmoney,@cs_ap_6 smallmoney,@cs_ap_7 smallmoney,@cs_ap_8 smallmoney,@cs_ap_9 smallmoney,@cs_ap_10 smallmoney,@cs_ap_9999 smallmoney,
	@cs_alp_1 smallmoney,@cs_alp_3 smallmoney,@cs_alp_7 smallmoney,@cs_alp_8 smallmoney,
	@cs_v2ap_1 smallmoney,@cs_v2ap_2 smallmoney,@cs_v2ap_3 smallmoney,@cs_v2ap_7 smallmoney,@cs_v2ap_8 smallmoney,@cs_v2ap_20 smallmoney,@cs_v2ap_9999 smallmoney,
	@cs_v3ap_1 smallmoney,@cs_v3ap_2 smallmoney,@cs_v3ap_3 smallmoney,@cs_v3ap_20 smallmoney,
	@cs_v5ap_1 smallmoney,@cs_v5ap_2 smallmoney,@cs_v5ap_3 smallmoney,@cs_v5ap_20 smallmoney,@cs_v5ap_9999 smallmoney,
	@cs_v8ap_1 smallmoney,@cs_v8ap_3 smallmoney,@cs_v8ap_20 smallmoney,
	@cs_v10ap_1 smallmoney,@cs_v10ap_2 smallmoney,@cs_v10ap_3 smallmoney,@cs_v10ap_20 smallmoney,
	@cs_v11ap_1 smallmoney,@cs_v11ap_20 smallmoney,
	@cs_v99ap_1 smallmoney,@cs_v99ap_2 smallmoney,@cs_v99ap_3 smallmoney,@cs_v99ap_9 smallmoney,@cs_v99ap_20 smallmoney,@cs_v99ap_9999 smallmoney,		
	
	@sp_1 smallmoney,@sp_2 smallmoney,@sp_3 smallmoney,@sp_4 smallmoney,@sp_5 smallmoney,@sp_6 smallmoney,@sp_7 smallmoney,@sp_8 smallmoney,@sp_9 smallmoney,@sp_10 smallmoney,@sp_9999 smallmoney,
	@slp_1 smallmoney,@slp_3 smallmoney,@slp_7 smallmoney,@slp_8 smallmoney,
	@v2sp_1 smallmoney,@v2sp_2 smallmoney,@v2sp_3 smallmoney,@v2sp_7 smallmoney,@v2sp_8 smallmoney,@v2sp_20 smallmoney,@v2sp_9999 smallmoney,
	@v3sp_1 smallmoney,@v3sp_2 smallmoney,@v3sp_3 smallmoney,@v3sp_20 smallmoney,
	@v5sp_1 smallmoney,@v5sp_2 smallmoney,@v5sp_3 smallmoney,@v5sp_20 smallmoney,@v5sp_9999 smallmoney,
	@v8sp_1 smallmoney,@v8sp_3 smallmoney,@v8sp_20 smallmoney,
	@v10sp_1 smallmoney,@v10sp_2 smallmoney,@v10sp_3 smallmoney,@v10sp_20 smallmoney,
	@v11sp_1 smallmoney,@v11sp_20 smallmoney,
	
	@v99sp_1 smallmoney,@v99sp_2 smallmoney,@v99sp_3 smallmoney,@v99sp_9 smallmoney,@v99sp_20 smallmoney,@v99sp_9999 smallmoney,	
	@Credit_AllOtherMember money, @Credit_Ag money,@Credit_Ag_Bal money, @Credit_Mem_Max money, @MaxCredit_Mem money ,
	
	-- Outright PT for sports
	@cs_v2ap_10 smallmoney,
	@cs_v3ap_10 smallmoney,
	@cs_v5ap_10 smallmoney,
	@cs_v8ap_10 smallmoney,
	@cs_v10ap_10 smallmoney,
	@cs_v11ap_10 smallmoney,
	@cs_v99ap_10 smallmoney,
	@v2sp_10 smallmoney,
	@v3sp_10 smallmoney,
	@v5sp_10 smallmoney,
	@v8sp_10 smallmoney,
	@v10sp_10 smallmoney,
	@v11sp_10 smallmoney,
	@v99sp_10 smallmoney
	
DECLARE @minbet                 MONEY = 0, 
        @maxbet                 MONEY = 0, 
        @maxpermatch            MONEY = 0, 
        @minbetv2               MONEY = 0, 
        @maxbetv2               MONEY = 0, 
        @maxpermatchv2          MONEY = 0, 
        @minbetv3               MONEY = 0, 
        @maxbetv3               MONEY = 0, 
        @maxpermatchv3          MONEY = 0, 
        @minbetv5               MONEY = 0, 
        @maxbetv5               MONEY = 0, 
        @maxpermatchv5          MONEY = 0, 
        @minbetv8               MONEY = 0, 
        @maxbetv8               MONEY = 0, 
        @maxpermatchv8          MONEY = 0, 
        @minbetv10              MONEY = 0, 
        @maxbetv10              MONEY = 0, 
        @maxpermatchv10         MONEY = 0, 
        @minbetv11              MONEY = 0, 
        @maxbetv11              MONEY = 0, 
        @maxpermatchv11         MONEY = 0, 
        @minbetv99              MONEY = 0, 
        @maxbetv99              MONEY = 0, 
        @maxpermatchv99         MONEY = 0, 
        @minbetv99mp            MONEY = 0, 
        @maxbetv99mp            MONEY = 0, 
        @maxpermatchv99mp       MONEY = 0, 
        @minbetv1mp             MONEY = 0, 
        @maxbetv1mp             MONEY = 0, 
        @maxpermatchv1mp        MONEY = 0,        
        @MaxPayoutPerMatch      MONEY = 0, 
        @MaxPayoutPerMatchv2    MONEY = 0, 
        @MaxPayoutPerMatchv3    MONEY = 0, 
        @MaxPayoutPerMatchv5    MONEY = 0, 
        @MaxPayoutPerMatchv8    MONEY = 0, 
        @MaxPayoutPerMatchv10   MONEY = 0, 
        @MaxPayoutPerMatchv11   MONEY = 0, 
        @MaxPayoutPerMatchv99   MONEY = 0, 
        @MaxPayoutPerMatchv99mp MONEY = 0, 
        @MaxPayoutPerMatchv1mp  MONEY = 0,
		--- Saba soccer
		@minbetv1saba				MONEY = 0, 
		@maxbetv1saba				MONEY = 0, 
		@maxpermatchv1saba			MONEY = 0, 
		@maxPayoutpermatchv1saba    MONEY = 0,
		--- Saba basketball
		@minbetv2saba				MONEY = 0, 
		@maxbetv2saba				MONEY = 0, 
		@maxpermatchv2saba			MONEY = 0, 
		@maxPayoutpermatchv2saba	MONEY = 0,

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
		@MaxPayoutPerMatchv2saba_max MONEY = 0

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @srecommend int, @mrecommend int, @recommend int  ,@site varchar(10),@sitelabel varchar(50) --, @Asuspended bit
select	@srecommend = srecommend ,@mrecommend = mrecommend, @recommend=recommend from custinfo with (NOLOCK) where custid = @custid
--select	@Asuspended = isnull(reject,0)
--from custinfo with (NOLOCK) where custid = @recommend

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @Credit_AllOtherMember = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where recommend = @recommend and RoleID = 1 AND CustID <> @CustID
select @Credit_Ag = isnull(credit, 0) from CustInfo as ci with (NOLOCK) where CustID = @recommend

SELECT @MaxCredit_Mem = isnull(maxcredit,0) ,@site = ca.site, @sitelabel=s.sitelabel
FROM CustAgent ca WITH (NOLOCK) 
INNER JOIN site s WITH (NOLOCK) ON s.site=ca.site
where ca.CustID = @recommend

select @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @Credit_Mem_Max = case when @MaxCredit_Mem =0 then @Credit_Ag_Bal
						      when @MaxCredit_Mem > @Credit_Ag_Bal then @Credit_Ag_Bal
							  else @MaxCredit_Mem end  
							  

Declare 
	@apositiontaking_1_max smallmoney,
	@apositiontaking_2_max smallmoney,
	@apositiontaking_3_max smallmoney,
	@apositiontaking_4_max smallmoney,
	@apositiontaking_5_max smallmoney,
	@apositiontaking_6_max smallmoney,
	@apositiontaking_7_max smallmoney,
	@apositiontaking_8_max smallmoney,
	@apositiontaking_9_max smallmoney,
	@apositiontaking_10_max smallmoney,
	@apositiontaking_9999_max smallmoney,
	
	@alivepositiontaking_1_max smallmoney,
	@alivepositiontaking_3_max smallmoney,
	@alivepositiontaking_7_max smallmoney,
	@alivepositiontaking_8_max smallmoney,
	
	@v2apositiontaking_1_max smallmoney,
	@v2apositiontaking_2_max smallmoney,
	@v2apositiontaking_3_max smallmoney,
	@v2apositiontaking_7_max smallmoney,
	@v2apositiontaking_8_max smallmoney,
	--@v2apositiontaking_9_max smallmoney,
	@v2apositiontaking_20_max smallmoney,
	@v2apositiontaking_9999_max smallmoney,
	
	@v3apositiontaking_1_max smallmoney,
	@v3apositiontaking_2_max smallmoney,
	@v3apositiontaking_3_max smallmoney,
	@v3apositiontaking_20_max smallmoney,

	@v5apositiontaking_1_max smallmoney,
	@v5apositiontaking_2_max smallmoney,
	@v5apositiontaking_3_max smallmoney,
	@v5apositiontaking_20_max smallmoney,
	@v5apositiontaking_9999_max smallmoney,

	@v8apositiontaking_1_max smallmoney,
	@v8apositiontaking_3_max smallmoney,
	@v8apositiontaking_20_max smallmoney,

	@v10apositiontaking_1_max smallmoney,
	@v10apositiontaking_2_max smallmoney,
	@v10apositiontaking_3_max smallmoney,
	@v10apositiontaking_20_max smallmoney,

	@v11apositiontaking_1_max smallmoney,
	@v11apositiontaking_20_max smallmoney,

	@v99apositiontaking_1_max smallmoney,
	@v99apositiontaking_2_max smallmoney,
	@v99apositiontaking_3_max smallmoney,
	@v99apositiontaking_9_max smallmoney,
	@v99apositiontaking_20_max smallmoney,
	@v99apositiontaking_9999_max smallmoney,	

	@apositiontaking_1_min smallmoney,
	@apositiontaking_2_min smallmoney,
	@apositiontaking_3_min smallmoney,
	@apositiontaking_4_min smallmoney,
	@apositiontaking_5_min smallmoney,
	@apositiontaking_6_min smallmoney,
	@apositiontaking_7_min smallmoney,
	@apositiontaking_8_min smallmoney,
	@apositiontaking_9_min smallmoney,
	@apositiontaking_10_min smallmoney,
	@apositiontaking_9999_min smallmoney,
	
	@alivepositiontaking_1_min smallmoney,
	@alivepositiontaking_3_min smallmoney,
	@alivepositiontaking_7_min smallmoney,
	@alivepositiontaking_8_min smallmoney,
	
	@v2apositiontaking_1_min smallmoney,
	@v2apositiontaking_2_min smallmoney,
	@v2apositiontaking_3_min smallmoney,
	@v2apositiontaking_7_min smallmoney,
	@v2apositiontaking_8_min smallmoney,
	--@v2apositiontaking_9_min smallmoney,
	@v2apositiontaking_20_min smallmoney,
	@v2apositiontaking_9999_min smallmoney,
	
	@v3apositiontaking_1_min smallmoney,
	@v3apositiontaking_2_min smallmoney,
	@v3apositiontaking_3_min smallmoney,
	@v3apositiontaking_20_min smallmoney,

	@v5apositiontaking_1_min smallmoney,
	@v5apositiontaking_2_min smallmoney,
	@v5apositiontaking_3_min smallmoney,
	@v5apositiontaking_20_min smallmoney,
	@v5apositiontaking_9999_min smallmoney,

	@v8apositiontaking_1_min smallmoney,
	@v8apositiontaking_3_min smallmoney,
	@v8apositiontaking_20_min smallmoney,

	@v10apositiontaking_1_min smallmoney,
	@v10apositiontaking_2_min smallmoney,
	@v10apositiontaking_3_min smallmoney,
	@v10apositiontaking_20_min smallmoney,

	@v11apositiontaking_1_min smallmoney,
	@v11apositiontaking_20_min smallmoney,

	@v99apositiontaking_1_min smallmoney,
	@v99apositiontaking_2_min smallmoney,
	@v99apositiontaking_3_min smallmoney,
	@v99apositiontaking_9_min smallmoney,
	@v99apositiontaking_20_min smallmoney,
	@v99apositiontaking_9999_min smallmoney,
	
	-- Outright PT
	@v2apositiontaking_10_max smallmoney,
	@v3apositiontaking_10_max smallmoney,
	@v5apositiontaking_10_max smallmoney,
	@v8apositiontaking_10_max smallmoney,
	@v10apositiontaking_10_max smallmoney,
	@v11apositiontaking_10_max smallmoney,
	@v99apositiontaking_10_max smallmoney,
	
	@v2apositiontaking_10_min smallmoney,
	@v3apositiontaking_10_min smallmoney,
	@v5apositiontaking_10_min smallmoney,
	@v8apositiontaking_10_min smallmoney,
	@v10apositiontaking_10_min smallmoney,
	@v11apositiontaking_10_min smallmoney,
	@v99apositiontaking_10_min smallmoney

--@apos_max = min(a4,a2,l2)
Select 	
	@apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	-- Outright PT
	@v2apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v11apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	
	@apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@alivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),

	@v2apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	--@v2apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@v2apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v3apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v5apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v8apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v10apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v11apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v11apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v99apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),	

	@apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_4_min = max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_5_min = max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_6_min = max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end),
	
	-- Outright PT for sporst
	@v2apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v3apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v5apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v8apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v10apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v11apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v99apositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end),
	
	@apositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end),

	@alivepositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@alivepositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@alivepositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@alivepositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end),

	@v2apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end),
	--@v2apositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2apositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end),
	
	@v3apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end),

	@v5apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5apositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end),

	@v8apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end),

	@v10apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end),

	@v11apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v11apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end),

	@v99apositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99apositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99apositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99apositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99apositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99apositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end)
	
From 
	--Customer c WITH(NOLOCK) 
	CustSetting as cs with (NOLOCK) --ON c.recommend = cs.custid
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @recommend

Select 
	@sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_4 = max(case when Scs.bettype = 4 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_5 = max(case when Scs.bettype = 5 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_6 = max(case when Scs.bettype = 6 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_7 = max(case when Scs.bettype = 7 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_8 = max(case when Scs.bettype = 8 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	@sp_9 = max(case when Scs.bettype = 9 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	
	@sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	
	@v2sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v3sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v5sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v8sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),
	@v10sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v11sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=11 then Scs.spositiontaking else 0 end),
	@v99sp_10 = max(case when Scs.bettype = 10 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	
	
	@sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	
	@slp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_7 = max(case when Scs.bettype = 7 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_8 = max(case when Scs.bettype = 8 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	
	@v2sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_7 = max(case when Scs.bettype = 7 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_8 = max(case when Scs.bettype = 8 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	--@v2sp_9 = max(case when Scs.bettype = 9 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	
	@v3sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),

	@v5sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),

	@v8sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),
	@v8sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),
	@v8sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),

	@v10sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),

	@v11sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=11 then Scs.spositiontaking else 0 end),
	@v11sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=11 then Scs.spositiontaking else 0 end),

	@v99sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_9 = max(case when Scs.bettype = 9 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),

	--@apos_max = min(a4,a2,l2)
	@apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_1_max then scs.apositiontaking else @apositiontaking_1_max end else 0 end),
	@apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_2_max then scs.apositiontaking else @apositiontaking_2_max end else 0 end),
	@apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_3_max then scs.apositiontaking else @apositiontaking_3_max end else 0 end),
	@apositiontaking_4_max = max(case when scs.bettype = 4 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_4_max then scs.apositiontaking else @apositiontaking_4_max end else 0 end),
	@apositiontaking_5_max = max(case when scs.bettype = 5 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_5_max then scs.apositiontaking else @apositiontaking_5_max end else 0 end),
	@apositiontaking_6_max = max(case when scs.bettype = 6 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_6_max then scs.apositiontaking else @apositiontaking_6_max end else 0 end),
	@apositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_7_max then scs.apositiontaking else @apositiontaking_7_max end else 0 end),
	@apositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_8_max then scs.apositiontaking else @apositiontaking_8_max end else 0 end),
	@apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_9_max then scs.apositiontaking else @apositiontaking_9_max end else 0 end),
	@apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_10_max then scs.apositiontaking else @apositiontaking_10_max end else 0 end),
	@apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_9999_max then scs.apositiontaking else @apositiontaking_9999_max end else 0 end),
	
	-- Outright PT for sports
	@v2apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_10_max then scs.apositiontaking else @v2apositiontaking_10_max end else 0 end),
	@v3apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_10_max then scs.apositiontaking else @v3apositiontaking_10_max end else 0 end),
	@v5apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_10_max then scs.apositiontaking else @v5apositiontaking_10_max end else 0 end),
	@v8apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_10_max then scs.apositiontaking else @v8apositiontaking_10_max end else 0 end),
	@v10apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_10_max then scs.apositiontaking else @v10apositiontaking_10_max end else 0 end),
	@v11apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_10_max then scs.apositiontaking else @v11apositiontaking_10_max end else 0 end),
	@v99apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_10_max then scs.apositiontaking else @v99apositiontaking_10_max end else 0 end),
	
		
	@alivepositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_1_max then scs.alivepositiontaking else @alivepositiontaking_1_max end else 0 end),
	@alivepositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_3_max then scs.alivepositiontaking else @alivepositiontaking_3_max end else 0 end),
	@alivepositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_7_max then scs.alivepositiontaking else @alivepositiontaking_7_max end else 0 end),
	@alivepositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_8_max then scs.alivepositiontaking else @alivepositiontaking_8_max end else 0 end),

	@v2apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_1_max then scs.apositiontaking else @v2apositiontaking_1_max end else 0 end),
	@v2apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_2_max then scs.apositiontaking else @v2apositiontaking_2_max end else 0 end),
	@v2apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_3_max then scs.apositiontaking else @v2apositiontaking_3_max end else 0 end),
	@v2apositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_7_max then scs.apositiontaking else @v2apositiontaking_7_max end else 0 end),
	@v2apositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_8_max then scs.apositiontaking else @v2apositiontaking_8_max end else 0 end),
	--@v2apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_9_max then scs.apositiontaking else @v2apositiontaking_9_max end else 0 end),
	@v2apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_20_max then scs.apositiontaking else @v2apositiontaking_20_max end else 0 end),
	
	@v2apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_9999_max then scs.apositiontaking else @v2apositiontaking_9999_max end else 0 end),

	@v3apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_1_max then scs.apositiontaking else @v3apositiontaking_1_max end else 0 end),
	@v3apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_2_max then scs.apositiontaking else @v3apositiontaking_2_max end else 0 end),
	@v3apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_3_max then scs.apositiontaking else @v3apositiontaking_3_max end else 0 end),
	@v3apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_20_max then scs.apositiontaking else @v3apositiontaking_20_max end else 0 end),

	@v5apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_1_max then scs.apositiontaking else @v5apositiontaking_1_max end else 0 end),
	@v5apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_2_max then scs.apositiontaking else @v5apositiontaking_2_max end else 0 end),
	@v5apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_3_max then scs.apositiontaking else @v5apositiontaking_3_max end else 0 end),
	@v5apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_20_max then scs.apositiontaking else @v5apositiontaking_20_max end else 0 end),
	@v5apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_9999_max then scs.apositiontaking else @v5apositiontaking_9999_max end else 0 end),

	@v8apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_1_max then scs.apositiontaking else @v8apositiontaking_1_max end else 0 end),
	@v8apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_3_max then scs.apositiontaking else @v8apositiontaking_3_max end else 0 end),
	@v8apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_20_max then scs.apositiontaking else @v8apositiontaking_20_max end else 0 end),

	@v10apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_1_max then scs.apositiontaking else @v10apositiontaking_1_max end else 0 end),
	@v10apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_2_max then scs.apositiontaking else @v10apositiontaking_2_max end else 0 end),
	@v10apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_3_max then scs.apositiontaking else @v10apositiontaking_3_max end else 0 end),
	@v10apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_20_max then scs.apositiontaking else @v10apositiontaking_20_max end else 0 end),

	@v11apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_1_max then scs.apositiontaking else @v11apositiontaking_1_max end else 0 end),
	@v11apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_20_max then scs.apositiontaking else @v11apositiontaking_20_max end else 0 end),

	@v99apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_1_max then scs.apositiontaking else @v99apositiontaking_1_max end else 0 end),
	@v99apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_2_max then scs.apositiontaking else @v99apositiontaking_2_max end else 0 end),
	@v99apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_3_max then scs.apositiontaking else @v99apositiontaking_3_max end else 0 end),
	@v99apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_9_max then scs.apositiontaking else @v99apositiontaking_9_max end else 0 end),
	@v99apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_20_max then scs.apositiontaking else @v99apositiontaking_20_max end else 0 end),
	@v99apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_9999_max then scs.apositiontaking else @v99apositiontaking_9999_max end else 0 end)		
From
	--customer c WITH(NOLOCK) 
	--INNER JOIN CustSetting as Scs with (NOLOCK) ON c.srecommend = scs.custid
	Custsetting as scs WITH(NOLOCK)
WHERE
	--c.CustID = @CustID
	scs.custid = @srecommend
	
--PRINT 's4: ' + convert(varchar(10),@v2sp_9)

--=iff(im,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
Select 
	@cs_ap_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_4-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_4-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_5-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_5-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_6-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_6-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_7-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_7-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_8-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_8-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_9-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_9-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	-- Outright PT for sports
	@cs_v2ap_10 = max(case when cs.bettype = 10 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_10 = max(case when cs.bettype = 10 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v3sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v3sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_10 = max(case when cs.bettype = 10 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_10 = max(case when cs.bettype = 10 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v8sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v8sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_10 = max(case when cs.bettype = 10 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v10sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v10sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v11ap_10 = max(case when cs.bettype = 10 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v11sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v11sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_10 = max(case when cs.bettype = 10 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_10-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_10-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@sp_9999-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @sp_9999-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_alp_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=@slp_1-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else @slp_1-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=@slp_3-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else @slp_3-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=@slp_7-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else @slp_7-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=@slp_8-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else @slp_8-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	
	@cs_v2ap_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_7-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_7-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_8-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_8-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	--@cs_v2ap_9 = max(case when cs.bettype = 9 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_9-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_9-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_20 = max(case when cs.bettype = 20 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_v2ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v2sp_9999-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v2sp_9999-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v3ap_1 = max(case when cs.bettype = 1 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v3sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v3sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_2 = max(case when cs.bettype = 2 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v3sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v3sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_3 = max(case when cs.bettype = 3 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v3sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v3sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_20 = max(case when cs.bettype = 20 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v3sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v3sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v5ap_1 = max(case when cs.bettype = 1 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_2 = max(case when cs.bettype = 2 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_3 = max(case when cs.bettype = 3 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_20 = max(case when cs.bettype = 20 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v5sp_9999-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v5sp_9999-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v8ap_1 = max(case when cs.bettype = 1 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v8sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v8sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_3 = max(case when cs.bettype = 3 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v8sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v8sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_20 = max(case when cs.bettype = 20 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v8sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v8sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v10ap_1 = max(case when cs.bettype = 1 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v10sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v10sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_2 = max(case when cs.bettype = 2 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v10sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v10sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_3 = max(case when cs.bettype = 3 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v10sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v10sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_20 = max(case when cs.bettype = 20 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v10sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v10sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v11ap_1 = max(case when cs.bettype = 1 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v11sp_1-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v11sp_1-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v11ap_20 = max(case when cs.bettype = 20 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v11sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v11sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v99ap_1 = max(case when cs.bettype = 1 and cs.sporttype=99 
						   then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) 
									 then acs.apositiontaking 
									 else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) 
											   then mcs.mpositiontaking-cs.mpositiontaking 
											   else case when mcs.mpositiontaking-cs.mpositiontaking
																<=@v99sp_1-cs.spositiontaking-cs.mpositiontaking 
														 then  mcs.mpositiontaking-cs.mpositiontaking 
														 else @v99sp_1-cs.spositiontaking-cs.mpositiontaking 
													end 
										  end 
								end 
						  else 0 
					  end),

	@cs_v99ap_2 = max(case when cs.bettype = 2 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_3 = max(case when cs.bettype = 3 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_9 = max(case when cs.bettype = 9 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_9-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_9-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_20 = max(case when cs.bettype = 20 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_20-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_20-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v99sp_9999-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v99sp_9999-cs.spositiontaking-cs.mpositiontaking end end end else 0 end)

		
From CustSetting as cs with (NOLOCK) 
	--inner join customer as c with (nolock) on cs.custid = c.custid
	--inner join custsetting as mcs with (nolock) on mcs.custid = c.mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
	--inner join custsetting as acs with (nolock) on acs.custid = c.recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
	inner join custsetting as mcs with (nolock) on mcs.custid = @mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
	inner join custsetting as acs with (nolock) on acs.custid = @recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
WHERE 
	--c.custid = @custid
	cs.custid = @custid

--PRINT 'ap: ' + convert(varchar(10),@cs_v2ap_9)

select 
	@apositiontaking_1_max = case when @apositiontaking_1_max <= @cs_ap_1 then @apositiontaking_1_max else @cs_ap_1 end,
	@apositiontaking_2_max = case when @apositiontaking_2_max <= @cs_ap_2 then @apositiontaking_2_max else @cs_ap_2 end,
	@apositiontaking_3_max = case when @apositiontaking_3_max <= @cs_ap_3 then @apositiontaking_3_max else @cs_ap_3 end,
	@apositiontaking_4_max = case when @apositiontaking_4_max <= @cs_ap_4 then @apositiontaking_4_max else @cs_ap_4 end,
	@apositiontaking_5_max = case when @apositiontaking_5_max <= @cs_ap_5 then @apositiontaking_5_max else @cs_ap_5 end,
	@apositiontaking_6_max = case when @apositiontaking_6_max <= @cs_ap_6 then @apositiontaking_6_max else @cs_ap_6 end,
	@apositiontaking_7_max = case when @apositiontaking_7_max <= @cs_ap_7 then @apositiontaking_7_max else @cs_ap_7 end,
	@apositiontaking_8_max = case when @apositiontaking_8_max <= @cs_ap_8 then @apositiontaking_8_max else @cs_ap_8 end,
	@apositiontaking_9_max = case when @apositiontaking_9_max <= @cs_ap_9 then @apositiontaking_9_max else @cs_ap_9 end,
	@apositiontaking_10_max = case when @apositiontaking_10_max <= @cs_ap_10 then @apositiontaking_10_max else @cs_ap_10 end,
	
	@v2apositiontaking_10_max = case when @v2apositiontaking_10_max <= @cs_v2ap_10 then @v2apositiontaking_10_max else @cs_v2ap_10 end,
	@v3apositiontaking_10_max = case when @v3apositiontaking_10_max <= @cs_v3ap_10 then @v3apositiontaking_10_max else @cs_v3ap_10 end,
	@v5apositiontaking_10_max = case when @v5apositiontaking_10_max <= @cs_v5ap_10 then @v5apositiontaking_10_max else @cs_v5ap_10 end,
	@v8apositiontaking_10_max = case when @v8apositiontaking_10_max <= @cs_v8ap_10 then @v8apositiontaking_10_max else @cs_v8ap_10 end,
	@v10apositiontaking_10_max = case when @v10apositiontaking_10_max <= @cs_v10ap_10 then @v10apositiontaking_10_max else @cs_v10ap_10 end,
	@v11apositiontaking_10_max = case when @v11apositiontaking_10_max <= @cs_v11ap_10 then @v11apositiontaking_10_max else @cs_v11ap_10 end,
	@v99apositiontaking_10_max = case when @v99apositiontaking_10_max <= @cs_v99ap_10 then @v99apositiontaking_10_max else @cs_v99ap_10 end,
	
	@apositiontaking_9999_max = case when @apositiontaking_9999_max <= @cs_ap_9999 then @apositiontaking_9999_max else @cs_ap_9999 end,

	@alivepositiontaking_1_max = case when @alivepositiontaking_1_max <= @cs_alp_1 then @alivepositiontaking_1_max else @cs_alp_1 end,
	@alivepositiontaking_3_max = case when @alivepositiontaking_3_max <= @cs_alp_3 then @alivepositiontaking_3_max else @cs_alp_3 end,
	@alivepositiontaking_7_max = case when @alivepositiontaking_7_max <= @cs_alp_7 then @alivepositiontaking_7_max else @cs_alp_7 end,
	@alivepositiontaking_8_max = case when @alivepositiontaking_8_max <= @cs_alp_8 then @alivepositiontaking_8_max else @cs_alp_8 end,

	@v2apositiontaking_1_max = case when @v2apositiontaking_1_max <= @cs_v2ap_1 then @v2apositiontaking_1_max else @cs_v2ap_1 end,
	@v2apositiontaking_2_max = case when @v2apositiontaking_2_max <= @cs_v2ap_2 then @v2apositiontaking_2_max else @cs_v2ap_2 end,
	@v2apositiontaking_3_max = case when @v2apositiontaking_3_max <= @cs_v2ap_3 then @v2apositiontaking_3_max else @cs_v2ap_3 end,
	@v2apositiontaking_7_max = case when @v2apositiontaking_7_max <= @cs_v2ap_7 then @v2apositiontaking_7_max else @cs_v2ap_7 end,
	@v2apositiontaking_8_max = case when @v2apositiontaking_8_max <= @cs_v2ap_8 then @v2apositiontaking_8_max else @cs_v2ap_8 end,
	--@v2apositiontaking_9_max = case when @v2apositiontaking_9_max <= @cs_v2ap_9 then @v2apositiontaking_9_max else @cs_v2ap_9 end,
	@v2apositiontaking_20_max = case when @v2apositiontaking_20_max <= @cs_v2ap_20 then @v2apositiontaking_20_max else @cs_v2ap_20 end,
	
	@v2apositiontaking_9999_max = case when @v2apositiontaking_9999_max <= @cs_v2ap_9999 then @v2apositiontaking_9999_max else @cs_v2ap_9999 end,
	
	@v3apositiontaking_1_max = case when @v3apositiontaking_1_max <= @cs_v3ap_1 then @v3apositiontaking_1_max else @cs_v3ap_1 end,
	@v3apositiontaking_2_max = case when @v3apositiontaking_2_max <= @cs_v3ap_2 then @v3apositiontaking_2_max else @cs_v3ap_2 end,
	@v3apositiontaking_3_max = case when @v3apositiontaking_3_max <= @cs_v3ap_3 then @v3apositiontaking_3_max else @cs_v3ap_3 end,
	@v3apositiontaking_20_max = case when @v3apositiontaking_20_max <= @cs_v3ap_20 then @v3apositiontaking_20_max else @cs_v3ap_20 end,

	@v5apositiontaking_1_max = case when @v5apositiontaking_1_max <= @cs_v5ap_1 then @v5apositiontaking_1_max else @cs_v5ap_1 end,
	@v5apositiontaking_2_max = case when @v5apositiontaking_2_max <= @cs_v5ap_2 then @v5apositiontaking_2_max else @cs_v5ap_2 end,
	@v5apositiontaking_3_max = case when @v5apositiontaking_3_max <= @cs_v5ap_3 then @v5apositiontaking_3_max else @cs_v5ap_3 end,
	@v5apositiontaking_20_max = case when @v5apositiontaking_20_max <= @cs_v5ap_20 then @v5apositiontaking_20_max else @cs_v5ap_20 end,
	@v5apositiontaking_9999_max = case when @v5apositiontaking_9999_max <= @cs_v5ap_9999 then @v5apositiontaking_9999_max else @cs_v5ap_9999 end,

	@v8apositiontaking_1_max = case when @v8apositiontaking_1_max <= @cs_v8ap_1 then @v8apositiontaking_1_max else @cs_v8ap_1 end,
	@v8apositiontaking_3_max = case when @v8apositiontaking_3_max <= @cs_v8ap_3 then @v8apositiontaking_3_max else @cs_v8ap_3 end,
	@v8apositiontaking_20_max = case when @v8apositiontaking_20_max <= @cs_v8ap_20 then @v8apositiontaking_20_max else @cs_v8ap_20 end,

	@v10apositiontaking_1_max = case when @v10apositiontaking_1_max <= @cs_v10ap_1 then @v10apositiontaking_1_max else @cs_v10ap_1 end,
	@v10apositiontaking_2_max = case when @v10apositiontaking_2_max <= @cs_v10ap_2 then @v10apositiontaking_2_max else @cs_v10ap_2 end,
	@v10apositiontaking_3_max = case when @v10apositiontaking_3_max <= @cs_v10ap_3 then @v10apositiontaking_3_max else @cs_v10ap_3 end,
	@v10apositiontaking_20_max = case when @v10apositiontaking_20_max <= @cs_v10ap_20 then @v10apositiontaking_20_max else @cs_v10ap_20 end,

	@v11apositiontaking_1_max = case when @v11apositiontaking_1_max <= @cs_v11ap_1 then @v11apositiontaking_1_max else @cs_v11ap_1 end,
	@v11apositiontaking_20_max = case when @v11apositiontaking_20_max <= @cs_v11ap_20 then @v11apositiontaking_20_max else @cs_v11ap_20 end,

	@v99apositiontaking_1_max = case when @v99apositiontaking_1_max <= @cs_v99ap_1 then @v99apositiontaking_1_max else @cs_v99ap_1 end,
	@v99apositiontaking_2_max = case when @v99apositiontaking_2_max <= @cs_v99ap_2 then @v99apositiontaking_2_max else @cs_v99ap_2 end,
	@v99apositiontaking_3_max = case when @v99apositiontaking_3_max <= @cs_v99ap_3 then @v99apositiontaking_3_max else @cs_v99ap_3 end,
	@v99apositiontaking_9_max = case when @v99apositiontaking_9_max <= @cs_v99ap_9 then @v99apositiontaking_9_max else @cs_v99ap_9 end,
	@v99apositiontaking_20_max = case when @v99apositiontaking_20_max <= @cs_v99ap_20 then @v99apositiontaking_20_max else @cs_v99ap_20 end,
	@v99apositiontaking_9999_max = case when @v99apositiontaking_9999_max <= @cs_v99ap_9999 then @v99apositiontaking_9999_max else @cs_v99ap_9999 end

	-- Myanmar Odds
	DECLARE @playerdiscountMyanmarOdds DECIMAL (9,8) = 0, @discountMyanmarOdds DECIMAL (9,8) = 0
	DECLARE @IsMyanmarOdds BIT = 0

	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

	IF @IsMyanmarOdds = 1
	BEGIN
		SET @playerdiscountMyanmarOdds = ISNULL((SELECT playerdiscount FROM CustCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)
		SET @discountMyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @recommend AND Sporttype = 1 AND Bettype = 1),0)
	END	

--Get BetSetting limit
EXEC Age_CustomerSelMinMaxLimit @custid = @custid,
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

--> Get BetSetting
EXEC Acc_CustomerSelMinMax
	@custid						= @custid,
	@minbet						= @minbet					OUTPUT,            
	@maxbet                		= @maxbet                	OUTPUT,
	@maxpermatch           		= @maxpermatch           	OUTPUT,
	@minbetv2              		= @minbetv2              	OUTPUT,
	@maxbetv2              		= @maxbetv2              	OUTPUT,
	@maxpermatchv2         		= @maxpermatchv2         	OUTPUT,
	@minbetv3              		= @minbetv3              	OUTPUT,
	@maxbetv3              		= @maxbetv3              	OUTPUT,
	@maxpermatchv3         		= @maxpermatchv3         	OUTPUT,
	@minbetv5              		= @minbetv5              	OUTPUT,
	@maxbetv5              		= @maxbetv5              	OUTPUT,
	@maxpermatchv5         		= @maxpermatchv5         	OUTPUT,
	@minbetv8              		= @minbetv8              	OUTPUT,
	@maxbetv8              		= @maxbetv8              	OUTPUT,
	@maxpermatchv8         		= @maxpermatchv8         	OUTPUT,
	@minbetv10             		= @minbetv10             	OUTPUT,
	@maxbetv10             		= @maxbetv10             	OUTPUT,
	@maxpermatchv10        		= @maxpermatchv10        	OUTPUT,
	@minbetv11             		= @minbetv11             	OUTPUT,
	@maxbetv11             		= @maxbetv11             	OUTPUT,
	@maxpermatchv11        		= @maxpermatchv11        	OUTPUT,
	@minbetv99             		= @minbetv99             	OUTPUT,
	@maxbetv99             		= @maxbetv99             	OUTPUT,
	@maxpermatchv99        		= @maxpermatchv99        	OUTPUT,
	@minbetv99mp           		= @minbetv99mp           	OUTPUT,
	@maxbetv99mp           		= @maxbetv99mp           	OUTPUT,
	@maxpermatchv99mp      		= @maxpermatchv99mp      	OUTPUT,
	@minbetv1mp            		= @minbetv1mp            	OUTPUT,
	@maxbetv1mp            		= @maxbetv1mp            	OUTPUT,
	@maxpermatchv1mp       		= @maxpermatchv1mp       	OUTPUT,	
	@MaxPayoutPerMatch     		= @MaxPayoutPerMatch     	OUTPUT,
	@MaxPayoutPerMatchv2   		= @MaxPayoutPerMatchv2   	OUTPUT,
	@MaxPayoutPerMatchv3   		= @MaxPayoutPerMatchv3   	OUTPUT,
	@MaxPayoutPerMatchv5   		= @MaxPayoutPerMatchv5   	OUTPUT,
	@MaxPayoutPerMatchv8   		= @MaxPayoutPerMatchv8   	OUTPUT,
	@MaxPayoutPerMatchv10  		= @MaxPayoutPerMatchv10  	OUTPUT,
	@MaxPayoutPerMatchv11  		= @MaxPayoutPerMatchv11  	OUTPUT,
	@MaxPayoutPerMatchv99  		= @MaxPayoutPerMatchv99  	OUTPUT,
	@MaxPayoutPerMatchv99mp		= @MaxPayoutPerMatchv99mp	OUTPUT,
	@MaxPayoutPerMatchv1mp 		= @MaxPayoutPerMatchv1mp 	OUTPUT,
	--Saba
	@minbetv1saba              	= @minbetv1saba             OUTPUT,
	@maxbetv1saba              	= @maxbetv1saba             OUTPUT,
	@maxpermatchv1saba         	= @maxpermatchv1saba        OUTPUT,
	@MaxPayoutPerMatchv1saba   	= @MaxPayoutPerMatchv1saba  OUTPUT,

	@minbetv2saba              	= @minbetv2saba             OUTPUT,
	@maxbetv2saba              	= @maxbetv2saba             OUTPUT,
	@maxpermatchv2saba         	= @maxpermatchv2saba        OUTPUT,
	@MaxPayoutPerMatchv2saba   	= @MaxPayoutPerMatchv2saba  OUTPUT

SELECT 
	C.username, C.firstname, C.lastname,c.username2, Cps.closed,cps.reject as suspended,ci.currency AS CurrencyID,
	CASE WHEN (sp.SuperStatus + sp.MasterStatus + sp.AgentStatus) > 0 THEN 1 ELSE 0 END as Asuspended,
	C.postal, isnull(C.email,'') as email, 
	isnull(C.phone,'') as phone, 
	isnull(C.mobilephone,'') as mobilephone, 
	isnull(C.email,'') as email, 
	isnull(C.fax,'') as fax, 
	@Credit_Mem_Max as Credit_Max,	
	C.site as csite, 
	s.SiteLabel as sSitelabel,
	C.ugroup, C.roleid,
	isnull(exchange.minbet, 0) AS defaultminbet, C.refcode1,C.address, C.city, C.state, C.country, isnull(ci.credit, 0) as credit,
	
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.discount else 0 end), 0) as discount,
	isnull(max(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end), 0) as discountcs,
	isnull(max(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end), 0) as discount1x2, --1x2
	
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.playerdiscount else 0 end), 0) as playerdiscount,
	isnull(max(case when cs.bettype = 4 and cs.sporttype=1 then cs.playerdiscount else 0 end), 0) as playerdiscountcs,
	isnull(max(case when cs.bettype = 5 and cs.sporttype=1 then cs.playerdiscount else 0 end), 0) as playerdiscount1x2, --1x2
	-- For MyanmarOdds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@playerdiscountMyanmarOdds,0) AS playerdiscountMyanmarOdds,
	ISNULL(@discountMyanmarOdds,0) AS discountMyanmarOdds,
	@site as site,
	@sitelabel as sitelabel,
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_3,
	isnull(max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_4,
	isnull(max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_5,
	isnull(max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_6,
	isnull(max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_7,
	isnull(max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_8,
	isnull(max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_9,
	isnull(max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_10,	
	isnull(max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end), 0) as apositiontaking_9999,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end), 0) as alivepositiontaking_1,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end), 0) as alivepositiontaking_3,
	isnull(max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end), 0) as alivepositiontaking_7,
	isnull(max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end), 0) as alivepositiontaking_8,



	isnull(max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_3,
	isnull(max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_7,
	isnull(max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_8,
	--isnull(max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_9,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_20,
	
	isnull(max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_9999,
	
	isnull(max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end), 0) as v3apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end), 0) as v3apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end), 0) as v3apositiontaking_3,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end), 0) as v3apositiontaking_20,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_3,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_20,
	isnull(max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_9999,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end), 0) as v8apositiontaking_1,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end), 0) as v8apositiontaking_3,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end), 0) as v8apositiontaking_20,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end), 0) as v10apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end), 0) as v10apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end), 0) as v10apositiontaking_3,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end), 0) as v10apositiontaking_20,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end), 0) as v11apositiontaking_1,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end), 0) as v11apositiontaking_20,

	--v201
	isnull(max(case when cs.bettype = 3 and cs.sporttype=201 then cs.apositiontaking else 0 end), 0) as v201apositiontaking_3,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=201 then cs.apositiontaking else 0 end), 0) as v201apositiontaking_2,

	isnull(max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_1,
	isnull(max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_2,
	isnull(max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_3,
	isnull(max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_9,
	isnull(max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_20,
	isnull(max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_9999,
		
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end), 0) as groupa,
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end), 0) as groupb,
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end), 0) as groupc,
	isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end), 0) as groupd,
	
	isnull(@apositiontaking_1_max, 0) as maxpos_1,
	isnull(@apositiontaking_2_max, 0) as maxpos_2, 
	isnull(@apositiontaking_3_max, 0) as maxpos_3,
	isnull(@apositiontaking_4_max, 0) as maxpos_4,	
	isnull(@apositiontaking_5_max, 0) as maxpos_5,
	isnull(@apositiontaking_6_max, 0) as maxpos_6,
	isnull(@apositiontaking_7_max, 0) as maxpos_7,
	isnull(@apositiontaking_8_max, 0) as maxpos_8,	
	isnull(@apositiontaking_9_max, 0) as maxpos_9,
	isnull(@apositiontaking_10_max, 0) as maxpos_10,
	isnull(@apositiontaking_9999_max, 0) as maxpos_9999,

	isnull(@alivepositiontaking_1_max, 0) as maxlpos_1,
	isnull(@alivepositiontaking_3_max, 0) as maxlpos_3,
	isnull(@alivepositiontaking_7_max, 0) as maxlpos_7,
	isnull(@alivepositiontaking_8_max, 0) as maxlpos_8,	

	isnull(@v2apositiontaking_1_max, 0) as maxv2pos_1,
	isnull(@v2apositiontaking_2_max, 0) as maxv2pos_2,
	isnull(@v2apositiontaking_3_max, 0) as maxv2pos_3,
	isnull(@v2apositiontaking_7_max, 0) as maxv2pos_7,
	isnull(@v2apositiontaking_8_max, 0) as maxv2pos_8,
	--isnull(@v2apositiontaking_9_max, 0) as maxv2pos_9,
	isnull(@v2apositiontaking_20_max, 0) as maxv2pos_20,
	isnull(@v2apositiontaking_9999_max, 0) as maxv2pos_9999,
	
	isnull(@v3apositiontaking_1_max, 0) as maxv3pos_1,
	isnull(@v3apositiontaking_2_max, 0) as maxv3pos_2,
	isnull(@v3apositiontaking_3_max, 0) as maxv3pos_3,
	isnull(@v3apositiontaking_20_max, 0) as maxv3pos_20,

	isnull(@v5apositiontaking_1_max, 0) as maxv5pos_1,
	isnull(@v5apositiontaking_2_max, 0) as maxv5pos_2,
	isnull(@v5apositiontaking_3_max, 0) as maxv5pos_3,
	isnull(@v5apositiontaking_20_max, 0) as maxv5pos_20,
	isnull(@v5apositiontaking_9999_max, 0) as maxv5pos_9999,

	isnull(@v8apositiontaking_1_max, 0) as maxv8pos_1,
	isnull(@v8apositiontaking_3_max, 0) as maxv8pos_3,
	isnull(@v8apositiontaking_20_max, 0) as maxv8pos_20,

	isnull(@v10apositiontaking_1_max, 0) as maxv10pos_1,
	isnull(@v10apositiontaking_2_max, 0) as maxv10pos_2,
	isnull(@v10apositiontaking_3_max, 0) as maxv10pos_3,
	isnull(@v10apositiontaking_20_max, 0) as maxv10pos_20,

	isnull(@v11apositiontaking_1_max, 0) as maxv11pos_1,
	isnull(@v11apositiontaking_20_max, 0) as maxv11pos_20,

	isnull(@v99apositiontaking_1_max, 0) as maxv99pos_1,
	isnull(@v99apositiontaking_2_max, 0) as maxv99pos_2,
	isnull(@v99apositiontaking_3_max, 0) as maxv99pos_3,
	isnull(@v99apositiontaking_9_max, 0) as maxv99pos_9,
	isnull(@v99apositiontaking_20_max, 0) as maxv99pos_20,
	isnull(@v99apositiontaking_9999_max, 0) as maxv99pos_9999,	
	
	isnull(@apositiontaking_1_min, 0) as minpos_1,
	isnull(@apositiontaking_2_min, 0) as minpos_2, 
	isnull(@apositiontaking_3_min, 0) as minpos_3,
	isnull(@apositiontaking_4_min, 0) as minpos_4,	
	isnull(@apositiontaking_5_min, 0) as minpos_5,
	isnull(@apositiontaking_6_min, 0) as minpos_6,
	isnull(@apositiontaking_7_min, 0) as minpos_7,
	isnull(@apositiontaking_8_min, 0) as minpos_8,	
	isnull(@apositiontaking_9_min, 0) as minpos_9,
	isnull(@apositiontaking_10_min, 0) as minpos_10,
	isnull(@apositiontaking_9999_min, 0) as minpos_9999,

	isnull(@alivepositiontaking_1_min, 0) as minlpos_1,
	isnull(@alivepositiontaking_3_min, 0) as minlpos_3,
	isnull(@alivepositiontaking_7_min, 0) as minlpos_7,
	isnull(@alivepositiontaking_8_min, 0) as minlpos_8,	

	isnull(@v2apositiontaking_1_min, 0) as minv2pos_1,
	isnull(@v2apositiontaking_2_min, 0) as minv2pos_2,
	isnull(@v2apositiontaking_3_min, 0) as minv2pos_3,
	isnull(@v2apositiontaking_7_min, 0) as minv2pos_7,
	isnull(@v2apositiontaking_8_min, 0) as minv2pos_8,
	--isnull(@v2apositiontaking_9_min, 0) as minv2pos_9,
	isnull(@v2apositiontaking_20_min, 0) as minv2pos_20,
	isnull(@v2apositiontaking_9999_min, 0) as minv2pos_9999,
	
	isnull(@v3apositiontaking_1_min, 0) as minv3pos_1,
	isnull(@v3apositiontaking_2_min, 0) as minv3pos_2,
	isnull(@v3apositiontaking_3_min, 0) as minv3pos_3,
	isnull(@v3apositiontaking_20_min, 0) as minv3pos_20,

	isnull(@v5apositiontaking_1_min, 0) as minv5pos_1,
	isnull(@v5apositiontaking_2_min, 0) as minv5pos_2,
	isnull(@v5apositiontaking_3_min, 0) as minv5pos_3,
	isnull(@v5apositiontaking_20_min, 0) as minv5pos_20,
	isnull(@v5apositiontaking_9999_min, 0) as minv5pos_9999,

	isnull(@v8apositiontaking_1_min, 0) as minv8pos_1,
	isnull(@v8apositiontaking_3_min, 0) as minv8pos_3,
	isnull(@v8apositiontaking_20_min, 0) as minv8pos_20,

	isnull(@v10apositiontaking_1_min, 0) as minv10pos_1,
	isnull(@v10apositiontaking_2_min, 0) as minv10pos_2,
	isnull(@v10apositiontaking_3_min, 0) as minv10pos_3,
	isnull(@v10apositiontaking_20_min, 0) as minv10pos_20,

	isnull(@v11apositiontaking_1_min, 0) as minv11pos_1,
	isnull(@v11apositiontaking_20_min, 0) as minv11pos_20,

	isnull(@v99apositiontaking_1_min, 0) as minv99pos_1,
	isnull(@v99apositiontaking_2_min, 0) as minv99pos_2,
	isnull(@v99apositiontaking_3_min, 0) as minv99pos_3,
	isnull(@v99apositiontaking_9_min, 0) as minv99pos_9,
	isnull(@v99apositiontaking_20_min, 0) as minv99pos_20,
	isnull(@v99apositiontaking_9999_min, 0) as minv99pos_9999,
		
	-- Out right PT
	isnull(max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end), 0) as v2apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end), 0) as v3apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end), 0) as v5apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end), 0) as v8apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end), 0) as v10apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end), 0) as v11apositiontaking_10,	
	isnull(max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end), 0) as v99apositiontaking_10,	
	
	
	isnull(@v2apositiontaking_10_max, 0) as maxv2pos_10,
	isnull(@v3apositiontaking_10_max, 0) as maxv3pos_10,
	isnull(@v5apositiontaking_10_max, 0) as maxv5pos_10,
	isnull(@v8apositiontaking_10_max, 0) as maxv8pos_10,
	isnull(@v10apositiontaking_10_max, 0) as maxv10pos_10,
	isnull(@v11apositiontaking_10_max, 0) as maxv11pos_10,
	isnull(@v99apositiontaking_10_max, 0) as maxv99pos_10,
	
	isnull(@v2apositiontaking_10_min, 0) as minv2pos_10,
	isnull(@v3apositiontaking_10_min, 0) as minv3pos_10,
	isnull(@v5apositiontaking_10_min, 0) as minv5pos_10,
	isnull(@v8apositiontaking_10_min, 0) as minv8pos_10,
	isnull(@v10apositiontaking_10_min, 0) as minv10pos_10,
	isnull(@v11apositiontaking_10_min, 0) as minv11pos_10,
	isnull(@v99apositiontaking_10_min, 0) as minv99pos_10
	,CASE WHEN CDA.CustID IS NOT NULL THEN 1 ELSE 0 END AS IsDirectCustomer,
	ISNULL(NULLIF(MAX(c.site),''), MAX(ag.site)) AS Site,
	ISNULL(NULLIF(MAX(s.sitelabel),''), MAX(ags.SiteLabel)) AS SiteLabel,
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
	--BetSetting
	@minbet AS minbet, 
    @maxbet AS maxbet, 
    @maxpermatch AS maxpermatch, 
    @minbetv2 AS minbetv2, 
    @maxbetv2 AS maxbetv2, 
    @maxpermatchv2 AS maxpermatchv2, 
    @minbetv3 AS minbetv3, 
    @maxbetv3 AS maxbetv3, 
    @maxpermatchv3 AS maxpermatchv3, 
    @minbetv5 AS minbetv5, 
    @maxbetv5 AS maxbetv5, 
    @maxpermatchv5 AS maxpermatchv5, 
    @minbetv8 AS minbetv8, 
    @maxbetv8 AS maxbetv8, 
    @maxpermatchv8 AS maxpermatchv8, 
    @minbetv10 AS minbetv10, 
    @maxbetv10 AS maxbetv10, 
    @maxpermatchv10 AS maxpermatchv10, 
    @minbetv11 AS minbetv11, 
    @maxbetv11 AS maxbetv11, 
    @maxpermatchv11 AS maxpermatchv11, 
    @minbetv99 AS minbetv99, 
    @maxbetv99 AS maxbetv99, 
    @maxpermatchv99 AS maxpermatchv99, 
    @minbetv99mp AS minbetv99mp, 
    @maxbetv99mp AS maxbetv99mp, 
    @maxpermatchv99mp AS maxpermatchv99mp, 
    @minbetv1mp AS minbetv1mp, 
    @maxbetv1mp AS maxbetv1mp, 
    @maxpermatchv1mp AS maxpermatchv1mp,    
    @MaxPayoutPerMatch AS MaxPayoutPerMatch, 
    @MaxPayoutPerMatchv2 AS MaxPayoutPerMatchv2, 
    @MaxPayoutPerMatchv3 AS MaxPayoutPerMatchv3, 
    @MaxPayoutPerMatchv5 AS MaxPayoutPerMatchv5, 
    @MaxPayoutPerMatchv8 AS MaxPayoutPerMatchv8, 
    @MaxPayoutPerMatchv10 AS MaxPayoutPerMatchv10, 
    @MaxPayoutPerMatchv11 AS MaxPayoutPerMatchv11, 
    @MaxPayoutPerMatchv99 AS MaxPayoutPerMatchv99, 
    @MaxPayoutPerMatchv99mp AS MaxPayoutPerMatchv99mp, 
    @MaxPayoutPerMatchv1mp AS MaxPayoutPerMatchv1mp,
	--saba
	@minbetv1saba					AS minbetv1saba,
	@maxbetv1saba					AS maxbetv1saba,
	@maxpermatchv1saba				AS maxpermatchv1saba,
	@maxPayoutpermatchv1saba		AS maxPayoutpermatchv1saba,

	@minbetv2saba					AS minbetv2saba,
	@maxbetv2saba					AS maxbetv2saba,
	@maxpermatchv2saba				AS maxpermatchv2saba,
	@maxPayoutpermatchv2saba		AS maxPayoutpermatchv2saba,

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
from 
	customer as C with (NOLOCK) 
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	INNER JOIN CustInfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN CustSetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN exchange with (NOLOCK) ON C.currency=exchange.exchangeid
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, SuspendInfo
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
	CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp
	LEFT JOIN CustDirectAccount CDA WITH (NOLOCK) ON C.custid = CDA.CustID
	LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
	LEFT JOIN Site ags WITH (NOLOCK) ON ag.site=ags.site
where C.custid=@CustID
group by 
	C.username, C.firstname, C.lastname,c.username2, cps.closed,cps.reject,ci.currency,
	C.postal, C.email, C.phone, C.mobilephone, c.email, C.fax, 
	C.site, s.SiteLabel, C.ugroup, C.roleid,
	exchange.minbet, C.refcode1,C.address, C.city, C.state, C.country, ci.credit,
    CDA.CustID,
	sp.SuperStatus,sp.MasterStatus,sp.AgentStatus
    
END
GO 



