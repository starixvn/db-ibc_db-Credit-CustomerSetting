/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE  [dbo].[Acc_CustomerSelEditCustomer_SAg]
	@CustID INT,  
	@AgentID INT  
AS   
/*
Created by: []
Date: []
Task: SUPPER EDIT MEMBER AT AGENT SITE 
DB: DBCUST.CustDB
Revisions:
	- 20091117@Lee: add ci.synccasino
    - @PphuongDoan: remove '_1' on the SP name
    - 20090515@PhuongDao: Add 1x2 Commission
    - 20090619@ThoNguyen: Get value Super IsAuto on Master
    - 20090804@Phuc: get max_s1 = min(s4,l4)-m3
    - 20091215@Kiwi: Remove HR (151) and Financials (201).
    - 20100905@Terry: 
					+ Add new number game (161)
					+ Add new mix sports (99MP)
					+ Remove mixparlay of Basketball
	- 20100925@Lukas:	get UplineClosed & UplineSuspended
	- 20101027@Lukas: add max per ball (number game)
	- 20110118@Johnson: Separate to get setting from custsetting and custsetting3rd for performance
	- 20110801@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20131014@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20140630@Johnson: Add bettype Others for soccer & tennis [Redmine #16903] 			
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
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
*/
BEGIN
	SET NOCOUNT ON  	  
	  
	DECLARE  
		--min(s4,l4) 
		@mspositiontaking_1_max SMALLMONEY,  
		@mspositiontaking_2_max SMALLMONEY,  
		@mspositiontaking_3_max SMALLMONEY,  
		@mspositiontaking_4_max SMALLMONEY,  
		@mspositiontaking_5_max SMALLMONEY,  
		@mspositiontaking_6_max SMALLMONEY,  
		@mspositiontaking_7_max SMALLMONEY,  
		@mspositiontaking_8_max SMALLMONEY,  
		@mspositiontaking_9_max SMALLMONEY,  
		@mspositiontaking_10_max SMALLMONEY,  
		@mspositiontaking_9999_max SMALLMONEY, 
		
		@mslivepositiontaking_1_max SMALLMONEY,  
		@mslivepositiontaking_3_max SMALLMONEY,  
		@mslivepositiontaking_7_max SMALLMONEY,  
		@mslivepositiontaking_8_max SMALLMONEY,  

		@v2mspositiontaking_1_max SMALLMONEY,  
		@v2mspositiontaking_2_max SMALLMONEY,  
		@v2mspositiontaking_3_max SMALLMONEY,  
		@v2mspositiontaking_7_max SMALLMONEY,  
		@v2mspositiontaking_8_max SMALLMONEY,  	
		@v2mspositiontaking_20_max SMALLMONEY,  
		@v2mspositiontaking_9999_max SMALLMONEY,  

		@v3mspositiontaking_1_max SMALLMONEY,  
		@v3mspositiontaking_2_max SMALLMONEY,  
		@v3mspositiontaking_3_max SMALLMONEY,   
		@v3mspositiontaking_20_max SMALLMONEY,  

		@v5mspositiontaking_1_max SMALLMONEY,  
		@v5mspositiontaking_2_max SMALLMONEY,  
		@v5mspositiontaking_3_max SMALLMONEY,   
		@v5mspositiontaking_20_max SMALLMONEY,  
		@v5mspositiontaking_9999_max SMALLMONEY,
		
		@v8mspositiontaking_1_max SMALLMONEY,  
		@v8mspositiontaking_3_max SMALLMONEY,   
		@v8mspositiontaking_20_max SMALLMONEY,  

		@v10mspositiontaking_1_max SMALLMONEY,  
		@v10mspositiontaking_2_max SMALLMONEY,  
		@v10mspositiontaking_3_max SMALLMONEY,   
		@v10mspositiontaking_20_max SMALLMONEY,  

		@v11mspositiontaking_1_max SMALLMONEY,  
		@v11mspositiontaking_20_max SMALLMONEY,  
		
		@v99mspositiontaking_1_max SMALLMONEY,  
		@v99mspositiontaking_2_max SMALLMONEY,  
		@v99mspositiontaking_3_max SMALLMONEY,   
		@v99mspositiontaking_20_max SMALLMONEY,	
		@v99mspositiontaking_9999_max SMALLMONEY,	
				
		@v99mspositiontaking_9_max SMALLMONEY,
		
		--m3
		@mpositiontaking_1 SMALLMONEY,  
		@mpositiontaking_2 SMALLMONEY,  
		@mpositiontaking_3 SMALLMONEY,  
		@mpositiontaking_4 SMALLMONEY,  
		@mpositiontaking_5 SMALLMONEY,  
		@mpositiontaking_6 SMALLMONEY,  
		@mpositiontaking_7 SMALLMONEY,  
		@mpositiontaking_8 SMALLMONEY,  
		@mpositiontaking_9 SMALLMONEY,  
		@mpositiontaking_10 SMALLMONEY,
		@mpositiontaking_9999 SMALLMONEY,   

		@mlivepositiontaking_1 SMALLMONEY,  
		@mlivepositiontaking_3 SMALLMONEY,  
		@mlivepositiontaking_7 SMALLMONEY,  
		@mlivepositiontaking_8 SMALLMONEY,  

		@v2mpositiontaking_1 SMALLMONEY,  
		@v2mpositiontaking_2 SMALLMONEY,  
		@v2mpositiontaking_3 SMALLMONEY,  
		@v2mpositiontaking_7 SMALLMONEY,  
		@v2mpositiontaking_8 SMALLMONEY,  	 
		@v2mpositiontaking_20 SMALLMONEY,  
		@v2mpositiontaking_9999 SMALLMONEY,  

		@v3mpositiontaking_1 SMALLMONEY,  
		@v3mpositiontaking_2 SMALLMONEY,  
		@v3mpositiontaking_3 SMALLMONEY,   
		@v3mpositiontaking_20 SMALLMONEY,  

		@v5mpositiontaking_1 SMALLMONEY,  
		@v5mpositiontaking_2 SMALLMONEY,  
		@v5mpositiontaking_3 SMALLMONEY,   
		@v5mpositiontaking_20 SMALLMONEY,  
		@v5mpositiontaking_9999 SMALLMONEY,   

		@v8mpositiontaking_1 SMALLMONEY,  
		@v8mpositiontaking_3 SMALLMONEY,   
		@v8mpositiontaking_20 SMALLMONEY,  

		@v10mpositiontaking_1 SMALLMONEY,  
		@v10mpositiontaking_2 SMALLMONEY,  
		@v10mpositiontaking_3 SMALLMONEY,   
		@v10mpositiontaking_20 SMALLMONEY,  

		@v11mpositiontaking_1 SMALLMONEY,  
		@v11mpositiontaking_20 SMALLMONEY,  
		
		@v99mpositiontaking_1 SMALLMONEY,  
		@v99mpositiontaking_2 SMALLMONEY,  
		@v99mpositiontaking_3 SMALLMONEY,   
		@v99mpositiontaking_20 SMALLMONEY,
		@v99mpositiontaking_9999 SMALLMONEY,				
		
		@v99mpositiontaking_9 SMALLMONEY,
		--n4
		@mspositiontaking_1_min SMALLMONEY,  
		@mspositiontaking_2_min SMALLMONEY,  
		@mspositiontaking_3_min SMALLMONEY,  
		@mspositiontaking_4_min SMALLMONEY,  
		@mspositiontaking_5_min SMALLMONEY,  
		@mspositiontaking_6_min SMALLMONEY,  
		@mspositiontaking_7_min SMALLMONEY,  
		@mspositiontaking_8_min SMALLMONEY,  
		@mspositiontaking_9_min SMALLMONEY,  
		@mspositiontaking_10_min SMALLMONEY, 
		@mspositiontaking_9999_min SMALLMONEY,   

		@mslivepositiontaking_1_min SMALLMONEY,  
		@mslivepositiontaking_3_min SMALLMONEY,  
		@mslivepositiontaking_7_min SMALLMONEY,  
		@mslivepositiontaking_8_min SMALLMONEY,  

		@v2mspositiontaking_1_min SMALLMONEY,  
		@v2mspositiontaking_2_min SMALLMONEY,  
		@v2mspositiontaking_3_min SMALLMONEY,  
		@v2mspositiontaking_7_min SMALLMONEY,  
		@v2mspositiontaking_8_min SMALLMONEY,  	 
		@v2mspositiontaking_20_min SMALLMONEY,  
		@v2mspositiontaking_9999_min SMALLMONEY,  

		@v3mspositiontaking_1_min SMALLMONEY,  
		@v3mspositiontaking_2_min SMALLMONEY,  
		@v3mspositiontaking_3_min SMALLMONEY,   
		@v3mspositiontaking_20_min SMALLMONEY,  

		@v5mspositiontaking_1_min SMALLMONEY,  
		@v5mspositiontaking_2_min SMALLMONEY,  
		@v5mspositiontaking_3_min SMALLMONEY,   
		@v5mspositiontaking_20_min SMALLMONEY, 
		@v5mspositiontaking_9999_min SMALLMONEY,   

		@v8mspositiontaking_1_min SMALLMONEY,  
		@v8mspositiontaking_3_min SMALLMONEY,   
		@v8mspositiontaking_20_min SMALLMONEY,  

		@v10mspositiontaking_1_min SMALLMONEY,  
		@v10mspositiontaking_2_min SMALLMONEY,  
		@v10mspositiontaking_3_min SMALLMONEY,   
		@v10mspositiontaking_20_min SMALLMONEY,  

		@v11mspositiontaking_1_min SMALLMONEY,  
		@v11mspositiontaking_20_min SMALLMONEY,

		@v99mspositiontaking_1_min SMALLMONEY,  
		@v99mspositiontaking_2_min SMALLMONEY,  
		@v99mspositiontaking_3_min SMALLMONEY,   
		@v99mspositiontaking_20_min SMALLMONEY, 
		@v99mspositiontaking_9999_min SMALLMONEY, 
		
		@v99mspositiontaking_9_min SMALLMONEY,  
		
		--i3
		@isauto_spositiontaking_1 bit ,
		@isauto_spositiontaking_2 bit ,
		@isauto_spositiontaking_3 bit ,
		@isauto_spositiontaking_4 bit ,
		@isauto_spositiontaking_5 bit,
		@isauto_spositiontaking_6 bit ,
		@isauto_spositiontaking_7 bit ,
		@isauto_spositiontaking_8 bit ,
		@isauto_spositiontaking_9 bit ,
		@isauto_spositiontaking_10 bit ,
		@isauto_spositiontaking_9999 bit ,
		@isauto_slivepositiontaking_1 bit ,
		@isauto_slivepositiontaking_3 bit ,
		@isauto_slivepositiontaking_7 bit ,
		@isauto_slivepositiontaking_8 bit ,
		
		@isauto_v2spositiontaking_1 bit ,
		@isauto_v2spositiontaking_2 bit ,
		@isauto_v2spositiontaking_3 bit ,
		@isauto_v2spositiontaking_7 bit ,
		@isauto_v2spositiontaking_8 bit ,	
		@isauto_v2spositiontaking_20 bit ,
		@isauto_v2spositiontaking_9999 bit ,
		
		@isauto_v3spositiontaking_1 bit ,
		@isauto_v3spositiontaking_2 bit ,
		@isauto_v3spositiontaking_3 bit ,
		@isauto_v3spositiontaking_20 bit ,
		
		@isauto_v5spositiontaking_1 bit ,
		@isauto_v5spositiontaking_2 bit ,
		@isauto_v5spositiontaking_3 bit ,
		@isauto_v5spositiontaking_20 bit ,
		@isauto_v5spositiontaking_9999 bit ,
		
		@isauto_v8spositiontaking_1 bit ,
		@isauto_v8spositiontaking_3 bit ,
		@isauto_v8spositiontaking_20 bit ,
		
		@isauto_v10spositiontaking_1 bit ,
		@isauto_v10spositiontaking_2 bit ,
		@isauto_v10spositiontaking_3 bit ,
		@isauto_v10spositiontaking_20 bit ,
		
		@isauto_v11spositiontaking_1 bit ,
		@isauto_v11spositiontaking_20 bit ,

		@isauto_v99spositiontaking_1 bit ,
		@isauto_v99spositiontaking_2 bit ,
		@isauto_v99spositiontaking_3 bit ,
		@isauto_v99spositiontaking_20 bit,
		@isauto_v99spositiontaking_9999 bit,				
		
		@isauto_v99spositiontaking_9 bit,
		
		--@Ssuspended BIT, 
		@AllowedCurr BIT,
		@CurrencyID INT,
		
		-- is upline close suspend
		--@UplineClosed bit,
		--@UplineSuspended bit,
		
		-- Out right PT
		@v2mspositiontaking_10_max SMALLMONEY,
		@v3mspositiontaking_10_max SMALLMONEY,
		@v5mspositiontaking_10_max SMALLMONEY,
		@v8mspositiontaking_10_max SMALLMONEY,
		@v10mspositiontaking_10_max SMALLMONEY,
		@v11mspositiontaking_10_max SMALLMONEY,
		@v99mspositiontaking_10_max SMALLMONEY,
		
		@v2mpositiontaking_10 SMALLMONEY,
		@v3mpositiontaking_10 SMALLMONEY,
		@v5mpositiontaking_10 SMALLMONEY,
		@v8mpositiontaking_10 SMALLMONEY,
		@v10mpositiontaking_10 SMALLMONEY,
		@v11mpositiontaking_10 SMALLMONEY,
		@v99mpositiontaking_10 SMALLMONEY,
		
		@isauto_v2spositiontaking_10 bit ,
		@isauto_v3spositiontaking_10 bit ,
		@isauto_v5spositiontaking_10 bit ,
		@isauto_v8spositiontaking_10 bit ,
		@isauto_v10spositiontaking_10 bit ,
		@isauto_v11spositiontaking_10 bit ,
		@isauto_v99spositiontaking_10 bit ,
		
		@v2mspositiontaking_10_min SMALLMONEY, 
		@v3mspositiontaking_10_min SMALLMONEY, 
		@v5mspositiontaking_10_min SMALLMONEY, 
		@v8mspositiontaking_10_min SMALLMONEY, 
		@v10mspositiontaking_10_min SMALLMONEY, 
		@v11mspositiontaking_10_min SMALLMONEY, 
		@v99mspositiontaking_10_min SMALLMONEY
		
		

	--i3,m3
	Select 
		@isauto_spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_4 = max(case when mcs.bettype = 4 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_5 = max(case when mcs.bettype = 5 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_6 = max(case when mcs.bettype = 6 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		-- Outright PT
		@isauto_v2spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v3spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v5spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v8spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v10spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v11spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),
		@isauto_v99spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		
		@isauto_spositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		
		@isauto_slivepositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_slivepositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_slivepositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_slivepositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),

		@isauto_v2spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2spositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2spositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),	
		@isauto_v2spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		
		@isauto_v2spositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),

		@isauto_v3spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),

		@isauto_v5spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5spositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),

		@isauto_v8spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v8spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v8spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),

		@isauto_v10spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),

		@isauto_v11spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),
		@isauto_v11spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),

		@isauto_v99spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99spositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99spositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		
		@isauto_v99spositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),

		
		--m3
		@mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_4 = MAX(CASE WHEN mcs.bettype = 4 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_5 = MAX(CASE WHEN mcs.bettype = 5 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_6 = MAX(CASE WHEN mcs.bettype = 6 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_9 = MAX(CASE WHEN mcs.bettype = 9 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		-- For Outright PT
		@v2mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v11mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpositiontaking_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		
		@mpositiontaking_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  

		@mlivepositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepositiontaking_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepositiontaking_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  

		@v2mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpositiontaking_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpositiontaking_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  	
		@v2mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		
		@v2mpositiontaking_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  

		@v3mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  

		@v5mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpositiontaking_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  

		@v8mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  

		@v10mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  

		@v11mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		@v11mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		
		@v99mpositiontaking_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpositiontaking_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpositiontaking_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),
		@v99mpositiontaking_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),
			
		@v99mpositiontaking_9 = MAX(CASE WHEN mcs.bettype = 9 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END)
		  
	From custinfo ci WITH(NOLOCK)
	 INNER JOIN custsetting mcs with (NOLOCK) ON mcs.custid = ci.mrecommend

	where ci.custid = @AgentID

	SELECT  
		--min(s4,l4)  
		@mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_4_max = MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_5_max = MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_6_max = MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_9_max = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		-- For Outright PT
		@v2mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v11mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		
		@mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@mslivepositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  

		@v2mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  	
		@v2mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		@v2mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v3mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v5mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v8mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v10mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v11mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v11mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		@v99mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
			
		@v99mspositiontaking_9_max = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		
		--n4  
		@mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_4_min = MAX(CASE WHEN co.bettype = 4 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_5_min = MAX(CASE WHEN co.bettype = 5 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_6_min = MAX(CASE WHEN co.bettype = 6 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_7_min = MAX(CASE WHEN co.bettype = 7 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_8_min = MAX(CASE WHEN co.bettype = 8 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_9_min = MAX(CASE WHEN co.bettype = 9 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		
		@v2mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v11mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_10_min = MAX(CASE WHEN co.bettype = 10 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		
		@mspositiontaking_9999_min = MAX(CASE WHEN co.bettype = 9999 AND co.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  

		@mslivepositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_7_min = MAX(CASE WHEN co.bettype = 7 AND co.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_8_min = MAX(CASE WHEN co.bettype = 8 AND co.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  

		@v2mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_7_min = MAX(CASE WHEN co.bettype = 7 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_8_min = MAX(CASE WHEN co.bettype = 8 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  	
		@v2mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  

		@v2mspositiontaking_9999_min = MAX(CASE WHEN co.bettype = 9999 AND co.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		
		@v3mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  

		@v5mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_9999_min = MAX(CASE WHEN co.bettype = 9999 AND co.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  

		@v8mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  

		@v10mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  

		@v11mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  
		@v11mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  

		@v99mspositiontaking_1_min = MAX(CASE WHEN co.bettype = 1 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_2_min = MAX(CASE WHEN co.bettype = 2 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_3_min = MAX(CASE WHEN co.bettype = 3 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_20_min = MAX(CASE WHEN co.bettype = 20 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),
		@v99mspositiontaking_9999_min = MAX(CASE WHEN co.bettype = 9999 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END),
			
		@v99mspositiontaking_9_min = MAX(CASE WHEN co.bettype = 9 AND co.sporttype=99 THEN co.minpositiontaking ELSE 0 END)
		 
	FROM 
		custinfo ci WITH(NOLOCK)  
		INNER JOIN CustSetting AS cs WITH (NOLOCK) ON ci.srecommend = cs.custid
		LEFT JOIN custoverride AS co WITH (NOLOCK) ON ci.srecommend = co.custid AND cs.sporttype=co.sporttype AND cs.bettype=co.bettype  

	WHERE ci.CustID = @AgentID


	SELECT @CurrencyID=currency FROM custinfo WITH (NOLOCK)
	WHERE custid = (SELECT srecommend FROM customer WITH (NOLOCK) WHERE custid = @custid )
	 
	DECLARE @playerdiscountMyanmarOdds DECIMAL(9,8)=0,
			@discountMyanmarOdds DECIMAL(9,8)=0,
			@adiscountMyanmarOdds DECIMAL(9,8)=0
			
	DECLARE @IsMyanmarOdds BIT = 0
	DECLARE @srecommend INT,@mrecommmend INT,@recommend INT 
	SELECT @srecommend=srecommend,@mrecommmend = mrecommend,@recommend = recommend FROM custInfo WITH (NOLOCK) WHERE custid = @CustID
	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)
	
	IF @IsMyanmarOdds = 1
	BEGIN
		SET @playerdiscountMyanmarOdds = (SELECT playerdiscount FROM CustCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1)
		SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @recommend AND Sporttype = 1 AND Bettype = 1)
		SET @adiscountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @mrecommmend AND Sporttype = 1 AND Bettype = 1)
	END

	DECLARE @minbet                 MONEY , 
        @maxbet                 MONEY , 
        @maxpermatch            MONEY , 
        @minbetv2               MONEY , 
        @maxbetv2               MONEY , 
        @maxpermatchv2          MONEY , 
        @minbetv3               MONEY , 
        @maxbetv3               MONEY , 
        @maxpermatchv3          MONEY , 
        @minbetv5               MONEY , 
        @maxbetv5               MONEY , 
        @maxpermatchv5          MONEY , 
        @minbetv8               MONEY , 
        @maxbetv8               MONEY , 
        @maxpermatchv8          MONEY , 
        @minbetv10              MONEY , 
        @maxbetv10              MONEY , 
        @maxpermatchv10         MONEY , 
        @minbetv11              MONEY , 
        @maxbetv11              MONEY , 
        @maxpermatchv11         MONEY , 
        @minbetv99              MONEY , 
        @maxbetv99              MONEY , 
        @maxpermatchv99         MONEY , 
        @minbetv99mp            MONEY , 
        @maxbetv99mp            MONEY , 
        @maxpermatchv99mp       MONEY , 
        @minbetv1mp             MONEY , 
        @maxbetv1mp             MONEY , 
        @maxpermatchv1mp        MONEY ,        
        @MaxPayoutPerMatch      MONEY , 
        @MaxPayoutPerMatchv2    MONEY , 
        @MaxPayoutPerMatchv3    MONEY , 
        @MaxPayoutPerMatchv5    MONEY , 
        @MaxPayoutPerMatchv8    MONEY , 
        @MaxPayoutPerMatchv10   MONEY , 
        @MaxPayoutPerMatchv11   MONEY , 
        @MaxPayoutPerMatchv99   MONEY , 
        @MaxPayoutPerMatchv99mp MONEY , 
        @MaxPayoutPerMatchv1mp  MONEY ,
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
		ISNULL(c.fax,'') AS fax, c.firstname, c.lastname,c.username2,   
		cps.reject AS suspended, 
		
		sp.SuperStatus AS Ssuspended,
		@AllowedCurr AS AllowedCurr,
		CASE WHEN (cl.SuperStatus + cl.MasterStatus + cl.AgentStatus) > 0 THEN 1 ELSE 0 END AS UplineClosed,
		CASE WHEN (sp.SuperStatus + sp.MasterStatus + sp.AgentStatus) > 0 THEN 1 ELSE 0 END  AS UplineSuspended,
		
		ISNULL(c.mobilephone,'') AS mobilephone, ISNULL(c.email,'') AS email, ISNULL(c.phone,'') AS phone, c.ugroup, c.username,  
		exchange.minbet AS defaultminbet, 
		cps.closed,
		cps.reject, 
		ci.credit,  
		
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.adiscount ELSE 0 END) AS adiscount,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.adiscount ELSE 0 END) AS adiscountcs,  
		--1x2 
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.adiscount ELSE 0 END) AS adiscount1x2,  
		
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.discount ELSE 0 END) AS discount,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.discount ELSE 0 END) AS discountcs,  
		--1x2
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.discount ELSE 0 END) AS discount1x2,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.playerdiscount ELSE 0 END) AS playerdiscount,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.playerdiscount ELSE 0 END) AS playerdiscountcs,  
		--1x2
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.playerdiscount ELSE 0 END) AS playerdiscount1x2,
				
		---- For MyanmarOdd
		ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
		ISNULL(@playerdiscountMyanmarOdds,0) AS playerdiscountMyanmarOdds,
		ISNULL(@discountMyanmarOdds,0) AS discountMyanmarOdds,
		ISNULL(@adiscountMyanmarOdds,0) AS adiscountMyanmarOdds,  
		--a1,m1,s1
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_4,  
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_5,  
		MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_6,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_8,  
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_9,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.apositiontaking ELSE 0 END) AS apositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_4,  
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_5,  
		MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_6,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_8,  
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_9,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.mpositiontaking ELSE 0 END) AS mpositiontaking_9999,   

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_4,  
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_5,  
		MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_6,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_8,  
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_9,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.spositiontaking ELSE 0 END) AS spositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.alivepositiontaking ELSE 0 END) AS alivepositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.alivepositiontaking ELSE 0 END) AS alivepositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.alivepositiontaking ELSE 0 END) AS alivepositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.alivepositiontaking ELSE 0 END) AS alivepositiontaking_8,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.mlivepositiontaking ELSE 0 END) AS mlivepositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.mlivepositiontaking ELSE 0 END) AS mlivepositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.mlivepositiontaking ELSE 0 END) AS mlivepositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.mlivepositiontaking ELSE 0 END) AS mlivepositiontaking_8,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.slivepositiontaking ELSE 0 END) AS slivepositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.slivepositiontaking ELSE 0 END) AS slivepositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.slivepositiontaking ELSE 0 END) AS slivepositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.slivepositiontaking ELSE 0 END) AS slivepositiontaking_8,  

		--basketball  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_8,  	  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_20,  
		
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_8,  	
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_20,  
		
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_8,  	
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_20,  
		
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_9999,  

		--football  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.apositiontaking ELSE 0 END) AS v3apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.apositiontaking ELSE 0 END) AS v3apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.apositiontaking ELSE 0 END) AS v3apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.apositiontaking ELSE 0 END) AS v3apositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.mpositiontaking ELSE 0 END) AS v3mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.mpositiontaking ELSE 0 END) AS v3mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.mpositiontaking ELSE 0 END) AS v3mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.mpositiontaking ELSE 0 END) AS v3mpositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.spositiontaking ELSE 0 END) AS v3spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.spositiontaking ELSE 0 END) AS v3spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.spositiontaking ELSE 0 END) AS v3spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.spositiontaking ELSE 0 END) AS v3spositiontaking_20,  

		--Tennis  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_9999,  

		--baseball  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.apositiontaking ELSE 0 END) AS v8apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.apositiontaking ELSE 0 END) AS v8apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.apositiontaking ELSE 0 END) AS v8apositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.mpositiontaking ELSE 0 END) AS v8mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.mpositiontaking ELSE 0 END) AS v8mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.mpositiontaking ELSE 0 END) AS v8mpositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.spositiontaking ELSE 0 END) AS v8spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.spositiontaking ELSE 0 END) AS v8spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.spositiontaking ELSE 0 END) AS v8spositiontaking_20,  

		--Golf  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.apositiontaking ELSE 0 END) AS v10apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.apositiontaking ELSE 0 END) AS v10apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.apositiontaking ELSE 0 END) AS v10apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.apositiontaking ELSE 0 END) AS v10apositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.mpositiontaking ELSE 0 END) AS v10mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.mpositiontaking ELSE 0 END) AS v10mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.mpositiontaking ELSE 0 END) AS v10mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.mpositiontaking ELSE 0 END) AS v10mpositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.spositiontaking ELSE 0 END) AS v10spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.spositiontaking ELSE 0 END) AS v10spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.spositiontaking ELSE 0 END) AS v10spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.spositiontaking ELSE 0 END) AS v10spositiontaking_20,  

		--Motorsports  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.apositiontaking ELSE 0 END) AS v11apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.apositiontaking ELSE 0 END) AS v11apositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.mpositiontaking ELSE 0 END) AS v11mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.mpositiontaking ELSE 0 END) AS v11mpositiontaking_20,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.spositiontaking ELSE 0 END) AS v11spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.spositiontaking ELSE 0 END) AS v11spositiontaking_20,  

		--Finacial  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=201 THEN cs.apositiontaking ELSE 0 END) AS v201apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=201 THEN cs.apositiontaking ELSE 0 END) AS v201apositiontaking_3,  

		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=201 THEN cs.mpositiontaking ELSE 0 END) AS v201mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=201 THEN cs.mpositiontaking ELSE 0 END) AS v201mpositiontaking_3,  

		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=201 THEN cs.spositiontaking ELSE 0 END) AS v201spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=201 THEN cs.spositiontaking ELSE 0 END) AS v201spositiontaking_3,  

		--Golf  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_20, 
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_9999,  			
		
		-- Mix Sports
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_9,  	
		
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_9,  
		
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_9,  
		
		--s1_max=min(s4,l4)-m3
		ISNULL(@mspositiontaking_1_max, 0) - ISNULL(@mpositiontaking_1,0) AS maxpos_1,  
		ISNULL(@mspositiontaking_2_max, 0) - ISNULL(@mpositiontaking_2,0) AS maxpos_2,  
		ISNULL(@mspositiontaking_3_max, 0) - ISNULL(@mpositiontaking_3,0) AS maxpos_3,  
		ISNULL(@mspositiontaking_4_max, 0) - ISNULL(@mpositiontaking_4,0) AS maxpos_4,  
		ISNULL(@mspositiontaking_5_max, 0) - ISNULL(@mpositiontaking_5,0) AS maxpos_5,  
		ISNULL(@mspositiontaking_6_max, 0) - ISNULL(@mpositiontaking_6,0) AS maxpos_6,  
		ISNULL(@mspositiontaking_7_max, 0) - ISNULL(@mpositiontaking_7,0) AS maxpos_7,  
		ISNULL(@mspositiontaking_8_max, 0) - ISNULL(@mpositiontaking_8,0) AS maxpos_8,  
		ISNULL(@mspositiontaking_9_max, 0) - ISNULL(@mpositiontaking_9,0) AS maxpos_9,  
		ISNULL(@mspositiontaking_10_max, 0) - ISNULL(@mpositiontaking_10,0) AS maxpos_10,  
		ISNULL(@mspositiontaking_9999_max, 0) - ISNULL(@mpositiontaking_9999,0) AS maxpos_9999,  

		ISNULL(@mslivepositiontaking_1_max, 0) - ISNULL(@mlivepositiontaking_1,0) AS maxlpos_1,  
		ISNULL(@mslivepositiontaking_3_max, 0) - ISNULL(@mlivepositiontaking_3,0) AS maxlpos_3,  
		ISNULL(@mslivepositiontaking_7_max, 0) - ISNULL(@mlivepositiontaking_7,0) AS maxlpos_7,  
		ISNULL(@mslivepositiontaking_8_max, 0) - ISNULL(@mlivepositiontaking_8,0) AS maxlpos_8,  

		--basketball  
		ISNULL(@v2mspositiontaking_1_max, 0) - ISNULL(@v2mpositiontaking_1, 0) AS maxv2pos_1,  
		ISNULL(@v2mspositiontaking_2_max, 0) - ISNULL(@v2mpositiontaking_2, 0) AS maxv2pos_2,  
		ISNULL(@v2mspositiontaking_3_max, 0) - ISNULL(@v2mpositiontaking_3, 0) AS maxv2pos_3,  
		ISNULL(@v2mspositiontaking_7_max, 0) - ISNULL(@v2mpositiontaking_7, 0) AS maxv2pos_7,  
		ISNULL(@v2mspositiontaking_8_max, 0) - ISNULL(@v2mpositiontaking_8, 0) AS maxv2pos_8,  	
		ISNULL(@v2mspositiontaking_20_max, 0) - ISNULL(@v2mpositiontaking_20, 0) AS maxv2pos_20,  
		ISNULL(@v2mspositiontaking_9999_max, 0) - ISNULL(@v2mpositiontaking_9999, 0) AS maxv2pos_9999,  
		
		--football  
		ISNULL(@v3mspositiontaking_1_max, 0) - ISNULL(@v3mpositiontaking_1,0) AS maxv3pos_1,  
		ISNULL(@v3mspositiontaking_2_max, 0) - ISNULL(@v3mpositiontaking_2,0) AS maxv3pos_2,  
		ISNULL(@v3mspositiontaking_3_max, 0) - ISNULL(@v3mpositiontaking_3,0) AS maxv3pos_3,  
		ISNULL(@v3mspositiontaking_20_max, 0) - ISNULL(@v3mpositiontaking_20,0) AS maxv3pos_20,  

		--tennis  
		ISNULL(@v5mspositiontaking_1_max, 0) - ISNULL(@v5mpositiontaking_1,0) AS maxv5pos_1,  
		ISNULL(@v5mspositiontaking_2_max, 0) - ISNULL(@v5mpositiontaking_2,0) AS maxv5pos_2,  
		ISNULL(@v5mspositiontaking_3_max, 0) - ISNULL(@v5mpositiontaking_3,0) AS maxv5pos_3,  
		ISNULL(@v5mspositiontaking_20_max, 0) - ISNULL(@v5mpositiontaking_20,0) AS maxv5pos_20,  
		ISNULL(@v5mspositiontaking_9999_max, 0) - ISNULL(@v5mpositiontaking_9999,0) AS maxv5pos_9999,  
		
		--baseball  
		ISNULL(@v8mspositiontaking_1_max, 0) - ISNULL(@v8mpositiontaking_1,0) AS maxv8pos_1,  
		ISNULL(@v8mspositiontaking_3_max, 0) - ISNULL(@v8mpositiontaking_3,0) AS maxv8pos_3,  
		ISNULL(@v8mspositiontaking_20_max, 0) - ISNULL(@v8mpositiontaking_20,0) AS maxv8pos_20,  
		
		--Golf  
		ISNULL(@v10mspositiontaking_1_max, 0) - ISNULL(@v10mpositiontaking_1,0) AS maxv10pos_1,  
		ISNULL(@v10mspositiontaking_2_max, 0) - ISNULL(@v10mpositiontaking_2,0) AS maxv10pos_2,  
		ISNULL(@v10mspositiontaking_3_max, 0) - ISNULL(@v10mpositiontaking_3,0) AS maxv10pos_3,  
		ISNULL(@v10mspositiontaking_20_max, 0) - ISNULL(@v10mpositiontaking_20,0) AS maxv10pos_20,  
		
		--motorsports  
		ISNULL(@v11mspositiontaking_1_max, 0) - ISNULL(@v11mpositiontaking_1,0) AS maxv11pos_1,  
		ISNULL(@v11mspositiontaking_20_max, 0) - ISNULL(@v11mpositiontaking_20,0) AS maxv11pos_20,  
		
		--others  
		ISNULL(@v99mspositiontaking_1_max, 0) - ISNULL(@v99mpositiontaking_1,0) AS maxv99pos_1,  
		ISNULL(@v99mspositiontaking_2_max, 0) - ISNULL(@v99mpositiontaking_2,0) AS maxv99pos_2,  
		ISNULL(@v99mspositiontaking_3_max, 0) - ISNULL(@v99mpositiontaking_3,0) AS maxv99pos_3,  
		ISNULL(@v99mspositiontaking_20_max, 0) - ISNULL(@v99mpositiontaking_20,0) AS maxv99pos_20,  
		ISNULL(@v99mspositiontaking_9999_max, 0) - ISNULL(@v99mpositiontaking_9999,0) AS maxv99pos_9999,  		

		-- Mix Sports
		ISNULL(@v99mspositiontaking_9_max, 0) - ISNULL(@v99mpositiontaking_9,0) AS maxv99pos_9,  

		--u1
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_4,  
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_5,  
		MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_6,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_8,  
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_9,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.autopositiontaking ELSE 0 END) AS auto_spositiontaking_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.autolivepositiontaking ELSE 0 END) AS auto_slivepositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.autolivepositiontaking ELSE 0 END) AS auto_slivepositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.autolivepositiontaking ELSE 0 END) AS auto_slivepositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.autolivepositiontaking ELSE 0 END) AS auto_slivepositiontaking_8,  

		--basketball  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_8,  	
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_9999,  

		--football  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.autopositiontaking ELSE 0 END) AS auto_v3spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.autopositiontaking ELSE 0 END) AS auto_v3spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.autopositiontaking ELSE 0 END) AS auto_v3spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.autopositiontaking ELSE 0 END) AS auto_v3spositiontaking_20,  

		--tennis  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_9999,  

		--baseball  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.autopositiontaking ELSE 0 END) AS auto_v8spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.autopositiontaking ELSE 0 END) AS auto_v8spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.autopositiontaking ELSE 0 END) AS auto_v8spositiontaking_20,  

		--Golf  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.autopositiontaking ELSE 0 END) AS auto_v10spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.autopositiontaking ELSE 0 END) AS auto_v10spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.autopositiontaking ELSE 0 END) AS auto_v10spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.autopositiontaking ELSE 0 END) AS auto_v10spositiontaking_20,  

		--Motorsports  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.autopositiontaking ELSE 0 END) AS auto_v11spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.autopositiontaking ELSE 0 END) AS auto_v11spositiontaking_20,  

		--Other sports  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_20,  
	    MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_9999,  			
		
		-- Mix Sports
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_9, 
		
		--i3
		@isauto_spositiontaking_1 as isauto_spositiontaking_1,
		@isauto_spositiontaking_2 as isauto_spositiontaking_2,
		@isauto_spositiontaking_3 as isauto_spositiontaking_3,
		@isauto_spositiontaking_4 as isauto_spositiontaking_4,
		@isauto_spositiontaking_5 as isauto_spositiontaking_5,
		@isauto_spositiontaking_6 as isauto_spositiontaking_6,
		@isauto_spositiontaking_7 as isauto_spositiontaking_7,
		@isauto_spositiontaking_8 as isauto_spositiontaking_8,
		@isauto_spositiontaking_9 as isauto_spositiontaking_9,
		@isauto_spositiontaking_10 as isauto_spositiontaking_10,
		@isauto_spositiontaking_9999 as isauto_spositiontaking_9999,
		@isauto_slivepositiontaking_1 as isauto_slivepositiontaking_1,
		@isauto_slivepositiontaking_3 as isauto_slivepositiontaking_3,
		@isauto_slivepositiontaking_7 as isauto_slivepositiontaking_7,
		@isauto_slivepositiontaking_8 as isauto_slivepositiontaking_8,
		
		@isauto_v2spositiontaking_1 as isauto_v2spositiontaking_1,
		@isauto_v2spositiontaking_2 as isauto_v2spositiontaking_2,
		@isauto_v2spositiontaking_3 as isauto_v2spositiontaking_3,
		@isauto_v2spositiontaking_7 as isauto_v2spositiontaking_7,
		@isauto_v2spositiontaking_8 as isauto_v2spositiontaking_8,	
		@isauto_v2spositiontaking_20 as isauto_v2spositiontaking_20,
		@isauto_v2spositiontaking_9999 as isauto_v2spositiontaking_9999,
		
		@isauto_v3spositiontaking_1 as isauto_v3spositiontaking_1,
		@isauto_v3spositiontaking_2 as isauto_v3spositiontaking_2,
		@isauto_v3spositiontaking_3 as isauto_v3spositiontaking_3,
		@isauto_v3spositiontaking_20 as isauto_v3spositiontaking_20,
		
		@isauto_v5spositiontaking_1 as isauto_v5spositiontaking_1,
		@isauto_v5spositiontaking_2 as isauto_v5spositiontaking_2,
		@isauto_v5spositiontaking_3 as isauto_v5spositiontaking_3,
		@isauto_v5spositiontaking_20 as isauto_v5spositiontaking_20,
		@isauto_v5spositiontaking_9999 as isauto_v5spositiontaking_9999,
		
		@isauto_v8spositiontaking_1 as isauto_v8spositiontaking_1,
		@isauto_v8spositiontaking_3 as isauto_v8spositiontaking_3,
		@isauto_v8spositiontaking_20 as isauto_v8spositiontaking_20,
		
		@isauto_v10spositiontaking_1 as isauto_v10spositiontaking_1,
		@isauto_v10spositiontaking_2 as isauto_v10spositiontaking_2,
		@isauto_v10spositiontaking_3 as isauto_v10spositiontaking_3,
		@isauto_v10spositiontaking_20 as isauto_v10spositiontaking_20,
		
		@isauto_v11spositiontaking_1 as isauto_v11spositiontaking_1,
		@isauto_v11spositiontaking_20 as isauto_v11spositiontaking_20,

		@isauto_v99spositiontaking_1 as isauto_v99spositiontaking_1,
		@isauto_v99spositiontaking_2 as isauto_v99spositiontaking_2,
		@isauto_v99spositiontaking_3 as isauto_v99spositiontaking_3,
		@isauto_v99spositiontaking_20 as isauto_v99spositiontaking_20,
		@isauto_v99spositiontaking_9999 as isauto_v99spositiontaking_9999,		
		
		@isauto_v99spositiontaking_9 as isauto_v99spositiontaking_9,

		--i1
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_4,  
		MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_5,  
		MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_6,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_8,  
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_9,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_spositiontaking_mem_9999,  

		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.isautolivepositiontaking ELSE 0 END) AS isauto_slivepositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.isautolivepositiontaking ELSE 0 END) AS isauto_slivepositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.isautolivepositiontaking ELSE 0 END) AS isauto_slivepositiontaking_mem_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.isautolivepositiontaking ELSE 0 END) AS isauto_slivepositiontaking_mem_8,  

		--v2  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_7,  
		MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_8,  	
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_9999,  

		--v3  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v3spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v3spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v3spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v3spositiontaking_mem_20,  

		--v5  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_9999,  

		--v8  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v8spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v8spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v8spositiontaking_mem_20,  

		--v10  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v10spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v10spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v10spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v10spositiontaking_mem_20,  

		--v11  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v11spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v11spositiontaking_mem_20,  

		--v99  
		MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_1,  
		MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_2,  
		MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_3,  
		MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_20,  
		MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_9999,  				 

		--v99MP
		MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_9,  

		--u1_max
		ISNULL(@mspositiontaking_1_max, 0) AS maxautopos_1,  
		ISNULL(@mspositiontaking_2_max, 0) AS maxautopos_2,  
		ISNULL(@mspositiontaking_3_max, 0) AS maxautopos_3,  
		ISNULL(@mspositiontaking_4_max, 0) AS maxautopos_4,  
		ISNULL(@mspositiontaking_5_max, 0) AS maxautopos_5,  
		ISNULL(@mspositiontaking_6_max, 0) AS maxautopos_6,  
		ISNULL(@mspositiontaking_7_max, 0) AS maxautopos_7,  
		ISNULL(@mspositiontaking_8_max, 0) AS maxautopos_8,   
		ISNULL(@mspositiontaking_9_max, 0) AS maxautopos_9,  
		ISNULL(@mspositiontaking_10_max, 0) AS maxautopos_10,  
		ISNULL(@mspositiontaking_9999_max, 0) AS maxautopos_9999,

		ISNULL(@mslivepositiontaking_1_max, 0) AS maxautolpos_1,  
		ISNULL(@mslivepositiontaking_3_max, 0) AS maxautolpos_3,  
		ISNULL(@mslivepositiontaking_7_max, 0) AS maxautolpos_7,  
		ISNULL(@mslivepositiontaking_8_max, 0) AS maxautolpos_8,   

		--v2  
		ISNULL(@v2mspositiontaking_1_max, 0) AS maxautov2pos_1,  
		ISNULL(@v2mspositiontaking_2_max, 0) AS maxautov2pos_2,  
		ISNULL(@v2mspositiontaking_3_max, 0) AS maxautov2pos_3,  
		ISNULL(@v2mspositiontaking_7_max, 0) AS maxautov2pos_7,  
		ISNULL(@v2mspositiontaking_8_max, 0) AS maxautov2pos_8,  	
		ISNULL(@v2mspositiontaking_20_max, 0) AS maxautov2pos_20,  
		ISNULL(@v2mspositiontaking_9999_max, 0) AS maxautov2pos_9999,  

		--v3  
		ISNULL(@v3mspositiontaking_1_max, 0) AS maxautov3pos_1,  
		ISNULL(@v3mspositiontaking_2_max, 0) AS maxautov3pos_2,  
		ISNULL(@v3mspositiontaking_3_max, 0) AS maxautov3pos_3,  
		ISNULL(@v3mspositiontaking_20_max, 0) AS maxautov3pos_20,  

		--v5  
		ISNULL(@v5mspositiontaking_1_max, 0) AS maxautov5pos_1,  
		ISNULL(@v5mspositiontaking_2_max, 0) AS maxautov5pos_2,  
		ISNULL(@v5mspositiontaking_3_max, 0) AS maxautov5pos_3,  
		ISNULL(@v5mspositiontaking_20_max, 0) AS maxautov5pos_20,
		ISNULL(@v5mspositiontaking_9999_max, 0) AS maxautov5pos_9999,    

		--v8  
		ISNULL(@v8mspositiontaking_1_max, 0) AS maxautov8pos_1,  
		ISNULL(@v8mspositiontaking_3_max, 0) AS maxautov8pos_3,  
		ISNULL(@v8mspositiontaking_20_max, 0) AS maxautov8pos_20,  

		--v10  
		ISNULL(@v10mspositiontaking_1_max, 0) AS maxautov10pos_1,  
		ISNULL(@v10mspositiontaking_2_max, 0) AS maxautov10pos_2,  
		ISNULL(@v10mspositiontaking_3_max, 0) AS maxautov10pos_3,  
		ISNULL(@v10mspositiontaking_20_max, 0) AS maxautov10pos_20,  

		--v11  
		ISNULL(@v11mspositiontaking_1_max, 0) AS maxautov11pos_1,  
		ISNULL(@v11mspositiontaking_20_max, 0) AS maxautov11pos_20,  

		--v99  
		ISNULL(@v99mspositiontaking_1_max, 0) AS maxautov99pos_1,  
		ISNULL(@v99mspositiontaking_2_max, 0) AS maxautov99pos_2,  
		ISNULL(@v99mspositiontaking_3_max, 0) AS maxautov99pos_3,  
		ISNULL(@v99mspositiontaking_20_max, 0) AS maxautov99pos_20,
		ISNULL(@v99mspositiontaking_9999_max, 0) AS maxautov99pos_9999,
	
		--v99MP  
		ISNULL(@v99mspositiontaking_9_max, 0) AS maxautov99pos_9, 

		--s1_min=max(n4-m1-a1,0)
		CASE WHEN ISNULL(@mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_1,  
		CASE WHEN ISNULL(@mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_2,  
		CASE WHEN ISNULL(@mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_3,  
		CASE WHEN ISNULL(@mspositiontaking_4_min, 0)-MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_4_min, 0)-MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_4,  
		CASE WHEN ISNULL(@mspositiontaking_5_min, 0)-MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_5_min, 0)-MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_5,  
		CASE WHEN ISNULL(@mspositiontaking_6_min, 0)-MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_6_min, 0)-MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_6,  
		CASE WHEN ISNULL(@mspositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_7,  
		CASE WHEN ISNULL(@mspositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_8,  
		CASE WHEN ISNULL(@mspositiontaking_9_min, 0)-MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_9_min, 0)-MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_9,  
		CASE WHEN ISNULL(@mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_10,  
		CASE WHEN ISNULL(@mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minpos_9999,  
		CASE WHEN ISNULL(@mslivepositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) >0 THEN ISNULL(@mslivepositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1
		THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) ELSE 0 END AS minlpos_1,  
		CASE WHEN ISNULL(@mslivepositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) >0 THEN ISNULL(@mslivepositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1
		THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) ELSE 0 END AS minlpos_3,  
		CASE WHEN ISNULL(@mslivepositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) >0 THEN ISNULL(@mslivepositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1
		THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) ELSE 0 END AS minlpos_7,  
		CASE WHEN ISNULL(@mslivepositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) >0 THEN ISNULL(@mslivepositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1
		THEN cs.mlivepositiontaking+cs.alivepositiontaking ELSE 0 END) ELSE 0 END AS minlpos_8,  

		--v2  
		CASE WHEN ISNULL(@v2mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_1,  
		CASE WHEN ISNULL(@v2mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_2,  
		CASE WHEN ISNULL(@v2mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_3,  
		CASE WHEN ISNULL(@v2mspositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_7_min, 0)-MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_7,  
		CASE WHEN ISNULL(@v2mspositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_8_min, 0)-MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_8,  	
		CASE WHEN ISNULL(@v2mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_20,  
		CASE WHEN ISNULL(@v2mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_9999,  

		--v3  
		CASE WHEN ISNULL(@v3mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v3mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv3pos_1,  
		CASE WHEN ISNULL(@v3mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v3mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv3pos_2,  
		CASE WHEN ISNULL(@v3mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v3mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv3pos_3,  
		CASE WHEN ISNULL(@v3mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v3mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv3pos_20,  

		--v5  
		CASE WHEN ISNULL(@v5mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_1,  
		CASE WHEN ISNULL(@v5mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_2,  
		CASE WHEN ISNULL(@v5mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_3,  
		CASE WHEN ISNULL(@v5mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_20,  
		CASE WHEN ISNULL(@v5mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_9999,  

		--v8  
		CASE WHEN ISNULL(@v8mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v8mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv8pos_1,  
		CASE WHEN ISNULL(@v8mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v8mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv8pos_3,  
		CASE WHEN ISNULL(@v8mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v8mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv8pos_20,  

		--v10  
		CASE WHEN ISNULL(@v10mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v10mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv10pos_1,  
		CASE WHEN ISNULL(@v10mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v10mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv10pos_2,  
		CASE WHEN ISNULL(@v10mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v10mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv10pos_3,  
		CASE WHEN ISNULL(@v10mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v10mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv10pos_20,  

		--v11  
		CASE WHEN ISNULL(@v11mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v11mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv11pos_1,  
		CASE WHEN ISNULL(@v11mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v11mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv11pos_20,  

		--v99  
		CASE WHEN ISNULL(@v99mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_1_min, 0)-MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_1,  
		CASE WHEN ISNULL(@v99mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_2_min, 0)-MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_2,  
		CASE WHEN ISNULL(@v99mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_3_min, 0)-MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_3,  
		CASE WHEN ISNULL(@v99mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_20_min, 0)-MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_20,
		CASE WHEN ISNULL(@v99mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_9999_min, 0)-MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_9999,
	
		--v99MP
		CASE WHEN ISNULL(@v99mspositiontaking_9_min, 0)-MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_9_min, 0)-MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_9,
		
		-- outright PT
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.apositiontaking ELSE 0 END) AS v2apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.apositiontaking ELSE 0 END) AS v3apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.apositiontaking ELSE 0 END) AS v5apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.apositiontaking ELSE 0 END) AS v8apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.apositiontaking ELSE 0 END) AS v10apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.apositiontaking ELSE 0 END) AS v11apositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.apositiontaking ELSE 0 END) AS v99apositiontaking_10,  
		
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.mpositiontaking ELSE 0 END) AS v2mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.mpositiontaking ELSE 0 END) AS v3mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.mpositiontaking ELSE 0 END) AS v5mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.mpositiontaking ELSE 0 END) AS v8mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.mpositiontaking ELSE 0 END) AS v10mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.mpositiontaking ELSE 0 END) AS v11mpositiontaking_10,   
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.mpositiontaking ELSE 0 END) AS v99mpositiontaking_10, 
		
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.spositiontaking ELSE 0 END) AS v2spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.spositiontaking ELSE 0 END) AS v3spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.spositiontaking ELSE 0 END) AS v5spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.spositiontaking ELSE 0 END) AS v8spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.spositiontaking ELSE 0 END) AS v10spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.spositiontaking ELSE 0 END) AS v11spositiontaking_10,
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.spositiontaking ELSE 0 END) AS v99spositiontaking_10,
		
		ISNULL(@v2mspositiontaking_10_max, 0) - ISNULL(@v2mpositiontaking_10,0) AS maxv2pos_10,  
		ISNULL(@v3mspositiontaking_10_max, 0) - ISNULL(@v3mpositiontaking_10,0) AS maxv3pos_10,  
		ISNULL(@v5mspositiontaking_10_max, 0) - ISNULL(@v5mpositiontaking_10,0) AS maxv5pos_10,  
		ISNULL(@v8mspositiontaking_10_max, 0) - ISNULL(@v8mpositiontaking_10,0) AS maxv8pos_10,  
		ISNULL(@v10mspositiontaking_10_max, 0) - ISNULL(@v10mpositiontaking_10,0) AS maxv10pos_10,  
		ISNULL(@v11mspositiontaking_10_max, 0) - ISNULL(@v11mpositiontaking_10,0) AS maxv11pos_10,  
		ISNULL(@v99mspositiontaking_10_max, 0) - ISNULL(@v99mpositiontaking_10,0) AS maxv99pos_10,  
		
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.autopositiontaking ELSE 0 END) AS auto_v2spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.autopositiontaking ELSE 0 END) AS auto_v3spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.autopositiontaking ELSE 0 END) AS auto_v5spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.autopositiontaking ELSE 0 END) AS auto_v8spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.autopositiontaking ELSE 0 END) AS auto_v10spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.autopositiontaking ELSE 0 END) AS auto_v11spositiontaking_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.autopositiontaking ELSE 0 END) AS auto_v99spositiontaking_10,  
		
		
		@isauto_v2spositiontaking_10 as isauto_v2spositiontaking_10,
		@isauto_v3spositiontaking_10 as isauto_v3spositiontaking_10,
		@isauto_v5spositiontaking_10 as isauto_v5spositiontaking_10,
		@isauto_v8spositiontaking_10 as isauto_v8spositiontaking_10,
		@isauto_v10spositiontaking_10 as isauto_v10spositiontaking_10,
		@isauto_v11spositiontaking_10 as isauto_v11spositiontaking_10,
		@isauto_v99spositiontaking_10 as isauto_v99spositiontaking_10,
		
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v2spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v3spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v5spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v8spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v10spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v11spositiontaking_mem_10,  
		MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.isautopositiontaking ELSE 0 END) AS isauto_v99spositiontaking_mem_10,  
		
		ISNULL(@v2mspositiontaking_10_max, 0) AS maxautov2pos_10,  
		ISNULL(@v3mspositiontaking_10_max, 0) AS maxautov3pos_10,  
		ISNULL(@v5mspositiontaking_10_max, 0) AS maxautov5pos_10,  
		ISNULL(@v8mspositiontaking_10_max, 0) AS maxautov8pos_10,  
		ISNULL(@v10mspositiontaking_10_max, 0) AS maxautov10pos_10,  
		ISNULL(@v11mspositiontaking_10_max, 0) AS maxautov11pos_10, 
		ISNULL(@v99mspositiontaking_10_max, 0) AS maxautov99pos_10,  
		 
		
		CASE WHEN ISNULL(@v2mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v2mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv2pos_10,  
		CASE WHEN ISNULL(@v3mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v3mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv3pos_10,  
		CASE WHEN ISNULL(@v5mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v5mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv5pos_10,  
		CASE WHEN ISNULL(@v8mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v8mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv8pos_10,  
		CASE WHEN ISNULL(@v10mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v10mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv10pos_10,  
		CASE WHEN ISNULL(@v11mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v11mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv11pos_10,  
		CASE WHEN ISNULL(@v99mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) >0 THEN ISNULL(@v99mspositiontaking_10_min, 0)-MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN cs.mpositiontaking+cs.apositiontaking ELSE 0 END) ELSE 0 END AS minv99pos_10,
		MAX(ag.Site) AS Site,
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
		@maxPayoutpermatchv2saba		AS maxPayoutpermatchv2saba
	FROM   
		customer AS C WITH (NOLOCK)   
		INNER JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON c.custid  = ci.custid  
		INNER JOIN custsetting AS cs WITH (NOLOCK) ON c.custid  = cs.custid  
		INNER JOIN exchange WITH (NOLOCK) ON C.currency=exchange.exchangeid 
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, CloseInfo
										, SuspendInfo
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps 
		CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.CloseInfo)) AS cl
		CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp 
	WHERE 
		c.custid=@custId AND c.recommend=@agentId  
	GROUP BY   
		c.fax, c.firstname, c.lastname, c.username2, c.mobilephone, c.email, c.phone, c.ugroup, c.username,   
		
		exchange.minbet, cps.closed, ci.credit,cps.reject,
		cps.closed,
		sp.SuperStatus,sp.MasterStatus,sp.AgentStatus,
		cl.SuperStatus,cl.MasterStatus,cl.AgentStatus

END	 
 
GO
