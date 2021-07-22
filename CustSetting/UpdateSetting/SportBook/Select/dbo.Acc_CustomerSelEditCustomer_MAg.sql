/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE  [dbo].[Acc_CustomerSelEditCustomer_MAg]
	@CustID int,
	@AgentID int
AS
BEGIN
/*
Created by: []
Date:[]
Task: MASTER EDIT MEMBER AT AGENT SITE
DB: DBCUST.CustDB
Revisions:
	- 20091117@Lee: add ci.synccasino
    - @PphuongDoan: remove '_1' on the SP name
    - 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
	- 20090806@Phuc: remove check m1=min(m3-a2,m1)
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100915@Lukas:	- Add number game setting
						- Add mixed sports setting
						- Remove mix parlay of basketball
	- 20100925@Lukas:	get UplineClosed & UplineSuspended
	- 20101103@Lukas: get max per ball(number game)
	- 20110114@Johnson: separate get setting from custsetting and custsetting3rd for performance
	- 20110801@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20120504@Johnson: correct m1 max
	- 20120830@Johnson: check um1_max = min(m3,m4,l3)
	- 20131011@Kathy: Add new sport: HR Fixed Odds (154) [Redmine:#6505]
	- 20140306@Johnson: fix bug m1_max =  m3-a1 not apply range !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1) [Redmine:#12953]
	- 20140701@Logan: Add BetRadar(9999) for Soccer and Tennis [Redmine:#18432]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210513@Tina: Lock account & indirect close account [redmine: #148600]

*/
SET NOCOUNT ON


---------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @srecommend INT, @mrecommend int, @recommend INT, @DisableAutoMPT bit--,@Msuspended bit, @UplineClosed bit, @UplineSuspended bit
select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend from custinfo with (NOLOCK) where custid = @custid
--select @Msuspended = isnull(reject,0) from custinfo with (nolock) where custid = @mrecommend
--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @mrecommend

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Declare 
	--s4
	@sp_1 smallmoney, @sp_2 smallmoney, @sp_3 smallmoney, @sp_4 smallmoney,
	@sp_5 smallmoney, @sp_6 smallmoney, @sp_7 smallmoney, @sp_8 smallmoney,
	@sp_9 smallmoney, @sp_10 smallmoney, @sp_9999 smallmoney,

	@slp_1 smallmoney, @slp_3 smallmoney, @slp_7 smallmoney, @slp_8 smallmoney,

	@v2sp_1 smallmoney, @v2sp_2 smallmoney, @v2sp_3 smallmoney, @v2sp_7 smallmoney,
	@v2sp_8 smallmoney, --	@v2sp_9 smallmoney, 
	@v2sp_20 smallmoney,
	@v2sp_9999 smallmoney,
	
	@v3sp_1 smallmoney, @v3sp_2 smallmoney, @v3sp_3 smallmoney, @v3sp_20 smallmoney,

	@v5sp_1 smallmoney, @v5sp_2 smallmoney, @v5sp_3 smallmoney, @v5sp_20 smallmoney,
	@v5sp_9999 smallmoney,

	@v8sp_1 smallmoney,  @v8sp_3 smallmoney, @v8sp_20 smallmoney,

	@v10sp_1 smallmoney, @v10sp_2 smallmoney, @v10sp_3 smallmoney, @v10sp_20 smallmoney,

	@v11sp_1 smallmoney, @v11sp_20 smallmoney,

	@v99sp_1 smallmoney, @v99sp_2 smallmoney, @v99sp_3 smallmoney, @v99sp_20 smallmoney,@v99sp_9999 smallmoney,

	-- mixed sports
	@v99sp_9 smallmoney,
	
	-- number game
	@v161sp_81 smallmoney, @v161sp_83 smallmoney, @v161sp_86 smallmoney, @v161sp_88 smallmoney,
	@v161slp_85 smallmoney, @v161slp_86 smallmoney, @v161slp_87 smallmoney,
	@v161slp_89 smallmoney, @v161slp_90 smallmoney,

	@max_mp_1 smallmoney, @max_mp_2 smallmoney, @max_mp_3 smallmoney, @max_mp_4 smallmoney,
	@max_mp_5 smallmoney, @max_mp_6 smallmoney, @max_mp_7 smallmoney, @max_mp_8 smallmoney,
	@max_mp_9 smallmoney, @max_mp_10 smallmoney, @max_mp_9999 smallmoney,

	@max_mlp_1 smallmoney,@max_mlp_3 smallmoney,@max_mlp_7 smallmoney,@max_mlp_8 smallmoney,

	@max_v2mp_1 smallmoney, @max_v2mp_2 smallmoney, @max_v2mp_3 smallmoney,
	@max_v2mp_7 smallmoney, @max_v2mp_8 smallmoney, --	@max_v2mp_9 smallmoney,
	@max_v2mp_20 smallmoney,@max_v2mp_9999 smallmoney,

	@max_v3mp_1 smallmoney, @max_v3mp_2 smallmoney, @max_v3mp_3 smallmoney, @max_v3mp_20 smallmoney,

	@max_v5mp_1 smallmoney, @max_v5mp_2 smallmoney, @max_v5mp_3 smallmoney, @max_v5mp_20 smallmoney,
    @max_v5mp_9999 smallmoney,

	@max_v8mp_1 smallmoney, @max_v8mp_3 smallmoney, @max_v8mp_20 smallmoney,

	@max_v10mp_1 smallmoney, @max_v10mp_2 smallmoney, @max_v10mp_3 smallmoney, @max_v10mp_20 smallmoney,

	@max_v11mp_1 smallmoney, @max_v11mp_20 smallmoney,

	@max_v99mp_1 smallmoney, @max_v99mp_2 smallmoney, @max_v99mp_3 smallmoney, @max_v99mp_20 smallmoney,@max_v99mp_9999 smallmoney,

	-- mixed sports
	@max_v99mp_9 smallmoney,
	
	-- number game
	@max_v161mp_81 smallmoney, @max_v161mp_83 smallmoney, @max_v161mp_86 smallmoney,
	@max_v161mp_88 smallmoney, @max_v161mlp_85 smallmoney, @max_v161mlp_86 smallmoney,
	@max_v161mlp_87 smallmoney, @max_v161mlp_89 smallmoney, @max_v161mlp_90 smallmoney,
	
	--im2
	@isauto_mpositiontaking_1 bit,
	@isauto_mpositiontaking_2 bit,
	@isauto_mpositiontaking_3 bit,
	@isauto_mpositiontaking_4 bit,
	@isauto_mpositiontaking_5 bit,
	@isauto_mpositiontaking_6 bit,
	@isauto_mpositiontaking_7 bit,
	@isauto_mpositiontaking_8 bit,
	@isauto_mpositiontaking_9 bit,
	@isauto_mpositiontaking_10 bit,
	@isauto_mpositiontaking_9999 bit,
	@isauto_mlivepositiontaking_1 bit,
	@isauto_mlivepositiontaking_3 bit,
	@isauto_mlivepositiontaking_7 bit,
	@isauto_mlivepositiontaking_8 bit,

	@isauto_v2mpositiontaking_1 bit,
	@isauto_v2mpositiontaking_2 bit,
	@isauto_v2mpositiontaking_3 bit,
	@isauto_v2mpositiontaking_7 bit,
	@isauto_v2mpositiontaking_8 bit,
--	@isauto_v2mpositiontaking_9 bit,
	@isauto_v2mpositiontaking_20 bit,
	@isauto_v2mpositiontaking_9999 bit,
	
	@isauto_v3mpositiontaking_1 bit,
	@isauto_v3mpositiontaking_2 bit,
	@isauto_v3mpositiontaking_3 bit,
	@isauto_v3mpositiontaking_20 bit,
	
	@isauto_v5mpositiontaking_1 bit,
	@isauto_v5mpositiontaking_2 bit,
	@isauto_v5mpositiontaking_3 bit,
	@isauto_v5mpositiontaking_20 bit,
	@isauto_v5mpositiontaking_9999 bit,
	
	@isauto_v8mpositiontaking_1 bit,
	@isauto_v8mpositiontaking_3 bit,
	@isauto_v8mpositiontaking_20 bit,
	
	@isauto_v10mpositiontaking_1 bit,
	@isauto_v10mpositiontaking_2 bit,
	@isauto_v10mpositiontaking_3 bit,
	@isauto_v10mpositiontaking_20 bit,
	
	@isauto_v11mpositiontaking_1 bit,
	@isauto_v11mpositiontaking_20 bit,

	@isauto_v99mpositiontaking_1 bit,
	@isauto_v99mpositiontaking_2 bit,
	@isauto_v99mpositiontaking_3 bit,
	@isauto_v99mpositiontaking_20 bit,
	@isauto_v99mpositiontaking_9999 bit,
	-- mixed sports
	@isauto_v99mpositiontaking_9 bit,

	-- number game
	@isauto_v161mpositiontaking_81 bit,
	@isauto_v161mpositiontaking_83 bit,
	@isauto_v161mpositiontaking_86 bit,
	@isauto_v161mpositiontaking_88 bit,
	@isauto_v161mlivepositiontaking_85 bit,
	@isauto_v161mlivepositiontaking_86 bit,
	@isauto_v161mlivepositiontaking_87 bit, 
	@isauto_v161mlivepositiontaking_89 bit,
	@isauto_v161mlivepositiontaking_90 bit,
	-- Outright PT
	@isauto_v2mpositiontaking_10 bit,
	@isauto_v3mpositiontaking_10 bit,
	@isauto_v5mpositiontaking_10 bit,
	@isauto_v8mpositiontaking_10 bit,
	@isauto_v10mpositiontaking_10 bit,
	@isauto_v11mpositiontaking_10 bit,
	@isauto_v99mpositiontaking_10 bit
	
	
--im2
Select 
	@isauto_mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_4 = max(case when acs.bettype = 4 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_5 = max(case when acs.bettype = 5 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_6 = max(case when acs.bettype = 6 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_7 = max(case when acs.bettype = 7 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_8 = max(case when acs.bettype = 8 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_9 = max(case when acs.bettype = 9 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	@isauto_mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	
	@isauto_v2mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v3mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=3 then acs.isautompositiontaking else 0 end),
	@isauto_v5mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),
	@isauto_v8mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=8 then acs.isautompositiontaking else 0 end),
	@isauto_v10mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=10 then acs.isautompositiontaking else 0 end),
	@isauto_v11mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=11 then acs.isautompositiontaking else 0 end),
	@isauto_v99mpositiontaking_10 = max(case when acs.bettype = 10 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	
	@isauto_mpositiontaking_9999 = max(case when acs.bettype = 9999 and acs.sporttype=1 then acs.isautompositiontaking else 0 end),
	
	@isauto_mlivepositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=1 then acs.isautolivempositiontaking else 0 end),
	@isauto_mlivepositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=1 then acs.isautolivempositiontaking else 0 end),
	@isauto_mlivepositiontaking_7 = max(case when acs.bettype = 7 and acs.sporttype=1 then acs.isautolivempositiontaking else 0 end),
	@isauto_mlivepositiontaking_8 = max(case when acs.bettype = 8 and acs.sporttype=1 then acs.isautolivempositiontaking else 0 end),

	@isauto_v2mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_7 = max(case when acs.bettype = 7 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_8 = max(case when acs.bettype = 8 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
--	@isauto_v2mpositiontaking_9 = max(case when acs.bettype = 9 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),
	@isauto_v2mpositiontaking_9999 = max(case when acs.bettype = 9999 and acs.sporttype=2 then acs.isautompositiontaking else 0 end),

	@isauto_v3mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=3 then acs.isautompositiontaking else 0 end),
	@isauto_v3mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=3 then acs.isautompositiontaking else 0 end),
	@isauto_v3mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=3 then acs.isautompositiontaking else 0 end),
	@isauto_v3mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=3 then acs.isautompositiontaking else 0 end),

	@isauto_v5mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),
	@isauto_v5mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),
	@isauto_v5mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),
	@isauto_v5mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),
	@isauto_v5mpositiontaking_9999 = max(case when acs.bettype = 9999 and acs.sporttype=5 then acs.isautompositiontaking else 0 end),

	@isauto_v8mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=8 then acs.isautompositiontaking else 0 end),
	@isauto_v8mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=8 then acs.isautompositiontaking else 0 end),
	@isauto_v8mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=8 then acs.isautompositiontaking else 0 end),

	@isauto_v10mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=10 then acs.isautompositiontaking else 0 end),
	@isauto_v10mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=10 then acs.isautompositiontaking else 0 end),
	@isauto_v10mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=10 then acs.isautompositiontaking else 0 end),
	@isauto_v10mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=10 then acs.isautompositiontaking else 0 end),

	@isauto_v11mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=11 then acs.isautompositiontaking else 0 end),
	@isauto_v11mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=11 then acs.isautompositiontaking else 0 end),

	@isauto_v99mpositiontaking_1 = max(case when acs.bettype = 1 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	@isauto_v99mpositiontaking_2 = max(case when acs.bettype = 2 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	@isauto_v99mpositiontaking_3 = max(case when acs.bettype = 3 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	@isauto_v99mpositiontaking_20 = max(case when acs.bettype = 20 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	@isauto_v99mpositiontaking_9999 = max(case when acs.bettype = 9999 and acs.sporttype=99 then acs.isautompositiontaking else 0 end),
	--- mixed sports
	@isauto_v99mpositiontaking_9 = max(case when acs.bettype = 9 and acs.sporttype=99 then acs.isautompositiontaking else 0 end)
	
From custinfo m with(nolock) inner join custsetting acs with(nolock) on m.recommend = acs.custid 							 
where m.custid = @AgentID 

SELECT
	@isauto_v161mpositiontaking_81 = max(case when acs3.bettype = 81 and acs3.sporttype=161 then acs3.isautompositiontaking else 0 end),
	@isauto_v161mpositiontaking_83 = max(case when acs3.bettype = 83 and acs3.sporttype=161 then acs3.isautompositiontaking else 0 end),
	@isauto_v161mpositiontaking_86 = max(case when acs3.bettype = 86 and acs3.sporttype=161 then acs3.isautompositiontaking else 0 end),
	@isauto_v161mpositiontaking_88 = max(case when acs3.bettype = 88 and acs3.sporttype=161 then acs3.isautompositiontaking else 0 end),
	@isauto_v161mlivepositiontaking_85 = max(case when acs3.bettype = 85 and acs3.sporttype=161 then acs3.isautolivempositiontaking else 0 end),
	@isauto_v161mlivepositiontaking_86 = max(case when acs3.bettype = 86 and acs3.sporttype=161 then acs3.isautolivempositiontaking else 0 end),
	@isauto_v161mlivepositiontaking_87 = max(case when acs3.bettype = 87 and acs3.sporttype=161 then acs3.isautolivempositiontaking else 0 end),
	@isauto_v161mlivepositiontaking_89 = max(case when acs3.bettype = 89 and acs3.sporttype=161 then acs3.isautolivempositiontaking else 0 end),
	@isauto_v161mlivepositiontaking_90 = max(case when acs3.bettype = 90 and acs3.sporttype=161 then acs3.isautolivempositiontaking else 0 end)

FROM 
	custinfo m with(nolock)
	inner join custsetting3rd acs3 with(nolock) on m.recommend = acs3.custid
WHERE m.custid = @AgentID


--@sp=s4
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
	@sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=1 then Scs.spositiontaking else 0 end),
	
	@slp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_7 = max(case when Scs.bettype = 7 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),
	@slp_8 = max(case when Scs.bettype = 8 and Scs.sporttype=1 then Scs.slivepositiontaking else 0 end),

	--v2	
	@v2sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_7 = max(case when Scs.bettype = 7 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_8 = max(case when Scs.bettype = 8 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
--	@v2sp_9 = max(case when Scs.bettype = 9 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),
	@v2sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=2 then Scs.spositiontaking else 0 end),

	--v3
	@v3sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),
	@v3sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=3 then Scs.spositiontaking else 0 end),

	--v5	
	@v5sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),
	@v5sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=5 then Scs.spositiontaking else 0 end),

	--v8
	@v8sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),
	@v8sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),
	@v8sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=8 then Scs.spositiontaking else 0 end),

	--v10
	@v10sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),
	@v10sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=10 then Scs.spositiontaking else 0 end),

	--v11
	@v11sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=11 then Scs.spositiontaking else 0 end),
	@v11sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=11 then Scs.spositiontaking else 0 end),

	--v99
	@v99sp_1 = max(case when Scs.bettype = 1 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_2 = max(case when Scs.bettype = 2 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_3 = max(case when Scs.bettype = 3 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_20 = max(case when Scs.bettype = 20 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	@v99sp_9999 = max(case when Scs.bettype = 9999 and Scs.sporttype=99 then Scs.spositiontaking else 0 end),
	-- mixed sports
	@v99sp_9 = max(case when Scs.bettype = 9 and Scs.sporttype=99 then Scs.spositiontaking else 0 end)

From CustSetting as Scs with (NOLOCK) 
where scs.CustID in (Select srecommend from custinfo with (NOLOCK) where CustID = @CustID)

SELECT
	--number game
	@v161sp_81 = max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.spositiontaking else 0 end),
	@v161sp_83 = max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.spositiontaking else 0 end),
	@v161sp_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.spositiontaking else 0 end),
	@v161sp_88 = max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.spositiontaking else 0 end),
	@v161slp_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end),
	@v161slp_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end),
	@v161slp_87 = max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end),
	@v161slp_89 = max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end),
	@v161slp_90 = max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.slivepositiontaking else 0 end)
FROM custsetting3rd cs3 with(nolock)
WHERE cs3.CustID in (Select srecommend from custinfo with (NOLOCK) where CustID = @CustID)

Declare 
	--m1_max
	@mapositiontaking_1_max smallmoney,
	@mapositiontaking_2_max smallmoney,
	@mapositiontaking_3_max smallmoney,
	@mapositiontaking_4_max smallmoney,
	@mapositiontaking_5_max smallmoney,
	@mapositiontaking_6_max smallmoney,
	@mapositiontaking_7_max smallmoney,
	@mapositiontaking_8_max smallmoney,
	@mapositiontaking_9_max smallmoney,
	@mapositiontaking_10_max smallmoney,
	@mapositiontaking_9999_max smallmoney,
	
	@malivepositiontaking_1_max smallmoney,
	@malivepositiontaking_3_max smallmoney,
	@malivepositiontaking_7_max smallmoney,
	@malivepositiontaking_8_max smallmoney,
	
	--v2
	@v2mapositiontaking_1_max smallmoney,
	@v2mapositiontaking_2_max smallmoney,
	@v2mapositiontaking_3_max smallmoney,
	@v2mapositiontaking_7_max smallmoney,
	@v2mapositiontaking_8_max smallmoney,
--	@v2mapositiontaking_9_max smallmoney,
	@v2mapositiontaking_20_max smallmoney,
	@v2mapositiontaking_9999_max smallmoney,

	--v3
	@v3mapositiontaking_1_max smallmoney,
	@v3mapositiontaking_2_max smallmoney,
	@v3mapositiontaking_3_max smallmoney,
	@v3mapositiontaking_20_max smallmoney,

	--v5
	@v5mapositiontaking_1_max smallmoney,
	@v5mapositiontaking_2_max smallmoney,
	@v5mapositiontaking_3_max smallmoney,
	@v5mapositiontaking_20_max smallmoney,
	@v5mapositiontaking_9999_max smallmoney,

	--v8
	@v8mapositiontaking_1_max smallmoney,
	@v8mapositiontaking_3_max smallmoney,
	@v8mapositiontaking_20_max smallmoney,

	--v10
	@v10mapositiontaking_1_max smallmoney,
	@v10mapositiontaking_2_max smallmoney,
	@v10mapositiontaking_3_max smallmoney,
	@v10mapositiontaking_20_max smallmoney,

	--v11
	@v11mapositiontaking_1_max smallmoney,
	@v11mapositiontaking_20_max smallmoney,

	--v99
	@v99mapositiontaking_1_max smallmoney,
	@v99mapositiontaking_2_max smallmoney,
	@v99mapositiontaking_3_max smallmoney,
	@v99mapositiontaking_20_max smallmoney,
	@v99mapositiontaking_9999_max smallmoney,
	-- mixed sports
	@v99mapositiontaking_9_max smallmoney,
	
	-- number game
	@v161mapositiontaking_81_max smallmoney,
	@v161mapositiontaking_83_max smallmoney,
	@v161mapositiontaking_86_max smallmoney,
	@v161mapositiontaking_88_max smallmoney,
	@v161malivepositiontaking_85_max smallmoney,
	@v161malivepositiontaking_86_max smallmoney,
	@v161malivepositiontaking_87_max smallmoney,
	@v161malivepositiontaking_89_max smallmoney,
	@v161malivepositiontaking_90_max smallmoney,
	--------------------------------------------------
	--min
	@mapositiontaking_1_min smallmoney,
	@mapositiontaking_2_min smallmoney,
	@mapositiontaking_3_min smallmoney,
	@mapositiontaking_4_min smallmoney,
	@mapositiontaking_5_min smallmoney,
	@mapositiontaking_6_min smallmoney,
	@mapositiontaking_7_min smallmoney,
	@mapositiontaking_8_min smallmoney,
	@mapositiontaking_9_min smallmoney,
	@mapositiontaking_10_min smallmoney,
	@mapositiontaking_9999_min smallmoney,
	
	@malivepositiontaking_1_min smallmoney,
	@malivepositiontaking_3_min smallmoney,
	@malivepositiontaking_7_min smallmoney,
	@malivepositiontaking_8_min smallmoney,
	
	--v2
	@v2mapositiontaking_1_min smallmoney,
	@v2mapositiontaking_2_min smallmoney,
	@v2mapositiontaking_3_min smallmoney,
	@v2mapositiontaking_7_min smallmoney,
	@v2mapositiontaking_8_min smallmoney,
--	@v2mapositiontaking_9_min smallmoney,
	@v2mapositiontaking_20_min smallmoney,
	@v2mapositiontaking_9999_min smallmoney,

	--v3
	@v3mapositiontaking_1_min smallmoney,
	@v3mapositiontaking_2_min smallmoney,
	@v3mapositiontaking_3_min smallmoney,
	@v3mapositiontaking_20_min smallmoney,

	--v5
	@v5mapositiontaking_1_min smallmoney,
	@v5mapositiontaking_2_min smallmoney,
	@v5mapositiontaking_3_min smallmoney,
	@v5mapositiontaking_20_min smallmoney,
	@v5mapositiontaking_9999_min smallmoney,

	--v8
	@v8mapositiontaking_1_min smallmoney,
	@v8mapositiontaking_3_min smallmoney,
	@v8mapositiontaking_20_min smallmoney,

	--v10
	@v10mapositiontaking_1_min smallmoney,
	@v10mapositiontaking_2_min smallmoney,
	@v10mapositiontaking_3_min smallmoney,
	@v10mapositiontaking_20_min smallmoney,

	--v11
	@v11mapositiontaking_1_min smallmoney,
	@v11mapositiontaking_20_min smallmoney,

	--v99
	@v99mapositiontaking_1_min smallmoney,
	@v99mapositiontaking_2_min smallmoney,
	@v99mapositiontaking_3_min smallmoney,
	@v99mapositiontaking_20_min smallmoney,
	@v99mapositiontaking_9999_min smallmoney,
	-- mixed sports
	@v99mapositiontaking_9_min smallmoney,	

	-- number game
	@v161mapositiontaking_81_min smallmoney,
	@v161mapositiontaking_83_min smallmoney,
	@v161mapositiontaking_86_min smallmoney,
	@v161mapositiontaking_88_min smallmoney,
	@v161malivepositiontaking_85_min smallmoney,
	@v161malivepositiontaking_86_min smallmoney,
	@v161malivepositiontaking_87_min smallmoney,
	@v161malivepositiontaking_89_min smallmoney,
	@v161malivepositiontaking_90_min smallmoney,
	
	-- Outright PT
	@v2mapositiontaking_10_max smallmoney,
	@v3mapositiontaking_10_max smallmoney,
	@v5mapositiontaking_10_max smallmoney,
	@v8mapositiontaking_10_max smallmoney,
	@v10mapositiontaking_10_max smallmoney,
	@v11mapositiontaking_10_max smallmoney,
	@v99mapositiontaking_10_max smallmoney,
	
	@v2mapositiontaking_10_min smallmoney,
	@v3mapositiontaking_10_min smallmoney,
	@v5mapositiontaking_10_min smallmoney,
	@v8mapositiontaking_10_min smallmoney,
	@v10mapositiontaking_10_min smallmoney,
	@v11mapositiontaking_10_min smallmoney,
	@v99mapositiontaking_10_min smallmoney
	
	

Select
	--@mapos_max=min(m3,l3)
	@mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	
	@v2mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v3mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v5mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v8mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v10mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v11mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v99mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	
	@mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	@malivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@malivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@malivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@malivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking<co.maxlivepositiontaking then cs.mlivepositiontaking else co.maxlivepositiontaking end else 0 end),

	--v2
	@v2mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
--	@v2mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v3
	@v3mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v3mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v3mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v3mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v5
	@v5mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v5mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v5mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v5mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v5mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v8
	@v8mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v8mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v8mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v10
	@v10mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v10mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v10mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v10mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v11
	@v11mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v11mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),

	--v99
	@v99mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v99mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v99mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v99mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v99mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	--mixed sports
	@v99mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),	
	
	--@mapos_min=n3
	@mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_4_min = max(case when co.bettype = 4 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_5_min = max(case when co.bettype = 5 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_6_min = max(case when co.bettype = 6 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=1 then co.minpositiontaking else 0 end),
	@mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=1 then co.minpositiontaking else 0 end),
	-- Outright PT
	@v2mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v3mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v5mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v8mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v10mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v11mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v99mapositiontaking_10_min = max(case when co.bettype = 10 and co.sporttype=99 then co.minpositiontaking else 0 end),
	
	@mapositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=1 then co.minpositiontaking else 0 end),

	@malivepositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@malivepositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@malivepositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=1 then co.minlivepositiontaking else 0 end),
	@malivepositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=1 then co.minlivepositiontaking else 0 end),

	--v2
	@v2mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_7_min = max(case when co.bettype = 7 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_8_min = max(case when co.bettype = 8 and co.sporttype=2 then co.minpositiontaking else 0 end),
--	@v2mapositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=2 then co.minpositiontaking else 0 end),
	@v2mapositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=2 then co.minpositiontaking else 0 end),

	--v3
	@v3mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=3 then co.minpositiontaking else 0 end),
	@v3mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=3 then co.minpositiontaking else 0 end),

	--v5
	@v5mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=5 then co.minpositiontaking else 0 end),
	@v5mapositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=5 then co.minpositiontaking else 0 end),

	--v8
	@v8mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=8 then co.minpositiontaking else 0 end),
	@v8mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=8 then co.minpositiontaking else 0 end),

	--v10
	@v10mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=10 then co.minpositiontaking else 0 end),
	@v10mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=10 then co.minpositiontaking else 0 end),

	--v11
	@v11mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=11 then co.minpositiontaking else 0 end),
	@v11mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=11 then co.minpositiontaking else 0 end),

	--v99
	@v99mapositiontaking_1_min = max(case when co.bettype = 1 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mapositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mapositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mapositiontaking_20_min = max(case when co.bettype = 20 and co.sporttype=99 then co.minpositiontaking else 0 end),
	@v99mapositiontaking_9999_min = max(case when co.bettype = 9999 and co.sporttype=99 then co.minpositiontaking else 0 end),
	-- mixed sports
	@v99mapositiontaking_9_min = max(case when co.bettype = 9 and co.sporttype=99 then co.minpositiontaking else 0 end)
From 
	CustSetting as cs with (NOLOCK)	
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID in (Select mRecommend from custinfo with (NOLOCK) where CustID = @AgentID)


SELECT
	-- number game
	@v161mapositiontaking_81_max = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.mpositiontaking<co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end),
	@v161mapositiontaking_83_max = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.mpositiontaking<co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end),	
	@v161mapositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mpositiontaking<co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end),
	@v161mapositiontaking_88_max = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.mpositiontaking<co3.maxpositiontaking then cs3.mpositiontaking else co3.maxpositiontaking end else 0 end),

	@v161malivepositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mlivepositiontaking<co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161malivepositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mlivepositiontaking<co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161malivepositiontaking_87_max = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.mlivepositiontaking<co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161malivepositiontaking_89_max = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.mlivepositiontaking<co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161malivepositiontaking_90_max = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.mlivepositiontaking<co3.maxlivepositiontaking then cs3.mlivepositiontaking else co3.maxlivepositiontaking end else 0 end),

	@v161mapositiontaking_81_min = max(case when co3.bettype = 81 and co3.sporttype=161 then co3.minpositiontaking else 0 end),
	@v161mapositiontaking_83_min = max(case when co3.bettype = 83 and co3.sporttype=161 then co3.minpositiontaking else 0 end),	
	@v161mapositiontaking_86_min = max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minpositiontaking else 0 end),
	@v161mapositiontaking_88_min = max(case when co3.bettype = 88 and co3.sporttype=161 then co3.minpositiontaking else 0 end),

	@v161malivepositiontaking_85_min = max(case when co3.bettype = 85 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end),
	@v161malivepositiontaking_86_min = max(case when co3.bettype = 86 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end),
	@v161malivepositiontaking_87_min = max(case when co3.bettype = 87 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end),
	@v161malivepositiontaking_89_min = max(case when co3.bettype = 89 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end),
	@v161malivepositiontaking_90_min = max(case when co3.bettype = 90 and co3.sporttype=161 then co3.minlivepositiontaking else 0 end)

FROM custsetting3rd cs3 with(nolock)
	LEFT JOIN custoverride3rd co3 with(nolock) on cs3.custid = co3.custid and cs3.sporttype = co3.sporttype and cs3.bettype = co3.bettype
Where cs3.CustID in (Select mRecommend from custinfo with (NOLOCK) where CustID = @AgentID)


Select
	--@mapos_max=min(m3,m4,l3)
	@mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_1_max then cs.mpositiontaking else @mapositiontaking_1_max end else 0 end),
	@mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_2_max then cs.mpositiontaking else @mapositiontaking_2_max end else 0 end),
	@mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_3_max then cs.mpositiontaking else @mapositiontaking_3_max end else 0 end),
	@mapositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_4_max then cs.mpositiontaking else @mapositiontaking_4_max end else 0 end),
	@mapositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_5_max then cs.mpositiontaking else @mapositiontaking_5_max end else 0 end),
	@mapositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_6_max then cs.mpositiontaking else @mapositiontaking_6_max end else 0 end),
	@mapositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_7_max then cs.mpositiontaking else @mapositiontaking_7_max end else 0 end),
	@mapositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_8_max then cs.mpositiontaking else @mapositiontaking_8_max end else 0 end),
	@mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_9_max then cs.mpositiontaking else @mapositiontaking_9_max end else 0 end),
	@mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_10_max then cs.mpositiontaking else @mapositiontaking_10_max end else 0 end),
	
	-- Outright PT
	@v2mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_10_max then cs.mpositiontaking else @v2mapositiontaking_10_max end else 0 end),
	@v3mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.mpositiontaking< @v3mapositiontaking_10_max then cs.mpositiontaking else @v3mapositiontaking_10_max end else 0 end),
	@v5mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_10_max then cs.mpositiontaking else @v5mapositiontaking_10_max end else 0 end),
	@v8mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.mpositiontaking< @v8mapositiontaking_10_max then cs.mpositiontaking else @v8mapositiontaking_10_max end else 0 end),
	@v10mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.mpositiontaking< @v10mapositiontaking_10_max then cs.mpositiontaking else @v10mapositiontaking_10_max end else 0 end),
	@v11mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.mpositiontaking< @v11mapositiontaking_10_max then cs.mpositiontaking else @v11mapositiontaking_10_max end else 0 end),
	@v99mapositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.mpositiontaking< @v99mapositiontaking_10_max then cs.mpositiontaking else @v99mapositiontaking_10_max end else 0 end),
	
	
	@mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.mpositiontaking< @mapositiontaking_9999_max then cs.mpositiontaking else @mapositiontaking_9999_max end else 0 end),

	@malivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.mlivepositiontaking< @malivepositiontaking_1_max then cs.mlivepositiontaking else @malivepositiontaking_1_max end else 0 end),
	@malivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.mlivepositiontaking< @malivepositiontaking_3_max then cs.mlivepositiontaking else @malivepositiontaking_3_max end else 0 end),
	@malivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.mlivepositiontaking< @malivepositiontaking_7_max then cs.mlivepositiontaking else @malivepositiontaking_7_max end else 0 end),
	@malivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.mlivepositiontaking< @malivepositiontaking_8_max then cs.mlivepositiontaking else @malivepositiontaking_8_max end else 0 end),

	--v2
	@v2mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_1_max then cs.mpositiontaking else @v2mapositiontaking_1_max end else 0 end),
	@v2mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_2_max then cs.mpositiontaking else @v2mapositiontaking_2_max end else 0 end),
	@v2mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_3_max then cs.mpositiontaking else @v2mapositiontaking_3_max end else 0 end),
	@v2mapositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_7_max then cs.mpositiontaking else @v2mapositiontaking_7_max end else 0 end),
	@v2mapositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_8_max then cs.mpositiontaking else @v2mapositiontaking_8_max end else 0 end),
--	@v2mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v2mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_20_max then cs.mpositiontaking else @v2mapositiontaking_20_max end else 0 end),
	@v2mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=2 then case when cs.mpositiontaking< @v2mapositiontaking_9999_max then cs.mpositiontaking else @v2mapositiontaking_9999_max end else 0 end),

	--v3
	@v3mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.mpositiontaking< @v3mapositiontaking_1_max then cs.mpositiontaking else @v3mapositiontaking_1_max end else 0 end),
	@v3mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.mpositiontaking< @v3mapositiontaking_2_max then cs.mpositiontaking else @v3mapositiontaking_2_max end else 0 end),
	@v3mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.mpositiontaking< @v3mapositiontaking_3_max then cs.mpositiontaking else @v3mapositiontaking_3_max end else 0 end),
	@v3mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.mpositiontaking< @v3mapositiontaking_20_max then cs.mpositiontaking else @v3mapositiontaking_20_max end else 0 end),

	--v5
	@v5mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_1_max then cs.mpositiontaking else @v5mapositiontaking_1_max end else 0 end),
	@v5mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_2_max then cs.mpositiontaking else @v5mapositiontaking_2_max end else 0 end),
	@v5mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_3_max then cs.mpositiontaking else @v5mapositiontaking_3_max end else 0 end),
	@v5mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_20_max then cs.mpositiontaking else @v5mapositiontaking_20_max end else 0 end),
	@v5mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.mpositiontaking< @v5mapositiontaking_9999_max then cs.mpositiontaking else @v5mapositiontaking_9999_max end else 0 end),

	--v8
	@v8mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.mpositiontaking< @v8mapositiontaking_1_max then cs.mpositiontaking else @v8mapositiontaking_1_max end else 0 end),
	@v8mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.mpositiontaking< @v8mapositiontaking_3_max then cs.mpositiontaking else @v8mapositiontaking_3_max end else 0 end),
	@v8mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.mpositiontaking< @v8mapositiontaking_20_max then cs.mpositiontaking else @v8mapositiontaking_20_max end else 0 end),

	--v10
	@v10mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.mpositiontaking< @v10mapositiontaking_1_max then cs.mpositiontaking else @v10mapositiontaking_1_max end else 0 end),
	@v10mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.mpositiontaking< @v10mapositiontaking_2_max then cs.mpositiontaking else @v10mapositiontaking_2_max end else 0 end),
	@v10mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.mpositiontaking< @v10mapositiontaking_3_max then cs.mpositiontaking else @v10mapositiontaking_3_max end else 0 end),
	@v10mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.mpositiontaking< @v10mapositiontaking_20_max then cs.mpositiontaking else @v10mapositiontaking_20_max end else 0 end),

	--v11
	@v11mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.mpositiontaking< @v11mapositiontaking_1_max then cs.mpositiontaking else @v11mapositiontaking_1_max end else 0 end),
	@v11mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.mpositiontaking< @v11mapositiontaking_20_max then cs.mpositiontaking else @v11mapositiontaking_20_max end else 0 end),

	--v99
	@v99mapositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.mpositiontaking<@v99mapositiontaking_1_max then cs.mpositiontaking else @v99mapositiontaking_1_max end else 0 end),
	@v99mapositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.mpositiontaking<@v99mapositiontaking_2_max then cs.mpositiontaking else @v99mapositiontaking_2_max end else 0 end),
	@v99mapositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.mpositiontaking<@v99mapositiontaking_3_max then cs.mpositiontaking else @v99mapositiontaking_3_max end else 0 end),
	@v99mapositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.mpositiontaking< @v99mapositiontaking_20_max then cs.mpositiontaking else @v99mapositiontaking_20_max end else 0 end),
	@v99mapositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=99 then case when cs.mpositiontaking< @v99mapositiontaking_9999_max then cs.mpositiontaking else @v99mapositiontaking_9999_max end else 0 end),
	--mixed sports
	@v99mapositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.mpositiontaking< @v99mapositiontaking_9_max then cs.mpositiontaking else @v99mapositiontaking_9_max end else 0 end)
FROM custsetting cs with(nolock)
WHERE custid IN (select srecommend from custinfo with(NOLOCK) where custid = @AgentID)	


SELECT
	-- number game
	@v161mapositiontaking_81_max = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.mpositiontaking< @v161mapositiontaking_81_max then cs3.mpositiontaking else @v161mapositiontaking_81_max end else 0 end),
	@v161mapositiontaking_83_max = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.mpositiontaking< @v161mapositiontaking_83_max then cs3.mpositiontaking else @v161mapositiontaking_83_max end else 0 end),	
	@v161mapositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mpositiontaking< @v161mapositiontaking_86_max then cs3.mpositiontaking else @v161mapositiontaking_86_max end else 0 end),
	@v161mapositiontaking_88_max = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.mpositiontaking< @v161mapositiontaking_88_max then cs3.mpositiontaking else @v161mapositiontaking_88_max end else 0 end),

	@v161malivepositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.mlivepositiontaking< @v161malivepositiontaking_85_max then cs3.mlivepositiontaking else @v161malivepositiontaking_85_max end else 0 end),
	@v161malivepositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.mlivepositiontaking< @v161malivepositiontaking_86_max then cs3.mlivepositiontaking else @v161malivepositiontaking_86_max end else 0 end),
	@v161malivepositiontaking_87_max = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.mlivepositiontaking< @v161malivepositiontaking_87_max then cs3.mlivepositiontaking else @v161malivepositiontaking_87_max end else 0 end),
	@v161malivepositiontaking_89_max = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.mlivepositiontaking< @v161malivepositiontaking_89_max then cs3.mlivepositiontaking else @v161malivepositiontaking_89_max end else 0 end),
	@v161malivepositiontaking_90_max = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.mlivepositiontaking< @v161malivepositiontaking_90_max then cs3.mlivepositiontaking else @v161malivepositiontaking_90_max end else 0 end)
FROM custsetting3rd cs3 with(nolock)	
Where cs3.CustID in (Select sRecommend from custinfo with (NOLOCK) where CustID = @AgentID)

/*
Select
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	@max_mp_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_4-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_4-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_5-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_5-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_6-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_6-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_7-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_7-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_8-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_8-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_9-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_9-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_mp_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@sp_10-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @sp_10-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	
	@max_mlp_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0) then mcs.mlivepositiontaking-cs.alivepositiontaking else case when mcs.mlivepositiontaking-cs.alivepositiontaking<=@slp_1-cs.slivepositiontaking-cs.alivepositiontaking then  mcs.mlivepositiontaking-cs.alivepositiontaking else @slp_1-cs.slivepositiontaking-cs.alivepositiontaking end end else 0 end),
	@max_mlp_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0) then mcs.mlivepositiontaking-cs.alivepositiontaking else case when mcs.mlivepositiontaking-cs.alivepositiontaking<=@slp_3-cs.slivepositiontaking-cs.alivepositiontaking then  mcs.mlivepositiontaking-cs.alivepositiontaking else @slp_3-cs.slivepositiontaking-cs.alivepositiontaking end end else 0 end),
	@max_mlp_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0) then mcs.mlivepositiontaking-cs.alivepositiontaking else case when mcs.mlivepositiontaking-cs.alivepositiontaking<=@slp_7-cs.slivepositiontaking-cs.alivepositiontaking then  mcs.mlivepositiontaking-cs.alivepositiontaking else @slp_7-cs.slivepositiontaking-cs.alivepositiontaking end end else 0 end),
	@max_mlp_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0) then mcs.mlivepositiontaking-cs.alivepositiontaking else case when mcs.mlivepositiontaking-cs.alivepositiontaking<=@slp_8-cs.slivepositiontaking-cs.alivepositiontaking then  mcs.mlivepositiontaking-cs.alivepositiontaking else @slp_8-cs.slivepositiontaking-cs.alivepositiontaking end end else 0 end),
	
	--v2
	@max_v2mp_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v2mp_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v2mp_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v2mp_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_7-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_7-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v2mp_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_8-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_8-cs.spositiontaking-cs.apositiontaking end end else 0 end),
--	@max_v2mp_9 = max(case when cs.bettype = 9 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_9-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_9-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v2mp_20 = max(case when cs.bettype = 20 and cs.sporttype=2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v2sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v2sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v3
	@max_v3mp_1 = max(case when cs.bettype = 1 and cs.sporttype=3 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v3sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v3sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v3mp_2 = max(case when cs.bettype = 2 and cs.sporttype=3 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v3sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v3sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v3mp_3 = max(case when cs.bettype = 3 and cs.sporttype=3 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v3sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v3sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v3mp_20 = max(case when cs.bettype = 20 and cs.sporttype=3 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v3sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v3sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v5
	@max_v5mp_1 = max(case when cs.bettype = 1 and cs.sporttype=5 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v5sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v5sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v5mp_2 = max(case when cs.bettype = 2 and cs.sporttype=5 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v5sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v5sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v5mp_3 = max(case when cs.bettype = 3 and cs.sporttype=5 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v5sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v5sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v5mp_20 = max(case when cs.bettype = 20 and cs.sporttype=5 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v5sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v5sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v8
	@max_v8mp_1 = max(case when cs.bettype = 1 and cs.sporttype=8 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v8sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v8sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v8mp_3 = max(case when cs.bettype = 3 and cs.sporttype=8 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v8sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v8sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v8mp_20 = max(case when cs.bettype = 20 and cs.sporttype=8 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v8sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v8sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v10
	@max_v10mp_1 = max(case when cs.bettype = 1 and cs.sporttype=10 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v10sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v10sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v10mp_2 = max(case when cs.bettype = 2 and cs.sporttype=10 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v10sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v10sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v10mp_3 = max(case when cs.bettype = 3 and cs.sporttype=10 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v10sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v10sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v10mp_20 = max(case when cs.bettype = 20 and cs.sporttype=10 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v10sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v10sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v11
	@max_v11mp_1 = max(case when cs.bettype = 1 and cs.sporttype=11 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v11sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v11sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v11mp_20 = max(case when cs.bettype = 20 and cs.sporttype=11 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v11sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v11sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	--v99
	@max_v99mp_1 = max(case when cs.bettype = 1 and cs.sporttype=99 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v99sp_1-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v99sp_1-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v99mp_2 = max(case when cs.bettype = 2 and cs.sporttype=99 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v99sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v99sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v99mp_3 = max(case when cs.bettype = 3 and cs.sporttype=99 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v99sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v99sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v99mp_20 = max(case when cs.bettype = 20 and cs.sporttype=99 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v99sp_20-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v99sp_20-cs.spositiontaking-cs.apositiontaking end end else 0 end),

	-- mixed sports
	@max_v99mp_9 = max(case when cs.bettype = 9 and cs.sporttype=99 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v99sp_9-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v99sp_9-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	
	
From CustSetting as cs with (NOLOCK) 
	inner join custinfo as c with (nolock) on cs.custid = c.custid
	inner join custsetting as mcs with (nolock) on mcs.custid = c.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
where cs.custid = @custid

--setting from custsetting3rd
SELECT
-- number game
	@max_v161mp_81 = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0) then mcs3.mpositiontaking-cs3.apositiontaking else case when mcs3.mpositiontaking-cs3.apositiontaking<=@v161sp_81-cs3.spositiontaking-cs3.apositiontaking then  mcs3.mpositiontaking-cs3.apositiontaking else @v161sp_81-cs3.spositiontaking-cs3.apositiontaking end end else 0 end),
	@max_v161mp_83 = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0) then mcs3.mpositiontaking-cs3.apositiontaking else case when mcs3.mpositiontaking-cs3.apositiontaking<=@v161sp_83-cs3.spositiontaking-cs3.apositiontaking then  mcs3.mpositiontaking-cs3.apositiontaking else @v161sp_83-cs3.spositiontaking-cs3.apositiontaking end end else 0 end),	
	@max_v161mp_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0) then mcs3.mpositiontaking-cs3.apositiontaking else case when mcs3.mpositiontaking-cs3.apositiontaking<=@v161sp_86-cs3.spositiontaking-cs3.apositiontaking then  mcs3.mpositiontaking-cs3.apositiontaking else @v161sp_86-cs3.spositiontaking-cs3.apositiontaking end end else 0 end),
	@max_v161mp_88 = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0) then mcs3.mpositiontaking-cs3.apositiontaking else case when mcs3.mpositiontaking-cs3.apositiontaking<=@v161sp_88-cs3.spositiontaking-cs3.apositiontaking then  mcs3.mpositiontaking-cs3.apositiontaking else @v161sp_88-cs3.spositiontaking-cs3.apositiontaking end end else 0 end),

	@max_v161mlp_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0) then mcs3.mlivepositiontaking-cs3.alivepositiontaking else case when mcs3.mlivepositiontaking-cs3.alivepositiontaking<=@v161slp_85-cs3.slivepositiontaking-cs3.alivepositiontaking then  mcs3.mlivepositiontaking-cs3.alivepositiontaking else @v161slp_85-cs3.slivepositiontaking-cs3.alivepositiontaking end end else 0 end),
	@max_v161mlp_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0) then mcs3.mlivepositiontaking-cs3.alivepositiontaking else case when mcs3.mlivepositiontaking-cs3.alivepositiontaking<=@v161slp_86-cs3.slivepositiontaking-cs3.alivepositiontaking then  mcs3.mlivepositiontaking-cs3.alivepositiontaking else @v161slp_86-cs3.slivepositiontaking-cs3.alivepositiontaking end end else 0 end),
	@max_v161mlp_87 = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0) then mcs3.mlivepositiontaking-cs3.alivepositiontaking else case when mcs3.mlivepositiontaking-cs3.alivepositiontaking<=@v161slp_87-cs3.slivepositiontaking-cs3.alivepositiontaking then  mcs3.mlivepositiontaking-cs3.alivepositiontaking else @v161slp_87-cs3.slivepositiontaking-cs3.alivepositiontaking end end else 0 end),
	@max_v161mlp_89 = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0) then mcs3.mlivepositiontaking-cs3.alivepositiontaking else case when mcs3.mlivepositiontaking-cs3.alivepositiontaking<=@v161slp_89-cs3.slivepositiontaking-cs3.alivepositiontaking then  mcs3.mlivepositiontaking-cs3.alivepositiontaking else @v161slp_89-cs3.slivepositiontaking-cs3.alivepositiontaking end end else 0 end),
	@max_v161mlp_90 = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0) then mcs3.mlivepositiontaking-cs3.alivepositiontaking else case when mcs3.mlivepositiontaking-cs3.alivepositiontaking<=@v161slp_90-cs3.slivepositiontaking-cs3.alivepositiontaking then  mcs3.mlivepositiontaking-cs3.alivepositiontaking else @v161slp_90-cs3.slivepositiontaking-cs3.alivepositiontaking end end else 0 end)
FROM 
	custsetting3rd cs3 with(nolock) 
	inner join custinfo as c with (nolock) on cs3.custid = c.custid	
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend AND mcs3.sporttype = cs3.sporttype AND mcs3.bettype = cs3.bettype
WHERE cs3.custid = @custid
*/

--SELECT @UplineClosed = closed, @UplineSuspended = reject  FROM custinfo WITH(NOLOCK) 
--WHERE custid = @agentid

DECLARE @playerdiscountMyanmarOdds DECIMAL(9,8)=0,
		@discountMyanmarOdds DECIMAL(9,8)=0,
		@adiscountMyanmarOdds DECIMAL(9,8)=0
		
DECLARE @IsMyanmarOdds BIT = 0

SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)

IF @IsMyanmarOdds = 1
BEGIN
	SET @playerdiscountMyanmarOdds = (SELECT playerdiscount FROM CustCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1)
	SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @recommend AND Sporttype = 1 AND Bettype = 1)
END
	
SELECT

	isnull(c.email,'') as email, 
	isnull(c.fax,'') as fax, 
	c.firstname, 
	c.lastname, c.username2,
	ci.maxpermatch, isnull(c.mobilephone,'') as mobilephone, 
	isnull(c.email,'') as email, 
	isnull(c.phone,'') as phone, 
	c.ugroup, c.username,  
	ci.maxpermatch2 as maxpermatchv2,
	ci.maxpermatch3 as maxpermatchv3,
	ci.maxpermatch5 as maxpermatchv5,
	ci.maxpermatch8 as maxpermatchv8,
	ci.maxpermatch10 as maxpermatchv10,
	ci.maxpermatch11 as maxpermatchv11,
	ci.maxpermatch99 as maxpermatchv99,
	ci.maxpermatch99mp as maxpermatchv99mp,
	ci.maxpermatch1mp as maxpermatchv1mp,	
	ci.maxpermatch161 as maxpermatchv161,
	ci.maxperball161 as maxperballv161,
	ci.maxpermatch164 as maxpermatchv164,
	exchange.minbet as defaultminbet, 
	cps.closed, 
	cps.reject as suspended, 
	ci.synccasino,
	sp.MasterStatus as Msuspended, 
	CASE WHEN (cl.SuperStatus + cl.MasterStatus + cl.AgentStatus) > 0 THEN 1 ELSE 0 END AS UplineClosed,
	CASE WHEN (sp.SuperStatus + sp.MasterStatus + sp.AgentStatus) > 0 THEN 1 ELSE 0 END AS UplineSuspended,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	ci.credit,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.minbet else 0 end) as minbet,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.maxbet else 0 end) as maxbet,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.discount else 0 end) as discount,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2, --1x2	

	-- For Myanmar Odds
	ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
	ISNULL(@playerdiscountMyanmarOdds,0) AS playerdiscountMyanmarOdds,
	ISNULL(@discountMyanmarOdds,0) discountMyanmarOdds ,


	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.playerdiscount else 0 end) as playerdiscount,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.playerdiscount else 0 end) as playerdiscountcs,
	
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.playerdiscount else 0 end) as playerdiscount1x2, --1x2

	--v2
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.minbet else 0 end) as minbetv2,
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.maxbet else 0 end) as maxbetv2,

	--v3
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.minbet else 0 end) as minbetv3,
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.maxbet else 0 end) as maxbetv3,
	
	--v5
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.minbet else 0 end) as minbetv5,
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.maxbet else 0 end) as maxbetv5,
	
	--v8
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.minbet else 0 end) as minbetv8,
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.maxbet else 0 end) as maxbetv8,

	--v10
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.minbet else 0 end) as minbetv10,
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.maxbet else 0 end) as maxbetv10,

	--v11
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.minbet else 0 end) as minbetv11,
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.maxbet else 0 end) as maxbetv11,

	--v99
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.minbet else 0 end) as minbetv99,
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.maxbet else 0 end) as maxbetv99,

	--- mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.minbet else 0 end) as minbetv99mp,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.maxbet else 0 end) as maxbetv99mp,

	--- SOCCER sports
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.minbet else 0 end) as minbetv1mp,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.maxbet else 0 end) as maxbetv1mp,
	

	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.minbet else 0 end) as minbetv161,
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.maxbet else 0 end) as maxbetv161,
	
	max(case when cs3.bettype = 8101 and cs3.sporttype=164 then cs3.minbet else 0 end) as minbetv164,
	max(case when cs3.bettype = 8101 and cs3.sporttype=164 then cs3.maxbet else 0 end) as maxbetv164,

	--a1,m1
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

	--v2
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_9,
 	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_20,
 	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_9999,
	
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_9999,
	--v3
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_20,
 	
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_20,

	--v5
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_9999,
 	
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_9999,

	--v8
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_20,
 	
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_20,

	--v10
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_20,
 	
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_20,

	--v11
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_20,
 	
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_20,

	--v99
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9999,
 	
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9999,

	-- mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_9,
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_9,

	
	
	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_83,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as v161apositiontaking_88,

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as v161alivepositiontaking_90,

	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_83,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.mpositiontaking else 0 end) as v161mpositiontaking_88,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.mlivepositiontaking else 0 end) as v161mlivepositiontaking_90,
	
	--------------------------------------------------------------------------------
	--m1_max = m3 - a1
	@mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_1,
	@mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_2, 
	@mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_3,
	@mapositiontaking_4_max - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_4,
	@mapositiontaking_5_max - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_5,
	@mapositiontaking_6_max - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_6,
	@mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_7,
	@mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_8,
	@mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end) as maxpos_9,
	
	@mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end)  as maxpos_10,
	
	@mapositiontaking_9999_max - max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end)  as maxpos_9999,
	@malivepositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as maxlpos_1,
	@malivepositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as maxlpos_3,
	@malivepositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as maxlpos_7,
	@malivepositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end) as maxlpos_8,

	--v2
	@v2mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_1,
	@v2mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_2,
	@v2mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_3,
	@v2mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_7,
	@v2mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_8,
--	@v2mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_9,
	@v2mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_20,
	@v2mapositiontaking_9999_max - max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end) as maxv2pos_9999,

	--v3
	@v3mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end) as maxv3pos_1,
	@v3mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end) as maxv3pos_2,
	@v3mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end) as maxv3pos_3,
	@v3mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end) as maxv3pos_20,

	--v5
	@v5mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end) as maxv5pos_1,
	@v5mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end) as maxv5pos_2,
	@v5mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end) as maxv5pos_3,
	@v5mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end) as maxv5pos_20,
	@v5mapositiontaking_9999_max - max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end) as maxv5pos_9999,

	--v8
	@v8mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end)  as maxv8pos_1,
	@v8mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end)  as maxv8pos_3,
	@v8mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end) as maxv8pos_20,

	--v10
	@v10mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end) as maxv10pos_1,
	@v10mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end) as maxv10pos_2,
	@v10mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end) as maxv10pos_3,
	@v10mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end) as maxv10pos_20,

	--v11
	@v11mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end) as maxv11pos_1,
	@v11mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end) as maxv11pos_20,

	--v99
	@v99mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_1,
	@v99mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_2,
	@v99mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_3,
	@v99mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_20,
	@v99mapositiontaking_9999_max - max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_9999,

	--- mixed sports
	@v99mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end) as maxv99pos_9,
	-- number game
	@v161mapositiontaking_81_max - max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as maxv161pos_81,
	@v161mapositiontaking_83_max - max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as maxv161pos_83,
	@v161mapositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as maxv161pos_86,
	@v161mapositiontaking_88_max - max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end) as maxv161pos_88,

	@v161malivepositiontaking_85_max - max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as maxv161lpos_85,
	@v161malivepositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as maxv161lpos_86,
	@v161malivepositiontaking_87_max - max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as maxv161lpos_87,
	@v161malivepositiontaking_89_max - max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as maxv161lpos_89,
	@v161malivepositiontaking_90_max - max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end) as maxv161lpos_90,
	------------------------------------------------------------------------------------------------------------------------------------
	
	/*
	--maxpos_1=min[@max_mp,min(m3,l3)-a1]
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	case when isnull(@max_mp_1, 0)  < @mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_1, 0)  else @mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_1,
	case when isnull(@max_mp_2, 0)  < @mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_2, 0)  else @mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_2, 
	case when isnull(@max_mp_3, 0)  < @mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_3, 0)  else @mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_3,
	case when isnull(@max_mp_4, 0)  < @mapositiontaking_4_max - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_4, 0)  else @mapositiontaking_4_max - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_4,
	case when isnull(@max_mp_5, 0)  < @mapositiontaking_5_max - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_5, 0)  else @mapositiontaking_5_max - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_5,
	case when isnull(@max_mp_6, 0)  < @mapositiontaking_6_max - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_6, 0)  else @mapositiontaking_6_max - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_6,
	case when isnull(@max_mp_7, 0)  < @mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_7, 0)  else @mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_7,
	case when isnull(@max_mp_8, 0)  < @mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_8, 0)  else @mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_8,
	case when isnull(@max_mp_9, 0)  < @mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_9, 0)  else @mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_9,
	case when isnull(@max_mp_10, 0)  < @mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end)  then isnull(@max_mp_10, 0)  else @mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as maxpos_10,
	case when isnull(@max_mlp_1, 0)  < @malivepositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  then isnull(@max_mlp_1, 0)  else @malivepositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as maxlpos_1,
	case when isnull(@max_mlp_3, 0)  < @malivepositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  then isnull(@max_mlp_3, 0)  else @malivepositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as maxlpos_3,
	case when isnull(@max_mlp_7, 0)  < @malivepositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  then isnull(@max_mlp_7, 0)  else @malivepositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as maxlpos_7,
	case when isnull(@max_mlp_8, 0)  < @malivepositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  then isnull(@max_mlp_8, 0)  else @malivepositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as maxlpos_8,

	--v2
	case when isnull(@max_v2mp_1, 0)  < @v2mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_1, 0)  else @v2mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_1,
	case when isnull(@max_v2mp_2, 0)  < @v2mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_2, 0)  else @v2mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_2,
	case when isnull(@max_v2mp_3, 0)  < @v2mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_3, 0)  else @v2mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_3,
	case when isnull(@max_v2mp_7, 0)  < @v2mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_7, 0)  else @v2mapositiontaking_7_max - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_7,
	case when isnull(@max_v2mp_8, 0)  < @v2mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_8, 0)  else @v2mapositiontaking_8_max - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_8,
--	case when isnull(@max_v2mp_9, 0)  < @v2mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_9, 0)  else @v2mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_9,
	case when isnull(@max_v2mp_20, 0)  < @v2mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end)  then isnull(@max_v2mp_20, 0)  else @v2mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as maxv2pos_20,

	--v3
	case when isnull(@max_v3mp_1, 0)  < @v3mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end)  then isnull(@max_v3mp_1, 0)  else @v3mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as maxv3pos_1,
	case when isnull(@max_v3mp_2, 0)  < @v3mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end)  then isnull(@max_v3mp_2, 0)  else @v3mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as maxv3pos_2,
	case when isnull(@max_v3mp_3, 0)  < @v3mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end)  then isnull(@max_v3mp_3, 0)  else @v3mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as maxv3pos_3,
	case when isnull(@max_v3mp_20, 0)  < @v3mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end)  then isnull(@max_v3mp_20, 0)  else @v3mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as maxv3pos_20,

	--v5
	case when isnull(@max_v5mp_1, 0)  < @v5mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end)  then isnull(@max_v5mp_1, 0)  else @v5mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as maxv5pos_1,
	case when isnull(@max_v5mp_2, 0)  < @v5mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end)  then isnull(@max_v5mp_2, 0)  else @v5mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as maxv5pos_2,
	case when isnull(@max_v5mp_3, 0)  < @v5mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end)  then isnull(@max_v5mp_3, 0)  else @v5mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as maxv5pos_3,
	case when isnull(@max_v5mp_20, 0)  < @v5mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end)  then isnull(@max_v5mp_20, 0)  else @v5mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as maxv5pos_20,

	--v8
	case when isnull(@max_v8mp_1, 0)  < @v8mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end)  then isnull(@max_v8mp_1, 0)  else @v8mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as maxv8pos_1,
	case when isnull(@max_v8mp_3, 0)  < @v8mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end)  then isnull(@max_v8mp_3, 0)  else @v8mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as maxv8pos_3,
	case when isnull(@max_v8mp_20, 0)  < @v8mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end)  then isnull(@max_v8mp_20, 0)  else @v8mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as maxv8pos_20,

	--v10
	case when isnull(@max_v10mp_1, 0)  < @v10mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end)  then isnull(@max_v10mp_1, 0)  else @v10mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as maxv10pos_1,
	case when isnull(@max_v10mp_2, 0)  < @v10mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end)  then isnull(@max_v10mp_2, 0)  else @v10mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as maxv10pos_2,
	case when isnull(@max_v10mp_3, 0)  < @v10mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end)  then isnull(@max_v10mp_3, 0)  else @v10mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as maxv10pos_3,
	case when isnull(@max_v10mp_20, 0)  < @v10mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end)  then isnull(@max_v10mp_20, 0)  else @v10mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as maxv10pos_20,

	--v11
	case when isnull(@max_v11mp_1, 0)  < @v11mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end)  then isnull(@max_v11mp_1, 0)  else @v11mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end)  end as maxv11pos_1,
	case when isnull(@max_v11mp_20, 0)  < @v11mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end)  then isnull(@max_v11mp_20, 0)  else @v11mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end)  end as maxv11pos_20,

	--v99
	case when isnull(@max_v99mp_1, 0)  < @v99mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end)  then isnull(@max_v99mp_1, 0)  else @v99mapositiontaking_1_max - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as maxv99pos_1,
	case when isnull(@max_v99mp_2, 0)  < @v99mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end)  then isnull(@max_v99mp_2, 0)  else @v99mapositiontaking_2_max - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as maxv99pos_2,
	case when isnull(@max_v99mp_3, 0)  < @v99mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end)  then isnull(@max_v99mp_3, 0)  else @v99mapositiontaking_3_max - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as maxv99pos_3,
	case when isnull(@max_v99mp_20, 0)  < @v99mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end)  then isnull(@max_v99mp_20, 0)  else @v99mapositiontaking_20_max - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as maxv99pos_20,

	--- mixed sports
	case when isnull(@max_v99mp_9, 0)  < @v99mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)  then isnull(@max_v99mp_9, 0)  else @v99mapositiontaking_9_max - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as maxv99pos_9,

	-- number game
	case when isnull(@max_v161mp_81, 0)  < @v161mapositiontaking_81_max - max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  then isnull(@max_v161mp_81, 0)  else @v161mapositiontaking_81_max - max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as maxv161pos_81,
	case when isnull(@max_v161mp_83, 0)  < @v161mapositiontaking_83_max - max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  then isnull(@max_v161mp_83, 0)  else @v161mapositiontaking_83_max - max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as maxv161pos_83,
	case when isnull(@max_v161mp_86, 0)  < @v161mapositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  then isnull(@max_v161mp_86, 0)  else @v161mapositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as maxv161pos_86,
	case when isnull(@max_v161mp_88, 0)  < @v161mapositiontaking_88_max - max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  then isnull(@max_v161mp_88, 0)  else @v161mapositiontaking_88_max - max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as maxv161pos_88,

	case when isnull(@max_v161mlp_85, 0)  < @v161malivepositiontaking_85_max - max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  then isnull(@max_v161mlp_85, 0)  else @v161malivepositiontaking_85_max - max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as maxv161lpos_85,
	case when isnull(@max_v161mlp_86, 0)  < @v161malivepositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  then isnull(@max_v161mlp_86, 0)  else @v161malivepositiontaking_86_max - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as maxv161lpos_86,
	case when isnull(@max_v161mlp_87, 0)  < @v161malivepositiontaking_87_max - max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  then isnull(@max_v161mlp_87, 0)  else @v161malivepositiontaking_87_max - max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as maxv161lpos_87,
	case when isnull(@max_v161mlp_89, 0)  < @v161malivepositiontaking_89_max - max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  then isnull(@max_v161mlp_89, 0)  else @v161malivepositiontaking_89_max - max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as maxv161lpos_89,
	case when isnull(@max_v161mlp_90, 0)  < @v161malivepositiontaking_90_max - max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  then isnull(@max_v161mlp_90, 0)  else @v161malivepositiontaking_90_max - max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as maxv161lpos_90,
	------------------------------------------------------------------------------------------------------------------------------------
	*/
	
	case when @mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_1,
	case when @mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_2, 
	case when @mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_3,
	case when @mapositiontaking_4_min - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_4_min - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_4,
	case when @mapositiontaking_5_min - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_5_min - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_5,
	case when @mapositiontaking_6_min - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_6_min - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_6,
	case when @mapositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_7,
	case when @mapositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_8,
	case when @mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_9,
	case when @mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_10,
	case when @mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end)  <0 then 0 else @mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end)  end as minpos_9999,
	case when @malivepositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  <0 then 0 else @malivepositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as minlpos_1,
	case when @malivepositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  <0 then 0 else @malivepositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as minlpos_3,
	case when @malivepositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  <0 then 0 else @malivepositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as minlpos_7,
	case when @malivepositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  <0 then 0 else @malivepositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end)  end as minlpos_8,
	
	--v2
	case when @v2mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_1,
	case when @v2mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_2,
	case when @v2mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_3,
	case when @v2mapositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_7_min - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_7,
	case when @v2mapositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_8_min - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_8,
--	case when @v2mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_9,
	case when @v2mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_20,
	case when @v2mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_9999,

	--v3
	case when @v3mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end)  <0 then 0 else @v3mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as minv3pos_1,
	case when @v3mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end)  <0 then 0 else @v3mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as minv3pos_2,
	case when @v3mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end)  <0 then 0 else @v3mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as minv3pos_3,
	case when @v3mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end)  <0 then 0 else @v3mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as minv3pos_20,

	--v5
	case when @v5mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_1,
	case when @v5mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_2,
	case when @v5mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_3,
	case when @v5mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_20,
	case when @v5mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_9999,

	--v8
	case when @v8mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end)  <0 then 0 else @v8mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as minv8pos_1,
	case when @v8mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end)  <0 then 0 else @v8mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as minv8pos_3,
	case when @v8mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end)  <0 then 0 else @v8mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as minv8pos_20,

	--v10
	case when @v10mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end)  <0 then 0 else @v10mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as minv10pos_1,
	case when @v10mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end)  <0 then 0 else @v10mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as minv10pos_2,
	case when @v10mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end)  <0 then 0 else @v10mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as minv10pos_3,
	case when @v10mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end)  <0 then 0 else @v10mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as minv10pos_20,

	--v11
	case when @v11mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end)  <0 then 0 else @v11mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end)  end as minv11pos_1,
	case when @v11mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end)  <0 then 0 else @v11mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end)  end as minv11pos_20,

	--v99
	case when @v99mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_1_min - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_1,
	case when @v99mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_2_min - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_2,
	case when @v99mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_3_min - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_3,
	case when @v99mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_20_min - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_20,
	case when @v99mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_9999_min - max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_9999,

	-- mixed sports
	case when @v99mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_9_min - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_9,
	
	-- number game
	case when @v161mapositiontaking_81_min - max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  <0 then 0 else @v161mapositiontaking_81_min - max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as minv161pos_81,
	case when @v161mapositiontaking_83_min - max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  <0 then 0 else @v161mapositiontaking_83_min - max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as minv161pos_83,
	case when @v161mapositiontaking_86_min - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  <0 then 0 else @v161mapositiontaking_86_min - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as minv161pos_86,
	case when @v161mapositiontaking_88_min - max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  <0 then 0 else @v161mapositiontaking_88_min - max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.apositiontaking else 0 end)  end as minv161pos_88,

	case when @v161malivepositiontaking_85_min - max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  <0 then 0 else @v161malivepositiontaking_85_min - max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as minv161lpos_85,
	case when @v161malivepositiontaking_86_min - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  <0 then 0 else @v161malivepositiontaking_86_min - max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as minv161lpos_86,
	case when @v161malivepositiontaking_87_min - max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  <0 then 0 else @v161malivepositiontaking_87_min - max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as minv161lpos_87,
	case when @v161malivepositiontaking_89_min - max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  <0 then 0 else @v161malivepositiontaking_89_min - max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as minv161lpos_89,
	case when @v161malivepositiontaking_90_min - max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  <0 then 0 else @v161malivepositiontaking_90_min - max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.alivepositiontaking else 0 end)  end as minv161lpos_90,

	--im2
	@isauto_mpositiontaking_1 	as	isauto_mpositiontaking_1,
	@isauto_mpositiontaking_2 	as	isauto_mpositiontaking_2,
	@isauto_mpositiontaking_3 	as	isauto_mpositiontaking_3,
	@isauto_mpositiontaking_4 	as	isauto_mpositiontaking_4,
	@isauto_mpositiontaking_5	as	isauto_mpositiontaking_5,
	@isauto_mpositiontaking_6 	as	isauto_mpositiontaking_6,
	@isauto_mpositiontaking_7 	as	isauto_mpositiontaking_7,
	@isauto_mpositiontaking_8 	as	isauto_mpositiontaking_8,
	@isauto_mpositiontaking_9 	as	isauto_mpositiontaking_9,
	@isauto_mpositiontaking_10 	as	isauto_mpositiontaking_10,
	@isauto_mpositiontaking_9999 	as	isauto_mpositiontaking_9999,
	@isauto_mlivepositiontaking_1 	as	isauto_mlivepositiontaking_1,
	@isauto_mlivepositiontaking_3 	as	isauto_mlivepositiontaking_3,
	@isauto_mlivepositiontaking_7 	as	isauto_mlivepositiontaking_7,
	@isauto_mlivepositiontaking_8 	as	isauto_mlivepositiontaking_8,
			
	@isauto_v2mpositiontaking_1 	as	isauto_v2mpositiontaking_1 ,
	@isauto_v2mpositiontaking_2 	as	isauto_v2mpositiontaking_2 ,
	@isauto_v2mpositiontaking_3 	as	isauto_v2mpositiontaking_3 ,
	@isauto_v2mpositiontaking_7 	as	isauto_v2mpositiontaking_7 ,
	@isauto_v2mpositiontaking_8 	as	isauto_v2mpositiontaking_8 ,
--	@isauto_v2mpositiontaking_9 	as	isauto_v2mpositiontaking_9 ,
	@isauto_v2mpositiontaking_20 	as	isauto_v2mpositiontaking_20 ,
	@isauto_v2mpositiontaking_9999 	as	isauto_v2mpositiontaking_9999 ,
			
	@isauto_v3mpositiontaking_1 	as	isauto_v3mpositiontaking_1 ,
	@isauto_v3mpositiontaking_2 	as	isauto_v3mpositiontaking_2 ,
	@isauto_v3mpositiontaking_3 	as	isauto_v3mpositiontaking_3 ,
	@isauto_v3mpositiontaking_20 	as	isauto_v3mpositiontaking_20 ,

			
	@isauto_v5mpositiontaking_1 	as	isauto_v5mpositiontaking_1 ,
	@isauto_v5mpositiontaking_2 	as	isauto_v5mpositiontaking_2 ,
	@isauto_v5mpositiontaking_3 	as	isauto_v5mpositiontaking_3 ,
	@isauto_v5mpositiontaking_20 	as	isauto_v5mpositiontaking_20 ,
	@isauto_v5mpositiontaking_9999 	as	isauto_v5mpositiontaking_9999 ,
			
	@isauto_v8mpositiontaking_1 	as	isauto_v8mpositiontaking_1 ,
	@isauto_v8mpositiontaking_3 	as	isauto_v8mpositiontaking_3 ,
	@isauto_v8mpositiontaking_20 	as	isauto_v8mpositiontaking_20 ,
			
	@isauto_v10mpositiontaking_1 	as	isauto_v10mpositiontaking_1 ,
	@isauto_v10mpositiontaking_2 	as	isauto_v10mpositiontaking_2 ,
	@isauto_v10mpositiontaking_3 	as	isauto_v10mpositiontaking_3 ,
	@isauto_v10mpositiontaking_20 	as	isauto_v10mpositiontaking_20 ,
			
	@isauto_v11mpositiontaking_1 	as	isauto_v11mpositiontaking_1 ,
	@isauto_v11mpositiontaking_20 	as	isauto_v11mpositiontaking_20 ,
			
	@isauto_v99mpositiontaking_1 	as	isauto_v99mpositiontaking_1 ,
	@isauto_v99mpositiontaking_2 	as	isauto_v99mpositiontaking_2 ,
	@isauto_v99mpositiontaking_3 	as	isauto_v99mpositiontaking_3 ,
	@isauto_v99mpositiontaking_20	as	isauto_v99mpositiontaking_20,
	@isauto_v99mpositiontaking_9999	as	isauto_v99mpositiontaking_9999,
	-- mixed sports
	@isauto_v99mpositiontaking_9 	as	isauto_v99mpositiontaking_9 ,

	-- number game
	@isauto_v161mpositiontaking_81 	as	isauto_v161mpositiontaking_81 ,
	@isauto_v161mpositiontaking_83 	as	isauto_v161mpositiontaking_83 ,
	@isauto_v161mpositiontaking_86 	as	isauto_v161mpositiontaking_86 ,
	@isauto_v161mpositiontaking_88 	as	isauto_v161mpositiontaking_88 ,
	@isauto_v161mlivepositiontaking_85 	as	isauto_v161mlivepositiontaking_85 ,
	@isauto_v161mlivepositiontaking_86 	as	isauto_v161mlivepositiontaking_86 ,
	@isauto_v161mlivepositiontaking_87 	as	isauto_v161mlivepositiontaking_87 ,
	@isauto_v161mlivepositiontaking_89 	as	isauto_v161mlivepositiontaking_89 ,
	@isauto_v161mlivepositiontaking_90 	as	isauto_v161mlivepositiontaking_90 ,

	--im1
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.isautompositiontaking else 0 end) as isauto_mpositiontaking_mem_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_mem_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_mem_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautolivempositiontaking else 0 end) as isauto_mlivepositiontaking_mem_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_9999,

	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_mem_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_9999,

	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_mem_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_mem_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_mem_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_mem_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_mem_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_9999,
	-- mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_9,
	
	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_mem_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_mem_83,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_mem_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.isautompositiontaking else 0 end) as isauto_v161mpositiontaking_mem_88,

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_mem_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_mem_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_mem_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_mem_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.isautolivempositiontaking else 0 end) as isauto_v161mlivepositiontaking_mem_90,
	
	--um1
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_10,
	max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.autompositiontaking else 0 end) as auto_mpositiontaking_mem_9999,

	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_mem_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_mem_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autolivempositiontaking else 0 end) as auto_mlivepositiontaking_mem_8,

	--v2	
	max(case when cs.bettype = 1 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_8,
--	max(case when cs.bettype = 9 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_9999,

	--v3
	max(case when cs.bettype = 1 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_mem_20,

	--v5	
	max(case when cs.bettype = 1 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_9999,

	--v8
	max(case when cs.bettype = 1 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_mem_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_mem_20,

	--v10
	max(case when cs.bettype = 1 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_mem_20,

	--v11
	max(case when cs.bettype = 1 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_mem_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_mem_20,

	--v99
	max(case when cs.bettype = 1 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_3,
	max(case when cs.bettype = 20 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_20,
	max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_9999,
	-- mixed sports
	max(case when cs.bettype = 9 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_9,	

	-- number game
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_mem_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_mem_83,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_mem_86,
	max(case when cs3.bettype = 88 and cs3.sporttype=161 then cs3.autompositiontaking else 0 end) as auto_v161mpositiontaking_mem_88,

	max(case when cs3.bettype = 85 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_mem_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_mem_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_mem_87,
	max(case when cs3.bettype = 89 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_mem_89,
	max(case when cs3.bettype = 90 and cs3.sporttype=161 then cs3.autolivempositiontaking else 0 end) as auto_v161mlivepositiontaking_mem_90,
	
	--um1_max
	isnull(@mapositiontaking_1_max,0) as maxauto_mpositiontaking_mem_1,
	isnull(@mapositiontaking_2_max,0) as maxauto_mpositiontaking_mem_2,
	isnull(@mapositiontaking_3_max,0) as maxauto_mpositiontaking_mem_3,
	isnull(@mapositiontaking_4_max,0) as maxauto_mpositiontaking_mem_4,
	isnull(@mapositiontaking_5_max,0) as maxauto_mpositiontaking_mem_5,
	isnull(@mapositiontaking_6_max,0) as maxauto_mpositiontaking_mem_6,
	isnull(@mapositiontaking_7_max,0) as maxauto_mpositiontaking_mem_7,
	isnull(@mapositiontaking_8_max,0) as maxauto_mpositiontaking_mem_8,
	isnull(@mapositiontaking_9_max,0) as maxauto_mpositiontaking_mem_9,
	isnull(@mapositiontaking_10_max,0) as maxauto_mpositiontaking_mem_10,
	isnull(@mapositiontaking_9999_max,0) as maxauto_mpositiontaking_mem_9999,
	
	isnull(@malivepositiontaking_1_max,0) as maxauto_mlivepositiontaking_mem_1,
	isnull(@malivepositiontaking_3_max,0) as maxauto_mlivepositiontaking_mem_3,
	isnull(@malivepositiontaking_7_max,0) as maxauto_mlivepositiontaking_mem_7,
	isnull(@malivepositiontaking_8_max,0) as maxauto_mlivepositiontaking_mem_8,
	
	--v2
	isnull(@v2mapositiontaking_1_max,0) as maxauto_v2mpositiontaking_mem_1,
	isnull(@v2mapositiontaking_2_max,0) as maxauto_v2mpositiontaking_mem_2,
	isnull(@v2mapositiontaking_3_max,0) as maxauto_v2mpositiontaking_mem_3,
	isnull(@v2mapositiontaking_7_max,0) as maxauto_v2mpositiontaking_mem_7,
	isnull(@v2mapositiontaking_8_max,0) as maxauto_v2mpositiontaking_mem_8,
--	isnull(@v2mapositiontaking_9_max,0) as maxauto_v2mpositiontaking_mem_9,
	isnull(@v2mapositiontaking_20_max,0) as maxauto_v2mpositiontaking_mem_20,
	isnull(@v2mapositiontaking_9999_max,0) as maxauto_v2mpositiontaking_mem_9999,
	--v3
	isnull(@v3mapositiontaking_1_max,0) as maxauto_v3mpositiontaking_mem_1,
	isnull(@v3mapositiontaking_2_max,0) as maxauto_v3mpositiontaking_mem_2,
	isnull(@v3mapositiontaking_3_max,0) as maxauto_v3mpositiontaking_mem_3,
	isnull(@v3mapositiontaking_20_max,0) as maxauto_v3mpositiontaking_mem_20,
	
	--v5
	isnull(@v5mapositiontaking_1_max,0) as maxauto_v5mpositiontaking_mem_1,
	isnull(@v5mapositiontaking_2_max,0) as maxauto_v5mpositiontaking_mem_2,
	isnull(@v5mapositiontaking_3_max,0) as maxauto_v5mpositiontaking_mem_3,
	isnull(@v5mapositiontaking_20_max,0) as maxauto_v5mpositiontaking_mem_20,
	isnull(@v5mapositiontaking_9999_max,0) as maxauto_v5mpositiontaking_mem_9999,
	
	--v8
	isnull(@v8mapositiontaking_1_max,0) as maxauto_v8mpositiontaking_mem_1,
	isnull(@v8mapositiontaking_3_max,0) as maxauto_v8mpositiontaking_mem_3,
	isnull(@v8mapositiontaking_20_max,0) as maxauto_v8mpositiontaking_mem_20,
	
	--v10
	isnull(@v10mapositiontaking_1_max,0) as maxauto_v10mpositiontaking_mem_1,
	isnull(@v10mapositiontaking_2_max,0) as maxauto_v10mpositiontaking_mem_2,
	isnull(@v10mapositiontaking_3_max,0) as maxauto_v10mpositiontaking_mem_3,
	isnull(@v10mapositiontaking_20_max,0) as maxauto_v10mpositiontaking_mem_20,
	
	--v11
	isnull(@v11mapositiontaking_1_max,0) as maxauto_v11mpositiontaking_mem_1,
	isnull(@v11mapositiontaking_20_max,0) as maxauto_v11mpositiontaking_mem_20,
	
	--v99
	isnull(@v99mapositiontaking_1_max,0) as maxauto_v99mpositiontaking_mem_1,
	isnull(@v99mapositiontaking_2_max,0) as maxauto_v99mpositiontaking_mem_2,
	isnull(@v99mapositiontaking_3_max,0) as maxauto_v99mpositiontaking_mem_3,
	isnull(@v99mapositiontaking_20_max,0) as maxauto_v99mpositiontaking_mem_20,
	isnull(@v99mapositiontaking_9999_max,0) as maxauto_v99mpositiontaking_mem_9999,
	-- mixed sports
	isnull(@v99mapositiontaking_9_max,0) as maxauto_v99mpositiontaking_mem_9,

	-- number game
	isnull(@v161mapositiontaking_81_max,0) as maxauto_v161mpositiontaking_mem_81,
	isnull(@v161mapositiontaking_83_max,0) as maxauto_v161mpositiontaking_mem_83,
	isnull(@v161mapositiontaking_86_max,0) as maxauto_v161mpositiontaking_mem_86,
	isnull(@v161mapositiontaking_88_max,0) as maxauto_v161mpositiontaking_mem_88,

	isnull(@v161malivepositiontaking_85_max,0) as maxauto_v161mlivepositiontaking_mem_85,
	isnull(@v161malivepositiontaking_86_max,0) as maxauto_v161mlivepositiontaking_mem_86,
	isnull(@v161malivepositiontaking_87_max,0) as maxauto_v161mlivepositiontaking_mem_87,
	isnull(@v161malivepositiontaking_89_max,0) as maxauto_v161mlivepositiontaking_mem_89,
	isnull(@v161malivepositiontaking_90_max,0) as maxauto_v161mlivepositiontaking_mem_90,
	
	-- Outright PT
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end) as v2apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end) as v3apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end) as v5apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end) as v8apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end) as v10apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end) as v11apositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end) as v99apositiontaking_10,

	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.mpositiontaking else 0 end) as v2mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.mpositiontaking else 0 end) as v3mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.mpositiontaking else 0 end) as v5mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.mpositiontaking else 0 end) as v8mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.mpositiontaking else 0 end) as v10mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.mpositiontaking else 0 end) as v11mpositiontaking_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.mpositiontaking else 0 end) as v99mpositiontaking_10,

	@v2mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end)  as maxv2pos_10,
	@v3mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end)  as maxv3pos_10,
	@v5mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end)  as maxv5pos_10,
	@v8mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end)  as maxv8pos_10,
	@v10mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end)  as maxv10pos_10,
	@v11mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end)  as maxv11pos_10,
	@v99mapositiontaking_10_max - max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end)  as maxv99pos_10,
	
	case when @v2mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end)  <0 then 0 else @v2mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end)  end as minv2pos_10,
	case when @v3mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end)  <0 then 0 else @v3mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end)  end as minv3pos_10,
	case when @v5mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end)  <0 then 0 else @v5mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end)  end as minv5pos_10,
	case when @v8mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end)  <0 then 0 else @v8mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end)  end as minv8pos_10,
	case when @v10mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end)  <0 then 0 else @v10mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end)  end as minv10pos_10,
	case when @v11mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end)  <0 then 0 else @v11mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end)  end as minv11pos_10,
	case when @v99mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end)  <0 then 0 else @v99mapositiontaking_10_min - max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end)  end as minv99pos_10,
	
	@isauto_v2mpositiontaking_10 	as	isauto_v2mpositiontaking_10,
	@isauto_v3mpositiontaking_10 	as	isauto_v3mpositiontaking_10,
	@isauto_v5mpositiontaking_10 	as	isauto_v5mpositiontaking_10,
	@isauto_v8mpositiontaking_10 	as	isauto_v8mpositiontaking_10,
	@isauto_v10mpositiontaking_10 	as	isauto_v10mpositiontaking_10,
	@isauto_v11mpositiontaking_10 	as	isauto_v11mpositiontaking_10,
	@isauto_v99mpositiontaking_10 	as	isauto_v99mpositiontaking_10,		
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.isautompositiontaking else 0 end) as isauto_v2mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.isautompositiontaking else 0 end) as isauto_v3mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.isautompositiontaking else 0 end) as isauto_v5mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.isautompositiontaking else 0 end) as isauto_v8mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.isautompositiontaking else 0 end) as isauto_v10mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.isautompositiontaking else 0 end) as isauto_v11mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.isautompositiontaking else 0 end) as isauto_v99mpositiontaking_mem_10,
	
	max(case when cs.bettype = 10 and cs.sporttype=2 then cs.autompositiontaking else 0 end) as auto_v2mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=3 then cs.autompositiontaking else 0 end) as auto_v3mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=5 then cs.autompositiontaking else 0 end) as auto_v5mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=8 then cs.autompositiontaking else 0 end) as auto_v8mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=10 then cs.autompositiontaking else 0 end) as auto_v10mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=11 then cs.autompositiontaking else 0 end) as auto_v11mpositiontaking_mem_10,
	max(case when cs.bettype = 10 and cs.sporttype=99 then cs.autompositiontaking else 0 end) as auto_v99mpositiontaking_mem_10,
	
	isnull(@v2mapositiontaking_10_max,0) as maxauto_v2mpositiontaking_mem_10,
	isnull(@v3mapositiontaking_10_max,0) as maxauto_v3mpositiontaking_mem_10,
	isnull(@v5mapositiontaking_10_max,0) as maxauto_v5mpositiontaking_mem_10,
	isnull(@v8mapositiontaking_10_max,0) as maxauto_v8mpositiontaking_mem_10,
	isnull(@v10mapositiontaking_10_max,0) as maxauto_v10mpositiontaking_mem_10,
	isnull(@v11mapositiontaking_10_max,0) as maxauto_v11mpositiontaking_mem_10,
	isnull(@v99mapositiontaking_10_max,0) as maxauto_v99mpositiontaking_mem_10,
	MAX(ag.Site) AS Site

FROM 
	customer as C with (nolock) 
	INNER JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid  = cs.custid
	inner join custsetting3rd cs3 with(nolock) on c.custid = cs3.custid 
	inner join exchange with (nolock) ON C.currency=exchange.exchangeid 
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, CloseInfo
										, SuspendInfo
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
	CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.CloseInfo)) AS cl
	CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp
	
WHERE c.custid=@custId AND c.recommend=@agentId
group by 
	c.email, c.fax, c.firstname, c.lastname,c.username2, ci.maxpermatch, 
	c.mobilephone, c.email, c.phone, c.ugroup, c.username,
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
	ci.maxpermatch164,
	exchange.minbet, cps.closed,cps.reject,ci.synccasino,ci.credit,
	sp.SuperStatus,sp.MasterStatus,sp.AgentStatus,
	cl.SuperStatus,cl.MasterStatus,cl.AgentStatus
END
GO
