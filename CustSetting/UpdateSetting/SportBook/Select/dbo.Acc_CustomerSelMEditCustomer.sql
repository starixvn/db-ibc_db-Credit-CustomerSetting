/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomer]
	@CustId		INT,
	@MRecommend	INT
AS
BEGIN
/*
Created: 
Task : MASTER EDIT AGENT
DB: DBCUST.CustDB

Revisions:
	- 20090317@Phuc: disable FI, HR 	
	- 20090407@Lee: add 2 return fields for casino
	- 20090515@PhuongDao: Add 1x2 Commission 
	- 20090521@PhuongDao: Get maxcredit from CustAgent 
	- 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100507@Phuc: remove group by maxcredit.
	- 20100913@Terry: 
						+ Add new number game (161)
						+ Add new mix sports (99MP)
						+ Remove mixparlay of Basketball
	- 20101027@Lukas: add max per ball (number game)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20110913@Jamie: Remove linked server for checking belonging 
	- 20120829@Johnson: max_um2 = min (m3,m4), max_m2 = min(m3,m4) 
	- 20131016@Kathy: Add HR Fixed Odds(154) [Redmine:#6505]
	- 20140626@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190909@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
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
• @CustID: AgentID
  @MRecommend
*/

SET NOCOUNT ON
--SET ANSI_WARNINGS OFF
---------------------------
-- ***Check Downline Belonging***
declare @roleid tinyint, @Username varchar(30), @srecommend INT

EXEC Age_CustomerSelCheckBelongingByCustID 
	@SessionCustID = @MRecommend, 
	@Custid = @custid,
	@Username = @Username OUTPUT,
	@roleid = @roleid OUTPUT
	if (@roleid = 0) return
---------------------------

Declare 
	@MinBet_Max money,
	@MaxBet_Min money,
	@MaxPerMatch_Min money,
	@MaxPerMatch_Max money,
	
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

	@ga decimal(9,8), @gb decimal(9,8), @gc decimal(9,8), @gd decimal(9,8), @dis decimal(9,8), 
		@dis1x2 decimal(9,8),
	@Credit_AllOtherAgent money, @Credit_AllMember money, @Credit_MAg money,
	@Credit_Ag_Min money, @Credit_Ag_Max money, @MaxCredit_Mem_Min money, @Mem_MaxCredit money,
	@Msuspended bit, @DisableAutoMPT bit

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Maxcredit 
SELECT @Mem_MaxCredit = isnull(maxcredit,0) FROM CustAgent WITH (NOLOCK) 
WHERE  custid=@CustID 

Select @Credit_AllOtherAgent = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where mrecommend = @MRecommend and RoleID = 2 and Custid <> @CustId
select @Credit_MAg = isnull(credit, 0) from CustInfo as ci with (NOLOCK) where CustID = @MRecommend

select @Credit_Ag_Max = @Credit_MAg - @Credit_AllOtherAgent

--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @Mrecommend

-----------------------------------------------------------------
select @Credit_Ag_Min = max(c.credit)
from
	(
	Select isnull(sum(credit), 0) as credit from custinfo with (NOLOCK) where recommend = @CustID and RoleID=1
	) c
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @MaxCredit_Mem_Min = max (isnull(credit,0)) from custinfo 
where recommend = @CustID and roleid =1 

SELECT @srecommend = srecommend FROM custInfo WITH(NOLOCK) WHERE custid = @CustId
	
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

select 
	@ga = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupa else 0 end),
	@gb = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupb else 0 end),
	@gc = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupc else 0 end),
	@gd = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupd else 0 end),
	@dis = max(case when acs.bettype = 4 and acs.sporttype=1 then acs.adiscount else 0 end),
	@dis1x2 = max(case when acs.bettype = 5 and acs.sporttype=1 then acs.adiscount else 0 end)
	
from custsetting as acs with (NOLOCK)
where acs.custid = @MRecommend

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

-- Myanmar Odds

DECLARE @MyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0, @discountMyanmarOdds_max DECIMAL (9,8) = 0

SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
BEGIN
	SET @MyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)
	SET @discountMyanmarOdds_max = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @MRecommend AND Sporttype = 1 AND Bettype = 1),0)
END

declare
	@max_mapositiontaking_1 smallmoney,
	@max_mapositiontaking_2 smallmoney,
	@max_mapositiontaking_3 smallmoney,
	@max_mapositiontaking_4 smallmoney,
	@max_mapositiontaking_5 smallmoney,
	@max_mapositiontaking_6 smallmoney,
	@max_mapositiontaking_7 smallmoney,
	@max_mapositiontaking_8 smallmoney,
	@max_mapositiontaking_9 smallmoney,
	@max_mapositiontaking_10 smallmoney,
	@max_mapositiontaking_9999 smallmoney,
	
	@max_malivepositiontaking_1 smallmoney,
	@max_malivepositiontaking_3 smallmoney,
	@max_malivepositiontaking_7 smallmoney,
	@max_malivepositiontaking_8 smallmoney,
	
	@max_v2mapositiontaking_1 smallmoney,
	@max_v2mapositiontaking_2 smallmoney,
	@max_v2mapositiontaking_3 smallmoney,
	@max_v2mapositiontaking_7 smallmoney,
	@max_v2mapositiontaking_8 smallmoney,
--	@max_v2mapositiontaking_9 smallmoney,
	@max_v2mapositiontaking_20 smallmoney,
	@max_v2mapositiontaking_9999 smallmoney,

	@max_v3mapositiontaking_1 smallmoney,
	@max_v3mapositiontaking_2 smallmoney,
	@max_v3mapositiontaking_3 smallmoney,
	@max_v3mapositiontaking_20 smallmoney,

	@max_v5mapositiontaking_1 smallmoney,
	@max_v5mapositiontaking_2 smallmoney,
	@max_v5mapositiontaking_3 smallmoney,
	@max_v5mapositiontaking_20 smallmoney,
	@max_v5mapositiontaking_9999 smallmoney,

	@max_v8mapositiontaking_1 smallmoney,
	@max_v8mapositiontaking_3 smallmoney,
	@max_v8mapositiontaking_20 smallmoney,

	@max_v10mapositiontaking_1 smallmoney,
	@max_v10mapositiontaking_2 smallmoney,
	@max_v10mapositiontaking_3 smallmoney,
	@max_v10mapositiontaking_20 smallmoney,

	@max_v11mapositiontaking_1 smallmoney,
	@max_v11mapositiontaking_20 smallmoney,
	
	@max_v99mapositiontaking_1 smallmoney,
	@max_v99mapositiontaking_2 smallmoney,
	@max_v99mapositiontaking_3 smallmoney,
	@max_v99mapositiontaking_20 smallmoney,
	@max_v99mapositiontaking_9 smallmoney,
	@max_v99mapositiontaking_9999 smallmoney,
		
	@min_mapositiontaking_1 smallmoney,
	@min_mapositiontaking_2 smallmoney,
	@min_mapositiontaking_3 smallmoney,
	@min_mapositiontaking_4 smallmoney,
	@min_mapositiontaking_5 smallmoney,
	@min_mapositiontaking_6 smallmoney,
	@min_mapositiontaking_7 smallmoney,
	@min_mapositiontaking_8 smallmoney,
	@min_mapositiontaking_9 smallmoney,
	@min_mapositiontaking_10 smallmoney,
	@min_mapositiontaking_9999 smallmoney,
	
	@min_malivepositiontaking_1 smallmoney,
	@min_malivepositiontaking_3 smallmoney,
	@min_malivepositiontaking_7 smallmoney,
	@min_malivepositiontaking_8 smallmoney,
	
	@min_v2mapositiontaking_1 smallmoney,
	@min_v2mapositiontaking_2 smallmoney,
	@min_v2mapositiontaking_3 smallmoney,
	@min_v2mapositiontaking_7 smallmoney,
	@min_v2mapositiontaking_8 smallmoney,
--	@min_v2mapositiontaking_9 smallmoney,
	@min_v2mapositiontaking_20 smallmoney,
	@min_v2mapositiontaking_9999 smallmoney,
	
	@min_v3mapositiontaking_1 smallmoney,
	@min_v3mapositiontaking_2 smallmoney,
	@min_v3mapositiontaking_3 smallmoney,
	@min_v3mapositiontaking_20 smallmoney,

	@min_v5mapositiontaking_1 smallmoney,
	@min_v5mapositiontaking_2 smallmoney,
	@min_v5mapositiontaking_3 smallmoney,
	@min_v5mapositiontaking_20 smallmoney,
	@min_v5mapositiontaking_9999 smallmoney,

	@min_v8mapositiontaking_1 smallmoney,
	@min_v8mapositiontaking_3 smallmoney,
	@min_v8mapositiontaking_20 smallmoney,

	@min_v10mapositiontaking_1 smallmoney,
	@min_v10mapositiontaking_2 smallmoney,
	@min_v10mapositiontaking_3 smallmoney,
	@min_v10mapositiontaking_20 smallmoney,

	@min_v11mapositiontaking_1 smallmoney,
	@min_v11mapositiontaking_20 smallmoney,

	@min_v99mapositiontaking_1 smallmoney,
	@min_v99mapositiontaking_2 smallmoney,
	@min_v99mapositiontaking_3 smallmoney,
	@min_v99mapositiontaking_20 smallmoney,
	@min_v99mapositiontaking_9 smallmoney,
	@min_v99mapositiontaking_9999 smallmoney,	
	
	--Declare @apt_max = a4
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
--	@v2apositiontaking_9_max smallmoney,
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
	@v99apositiontaking_20_max smallmoney,
	@v99apositiontaking_9_max smallmoney,
	@v99apositiontaking_9999_max smallmoney,
	
	-- Outright PT params
	@max_v2mapositiontaking_10 smallmoney,
	@min_v2mapositiontaking_10 smallmoney,
	@v2apositiontaking_10_max smallmoney,

	@max_v3mapositiontaking_10 smallmoney,
	@min_v3mapositiontaking_10 smallmoney,
	@v3apositiontaking_10_max smallmoney,
	
	@max_v5mapositiontaking_10 smallmoney,
	@min_v5mapositiontaking_10 smallmoney,
	@v5apositiontaking_10_max smallmoney,
	
	@max_v8mapositiontaking_10 smallmoney,
	@min_v8mapositiontaking_10 smallmoney,
	@v8apositiontaking_10_max smallmoney,
	
	@max_v10mapositiontaking_10 smallmoney,
	@min_v10mapositiontaking_10 smallmoney,
	@v10apositiontaking_10_max smallmoney,
	
	@max_v11mapositiontaking_10 smallmoney,
	@min_v11mapositiontaking_10 smallmoney,
	@v11apositiontaking_10_max smallmoney,
	
	@max_v99mapositiontaking_10 smallmoney,
	@min_v99mapositiontaking_10 smallmoney,
	@v99apositiontaking_10_max smallmoney
	

--Get n3, l3
select @min_mapositiontaking_1 =minpositiontaking, @min_malivepositiontaking_1 =minlivepositiontaking, @max_mapositiontaking_1 =maxpositiontaking, @max_malivepositiontaking_1 =maxlivepositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @min_mapositiontaking_3 =minpositiontaking, @min_malivepositiontaking_3 =minlivepositiontaking, @max_mapositiontaking_3 =maxpositiontaking, @max_malivepositiontaking_3 =maxlivepositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @min_mapositiontaking_7 =minpositiontaking, @min_malivepositiontaking_7 =minlivepositiontaking, @max_mapositiontaking_7 =maxpositiontaking, @max_malivepositiontaking_7 =maxlivepositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @min_mapositiontaking_8 =minpositiontaking, @min_malivepositiontaking_8 =minlivepositiontaking, @max_mapositiontaking_8 =maxpositiontaking, @max_malivepositiontaking_8 =maxlivepositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
select @min_mapositiontaking_2 =minpositiontaking, @max_mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @min_mapositiontaking_4 =minpositiontaking, @max_mapositiontaking_4 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @min_mapositiontaking_5 =minpositiontaking, @max_mapositiontaking_5 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @min_mapositiontaking_6 =minpositiontaking, @max_mapositiontaking_6 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @min_mapositiontaking_9 =minpositiontaking, @max_mapositiontaking_9 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @min_mapositiontaking_10 =minpositiontaking, @max_mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

-- Outright PT

select @min_v2mapositiontaking_10 =minpositiontaking, @max_v2mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=2
select @min_v3mapositiontaking_10 =minpositiontaking, @max_v3mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=3
select @min_v5mapositiontaking_10 =minpositiontaking, @max_v5mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=5
select @min_v8mapositiontaking_10 =minpositiontaking, @max_v8mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=8
select @min_v10mapositiontaking_10 =minpositiontaking, @max_v10mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=10
select @min_v11mapositiontaking_10 =minpositiontaking, @max_v11mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=11
select @min_v99mapositiontaking_10 =minpositiontaking, @max_v99mapositiontaking_10 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=99


select @min_mapositiontaking_9999 =minpositiontaking, @max_mapositiontaking_9999 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=1

select @min_v2mapositiontaking_1 =minpositiontaking, @max_v2mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @min_v2mapositiontaking_2 =minpositiontaking, @max_v2mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @min_v2mapositiontaking_3 =minpositiontaking, @max_v2mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @min_v2mapositiontaking_7 =minpositiontaking, @max_v2mapositiontaking_7 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @min_v2mapositiontaking_8 =minpositiontaking, @max_v2mapositiontaking_8 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
--select @min_v2mapositiontaking_9 =minpositiontaking, @max_v2mapositiontaking_9 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @min_v2mapositiontaking_20 =minpositiontaking, @max_v2mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2
select @min_v2mapositiontaking_9999 =minpositiontaking, @max_v2mapositiontaking_9999 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=2

select @min_v3mapositiontaking_1 =minpositiontaking, @max_v3mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
select @min_v3mapositiontaking_2 =minpositiontaking, @max_v3mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
select @min_v3mapositiontaking_3 =minpositiontaking, @max_v3mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
select @min_v3mapositiontaking_20 =minpositiontaking, @max_v3mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3

select @min_v5mapositiontaking_1 =minpositiontaking, @max_v5mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
select @min_v5mapositiontaking_2 =minpositiontaking, @max_v5mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
select @min_v5mapositiontaking_3 =minpositiontaking, @max_v5mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
select @min_v5mapositiontaking_20 =minpositiontaking, @max_v5mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5
select @min_v5mapositiontaking_9999 =minpositiontaking, @max_v5mapositiontaking_9999 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=5

select @min_v8mapositiontaking_1 =minpositiontaking, @max_v8mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
select @min_v8mapositiontaking_3 =minpositiontaking, @max_v8mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
select @min_v8mapositiontaking_20 =minpositiontaking, @max_v8mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8

select @min_v10mapositiontaking_1 =minpositiontaking, @max_v10mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
select @min_v10mapositiontaking_2 =minpositiontaking, @max_v10mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
select @min_v10mapositiontaking_3 =minpositiontaking, @max_v10mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
select @min_v10mapositiontaking_20 =minpositiontaking, @max_v10mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10

select @min_v11mapositiontaking_1 =minpositiontaking, @max_v11mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
select @min_v11mapositiontaking_20 =minpositiontaking, @max_v11mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11

select @min_v99mapositiontaking_1 =minpositiontaking, @max_v99mapositiontaking_1 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
select @min_v99mapositiontaking_2 =minpositiontaking, @max_v99mapositiontaking_2 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
select @min_v99mapositiontaking_3 =minpositiontaking, @max_v99mapositiontaking_3 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
select @min_v99mapositiontaking_20 =minpositiontaking, @max_v99mapositiontaking_20 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99
select @min_v99mapositiontaking_9 =minpositiontaking, @max_v99mapositiontaking_9 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99
select @min_v99mapositiontaking_9999 =minpositiontaking, @max_v99mapositiontaking_9999 =maxpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=99

--get @max_ma = min(l3,m3)
Select	
	@max_mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	-- Outright PT
	@max_v2mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v3mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v5mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v8mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v10mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v11mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v99mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	
	@max_mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_malivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking < mco.maxlivepositiontaking then cs.mlivepositiontaking else mco.maxlivepositiontaking end else 0 end),
	@max_malivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking < mco.maxlivepositiontaking then cs.mlivepositiontaking else mco.maxlivepositiontaking end else 0 end),
	@max_malivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking < mco.maxlivepositiontaking then cs.mlivepositiontaking else mco.maxlivepositiontaking end else 0 end),
	@max_malivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking < mco.maxlivepositiontaking then cs.mlivepositiontaking else mco.maxlivepositiontaking end else 0 end),

	@max_v2mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
--	@max_v2mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v3mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v3mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v3mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v3mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v5mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v5mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v5mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v5mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v5mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v8mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v8mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v8mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v10mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v10mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v10mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v10mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v11mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v11mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	
	@max_v99mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=99 
											then case when cs.mpositiontaking < mco.maxpositiontaking 
														then cs.mpositiontaking 
														else mco.maxpositiontaking 
											end 
											else 0 
									end),
	@max_v99mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v99mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v99mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v99mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v99mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end)
from
	custsetting as cs with (nolock)
	inner join custoverride as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype	
where cs.custid = (select mrecommend from customer with (nolock) where custid = @CustID)

--get @max_ma = min(m4,m3,l3)
Select	
	@max_mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_1 then cs.mpositiontaking else @max_mapositiontaking_1 end else 0 end),
	@max_mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_2 then cs.mpositiontaking else @max_mapositiontaking_2 end else 0 end),
	@max_mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_3 then cs.mpositiontaking else @max_mapositiontaking_3 end else 0 end),
	@max_mapositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_4 then cs.mpositiontaking else @max_mapositiontaking_4 end else 0 end),
	@max_mapositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_5 then cs.mpositiontaking else @max_mapositiontaking_5 end else 0 end),
	@max_mapositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_6 then cs.mpositiontaking else @max_mapositiontaking_6 end else 0 end),
	@max_mapositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_7 then cs.mpositiontaking else @max_mapositiontaking_7 end else 0 end),
	@max_mapositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_8 then cs.mpositiontaking else @max_mapositiontaking_8 end else 0 end),
	@max_mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_9 then cs.mpositiontaking else @max_mapositiontaking_9 end else 0 end),
	@max_mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_10 then cs.mpositiontaking else @max_mapositiontaking_10 end else 0 end),
	
	-- OutrightPT
	@max_v2mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_10 then cs.mpositiontaking else @max_v2mapositiontaking_10 end else 0 end),
	@max_v3mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.mpositiontaking < @max_v3mapositiontaking_10 then cs.mpositiontaking else @max_v3mapositiontaking_10 end else 0 end),
	@max_v5mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_10 then cs.mpositiontaking else @max_v5mapositiontaking_10 end else 0 end),
	@max_v8mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.mpositiontaking < @max_v8mapositiontaking_10 then cs.mpositiontaking else @max_v8mapositiontaking_10 end else 0 end),
	@max_v10mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.mpositiontaking < @max_v10mapositiontaking_10 then cs.mpositiontaking else @max_v10mapositiontaking_10 end else 0 end),
	@max_v11mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.mpositiontaking < @max_v11mapositiontaking_10 then cs.mpositiontaking else @max_v11mapositiontaking_10 end else 0 end),
	@max_v99mapositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_10 then cs.mpositiontaking else @max_v99mapositiontaking_10 end else 0 end),
	
	
	@max_mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.mpositiontaking < @max_mapositiontaking_9999 then cs.mpositiontaking else @max_mapositiontaking_9999 end else 0 end),

	@max_malivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking < @max_malivepositiontaking_1 then cs.mlivepositiontaking else @max_malivepositiontaking_1 end else 0 end),
	@max_malivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking < @max_malivepositiontaking_3 then cs.mlivepositiontaking else @max_malivepositiontaking_3 end else 0 end),
	@max_malivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking < @max_malivepositiontaking_7 then cs.mlivepositiontaking else @max_malivepositiontaking_7 end else 0 end),
	@max_malivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking < @max_malivepositiontaking_8 then cs.mlivepositiontaking else @max_malivepositiontaking_8 end else 0 end),

	@max_v2mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_1 then cs.mpositiontaking else @max_v2mapositiontaking_1 end else 0 end),
	@max_v2mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_2 then cs.mpositiontaking else @max_v2mapositiontaking_2 end else 0 end),
	@max_v2mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_3 then cs.mpositiontaking else @max_v2mapositiontaking_3 end else 0 end),
	@max_v2mapositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_7 then cs.mpositiontaking else @max_v2mapositiontaking_7 end else 0 end),
	@max_v2mapositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_8 then cs.mpositiontaking else @max_v2mapositiontaking_8 end else 0 end),
--	@max_v2mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v2mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_20 then cs.mpositiontaking else @max_v2mapositiontaking_20 end else 0 end),
	@max_v2mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.mpositiontaking < @max_v2mapositiontaking_9999 then cs.mpositiontaking else @max_v2mapositiontaking_9999 end else 0 end),

	@max_v3mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking < @max_v3mapositiontaking_1 then cs.mpositiontaking else @max_v3mapositiontaking_1 end else 0 end),
	@max_v3mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking < @max_v3mapositiontaking_2 then cs.mpositiontaking else @max_v3mapositiontaking_2 end else 0 end),
	@max_v3mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking < @max_v3mapositiontaking_3 then cs.mpositiontaking else @max_v3mapositiontaking_3 end else 0 end),
	@max_v3mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking < @max_v3mapositiontaking_20 then cs.mpositiontaking else @max_v3mapositiontaking_20 end else 0 end),

	@max_v5mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_1 then cs.mpositiontaking else @max_v5mapositiontaking_1 end else 0 end),
	@max_v5mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_2 then cs.mpositiontaking else @max_v5mapositiontaking_2 end else 0 end),
	@max_v5mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_3 then cs.mpositiontaking else @max_v5mapositiontaking_3 end else 0 end),
	@max_v5mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_20 then cs.mpositiontaking else @max_v5mapositiontaking_20 end else 0 end),
	@max_v5mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.mpositiontaking < @max_v5mapositiontaking_9999 then cs.mpositiontaking else @max_v5mapositiontaking_9999 end else 0 end),

	@max_v8mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking < @max_v8mapositiontaking_1 then cs.mpositiontaking else @max_v8mapositiontaking_1 end else 0 end),
	@max_v8mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking < @max_v8mapositiontaking_3 then cs.mpositiontaking else @max_v8mapositiontaking_3 end else 0 end),
	@max_v8mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking < @max_v8mapositiontaking_20 then cs.mpositiontaking else @max_v8mapositiontaking_20 end else 0 end),

	@max_v10mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking < @max_v10mapositiontaking_1 then cs.mpositiontaking else @max_v10mapositiontaking_1 end else 0 end),
	@max_v10mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking < @max_v10mapositiontaking_2 then cs.mpositiontaking else @max_v10mapositiontaking_2 end else 0 end),
	@max_v10mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking < @max_v10mapositiontaking_3 then cs.mpositiontaking else @max_v10mapositiontaking_3 end else 0 end),
	@max_v10mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking < @max_v10mapositiontaking_20 then cs.mpositiontaking else @max_v10mapositiontaking_20 end else 0 end),

	@max_v11mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking < @max_v11mapositiontaking_1 then cs.mpositiontaking else @max_v11mapositiontaking_1 end else 0 end),
	@max_v11mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking < @max_v11mapositiontaking_20 then cs.mpositiontaking else @max_v11mapositiontaking_20 end else 0 end),
	
	@max_v99mapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=99 
											then case when cs.mpositiontaking < @max_v99mapositiontaking_1 
													  then cs.mpositiontaking 
													  else @max_v99mapositiontaking_1 
												 end 
										    else 0 
									 end),
	@max_v99mapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_2 then cs.mpositiontaking else @max_v99mapositiontaking_2 end else 0 end),
	@max_v99mapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_3 then cs.mpositiontaking else @max_v99mapositiontaking_3 end else 0 end),
	@max_v99mapositiontaking_20 = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_20 then cs.mpositiontaking else @max_v99mapositiontaking_20 end else 0 end),
	@max_v99mapositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_9 then cs.mpositiontaking else @max_v99mapositiontaking_9 end else 0 end),
	@max_v99mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_9999 then cs.mpositiontaking else @max_v99mapositiontaking_9999 end else 0 end)
from
	custsetting as cs with (nolock)	
where cs.custid = (select srecommend from customer with (nolock) where custid = @CustID)

Select
	--get @apt_max = a4
	@apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	
	-- Outright PT
	@v2apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v3apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end),
	@v5apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end),
	@v8apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end),
	@v10apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end),
	@v11apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end),
	@v99apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	
	@apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end),

	@alivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),

	@v2apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end),
--	@v2apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@v2apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end),

	@v3apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end),
	@v3apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end),
	@v3apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end),
	@v3apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end),

	@v5apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end),
	@v5apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end),
	@v5apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end),
	@v5apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end),
	@v5apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end),

	@v8apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end),
	@v8apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end),
	@v8apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end),

	@v10apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end),
	@v10apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end),
	@v10apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end),
	@v10apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end),

	@v11apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end),
	@v11apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end),

	@v99apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	@v99apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	@v99apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	@v99apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	@v99apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end),
	@v99apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end)

from custsetting as cs with (nolock)
where cs.custid = (select srecommend from customer with (nolock) where custid = @CustID)

select 
	cps.closed, 
	cps.reject as suspended, 
	CASE WHEN (sp.SuperStatus + sp.MasterStatus)  > 0 THEN 1 ELSE 0 END as Msuspended, 	 
	isnull(c.firstname,'') as firstname, 
	isnull(c.lastname,'') as lastname, 
	c.roleid, c.username,
	exchange.minbet AS defaultminbet, 
	isnull(c.phone,'') as phone, 
	isnull(c.mobilephone,'') as mobilephone, 
	isnull(c.email,'') as email,
	isnull(c.fax,'') as fax,
	ci.credit,
	@Mem_MaxCredit as Mem_MaxCredit,
	@Credit_Ag_Min as Credit_Min,
	@Credit_Ag_Max as Credit_Max,
	@MaxCredit_Mem_Min as MaxCredit_Min,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	
	--------------
	

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,
	
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2, --1x2

	-- For MyanmarOdds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@MyanmarOdds,0) AS discountMyanmarOdds,
	ISNULL(@discountMyanmarOdds_max,0) AS discountMyanmarOdds_max,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end) as apositiontaking_9999,

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

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end) as mlivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_20,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9999,

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

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9999,
		
	--Auto Master PT
	--u2
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_20,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_9,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_9999,

	--i2
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_20,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_9,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_9999,
	
	--max u2
	--@max_mapositiontaking_1
	--@max_v3mapositiontaking_20
	@max_mapositiontaking_1 as auto_mpositiontaking_1_max,
	@max_mapositiontaking_2 as auto_mpositiontaking_2_max,
	@max_mapositiontaking_3 as auto_mpositiontaking_3_max,
	@max_mapositiontaking_4 as auto_mpositiontaking_4_max,
	@max_mapositiontaking_5 as auto_mpositiontaking_5_max,
	@max_mapositiontaking_6 as auto_mpositiontaking_6_max,
	@max_mapositiontaking_7 as auto_mpositiontaking_7_max,
	@max_mapositiontaking_8 as auto_mpositiontaking_8_max,
	@max_mapositiontaking_9 as auto_mpositiontaking_9_max,
	@max_mapositiontaking_10 as auto_mpositiontaking_10_max,
	@max_mapositiontaking_9999 as auto_mpositiontaking_9999_max,
	
	@max_malivepositiontaking_1 as auto_mlivepositiontaking_1_max,
	@max_malivepositiontaking_3 as auto_mlivepositiontaking_3_max,
	@max_malivepositiontaking_7 as auto_mlivepositiontaking_7_max,
	@max_malivepositiontaking_8 as auto_mlivepositiontaking_8_max,
	
	@max_v2mapositiontaking_1 as auto_v2mpositiontaking_1_max,
	@max_v2mapositiontaking_2 as auto_v2mpositiontaking_2_max,
	@max_v2mapositiontaking_3 as auto_v2mpositiontaking_3_max,
	@max_v2mapositiontaking_7 as auto_v2mpositiontaking_7_max,
	@max_v2mapositiontaking_8 as auto_v2mpositiontaking_8_max,	
--	@max_v2mapositiontaking_9 as auto_v2mpositiontaking_9_max,
	@max_v2mapositiontaking_20 as auto_v2mpositiontaking_20_max,
	@max_v2mapositiontaking_9999 as auto_v2mpositiontaking_9999_max,
	
	@max_v3mapositiontaking_1 as auto_v3mpositiontaking_1_max,
	@max_v3mapositiontaking_2 as auto_v3mpositiontaking_2_max,
	@max_v3mapositiontaking_3 as auto_v3mpositiontaking_3_max,
	@max_v3mapositiontaking_20 as auto_v3mpositiontaking_20_max,
	
	@max_v5mapositiontaking_1 as auto_v5mpositiontaking_1_max,
	@max_v5mapositiontaking_2 as auto_v5mpositiontaking_2_max,
	@max_v5mapositiontaking_3 as auto_v5mpositiontaking_3_max,
	@max_v5mapositiontaking_20 as auto_v5mpositiontaking_20_max,
	@max_v5mapositiontaking_9999 as auto_v5mpositiontaking_9999_max,
	
	@max_v8mapositiontaking_1 as auto_v8mpositiontaking_1_max,
	@max_v8mapositiontaking_3 as auto_v8mpositiontaking_3_max,
	@max_v8mapositiontaking_20 as auto_v8mpositiontaking_20_max,
	
	@max_v10mapositiontaking_1 as auto_v10mpositiontaking_1_max,
	@max_v10mapositiontaking_2 as auto_v10mpositiontaking_2_max,
	@max_v10mapositiontaking_3 as auto_v10mpositiontaking_3_max,
	@max_v10mapositiontaking_20 as auto_v10mpositiontaking_20_max,
	
	@max_v11mapositiontaking_1 as auto_v11mpositiontaking_1_max,
	@max_v11mapositiontaking_20 as auto_v11mpositiontaking_20_max,
	
	@max_v99mapositiontaking_1 as auto_v99mpositiontaking_1_max,
	@max_v99mapositiontaking_2 as auto_v99mpositiontaking_2_max,
	@max_v99mapositiontaking_3 as auto_v99mpositiontaking_3_max,
	@max_v99mapositiontaking_20 as auto_v99mpositiontaking_20_max,
	@max_v99mapositiontaking_9 as auto_v99mpositiontaking_9_max,
	@max_v99mapositiontaking_9999 as auto_v99mpositiontaking_9999_max,

	@ga as groupa_max,
	@gb as groupb_max,
	@gc as groupc_max,
	@gd as groupd_max,
	@dis as discountcs_max,
	@dis1x2 as discount1x2_max,

	--max (m2+a2)
	@max_mapositiontaking_1 as max_mapositiontaking_1,
	@max_mapositiontaking_2 as max_mapositiontaking_2,
	@max_mapositiontaking_3 as max_mapositiontaking_3,
	@max_mapositiontaking_4 as max_mapositiontaking_4,
	@max_mapositiontaking_5 as max_mapositiontaking_5,
	@max_mapositiontaking_6 as max_mapositiontaking_6,
	@max_mapositiontaking_7 as max_mapositiontaking_7,
	@max_mapositiontaking_8 as max_mapositiontaking_8,
	@max_mapositiontaking_9 as max_mapositiontaking_9,
	@max_mapositiontaking_10 as max_mapositiontaking_10,
	@max_mapositiontaking_9999 as max_mapositiontaking_9999,
	
	@max_malivepositiontaking_1 as max_malivepositiontaking_1,
	@max_malivepositiontaking_3 as max_malivepositiontaking_3,
	@max_malivepositiontaking_7 as max_malivepositiontaking_7,
	@max_malivepositiontaking_8 as max_malivepositiontaking_8,
	
	@max_v2mapositiontaking_1 as max_v2mapositiontaking_1,
	@max_v2mapositiontaking_2 as max_v2mapositiontaking_2,
	@max_v2mapositiontaking_3 as max_v2mapositiontaking_3,
	@max_v2mapositiontaking_7 as max_v2mapositiontaking_7,
	@max_v2mapositiontaking_8 as max_v2mapositiontaking_8,
--	@max_v2mapositiontaking_9 as max_v2mapositiontaking_9,
	@max_v2mapositiontaking_20 as max_v2mapositiontaking_20,
	@max_v2mapositiontaking_9999 as max_v2mapositiontaking_9999,

	@max_v3mapositiontaking_1 as max_v3mapositiontaking_1,
	@max_v3mapositiontaking_2 as max_v3mapositiontaking_2,
	@max_v3mapositiontaking_3 as max_v3mapositiontaking_3,
	@max_v3mapositiontaking_20 as max_v3mapositiontaking_20,

	@max_v5mapositiontaking_1 as max_v5mapositiontaking_1,
	@max_v5mapositiontaking_2 as max_v5mapositiontaking_2,
	@max_v5mapositiontaking_3 as max_v5mapositiontaking_3,
	@max_v5mapositiontaking_20 as max_v5mapositiontaking_20,
	@max_v5mapositiontaking_9999 as max_v5mapositiontaking_9999,

	@max_v8mapositiontaking_1 as max_v8mapositiontaking_1,
	@max_v8mapositiontaking_3 as max_v8mapositiontaking_3,
	@max_v8mapositiontaking_20 as max_v8mapositiontaking_20,

	@max_v10mapositiontaking_1 as max_v10mapositiontaking_1,
	@max_v10mapositiontaking_2 as max_v10mapositiontaking_2,
	@max_v10mapositiontaking_3 as max_v10mapositiontaking_3,
	@max_v10mapositiontaking_20 as max_v10mapositiontaking_20,

	@max_v11mapositiontaking_1 as max_v11mapositiontaking_1,
	@max_v11mapositiontaking_20 as max_v11mapositiontaking_20,

	@max_v99mapositiontaking_1 as max_v99mapositiontaking_1,
	@max_v99mapositiontaking_2 as max_v99mapositiontaking_2,
	@max_v99mapositiontaking_3 as max_v99mapositiontaking_3,
	@max_v99mapositiontaking_20 as max_v99mapositiontaking_20,
	@max_v99mapositiontaking_9 as max_v99mapositiontaking_9,
	@max_v99mapositiontaking_9999 as max_v99mapositiontaking_9999,
		
	@min_mapositiontaking_1 as min_mapositiontaking_1,
	@min_mapositiontaking_2 as min_mapositiontaking_2,
	@min_mapositiontaking_3 as min_mapositiontaking_3,
	@min_mapositiontaking_4 as min_mapositiontaking_4,
	@min_mapositiontaking_5 as min_mapositiontaking_5,
	@min_mapositiontaking_6 as min_mapositiontaking_6,
	@min_mapositiontaking_7 as min_mapositiontaking_7,
	@min_mapositiontaking_8 as min_mapositiontaking_8,
	@min_mapositiontaking_9 as min_mapositiontaking_9,
	@min_mapositiontaking_10 as min_mapositiontaking_10,
	@min_mapositiontaking_9999 as min_mapositiontaking_9999,
	
	@min_malivepositiontaking_1 as min_malivepositiontaking_1,
	@min_malivepositiontaking_3 as min_malivepositiontaking_3,
	@min_malivepositiontaking_7 as min_malivepositiontaking_7,
	@min_malivepositiontaking_8 as min_malivepositiontaking_8,
	
	@min_v2mapositiontaking_1 as min_v2mapositiontaking_1,
	@min_v2mapositiontaking_2 as min_v2mapositiontaking_2,
	@min_v2mapositiontaking_3 as min_v2mapositiontaking_3,
	@min_v2mapositiontaking_7 as min_v2mapositiontaking_7,
	@min_v2mapositiontaking_8 as min_v2mapositiontaking_8,
--	@min_v2mapositiontaking_9 as min_v2mapositiontaking_9,
	@min_v2mapositiontaking_20 as min_v2mapositiontaking_20,
	@min_v2mapositiontaking_9999 as min_v2mapositiontaking_9999,

	@min_v3mapositiontaking_1 as min_v3mapositiontaking_1,
	@min_v3mapositiontaking_2 as min_v3mapositiontaking_2,
	@min_v3mapositiontaking_3 as min_v3mapositiontaking_3,
	@min_v3mapositiontaking_20 as min_v3mapositiontaking_20,

	@min_v5mapositiontaking_1 as min_v5mapositiontaking_1,
	@min_v5mapositiontaking_2 as min_v5mapositiontaking_2,
	@min_v5mapositiontaking_3 as min_v5mapositiontaking_3,
	@min_v5mapositiontaking_20 as min_v5mapositiontaking_20,
	@min_v5mapositiontaking_9999 as min_v5mapositiontaking_9999,

	@min_v8mapositiontaking_1 as min_v8mapositiontaking_1,
	@min_v8mapositiontaking_3 as min_v8mapositiontaking_3,
	@min_v8mapositiontaking_20 as min_v8mapositiontaking_20,

	@min_v10mapositiontaking_1 as min_v10mapositiontaking_1,
	@min_v10mapositiontaking_2 as min_v10mapositiontaking_2,
	@min_v10mapositiontaking_3 as min_v10mapositiontaking_3,
	@min_v10mapositiontaking_20 as min_v10mapositiontaking_20,

	@min_v11mapositiontaking_1 as min_v11mapositiontaking_1,
	@min_v11mapositiontaking_20 as min_v11mapositiontaking_20,

	@min_v99mapositiontaking_1 as min_v99mapositiontaking_1,
	@min_v99mapositiontaking_2 as min_v99mapositiontaking_2,
	@min_v99mapositiontaking_3 as min_v99mapositiontaking_3,
	@min_v99mapositiontaking_20 as min_v99mapositiontaking_20,
	@min_v99mapositiontaking_9 as min_v99mapositiontaking_9,
	@min_v99mapositiontaking_9999 as min_v99mapositiontaking_9999,
		
	--get n2 to check a2 > n2 on the web
	max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_3_min,
	max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_4_min,
	max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_5_min,
	max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_6_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_8_min,
	max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_9_min, 
	max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_10_min, 
	
	max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_9999_min, 

	max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_8_min,

	max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_8_min,
--	max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_9_min,
	max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_20_min,
	max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_9999_min,

	max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_20_min,
	max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_9999_min,

	max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_1_min,
	max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_20_min,

	max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_20_min,
	max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_9_min,
	max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_9999_min,

	--get apt_max = min(a4, l2) to check a2 < min(a4, l2) on the web
	max(case when co.bettype = 1 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_1_max then co.maxpositiontaking else @apositiontaking_1_max end else 0 end) as apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_2_max then co.maxpositiontaking else @apositiontaking_2_max end else 0 end) as apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_3_max then co.maxpositiontaking else @apositiontaking_3_max end else 0 end) as apositiontaking_3_max,
	max(case when co.bettype = 4 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_4_max then co.maxpositiontaking else @apositiontaking_4_max end else 0 end) as apositiontaking_4_max,
	max(case when co.bettype = 5 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_5_max then co.maxpositiontaking else @apositiontaking_5_max end else 0 end) as apositiontaking_5_max,
	max(case when co.bettype = 6 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_6_max then co.maxpositiontaking else @apositiontaking_6_max end else 0 end) as apositiontaking_6_max,
	max(case when co.bettype = 7 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_7_max then co.maxpositiontaking else @apositiontaking_7_max end else 0 end) as apositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_8_max then co.maxpositiontaking else @apositiontaking_8_max end else 0 end) as apositiontaking_8_max,
	max(case when co.bettype = 9 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_9_max then co.maxpositiontaking else @apositiontaking_9_max end else 0 end) as apositiontaking_9_max, 
	max(case when co.bettype = 10 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_10_max then co.maxpositiontaking else @apositiontaking_10_max end else 0 end) as apositiontaking_10_max, 
	max(case when co.bettype = 9999 and co.sporttype=1 then case when co.maxpositiontaking<@apositiontaking_9999_max then co.maxpositiontaking else @apositiontaking_9999_max end else 0 end) as apositiontaking_9999_max, 

	max(case when co.bettype = 1 and co.sporttype=1 then case when co.maxlivepositiontaking<@alivepositiontaking_1_max then co.maxlivepositiontaking else @alivepositiontaking_1_max end else 0 end) as alivepositiontaking_1_max,
	max(case when co.bettype = 3 and co.sporttype=1 then case when co.maxlivepositiontaking<@alivepositiontaking_3_max then co.maxlivepositiontaking else @alivepositiontaking_3_max end else 0 end) as alivepositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=1 then case when co.maxlivepositiontaking<@alivepositiontaking_7_max then co.maxlivepositiontaking else @alivepositiontaking_7_max end else 0 end) as alivepositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=1 then case when co.maxlivepositiontaking<@alivepositiontaking_8_max then co.maxlivepositiontaking else @alivepositiontaking_8_max end else 0 end) as alivepositiontaking_8_max,

	max(case when co.bettype = 1 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_1_max then co.maxpositiontaking else @v2apositiontaking_1_max end else 0 end) as v2apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_2_max then co.maxpositiontaking else @v2apositiontaking_2_max end else 0 end) as v2apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_3_max then co.maxpositiontaking else @v2apositiontaking_3_max end else 0 end) as v2apositiontaking_3_max,
	max(case when co.bettype = 7 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_7_max then co.maxpositiontaking else @v2apositiontaking_7_max end else 0 end) as v2apositiontaking_7_max,
	max(case when co.bettype = 8 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_8_max then co.maxpositiontaking else @v2apositiontaking_8_max end else 0 end) as v2apositiontaking_8_max,
--	max(case when co.bettype = 9 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_9_max then co.maxpositiontaking else @v2apositiontaking_9_max end else 0 end) as v2apositiontaking_9_max,
	max(case when co.bettype = 20 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_20_max then co.maxpositiontaking else @v2apositiontaking_20_max end else 0 end) as v2apositiontaking_20_max,
	max(case when co.bettype = 9999 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_9999_max then co.maxpositiontaking else @v2apositiontaking_9999_max end else 0 end) as v2apositiontaking_9999_max,

	max(case when co.bettype = 1 and co.sporttype=3 then case when co.maxpositiontaking<@v3apositiontaking_1_max then co.maxpositiontaking else @v3apositiontaking_1_max end else 0 end) as v3apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=3 then case when co.maxpositiontaking<@v3apositiontaking_2_max then co.maxpositiontaking else @v3apositiontaking_2_max end else 0 end) as v3apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=3 then case when co.maxpositiontaking<@v3apositiontaking_3_max then co.maxpositiontaking else @v3apositiontaking_3_max end else 0 end) as v3apositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=3 then case when co.maxpositiontaking<@v3apositiontaking_20_max then co.maxpositiontaking else @v3apositiontaking_20_max end else 0 end) as v3apositiontaking_20_max,

	max(case when co.bettype = 1 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_1_max then co.maxpositiontaking else @v5apositiontaking_1_max end else 0 end) as v5apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_2_max then co.maxpositiontaking else @v5apositiontaking_2_max end else 0 end) as v5apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_3_max then co.maxpositiontaking else @v5apositiontaking_3_max end else 0 end) as v5apositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_20_max then co.maxpositiontaking else @v5apositiontaking_20_max end else 0 end) as v5apositiontaking_20_max,

	max(case when co.bettype = 9999 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_9999_max then co.maxpositiontaking else @v5apositiontaking_9999_max end else 0 end) as v5apositiontaking_9999_max,

	max(case when co.bettype = 1 and co.sporttype=8 then case when co.maxpositiontaking<@v8apositiontaking_1_max then co.maxpositiontaking else @v8apositiontaking_1_max end else 0 end) as v8apositiontaking_1_max,
	max(case when co.bettype = 3 and co.sporttype=8 then case when co.maxpositiontaking<@v8apositiontaking_3_max then co.maxpositiontaking else @v8apositiontaking_3_max end else 0 end) as v8apositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=8 then case when co.maxpositiontaking<@v8apositiontaking_20_max then co.maxpositiontaking else @v8apositiontaking_20_max end else 0 end) as v8apositiontaking_20_max,

	max(case when co.bettype = 1 and co.sporttype=10 then case when co.maxpositiontaking<@v10apositiontaking_1_max then co.maxpositiontaking else @v10apositiontaking_1_max end else 0 end) as v10apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=10 then case when co.maxpositiontaking<@v10apositiontaking_2_max then co.maxpositiontaking else @v10apositiontaking_2_max end else 0 end) as v10apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=10 then case when co.maxpositiontaking<@v10apositiontaking_3_max then co.maxpositiontaking else @v10apositiontaking_3_max end else 0 end) as v10apositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=10 then case when co.maxpositiontaking<@v10apositiontaking_20_max then co.maxpositiontaking else @v10apositiontaking_20_max end else 0 end) as v10apositiontaking_20_max,

	max(case when co.bettype = 1 and co.sporttype=11 then case when co.maxpositiontaking<@v11apositiontaking_1_max then co.maxpositiontaking else @v11apositiontaking_1_max end else 0 end) as v11apositiontaking_1_max,
	max(case when co.bettype = 20 and co.sporttype=11 then case when co.maxpositiontaking<@v11apositiontaking_20_max then co.maxpositiontaking else @v11apositiontaking_20_max end else 0 end) as v11apositiontaking_20_max,

	max(case when co.bettype = 1 and co.sporttype=99 
				then case when co.maxpositiontaking<@v99apositiontaking_1_max 
							then co.maxpositiontaking 
							else @v99apositiontaking_1_max 
					end 
				else 0 
		end) as v99apositiontaking_1_max,
	max(case when co.bettype = 2 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_2_max then co.maxpositiontaking else @v99apositiontaking_2_max end else 0 end) as v99apositiontaking_2_max,
	max(case when co.bettype = 3 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_3_max then co.maxpositiontaking else @v99apositiontaking_3_max end else 0 end) as v99apositiontaking_3_max,
	max(case when co.bettype = 20 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_20_max then co.maxpositiontaking else @v99apositiontaking_20_max end else 0 end) as v99apositiontaking_20_max,
	max(case when co.bettype = 9 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_9_max then co.maxpositiontaking else @v99apositiontaking_9_max end else 0 end) as v99apositiontaking_9_max,
	max(case when co.bettype = 9999 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_9999_max then co.maxpositiontaking else @v99apositiontaking_9999_max end else 0 end) as v99apositiontaking_9999_max,

    -- Outright PT
	-- PT for Master

	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_10,
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_10,
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_10,
	
	@max_v2mapositiontaking_10 as auto_v2mpositiontaking_10_max,
	@max_v3mapositiontaking_10 as auto_v3mpositiontaking_10_max,
	@max_v5mapositiontaking_10 as auto_v5mpositiontaking_10_max,
	@max_v8mapositiontaking_10 as auto_v8mpositiontaking_10_max,
	@max_v10mapositiontaking_10 as auto_v10mpositiontaking_10_max,
	@max_v11mapositiontaking_10 as auto_v11mpositiontaking_10_max,
	@max_v99mapositiontaking_10 as auto_v99mpositiontaking_10_max,
	
	@max_v2mapositiontaking_10 as max_v2mapositiontaking_10,
	@max_v3mapositiontaking_10 as max_v3mapositiontaking_10,
	@max_v5mapositiontaking_10 as max_v5mapositiontaking_10,
	@max_v8mapositiontaking_10 as max_v8mapositiontaking_10,
	@max_v10mapositiontaking_10 as max_v10mapositiontaking_10,
	@max_v11mapositiontaking_10 as max_v11mapositiontaking_10,
	@max_v99mapositiontaking_10 as max_v99mapositiontaking_10,
	
	@min_v2mapositiontaking_10 as min_v2mapositiontaking_10,
	@min_v3mapositiontaking_10 as min_v3mapositiontaking_10,
	@min_v5mapositiontaking_10 as min_v5mapositiontaking_10,
	@min_v8mapositiontaking_10 as min_v8mapositiontaking_10,
	@min_v10mapositiontaking_10 as min_v10mapositiontaking_10,
	@min_v11mapositiontaking_10 as min_v11mapositiontaking_10,
	@min_v99mapositiontaking_10 as min_v99mapositiontaking_10,
	
	-- PT for Agent
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_10,
	
	max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_10_min, 
	
	max(case when co.bettype = 10 and co.sporttype=2 then case when co.maxpositiontaking<@v2apositiontaking_10_max then co.maxpositiontaking else @v2apositiontaking_10_max end else 0 end) as v2apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=3 then case when co.maxpositiontaking<@v3apositiontaking_10_max then co.maxpositiontaking else @v3apositiontaking_10_max end else 0 end) as v3apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=5 then case when co.maxpositiontaking<@v5apositiontaking_10_max then co.maxpositiontaking else @v5apositiontaking_10_max end else 0 end) as v5apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=8 then case when co.maxpositiontaking<@v8apositiontaking_10_max then co.maxpositiontaking else @v8apositiontaking_10_max end else 0 end) as v8apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=10 then case when co.maxpositiontaking<@v10apositiontaking_10_max then co.maxpositiontaking else @v10apositiontaking_10_max end else 0 end) as v10apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=11 then case when co.maxpositiontaking<@v11apositiontaking_10_max then co.maxpositiontaking else @v11apositiontaking_10_max end else 0 end) as v11apositiontaking_10_max, 
	max(case when co.bettype = 10 and co.sporttype=99 then case when co.maxpositiontaking<@v99apositiontaking_10_max then co.maxpositiontaking else @v99apositiontaking_10_max end else 0 end) as v99apositiontaking_10_max,
	max(c.site) AS Site,
	max(s.SiteLabel) as SiteLabel,
	---------------------------------------------------------------------------------------------------------------

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
	customer as c with (nolock) 
	INNER JOIN Site s WITH (NOLOCK) ON  s.site=c.site
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, SuspendInfo
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
	CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp
	INNER JOIN exchange with (NOLOCK) ON c.currency = exchange.exchangeid
where 
	c.roleid=2 and c.custid=@CustID and
	c.mrecommend=@MRecommend
group by 
	cps.closed, cps.reject, c.firstname, c.lastname, c.roleid, c.username,
	sp.SuperStatus, sp.MasterStatus,
	exchange.minbet, c.phone, c.mobilephone, c.email,c.fax,
	ci.credit
END
GO
