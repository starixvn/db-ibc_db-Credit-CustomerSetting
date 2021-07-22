/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelMAgentInfo] 
	@CustID int 
AS

/*
Created by:[]
Date:2006-12-02
Task: Master create Agent at Agent Site 
DB: DBCUST.CustDB
Original: agentsite\account\addnewmember.asp

Revisions:
    - @PphuongDoan: remove '_1' on the SP name 
	- 20090515@PhuongDao: Add new commission
	- 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
	- 20090903@Shifu: add IsInternal
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
    - 20100901@Lukas:	- Add mix parlay of mixed sports
						- Add number game
						- Remove mix parlay of basket ball
	- 20101027@Lukas: Add max per ball (number game)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
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
	- 20190909@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]	

 */
BEGIN 
SET NOCOUNT ON


Declare @UserName varchar(50), @UplineUsername varchar(50),@Msuspended bit 
Declare @MinBet_Max money,
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

	@MinBetv161_Max money,
	@MaxBetv161_Min money,	
	@MaxPerMatchv161_Min money,	
	@MaxPerMatchv161_Max money,

	@MaxPerBallv161_Max money,
	
	@MinBetv164_Max money,
	@MaxBetv164_Min money,	
	@MaxPerMatchv164_Min money,	
	@MaxPerMatchv164_Max money,
	
	@Credit_AllOtherAgent money, 
	@Credit_MAg money, 
	@Credit_Ag_Max money,
	@CurrencyID int,
	@AllowedCurr bit,	
	@DisableAutoMPT bit,
	@IsInternalMaster bit,
	@srecommend INT

----------------------------------

Declare
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
	@v2apositiontaking_10_max smallmoney,
	@v3apositiontaking_10_max smallmoney,
	@v5apositiontaking_10_max smallmoney,
	@v8apositiontaking_10_max smallmoney,
	@v10apositiontaking_10_max smallmoney,
	@v11apositiontaking_10_max smallmoney,
	@v99apositiontaking_10_max smallmoney,
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
	@v99apositiontaking_9999_max smallmoney,	
	@v99apositiontaking_9_max smallmoney,

	@v161apositiontaking_81_max smallmoney,
	@v161apositiontaking_83_max smallmoney,
	--@v161apositiontaking_85_max smallmoney,
	@v161apositiontaking_86_max smallmoney,
	@v161apositiontaking_88_max smallmoney,

	@v161alivepositiontaking_85_max smallmoney,
	@v161alivepositiontaking_86_max smallmoney,
	@v161alivepositiontaking_87_max smallmoney,
	@v161alivepositiontaking_89_max smallmoney,
	@v161alivepositiontaking_90_max smallmoney


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @Credit_AllOtherAgent = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where mrecommend = @CustID and RoleID = 2
select @Credit_MAg = isnull(credit, 0),@CurrencyID=ci.currency , @srecommend = srecommend from CustInfo as ci with (NOLOCK) where CustID = @CustID
SELECT @Msuspended = CASE WHEN cps.SuspendInfo > 0 THEN 1 ELSE 0 END FROM CustProductStatus cps WITH (NOLOCK) WHERE CustID = @CustID
select @Credit_Ag_Max = @Credit_MAg - @Credit_AllOtherAgent
Select @IsInternalMaster = isnull(IsInternal, 0) from CustMaster with (NOLOCK) where CustID = @CustId
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @Custid

Select 
	@MinBet_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBet_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetv2_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv2_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @CustID

Select 
	@MinBetv3_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv3_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @CustID

Select 
	@MinBetv5_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv5_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @CustID

Select 
	@MinBetv8_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv8_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @CustID

Select 
	@MinBetv10_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv10_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @CustID

Select 
	@MinBetv11_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv11_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @CustID

Select 
	@MinBetv99_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @CustID

-- mix parlay mixed sports
select	@MinBetv99MP_Max = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv99MP_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from custsetting cs WITH(NOLOCK)
	 INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype = 99
where ci.custid = @Custid

-- mix parlay soccer sports
select	@MinBetv1MP_Max = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv1MP_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from custsetting cs WITH(NOLOCK)
	 INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype = 1
where ci.custid = @Custid


-- number game
select	@MinBetv161_Max = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv161_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 81 and cs.sporttype = 161
where ci.custid = @CustID

select	@MinBetv164_Max = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv164_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 8101 and cs.sporttype = 164
where ci.custid = @CustID

-- Myanmar Odds

DECLARE @MyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0

SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
BEGIN
	SET @MyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)
	
END	
--------------------------------------
Select 
	@MaxPerMatch_Min = 0, 
	@MaxperMatch_Max = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),
	
	@MaxPerMatchv2_Min = 0,
	@MaxPerMatchv2_Max = Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),
	
	@MaxPerMatchv3_Min = 0,
	@MaxPerMatchv3_Max = Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),

	@MaxPerMatchv5_Min = 0,
	@MaxPerMatchv5_Max = Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),

	@MaxPerMatchv8_Min = 0,
	@MaxPerMatchv8_Max = Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),

	@MaxPerMatchv10_Min = 0,
	@MaxPerMatchv10_Max = Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),

	@MaxPerMatchv11_Min = 0,
	@MaxPerMatchv11_Max = Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),

	@MaxPerMatchv99_Min = 0,
	@MaxPerMatchv99_Max = Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),
		
	@MaxPerMatchv99MP_Min = 0,
	@MaxPerMatchv99MP_Max = Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),

	@MaxPerMatchv1MP_Min = 0,
	@MaxPerMatchv1MP_Max = Min(case when cs.MaxPerMatch1MP = 0 then NULL else cs.MaxPerMatch1MP end),


	@MaxPerMatchv161_Min = 0,
	@MaxPerMatchv161_Max = Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),

	@MaxPerBallv161_Max = Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),
	
	@MaxPerMatchv164_Min = 0,
	@MaxPerMatchv164_Max = Min(case when cs.MaxPerMatch164 = 0 then NULL else cs.MaxPerMatch164 end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

select @UplineUsername = username from custinfo with (nolock) where custid = @custid


EXEC dbo.Age_CustomerSelSuggestUsername @prefix = @uplineusername,@custid = @custid, @roleid = 3, @seqname = @username output
 

Select
	--get @apt_max = a4, to check a2<=a4 on the web
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
	@v99apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end),

	-- Mix parlay of mixed sports
	@v99apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)
from custsetting as cs with (nolock)
where custid = (select srecommend from customer with (nolock) where custid = @CustID)

-- number game setting
select 
	@v161apositiontaking_81_max = max(case when cs.bettype = 81 and cs.sporttype = 161 then cs.apositiontaking else 0 end),
	@v161apositiontaking_83_max = max(case when cs.bettype = 83 and cs.sporttype = 161 then cs.apositiontaking else 0 end),
	--@v161apositiontaking_85_max = max(case when cs.bettype = 85 and cs.sporttype = 161 then cs.apositiontaking else 0 end),
	@v161apositiontaking_86_max = max(case when cs.bettype = 86 and cs.sporttype = 161 then cs.apositiontaking else 0 end),
	@v161apositiontaking_88_max = max(case when cs.bettype = 88 and cs.sporttype = 161 then cs.apositiontaking else 0 end),

	@v161alivepositiontaking_85_max = max(case when cs.bettype = 85 and cs.sporttype = 161 then cs.alivepositiontaking else 0 end),
	@v161alivepositiontaking_86_max = max(case when cs.bettype = 86 and cs.sporttype = 161 then cs.alivepositiontaking else 0 end),
	@v161alivepositiontaking_87_max = max(case when cs.bettype = 87 and cs.sporttype = 161 then cs.alivepositiontaking else 0 end),
	@v161alivepositiontaking_89_max = max(case when cs.bettype = 89 and cs.sporttype = 161 then cs.alivepositiontaking else 0 end),
	@v161alivepositiontaking_90_max = max(case when cs.bettype = 90 and cs.sporttype = 161 then cs.alivepositiontaking else 0 end)
from custsetting3rd as cs with(nolock)
where custid = (select srecommend from customer with(nolock) where custid = @CustID)


Select
	@UserName as NewUserName,
	@Msuspended as suspended,
	@Credit_Ag_Max as Credit_Max,
	@AllowedCurr AS AllowedCurr,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	@IsInternalMaster as IsInternalMaster,
	--------------------------
	--get apt_max = a4, to check a2<=a4 on the web
	@apositiontaking_1_max as apositiontaking_1_max,
	@apositiontaking_2_max as apositiontaking_2_max,
	@apositiontaking_3_max as apositiontaking_3_max,
	@apositiontaking_4_max as apositiontaking_4_max,
	@apositiontaking_5_max as apositiontaking_5_max,
	@apositiontaking_6_max as apositiontaking_6_max,
	@apositiontaking_7_max as apositiontaking_7_max,
	@apositiontaking_8_max as apositiontaking_8_max,
	@apositiontaking_9_max as apositiontaking_9_max,
	@apositiontaking_10_max as apositiontaking_10_max,
	@v2apositiontaking_10_max as v2apositiontaking_10_max,
	@v3apositiontaking_10_max as v3apositiontaking_10_max,
	@v5apositiontaking_10_max as v5apositiontaking_10_max,
	@v8apositiontaking_10_max as v8apositiontaking_10_max,
	@v10apositiontaking_10_max as v10apositiontaking_10_max,
	@v11apositiontaking_10_max as v11apositiontaking_10_max,
	@v99apositiontaking_10_max as v99apositiontaking_10_max,
	@apositiontaking_9999_max as apositiontaking_9999_max,
	
	@alivepositiontaking_1_max as alivepositiontaking_1_max,
	@alivepositiontaking_3_max as alivepositiontaking_3_max,
	@alivepositiontaking_7_max as alivepositiontaking_7_max,
	@alivepositiontaking_8_max as alivepositiontaking_8_max,
	
	@v2apositiontaking_1_max as v2apositiontaking_1_max,
	@v2apositiontaking_2_max as v2apositiontaking_2_max,
	@v2apositiontaking_3_max as v2apositiontaking_3_max,
	@v2apositiontaking_7_max as v2apositiontaking_7_max,
	@v2apositiontaking_8_max as v2apositiontaking_8_max,
--	@v2apositiontaking_9_max as v2apositiontaking_9_max,
	@v2apositiontaking_20_max as v2apositiontaking_20_max,
	@v2apositiontaking_9999_max as v2apositiontaking_9999_max,

	@v3apositiontaking_1_max as v3apositiontaking_1_max,
	@v3apositiontaking_2_max as v3apositiontaking_2_max,
	@v3apositiontaking_3_max as v3apositiontaking_3_max,
	@v3apositiontaking_20_max as v3apositiontaking_20_max,

	@v5apositiontaking_1_max as v5apositiontaking_1_max,
	@v5apositiontaking_2_max as v5apositiontaking_2_max,
	@v5apositiontaking_3_max as v5apositiontaking_3_max,
	@v5apositiontaking_20_max as v5apositiontaking_20_max,
	@v5apositiontaking_9999_max as v5apositiontaking_9999_max,

	@v8apositiontaking_1_max as v8apositiontaking_1_max,
	@v8apositiontaking_3_max as v8apositiontaking_3_max,
	@v8apositiontaking_20_max as v8apositiontaking_20_max,

	@v10apositiontaking_1_max as v10apositiontaking_1_max,
	@v10apositiontaking_2_max as v10apositiontaking_2_max,
	@v10apositiontaking_3_max as v10apositiontaking_3_max,
	@v10apositiontaking_20_max as v10apositiontaking_20_max,

	@v11apositiontaking_1_max as v11apositiontaking_1_max,
	@v11apositiontaking_20_max as v11apositiontaking_20_max,

	@v99apositiontaking_1_max as v99apositiontaking_1_max,
	@v99apositiontaking_2_max as v99apositiontaking_2_max,
	@v99apositiontaking_3_max as v99apositiontaking_3_max,
	@v99apositiontaking_20_max as v99apositiontaking_20_max,
	@v99apositiontaking_9999_max as v99apositiontaking_9999_max,
	-- Mix parlay of mixed sports
	@v99apositiontaking_9_max as v99apositiontaking_9_max,


	--number game
	@v161apositiontaking_81_max as v161apositiontaking_81_max,
	@v161apositiontaking_83_max as v161apositiontaking_83_max,
	--@v161apositiontaking_85_max as v161apositiontaking_85_max,
	@v161apositiontaking_86_max as v161apositiontaking_86_max,
	@v161apositiontaking_88_max as v161apositiontaking_88_max,
	
	@v161alivepositiontaking_85_max as v161alivepositiontaking_85_max,
	@v161alivepositiontaking_86_max as v161alivepositiontaking_86_max,
	@v161alivepositiontaking_87_max as v161alivepositiontaking_87_max,
	@v161alivepositiontaking_89_max as v161alivepositiontaking_89_max,
	@v161alivepositiontaking_90_max as v161alivepositiontaking_90_max,
	
	--min(m3,l3)
	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as mlivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v2mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v3mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v5mpositiontaking_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v8mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v10mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v11mpositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_9999,
	-- mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.mpositiontaking < co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as v99mpositiontaking_9,


	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.mpositiontaking < co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.mpositiontaking < co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_83,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mpositiontaking < co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mpositiontaking < co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.mpositiontaking < co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end) as v161mpositiontaking_88,

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161mlivepositiontaking_90,
	
	--Auto Master PT
	--max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_3,
	--max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_4,
	--max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_5,
	--max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_6,
	--max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_7,
	--max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_9,
	--max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_mpositiontaking_10,

	--max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_mlivepositiontaking_1,
	--max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_mlivepositiontaking_3,
	--max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_mlivepositiontaking_7,
	--max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end) as auto_mlivepositiontaking_8,

	--max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_3,
	--max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_7,
	--max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_9,
	--max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v2mpositiontaking_20,

	--max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v3mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v3mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v3mpositiontaking_3,
	--max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v3mpositiontaking_20,

	--max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v5mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v5mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v5mpositiontaking_3,
	--max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v5mpositiontaking_20,

	--max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v8mpositiontaking_1,
	--max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v8mpositiontaking_3,
	--max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v8mpositiontaking_20,

	--max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v10mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v10mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v10mpositiontaking_3,
	--max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v10mpositiontaking_20,

	--max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v11mpositiontaking_1,
	--max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v11mpositiontaking_20,

	--max(case when cs.bettype = 2 and cs.sporttype=12 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v12mpositiontaking_2,
	--max(case when cs.bettype = 21 and cs.sporttype=12 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v12mpositiontaking_21,
	--max(case when cs.bettype = 22 and cs.sporttype=12 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v12mpositiontaking_22,

	--max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v99mpositiontaking_1,
	--max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v99mpositiontaking_2,
	--max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v99mpositiontaking_3,
	--max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end) as auto_v99mpositiontaking_20,
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- For MyanmarOdds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@MyanmarOdds,0) AS discountMyanmarOdds,
	
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.adiscount else 0 end) as discount1x2,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	
	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.adiscount else 0 end) as discountcsFC,	

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.minbet else 0 end) as minbet,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.maxbet else 0 end) as maxbet,
	ci.maxpermatch,
	
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.minbet else 0 end) as MinBetv2,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.maxbet else 0 end) as MaxBetv2,	
	ci.maxpermatch2 as MaxPerMatchv2,

	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.minbet else 0 end) as MinBetv3,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.maxbet else 0 end) as MaxBetv3,	
	ci.maxpermatch3 as MaxPerMatchv3,

	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.minbet else 0 end) as MinBetv5,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.maxbet else 0 end) as MaxBetv5,	
	ci.maxpermatch5 as MaxPerMatchv5,

	max(case when cs.bettype = 2 and cs.sporttype=8 then cs.minbet else 0 end) as MinBetv8,
	max(case when cs.bettype = 2 and cs.sporttype=8 then cs.maxbet else 0 end) as MaxBetv8,	
	ci.maxpermatch8 as MaxPerMatchv8,

	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.minbet else 0 end) as MinBetv10,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.maxbet else 0 end) as MaxBetv10,	
	ci.maxpermatch10 as MaxPerMatchv10,

	max(case when cs.bettype = 2 and cs.sporttype=11 then cs.minbet else 0 end) as MinBetv11,
	max(case when cs.bettype = 2 and cs.sporttype=11 then cs.maxbet else 0 end) as MaxBetv11,	
	ci.maxpermatch11 as MaxPerMatchv11,

	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.minbet else 0 end) as MinBetv99,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.maxbet else 0 end) as MaxBetv99,	
	ci.maxpermatch99 as MaxPerMatchv99,	
	
	--Mix parlay of mixed sports
	max(case when cs.bettype = 9 and cs.sporttype = 99 then cs.minbet else 0 end) as MinBetv99MP,
	max(case when cs.bettype = 9 and cs.sporttype = 99 then cs.maxbet else 0 end) as MaxBetv99MP,	
	ci.maxpermatch99mp as MaxPerMatchv99MP,

	--Mix parlay of soccer sports
	max(case when cs.bettype = 9 and cs.sporttype = 1 then cs.minbet else 0 end) as MinBetv1MP,
	max(case when cs.bettype = 9 and cs.sporttype = 1 then cs.maxbet else 0 end) as MaxBetv1MP,	
	ci.maxpermatch1mp as MaxPerMatchv1MP,

	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype = 161 then cs3.minbet else 0 end) as MinBetv161,
	max(case when cs3.bettype = 81 and cs3.sporttype = 161 then cs3.maxbet else 0 end) as MaxBetv161,
	ci.maxpermatch161 as MaxPerMatchv161,
	ci.maxperball161 as MaxPerBallv161,
	
	max(case when cs3.bettype = 8101 and cs3.sporttype = 164 then cs3.minbet else 0 end) as MinBetv164,
	max(case when cs3.bettype = 8101 and cs3.sporttype = 164 then cs3.maxbet else 0 end) as MaxBetv164,
	ci.maxpermatch164 as MaxPerMatchv164,
	
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
	
	IsNull(@MinBetv99MP_Max,0) as MinBetv99MP_Max,
	IsNull(@MaxBetv99MP_Min,0) as MaxBetv99MP_Min,
	IsNull(@MaxPerMatchv99MP_Min,0) as MaxPerMatchv99MP_Min,
	IsNull(@MaxPerMatchv99MP_Max,0) as MaxPerMatchv99MP_Max,

	IsNull(@MinBetv1MP_Max,0) as MinBetv1MP_Max,
	IsNull(@MaxBetv1MP_Min,0) as MaxBetv1MP_Min,
	IsNull(@MaxPerMatchv1MP_Min,0) as MaxPerMatchv1MP_Min,
	IsNull(@MaxPerMatchv1MP_Max,0) as MaxPerMatchv1MP_Max,
	


	IsNull(@MinBetv161_Max,0) as MinBetv161_Max,
	IsNull(@MaxBetv161_Min,0) as MaxBetv161_Min,
	IsNull(@MaxPerMatchv161_Min,0) as MaxPerMatchv161_Min,
	IsNull(@MaxPerMatchv161_Max,0) as MaxPerMatchv161_Max,
	ISNull(@MaxPerBallv161_Max,0) as MaxPerBallv161_Max,
	
	IsNull(@MinBetv164_Max,0) as MinBetv164_Max,
	IsNull(@MaxBetv164_Min,0) as MaxBetv164_Min,
	IsNull(@MaxPerMatchv164_Min,0) as MaxPerMatchv164_Min,
	IsNull(@MaxPerMatchv164_Max,0) as MaxPerMatchv164_Max,
	
	--n3
	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_3_min,
	max(case when cs.bettype = 4 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_4_min,
	max(case when cs.bettype = 5 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_5_min,
	max(case when cs.bettype = 6 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_6_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_8_min,
	max(case when cs.bettype = 9 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_9_min,
	max(case when cs.bettype = 10 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_10_min,
	max(case when cs.bettype = 10 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_10_min,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then co.minpositiontaking else 0 end) as mpositiontaking_9999_min,

	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as mlivepositiontaking_8_min,

	max(case when cs.bettype = 1 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_8_min,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_9_min,
	max(case when cs.bettype = 20 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_20_min,
	
	max(case when cs.bettype = 9999 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2mpositiontaking_9999_min,

	max(case when cs.bettype = 1 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3mpositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_20_min,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5mpositiontaking_9999_min,

	max(case when cs.bettype = 1 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8mpositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10mpositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_1_min,
	max(case when cs.bettype = 20 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11mpositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_20_min,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_9999_min,

	-- Mix parlay mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99mpositiontaking_9_min,


	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_81_min,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_83_min,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_85_min,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_86_min,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161mpositiontaking_88_min,

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_85_min,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_86_min,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_87_min,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_89_min,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161mlivepositiontaking_90_min,
	MAX(Customer.site) AS Site
From 
	Customer with (NOLOCK)
	INNER JOIN custinfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
	INNER JOIN CustSetting as cs with (NOLOCK) on Customer.CustID = CS.CustID
	LEFT JOIN custsetting3rd as cs3 with(nolock) on Customer.CustID = cs3.CustID
	LEFT JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype= cs.bettype
	LEFT JOIN custoverride3rd as co3 with(nolock) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
Where Customer.CustID = @CustID
group by ci.maxpermatch,
	ci.maxpermatch2,
	ci.maxpermatch3,
	ci.maxpermatch5,
	ci.maxpermatch8,
	ci.maxpermatch10,	
	ci.maxpermatch11,
	ci.maxpermatch99,
	ci.maxpermatch99mp,
	ci.maxpermatch1mp,
	ci.maxpermatch161,
	ci.maxperball161,
	ci.maxpermatch164

END
GO
