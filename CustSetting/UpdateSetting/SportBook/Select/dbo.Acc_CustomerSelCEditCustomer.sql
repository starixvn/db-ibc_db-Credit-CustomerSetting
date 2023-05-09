/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelCEditCustomer]     
	@CustId int
AS

/*
Created: 
Task : COMPANY EDIT SUPER
DB: DBCUST/CustDB

Revisions:
    - 20090317@Phuc: disable FI, HR 	
    - 20090408@Lee: add 2 return fields for casino
    - 20090515@PhuongDao: Add 1x2 Commission 
    - 20090901@Shifu: Add IsInternal status
    - 20091215@Kiwi: Remove HR (151) and Financials (201).
    - 20100903@Henry: Add Number Game + Mix Parlay Mixed Sports
	- 20101026@Lukas: add max per ball(number game)
	- 20110121@Jamie: Enhance performance : separate custsetting and customer
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20131014@Kathy: - Add HR Fixed Odds (154) [Redmine:#6505]		
	- 20131028@Elodie: Add new super from existing super(Get currency, site, SyncLiveCasino) [Redmine:#5456] 				
	- 20140612@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170105@Elodie: Get DisableLiveCasio field - [Redmine:68879] 
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170420@Helen:  Add Extra information for Direct Accounts, for NAP only - [Redmine:72339]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181105@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20230310@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
 - @CustID: super ID
*/
BEGIN
SET NOCOUNT ON

declare @maxpermatch_min money, 
	@maxpermatchv2_min money,
	@maxpermatchv3_min money,
	@maxpermatchv5_min money,
	@maxpermatchv8_min money,
	@maxpermatchv10_min money,
	@maxpermatchv11_min money,	
	@maxpermatchv99_min money,	
	@maxpermatchv99MP_min money,	
	@maxpermatchv1MP_min money,		
	@Credit_SAg_Min money

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
		@maxPayoutpermatchv2saba	MONEY = 0
	
select @Credit_SAg_Min = max(c.credit)
from
	(
	Select isnull(sum(credit), 0) as credit from custinfo with (NOLOCK) where srecommend = @CustID and RoleID=3
	union all
	Select isnull(sum(credit), 0) as credit from custinfo with (NOLOCK) where srecommend = @CustID and RoleID=1
	union all
	Select isnull(sum(credit), 0) as credit from custinfo with (NOLOCK) where srecommend = @CustID and RoleID=2
	) c

DECLARE	@firstname	nvarchar(50),
		@lastname	nvarchar(50),
		@phone		nvarchar(50),
		@mobilephone	nvarchar(50),
		@email		nvarchar(50),
		@fax		nvarchar(50),
		@ExchangeMinbet	float,
		@isInternal	bit,
		@CurrencyID INT,
		@Currency nvarchar(50),
		@Site varchar(10),
		@SiteLabel varchar(50),
		@srecommend INT

SELECT	@isInternal = ISNULL(isInternal,0) FROM CustSuper WITH (NOLOCK) WHERE custID = @custID 

SELECT	@firstname	= c.firstname,
		@lastname	= c.lastname,
		@phone		= c.phone,
		@mobilephone	= c.mobilephone,
		@email		= c.email,
		@fax		= c.fax,
		@ExchangeMinbet = e.minbet,
		@CurrencyID = e.exchangeid,		
		@Currency = e.currency,		
		@Site = c.site,
		@SiteLabel = s.SiteLabel,
		@srecommend = c.srecommend
FROM	Customer c WITH (NOLOCK)
		INNER JOIN Exchange e WITH (NOLOCK) ON c.currency = e.exchangeID 
		INNER JOIN Site s WITH (NOLOCK) ON s.site = c.site
WHERE	c.custID = @CustID 

--to facilitate in Web Interface
Select 	
	@MaxPerMatch_Min = 0,
	@MaxPerMatchv2_Min = 0,
	@MaxPerMatchv3_Min = 0,
	@MaxPerMatchv5_Min = 0,
	@MaxPerMatchv8_Min = 0,
	@MaxPerMatchv10_Min = 0,
	@MaxPerMatchv11_Min = 0,	
	@MaxPerMatchv99_Min = 0,
	@maxpermatchv99MP_min =0,	
	@maxpermatchv1MP_min =0	

-- Myanmar Odds
DECLARE @MyanmarOdds DECIMAL (9,8) = 0, @IsMyanmarOdds BIT = 0
SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
	SET @MyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)

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
	
select 
	cps.closed, 
	cps.reject as suspended,  
	@firstname as firstname, @lastname lastname, 
	4 as roleid, 
	ci.username,
	isnull(@ExchangeMinbet,0) AS defaultminbet, isnull(@phone,'') as phone, 
	isnull(@mobilephone,'') as mobilephone, isnull(@email,'') as email, isnull(@fax,'') as fax,
	@Currency as currencyName, @CurrencyID as currencyID,
	@Site as site,
	@SiteLabel as SiteLabel,
	ci.credit,
	@Credit_SAg_Min as Credit_Min,
	
	@isInternal as isinternal,	--v151

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
	
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,  --1x2	
	
	dbo.[f_Max](0.0025, max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end))  as groupa_max,
	dbo.[f_Max](0.005, max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end)) as groupb_max,
	dbo.[f_Max](0.0075,max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end)) as groupc_max,
	dbo.[f_Max](0.01, max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end)) as groupd_max,
	dbo.[f_Max](0.01, max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end)) as discountcs_max,
	--1x2 
	0.0025 as discount1x2_max,

	-- For MyanmarOdds
	ISNULL(@MyanmarOdds,0) AS discountMyanmarOdds,
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	0.01 AS discountMyanmarOdds_max,
	---------------------------------------------------------------------
	-- get n4
	max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_3_min,
	max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_4_min,
	max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_5_min,
	max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_6_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_8_min,
	max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_9_min, 
	max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_10_min, 
	max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end) as spositiontaking_9999_min, 

	max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as slivepositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as slivepositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as slivepositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end) as slivepositiontaking_8_min,

	--v2
	max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_3_min,
	max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_7_min,
	max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_8_min,
	max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_9_min,	
	
	max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_20_min,	
	max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_9999_min,	

	--v3
	max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3spositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3spositiontaking_20_min,	

	--v5
	max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_20_min,	
	max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_9999_min,

	--v8
	max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8spositiontaking_1_min,
	max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8spositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8spositiontaking_20_min,	

	--v10
	max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10spositiontaking_3_min,
	max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10spositiontaking_20_min,	

	--v11
	max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11spositiontaking_1_min,
	max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11spositiontaking_20_min,	

	--v99
	max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_1_min,
	max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_2_min,
	max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_3_min,
	max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_9_min,	
	max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_20_min,	
	max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_9999_min,	
	
	--l4 = s4, so hard code to make s4_max = 0.9
	0.9 as spositiontaking_1_max,
	0.9 as spositiontaking_2_max,
	0.9 as spositiontaking_3_max,
	0.9 as spositiontaking_4_max,
	0.9 as spositiontaking_5_max,
	0.9 as spositiontaking_6_max,
	0.9 as spositiontaking_7_max,
	0.9 as spositiontaking_8_max,
	0.9 as spositiontaking_9_max, 
	0.9 as spositiontaking_10_max, 
	0.9 as spositiontaking_9999_max,

	0.9 as slivepositiontaking_1_max,
	0.9 as slivepositiontaking_3_max,
	0.9 as slivepositiontaking_7_max,
	0.9 as slivepositiontaking_8_max,

	--v2	
	0.9 as v2spositiontaking_1_max,
	0.9 as v2spositiontaking_2_max,
	0.9 as v2spositiontaking_3_max,
	0.9 as v2spositiontaking_7_max,
	0.9 as v2spositiontaking_8_max,	
	
	0.9 as v2spositiontaking_20_max,
	0.9 as v2spositiontaking_9999_max,

	--v3
	0.9 as v3spositiontaking_1_max,
	0.9 as v3spositiontaking_2_max,
	0.9 as v3spositiontaking_3_max,
	0.9 as v3spositiontaking_20_max,	

	--v5
	0.9 as v5spositiontaking_1_max,
	0.9 as v5spositiontaking_2_max,
	0.9 as v5spositiontaking_3_max,
	0.9 as v5spositiontaking_20_max,	
	0.9 as v5spositiontaking_9999_max,

	--v8
	0.9 as v8spositiontaking_1_max,
	0.9 as v8spositiontaking_3_max,
	0.9 as v8spositiontaking_20_max,	

	--v10
	0.9 as v10spositiontaking_1_max,
	0.9 as v10spositiontaking_2_max,
	0.9 as v10spositiontaking_3_max,
	0.9 as v10spositiontaking_20_max,	

	--v11
	0.9 as v11spositiontaking_1_max,
	0.9 as v11spositiontaking_20_max,	

	--v99
	0.9 as v99spositiontaking_1_max,
	0.9 as v99spositiontaking_2_max,
	0.9 as v99spositiontaking_3_max,
	0.9 as v99spositiontaking_9_max,
	0.9 as v99spositiontaking_20_max,
	0.9 as v99spositiontaking_9999_max,			
	---------------------------------------------------------------------

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

	--v2
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9,

	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9999,

	--v3
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_20,

	--v5
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_9999,

	--v8
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_20,

	--v10
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_20,

	--v11
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_20,
	
	--v99
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9999,		
-----------------------------------------------------------------------------------------------------------------------

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

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as alivepositiontaking_8,

	--v2
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_8,
	
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_9999,

	--v3
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_20,

	--v5
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_9999,

	--v8
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_20,

	--v10
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_20,

	--v11
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_20,

	--v99
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_20,	
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9999,		
	
	-- Provide dedicated Outright PT for each sport --
	
	0.9 as v2spositiontaking_10_max,
	0.9 as v3spositiontaking_10_max,
	0.9 as v5spositiontaking_10_max,
	0.9 as v8spositiontaking_10_max,
	0.9 as v10spositiontaking_10_max,
	0.9 as v11spositiontaking_10_max,
	0.9 as v99spositiontaking_10_max,
	
	--- Outright PT for Super
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.spositiontaking else 0 end) as v2spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.spositiontaking else 0 end) as v3spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.spositiontaking else 0 end) as v5spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.spositiontaking else 0 end) as v8spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.spositiontaking else 0 end) as v10spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.spositiontaking else 0 end) as v11spositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.spositiontaking else 0 end) as v99spositiontaking_10,
	
	--- Outright PT for Master
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_10,
	
	--- Outright PT for Agent
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_10,
	
	-- N4
	max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end) as v2spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end) as v3spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end) as v5spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end) as v8spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end) as v10spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end) as v11spositiontaking_10_min, 
	max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end) as v99spositiontaking_10_min,
	
	CASE WHEN CDA.CustID IS NOT NULL THEN 1 ELSE 0 END AS IsDirectCustomer,
	isnull(@maxpermatch_min, 0) as MaxPerMatch_Min,
	isnull(@maxpermatchv2_min, 0) as MaxPerMatchv2_Min,
	isnull(@maxpermatchv3_min, 0) as MaxPerMatchv3_Min,
	isnull(@maxpermatchv5_min, 0) as MaxPerMatchv5_Min,
	isnull(@maxpermatchv8_min, 0) as MaxPerMatchv8_Min,
	isnull(@maxpermatchv10_min, 0) as MaxPerMatchv10_Min,
	isnull(@maxpermatchv11_min, 0) as MaxPerMatchv11_Min,
	isnull(@maxpermatchv99_min, 0) as MaxPerMatchv99_Min,
	isnull(@maxpermatchv99MP_min, 0) as MaxPerMatchv99MP_Min,
	isnull(@maxpermatchv1MP_min, 0) as MaxPerMatchv1MP_Min,	
	--BetSetting
	@minbet AS minbet, 
    @maxbet AS maxbet, 
    @maxpermatch AS maxpermatch, 
    @minbetv2 AS minbetv2, 
    @maxbetv2 AS maxbetv2, 
    @maxpermatchv2 AS maxpermatch2, 
    @minbetv3 AS minbetv3, 
    @maxbetv3 AS maxbetv3, 
    @maxpermatchv3 AS maxpermatch3, 
    @minbetv5 AS minbetv5, 
    @maxbetv5 AS maxbetv5, 
    @maxpermatchv5 AS maxpermatch5, 
    @minbetv8 AS minbetv8, 
    @maxbetv8 AS maxbetv8, 
    @maxpermatchv8 AS maxpermatch8, 
    @minbetv10 AS minbetv10, 
    @maxbetv10 AS maxbetv10, 
    @maxpermatchv10 AS maxpermatch10, 
    @minbetv11 AS minbetv11, 
    @maxbetv11 AS maxbetv11, 
    @maxpermatchv11 AS maxpermatch11, 
    @minbetv99 AS minbetv99, 
    @maxbetv99 AS maxbetv99, 
    @maxpermatchv99 AS maxpermatch99, 
    @minbetv99mp AS minbetv99mp, 
    @maxbetv99mp AS maxbetv99mp, 
    @maxpermatchv99mp AS maxpermatch99mp, 
    @minbetv1mp AS minbetv1mp, 
    @maxbetv1mp AS maxbetv1mp, 
    @maxpermatchv1mp AS maxpermatch1mp,    
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
	@maxPayoutpermatchv2saba		AS maxPayoutpermatchv2saba
from 
	custinfo as ci with (NOLOCK)
	INNER JOIN custsetting as cs with (NOLOCK) on ci.custid = cs.custid
	INNER JOIN custoverride as co with (NOLOCK) on ci.custid = co.custid and co.sporttype = cs.sporttype and co.bettype = cs.bettype
	CROSS APPLY  (	SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
						, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
				) AS cps 
	LEFT JOIN CustDirectAccount CDA WITH (NOLOCK) ON ci.custid = CDA.CustID
where 
	ci.roleid=4 and ci.custid=@CustID
group by 
	cps.closed,
	cps.reject, 
	ci.username,
	ci.credit,
	CDA.CustID

END

GO
