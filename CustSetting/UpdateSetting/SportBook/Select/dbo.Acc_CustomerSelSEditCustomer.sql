/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomer]  
	@CustId int,
	@SRecommend int
AS
BEGIN
/*
Created: 
Task : SUPER EDIT MASTER
DB: DBCUST/CUSTDB
Revisions:
    - 20090317@Phuc: disable FI, HR 	
	- 20090336@PhuongDoan: remove '_1' in SP name
	- 20090407@Lee: add 2 return fields for casino
	- 20090515@PhuongDao: Add 1x2 Commission
	- 20090701@Phuc: allow super disable auto MPT.
	- 20091215@Kiwi: Remove HR (151) and Financials (201).	
	- 20100505@Kiwi: Remove TransferOption at Group by
	- 20100903@Lukas:	- Add Mix parlay of mixed sports setting
						- Add Number game setting
						- Remove Mix parlay of basketball
	- 20101027@Lukas: Add max per ball (number game)
	- 20110727@Lukas: (Number Game)
				- Add more bettypes: Warrior, Next Combo, Number Group
				- Remove Dead ball Over/Under
	- 20131014@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]				
	- 20140624@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]

Param's Explanation:
• @CustID: master ID
  @SRecommend
*/
SET NOCOUNT ON

declare 
	@mspositiontaking_1_max smallmoney,
	@mspositiontaking_2_max smallmoney,
	@mspositiontaking_3_max smallmoney,
	@mspositiontaking_4_max smallmoney,
	@mspositiontaking_5_max smallmoney,
	@mspositiontaking_6_max smallmoney,
	@mspositiontaking_7_max smallmoney,
	@mspositiontaking_8_max smallmoney,
	@mspositiontaking_9_max smallmoney,
	@mspositiontaking_10_max smallmoney,
	@mspositiontaking_9999_max smallmoney,
	
	@mslivepositiontaking_1_max smallmoney,
	@mslivepositiontaking_3_max smallmoney,
	@mslivepositiontaking_7_max smallmoney,
	@mslivepositiontaking_8_max smallmoney,
	
	@v2mspositiontaking_1_max smallmoney,
	@v2mspositiontaking_2_max smallmoney,
	@v2mspositiontaking_3_max smallmoney,
	@v2mspositiontaking_7_max smallmoney,
	@v2mspositiontaking_8_max smallmoney,
--	@v2mspositiontaking_9_max smallmoney,
	@v2mspositiontaking_20_max smallmoney,
	@v2mspositiontaking_9999_max smallmoney,
	
	@v3mspositiontaking_1_max smallmoney,
	@v3mspositiontaking_2_max smallmoney,
	@v3mspositiontaking_3_max smallmoney,	
	@v3mspositiontaking_20_max smallmoney,

	@v5mspositiontaking_1_max smallmoney,
	@v5mspositiontaking_2_max smallmoney,
	@v5mspositiontaking_3_max smallmoney,	
	@v5mspositiontaking_20_max smallmoney,
	@v5mspositiontaking_9999_max smallmoney,	

	@v8mspositiontaking_1_max smallmoney,
	@v8mspositiontaking_3_max smallmoney,	
	@v8mspositiontaking_20_max smallmoney,

	@v10mspositiontaking_1_max smallmoney,
	@v10mspositiontaking_2_max smallmoney,
	@v10mspositiontaking_3_max smallmoney,	
	@v10mspositiontaking_20_max smallmoney,

	@v11mspositiontaking_1_max smallmoney,
	@v11mspositiontaking_20_max smallmoney,

	@v99mspositiontaking_1_max smallmoney,
	@v99mspositiontaking_2_max smallmoney,
	@v99mspositiontaking_3_max smallmoney,	
	@v99mspositiontaking_20_max smallmoney,
	@v99mspositiontaking_9999_max smallmoney,
	-- Mix parlay of mixed sports
	@v99mspositiontaking_9_max smallmoney,
	
	-- number game
	@v161mspositiontaking_81_max smallmoney,
	@v161mspositiontaking_83_max smallmoney,	
	@v161mspositiontaking_86_max smallmoney,
	@v161mspositiontaking_88_max smallmoney,

	@v161mslivepositiontaking_85_max smallmoney,
	@v161mslivepositiontaking_86_max smallmoney,
	@v161mslivepositiontaking_87_max smallmoney,
	@v161mslivepositiontaking_89_max smallmoney,
	@v161mslivepositiontaking_90_max smallmoney,

	@mspositiontaking_1_min smallmoney,
	@mspositiontaking_2_min smallmoney,
	@mspositiontaking_3_min smallmoney,
	@mspositiontaking_4_min smallmoney,
	@mspositiontaking_5_min smallmoney,
	@mspositiontaking_6_min smallmoney,
	@mspositiontaking_7_min smallmoney,
	@mspositiontaking_8_min smallmoney,
	@mspositiontaking_9_min smallmoney,
	@mspositiontaking_10_min smallmoney,
	@mspositiontaking_9999_min smallmoney,
	
	@mslivepositiontaking_1_min smallmoney,
	@mslivepositiontaking_3_min smallmoney,
	@mslivepositiontaking_7_min smallmoney,
	@mslivepositiontaking_8_min smallmoney,
	
	@v2mspositiontaking_1_min smallmoney,
	@v2mspositiontaking_2_min smallmoney,
	@v2mspositiontaking_3_min smallmoney,
	@v2mspositiontaking_7_min smallmoney,
	@v2mspositiontaking_8_min smallmoney,
--	@v2mspositiontaking_9_min smallmoney,
	@v2mspositiontaking_20_min smallmoney,
	@v2mspositiontaking_9999_min smallmoney,
	
	@v3mspositiontaking_1_min smallmoney,
	@v3mspositiontaking_2_min smallmoney,
	@v3mspositiontaking_3_min smallmoney,	
	@v3mspositiontaking_20_min smallmoney,
	
	@v5mspositiontaking_1_min smallmoney,
	@v5mspositiontaking_2_min smallmoney,
	@v5mspositiontaking_3_min smallmoney,	
	@v5mspositiontaking_20_min smallmoney,
	@v5mspositiontaking_9999_min smallmoney,
	
	@v8mspositiontaking_1_min smallmoney,
	@v8mspositiontaking_3_min smallmoney,	
	@v8mspositiontaking_20_min smallmoney,
	
	@v10mspositiontaking_1_min smallmoney,
	@v10mspositiontaking_2_min smallmoney,
	@v10mspositiontaking_3_min smallmoney,	
	@v10mspositiontaking_20_min smallmoney,
	
	@v11mspositiontaking_1_min smallmoney,
	@v11mspositiontaking_20_min smallmoney,
	
	@v99mspositiontaking_1_min smallmoney,
	@v99mspositiontaking_2_min smallmoney,
	@v99mspositiontaking_3_min smallmoney,	
	@v99mspositiontaking_20_min smallmoney,	
	@v99mspositiontaking_9999_min smallmoney,		
	-- mix parlay of mixed sports
	@v99mspositiontaking_9_min smallmoney,	

	-- number game
	@v161mspositiontaking_81_min smallmoney,	
	@v161mspositiontaking_83_min smallmoney,	
	@v161mspositiontaking_86_min smallmoney,
	@v161mspositiontaking_88_min smallmoney,	

	@v161mslivepositiontaking_85_min smallmoney,	
	@v161mslivepositiontaking_86_min smallmoney,	
	@v161mslivepositiontaking_87_min smallmoney,
	@v161mslivepositiontaking_89_min smallmoney,
	@v161mslivepositiontaking_90_min smallmoney,

	----------------------------------
	--Declare @mpt_max = m4
	@mpositiontaking_1_max smallmoney,
	@mpositiontaking_2_max smallmoney,
	@mpositiontaking_3_max smallmoney,
	@mpositiontaking_4_max smallmoney,
	@mpositiontaking_5_max smallmoney,
	@mpositiontaking_6_max smallmoney,
	@mpositiontaking_7_max smallmoney,
	@mpositiontaking_8_max smallmoney,
	@mpositiontaking_9_max smallmoney,
	@mpositiontaking_10_max smallmoney,
	@mpositiontaking_9999_max smallmoney,
	
	@mlivepositiontaking_1_max smallmoney,
	@mlivepositiontaking_3_max smallmoney,
	@mlivepositiontaking_7_max smallmoney,
	@mlivepositiontaking_8_max smallmoney,
	
	@v2mpositiontaking_1_max smallmoney,
	@v2mpositiontaking_2_max smallmoney,
	@v2mpositiontaking_3_max smallmoney,
	@v2mpositiontaking_7_max smallmoney,
	@v2mpositiontaking_8_max smallmoney,
--	@v2mpositiontaking_9_max smallmoney,
	@v2mpositiontaking_20_max smallmoney,
	@v2mpositiontaking_9999_max smallmoney,
	
	@v3mpositiontaking_1_max smallmoney,
	@v3mpositiontaking_2_max smallmoney,
	@v3mpositiontaking_3_max smallmoney,	
	@v3mpositiontaking_20_max smallmoney,
	
	@v5mpositiontaking_1_max smallmoney,
	@v5mpositiontaking_2_max smallmoney,
	@v5mpositiontaking_3_max smallmoney,	
	@v5mpositiontaking_20_max smallmoney,
	@v5mpositiontaking_9999_max smallmoney,
	
	@v8mpositiontaking_1_max smallmoney,
	@v8mpositiontaking_3_max smallmoney,	
	@v8mpositiontaking_20_max smallmoney,
	
	@v10mpositiontaking_1_max smallmoney,
	@v10mpositiontaking_2_max smallmoney,
	@v10mpositiontaking_3_max smallmoney,	
	@v10mpositiontaking_20_max smallmoney,
	
	@v11mpositiontaking_1_max smallmoney,
	@v11mpositiontaking_20_max smallmoney,

	@v99mpositiontaking_1_max smallmoney,
	@v99mpositiontaking_2_max smallmoney,
	@v99mpositiontaking_3_max smallmoney,	
	@v99mpositiontaking_20_max smallmoney,
	@v99mpositiontaking_9999_max smallmoney,
	-- mix parlay of mixed sports
	@v99mpositiontaking_9_max smallmoney,	
	
	-- number game
	@v161mpositiontaking_81_max smallmoney,
	@v161mpositiontaking_83_max smallmoney,	
	@v161mpositiontaking_86_max smallmoney,
	@v161mpositiontaking_88_max smallmoney,

	@v161mlivepositiontaking_85_max smallmoney,
	@v161mlivepositiontaking_86_max smallmoney,
	@v161mlivepositiontaking_87_max smallmoney,
	@v161mlivepositiontaking_89_max smallmoney,
	@v161mlivepositiontaking_90_max smallmoney,
	
	-- Outright PT
	@v2mpositiontaking_10_max smallmoney,
	@v3mpositiontaking_10_max smallmoney,
	@v5mpositiontaking_10_max smallmoney,
	@v8mpositiontaking_10_max smallmoney,
	@v10mpositiontaking_10_max smallmoney,
	@v11mpositiontaking_10_max smallmoney,
	@v99mpositiontaking_10_max smallmoney,

	@v2mspositiontaking_10_max smallmoney,
	@v3mspositiontaking_10_max smallmoney,
	@v5mspositiontaking_10_max smallmoney,
	@v8mspositiontaking_10_max smallmoney,
	@v10mspositiontaking_10_max smallmoney,
	@v11mspositiontaking_10_max smallmoney,
	@v99mspositiontaking_10_max smallmoney,
	
	@v2mspositiontaking_10_min smallmoney,
	@v3mspositiontaking_10_min smallmoney,
	@v5mspositiontaking_10_min smallmoney,
	@v8mspositiontaking_10_min smallmoney,
	@v10mspositiontaking_10_min smallmoney,
	@v11mspositiontaking_10_min smallmoney,
	@v99mspositiontaking_10_min smallmoney,
	
	----------------------------------
	@ga decimal(9,8), @gb decimal(9,8), @gc decimal(9,8), @gd decimal(9,8), @dis decimal(9,8),@dis1x2 decimal(9,8), @maxdownline smallmoney 
	--@disnumber decimal(9,8), 

Declare @MinBet_Max money,
	@MaxBet_Min money,
	@MaxPerMatch_Max money,
	@MaxPerMatch_Min money,
	
	@MinBetv2_Max money,
	@MaxBetv2_Min money,
	@MaxPerMatchv2_Min money,	
	@MaxPerMatchv2_Max money,

	@MinBetv3_Max money,
	@MaxBetv3_Min money,	
	@MaxPerMatchv3_Min money,	
	@MaxPerMatchv3_Max money,

	@MinBetv5_Max money,
	@MaxBetv5_Min money,	
	@MaxPerMatchv5_Min money,	
	@MaxPerMatchv5_Max money,

	@MinBetv8_Max money,
	@MaxBetv8_Min money,	
	@MaxPerMatchv8_Min money,	
	@MaxPerMatchv8_Max money,

	@MinBetv10_Max money,
	@MaxBetv10_Min money,	
	@MaxPerMatchv10_Min money,	
	@MaxPerMatchv10_Max money,

	@MinBetv11_Max money,
	@MaxBetv11_Min money,	
	@MaxPerMatchv11_Min money,	
	@MaxPerMatchv11_Max money,

	@MinBetv99_Max money,
	@MaxBetv99_Min money,	
	@MaxPerMatchv99_Min money,	
	@MaxPerMatchv99_Max money,
	
	@MinBetv99MP_Max money,
	@MaxBetv99MP_Min money,
	@MaxPerMatchv99MP_Min money,
	@MaxPerMatchv99MP_Max money,

	@MinBetv1MP_Max money,
	@MaxBetv1MP_Min money,
	@MaxPerMatchv1MP_Min money,
	@MaxPerMatchv1MP_Max money,
	
	@MinBetv161_Max money,
	@MaxBetv161_Min money,
	@MaxPerMatchv161_Min money,
	@MaxPerMatchv161_Max money,

	@MaxPerBallv161_Max money,
	
	@MinBetv164_Max money,
	@MaxBetv164_Min money,
	@MaxPerMatchv164_Min money,
	@MaxPerMatchv164_Max money,

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

	@Credit_AllOtherMaster money, @Credit_SAg money, @Credit_MAg_Max money, @Credit_MAg_Min money,
	@Ssuspended bit, @DisableAutoMPT bit,
	@IsInternal bit, @IsInternalSuper bit 

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
        @minbetv161             MONEY = 0, 
        @maxbetv161             MONEY = 0, 
        @maxpermatchv161        MONEY = 0, 
        @MaxPerBallv161         MONEY = 0, 
        @minbetv164             MONEY = 0, 
        @maxbetv164             MONEY = 0, 
        @maxpermatchv164        MONEY = 0, 
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

Select @Credit_AllOtherMaster = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where srecommend = @SRecommend and RoleID = 3 and custid <> @CustId
select @Credit_SAg = isnull(credit, 0) from CustInfo as ci with (NOLOCK) where CustID = @SRecommend

if @SRecommend <= 100
BEGIN
	--Set unlimited for dummy super
	select @Credit_MAg_Max = 10000000000
END
ELSE
BEGIN
	select @Credit_MAg_Max = @Credit_SAg - @Credit_AllOtherMaster
END


select @Credit_MAg_Min = max(c.credit)
from
	(
	Select isnull(sum(credit), 0) as credit	from custinfo with (NOLOCK) where mrecommend = @CustID and RoleID=1
	union all
	Select isnull(sum(credit), 0) as credit	from custinfo with (NOLOCK) where mrecommend = @CustID and RoleID=2
	) c
-----------------------------------

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
	@MinBetv161_Max = @MinBetv161_Max output, @MaxBetv161_Min = @MaxBetv161_Min output, @MaxPerMatchv161_Min = @MaxPerMatchv161_Min output, @MaxPerMatchv161_Max = @MaxPerMatchv161_Max output, @MaxPerBallv161_Max = @MaxPerBallv161_Max output,
	@MinBetv164_Max = @MinBetv164_Max output, @MaxBetv164_Min = @MaxBetv164_Min output, @MaxPerMatchv164_Min = @MaxPerMatchv164_Min output, @MaxPerMatchv164_Max = @MaxPerMatchv164_Max output,
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
	@minbetv161            		= @minbetv161            	OUTPUT,
	@maxbetv161            		= @maxbetv161            	OUTPUT,
	@maxpermatchv161       		= @maxpermatchv161       	OUTPUT,
	@MaxPerBallv161        		= @MaxPerBallv161        	OUTPUT,
	@minbetv164            		= @minbetv164            	OUTPUT,
	@maxbetv164            		= @maxbetv164            	OUTPUT,
	@maxpermatchv164       		= @maxpermatchv164       	OUTPUT,
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

-- Myanmar Odds

DECLARE @MyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0, @discountMyanmarOdds_max DECIMAL (9,8) = 0

SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
BEGIN
	SET @MyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)
	SET @discountMyanmarOdds_max = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @SRecommend AND Sporttype = 1 AND Bettype = 1),0)
END 

Select
	--get @mpt_max = m4
	@mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.mpositiontaking else 0 end),

	@mlivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),

	@v2mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v2mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v2mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v2mpositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v2mpositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
--	@v2mpositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end),	
	@v2mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v2mpositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	
	@v3mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end),
	@v3mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end),
	@v3mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end),	
	@v3mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end),
	
	@v5mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end),
	@v5mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end),
	@v5mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end),	
	@v5mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end),
	@v5mpositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.mpositiontaking else 0 end),	
	
	@v8mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end),
	@v8mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end),	
	@v8mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end),
	
	@v10mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end),
	@v10mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end),
	@v10mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end),	
	@v10mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end),
	
	@v11mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end),
	@v11mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end),

	@v99mpositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end),
	@v99mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end),
	@v99mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end),	
	@v99mpositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end),	
	@v99mpositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end),	
	-- Outright PT
	@v2mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@v3mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end),
	@v5mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end),
	@v8mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end),
	@v10mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end),
	@v11mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end),
	@v99mpositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end),
	
	-- mix parlay of mixed sports
	@v99mpositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end),
	

	-------------------------------------
	--get @mspt_max = min(s4, l4)
	@mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@mspositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@mslivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@mslivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@mslivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@mslivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.slivepositiontaking<co.maxlivepositiontaking then cs.slivepositiontaking else co.maxlivepositiontaking end else 0 end),

	@v2mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
--	@v2mspositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v2mspositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v3mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v3mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v3mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v3mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v5mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v5mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v5mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v5mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v5mspositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v8mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v8mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v8mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v10mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v10mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v10mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v10mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v11mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v11mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),

	@v99mspositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v99mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v99mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v99mspositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),	
	@v99mspositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),	

	-- mix parlay of mixed sports
	@v99mspositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	

	-- Outright PT
	@v2mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v3mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v5mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v8mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v10mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v11mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v99mspositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	-------------------------------------
	@mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_4_min = max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_5_min = max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_6_min = max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mspositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end),

	@mslivepositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@mslivepositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@mslivepositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@mslivepositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end),

	@v2mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end),
--	@v2mspositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mspositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end),

	@v3mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end),
	
	@v5mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mspositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end),
	
	@v8mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end),
	
	@v10mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end),
	
	@v11mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v11mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end),
	
	@v99mspositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mspositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mspositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end),
	-- mix parlay of mixed sports
	@v99mspositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end),
		
	
	
	-- Outright PT
	@v2mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v3mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v5mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v8mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v10mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v11mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v99mspositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end),
	
	@ga = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end),
	@gb = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end),
	@gc = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end),
	@gd = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end),
	
	@dis = max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.sdiscount else 0 end),
		
	@dis1x2 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end)

From 
	CustSetting as cs with (NOLOCK)
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @srecommend

--- number game
select 
	--@disnumber = max(case when cs3.bettype = 81 and cs3.sporttype = 161 then cs3.sdiscount else 0 end),
	@v161mpositiontaking_81_max = max(case when cs3.bettype=81 and cs3.sporttype = 161 then cs3.mpositiontaking else 0 end),
	@v161mpositiontaking_83_max = max(case when cs3.bettype=83 and cs3.sporttype = 161 then cs3.mpositiontaking else 0 end),	
	@v161mpositiontaking_86_max = max(case when cs3.bettype=86 and cs3.sporttype = 161 then cs3.mpositiontaking else 0 end),
	@v161mpositiontaking_88_max = max(case when cs3.bettype=88 and cs3.sporttype = 161 then cs3.mpositiontaking else 0 end),
	@v161mlivepositiontaking_85_max = max(case when cs3.bettype=85 and cs3.sporttype = 161 then cs3.mlivepositiontaking else 0 end),
	@v161mlivepositiontaking_86_max = max(case when cs3.bettype=86 and cs3.sporttype = 161 then cs3.mlivepositiontaking else 0 end),
	@v161mlivepositiontaking_87_max = max(case when cs3.bettype=87 and cs3.sporttype = 161 then cs3.mlivepositiontaking else 0 end),
	@v161mlivepositiontaking_89_max = max(case when cs3.bettype=89 and cs3.sporttype = 161 then cs3.mlivepositiontaking else 0 end),
	@v161mlivepositiontaking_90_max = max(case when cs3.bettype=90 and cs3.sporttype = 161 then cs3.mlivepositiontaking else 0 end),

	@v161mspositiontaking_81_max = max(case when cs3.bettype = 81 and cs3.sporttype = 161 then case when cs3.spositiontaking < co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end),
	@v161mspositiontaking_83_max = max(case when cs3.bettype = 83 and cs3.sporttype = 161 then case when cs3.spositiontaking < co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end),	
	@v161mspositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype = 161 then case when cs3.spositiontaking < co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end),
	@v161mspositiontaking_88_max = max(case when cs3.bettype = 88 and cs3.sporttype = 161 then case when cs3.spositiontaking < co3.maxpositiontaking then cs3.spositiontaking else co3.maxpositiontaking end else 0 end),
	@v161mslivepositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype = 161 then case when cs3.slivepositiontaking < co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161mslivepositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype = 161 then case when cs3.slivepositiontaking < co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161mslivepositiontaking_87_max = max(case when cs3.bettype = 87 and cs3.sporttype = 161 then case when cs3.slivepositiontaking < co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161mslivepositiontaking_89_max = max(case when cs3.bettype = 89 and cs3.sporttype = 161 then case when cs3.slivepositiontaking < co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161mslivepositiontaking_90_max = max(case when cs3.bettype = 90 and cs3.sporttype = 161 then case when cs3.slivepositiontaking < co3.maxlivepositiontaking then cs3.slivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	
	@v161mspositiontaking_81_min = max(case when co3.bettype = 81 and co3.sporttype = 161 then co3.minpositiontaking else 0 end),
	@v161mspositiontaking_83_min = max(case when co3.bettype = 83 and co3.sporttype = 161 then co3.minpositiontaking else 0 end),	
	@v161mspositiontaking_86_min = max(case when co3.bettype = 86 and co3.sporttype = 161 then co3.minpositiontaking else 0 end),
	@v161mspositiontaking_88_min = max(case when co3.bettype = 88 and co3.sporttype = 161 then co3.minpositiontaking else 0 end),
	@v161mslivepositiontaking_85_min = max(case when co3.bettype = 85 and co3.sporttype = 161 then co3.minlivepositiontaking else 0 end),
	@v161mslivepositiontaking_86_min = max(case when co3.bettype = 86 and co3.sporttype = 161 then co3.minlivepositiontaking else 0 end),
	@v161mslivepositiontaking_87_min = max(case when co3.bettype = 87 and co3.sporttype = 161 then co3.minlivepositiontaking else 0 end),
	@v161mslivepositiontaking_89_min = max(case when co3.bettype = 89 and co3.sporttype = 161 then co3.minlivepositiontaking else 0 end),
	@v161mslivepositiontaking_90_min = max(case when co3.bettype = 90 and co3.sporttype = 161 then co3.minlivepositiontaking else 0 end)

from custsetting3rd as cs3 with(nolock)
	 left join custoverride3rd as co3 with(nolock) on cs3.custid = co3.custid and cs3.sporttype = co3.sporttype and cs3.bettype = co3.bettype
where cs3.custid = @srecommend AND cs3.sporttype = 161


SELECT @Ssuspended = CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END FROM CustProductStatus WITH (NOLOCK) WHERE custid = @srecommend
--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @CustID


select 
	cps.closed, @Ssuspended as Ssuspended, isnull(@DisableAutoMPT,0) as DisableAutoMPT,	 
	cps.reject AS suspended,
	c.firstname, c.lastname, c.roleid, c.username,
	exchange.minbet AS defaultminbet, isnull(c.phone, '') as phone, isnull(c.mobilephone, '') as mobilephone, isnull(c.email, '') as email,isnull(c.fax, '') as fax,	
	ci.credit,
	@Credit_MAg_Min as Credit_Min,
	@Credit_MAg_Max as Credit_Max,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.adiscount else 0 end) as discount1x2,
	

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.spositiontaking else 0 end) as spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_9, 
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_10, 
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.mpositiontaking else 0 end) as mpositiontaking_9999, 

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.slivepositiontaking else 0 end) as slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_20,

	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.spositiontaking else 0 end) as v201spositiontaking_3,	--v201
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.spositiontaking else 0 end) as v201spositiontaking_2,	--v201
	
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_9999,

	-- mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_9,
	

	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.spositiontaking else 0 end) as v161spositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.spositiontaking else 0 end) as v161spositiontaking_83,	
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.spositiontaking else 0 end) as v161spositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.spositiontaking else 0 end) as v161spositiontaking_88,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end) as v161slivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end) as v161slivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end) as v161slivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end) as v161slivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end) as v161slivepositiontaking_90,


	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_20,

	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,---v201	
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,---v201	

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9999,

	--mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9,	
	
	
	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_83,	
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_88,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_90,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.autopositiontaking else 0 end) as auto_spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end) as auto_slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end) as auto_slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end) as auto_slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end) as auto_slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.autopositiontaking else 0 end) as auto_v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.autopositiontaking else 0 end) as auto_v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.autopositiontaking else 0 end) as auto_v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.autopositiontaking else 0 end) as auto_v3spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.autopositiontaking else 0 end) as auto_v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.autopositiontaking else 0 end) as auto_v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.autopositiontaking else 0 end) as auto_v8spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.autopositiontaking else 0 end) as auto_v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.autopositiontaking else 0 end) as auto_v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.autopositiontaking else 0 end) as auto_v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.autopositiontaking else 0 end) as auto_v10spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.autopositiontaking else 0 end) as auto_v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.autopositiontaking else 0 end) as auto_v11spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_9999,

	-- mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_9,
	
	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.autopositiontaking else 0 end) as auto_v161spositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.autopositiontaking else 0 end) as auto_v161spositiontaking_83,	
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autopositiontaking else 0 end) as auto_v161spositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.autopositiontaking else 0 end) as auto_v161spositiontaking_88,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.autolivepositiontaking else 0 end) as auto_v161slivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autolivepositiontaking else 0 end) as auto_v161slivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.autolivepositiontaking else 0 end) as auto_v161slivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.autolivepositiontaking else 0 end) as auto_v161slivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.autolivepositiontaking else 0 end) as auto_v161slivepositiontaking_90,


	@mspositiontaking_1_max as spositiontaking_1_max,
	@mspositiontaking_2_max as spositiontaking_2_max,
	@mspositiontaking_3_max as spositiontaking_3_max,
	@mspositiontaking_4_max as spositiontaking_4_max,
	@mspositiontaking_5_max as spositiontaking_5_max,
	@mspositiontaking_6_max as spositiontaking_6_max,
	@mspositiontaking_7_max as spositiontaking_7_max,
	@mspositiontaking_8_max as spositiontaking_8_max,
	@mspositiontaking_9_max as spositiontaking_9_max,
	@mspositiontaking_10_max as spositiontaking_10_max,
	@mspositiontaking_9999_max as spositiontaking_9999_max,
	
	@mslivepositiontaking_1_max as slivepositiontaking_1_max,
	@mslivepositiontaking_3_max as slivepositiontaking_3_max,
	@mslivepositiontaking_7_max as slivepositiontaking_7_max,
	@mslivepositiontaking_8_max as slivepositiontaking_8_max,
	
	@v2mspositiontaking_1_max as v2spositiontaking_1_max,
	@v2mspositiontaking_2_max as v2spositiontaking_2_max,
	@v2mspositiontaking_3_max as v2spositiontaking_3_max,
	@v2mspositiontaking_7_max as v2spositiontaking_7_max,
	@v2mspositiontaking_8_max as v2spositiontaking_8_max,
--	@v2mspositiontaking_9_max as v2spositiontaking_9_max,

	@v2mspositiontaking_20_max as v2spositiontaking_20_max,
	@v2mspositiontaking_9999_max as v2spositiontaking_9999_max,

	@v3mspositiontaking_1_max as v3spositiontaking_1_max,
	@v3mspositiontaking_2_max as v3spositiontaking_2_max,
	@v3mspositiontaking_3_max as v3spositiontaking_3_max,
	@v3mspositiontaking_20_max as v3spositiontaking_20_max,

	@v5mspositiontaking_1_max as v5spositiontaking_1_max,
	@v5mspositiontaking_2_max as v5spositiontaking_2_max,
	@v5mspositiontaking_3_max as v5spositiontaking_3_max,
	@v5mspositiontaking_20_max as v5spositiontaking_20_max,
	@v5mspositiontaking_9999_max as v5spositiontaking_9999_max,

	@v8mspositiontaking_1_max as v8spositiontaking_1_max,
	@v8mspositiontaking_3_max as v8spositiontaking_3_max,
	@v8mspositiontaking_20_max as v8spositiontaking_20_max,

	@v10mspositiontaking_1_max as v10spositiontaking_1_max,
	@v10mspositiontaking_2_max as v10spositiontaking_2_max,
	@v10mspositiontaking_3_max as v10spositiontaking_3_max,
	@v10mspositiontaking_20_max as v10spositiontaking_20_max,

	@v11mspositiontaking_1_max as v11spositiontaking_1_max,
	@v11mspositiontaking_20_max as v11spositiontaking_20_max,

	@v99mspositiontaking_1_max as v99spositiontaking_1_max,
	@v99mspositiontaking_2_max as v99spositiontaking_2_max,
	@v99mspositiontaking_3_max as v99spositiontaking_3_max,
	@v99mspositiontaking_20_max as v99spositiontaking_20_max,
	@v99mspositiontaking_9999_max as v99spositiontaking_9999_max,
	-- mix parlay of mixed sports
	@v99mspositiontaking_9_max as v99spositiontaking_9_max,
	
	-- number game
	@v161mspositiontaking_81_max as v161spositiontaking_81_max,
	@v161mspositiontaking_83_max as v161spositiontaking_83_max,	
	@v161mspositiontaking_86_max as v161spositiontaking_86_max,
	@v161mspositiontaking_88_max as v161spositiontaking_88_max,
	@v161mslivepositiontaking_85_max as v161slivepositiontaking_85_max,
	@v161mslivepositiontaking_86_max as v161slivepositiontaking_86_max,
	@v161mslivepositiontaking_87_max as v161slivepositiontaking_87_max,
	@v161mslivepositiontaking_89_max as v161slivepositiontaking_89_max,
	@v161mslivepositiontaking_90_max as v161slivepositiontaking_90_max,

	@mspositiontaking_1_max as auto_spositiontaking_1_max,
	@mspositiontaking_2_max as auto_spositiontaking_2_max,
	@mspositiontaking_3_max as auto_spositiontaking_3_max,
	@mspositiontaking_4_max as auto_spositiontaking_4_max,
	@mspositiontaking_5_max as auto_spositiontaking_5_max,
	@mspositiontaking_6_max as auto_spositiontaking_6_max,
	@mspositiontaking_7_max as auto_spositiontaking_7_max,
	@mspositiontaking_8_max as auto_spositiontaking_8_max,
	@mspositiontaking_9_max as auto_spositiontaking_9_max,
	@mspositiontaking_10_max as auto_spositiontaking_10_max,
	@mspositiontaking_9999_max as auto_spositiontaking_9999_max,
	
	@mslivepositiontaking_1_max as auto_slivepositiontaking_1_max,
	@mslivepositiontaking_3_max as auto_slivepositiontaking_3_max,
	@mslivepositiontaking_7_max as auto_slivepositiontaking_7_max,
	@mslivepositiontaking_8_max as auto_slivepositiontaking_8_max,
	
	@v2mspositiontaking_1_max as auto_v2spositiontaking_1_max,
	@v2mspositiontaking_2_max as auto_v2spositiontaking_2_max,
	@v2mspositiontaking_3_max as auto_v2spositiontaking_3_max,
	@v2mspositiontaking_7_max as auto_v2spositiontaking_7_max,
	@v2mspositiontaking_8_max as auto_v2spositiontaking_8_max,	
--	@v2mspositiontaking_9_max as auto_v2spositiontaking_9_max,
	@v2mspositiontaking_20_max as auto_v2spositiontaking_20_max,
	@v2mspositiontaking_9999_max as auto_v2spositiontaking_9999_max,
	
	@v3mspositiontaking_1_max as auto_v3spositiontaking_1_max,
	@v3mspositiontaking_2_max as auto_v3spositiontaking_2_max,
	@v3mspositiontaking_3_max as auto_v3spositiontaking_3_max,
	@v3mspositiontaking_20_max as auto_v3spositiontaking_20_max,
	
	@v5mspositiontaking_1_max as auto_v5spositiontaking_1_max,
	@v5mspositiontaking_2_max as auto_v5spositiontaking_2_max,
	@v5mspositiontaking_3_max as auto_v5spositiontaking_3_max,
	@v5mspositiontaking_20_max as auto_v5spositiontaking_20_max,
	@v5mspositiontaking_9999_max as auto_v5spositiontaking_9999_max,
	
	@v8mspositiontaking_1_max as auto_v8spositiontaking_1_max,
	@v8mspositiontaking_3_max as auto_v8spositiontaking_3_max,
	@v8mspositiontaking_20_max as auto_v8spositiontaking_20_max,
	
	@v10mspositiontaking_1_max as auto_v10spositiontaking_1_max,
	@v10mspositiontaking_2_max as auto_v10spositiontaking_2_max,
	@v10mspositiontaking_3_max as auto_v10spositiontaking_3_max,
	@v10mspositiontaking_20_max as auto_v10spositiontaking_20_max,
	
	@v11mspositiontaking_1_max as auto_v11spositiontaking_1_max,
	@v11mspositiontaking_20_max as auto_v11spositiontaking_20_max,
	
	@v99mspositiontaking_1_max as auto_v99spositiontaking_1_max,
	@v99mspositiontaking_2_max as auto_v99spositiontaking_2_max,
	@v99mspositiontaking_3_max as auto_v99spositiontaking_3_max,
	@v99mspositiontaking_20_max as auto_v99spositiontaking_20_max,
	@v99mspositiontaking_9999_max as auto_v99spositiontaking_9999_max,
	-- mix parlay of mixed sports
	@v99mspositiontaking_9_max as auto_v99spositiontaking_9_max,

	-- number game
	@v161mspositiontaking_81_max as auto_v161spositiontaking_81_max,
	@v161mspositiontaking_83_max as auto_v161spositiontaking_83_max,	
	@v161mspositiontaking_86_max as auto_v161spositiontaking_86_max,
	@v161mspositiontaking_88_max as auto_v161spositiontaking_88_max,
	@v161mslivepositiontaking_85_max as auto_v161slivepositiontaking_85_max,
	@v161mslivepositiontaking_86_max as auto_v161slivepositiontaking_86_max,
	@v161mslivepositiontaking_87_max as auto_v161slivepositiontaking_87_max,
	@v161mslivepositiontaking_89_max as auto_v161slivepositiontaking_89_max,
	@v161mslivepositiontaking_90_max as auto_v161slivepositiontaking_90_max,
	
	@ga as groupa_max,
	@gb as groupb_max,
	@gc as groupc_max,
	@gd as groupd_max,
	@dis as discountcs_max,
	@dis1x2 as discount1x2_max,	
	
	-- For MyanmarOdds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@MyanmarOdds,0) AS discountMyanmarOdds,
	ISNULL(@discountMyanmarOdds_max,0) AS discountMyanmarOdds_max,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.isautopositiontaking else 0 end) as isauto_spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end) as isauto_slivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end) as isauto_slivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end) as isauto_slivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end) as isauto_slivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.isautopositiontaking else 0 end) as isauto_v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.isautopositiontaking else 0 end) as isauto_v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.isautopositiontaking else 0 end) as isauto_v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.isautopositiontaking else 0 end) as isauto_v3spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.isautopositiontaking else 0 end) as isauto_v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.isautopositiontaking else 0 end) as isauto_v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.isautopositiontaking else 0 end) as isauto_v8spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.isautopositiontaking else 0 end) as isauto_v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.isautopositiontaking else 0 end) as isauto_v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.isautopositiontaking else 0 end) as isauto_v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.isautopositiontaking else 0 end) as isauto_v10spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.isautopositiontaking else 0 end) as isauto_v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.isautopositiontaking else 0 end) as isauto_v11spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_9999,

	-- mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_9,

	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.isautopositiontaking else 0 end) as isauto_v161spositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.isautopositiontaking else 0 end) as isauto_v161spositiontaking_83,	
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautopositiontaking else 0 end) as isauto_v161spositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.isautopositiontaking else 0 end) as isauto_v161spositiontaking_88,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.isautolivepositiontaking else 0 end) as isauto_v161slivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautolivepositiontaking else 0 end) as isauto_v161slivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.isautolivepositiontaking else 0 end) as isauto_v161slivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.isautolivepositiontaking else 0 end) as isauto_v161slivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.isautolivepositiontaking else 0 end) as isauto_v161slivepositiontaking_90,

	@mspositiontaking_1_max as mspositiontaking_1_max,
	@mspositiontaking_2_max as mspositiontaking_2_max,
	@mspositiontaking_3_max as mspositiontaking_3_max,
	@mspositiontaking_4_max as mspositiontaking_4_max,
	@mspositiontaking_5_max as mspositiontaking_5_max,
	@mspositiontaking_6_max as mspositiontaking_6_max,
	@mspositiontaking_7_max as mspositiontaking_7_max,
	@mspositiontaking_8_max as mspositiontaking_8_max,
	@mspositiontaking_9_max as mspositiontaking_9_max,
	@mspositiontaking_10_max as mspositiontaking_10_max,
	@mspositiontaking_9999_max as mspositiontaking_9999_max,
	
	@mslivepositiontaking_1_max as mslivepositiontaking_1_max,
	@mslivepositiontaking_3_max as mslivepositiontaking_3_max,
	@mslivepositiontaking_7_max as mslivepositiontaking_7_max,
	@mslivepositiontaking_8_max as mslivepositiontaking_8_max,
	
	@v2mspositiontaking_1_max as v2mspositiontaking_1_max,
	@v2mspositiontaking_2_max as v2mspositiontaking_2_max,
	@v2mspositiontaking_3_max as v2mspositiontaking_3_max,
	@v2mspositiontaking_7_max as v2mspositiontaking_7_max,
	@v2mspositiontaking_8_max as v2mspositiontaking_8_max,
--	@v2mspositiontaking_9_max as v2mspositiontaking_9_max,

	@v2mspositiontaking_20_max as v2mspositiontaking_20_max,
	@v2mspositiontaking_9999_max as v2mspositiontaking_9999_max,

	@v3mspositiontaking_1_max as v3mspositiontaking_1_max,
	@v3mspositiontaking_2_max as v3mspositiontaking_2_max,
	@v3mspositiontaking_3_max as v3mspositiontaking_3_max,
	@v3mspositiontaking_20_max as v3mspositiontaking_20_max,

	@v5mspositiontaking_1_max as v5mspositiontaking_1_max,
	@v5mspositiontaking_2_max as v5mspositiontaking_2_max,
	@v5mspositiontaking_3_max as v5mspositiontaking_3_max,
	@v5mspositiontaking_20_max as v5mspositiontaking_20_max,
	@v5mspositiontaking_9999_max as v5mspositiontaking_9999_max,

	@v8mspositiontaking_1_max as v8mspositiontaking_1_max,
	@v8mspositiontaking_3_max as v8mspositiontaking_3_max,
	@v8mspositiontaking_20_max as v8mspositiontaking_20_max,

	@v10mspositiontaking_1_max as v10mspositiontaking_1_max,
	@v10mspositiontaking_2_max as v10mspositiontaking_2_max,
	@v10mspositiontaking_3_max as v10mspositiontaking_3_max,
	@v10mspositiontaking_20_max as v10mspositiontaking_20_max,

	@v11mspositiontaking_1_max as v11mspositiontaking_1_max,
	@v11mspositiontaking_20_max as v11mspositiontaking_20_max,

	@v99mspositiontaking_1_max as v99mspositiontaking_1_max,
	@v99mspositiontaking_2_max as v99mspositiontaking_2_max,
	@v99mspositiontaking_3_max as v99mspositiontaking_3_max,
	@v99mspositiontaking_20_max as v99mspositiontaking_20_max,
	@v99mspositiontaking_9999_max as v99mspositiontaking_9999_max,

	-- mix parlay of mixed sports
	@v99mspositiontaking_9_max as v99mspositiontaking_9_max,
	

	-- number game
	@v161mspositiontaking_81_max as v161mspositiontaking_81_max,
	@v161mspositiontaking_83_max as v161mspositiontaking_83_max,	
	@v161mspositiontaking_86_max as v161mspositiontaking_86_max,
	@v161mspositiontaking_88_max as v161mspositiontaking_88_max,
	@v161mslivepositiontaking_85_max as v161mslivepositiontaking_85_max,
	@v161mslivepositiontaking_86_max as v161mslivepositiontaking_86_max,
	@v161mslivepositiontaking_87_max as v161mslivepositiontaking_87_max,
	@v161mslivepositiontaking_89_max as v161mslivepositiontaking_89_max,
	@v161mslivepositiontaking_90_max as v161mslivepositiontaking_90_max,

	@mspositiontaking_1_min as mspositiontaking_1_min,
	@mspositiontaking_2_min as mspositiontaking_2_min,
	@mspositiontaking_3_min as mspositiontaking_3_min,
	@mspositiontaking_4_min as mspositiontaking_4_min,
	@mspositiontaking_5_min as mspositiontaking_5_min,
	@mspositiontaking_6_min as mspositiontaking_6_min,
	@mspositiontaking_7_min as mspositiontaking_7_min,
	@mspositiontaking_8_min as mspositiontaking_8_min,
	@mspositiontaking_9_min as mspositiontaking_9_min,
	@mspositiontaking_10_min as mspositiontaking_10_min,
	@mspositiontaking_9999_min as mspositiontaking_9999_min,
	
	@mslivepositiontaking_1_min as mslivepositiontaking_1_min,
	@mslivepositiontaking_3_min as mslivepositiontaking_3_min,
	@mslivepositiontaking_7_min as mslivepositiontaking_7_min,
	@mslivepositiontaking_8_min as mslivepositiontaking_8_min,
	
	@v2mspositiontaking_1_min as v2mspositiontaking_1_min,
	@v2mspositiontaking_2_min as v2mspositiontaking_2_min,
	@v2mspositiontaking_3_min as v2mspositiontaking_3_min,
	@v2mspositiontaking_7_min as v2mspositiontaking_7_min,
	@v2mspositiontaking_8_min as v2mspositiontaking_8_min,
--	@v2mspositiontaking_9_min as v2mspositiontaking_9_min,
	@v2mspositiontaking_20_min as v2mspositiontaking_20_min,
	@v2mspositiontaking_9999_min as v2mspositiontaking_9999_min,
	
	@v3mspositiontaking_1_min as v3mspositiontaking_1_min,
	@v3mspositiontaking_2_min as v3mspositiontaking_2_min,
	@v3mspositiontaking_3_min as v3mspositiontaking_3_min,
	@v3mspositiontaking_20_min as v3mspositiontaking_20_min,
	
	@v5mspositiontaking_1_min as v5mspositiontaking_1_min,
	@v5mspositiontaking_2_min as v5mspositiontaking_2_min,
	@v5mspositiontaking_3_min as v5mspositiontaking_3_min,
	@v5mspositiontaking_20_min as v5mspositiontaking_20_min,
	@v5mspositiontaking_9999_min as v5mspositiontaking_9999_min,
	
	@v8mspositiontaking_1_min as v8mspositiontaking_1_min,
	@v8mspositiontaking_3_min as v8mspositiontaking_3_min,
	@v8mspositiontaking_20_min as v8mspositiontaking_20_min,
	
	@v10mspositiontaking_1_min as v10mspositiontaking_1_min,
	@v10mspositiontaking_2_min as v10mspositiontaking_2_min,
	@v10mspositiontaking_3_min as v10mspositiontaking_3_min,
	@v10mspositiontaking_20_min as v10mspositiontaking_20_min,
	
	@v11mspositiontaking_1_min as v11mspositiontaking_1_min,
	@v11mspositiontaking_20_min as v11mspositiontaking_20_min,

	@v99mspositiontaking_1_min as v99mspositiontaking_1_min,
	@v99mspositiontaking_2_min as v99mspositiontaking_2_min,
	@v99mspositiontaking_3_min as v99mspositiontaking_3_min,
	@v99mspositiontaking_20_min as v99mspositiontaking_20_min,
	@v99mspositiontaking_9999_min as v99mspositiontaking_9999_min,
	@v99mspositiontaking_9_min as v99mspositiontaking_9_min,
	
	-- number game
	@v161mspositiontaking_81_min as v161mspositiontaking_81_min,
	@v161mspositiontaking_83_min as v161mspositiontaking_83_min,	
	@v161mspositiontaking_86_min as v161mspositiontaking_86_min,
	@v161mspositiontaking_88_min as v161mspositiontaking_88_min,
	@v161mslivepositiontaking_85_min as v161mslivepositiontaking_85_min,
	@v161mslivepositiontaking_86_min as v161mslivepositiontaking_86_min,
	@v161mslivepositiontaking_87_min as v161mslivepositiontaking_87_min,
	@v161mslivepositiontaking_89_min as v161mslivepositiontaking_89_min,
	@v161mslivepositiontaking_90_min as v161mslivepositiontaking_90_min,
	
	
	-- get n3 to check m3 > n3 on the web
	max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_3_min,
	max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_4_min,
	max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_5_min,
	max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_6_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_8_min,
	max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_9_min, 
	max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_10_min, 
	max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_9999_min, 

	max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_8_min,

	max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_8_min,
--	max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_9_min,

	max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_20_min,
	max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_9999_min,

	max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_20_min,
	max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_9999_min,

	max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_1_min,
	max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_20_min,
	max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_9999_min,

	-- mix parlay of mixed sports
	max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_9_min,

	-- number game
	max(case when co3.bettype = 81 and co3.sporttype= 161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_81_min,
	max(case when co3.bettype = 83 and co3.sporttype= 161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_83_min,	
	max(case when co3.bettype = 86 and co3.sporttype= 161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_86_min,
	max(case when co3.bettype = 88 and co3.sporttype= 161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_88_min,
	max(case when co3.bettype = 85 and co3.sporttype= 161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_85_min,
	max(case when co3.bettype = 86 and co3.sporttype= 161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_86_min,
	max(case when co3.bettype = 87 and co3.sporttype= 161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_87_min,
	max(case when co3.bettype = 89 and co3.sporttype= 161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_89_min,
	max(case when co3.bettype = 90 and co3.sporttype= 161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_90_min,

	/*
	max(case when co.bettype = 1 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_3_max,
	max(case when co.bettype = 4 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_4_max,
	max(case when co.bettype = 5 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_5_max,
	max(case when co.bettype = 6 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_6_max,
	max(case when co.bettype = 7 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_8_max,
	max(case when co.bettype = 9 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_9_max, 
	max(case when co.bettype = 10 and co.sporttype=1 then co.maxpositiontaking else 0 end) as mpositiontaking_10_max, 

	max(case when co.bettype = 1 and co.sporttype=1 then co.maxlivepositiontaking else 0 end) as mlivepositiontaking_1_max,
	max(case when co.bettype = 3 and co.sporttype=1 then co.maxlivepositiontaking else 0 end) as mlivepositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=1 then co.maxlivepositiontaking else 0 end) as mlivepositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then co.maxlivepositiontaking else 0 end) as mlivepositiontaking_8_max,

	max(case when co.bettype = 1 and co.sporttype=2 then co.maxpositiontaking else 0 end) as v2mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=2 then co.maxpositiontaking else 0 end) as v2mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=2 then co.maxpositiontaking else 0 end) as v2mpositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=2 then co.maxpositiontaking else 0 end) as v2mpositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=2 then co.maxpositiontaking else 0 end) as v2mpositiontaking_8_max,
	*/
	--get mpt_max = min(m4, l3), to check m3 <= mpt_max on the web 
	max(case when co.bettype = 1 and co.sporttype=1 then case when @mpositiontaking_1_max<co.maxpositiontaking then @mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=1 then case when @mpositiontaking_2_max<co.maxpositiontaking then @mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=1 then case when @mpositiontaking_3_max<co.maxpositiontaking then @mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as mpositiontaking_3_max,
	max(case when co.bettype = 4 and co.sporttype=1 then case when @mpositiontaking_4_max<co.maxpositiontaking then @mpositiontaking_4_max else co.maxpositiontaking end else 0 end) as mpositiontaking_4_max,
	max(case when co.bettype = 5 and co.sporttype=1 then case when @mpositiontaking_5_max<co.maxpositiontaking then @mpositiontaking_5_max else co.maxpositiontaking end else 0 end) as mpositiontaking_5_max,
	max(case when co.bettype = 6 and co.sporttype=1 then case when @mpositiontaking_6_max<co.maxpositiontaking then @mpositiontaking_6_max else co.maxpositiontaking end else 0 end) as mpositiontaking_6_max,
	max(case when co.bettype = 7 and co.sporttype=1 then case when @mpositiontaking_7_max<co.maxpositiontaking then @mpositiontaking_7_max else co.maxpositiontaking end else 0 end) as mpositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then case when @mpositiontaking_8_max<co.maxpositiontaking then @mpositiontaking_8_max else co.maxpositiontaking end else 0 end) as mpositiontaking_8_max,
	max(case when co.bettype = 9 and co.sporttype=1 then case when @mpositiontaking_9_max<co.maxpositiontaking then @mpositiontaking_9_max else co.maxpositiontaking end else 0 end) as mpositiontaking_9_max,
	
	max(case when co.bettype = 10 and co.sporttype=1 then case when @mpositiontaking_10_max<co.maxpositiontaking then @mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as mpositiontaking_10_max,
		
	max(case when co.bettype = 9999 and co.sporttype=1 then case when @mpositiontaking_9999_max<co.maxpositiontaking then @mpositiontaking_9999_max else co.maxpositiontaking end else 0 end) as mpositiontaking_9999_max,

	max(case when co.bettype = 1 and co.sporttype=1 then case when @mlivepositiontaking_1_max<co.maxlivepositiontaking then @mlivepositiontaking_1_max else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_1_max,
	max(case when co.bettype = 3 and co.sporttype=1 then case when @mlivepositiontaking_3_max<co.maxlivepositiontaking then @mlivepositiontaking_3_max else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=1 then case when @mlivepositiontaking_7_max<co.maxlivepositiontaking then @mlivepositiontaking_7_max else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then case when @mlivepositiontaking_8_max<co.maxlivepositiontaking then @mlivepositiontaking_8_max else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_8_max,

	max(case when co.bettype = 1 and co.sporttype=2 then case when @v2mpositiontaking_1_max<co.maxpositiontaking then @v2mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=2 then case when @v2mpositiontaking_2_max<co.maxpositiontaking then @v2mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=2 then case when @v2mpositiontaking_3_max<co.maxpositiontaking then @v2mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=2 then case when @v2mpositiontaking_7_max<co.maxpositiontaking then @v2mpositiontaking_7_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=2 then case when @v2mpositiontaking_8_max<co.maxpositiontaking then @v2mpositiontaking_8_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_8_max,
--	max(case when co.bettype = 9 and co.sporttype=2 then case when @v2mpositiontaking_9_max<co.maxpositiontaking then @v2mpositiontaking_9_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_9_max,

	max(case when co.bettype = 20 and co.sporttype=2 then case when @v2mpositiontaking_20_max<co.maxpositiontaking then @v2mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_20_max,
	max(case when co.bettype = 9999 and co.sporttype=2 then case when @v2mpositiontaking_9999_max<co.maxpositiontaking then @v2mpositiontaking_9999_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_9999_max,

	max(case when co.bettype = 1 and co.sporttype=3 then case when @v3mpositiontaking_1_max<co.maxpositiontaking then @v3mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v3mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=3 then case when @v3mpositiontaking_2_max<co.maxpositiontaking then @v3mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v3mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=3 then case when @v3mpositiontaking_3_max<co.maxpositiontaking then @v3mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v3mpositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=3 then case when @v3mpositiontaking_20_max<co.maxpositiontaking then @v3mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v3mpositiontaking_20_max,
	
	max(case when co.bettype = 1 and co.sporttype=5 then case when @v5mpositiontaking_1_max<co.maxpositiontaking then @v5mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=5 then case when @v5mpositiontaking_2_max<co.maxpositiontaking then @v5mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=5 then case when @v5mpositiontaking_3_max<co.maxpositiontaking then @v5mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=5 then case when @v5mpositiontaking_20_max<co.maxpositiontaking then @v5mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_20_max,
	max(case when co.bettype = 9999 and co.sporttype=5 then case when @v5mpositiontaking_9999_max<co.maxpositiontaking then @v5mpositiontaking_9999_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_9999_max,
	
	max(case when co.bettype = 1 and co.sporttype=8 then case when @v8mpositiontaking_1_max<co.maxpositiontaking then @v8mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v8mpositiontaking_1_max,
	max(case when co.bettype = 3 and co.sporttype=8 then case when @v8mpositiontaking_3_max<co.maxpositiontaking then @v8mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v8mpositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=8 then case when @v8mpositiontaking_20_max<co.maxpositiontaking then @v8mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v8mpositiontaking_20_max,
	
	max(case when co.bettype = 1 and co.sporttype=10 then case when @v10mpositiontaking_1_max<co.maxpositiontaking then @v10mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v10mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=10 then case when @v10mpositiontaking_2_max<co.maxpositiontaking then @v10mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v10mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=10 then case when @v10mpositiontaking_3_max<co.maxpositiontaking then @v10mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v10mpositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=10 then case when @v10mpositiontaking_20_max<co.maxpositiontaking then @v10mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v10mpositiontaking_20_max,
	
	max(case when co.bettype = 1 and co.sporttype=11 then case when @v11mpositiontaking_1_max<co.maxpositiontaking then @v11mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v11mpositiontaking_1_max,
	max(case when co.bettype = 20 and co.sporttype=11 then case when @v11mpositiontaking_20_max<co.maxpositiontaking then @v11mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v11mpositiontaking_20_max,
	
	max(case when co.bettype = 1 and co.sporttype=99 then case when @v99mpositiontaking_1_max<co.maxpositiontaking then @v99mpositiontaking_1_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=99 then case when @v99mpositiontaking_2_max<co.maxpositiontaking then @v99mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=99 then case when @v99mpositiontaking_3_max<co.maxpositiontaking then @v99mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=99 then case when @v99mpositiontaking_20_max<co.maxpositiontaking then @v99mpositiontaking_20_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_20_max,
	max(case when co.bettype = 9999 and co.sporttype=99 then case when @v99mpositiontaking_9999_max<co.maxpositiontaking then @v99mpositiontaking_9999_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_9999_max,

	-- mix parlay of mixed sports
	max(case when co.bettype = 9 and co.sporttype=99 then case when @v99mpositiontaking_9_max<co.maxpositiontaking then @v99mpositiontaking_9_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_9_max,

	--number game
	max(case when co3.bettype = 81 and co3.sporttype = 161 then case when @v161mpositiontaking_81_max < co3.maxpositiontaking then @v161mpositiontaking_81_max else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_81_max,
	max(case when co3.bettype = 83 and co3.sporttype = 161 then case when @v161mpositiontaking_83_max < co3.maxpositiontaking then @v161mpositiontaking_83_max else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_83_max,	
	max(case when co3.bettype = 86 and co3.sporttype = 161 then case when @v161mpositiontaking_86_max < co3.maxpositiontaking then @v161mpositiontaking_86_max else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_86_max,
	max(case when co3.bettype = 88 and co3.sporttype = 161 then case when @v161mpositiontaking_88_max < co3.maxpositiontaking then @v161mpositiontaking_88_max else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_88_max,
	max(case when co3.bettype = 85 and co3.sporttype = 161 then case when @v161mlivepositiontaking_85_max < co3.maxlivepositiontaking then @v161mlivepositiontaking_85_max else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_85_max,
	max(case when co3.bettype = 86 and co3.sporttype = 161 then case when @v161mlivepositiontaking_86_max < co3.maxlivepositiontaking then @v161mlivepositiontaking_86_max else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_86_max,
	max(case when co3.bettype = 87 and co3.sporttype = 161 then case when @v161mlivepositiontaking_87_max < co3.maxlivepositiontaking then @v161mlivepositiontaking_87_max else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_87_max,
	max(case when co3.bettype = 89 and co3.sporttype = 161 then case when @v161mlivepositiontaking_89_max < co3.maxlivepositiontaking then @v161mlivepositiontaking_89_max else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_89_max,
	max(case when co3.bettype = 90 and co3.sporttype = 161 then case when @v161mlivepositiontaking_90_max < co3.maxlivepositiontaking then @v161mlivepositiontaking_90_max else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_90_max,
	
	-- number game
	ci.DisableNumber,
	
	-- Provide dedicated Outright PT for each sport --
	--- Outright PT for Super
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_10,
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.isautopositiontaking else 0 end) as isauto_v2spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.isautopositiontaking else 0 end) as isauto_v3spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.isautopositiontaking else 0 end) as isauto_v5spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.isautopositiontaking else 0 end) as isauto_v8spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.isautopositiontaking else 0 end) as isauto_v10spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.isautopositiontaking else 0 end) as isauto_v11spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.isautopositiontaking else 0 end) as isauto_v99spositiontaking_10,
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.autopositiontaking else 0 end) as auto_v2spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.autopositiontaking else 0 end) as auto_v3spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.autopositiontaking else 0 end) as auto_v5spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.autopositiontaking else 0 end) as auto_v8spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.autopositiontaking else 0 end) as auto_v10spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.autopositiontaking else 0 end) as auto_v11spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.autopositiontaking else 0 end) as auto_v99spositiontaking_10,
	
	@v2mspositiontaking_10_max as auto_v2spositiontaking_10_max,
	@v3mspositiontaking_10_max as auto_v3spositiontaking_10_max,
	@v5mspositiontaking_10_max as auto_v5spositiontaking_10_max,
	@v8mspositiontaking_10_max as auto_v8spositiontaking_10_max,
	@v10mspositiontaking_10_max as auto_v10spositiontaking_10_max,
	@v11mspositiontaking_10_max as auto_v11spositiontaking_10_max,
	@v99mspositiontaking_10_max as auto_v99spositiontaking_10_max,
	
	@v2mspositiontaking_10_max as v2spositiontaking_10_max,
	@v3mspositiontaking_10_max as v3spositiontaking_10_max,
	@v5mspositiontaking_10_max as v5spositiontaking_10_max,
	@v8mspositiontaking_10_max as v8spositiontaking_10_max,
	@v10mspositiontaking_10_max as v10spositiontaking_10_max,
	@v11mspositiontaking_10_max as v11spositiontaking_10_max,
	@v99mspositiontaking_10_max as v99spositiontaking_10_max,
	
	--- Outright PT for Master
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_10,
	
	
	max(case when co.bettype = 10 and co.sporttype=2 then case when @v2mpositiontaking_10_max <co.maxpositiontaking then @v2mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v2mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=3 then case when @v3mpositiontaking_10_max <co.maxpositiontaking then @v3mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v3mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=5 then case when @v5mpositiontaking_10_max <co.maxpositiontaking then @v5mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v5mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=8 then case when @v8mpositiontaking_10_max <co.maxpositiontaking then @v8mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v8mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=10 then case when @v10mpositiontaking_10_max <co.maxpositiontaking then @v10mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v10mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=11 then case when @v11mpositiontaking_10_max <co.maxpositiontaking then @v11mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v11mpositiontaking_10_max,
	max(case when co.bettype = 10 and co.sporttype=99 then case when @v99mpositiontaking_10_max <co.maxpositiontaking then @v99mpositiontaking_10_max else co.maxpositiontaking end else 0 end) as v99mpositiontaking_10_max,
	
	
	@v2mspositiontaking_10_max as v2mspositiontaking_10_max,
	@v3mspositiontaking_10_max as v3mspositiontaking_10_max,
	@v5mspositiontaking_10_max as v5mspositiontaking_10_max,
	@v8mspositiontaking_10_max as v8mspositiontaking_10_max,
	@v10mspositiontaking_10_max as v10mspositiontaking_10_max,
	@v11mspositiontaking_10_max as v11mspositiontaking_10_max,
	@v99mspositiontaking_10_max as v99mspositiontaking_10_max,
	
	
	@v2mspositiontaking_10_min as v2mspositiontaking_10_min,
	@v3mspositiontaking_10_min as v3mspositiontaking_10_min,
	@v5mspositiontaking_10_min as v5mspositiontaking_10_min,
	@v8mspositiontaking_10_min as v8mspositiontaking_10_min,
	@v10mspositiontaking_10_min as v10mspositiontaking_10_min,
	@v11mspositiontaking_10_min as v11mspositiontaking_10_min,
	@v99mspositiontaking_10_min as v99mspositiontaking_10_min,
	
	max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_10_min,
	MAX(c.site) AS Site,

	isnull(@MinBet_Max, 0) as MinBet_Max,	
	isnull(@MaxBet_Min, 0) as MaxBet_Min,
	isnull(@MaxPerMatch_Min, 0) as MaxPerMatch_Min,
	isnull(@MaxPerMatch_Max, 0) as MaxPerMatch_Max,
	
	isnull(@MinBetv2_Max, 0) as MinBetv2_Max,
	isnull(@MaxBetv2_Min, 0) as MaxBetv2_Min,	
	isnull(@MaxPerMatchv2_Min, 0) as MaxPerMatchv2_Min,	
	isnull(@MaxPerMatchv2_Max, 0) as MaxPerMatchv2_Max,
	
	isnull(@MinBetv3_Max, 0) as MinBetv3_Max,
	isnull(@MaxBetv3_Min, 0) as MaxBetv3_Min,	
	isnull(@MaxPerMatchv3_Min, 0) as MaxPerMatchv3_Min,	
	isnull(@MaxPerMatchv3_Max, 0) as MaxPerMatchv3_Max,
	
	isnull(@MinBetv5_Max, 0) as MinBetv5_Max,
	isnull(@MaxBetv5_Min, 0) as MaxBetv5_Min,	
	isnull(@MaxPerMatchv5_Min, 0) as MaxPerMatchv5_Min,	
	isnull(@MaxPerMatchv5_Max, 0) as MaxPerMatchv5_Max,
	
	isnull(@MinBetv8_Max, 0) as MinBetv8_Max,
	isnull(@MaxBetv8_Min, 0) as MaxBetv8_Min,	
	isnull(@MaxPerMatchv8_Min, 0) as MaxPerMatchv8_Min,	
	isnull(@MaxPerMatchv8_Max, 0) as MaxPerMatchv8_Max,
	
	isnull(@MinBetv10_Max, 0) as MinBetv10_Max,
	isnull(@MaxBetv10_Min, 0) as MaxBetv10_Min,	
	isnull(@MaxPerMatchv10_Min, 0) as MaxPerMatchv10_Min,	
	isnull(@MaxPerMatchv10_Max, 0) as MaxPerMatchv10_Max,
		
	isnull(@MinBetv11_Max, 0) as MinBetv11_Max,
	isnull(@MaxBetv11_Min, 0) as MaxBetv11_Min,	
	isnull(@MaxPerMatchv11_Min, 0) as MaxPerMatchv11_Min,	
	isnull(@MaxPerMatchv11_Max, 0) as MaxPerMatchv11_Max,
	
	isnull(@MinBetv99_Max, 0) as MinBetv99_Max,
	isnull(@MaxBetv99_Min, 0) as MaxBetv99_Min,	
	isnull(@MaxPerMatchv99_Min, 0) as MaxPerMatchv99_Min,	
	isnull(@MaxPerMatchv99_Max, 0) as MaxPerMatchv99_Max,

	isnull(@MinBetv99MP_Max,0) as MinBetv99MP_Max,
	isnull(@MaxBetv99MP_Min,0) as MaxBetv99MP_Min,
	isnull(@MaxPerMatchv99MP_Min,0) as MaxPerMatchv99MP_Min,
	isnull(@MaxPerMatchv99MP_Max,0) as MaxPerMatchv99MP_Max,
	
	isnull(@MinBetv1MP_Max,0) as MinBetv1MP_Max,
	isnull(@MaxBetv1MP_Min,0) as MaxBetv1MP_Min,
	isnull(@MaxPerMatchv1MP_Min,0) as MaxPerMatchv1MP_Min,
	isnull(@MaxPerMatchv1MP_Max,0) as MaxPerMatchv1MP_Max,

	isnull(@MinBetv161_Max, 0) as MinBetv161_Max,
	isnull(@MaxBetv161_Min, 0) as MaxBetv161_Min,	
	isnull(@MaxPerMatchv161_Min, 0) as MaxPerMatchv161_Min,	
	isnull(@MaxPerMatchv161_Max, 0) as MaxPerMatchv161_Max,

	isnull(@MaxPerBallv161_Max, 0) as MaxPerBallv161_Max,
	
	isnull(@MinBetv164_Max, 0) as MinBetv164_Max,
	isnull(@MaxBetv164_Min, 0) as MaxBetv164_Min,	
	isnull(@MaxPerMatchv164_Min, 0) as MaxPerMatchv164_Min,	
	isnull(@MaxPerMatchv164_Max, 0) as MaxPerMatchv164_Max,
	
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
    @minbetv161 AS minbetv161, 
    @maxbetv161 AS maxbetv161, 
    @maxpermatchv161 AS maxpermatchv161, 
    @MaxPerBallv161 AS MaxPerBallv161, 
    @minbetv164 AS minbetv164, 
    @maxbetv164 AS maxbetv164, 
    @maxpermatchv164 AS maxpermatchv164, 
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
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custsetting3rd as cs3 with(nolock) on c.custid = cs3.custid
	INNER JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
	--left join custoverride3rd for sporttype = 164
	LEFT JOIN custoverride3rd as co3 with(nolock) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
	INNER JOIN exchange with (NOLOCK) ON c.currency = exchange.exchangeid
where 
	c.roleid=3 and c.custid=@CustID and
	c.srecommend=@SRecommend
group by 
	cps.closed, 
	cps.reject,
	c.firstname, c.lastname, c.roleid, c.username,
	exchange.minbet, c.phone, c.mobilephone, c.email,c.fax,
	ci.credit,
	-- number game
	ci.DisableNumber
END
GO



