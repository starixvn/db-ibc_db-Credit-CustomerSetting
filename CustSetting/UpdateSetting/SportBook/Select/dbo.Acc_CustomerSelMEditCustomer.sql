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

Param's Explanation:
• @CustID: AgentID
  @MRecommend
*/

SET NOCOUNT ON
--SET ANSI_WARNINGS OFF
---------------------------
-- ***Check Downline Belonging***
declare @roleid tinyint, @Username varchar(30), @srecommend INT = 0

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

	@MinBetv161_Max money,
	@MaxBetv161_Min money,	
	@MaxPerMatchv161_Min money,	
	@MaxPerMatchv161_Max money,
	
	@MaxPerBallv161_Max money,
	
	@MinBetv99MP_Max money,
	@MaxBetv99MP_Min money,	
	@MaxPerMatchv99MP_Min money,	
	@MaxPerMatchv99MP_Max money,
	
	@MinBetv1MP_Max money,
	@MaxBetv1MP_Min money,	
	@MaxPerMatchv1MP_Min money,	
	@MaxPerMatchv1MP_Max money,
	
	@MinBetv164_Max money,
	@MaxBetv164_Min money,	
	@MaxPerMatchv164_Min money,	
	@MaxPerMatchv164_Max money,
	
	@ga decimal(9,8), @gb decimal(9,8), @gc decimal(9,8), @gd decimal(9,8), @dis decimal(9,8), 
		@dis1x2 decimal(9,8),
	@Credit_AllOtherAgent money, @Credit_AllMember money, @Credit_MAg money,
	@Credit_Ag_Min money, @Credit_Ag_Max money, @MaxCredit_Mem_Min money, @Mem_MaxCredit money,
	@Msuspended bit, @DisableAutoMPT bit

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------
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
	
Select 
	@MinBet_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBet_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetv2_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv2_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @CustID

Select 
	@MinBetv3_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv3_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @CustID

Select 
	@MinBetv5_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv5_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @CustID

Select 
	@MinBetv8_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv8_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @CustID

Select 
	@MinBetv10_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv10_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @CustID

Select 
	@MinBetv11_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv11_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @CustID


Select 
	@MinBetv99_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @CustID


Select 
	@MinBetv99MP_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99MP_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=99
where ci.custid = @CustID


Select 
	@MinBetv1MP_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv1MP_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetv161_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv161_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 81 and cs.sporttype=161
where ci.custid = @CustID

Select 
	@MinBetv164_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv164_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 8101 and cs.sporttype=164
where ci.custid = @CustID

Select
	@MaxperMatch_Min = 0,	
	@MaxPerMatchv2_Min = 0,
	@MaxPerMatchv3_Min = 0,
	@MaxPerMatchv5_Min = 0,
	@MaxPerMatchv8_Min = 0,
	@MaxPerMatchv10_Min = 0,
	@MaxPerMatchv11_Min = 0,
	@MaxPerMatchv99_Min = 0,

	@MaxperMatch_Max = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end), 
	@MaxPerMatchv2_Max = Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),
	@MaxPerMatchv3_Max = Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),
	@MaxPerMatchv5_Max = Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),
	@MaxPerMatchv8_Max = Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),
	@MaxPerMatchv10_Max = Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),
	@MaxPerMatchv11_Max = Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),
	@MaxPerMatchv99_Max = Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),
	@MaxPerMatchv99MP_Max = Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),
	
	@MaxPerMatchv1MP_Max = Min(case when cs.MaxPerMatch1MP = 0 then NULL else cs.MaxPerMatch1MP end),
	
	@MaxPerMatchv164_Max = Min(case when cs.MaxPerMatch164 = 0 then NULL else cs.MaxPerMatch164 end),
	
	@MaxPerMatchv161_Max = Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),
	@MaxPerBallv161_Max = Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),
	@srecommend = cs.srecommend
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID
group by Cs.srecommend

select 
	@ga = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupa else 0 end),
	@gb = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupb else 0 end),
	@gc = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupc else 0 end),
	@gd = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.groupd else 0 end),
	@dis = max(case when acs.bettype = 4 and acs.sporttype=1 then acs.adiscount else 0 end),
	@dis1x2 = max(case when acs.bettype = 5 and acs.sporttype=1 then acs.adiscount else 0 end)
	
from custsetting as acs with (NOLOCK)
where acs.custid = @MRecommend

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
	
	@max_v161mapositiontaking_81 smallmoney,
	@max_v161mapositiontaking_83 smallmoney,
	--@max_v161mapositiontaking_85 smallmoney,
	@max_v161mapositiontaking_86 smallmoney,
	@max_v161mapositiontaking_88 smallmoney,
	
	@max_v161malivepositiontaking_85 smallmoney,
	@max_v161malivepositiontaking_86 smallmoney,
	@max_v161malivepositiontaking_87 smallmoney,
	@max_v161malivepositiontaking_89 smallmoney,
	@max_v161malivepositiontaking_90 smallmoney,
	
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

	@min_v161mapositiontaking_81 smallmoney,
	@min_v161mapositiontaking_83 smallmoney,
	--@min_v161mapositiontaking_85 smallmoney,
	@min_v161mapositiontaking_86 smallmoney,
	@min_v161mapositiontaking_88 smallmoney,
	
	@min_v161malivepositiontaking_85 smallmoney,
	@min_v161malivepositiontaking_86 smallmoney,
	@min_v161malivepositiontaking_87 smallmoney,
	@min_v161malivepositiontaking_89 smallmoney,
	@min_v161malivepositiontaking_90 smallmoney,
	
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
	
	@v161apositiontaking_81_max smallmoney,
	@v161apositiontaking_83_max smallmoney,
	--@v161apositiontaking_85_max smallmoney,
	@v161apositiontaking_86_max smallmoney,
	@v161apositiontaking_88_max smallmoney,
	
	@v161alivepositiontaking_85_max smallmoney,
	@v161alivepositiontaking_86_max smallmoney,
	@v161alivepositiontaking_87_max smallmoney,
	@v161alivepositiontaking_89_max smallmoney,
	@v161alivepositiontaking_90_max smallmoney,
	
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

select @min_v161mapositiontaking_81 =minpositiontaking, @max_v161mapositiontaking_81 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
select @min_v161mapositiontaking_83 =minpositiontaking, @max_v161mapositiontaking_83 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
--select @min_v161mapositiontaking_85 =minpositiontaking, @max_v161mapositiontaking_85 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
select @min_v161mapositiontaking_86 =minpositiontaking, @max_v161mapositiontaking_86 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select @min_v161mapositiontaking_88 =minpositiontaking, @max_v161mapositiontaking_88 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161

select @min_v161malivepositiontaking_85 =minlivepositiontaking, @max_v161malivepositiontaking_85 =maxlivepositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
select @min_v161malivepositiontaking_86 =minlivepositiontaking, @max_v161malivepositiontaking_86 =maxlivepositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select @min_v161malivepositiontaking_87 =minlivepositiontaking, @max_v161malivepositiontaking_87 =maxlivepositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
select @min_v161malivepositiontaking_89 =minlivepositiontaking, @max_v161malivepositiontaking_89 =maxlivepositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
select @min_v161malivepositiontaking_90 =minlivepositiontaking, @max_v161malivepositiontaking_90 =maxlivepositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161



-------------------------------------------------------
/*
--get m3
select @max_mapositiontaking_1 =mpositiontaking, @max_malivepositiontaking_1 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @max_mapositiontaking_3 =mpositiontaking, @max_malivepositiontaking_3 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @max_mapositiontaking_7 =mpositiontaking, @max_malivepositiontaking_7 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @max_mapositiontaking_8 =mpositiontaking, @max_malivepositiontaking_8 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1

select @max_mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @max_mapositiontaking_4 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @max_mapositiontaking_5 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @max_mapositiontaking_6 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @max_mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @max_mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

select @max_v2mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @max_v2mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @max_v2mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @max_v2mapositiontaking_7 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @max_v2mapositiontaking_8 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
*/

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
	@max_v99mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),

	@max_v161mapositiontaking_81 = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	@max_v161mapositiontaking_83 = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	--@max_v161mapositiontaking_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	@max_v161mapositiontaking_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	@max_v161mapositiontaking_88 = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	
	@max_v161malivepositiontaking_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < mco3.maxlivepositiontaking then cs3.mlivepositiontaking else mco3.maxlivepositiontaking end else 0 end),
	@max_v161malivepositiontaking_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < mco3.maxlivepositiontaking then cs3.mlivepositiontaking else mco3.maxlivepositiontaking end else 0 end),
	@max_v161malivepositiontaking_87 = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < mco3.maxlivepositiontaking then cs3.mlivepositiontaking else mco3.maxlivepositiontaking end else 0 end),
	@max_v161malivepositiontaking_89 = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < mco3.maxlivepositiontaking then cs3.mlivepositiontaking else mco3.maxlivepositiontaking end else 0 end),
	@max_v161malivepositiontaking_90 = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < mco3.maxlivepositiontaking then cs3.mlivepositiontaking else mco3.maxlivepositiontaking end else 0 end)	
	
from
	custsetting as cs with (nolock)
	inner join custoverride as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
	inner join custoverride3rd as mco3 with (nolock) on cs.custid = mco3.custid 
	inner join CustSetting3rd as cs3 with (nolock) on cs3.custid = mco3.custid and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype
	
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
	@max_v99mapositiontaking_9999 = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking < @max_v99mapositiontaking_9999 then cs.mpositiontaking else @max_v99mapositiontaking_9999 end else 0 end),

	@max_v161mapositiontaking_81 = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.mpositiontaking < @max_v161mapositiontaking_81 then cs3.mpositiontaking else @max_v161mapositiontaking_81 end else 0 end),
	@max_v161mapositiontaking_83 = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.mpositiontaking < @max_v161mapositiontaking_83 then cs3.mpositiontaking else @max_v161mapositiontaking_83 end else 0 end),
	--@max_v161mapositiontaking_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mpositiontaking < mco3.maxpositiontaking then cs3.mpositiontaking else mco3.maxpositiontaking end else 0 end),
	@max_v161mapositiontaking_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mpositiontaking < @max_v161mapositiontaking_86 then cs3.mpositiontaking else @max_v161mapositiontaking_86 end else 0 end),
	@max_v161mapositiontaking_88 = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.mpositiontaking < @max_v161mapositiontaking_88 then cs3.mpositiontaking else @max_v161mapositiontaking_88 end else 0 end),
	
	@max_v161malivepositiontaking_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < @max_v161malivepositiontaking_85 then cs3.mlivepositiontaking else @max_v161malivepositiontaking_85 end else 0 end),
	@max_v161malivepositiontaking_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < @max_v161malivepositiontaking_86 then cs3.mlivepositiontaking else @max_v161malivepositiontaking_86 end else 0 end),
	@max_v161malivepositiontaking_87 = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < @max_v161malivepositiontaking_87 then cs3.mlivepositiontaking else @max_v161malivepositiontaking_87 end else 0 end),
	@max_v161malivepositiontaking_89 = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < @max_v161malivepositiontaking_89 then cs3.mlivepositiontaking else @max_v161malivepositiontaking_89 end else 0 end),
	@max_v161malivepositiontaking_90 = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.mlivepositiontaking < @max_v161malivepositiontaking_90 then cs3.mlivepositiontaking else @max_v161malivepositiontaking_90 end else 0 end)	
	
from
	custsetting as cs with (nolock)
	inner join CustSetting3rd as cs3 with (nolock) on cs3.custid = cs.custid 
	
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
	@v99apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end),

	@v161apositiontaking_81_max = max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end),
	@v161apositiontaking_83_max = max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end),
	--@v161apositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.apositiontaking else 0 end),
	@v161apositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end),
	@v161apositiontaking_88_max = max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end),	

	@v161alivepositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end),
	@v161alivepositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end),
	@v161alivepositiontaking_87_max = max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end),
	@v161alivepositiontaking_89_max = max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end),
	@v161alivepositiontaking_90_max = max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)		

	
from custsetting as cs with (nolock)
	INNER JOIN CustSetting3rd as cs3 with (NOLOCK) on cs.custid = cs3.custid 
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
	ci.maxpermatch,
	ci.maxpermatch2 as maxpermatchv2,
	ci.maxpermatch3 as maxpermatchv3,
	ci.maxpermatch5 as maxpermatchv5,
	ci.maxpermatch8 as maxpermatchv8,
	ci.maxpermatch10 as maxpermatchv10,
	ci.maxpermatch11 as maxpermatchv11,
	ci.maxpermatch99 as maxpermatchv99,
	ci.maxpermatch99MP as maxpermatchv99MP,
	
	ci.maxpermatch1MP as maxpermatchv1MP,

	ci.maxpermatch161 as maxpermatchv161,
	ci.maxperball161 as maxperballv161,
	
	ci.maxpermatch164 as maxpermatchv164,
	
	ci.credit,
	@Mem_MaxCredit as Mem_MaxCredit,
	@Credit_Ag_Min as Credit_Min,
	@Credit_Ag_Max as Credit_Max,
	@MaxCredit_Mem_Min as MaxCredit_Min,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.minbet else 0 end) as minbet,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.maxbet else 0 end) as maxbet,
	
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.minbet else 0 end) as MinBetv2,
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.maxbet else 0 end) as MaxBetv2,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.minbet else 0 end) as MinBetv3,
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.maxbet else 0 end) as MaxBetv3,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.minbet else 0 end) as MinBetv5,
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.maxbet else 0 end) as MaxBetv5,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.minbet else 0 end) as MinBetv8,
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.maxbet else 0 end) as MaxBetv8,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.minbet else 0 end) as MinBetv10,
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.maxbet else 0 end) as MaxBetv10,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.minbet else 0 end) as MinBetv11,
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.maxbet else 0 end) as MaxBetv11,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.minbet else 0 end) as MinBetv99,
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.maxbet else 0 end) as MaxBetv99,
	
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.minbet else 0 end) as MinBetv99MP,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.maxbet else 0 end) as MaxBetv99MP,

	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.minbet else 0 end) as MinBetv1MP,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.maxbet else 0 end) as MaxBetv1MP,

	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.minbet else 0 end) as MinBetv161,
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.maxbet else 0 end) as MaxBetv161,
	
	max(case when cs3.bettype = 8101 and cs3.sporttype=164 then cs3.minbet else 0 end) as MinBetv164,
	max(case when cs3.bettype = 8101 and cs3.sporttype=164 then cs3.maxbet else 0 end) as MaxBetv164,

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

	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_83,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_88,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_90,
	
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_83,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_88,	

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_90,
	
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

	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_83,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_88,	

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_87,	
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_90,	
	
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
	
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_83,
	--max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_88,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_90,
	
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

	@max_v161mapositiontaking_81 as auto_v161mpositiontaking_81_max,
	@max_v161mapositiontaking_83 as auto_v161mpositiontaking_83_max,
	--@max_v161mapositiontaking_85 as auto_v161mpositiontaking_85_max,
	@max_v161mapositiontaking_86 as auto_v161mpositiontaking_86_max,
	@max_v161mapositiontaking_88 as auto_v161mpositiontaking_88_max,
		
	@max_v161malivepositiontaking_85 as auto_v161mlivepositiontaking_85_max,
	@max_v161malivepositiontaking_86 as auto_v161mlivepositiontaking_86_max,
	@max_v161malivepositiontaking_87 as auto_v161mlivepositiontaking_87_max,
	@max_v161malivepositiontaking_89 as auto_v161mlivepositiontaking_89_max,
	@max_v161malivepositiontaking_90 as auto_v161mlivepositiontaking_90_max,
	
	
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

	IsNull(@MinBetv161_Max, 0) as MinBetv161_Max,
	IsNull(@MaxBetv161_Min, 0) as MaxBetv161_Min,	
	IsNull(@MaxPerMatchv161_Min, 0) as MaxPerMatchv161_Min,	
	IsNull(@MaxPerMatchv161_Max, 0) as MaxPerMatchv161_Max,
	isnull(@MaxPerBallv161_Max, 0) as MaxPerBallv161_Max,
	
	IsNull(@MinBetv164_Max, 0) as MinBetv164_Max,
	IsNull(@MaxBetv164_Min, 0) as MaxBetv164_Min,	
	IsNull(@MaxPerMatchv164_Min, 0) as MaxPerMatchv164_Min,	
	IsNull(@MaxPerMatchv164_Max, 0) as MaxPerMatchv164_Max,
	
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

	@max_v161mapositiontaking_81 as max_v161mapositiontaking_81,
	@max_v161mapositiontaking_83 as max_v161mapositiontaking_83,
	--@max_v161mapositiontaking_85 as max_v161mapositiontaking_85,
	@max_v161mapositiontaking_86 as max_v161mapositiontaking_86,
	@max_v161mapositiontaking_88 as max_v161mapositiontaking_88,
		
	@max_v161malivepositiontaking_85 as max_v161malivepositiontaking_85,
	@max_v161malivepositiontaking_86 as max_v161malivepositiontaking_86,
	@max_v161malivepositiontaking_87 as max_v161malivepositiontaking_87,
	@max_v161malivepositiontaking_89 as max_v161malivepositiontaking_89,
	@max_v161malivepositiontaking_90 as max_v161malivepositiontaking_90,
		
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

	@min_v161mapositiontaking_81 as min_v161mapositiontaking_81,
	@min_v161mapositiontaking_83 as min_v161mapositiontaking_83,
	--@min_v161mapositiontaking_85 as min_v161mapositiontaking_85,
	@min_v161mapositiontaking_86 as min_v161mapositiontaking_86,	
	@min_v161mapositiontaking_88 as min_v161mapositiontaking_88,
	
	@min_v161malivepositiontaking_85 as min_v161malivepositiontaking_85,
	@min_v161malivepositiontaking_86 as min_v161malivepositiontaking_86,
	@min_v161malivepositiontaking_87 as min_v161malivepositiontaking_87,
	@min_v161malivepositiontaking_89 as min_v161malivepositiontaking_89,
	@min_v161malivepositiontaking_90 as min_v161malivepositiontaking_90,
	
	
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

	max(case when co3.bettype = 81 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_81_min,
	max(case when co3.bettype = 83 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_83_min,
	--max(case when co3.bettype = 85 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_85_min,
	max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_86_min,	
	max(case when co3.bettype = 88 and co3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_88_min,

	max(case when co3.bettype = 85 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_85_min,
	max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_86_min,
	max(case when co3.bettype = 87 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_87_min,
	max(case when co3.bettype = 89 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_89_min,
	max(case when co3.bettype = 90 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_90_min,
	
	
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

	max(case when co3.bettype = 81 and co3.sporttype=161 then case when co3.maxpositiontaking<@v161apositiontaking_81_max then co3.maxpositiontaking else @v161apositiontaking_81_max end else 0 end) as v161apositiontaking_81_max,
	max(case when co3.bettype = 83 and co3.sporttype=161 then case when co3.maxpositiontaking<@v161apositiontaking_83_max then co3.maxpositiontaking else @v161apositiontaking_83_max end else 0 end) as v161apositiontaking_83_max,
	--max(case when co3.bettype = 85 and co3.sporttype=161 then case when co3.maxpositiontaking<@v161apositiontaking_85_max then co3.maxpositiontaking else @v161apositiontaking_85_max end else 0 end) as v161apositiontaking_85_max,
	max(case when co3.bettype = 86 and co3.sporttype=161 then case when co3.maxpositiontaking<@v161apositiontaking_86_max then co3.maxpositiontaking else @v161apositiontaking_86_max end else 0 end) as v161apositiontaking_86_max,
	max(case when co3.bettype = 88 and co3.sporttype=161 then case when co3.maxpositiontaking<@v161apositiontaking_88_max then co3.maxpositiontaking else @v161apositiontaking_88_max end else 0 end) as v161apositiontaking_88_max,
	
	max(case when co3.bettype = 85 and co3.sporttype=161 then case when co3.maxlivepositiontaking<@v161alivepositiontaking_85_max then co3.maxlivepositiontaking else @v161alivepositiontaking_85_max end else 0 end) as v161alivepositiontaking_85_max,
	max(case when co3.bettype = 86 and co3.sporttype=161 then case when co3.maxlivepositiontaking<@v161alivepositiontaking_86_max then co3.maxlivepositiontaking else @v161alivepositiontaking_86_max end else 0 end) as v161alivepositiontaking_86_max,
	max(case when co3.bettype = 87 and co3.sporttype=161 then case when co3.maxlivepositiontaking<@v161alivepositiontaking_87_max then co3.maxlivepositiontaking else @v161alivepositiontaking_87_max end else 0 end) as v161alivepositiontaking_87_max,
	max(case when co3.bettype = 89 and co3.sporttype=161 then case when co3.maxlivepositiontaking<@v161alivepositiontaking_89_max then co3.maxlivepositiontaking else @v161alivepositiontaking_89_max end else 0 end) as v161alivepositiontaking_89_max,
	max(case when co3.bettype = 90 and co3.sporttype=161 then case when co3.maxlivepositiontaking<@v161alivepositiontaking_90_max then co3.maxlivepositiontaking else @v161alivepositiontaking_90_max end else 0 end) as v161alivepositiontaking_90_max,
	

	-- Casino section
	ci.synccasino,
    ci.disablecasino,
    
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
	max(c.site) AS Site
    
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custsetting3rd as cs3 with (NOLOCK) on c.custid = cs3.custid
	INNER JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, SuspendInfo
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
	CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp
	--left join Custoverride3rd for sporttype = 164
	LEFT JOIN custoverride3rd as co3 with (NOLOCK) on co3.custid = cs3.custid and co3.sporttype=cs3.sporttype and co3.bettype=cs3.bettype
	INNER JOIN exchange with (NOLOCK) ON c.currency = exchange.exchangeid
where 
	c.roleid=2 and c.custid=@CustID and
	c.mrecommend=@MRecommend
group by 
	cps.closed, cps.reject, c.firstname, c.lastname, c.roleid, c.username,
	sp.SuperStatus, sp.MasterStatus,
	exchange.minbet, c.phone, c.mobilephone, c.email,c.fax,
	ci.maxpermatch,
	ci.maxpermatch2,
	ci.maxpermatch3,
	ci.maxpermatch5,
	ci.maxpermatch8,
	ci.maxpermatch10,
	ci.maxpermatch11,
	ci.maxpermatch99,
	ci.maxpermatch99MP,
	ci.maxpermatch1MP,

	ci.maxpermatch161,	
	ci.maxperball161,
	ci.maxpermatch164,
	ci.credit,
	-- Casino section
	ci.synccasino,
    ci.disablecasino

END
GO
