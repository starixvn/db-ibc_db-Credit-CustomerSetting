/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_SAg]
	@custid     INT OUTPUT,
	@firstname  NVARCHAR(50),
	@lastname   NVARCHAR(50),
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@email      NVARCHAR(50)=NULL,
	@fax        NVARCHAR(50),
	@address    NVARCHAR(80)=NULL,
	@city       NVARCHAR(50)=NULL,
	@state      NVARCHAR(50)=NULL,
	@country    NVARCHAR(50)=NULL,
	@postal     NVARCHAR(50)=NULL,

	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in CASE dummy super add new master
	
	@DisableCasino    BIT = 0,
	@DisableAutoMPT   BIT = 1,--Super allow master using auto master PT or not.

	@DisableNumber    BIT = 0,
		
	--@IsInternal BIT = 0,
	@minbet MONEY,
	@maxbet MONEY,
	@maxpermatch MONEY,
	
	@minbetv2 MONEY,
	@maxbetv2 MONEY,
	@maxpermatchv2 MONEY,
	
	@minbetv3 MONEY,
	@maxbetv3 MONEY,
	@maxpermatchv3 MONEY,
	
	@minbetv5 MONEY,
	@maxbetv5 MONEY,
	@maxpermatchv5 MONEY,
	
	@minbetv8 MONEY,
	@maxbetv8 MONEY,
	@maxpermatchv8 MONEY,
	
	@minbetv10 MONEY,
	@maxbetv10 MONEY,
	@maxpermatchv10 MONEY,
	
	@minbetv11 MONEY,
	@maxbetv11 MONEY,
	@maxpermatchv11 MONEY,
	
	@minbetv99 MONEY,
	@maxbetv99 MONEY,
	@maxpermatchv99 MONEY,
	
	@minbetv99mp MONEY = 0,
	@maxbetv99mp MONEY = 0,
	@maxpermatchv99mp MONEY = 0,
	
	@minbetv1mp MONEY = 0,
	@maxbetv1mp MONEY = 0,
	@maxpermatchv1mp MONEY = 0,	
	
	@minbetv161 MONEY = 0,				
	@maxbetv161 MONEY = 0,
	@maxpermatchv161 MONEY = 0,	
	
	@minbetv164 MONEY = 0,				
	@maxbetv164 MONEY = 0,
	@maxpermatchv164 MONEY = 0,	

	@maxperballv161 MONEY = 0,

	--Max Payout Per Match
	@maxPOpermatch money = NULL,
	@maxPOpermatchv2 money = NULL,
	@maxPOpermatchv3 money = NULL,
	@maxPOpermatchv5 money = NULL,
	@maxPOpermatchv8 money = NULL,
	@maxPOpermatchv10 money = NULL,
	@maxPOpermatchv11 money = NULL,
	@maxPOpermatchv99 money = NULL,
	@maxPOpermatchv99mp money = NULL,
	@maxPOpermatchv1mp money = NULL,

	--- Saba soccer
	@minbetv1saba money = NULL,
	@maxbetv1saba money = NULL,
	@maxpermatchv1saba money  = NULL,
	@maxPOpermatchv1saba money = NULL,

	--- Saba basketball
	@minbetv2saba money = NULL,
	@maxbetv2saba money = NULL,
	@maxpermatchv2saba money  = NULL,
	@maxPOpermatchv2saba money = NULL,
	
	@credit MONEY,
	@srecommend INT,
	@spositiontaking_1 SMALLMONEY,
	@spositiontaking_2 SMALLMONEY,
	@spositiontaking_3 SMALLMONEY,
	@spositiontaking_4 SMALLMONEY,
	@spositiontaking_5 SMALLMONEY,
	@spositiontaking_6 SMALLMONEY,
	@spositiontaking_7 SMALLMONEY,
	@spositiontaking_8 SMALLMONEY,
	@spositiontaking_9 SMALLMONEY,
	@spositiontaking_10 SMALLMONEY,
	@v2spositiontaking_10 SMALLMONEY,
	@v3spositiontaking_10 SMALLMONEY,
	@v5spositiontaking_10 SMALLMONEY,
	@v8spositiontaking_10 SMALLMONEY,
	@v10spositiontaking_10 SMALLMONEY,
	@v11spositiontaking_10 SMALLMONEY,
	@v99spositiontaking_10 SMALLMONEY,
	@spositiontaking_9999 SMALLMONEY = 0,
	@slivepositiontaking_1 SMALLMONEY,
	@slivepositiontaking_3 SMALLMONEY,
	@slivepositiontaking_7 SMALLMONEY,
	@slivepositiontaking_8 SMALLMONEY,
	
	@v2spositiontaking_1 SMALLMONEY,
	@v2spositiontaking_2 SMALLMONEY,
	@v2spositiontaking_3 SMALLMONEY,
	@v2spositiontaking_7 SMALLMONEY,
	@v2spositiontaking_8 SMALLMONEY,

	@v2spositiontaking_20 SMALLMONEY,
	@v2spositiontaking_9999 SMALLMONEY = 0,
	
	@v3spositiontaking_1 SMALLMONEY,
	@v3spositiontaking_2 SMALLMONEY,
	@v3spositiontaking_3 SMALLMONEY,
	@v3spositiontaking_20 SMALLMONEY,
	
	@v5spositiontaking_1 SMALLMONEY,
	@v5spositiontaking_2 SMALLMONEY,
	@v5spositiontaking_3 SMALLMONEY,
	@v5spositiontaking_20 SMALLMONEY,
	@v5spositiontaking_9999 SMALLMONEY = 0,
	
	@v8spositiontaking_1 SMALLMONEY,	
	@v8spositiontaking_3 SMALLMONEY,
	@v8spositiontaking_20 SMALLMONEY,
	
	@v10spositiontaking_1 SMALLMONEY,
	@v10spositiontaking_2 SMALLMONEY,
	@v10spositiontaking_3 SMALLMONEY,
	@v10spositiontaking_20 SMALLMONEY,
	
	@v11spositiontaking_1 SMALLMONEY,	
	@v11spositiontaking_20 SMALLMONEY,
	
	@v99spositiontaking_1 SMALLMONEY,
	@v99spositiontaking_2 SMALLMONEY,
	@v99spositiontaking_3 SMALLMONEY,	
	@v99spositiontaking_20 SMALLMONEY,	
	
	@v99spositiontaking_9 SMALLMONEY = 0,
	@v99spositiontaking_9999 SMALLMONEY = 0,

	@v161spositiontaking_81 SMALLMONEY = 0, 				
	@v161spositiontaking_83 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87	smallmoney = 0,
	@v161slivepositiontaking_89	smallmoney = 0,
	@v161slivepositiontaking_90	smallmoney = 0,

	@groupa DECIMAL(9, 8),
	@groupb DECIMAL(9, 8),
	@groupc DECIMAL(9, 8),
	@groupd DECIMAL(9, 8),
	@discountcs DECIMAL(9, 8),	
	--1x2
	@discount1x2 DECIMAL(9, 8) = 0,	
	
	-- MyanmarOdds
	@discountMyanmarOdds DECIMAL(9,8)=0,
	
	@auto_spositiontaking_1 SMALLMONEY = 0,
	@auto_spositiontaking_2 SMALLMONEY = 0,
	@auto_spositiontaking_3 SMALLMONEY = 0,
	@auto_spositiontaking_4 SMALLMONEY = 0,
	@auto_spositiontaking_5 SMALLMONEY = 0,
	@auto_spositiontaking_6 SMALLMONEY = 0,
	@auto_spositiontaking_7 SMALLMONEY = 0,
	@auto_spositiontaking_8 SMALLMONEY = 0,
	@auto_spositiontaking_9 SMALLMONEY = 0,
	@auto_spositiontaking_10 SMALLMONEY = 0,
	@auto_v2spositiontaking_10 SMALLMONEY = 0,
	@auto_v3spositiontaking_10 SMALLMONEY = 0,
	@auto_v5spositiontaking_10 SMALLMONEY = 0,
	@auto_v8spositiontaking_10 SMALLMONEY = 0,
	@auto_v10spositiontaking_10 SMALLMONEY = 0,
	@auto_v11spositiontaking_10 SMALLMONEY = 0,
	@auto_v99spositiontaking_10 SMALLMONEY = 0,
	@auto_spositiontaking_9999 SMALLMONEY = 0,
	@auto_slivepositiontaking_1 SMALLMONEY = 0,
	@auto_slivepositiontaking_3 SMALLMONEY = 0,
	@auto_slivepositiontaking_7 SMALLMONEY = 0,
	@auto_slivepositiontaking_8 SMALLMONEY = 0,
	
	@auto_v2spositiontaking_1 SMALLMONEY = 0,
	@auto_v2spositiontaking_2 SMALLMONEY = 0,
	@auto_v2spositiontaking_3 SMALLMONEY = 0,
	@auto_v2spositiontaking_7 SMALLMONEY = 0,
	@auto_v2spositiontaking_8 SMALLMONEY = 0,

	@auto_v2spositiontaking_20 SMALLMONEY = 0,
	@auto_v2spositiontaking_9999 SMALLMONEY = 0,
		
	@auto_v3spositiontaking_1 SMALLMONEY = 0,
	@auto_v3spositiontaking_2 SMALLMONEY = 0,
	@auto_v3spositiontaking_3 SMALLMONEY = 0,	
	@auto_v3spositiontaking_20 SMALLMONEY = 0,
	
	@auto_v5spositiontaking_1 SMALLMONEY = 0,
	@auto_v5spositiontaking_2 SMALLMONEY = 0,
	@auto_v5spositiontaking_3 SMALLMONEY = 0,	
	@auto_v5spositiontaking_20 SMALLMONEY = 0,
	@auto_v5spositiontaking_9999 SMALLMONEY = 0,
	
	@auto_v8spositiontaking_1 SMALLMONEY = 0,	
	@auto_v8spositiontaking_3 SMALLMONEY = 0,	
	@auto_v8spositiontaking_20 SMALLMONEY = 0,
	
	@auto_v10spositiontaking_1 SMALLMONEY = 0,
	@auto_v10spositiontaking_2 SMALLMONEY = 0,
	@auto_v10spositiontaking_3 SMALLMONEY = 0,	
	@auto_v10spositiontaking_20 SMALLMONEY = 0,
	
	@auto_v11spositiontaking_1 SMALLMONEY = 0,	
	@auto_v11spositiontaking_20 SMALLMONEY = 0,
	
	@auto_v99spositiontaking_1 SMALLMONEY = 0,
	@auto_v99spositiontaking_2 SMALLMONEY = 0,
	@auto_v99spositiontaking_3 SMALLMONEY = 0,		
	@auto_v99spositiontaking_20 SMALLMONEY = 0,	

	@auto_v99spositiontaking_9 SMALLMONEY = 0,
	@auto_v99spositiontaking_9999 SMALLMONEY = 0,
	
	@auto_v161spositiontaking_81 SMALLMONEY = 0,            
	@auto_v161spositiontaking_83 SMALLMONEY = 0,
	@auto_v161spositiontaking_86 SMALLMONEY = 0,
	@auto_v161spositiontaking_88 SMALLMONEY = 0,
	
	@auto_v161slivepositiontaking_85 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_86 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_87 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_89 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_90 SMALLMONEY = 0,
	
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0,--Sub-AccountID,
	@mpositiontaking_1 SMALLMONEY = 0.7,
	@mpositiontaking_2 SMALLMONEY = 0.7,
	@mpositiontaking_3 SMALLMONEY = 0.7,
	@mpositiontaking_4 SMALLMONEY = 0.7,
	@mpositiontaking_5 SMALLMONEY = 0.7,
	@mpositiontaking_6 SMALLMONEY = 0.7,
	@mpositiontaking_7 SMALLMONEY = 0.7,
	@mpositiontaking_8 SMALLMONEY = 0.7,
	@mpositiontaking_9 SMALLMONEY = 0.7,
	@mpositiontaking_10 SMALLMONEY = 0.7,
	@v2mpositiontaking_10 SMALLMONEY = 0.7,
	@v3mpositiontaking_10 SMALLMONEY = 0.7,
	@v5mpositiontaking_10 SMALLMONEY = 0.7,
	@v8mpositiontaking_10 SMALLMONEY = 0.7,
	@v10mpositiontaking_10 SMALLMONEY = 0.7,
	@v11mpositiontaking_10 SMALLMONEY = 0.7,
	@v99mpositiontaking_10 SMALLMONEY = 0.7,
	@mpositiontaking_9999 SMALLMONEY = 0,
	@mlivepositiontaking_1 SMALLMONEY = 0.7,
	@mlivepositiontaking_3 SMALLMONEY = 0.7,
	@mlivepositiontaking_7 SMALLMONEY = 0.7,
	@mlivepositiontaking_8 SMALLMONEY = 0.7,

	
	@v2mpositiontaking_1 SMALLMONEY = 0.7,
	@v2mpositiontaking_2 SMALLMONEY = 0.7,
	@v2mpositiontaking_3 SMALLMONEY = 0.7,
	@v2mpositiontaking_7 SMALLMONEY = 0.7,
	@v2mpositiontaking_8 SMALLMONEY = 0.7,

	@v2mpositiontaking_20 SMALLMONEY = 0.7,
	@v2mpositiontaking_9999 SMALLMONEY = 0.7,
	
	@v3mpositiontaking_1 SMALLMONEY = 0.7,
	@v3mpositiontaking_2 SMALLMONEY = 0.7,
	@v3mpositiontaking_3 SMALLMONEY = 0.7,	
	@v3mpositiontaking_20 SMALLMONEY = 0.7,
	
	@v5mpositiontaking_1 SMALLMONEY = 0.7,
	@v5mpositiontaking_2 SMALLMONEY = 0.7,
	@v5mpositiontaking_3 SMALLMONEY = 0.7,	
	@v5mpositiontaking_20 SMALLMONEY = 0,
	@v5mpositiontaking_9999 SMALLMONEY = 0,
	
	@v8mpositiontaking_1 SMALLMONEY = 0.7,	
	@v8mpositiontaking_3 SMALLMONEY = 0.7,	
	@v8mpositiontaking_20 SMALLMONEY = 0.7,
	
	@v10mpositiontaking_1 SMALLMONEY = 0.7,
	@v10mpositiontaking_2 SMALLMONEY = 0.7,
	@v10mpositiontaking_3 SMALLMONEY = 0.7,	
	@v10mpositiontaking_20 SMALLMONEY = 0.7,
	
	@v11mpositiontaking_1 SMALLMONEY = 0.7,	
	@v11mpositiontaking_20 SMALLMONEY = 0.7,
	
	@v99mpositiontaking_1 SMALLMONEY = 0.7,
	@v99mpositiontaking_2 SMALLMONEY = 0.7,
	@v99mpositiontaking_3 SMALLMONEY = 0.7,		
	@v99mpositiontaking_20 SMALLMONEY = 0.7,

	@v99mpositiontaking_9 SMALLMONEY = 0.7,
	@v99mpositiontaking_9999 SMALLMONEY = 0.7,

	@v161mpositiontaking_81 SMALLMONEY = 0.7,        
	@v161mpositiontaking_83 SMALLMONEY = 0.7,
	@v161mpositiontaking_86 SMALLMONEY = 0.7,
	@v161mpositiontaking_88 SMALLMONEY = 0.7,
	
	@v161mlivepositiontaking_85 SMALLMONEY = 0.7,
	@v161mlivepositiontaking_86 SMALLMONEY = 0.7,
	@v161mlivepositiontaking_87 SMALLMONEY = 0.7,
	@v161mlivepositiontaking_89 SMALLMONEY = 0.7,
	@v161mlivepositiontaking_90 SMALLMONEY = 0.7,
	@SystemID	TINYINT=1,
	
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT,
	@site VARCHAR(50) = '',
	@SettingStatus TINYINT = 0
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Super creates Master
DB: DBCUST/CustDB
Original:

Revisions:
    - 20081009@Phuc: Apply Auto Super PT WHEN create Master
	- 20081021@Phuc: Add new sporttype 201, bettype 3,Hard code copy min/max/maxperbet/PT for 201 FROM 2 sporttype 
	- 20090122@PhuongNguyen: Remove userpwd FROM log writing
	- 20090122@PhuongDao: Add new sporttype 201, bettype 2.
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission
	- 20090407@Phuc: IF DisableFinancial (upline or webconfig) set s3 = n4, m3 = 0; get minbet201, maxbet201, maxpermatch201 FROM upline
	- 20090417@PhuongDao: Set default virtualrate = 0%
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20090701@Phuc: super allow master using auto master.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access AND check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Shifu: Add IsInternal
	- 20090903@Simon: Write Credit Log INTo Userlog_Credit table.
	- 20090917@Phuc: write log INTo DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status FROM the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100827@Lukas:	- Add setting information (minbet,maxbet,positiontaking, auto_positiontaking...) for Number game 
						- Add setting information for Mix Parlay for Mixed Sports (sporttype = 99, bettype = 9)
						- Remove Mix Parlay for Basketball game (sporttype = 2, bettype = 9)
	- 20100909@Jamie: Add param @DisableCasino
	- 20101019@Henry: Record execution time
	- 20101026@Lukas: Add max per ball for number game
	- 20101231@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110520@Johnson: Allow spaces between words in user name WHEN creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110801@Lukas: (Number Game)
				- Add more bettypes: Warrior, Next Combo, Number Group
				- Remove dead ball Over/Under
	- 20110822@Tom: Add P2P setting
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@Error for inserting P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (FROM upline)
	- 20111222@Johnson: Add live casino setting
	- 20120210@TOM: Insert default value of P2P Comm
	- 20120502@Lukas: Encode XML values in logging
	- 20120531@Johnson: correct site of direct master IF passed
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120810@Johnson: Add virtual soccer setting
	- 20120928@Johnson: add double comm losing status
	- 20121011@Dan: add win limit setting for live casino
	- 20121128@Elodie: Get an error message FROM f_Get_MsgNameByMsgID function by language
	- 20130219@Johnson: add virtual horse racing setting (sporttype : 181, bettype : 1231)
						AND write log INTo DBTXN IF DBLOG failure
	- 20130717@Lukas: limit created customers in a MINUTE
	- 20130731@Elodie: Apply progressive bonus
	- 20130905@Lukas: restrict new customers created: 100 customers per 10 MINUTEs		
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend INTo Soccer AND Other Sport [Redmine:#5520] 
	- 20131107@Johnson: Apply execrep WHEN insert setting INTo custsetting/custsetting3rd
	- 20131108@Elodie: Splitting bodb02 INTo CustDB (call sport, bettype by link database)
	- 20131120@Kathy: Add Virtual Greyhounds, Virtual Motor Racing (182, 184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140318@Patrick: Modify log for Keno status
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
	- 20140619@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20140826@Logan: Add status for Esports [Redmine: #20531]
	- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	- 20150601@Elodie: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table)
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150714@Patrick: Add max win limit for Gold deluxe
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151104@Billy: Add Disable and Hide SB2 to log initial status [Redmine: #46833]
	- 20151217@Helen: Creating Disable and Hide Product dynamically - [Redmine:#48602] 
	- 20160120@Lukas: add checking constraint on prefix of username of new customer - [Redmine: #51169]
	- 20151223@Patrick: Add Max/Loss limit for RnG Casino [Redmine: #49528]
	- 20160215@Dominic: Cricket is not showed in log for MBC customers [Redmine: #52158]
	- 20160222@Dominic: Log initial status is blank [Redmine: #52657]
	- 20160315@Winnie: Hotfix 51457 write wrong log info
	- 20160407@Lukas: change error code of invalid username from 101 to 1101
	- 20160627@Winnie: Out right PT [Redmine #59438] 
	- 20160722@Winnie: #48948 Hide_special_sites_from_unautorized_users
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20161223@Winnie: Hot Fix  Show Fishing World logs although this Product is not released to PROD yet [Redmine:69236]
	- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]		
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170620@Winnie: Apply color for closed account - [RedmineID: 74494]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20171206@Johnson: add more log for special, doublecomm, autosuspend status [Redmine: #87121]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]
	- 20180808@Helen: DB05.DBPOLICY migration  [Redmine:99462]
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]  
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526] 	
	- 20181102@Johnson: Apply service broker for logging [Redmine: #103547]  	
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]  
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190510@Johnson: remove suspend status on setting page [redmine: #105587]
	- 20190923@Johnson: copy danger status from upline [redmine:#120056]
	- 20190909@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200903@Elodie: Remove IsInternal param [Redmine: #134911]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201027@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210202@Winfred : Virtual Rate for Basketball - New 611111 site super must have VR setting = 0%   [Redmine: #149369]	
	- 20210308@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210319@Winfred: Check Site to limit create accounts [Redmine: #151526]
	- 20210405@Johnson: Hide log Gold Deluxe Setting [redmined:#151188]	
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20211104@Johnson: Abnormal remark on Accounting Site [redmine: #163518]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220222@Elodie: Default VR for 789y site [Redmine: #168885]

Param's Explanation:
• @ErrCode:
    = 0: super create master successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
- @SettingStatus: 0: Pro, 1: UAT
*/
BEGIN
    SET NOCOUNT ON   

	DECLARE @Super_site VARCHAR(50), @currency INT, @EnableVR BIT
	SELECT @Super_site = site,
		@currency = currency
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @srecommend
	 
	SET  @Site = ISNULL(NULLIF(@Site,''),@Super_site)

	-------------------BLOCK ADDING NEW USE UMCONFIG----------------------------
	IF @Site = @Super_site
		OR NOT EXISTS ( SELECT 1 FROM Site WITH(NOLOCK) WHERE site = @Site) -- @site = 'ExtAcc'
	BEGIN
		EXEC [Acc_CheckUM] @CustID = @srecommend
			,@FunctionType = 2
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
			,@ReturnUMData = 0
			,@Language = @Language

		IF @ErrCode <> 0 RETURN
	END
	ELSE
	BEGIN -- Direct master cross site
		DECLARE @SiteID int
		SELECT @SiteID = siteid FROM site WITH(NOLOCK) WHERE site = @site

		DECLARE @FromTime VARCHAR(30), @ToTime VARCHAR(30)
	
		SELECT t.SportType,t.SiteID,t.Currency,t.BeginTime,t.EndTime
		INTO #UMConfig
		FROM UMConfig t WITH(NOLOCK)
		WHERE CONVERT(SMALLDATETIME,GETDATE()) BETWEEN t.BeginTime AND t.EndTime
			AND t.Currency IN (0,@currency)
			AND t.SiteID IN (0,@siteid)
			AND (t.FunctionType = 2 
				 OR (t.FunctionType = 1 AND t.LockAddingNew = 1)
				 )
			AND t.SuperID IN (0, @srecommend)
	
		--Delete Non-offered Products
		DELETE ft
		FROM #UMConfig ft
			INNER JOIN SportNonOfferedSiteCurrency nof WITH(NOLOCK)
				ON ft.SportType = nof.SportType
				AND nof.siteID IN (ft.SiteID, 0)
				AND nof.Currency IN (ft.Currency, 0)
		WHERE NOT EXISTS(	SELECT 1 
							FROM ProductSettingDetail p WITH(NOLOCK) 
							WHERE nof.SportType = p.SportType 
								AND nof.BetType <> p.BetType 
								AND p.SettingStatus = 0 
						)

		SELECT @FromTime = CONVERT(VARCHAR,MIN(dateadd(HH,12,t.BeginTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MIN(dateadd(HH,12,t.BeginTime)),8),5)),
			  @ToTime = CONVERT(VARCHAR,MAX(dateadd(HH,12,t.EndTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MAX(dateadd(HH,12,t.EndTime)),8),5))
		FROM #UMConfig t

		IF @FromTime IS NOT NULL AND @ToTime IS NOT NULL
		BEGIN
			SELECT @ErrCode = 90016
				 , @ErrMsg =   REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](90016,@Language),'<FromTime>',@FromTime),'<ToTime>',@ToTime)

			RETURN
		END
	END
	------------------------------END----------------------------------------

	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @creator AND roleid > 4) --Only check on admin user
	BEGIN
		DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
		DECLARE @tmpUserid VARCHAR(50)
		
		SELECT @tmpUserid=CAST(@creator AS VARCHAR(50))
		
		INSERT INTO  @tmp (siteid , site,SpecialGroup)
		SELECT siteid , [site], SpecialGroup FROM NAP_UserControl.dbo.f_GetDeniedSiteByUser(@tmpUserid)	
	
		IF (@site IN (SELECT site FROM @tmp ))
		BEGIN
			SELECT @ErrCode = 110, @ErrMsg ='You don''t have permission to access'
			RETURN
		END
	END
	
----- Elodie @ 01 JUN 2015 -------------------
	BEGIN TRY
		SELECT *
		INTO #tmp_Sports
		FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBAGE')	
	END TRY
	BEGIN CATCH
		IF OBJECT_ID(N'tempdb..#tmp_Sports') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Sports
			INSERT INTO #tmp_Sports
			SELECT *
			FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBTXN')	
		END
	END CATCH

	BEGIN TRY			
		SELECT *
		INTO #tmp_Bettype
		FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_Bettype') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Bettype
			INSERT INTO #tmp_Bettype
			SELECT *
			FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBTXN')	
		END
	END CATCH

	BEGIN TRY		
		SELECT *
		INTO #tmp_GameType
		FROM dbo.f_GetSportTypeBetTypeGameType(3,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_GameType') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_GameType
			INSERT INTO #tmp_GameType
			SELECT *
			FROM dbo.f_GetSportTypeBetTypeGameType(3,'DBTXN')	
		END
	END CATCH
----- /Elodie @ 01 JUN 2015 -------------------

    ----- 20130717@Lukas -------------------
	DECLARE @lastMINUTEMemberCount INT

	SELECT @lastMINUTEMemberCount = COUNT(1)
	  FROM Customer c WITH(NOLOCK)
		INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
	 WHERE ci.srecommend = @srecommend
		AND ci.roleid = 3
		AND creatdate > DATEADD(MINUTE, -10, CURRENT_TIMESTAMP)
		
	IF @lastMINUTEMemberCount > 100
	BEGIN		
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Sorry. You cannot create customer too often.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40029,@Language)
					end,
				@ErrCode = 998	
		RETURN 
	END
    ----- / 20130717@Lukas-----------------
    DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0, @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.srecommend = @srecommend
									AND c.roleid = 3
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			Select	@ErrMsg = CASE @Language  
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056	
			RETURN
		END
	END
--20140619@Johnson: Check IP to create downline-----------------
	DECLARE @isValidIP BIT
	
				EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
    --End check IP--------------------------------------------------

	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @srecommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @srecommend

		IF LEFT(@username,LEN(@uplineUsername)) <> @uplineUsername
		BEGIN
			SELECT @ErrMsg = CASE @Language
						    WHEN 'E' THEN 'This function is under maintenance and not available at the moment. Please kindly check back later. Thank you!'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](90011, @Language)
					     END,				   
				   @ErrCode = 101
			RETURN 
		END
	END 
	-----/20160120@Lukas -----------------


    DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    set @startRun = GETDATE()

    --NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
    --20081218_By_AhWan: KER - 1238537
    --20090112_Wan: unblock KM 194354
    --20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
    IF @srecommend = 726582
    BEGIN
	    Select	@ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Sorry, cannot create master.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40012,@Language)
					    END,@ErrCode = 100	
    	
	    return
    END

    --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @srecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0		RETURN 

    DECLARE 
	    @transcode BIGINT, @pwdexpiry DATETIME,
    	
	    @Credit_AllOtherMaster MONEY, @Credit_AllMember MONEY, @Credit_SAg MONEY,
	    @RoleID_SAg TINYINT, @matchlimit SMALLMONEY,
	    @TransferOption_dec TINYINT,
	    @DisableOutright BIT,
	    --@Ssuspended BIT,
	    @UplineClosed BIT,
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@suspended    BIT = 0,

	    @max_spositiontaking_1 SMALLMONEY,
	    @max_spositiontaking_2 SMALLMONEY,
	    @max_spositiontaking_3 SMALLMONEY,
	    @max_spositiontaking_4 SMALLMONEY,
	    @max_spositiontaking_5 SMALLMONEY,
	    @max_spositiontaking_6 SMALLMONEY,
	    @max_spositiontaking_7 SMALLMONEY,
	    @max_spositiontaking_8 SMALLMONEY,
	    @max_spositiontaking_9 SMALLMONEY,
	    @max_spositiontaking_10 SMALLMONEY,
	    @max_v2spositiontaking_10 SMALLMONEY,
	    @max_v3spositiontaking_10 SMALLMONEY,
	    @max_v5spositiontaking_10 SMALLMONEY,
	    @max_v8spositiontaking_10 SMALLMONEY,
	    @max_v10spositiontaking_10 SMALLMONEY,
	    @max_v11spositiontaking_10 SMALLMONEY,
	    @max_v99spositiontaking_10 SMALLMONEY,
	    @max_spositiontaking_9999 SMALLMONEY,
	    @max_slivepositiontaking_1 SMALLMONEY,
	    @max_slivepositiontaking_3 SMALLMONEY,
	    @max_slivepositiontaking_7 SMALLMONEY,
	    @max_slivepositiontaking_8 SMALLMONEY,

	    @max_v2spositiontaking_1 SMALLMONEY,
	    @max_v2spositiontaking_2 SMALLMONEY,
	    @max_v2spositiontaking_3 SMALLMONEY,
	    @max_v2spositiontaking_7 SMALLMONEY,
	    @max_v2spositiontaking_8 SMALLMONEY,
 
	    @max_v2spositiontaking_20 SMALLMONEY,
	    @max_v2spositiontaking_9999 SMALLMONEY,
    	
	    @max_v3spositiontaking_1 SMALLMONEY,
	    @max_v3spositiontaking_2 SMALLMONEY,
	    @max_v3spositiontaking_3 SMALLMONEY,	
	    @max_v3spositiontaking_20 SMALLMONEY,
    	
	    @max_v5spositiontaking_1 SMALLMONEY,
	    @max_v5spositiontaking_2 SMALLMONEY,
	    @max_v5spositiontaking_3 SMALLMONEY,	
	    @max_v5spositiontaking_20 SMALLMONEY,
	    @max_v5spositiontaking_9999 SMALLMONEY,
    	
	    @max_v8spositiontaking_1 SMALLMONEY,	
	    @max_v8spositiontaking_3 SMALLMONEY,	
	    @max_v8spositiontaking_20 SMALLMONEY,
    	
	    @max_v10spositiontaking_1 SMALLMONEY,
	    @max_v10spositiontaking_2 SMALLMONEY,
	    @max_v10spositiontaking_3 SMALLMONEY,	
	    @max_v10spositiontaking_20 SMALLMONEY,
    	
	    @max_v11spositiontaking_1 SMALLMONEY,	
	    @max_v11spositiontaking_20 SMALLMONEY,

	    @max_v99spositiontaking_1 SMALLMONEY,
	    @max_v99spositiontaking_2 SMALLMONEY,
	    @max_v99spositiontaking_3 SMALLMONEY,		
	    @max_v99spositiontaking_20 SMALLMONEY,

	    @max_v99spositiontaking_9 SMALLMONEY,
		@max_v99spositiontaking_9999 SMALLMONEY,
	  
	    @max_v161spositiontaking_81 SMALLMONEY,							
	    @max_v161spositiontaking_83 SMALLMONEY,
	    @max_v161spositiontaking_86 SMALLMONEY,
	    @max_v161spositiontaking_88 SMALLMONEY,
    	
	    @max_v161slivepositiontaking_85 SMALLMONEY,
	    @max_v161slivepositiontaking_86 SMALLMONEY,
	    @max_v161slivepositiontaking_87 SMALLMONEY,
	    @max_v161slivepositiontaking_89 SMALLMONEY,
	    @max_v161slivepositiontaking_90 SMALLMONEY,
    	
	    @isauto_spositiontaking_1 BIT,
	    @isauto_spositiontaking_2 BIT,
	    @isauto_spositiontaking_3 BIT,
	    @isauto_spositiontaking_4 BIT,
	    @isauto_spositiontaking_5 BIT,
	    @isauto_spositiontaking_6 BIT,
	    @isauto_spositiontaking_7 BIT,
	    @isauto_spositiontaking_8 BIT,
	    @isauto_spositiontaking_9 BIT,
	    @isauto_spositiontaking_10 BIT,
	    @isauto_v2spositiontaking_10 BIT,
	    @isauto_v3spositiontaking_10 BIT,
	    @isauto_v5spositiontaking_10 BIT,
	    @isauto_v8spositiontaking_10 BIT,
	    @isauto_v10spositiontaking_10 BIT,
	    @isauto_v11spositiontaking_10 BIT,
	    @isauto_v99spositiontaking_10 BIT,
	    @isauto_spositiontaking_9999 BIT,
    	
	    @isauto_slivepositiontaking_1 BIT,
	    @isauto_slivepositiontaking_3 BIT,
	    @isauto_slivepositiontaking_7 BIT,
	    @isauto_slivepositiontaking_8 BIT,
    	
	    @isauto_v2spositiontaking_1 BIT,
	    @isauto_v2spositiontaking_2 BIT,
	    @isauto_v2spositiontaking_3 BIT,
	    @isauto_v2spositiontaking_7 BIT,
	    @isauto_v2spositiontaking_8 BIT,

	    @isauto_v2spositiontaking_20 BIT,
	    @isauto_v2spositiontaking_9999 BIT,
    	
	    @isauto_v3spositiontaking_1 BIT,
	    @isauto_v3spositiontaking_2 BIT,
	    @isauto_v3spositiontaking_3 BIT,	
	    @isauto_v3spositiontaking_20 BIT,
    	
	    @isauto_v5spositiontaking_1 BIT,
	    @isauto_v5spositiontaking_2 BIT,
	    @isauto_v5spositiontaking_3 BIT,	
	    @isauto_v5spositiontaking_20 BIT,
	    @isauto_v5spositiontaking_9999 BIT,	
    	
	    @isauto_v8spositiontaking_1 BIT,	
	    @isauto_v8spositiontaking_3 BIT,	
	    @isauto_v8spositiontaking_20 BIT,
    	
	    @isauto_v10spositiontaking_1 BIT,
	    @isauto_v10spositiontaking_2 BIT,
	    @isauto_v10spositiontaking_3 BIT,	
	    @isauto_v10spositiontaking_20 BIT,
    	
	    @isauto_v11spositiontaking_1 BIT,	
	    @isauto_v11spositiontaking_20 BIT,

	    @isauto_v99spositiontaking_1 BIT,
	    @isauto_v99spositiontaking_2 BIT,
	    @isauto_v99spositiontaking_3 BIT,		
	    @isauto_v99spositiontaking_20 BIT,

	    @isauto_v99spositiontaking_9 BIT,
		@isauto_v99spositiontaking_9999 BIT,
	 
	    @isauto_v161spositiontaking_81 BIT,					
	    @isauto_v161spositiontaking_83 BIT,
	    @isauto_v161spositiontaking_86 BIT,
	    @isauto_v161spositiontaking_88 BIT,
    	
	    @isauto_v161slivepositiontaking_85 BIT,
	    @isauto_v161slivepositiontaking_86 BIT,
	    @isauto_v161slivepositiontaking_87 BIT,
	    @isauto_v161slivepositiontaking_89 BIT,
	    @isauto_v161slivepositiontaking_90 BIT,	
	    @DoubleCommLosing	BIT,

	    --Keno
	    @HideKeno BIT = 1,
		@DisableGoldDeluxe BIT = 0,
		@HideGoldDeluxe BIT = 1,

		
		@DisableSuperLive BIT = 0,
		@DangerSuper TINYINT = 0,
		@DangerSuper2 TINYINT = 0,
		@DangerSuper3 TINYINT = 0,
		@DangerSuper4 TINYINT = 0,
		@DangerSuper5 TINYINT = 0
		

    DECLARE @ErrType VARCHAR(4000)	
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SELECT @username = rtrim(ltrim(@username))

    SELECT 
	    --@currency = currency,
	    --@Ssuspended = cs.reject,
	    @UplineClosed = cs.closed,
	    @Credit_SAg = isnull(credit, 0),
	    @matchlimit = matchlimit,
	
	    @DisableNumber = CASE WHEN ci.DisableNumber = 1 THEN 1 ELSE @DisableNumber END,	   
	    @DisableCasino = CASE WHEN DisableCasino = 1 THEN 1 ELSE @DisableCasino END, 	 
	    @DisableOutright = DisableOutright,
	    
	    @DoubleCommLosing = DoubleCommLosing,
	    @EnableVR = ISNULL(virtualmultiplier,1),	  
	    @autosuspend = ISNULL(autosuspend, 0 ),
	    @autosuspend2 = ISNULL(autosuspend2, 0),
	    --Keno
	    @HideKeno = HideKeno,
		
		@DisableGoldDeluxe = DisableGoldDeluxe,
		@HideGoldDeluxe = HideGoldDeluxe,
		
		@DisableSuperLive = DisableSuperLive,
		@DangerSuper = Danger,
		@DangerSuper2 = Danger2,
		@DangerSuper3 = Danger3,
		@DangerSuper4 = Danger4,
		@DangerSuper5 = Danger5
    FROM CustInfo ci WITH(NOLOCK)
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs	
    WHERE CustID = @srecommend

	--Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @srecommend)				
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	END	

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsValid BIT
    SELECT @IsValid = 0
    SELECT @ErrCode = 0
    
    -- MyanmarOdds
	-- Reset discount value in case its value > upline
	DECLARE @IsMyanmarOdds BIT = 0
	
	 IF @srecommend > 100 -- get site FROM upline IF not direct master
	 BEGIN
		   SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Super_site)
	 END
	 ELSE
	 BEGIN
		   	-- For Direct Master
			SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)
	 END

	IF @IsMyanmarOdds = 1 AND dbo.fn_IsMyanmarOdds (@srecommend) <> 1
	BEGIN
		 SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Cannot add Direct Master under Myanmar Odds site(s).'
						    END, @ErrCode = 361
	    RETURN	
	END
		
	IF @IsMyanmarOdds = 1
	BEGIN
		SELECT @discountMyanmarOdds = CASE 
											WHEN @discountMyanmarOdds > commRate THEN commRate
											ELSE @discountMyanmarOdds  
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @srecommend
			AND sporttype = 1   
			AND bettype = 1  
	   SELECT @groupb = 0, @groupc = 0, @groupd = 0		
	END
    
    EXEC dbo.Acc_CustomerInsMember_SAg_CheckParam
			@custid = @custid OUTPUT,
		    @credit = @credit,
		    @srecommend = @srecommend,
		    @spositiontaking_1 = @spositiontaking_1,
		    @spositiontaking_2 = @spositiontaking_2,
		    @spositiontaking_3 = @spositiontaking_3,
		    @spositiontaking_4 = @spositiontaking_4,
		    @spositiontaking_5 = @spositiontaking_5,
		    @spositiontaking_6 = @spositiontaking_6,
		    @spositiontaking_7 = @spositiontaking_7,
		    @spositiontaking_8 = @spositiontaking_8,
		    @spositiontaking_9 = @spositiontaking_9,
		    @spositiontaking_10 = @spositiontaking_10,
		    @v2spositiontaking_10 = @v2spositiontaking_10,
		    @v3spositiontaking_10 = @v3spositiontaking_10,
		    @v5spositiontaking_10 = @v5spositiontaking_10,
		    @v8spositiontaking_10 = @v8spositiontaking_10,
		    @v10spositiontaking_10 = @v10spositiontaking_10,
		    @v11spositiontaking_10 = @v11spositiontaking_10,
		    @v99spositiontaking_10 = @v99spositiontaking_10,
		    @spositiontaking_9999 = @spositiontaking_9999,
		    @slivepositiontaking_1 = @slivepositiontaking_1,
		    @slivepositiontaking_3 = @slivepositiontaking_3,
		    @slivepositiontaking_7 = @slivepositiontaking_7,
		    @slivepositiontaking_8 = @slivepositiontaking_8,
		    @v2spositiontaking_1 = @v2spositiontaking_1,
		    @v2spositiontaking_2 = @v2spositiontaking_2,
		    @v2spositiontaking_3 = @v2spositiontaking_3,
		    @v2spositiontaking_7 = @v2spositiontaking_7,
		    @v2spositiontaking_8 = @v2spositiontaking_8,
   
		    @v2spositiontaking_20 = @v2spositiontaking_20,
		    @v2spositiontaking_9999 = @v2spositiontaking_9999,
		    
		    @v3spositiontaking_1 = @v3spositiontaking_1,
		    @v3spositiontaking_2 = @v3spositiontaking_2,
		    @v3spositiontaking_3 = @v3spositiontaking_3,
		    @v3spositiontaking_20 = @v3spositiontaking_20,
		    @v5spositiontaking_1 = @v5spositiontaking_1,
		    @v5spositiontaking_2 = @v5spositiontaking_2,
		    @v5spositiontaking_3 = @v5spositiontaking_3,
		    @v5spositiontaking_20 = @v5spositiontaking_20,
		    @v5spositiontaking_9999 = @v5spositiontaking_9999,
		    @v8spositiontaking_1 = @v8spositiontaking_1,
		    @v8spositiontaking_3 = @v8spositiontaking_3,
		    @v8spositiontaking_20 = @v8spositiontaking_20,
		    @v10spositiontaking_1 = @v10spositiontaking_1,
		    @v10spositiontaking_2 = @v10spositiontaking_2,
		    @v10spositiontaking_3 = @v10spositiontaking_3,
		    @v10spositiontaking_20 = @v10spositiontaking_20,
		    @v11spositiontaking_1 = @v11spositiontaking_1,
		    @v11spositiontaking_20 = @v11spositiontaking_20,

		    @v99spositiontaking_1 = @v99spositiontaking_1,
		    @v99spositiontaking_2 = @v99spositiontaking_2,
		    @v99spositiontaking_3 = @v99spositiontaking_3,		
		    @v99spositiontaking_20 = @v99spositiontaking_20,

		    @v99spositiontaking_9 = @v99spositiontaking_9,
			@v99spositiontaking_9999 = @v99spositiontaking_9999,
		
		    @v161spositiontaking_81 = @v161spositiontaking_81,
		    @v161spositiontaking_83 = @v161spositiontaking_83,
		    @v161spositiontaking_86 = @v161spositiontaking_86,
		    @v161spositiontaking_88 = @v161spositiontaking_88,
    		
		    @v161slivepositiontaking_85 = @v161slivepositiontaking_85,
		    @v161slivepositiontaking_86 = @v161slivepositiontaking_86,
		    @v161slivepositiontaking_87 = @v161slivepositiontaking_87,
		    @v161slivepositiontaking_89 = @v161slivepositiontaking_89,
		    @v161slivepositiontaking_90 = @v161slivepositiontaking_90,
    		
		    @groupa = @groupa,
		    @groupb = @groupb,
		    @groupc = @groupc,
		    @groupd = @groupd,
		    @discountcs = @discountcs,
		    @discount1x2 = @discount1x2, --1x2

			-- MyanmarOdds
			@discountMyanmarOdds = @discountMyanmarOdds,

		    @auto_spositiontaking_1 = @auto_spositiontaking_1,
		    @auto_spositiontaking_2 = @auto_spositiontaking_2,
		    @auto_spositiontaking_3 = @auto_spositiontaking_3,
		    @auto_spositiontaking_4 = @auto_spositiontaking_4,
		    @auto_spositiontaking_5 = @auto_spositiontaking_5,
		    @auto_spositiontaking_6 = @auto_spositiontaking_6,
		    @auto_spositiontaking_7 = @auto_spositiontaking_7,
		    @auto_spositiontaking_8 = @auto_spositiontaking_8,
		    @auto_spositiontaking_9 = @auto_spositiontaking_9,
		    @auto_spositiontaking_10 = @auto_spositiontaking_10,
		    @auto_v2spositiontaking_10 = @auto_v2spositiontaking_10,
		    @auto_v3spositiontaking_10 = @auto_v3spositiontaking_10,
		    @auto_v5spositiontaking_10 = @auto_v5spositiontaking_10,
		    @auto_v8spositiontaking_10 = @auto_v8spositiontaking_10,
		    @auto_v10spositiontaking_10 = @auto_v10spositiontaking_10,
		    @auto_v11spositiontaking_10 = @auto_v11spositiontaking_10,
		    @auto_v99spositiontaking_10 = @auto_v99spositiontaking_10,

		    @auto_spositiontaking_9999 = @auto_spositiontaking_9999,
		    @auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
		    @auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
		    @auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
		    @auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
		    @auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
		    @auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
		    @auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
		    @auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
		    @auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,

		    @auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
		    @auto_v2spositiontaking_9999 = @auto_v2spositiontaking_9999,
		    		
		    @auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
		    @auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
		    @auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,
		    @auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,
		    @auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
		    @auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
		    @auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,
		    @auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
		    @auto_v5spositiontaking_9999 = @auto_v5spositiontaking_9999,
		    @auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
		    @auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,
		    @auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,
		    @auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
		    @auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
		    @auto_v10spositiontaking_3 = @auto_v10spositiontaking_3,
		    @auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,
		    @auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,
		    @auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,

		    @auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
		    @auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
		    @auto_v99spositiontaking_3 = @auto_v99spositiontaking_3,		
		    @auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,

		    @auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,		
			@auto_v99spositiontaking_9999 = @auto_v99spositiontaking_9999,		   
    	
		    @auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
		    @auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
		    @auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
		    @auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
    		
		    @auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
		    @auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
		    @auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
		    @auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
		    @auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

		    @mpositiontaking_1 = @mpositiontaking_1,
		    @mpositiontaking_2 = @mpositiontaking_2,
		    @mpositiontaking_3 = @mpositiontaking_3,
		    @mpositiontaking_4 = @mpositiontaking_4,
		    @mpositiontaking_5 = @mpositiontaking_5,
		    @mpositiontaking_6 = @mpositiontaking_6,
		    @mpositiontaking_7 = @mpositiontaking_7,
		    @mpositiontaking_8 = @mpositiontaking_8,
		    @mpositiontaking_9 = @mpositiontaking_9,
		    @mpositiontaking_10 = @mpositiontaking_10,
		    @v2mpositiontaking_10 = @v2mpositiontaking_10,		
		    @v3mpositiontaking_10 = @v3mpositiontaking_10,		
		    @v5mpositiontaking_10 = @v5mpositiontaking_10,		
		    @v8mpositiontaking_10 = @v8mpositiontaking_10,		
		    @v10mpositiontaking_10 = @v10mpositiontaking_10,		
		    @v11mpositiontaking_10 = @v11mpositiontaking_10,		
		    @v99mpositiontaking_10 = @v99mpositiontaking_10,				
		    @mpositiontaking_9999 = @mpositiontaking_9999,
		    @mlivepositiontaking_1 = @mlivepositiontaking_1,
		    @mlivepositiontaking_3 = @mlivepositiontaking_3,
		    @mlivepositiontaking_7 = @mlivepositiontaking_7,
		    @mlivepositiontaking_8 = @mlivepositiontaking_8,
		    @v2mpositiontaking_1 = @v2mpositiontaking_1,
		    @v2mpositiontaking_2 = @v2mpositiontaking_2,
		    @v2mpositiontaking_3 = @v2mpositiontaking_3,
		    @v2mpositiontaking_7 = @v2mpositiontaking_7,
		    @v2mpositiontaking_8 = @v2mpositiontaking_8,

		    @v2mpositiontaking_20 = @v2mpositiontaking_20,
		    @v2mpositiontaking_9999 = @v2mpositiontaking_9999,
		    
		    @v3mpositiontaking_1 = @v3mpositiontaking_1,
		    @v3mpositiontaking_2 = @v3mpositiontaking_2,
		    @v3mpositiontaking_3 = @v3mpositiontaking_3,
		    @v3mpositiontaking_20 = @v3mpositiontaking_20,
		    @v5mpositiontaking_1 = @v5mpositiontaking_1,
		    @v5mpositiontaking_2 = @v5mpositiontaking_2,
		    @v5mpositiontaking_3 = @v5mpositiontaking_3,
		    @v5mpositiontaking_20 = @v5mpositiontaking_20,
		    @v5mpositiontaking_9999 = @v5mpositiontaking_9999,
		    @v8mpositiontaking_1 = @v8mpositiontaking_1,
		    @v8mpositiontaking_3 = @v8mpositiontaking_3,
		    @v8mpositiontaking_20 = @v8mpositiontaking_20,
		    @v10mpositiontaking_1 = @v10mpositiontaking_1,
		    @v10mpositiontaking_2 = @v10mpositiontaking_2,
		    @v10mpositiontaking_3 = @v10mpositiontaking_3,
		    @v10mpositiontaking_20 = @v10mpositiontaking_20,
		    @v11mpositiontaking_1 = @v11mpositiontaking_1,
		    @v11mpositiontaking_20 = @v11mpositiontaking_20,

		    @v99mpositiontaking_1 = @v99mpositiontaking_1,
		    @v99mpositiontaking_2 = @v99mpositiontaking_2,
		    @v99mpositiontaking_3 = @v99mpositiontaking_3,		
		    @v99mpositiontaking_20 = @v99mpositiontaking_20,

		    @v99mpositiontaking_9 = @v99mpositiontaking_9,  
			@v99mpositiontaking_9999 = @v99mpositiontaking_9999,    		
		   
		    @v161mpositiontaking_81 = @v161mpositiontaking_81,
		    @v161mpositiontaking_83 = @v161mpositiontaking_83,
		    @v161mpositiontaking_86 = @v161mpositiontaking_86,
		    @v161mpositiontaking_88 = @v161mpositiontaking_88,
    		
		    @v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
		    @v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
		    @v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
		    @v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
		    @v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,
	
	
		    @isvalid = @isvalid OUTPUT,
		    @errmsg = @errmsg OUTPUT,
		    @errcode = @errcode OUTPUT,
		    @language = @language,
			@SystemID = @SystemID,
			@creator = @creator

    IF @IsValid = 0
    BEGIN
	    return
    END

	DECLARE @BetSettingXML VARCHAR(8000) = ''

	EXEC Acc_CustomerInsMember_CheckBetSetting
		 @custid			= @srecommend
		,@minbet			= @minbet
		,@maxbet			= @maxbet
		,@maxpermatch		= @maxpermatch

		,@minbetv2			= @minbetv2
		,@maxbetv2			= @maxbetv2
		,@maxpermatchv2		= @maxpermatchv2

		,@minbetv3			= @minbetv3
		,@maxbetv3			= @maxbetv3
		,@maxpermatchv3		= @maxpermatchv3

		,@minbetv5			= @minbetv5
		,@maxbetv5			= @maxbetv5
		,@maxpermatchv5		= @maxpermatchv5

		,@minbetv8			= @minbetv8
		,@maxbetv8			= @maxbetv8
		,@maxpermatchv8		= @maxpermatchv8

		,@minbetv10			= @minbetv10
		,@maxbetv10			= @maxbetv10
		,@maxpermatchv10	= @maxpermatchv10

		,@minbetv11			= @minbetv11
		,@maxbetv11			= @maxbetv11
		,@maxpermatchv11	= @maxpermatchv11

		,@minbetv99			= @minbetv99
		,@maxbetv99			= @maxbetv99
		,@maxpermatchv99	= @maxpermatchv99

		,@minbetv99mp		= @minbetv99mp
		,@maxbetv99mp		= @maxbetv99mp
		,@maxpermatchv99mp	= @maxpermatchv99mp

		,@minbetv1mp		= @minbetv1mp
		,@maxbetv1mp		= @maxbetv1mp
		,@maxpermatchv1mp	= @maxpermatchv1mp

		,@minbetv161		= @minbetv161
		,@maxbetv161		= @maxbetv161
		,@maxpermatchv161	= @maxpermatchv161
		,@MaxPerBallv161	= @MaxPerBallv161

		,@minbetv164		= @minbetv164
		,@maxbetv164		= @maxbetv164
		,@maxpermatchv164	= @maxpermatchv164

		,@maxPOpermatch		= @maxPOpermatch
		,@maxPOpermatchv2	= @maxPOpermatchv2
		,@maxPOpermatchv3	= @maxPOpermatchv3
		,@maxPOpermatchv5	= @maxPOpermatchv5
		,@maxPOpermatchv8	= @maxPOpermatchv8
		,@maxPOpermatchv10	= @maxPOpermatchv10
		,@maxPOpermatchv11	= @maxPOpermatchv11
		,@maxPOpermatchv99	= @maxPOpermatchv99
		,@maxPOpermatchv99mp= @maxPOpermatchv99mp
		,@maxPOpermatchv1mp	= @maxPOpermatchv1mp

		--Saba
	    ,@minbetv1saba              	= @minbetv1saba
	    ,@maxbetv1saba              	= @maxbetv1saba
	    ,@maxpermatchv1saba         	= @maxpermatchv1saba 
	    ,@MaxPOpermatchv1saba   		= @MaxPOpermatchv1saba 
	    
	    ,@minbetv2saba              	= @minbetv2saba
	    ,@maxbetv2saba              	= @maxbetv2saba
	    ,@maxpermatchv2saba         	= @maxpermatchv2saba 
	    ,@MaxPOpermatchv2saba   		= @MaxPOpermatchv2saba 

		,@language			= @language
		,@SystemID			= @SystemID
		,@ErrCode			= @ErrCode OUTPUT
		,@ErrMsg			= @ErrMsg OUTPUT
		,@BetSettingXML		= @BetSettingXML OUTPUT

	IF @ErrCode <> 0
    BEGIN
	    RETURN
    END
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'This username is not available.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
					    END		
	    SELECT @ErrCode = 1101
	    RETURN
    END
    SELECT @pwdexpiry = DATEADD(dd, 30, GETDATE())

  
   
    SELECT @max_spositiontaking_1 = spositiontaking, @max_slivepositiontaking_1 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=1
    SELECT @max_spositiontaking_3 = spositiontaking, @max_slivepositiontaking_3 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=1
    SELECT @max_spositiontaking_7 = spositiontaking, @max_slivepositiontaking_7 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=1
    SELECT @max_spositiontaking_8 = spositiontaking, @max_slivepositiontaking_8 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=1
    SELECT @max_spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=1
    SELECT @max_spositiontaking_4 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=4 AND sporttype=1
    SELECT @max_spositiontaking_5 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=5 AND sporttype=1
    SELECT @max_spositiontaking_6 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=6 AND sporttype=1
    SELECT @max_spositiontaking_9 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=1
    SELECT @max_spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=1
    SELECT @max_v2spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=2
    SELECT @max_v3spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=3
    SELECT @max_v5spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=5
    SELECT @max_v8spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=8
    SELECT @max_v10spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=10
    SELECT @max_v11spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=11
    SELECT @max_v99spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=99
    SELECT @max_spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=1

    SELECT @max_v2spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=2
    SELECT @max_v2spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=2
    SELECT @max_v2spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=2
    
    SELECT @max_v2spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=2
    
    SELECT @max_v2spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=2
    

    SELECT @max_v3spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=3
    SELECT @max_v3spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=3
    SELECT @max_v3spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=3
    SELECT @max_v3spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=3

    SELECT @max_v5spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=5
    SELECT @max_v5spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=5
    SELECT @max_v5spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=5
    SELECT @max_v5spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=5
    SELECT @max_v5spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=5

    SELECT @max_v8spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=8
    SELECT @max_v8spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=8
    SELECT @max_v8spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=8

    SELECT @max_v10spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=10
    SELECT @max_v10spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=10
    SELECT @max_v10spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=10
    SELECT @max_v10spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=10

    SELECT @max_v11spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=11
    SELECT @max_v11spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=11

    SELECT @max_v99spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=99
    SELECT @max_v99spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=99

    SELECT @max_v99spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=99
    SELECT @max_v99spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=99

    SELECT @max_v99spositiontaking_9 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=99
	SELECT @max_v99spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=99
   
    SELECT @max_v161spositiontaking_81 = spositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 81 AND sporttype = 161
    SELECT @max_v161spositiontaking_83 = spositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 83 AND sporttype = 161
    SELECT @max_v161spositiontaking_88 = spositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 88 AND sporttype = 161
    SELECT @max_v161slivepositiontaking_85 = slivepositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 85 AND sporttype = 161
    SELECT @max_v161spositiontaking_86 = spositiontaking, @max_v161slivepositiontaking_86 = slivepositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 86 AND sporttype = 161
    SELECT @max_v161slivepositiontaking_87 = slivepositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 87 AND sporttype = 161
    SELECT @max_v161slivepositiontaking_89 = slivepositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 89 AND sporttype = 161
    SELECT @max_v161slivepositiontaking_90 = slivepositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 90 AND sporttype = 161

    
    --check s3+m3<=s4
    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + sports.name + '-' + bettype.name + '-Max:'+ dbo.f_FomatNumericToChar(max_spositiontaking)
	    + CASE WHEN b.sporttype in (1,161) AND b.bettype in (1,3,7,8,85,86,87,89,90) THEN '--Live:'+ dbo.f_FomatNumericToChar(max_slivepositiontaking) ELSE '' END + '<br>'
    FROM #tmp_Sports sports inner join
    (
				    SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS spositiontaking, @slivepositiontaking_1 AS slivepositiontaking, @mpositiontaking_1 AS mpositiontaking, @mlivepositiontaking_1 AS mlivepositiontaking, @max_spositiontaking_1 AS max_spositiontaking,  @max_slivepositiontaking_1 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS spositiontaking, @slivepositiontaking_3 AS slivepositiontaking, @mpositiontaking_3 AS mpositiontaking, @mlivepositiontaking_3 AS mlivepositiontaking, @max_spositiontaking_3 AS max_spositiontaking,  @max_slivepositiontaking_3 AS max_slivepositiontaking
	    union all 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS spositiontaking, @slivepositiontaking_7 AS slivepositiontaking, @mpositiontaking_7 AS mpositiontaking, @mlivepositiontaking_7 AS mlivepositiontaking, @max_spositiontaking_7 AS max_spositiontaking,  @max_slivepositiontaking_7 AS max_slivepositiontaking
	    union all 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS spositiontaking, @slivepositiontaking_8 AS slivepositiontaking, @mpositiontaking_8 AS mpositiontaking, @mlivepositiontaking_8 AS mlivepositiontaking, @max_spositiontaking_8 AS max_spositiontaking,  @max_slivepositiontaking_8 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_4 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_4 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_5 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_5 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_6 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_6 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_9 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_9 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 2 AS sporttype, @v2spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 3 AS sporttype, @v3spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v3mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v3spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 5 AS sporttype, @v5spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 8 AS sporttype, @v8spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v8mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v8spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 10 AS sporttype, @v10spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v10mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v10spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 11 AS sporttype, @v11spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v11mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v11spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 10 AS bettype, 99 AS sporttype, @v99spositiontaking_10 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_10 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_10 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 9999 AS bettype, 1 AS sporttype, @spositiontaking_9999 AS spositiontaking, 0 AS slivepositiontaking, @mpositiontaking_9999 AS mpositiontaking, 0 AS mlivepositiontaking, @max_spositiontaking_9999 AS max_spositiontaking,  0 AS max_slivepositiontaking

	    union all 	SELECT 1 AS bettype, 2 AS sporttype, @v2spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 2 AS sporttype, @v2spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 2 AS sporttype, @v2spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking
		union all 	SELECT 20 AS bettype, 2 AS sporttype, @v2spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    
	    union all 	SELECT 9999 AS bettype, 2 AS sporttype, @v2spositiontaking_9999 AS spositiontaking, 0 AS slivepositiontaking, @v2mpositiontaking_9999 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v2spositiontaking_9999 AS max_spositiontaking,  0 AS max_slivepositiontaking

	    union all 	SELECT 1 AS bettype, 3 AS sporttype, @v3spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v3mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v3spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 3 AS sporttype, @v3spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @v3mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v3spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 3 AS sporttype, @v3spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v3mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v3spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 20 AS bettype, 3 AS sporttype, @v3spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v3mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v3spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking
    	
	    union all 	SELECT 1 AS bettype, 5 AS sporttype, @v5spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 5 AS sporttype, @v5spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 5 AS sporttype, @v5spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 20 AS bettype, 5 AS sporttype, @v5spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 9999 AS bettype, 5 AS sporttype, @v5spositiontaking_9999 AS spositiontaking, 0 AS slivepositiontaking, @v5mpositiontaking_9999 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v5spositiontaking_9999 AS max_spositiontaking,  0 AS max_slivepositiontaking
    	
	    union all 	SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v8mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v8spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v8mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v8spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v8mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v8spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking
    	
	    union all 	SELECT 1 AS bettype, 10 AS sporttype, @v10spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v10mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v10spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 10 AS sporttype, @v10spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @v10mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v10spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 10 AS sporttype, @v10spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v10mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v10spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 20 AS bettype, 10 AS sporttype, @v10spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v10mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v10spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking
    	
	    union all 	SELECT 1 AS bettype, 11 AS sporttype, @v11spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v11mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v11spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 20 AS bettype, 11 AS sporttype, @v11spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v11mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v11spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking

	    union all 	SELECT 1 AS bettype, 99 AS sporttype, @v99spositiontaking_1 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_1 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_1 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 2 AS bettype, 99 AS sporttype, @v99spositiontaking_2 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_2 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_2 AS max_spositiontaking,  0 AS max_slivepositiontaking
	    union all 	SELECT 3 AS bettype, 99 AS sporttype, @v99spositiontaking_3 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_3 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_3 AS max_spositiontaking,  0 AS max_slivepositiontaking	
	    union all 	SELECT 20 AS bettype, 99 AS sporttype, @v99spositiontaking_20 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_20 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_20 AS max_spositiontaking,  0 AS max_slivepositiontaking

	    union all 	SELECT 9 AS bettype, 99 AS sporttype, @v99spositiontaking_9 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_9 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_9 AS max_spositiontaking,  0 AS max_slivepositiontaking
		union all 	SELECT 9999 AS bettype, 99 AS sporttype, @v99spositiontaking_9999 AS spositiontaking, 0 AS slivepositiontaking, @v99mpositiontaking_9999 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v99spositiontaking_9999 AS max_spositiontaking,  0 AS max_slivepositiontaking
			   
	    union all   SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS spositiontaking, 0 AS slivepositiontaking, @v161mpositiontaking_81 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v161spositiontaking_81 AS max_positiontaking, 0 AS max_slivepositiontaking
	    union all   SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS spositiontaking, 0 AS slivepositiontaking, @v161mpositiontaking_83 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v161spositiontaking_83 AS max_positiontaking, 0 AS max_slivepositiontaking
	    union all   SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS spositiontaking, 0 AS slivepositiontaking, @v161mpositiontaking_88 AS mpositiontaking, 0 AS mlivepositiontaking, @max_v161spositiontaking_88 AS max_positiontaking, 0 AS max_slivepositiontaking	
	    union all   SELECT 85 AS bettype, 161 AS sporttype, 0 AS spositiontaking, @v161slivepositiontaking_85 AS slivepositiontaking, 0 AS mpositiontaking, @v161mlivepositiontaking_85 AS mlivepositiontaking, 0 AS max_positiontaking, @max_v161slivepositiontaking_85 AS max_slivepositiontaking
	    union all   SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS spositiontaking, @v161slivepositiontaking_86 AS slivepositiontaking, @v161mpositiontaking_86 AS mpositiontaking, @v161mlivepositiontaking_86 AS mlivepositiontaking, @max_v161spositiontaking_86 AS max_spositiontaking, @max_v161slivepositiontaking_86 AS max_slivepositiontaking
	    union all   SELECT 87 AS bettype, 161 AS sporttype, 0 AS spositiontaking, @v161slivepositiontaking_87 AS slivepositiontaking, 0 AS mpositiontaking, @v161mlivepositiontaking_87 AS mlivepositiontaking, 0 AS max_positiontaking, @max_v161slivepositiontaking_87 AS max_slivepositiontaking
	    union all   SELECT 89 AS bettype, 161 AS sporttype, 0 AS spositiontaking, @v161slivepositiontaking_89 AS slivepositiontaking, 0 AS mpositiontaking, @v161mlivepositiontaking_89 AS mlivepositiontaking, 0 AS max_positiontaking, @max_v161slivepositiontaking_89 AS max_slivepositiontaking
	    union all   SELECT 90 AS bettype, 161 AS sporttype, 0 AS spositiontaking, @v161slivepositiontaking_90 AS slivepositiontaking, 0 AS mpositiontaking, @v161mlivepositiontaking_90 AS mlivepositiontaking, 0 AS max_positiontaking, @max_v161slivepositiontaking_90 AS max_slivepositiontaking
    			
	    ) AS b on sports.ID = b.sporttype
	    inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	    WHERE (spositiontaking + mpositiontaking>max_spositiontaking)
		    or (slivepositiontaking + mlivepositiontaking>max_slivepositiontaking)


    IF @ErrType <>''
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Wrong position taking (max for super set by company).<br>'+@ErrType
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](20004,@Language) + '<br>' + @ErrType
						    END
	    SELECT @ErrCode = 104
	    RETURN 
    END


    SELECT @auto_spositiontaking_1=  CASE WHEN @auto_spositiontaking_1>@max_spositiontaking_1 THEN @max_spositiontaking_1 ELSE @auto_spositiontaking_1 END
    SELECT @auto_spositiontaking_2=  CASE WHEN @auto_spositiontaking_2>@max_spositiontaking_2 THEN @max_spositiontaking_2 ELSE @auto_spositiontaking_2 END
    SELECT @auto_spositiontaking_3=  CASE WHEN @auto_spositiontaking_3>@max_spositiontaking_3 THEN @max_spositiontaking_3 ELSE @auto_spositiontaking_3 END
    SELECT @auto_spositiontaking_4=  CASE WHEN @auto_spositiontaking_4>@max_spositiontaking_4 THEN @max_spositiontaking_4 ELSE @auto_spositiontaking_4 END
    SELECT @auto_spositiontaking_5=  CASE WHEN @auto_spositiontaking_5>@max_spositiontaking_5 THEN @max_spositiontaking_5 ELSE @auto_spositiontaking_5 END
    SELECT @auto_spositiontaking_6=  CASE WHEN @auto_spositiontaking_6>@max_spositiontaking_6 THEN @max_spositiontaking_6 ELSE @auto_spositiontaking_6 END
    SELECT @auto_spositiontaking_7=  CASE WHEN @auto_spositiontaking_7>@max_spositiontaking_7 THEN @max_spositiontaking_7 ELSE @auto_spositiontaking_7 END
    SELECT @auto_spositiontaking_8= CASE WHEN @auto_spositiontaking_8>@max_spositiontaking_8 THEN @max_spositiontaking_8 ELSE @auto_spositiontaking_8 END
    SELECT @auto_spositiontaking_9=  CASE WHEN @auto_spositiontaking_9>@max_spositiontaking_9 THEN @max_spositiontaking_9 ELSE @auto_spositiontaking_9 END
    SELECT @auto_spositiontaking_10=  CASE WHEN @auto_spositiontaking_10>@max_spositiontaking_10 THEN @max_spositiontaking_10 ELSE @auto_spositiontaking_10 END
    SELECT @auto_v2spositiontaking_10=  CASE WHEN @auto_v2spositiontaking_10>@max_v2spositiontaking_10 THEN @max_v2spositiontaking_10 ELSE @auto_v2spositiontaking_10 END
    SELECT @auto_v3spositiontaking_10=  CASE WHEN @auto_v3spositiontaking_10>@max_v3spositiontaking_10 THEN @max_v3spositiontaking_10 ELSE @auto_v3spositiontaking_10 END
    SELECT @auto_v5spositiontaking_10=  CASE WHEN @auto_v5spositiontaking_10>@max_v5spositiontaking_10 THEN @max_v5spositiontaking_10 ELSE @auto_v5spositiontaking_10 END
    SELECT @auto_v8spositiontaking_10=  CASE WHEN @auto_v8spositiontaking_10>@max_v8spositiontaking_10 THEN @max_v8spositiontaking_10 ELSE @auto_v8spositiontaking_10 END
    SELECT @auto_v10spositiontaking_10=  CASE WHEN @auto_v10spositiontaking_10>@max_v10spositiontaking_10 THEN @max_v10spositiontaking_10 ELSE @auto_v10spositiontaking_10 END
    SELECT @auto_v11spositiontaking_10=  CASE WHEN @auto_v11spositiontaking_10>@max_v11spositiontaking_10 THEN @max_v11spositiontaking_10 ELSE @auto_v11spositiontaking_10 END
    SELECT @auto_v99spositiontaking_10=  CASE WHEN @auto_v99spositiontaking_10>@max_v99spositiontaking_10 THEN @max_v99spositiontaking_10 ELSE @auto_v99spositiontaking_10 END
    SELECT @auto_spositiontaking_9999=  CASE WHEN @auto_spositiontaking_9999>@max_spositiontaking_9999 THEN @max_spositiontaking_9999 ELSE @auto_spositiontaking_9999 END

    SELECT @auto_slivepositiontaking_1=  CASE WHEN @auto_slivepositiontaking_1>@max_slivepositiontaking_1 THEN @max_slivepositiontaking_1 ELSE @auto_slivepositiontaking_1 END
    SELECT @auto_slivepositiontaking_3=  CASE WHEN @auto_slivepositiontaking_3>@max_slivepositiontaking_3 THEN @max_slivepositiontaking_3 ELSE @auto_slivepositiontaking_3 END
    SELECT @auto_slivepositiontaking_7=  CASE WHEN @auto_slivepositiontaking_7>@max_slivepositiontaking_7 THEN @max_slivepositiontaking_7 ELSE @auto_slivepositiontaking_7 END
    SELECT @auto_slivepositiontaking_8=  CASE WHEN @auto_slivepositiontaking_8>@max_slivepositiontaking_8 THEN @max_slivepositiontaking_8 ELSE @auto_slivepositiontaking_8 END

    SELECT @auto_v2spositiontaking_1=  CASE WHEN @auto_v2spositiontaking_1>@max_v2spositiontaking_1 THEN @max_v2spositiontaking_1 ELSE @auto_v2spositiontaking_1 END
    SELECT @auto_v2spositiontaking_2=  CASE WHEN @auto_v2spositiontaking_2>@max_v2spositiontaking_2 THEN @max_v2spositiontaking_2 ELSE @auto_v2spositiontaking_2 END
    SELECT @auto_v2spositiontaking_3=  CASE WHEN @auto_v2spositiontaking_3>@max_v2spositiontaking_3 THEN @max_v2spositiontaking_3 ELSE @auto_v2spositiontaking_3 END
    SELECT @auto_v2spositiontaking_7=  CASE WHEN @auto_v2spositiontaking_7>@max_v2spositiontaking_7 THEN @max_v2spositiontaking_7 ELSE @auto_v2spositiontaking_7 END
    SELECT @auto_v2spositiontaking_8=  CASE WHEN @auto_v2spositiontaking_8>@max_v2spositiontaking_8 THEN @max_v2spositiontaking_8 ELSE @auto_v2spositiontaking_8 END
    
    SELECT @auto_v2spositiontaking_20=  CASE WHEN @auto_v2spositiontaking_20>@max_v2spositiontaking_20 THEN @max_v2spositiontaking_20 ELSE @auto_v2spositiontaking_20 END
    SELECT @auto_v2spositiontaking_9999=  CASE WHEN @auto_v2spositiontaking_9999>@max_v2spositiontaking_9999 THEN @max_v2spositiontaking_9999 ELSE @auto_v2spositiontaking_9999 END

    SELECT @auto_v3spositiontaking_1=  CASE WHEN @auto_v3spositiontaking_1>@max_v3spositiontaking_1 THEN @max_v3spositiontaking_1 ELSE @auto_v3spositiontaking_1 END
    SELECT @auto_v3spositiontaking_2=  CASE WHEN @auto_v3spositiontaking_2>@max_v3spositiontaking_2 THEN @max_v3spositiontaking_2 ELSE @auto_v3spositiontaking_2 END
    SELECT @auto_v3spositiontaking_3=  CASE WHEN @auto_v3spositiontaking_3>@max_v3spositiontaking_3 THEN @max_v3spositiontaking_3 ELSE @auto_v3spositiontaking_3 END
    SELECT @auto_v3spositiontaking_20=  CASE WHEN @auto_v3spositiontaking_20>@max_v3spositiontaking_20 THEN @max_v3spositiontaking_20 ELSE @auto_v3spositiontaking_20 END

    SELECT @auto_v5spositiontaking_1=  CASE WHEN @auto_v5spositiontaking_1>@max_v5spositiontaking_1 THEN @max_v5spositiontaking_1 ELSE @auto_v5spositiontaking_1 END
    SELECT @auto_v5spositiontaking_2=  CASE WHEN @auto_v5spositiontaking_2>@max_v5spositiontaking_2 THEN @max_v5spositiontaking_2 ELSE @auto_v5spositiontaking_2 END
    SELECT @auto_v5spositiontaking_3=  CASE WHEN @auto_v5spositiontaking_3>@max_v5spositiontaking_3 THEN @max_v5spositiontaking_3 ELSE @auto_v5spositiontaking_3 END
    SELECT @auto_v5spositiontaking_20=  CASE WHEN @auto_v5spositiontaking_20>@max_v5spositiontaking_20 THEN @max_v5spositiontaking_20 ELSE @auto_v5spositiontaking_20 END
    SELECT @auto_v5spositiontaking_9999=  CASE WHEN @auto_v5spositiontaking_9999>@max_v5spositiontaking_9999 THEN @max_v5spositiontaking_9999 ELSE @auto_v5spositiontaking_9999 END

    SELECT @auto_v8spositiontaking_1=  CASE WHEN @auto_v8spositiontaking_1>@max_v8spositiontaking_1 THEN @max_v8spositiontaking_1 ELSE @auto_v8spositiontaking_1 END
    SELECT @auto_v8spositiontaking_3=  CASE WHEN @auto_v8spositiontaking_3>@max_v8spositiontaking_3 THEN @max_v8spositiontaking_3 ELSE @auto_v8spositiontaking_3 END
    SELECT @auto_v8spositiontaking_20=  CASE WHEN @auto_v8spositiontaking_20>@max_v8spositiontaking_20 THEN @max_v8spositiontaking_20 ELSE @auto_v8spositiontaking_20 END

    SELECT @auto_v10spositiontaking_1=  CASE WHEN @auto_v10spositiontaking_1>@max_v10spositiontaking_1 THEN @max_v10spositiontaking_1 ELSE @auto_v10spositiontaking_1 END
    SELECT @auto_v10spositiontaking_2=  CASE WHEN @auto_v10spositiontaking_2>@max_v10spositiontaking_2 THEN @max_v10spositiontaking_2 ELSE @auto_v10spositiontaking_2 END
    SELECT @auto_v10spositiontaking_3=  CASE WHEN @auto_v10spositiontaking_3>@max_v10spositiontaking_3 THEN @max_v10spositiontaking_3 ELSE @auto_v10spositiontaking_3 END
    SELECT @auto_v10spositiontaking_20=  CASE WHEN @auto_v10spositiontaking_20>@max_v10spositiontaking_20 THEN @max_v10spositiontaking_20 ELSE @auto_v10spositiontaking_20 END

    SELECT @auto_v11spositiontaking_1=  CASE WHEN @auto_v11spositiontaking_1>@max_v11spositiontaking_1 THEN @max_v11spositiontaking_1 ELSE @auto_v11spositiontaking_1 END
    SELECT @auto_v11spositiontaking_20=  CASE WHEN @auto_v11spositiontaking_20>@max_v11spositiontaking_20 THEN @max_v11spositiontaking_20 ELSE @auto_v11spositiontaking_20 END

    SELECT @auto_v99spositiontaking_1=  CASE WHEN @auto_v99spositiontaking_1>@max_v99spositiontaking_1 THEN @max_v99spositiontaking_1 ELSE @auto_v99spositiontaking_1 END
    SELECT @auto_v99spositiontaking_2=  CASE WHEN @auto_v99spositiontaking_2>@max_v99spositiontaking_2 THEN @max_v99spositiontaking_2 ELSE @auto_v99spositiontaking_2 END
    SELECT @auto_v99spositiontaking_3=  CASE WHEN @auto_v99spositiontaking_3>@max_v99spositiontaking_3 THEN @max_v99spositiontaking_3 ELSE @auto_v99spositiontaking_3 END
    SELECT @auto_v99spositiontaking_20=  CASE WHEN @auto_v99spositiontaking_20>@max_v99spositiontaking_20 THEN @max_v99spositiontaking_20 ELSE @auto_v99spositiontaking_20 END

    SELECT @auto_v99spositiontaking_9=  CASE WHEN @auto_v99spositiontaking_9>@max_v99spositiontaking_9 THEN @max_v99spositiontaking_9 ELSE @auto_v99spositiontaking_9 END
	SELECT @auto_v99spositiontaking_9999=  CASE WHEN @auto_v99spositiontaking_9999>@max_v99spositiontaking_9999 THEN @max_v99spositiontaking_9999 ELSE @auto_v99spositiontaking_9999 END
   
    SELECT @auto_v161spositiontaking_81 = CASE WHEN @auto_v161spositiontaking_81 > @max_v161spositiontaking_81 THEN @max_v161spositiontaking_81 ELSE @auto_v161spositiontaking_81 END
    SELECT @auto_v161spositiontaking_83 = CASE WHEN @auto_v161spositiontaking_83 > @max_v161spositiontaking_83 THEN @max_v161spositiontaking_83 ELSE @auto_v161spositiontaking_83 END
    SELECT @auto_v161spositiontaking_86 = CASE WHEN @auto_v161spositiontaking_86 > @max_v161spositiontaking_86 THEN @max_v161spositiontaking_86 ELSE @auto_v161spositiontaking_86 END
    SELECT @auto_v161spositiontaking_88 = CASE WHEN @auto_v161spositiontaking_88 > @max_v161spositiontaking_88 THEN @max_v161spositiontaking_88 ELSE @auto_v161spositiontaking_88 END

    SELECT @auto_v161slivepositiontaking_85=  CASE WHEN @auto_v161slivepositiontaking_85 > @max_v161slivepositiontaking_85 THEN @max_v161slivepositiontaking_85 ELSE @auto_v161slivepositiontaking_85 END
    SELECT @auto_v161slivepositiontaking_86=  CASE WHEN @auto_v161slivepositiontaking_86 > @max_v161slivepositiontaking_86 THEN @max_v161slivepositiontaking_86 ELSE @auto_v161slivepositiontaking_86 END
    SELECT @auto_v161slivepositiontaking_87 = CASE WHEN @auto_v161slivepositiontaking_87 > @max_v161slivepositiontaking_87 THEN @max_v161slivepositiontaking_87 ELSE @auto_v161slivepositiontaking_87 END
    SELECT @auto_v161slivepositiontaking_89 = CASE WHEN @auto_v161slivepositiontaking_89 > @max_v161slivepositiontaking_89 THEN @max_v161slivepositiontaking_89 ELSE @auto_v161slivepositiontaking_89 END
    SELECT @auto_v161slivepositiontaking_90 = CASE WHEN @auto_v161slivepositiontaking_90 > @max_v161slivepositiontaking_90 THEN @max_v161slivepositiontaking_90 ELSE @auto_v161slivepositiontaking_90 END

    SELECT 
	    @groupa = CASE WHEN @groupa>groupa THEN groupa ELSE @groupa END,
	    @groupb = CASE WHEN @groupb>groupb THEN groupb ELSE @groupb END,
	    @groupc = CASE WHEN @groupc>groupc THEN groupc ELSE @groupc END,
	    @groupd = CASE WHEN @groupd>groupd THEN groupd ELSE @groupd END
    FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND  bettype=1 AND sporttype=1

    SELECT 
	    @discountcs = CASE WHEN @discountcs>sdiscount THEN sdiscount ELSE @discountcs END
    FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=4 AND sporttype=1

    --1X2 Commission
    SELECT 
	    @discount1x2 = CASE WHEN @discount1x2>sdiscount THEN sdiscount ELSE @discount1x2 END
    FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=5 AND sporttype=1   

    --Vinh@20080213: get transfer option FROM super
    IF @srecommend > 100 -- get site FROM upline IF not direct master
	    SELECT @site = site FROM customer WITH(NOLOCK) WHERE CustID = @srecommend

	DECLARE @IsInternal BIT
    select	@IsInternal = IsInternal,
		    @TransferOption_dec = TransferOption
    FROM custsuper WITH(NOLOCK) WHERE CustID = @srecommend

    SELECT @Credit_AllOtherMaster = isnull(sum(credit), 0) FROM custinfo AS ci WITH(NOLOCK) WHERE srecommend = @srecommend AND RoleID = 3

    IF @Credit_AllOtherMaster + @Credit > @Credit_SAg AND @srecommend>100
    BEGIN
	    SET @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Sorry, credit update is not successful, You have exceeded your super agent credit.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
					    END	
	    SELECT @ErrCode = 106
	    return
    END

    select	@isauto_spositiontaking_1 	= CASE when	@auto_spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_2 	= CASE when	@auto_spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_3 	= CASE when	@auto_spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_4 	= CASE when	@auto_spositiontaking_4 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_5 	= CASE when	@auto_spositiontaking_5 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_6 	= CASE when	@auto_spositiontaking_6 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_7 	= CASE when	@auto_spositiontaking_7 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_8 	= CASE when	@auto_spositiontaking_8 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_9 	= CASE when	@auto_spositiontaking_9 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_10 	= CASE when	@auto_spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v2spositiontaking_10 	= CASE when	@auto_v2spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v3spositiontaking_10 	= CASE when	@auto_v3spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v5spositiontaking_10 	= CASE when	@auto_v5spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v8spositiontaking_10 	= CASE when	@auto_v8spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v10spositiontaking_10 	= CASE when	@auto_v10spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v11spositiontaking_10 	= CASE when	@auto_v11spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_v99spositiontaking_10 	= CASE when	@auto_v99spositiontaking_10 	>0 THEN 1 ELSE 0 END,
	    @isauto_spositiontaking_9999 	= CASE when	@auto_spositiontaking_9999 	>0 THEN 1 ELSE 0 END,
	    @isauto_slivepositiontaking_1 	= CASE when	@auto_slivepositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_slivepositiontaking_3 	= CASE when	@auto_slivepositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_slivepositiontaking_7 	= CASE when	@auto_slivepositiontaking_7 	>0 THEN 1 ELSE 0 END,
	    @isauto_slivepositiontaking_8 	= CASE when	@auto_slivepositiontaking_8 	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v2spositiontaking_1 	= CASE when	@auto_v2spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v2spositiontaking_2 	= CASE when	@auto_v2spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_v2spositiontaking_3 	= CASE when	@auto_v2spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v2spositiontaking_7 	= CASE when	@auto_v2spositiontaking_7 	>0 THEN 1 ELSE 0 END,
	    @isauto_v2spositiontaking_8 	= CASE when	@auto_v2spositiontaking_8 	>0 THEN 1 ELSE 0 END,
  
	    @isauto_v2spositiontaking_20 	= CASE when	@auto_v2spositiontaking_20	>0 THEN 1 ELSE 0 END,
    	
    	@isauto_v2spositiontaking_9999 	= CASE when	@auto_v2spositiontaking_9999	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v3spositiontaking_1 	= CASE when	@auto_v3spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v3spositiontaking_2 	= CASE when	@auto_v3spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_v3spositiontaking_3 	= CASE when	@auto_v3spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v3spositiontaking_20 	= CASE when	@auto_v3spositiontaking_20	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v5spositiontaking_1 	= CASE when	@auto_v5spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v5spositiontaking_2 	= CASE when	@auto_v5spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_v5spositiontaking_3 	= CASE when	@auto_v5spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v5spositiontaking_20 	= CASE when	@auto_v5spositiontaking_20	>0 THEN 1 ELSE 0 END,
	    @isauto_v5spositiontaking_9999 	= CASE when	@auto_v5spositiontaking_9999 	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v8spositiontaking_1 	= CASE when	@auto_v8spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v8spositiontaking_3 	= CASE when	@auto_v8spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v8spositiontaking_20 	= CASE when	@auto_v8spositiontaking_20	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v10spositiontaking_1 	= CASE when	@auto_v10spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v10spositiontaking_2 	= CASE when	@auto_v10spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_v10spositiontaking_3 	= CASE when	@auto_v10spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v10spositiontaking_20 	= CASE when	@auto_v10spositiontaking_20	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v11spositiontaking_1 	= CASE when	@auto_v11spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v11spositiontaking_20 	= CASE when	@auto_v11spositiontaking_20	>0 THEN 1 ELSE 0 END,
    	
	    @isauto_v99spositiontaking_1 	= CASE when	@auto_v99spositiontaking_1 	>0 THEN 1 ELSE 0 END,
	    @isauto_v99spositiontaking_2 	= CASE when	@auto_v99spositiontaking_2 	>0 THEN 1 ELSE 0 END,
	    @isauto_v99spositiontaking_3 	= CASE when	@auto_v99spositiontaking_3 	>0 THEN 1 ELSE 0 END,
	    @isauto_v99spositiontaking_9 	= CASE when	@auto_v99spositiontaking_9 	>0 THEN 1 ELSE 0 END,
	    @isauto_v99spositiontaking_20 	= CASE when	@auto_v99spositiontaking_20	>0 THEN 1 ELSE 0 END,
		@isauto_v99spositiontaking_9999 = CASE when	@auto_v99spositiontaking_9999	>0 THEN 1 ELSE 0 END,
	    
	    @isauto_v161spositiontaking_81  = CASE WHEN @auto_v161spositiontaking_81 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161spositiontaking_83  = CASE WHEN @auto_v161spositiontaking_83 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161spositiontaking_86  = CASE WHEN @auto_v161spositiontaking_86 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161spositiontaking_88  = CASE WHEN @auto_v161spositiontaking_88 > 0 THEN 1 ELSE 0 END,
    	
	    @isauto_v161slivepositiontaking_85 = CASE WHEN @auto_v161slivepositiontaking_85 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161slivepositiontaking_86 = CASE WHEN @auto_v161slivepositiontaking_86 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161slivepositiontaking_87 = CASE WHEN @auto_v161slivepositiontaking_87 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161slivepositiontaking_89 = CASE WHEN @auto_v161slivepositiontaking_89 > 0 THEN 1 ELSE 0 END,
	    @isauto_v161slivepositiontaking_90 = CASE WHEN @auto_v161slivepositiontaking_90 > 0 THEN 1 ELSE 0 END
	
	--if upline suspended then new master will be suspended
    --IF @Ssuspended = 1 
    --begin 
	   -- set @suspended = 1
    --END 


    --Insert general info
    EXEC dbo.Acc_CustomerInsUserInfo
	    @custid = @custid OUTPUT,
	    @firstname = @firstname,
	    @lastname = @lastname,
	    @creator = @creator,
	    @username = @username,
	    @userpwd = @userpwd,
	    @pwdexpiry = @pwdexpiry,
	    @currency = @currency,
	    @site = @site,
	    @srecommend = @srecommend,
	    @mrecommend = 0,
	    @recommend = 0,
	    @roleid = 3,
	    @phone = @phone,
	    @mobilephone = @mobilephone,
	    @email = @email,
	    @fax = @fax,
	    @address = @address,
	    @city = @city,
	    @state = @state,
	    @country = @country,
	    @postal = @postal,
	    @TransferOption = @TransferOption,
		-- @suspended = @suspended,
	    @closed = @UplineClosed,
    	@SystemID=@SystemID,
	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,
	    @DisableOutright = @DisableOutright,
	    @matchlimit = @matchlimit,
	    @virtualmultiplier = @EnableVR,
	    @DisableCasino = @DisableCasino,
	    @DisableAutoMPT = @DisableAutoMPT,
	    @DisableNumber = @DisableNumber,
	     
	    @DoubleCommLosing = @DoubleCommLosing,  
	  
	    @IsInternal = @IsInternal,

	    --Keno
	    @HideKeno = @HideKeno,
	    
	    @DisableGoldDeluxe = @DisableGoldDeluxe,
		@HideGoldDeluxe = @HideGoldDeluxe,
		
		@DisableSuperLive = @DisableSuperLive,
		@Danger = @DangerSuper,
		@Danger2 = @DangerSuper2,
		@Danger3 = @DangerSuper3,
		@Danger4 = @DangerSuper4,
		@Danger5 = @DangerSuper5,
    	
	    @credit = @credit,
	    @maxcredit = null,
    	
	    @IP = @IP,
	    @TransferOption_dec = @TransferOption_dec,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    --Error Occurs
    IF @ErrCode <> 0
	    RETURN 

	--insert default value from upline
	EXEC dbo.Acc_CustomerWinLimitIns @CustId = @custid
		, @UplineId = @srecommend
		, @IP = @IP
		, @UserId = @Creator
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END
	  
        EXEC dbo.Acc_CustomerInfo_Execrep_00
	    @custid = @custid,
	    @srecommend = @srecommend,
	    @RoleID = 3,
    	
	    @groupa = @groupa, 
	    @groupb = @groupb, 
	    @groupc = @groupc, 
	    @groupd = @groupd,
    	
	    @spositiontaking_1 = @spositiontaking_1,
	    @spositiontaking_2 = @spositiontaking_2,
	    @spositiontaking_3 = @spositiontaking_3,
	    @spositiontaking_4 = @spositiontaking_4,
	    @spositiontaking_5 = @spositiontaking_5,
	    @spositiontaking_6 = @spositiontaking_6,
	    @spositiontaking_7 = @spositiontaking_7,
	    @spositiontaking_8 = @spositiontaking_8,
	    @spositiontaking_9 = @spositiontaking_9,
	    @spositiontaking_10 = @spositiontaking_10,
	    @v2spositiontaking_10 = @v2spositiontaking_10,
	    @v3spositiontaking_10 = @v3spositiontaking_10,
	    @v5spositiontaking_10 = @v5spositiontaking_10,
	    @v8spositiontaking_10 = @v8spositiontaking_10,
	    @v10spositiontaking_10 = @v10spositiontaking_10,
	    @v11spositiontaking_10 = @v11spositiontaking_10,
	    @v99spositiontaking_10 = @v99spositiontaking_10,
	    @spositiontaking_9999 = @spositiontaking_9999,
    	
	    @slivepositiontaking_1 = @slivepositiontaking_1,
	    @slivepositiontaking_3 = @slivepositiontaking_3,
	    @slivepositiontaking_7 = @slivepositiontaking_7,
	    @slivepositiontaking_8 = @slivepositiontaking_8,
    	
	    @v2spositiontaking_1 = @v2spositiontaking_1,
	    @v2spositiontaking_2 = @v2spositiontaking_2,
	    @v2spositiontaking_3 = @v2spositiontaking_3,
	    @v2spositiontaking_7 = @v2spositiontaking_7,
	    @v2spositiontaking_8 = @v2spositiontaking_8,

	    @v2spositiontaking_20 = @v2spositiontaking_20,
    	
    	@v2spositiontaking_9999 = @v2spositiontaking_9999,
    	
	    @v3spositiontaking_1 = @v3spositiontaking_1,
	    @v3spositiontaking_2 = @v3spositiontaking_2,
	    @v3spositiontaking_3 = @v3spositiontaking_3,
	    @v3spositiontaking_20 = @v3spositiontaking_20,

	    @v5spositiontaking_1 = @v5spositiontaking_1,
	    @v5spositiontaking_2 = @v5spositiontaking_2,
	    @v5spositiontaking_3 = @v5spositiontaking_3,
	    @v5spositiontaking_20 = @v5spositiontaking_20,
	    @v5spositiontaking_9999 = @v5spositiontaking_9999,

	    @v8spositiontaking_1 = @v8spositiontaking_1,
	    @v8spositiontaking_3 = @v8spositiontaking_3,
	    @v8spositiontaking_20 = @v8spositiontaking_20,

	    @v10spositiontaking_1 = @v10spositiontaking_1,
	    @v10spositiontaking_2 = @v10spositiontaking_2,
	    @v10spositiontaking_3 = @v10spositiontaking_3,
	    @v10spositiontaking_20 = @v10spositiontaking_20,

	    @v11spositiontaking_1 = @v11spositiontaking_1,
	    @v11spositiontaking_20 = @v11spositiontaking_20,

	    @v99spositiontaking_1 = @v99spositiontaking_1,
	    @v99spositiontaking_2 = @v99spositiontaking_2,
	    @v99spositiontaking_3 = @v99spositiontaking_3,
	    @v99spositiontaking_9 = @v99spositiontaking_9,
	    @v99spositiontaking_20 = @v99spositiontaking_20,    
		@v99spositiontaking_9999 = @v99spositiontaking_9999,    
    	
	    --v161
	    @v161spositiontaking_81 = @v161spositiontaking_81,
	    @v161spositiontaking_83 = @v161spositiontaking_83,
	
	    @v161spositiontaking_86 = @v161spositiontaking_86,
	    @v161spositiontaking_88 = @v161spositiontaking_88,
	    @v161slivepositiontaking_85 = @v161slivepositiontaking_85,
	    @v161slivepositiontaking_86 = @v161slivepositiontaking_86,
	    @v161slivepositiontaking_87 = @v161slivepositiontaking_87,	
	    @v161slivepositiontaking_89 = @v161slivepositiontaking_89,
	    @v161slivepositiontaking_90 = @v161slivepositiontaking_90,
    	
	    @mpositiontaking_1 = @mpositiontaking_1,
	    @mpositiontaking_2 = @mpositiontaking_2,
	    @mpositiontaking_3 = @mpositiontaking_3,
	    @mpositiontaking_4 = @mpositiontaking_4,
	    @mpositiontaking_5 = @mpositiontaking_5,
	    @mpositiontaking_6 = @mpositiontaking_6,
	    @mpositiontaking_7 = @mpositiontaking_7,
	    @mpositiontaking_8 = @mpositiontaking_8,
	    @mpositiontaking_9 = @mpositiontaking_9,
	    @mpositiontaking_10 = @mpositiontaking_10,
	    @v2mpositiontaking_10 = @v2mpositiontaking_10,
	    @v3mpositiontaking_10 = @v3mpositiontaking_10,
	    @v5mpositiontaking_10 = @v5mpositiontaking_10,
	    @v8mpositiontaking_10 = @v8mpositiontaking_10,
	    @v10mpositiontaking_10 = @v10mpositiontaking_10,
	    @v11mpositiontaking_10 = @v11mpositiontaking_10,
	    @v99mpositiontaking_10 = @v99mpositiontaking_10,
	    @mpositiontaking_9999 = @mpositiontaking_9999,
    	
	    @mlivepositiontaking_1 = @mlivepositiontaking_1,
	    @mlivepositiontaking_3 = @mlivepositiontaking_3,
	    @mlivepositiontaking_7 = @mlivepositiontaking_7,
	    @mlivepositiontaking_8 = @mlivepositiontaking_8,
    	
	    @v2mpositiontaking_1 = @v2mpositiontaking_1,
	    @v2mpositiontaking_2 = @v2mpositiontaking_2,
	    @v2mpositiontaking_3 = @v2mpositiontaking_3,
	    @v2mpositiontaking_7 = @v2mpositiontaking_7,
	    @v2mpositiontaking_8 = @v2mpositiontaking_8,
	    
	    @v2mpositiontaking_20 = @v2mpositiontaking_20,
	    @v2mpositiontaking_9999 = @v2mpositiontaking_9999,

	    @v3mpositiontaking_1 = @v3mpositiontaking_1,
	    @v3mpositiontaking_2 = @v3mpositiontaking_2,
	    @v3mpositiontaking_3 = @v3mpositiontaking_3,
	    @v3mpositiontaking_20 = @v3mpositiontaking_20,

	    @v5mpositiontaking_1 = @v5mpositiontaking_1,
	    @v5mpositiontaking_2 = @v5mpositiontaking_2,
	    @v5mpositiontaking_3 = @v5mpositiontaking_3,
	    @v5mpositiontaking_20 = @v5mpositiontaking_20,
	    @v5mpositiontaking_9999 = @v5mpositiontaking_9999,

	    @v8mpositiontaking_1 = @v8mpositiontaking_1,
	    @v8mpositiontaking_3 = @v8mpositiontaking_3,
	    @v8mpositiontaking_20 = @v8mpositiontaking_20,

	    @v10mpositiontaking_1 = @v10mpositiontaking_1,
	    @v10mpositiontaking_2 = @v10mpositiontaking_2,
	    @v10mpositiontaking_3 = @v10mpositiontaking_3,
	    @v10mpositiontaking_20 = @v10mpositiontaking_20,

	    @v11mpositiontaking_1 = @v11mpositiontaking_1,
	    @v11mpositiontaking_20 = @v11mpositiontaking_20,

	    @v99mpositiontaking_1 = @v99mpositiontaking_1,
	    @v99mpositiontaking_2 = @v99mpositiontaking_2,
	    @v99mpositiontaking_3 = @v99mpositiontaking_3,
	    @v99mpositiontaking_9 = @v99mpositiontaking_9,
	    @v99mpositiontaking_20 = @v99mpositiontaking_20,
		@v99mpositiontaking_9999 = @v99mpositiontaking_9999,
 
	    --v161
	    @v161mpositiontaking_81 = @v161mpositiontaking_81,
	    @v161mpositiontaking_83 = @v161mpositiontaking_83,

	    @v161mpositiontaking_86 = @v161mpositiontaking_86,
	    @v161mpositiontaking_88 = @v161mpositiontaking_88,
	    @v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
	    @v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
	    @v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
	    @v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
	    @v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,
    	
	    @auto_spositiontaking_1 = @auto_spositiontaking_1,
	    @auto_spositiontaking_2 = @auto_spositiontaking_2,
	    @auto_spositiontaking_3 = @auto_spositiontaking_3,
	    @auto_spositiontaking_4 = @auto_spositiontaking_4,
	    @auto_spositiontaking_5 = @auto_spositiontaking_5,
	    @auto_spositiontaking_6 = @auto_spositiontaking_6,
	    @auto_spositiontaking_7 = @auto_spositiontaking_7,
	    @auto_spositiontaking_8 = @auto_spositiontaking_8,
	    @auto_spositiontaking_9 = @auto_spositiontaking_9,
	    @auto_spositiontaking_10 = @auto_spositiontaking_10,
	    @auto_v2spositiontaking_10 = @auto_v2spositiontaking_10,
	    @auto_v3spositiontaking_10 = @auto_v3spositiontaking_10,
	    @auto_v5spositiontaking_10 = @auto_v5spositiontaking_10,
	    @auto_v8spositiontaking_10 = @auto_v8spositiontaking_10,
	    @auto_v10spositiontaking_10 = @auto_v10spositiontaking_10,
	    @auto_v11spositiontaking_10 = @auto_v11spositiontaking_10,
	    @auto_v99spositiontaking_10 = @auto_v99spositiontaking_10,
	    @auto_spositiontaking_9999 = @auto_spositiontaking_9999,
	    @auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
	    @auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
	    @auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
	    @auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
    	
	    @auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
	    @auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
	    @auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
	    @auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
	    @auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,

	    @auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
	    @auto_v2spositiontaking_9999 = @auto_v2spositiontaking_9999,
    	
	    @auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
	    @auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
	    @auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,	
	    @auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,
    	
	    @auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
	    @auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
	    @auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,	
	    @auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
	    @auto_v5spositiontaking_9999 = @auto_v5spositiontaking_9999,	
    	
	    @auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,	
	    @auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,	
	    @auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,
    	
	    @auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
	    @auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
	    @auto_v10spositiontaking_3 = @auto_v10spositiontaking_3,	
	    @auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,
    	
	    @auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,	
	    @auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,
    	
	    @auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
	    @auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
	    @auto_v99spositiontaking_3 = @auto_v99spositiontaking_3,		
	    @auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,	

	    @auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,  
		@auto_v99spositiontaking_9999 = @auto_v99spositiontaking_9999,  
    	
	    @auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,            
	    @auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
	    @auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
	    @auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
    	
	    @auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
	    @auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
	    @auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
	    @auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
	    @auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,
    	
	    @isauto_spositiontaking_1 = @isauto_spositiontaking_1,
	    @isauto_spositiontaking_2 = @isauto_spositiontaking_2,
	    @isauto_spositiontaking_3 = @isauto_spositiontaking_3,
	    @isauto_spositiontaking_4 = @isauto_spositiontaking_4,
	    @isauto_spositiontaking_5 = @isauto_spositiontaking_5,
	    @isauto_spositiontaking_6 = @isauto_spositiontaking_6,
	    @isauto_spositiontaking_7 = @isauto_spositiontaking_7,
	    @isauto_spositiontaking_8 = @isauto_spositiontaking_8,
	    @isauto_spositiontaking_9 = @isauto_spositiontaking_9,
	    @isauto_spositiontaking_10 = @isauto_spositiontaking_10,
	    @isauto_v2spositiontaking_10 = @isauto_v2spositiontaking_10,
	    @isauto_v3spositiontaking_10 = @isauto_v3spositiontaking_10,
	    @isauto_v5spositiontaking_10 = @isauto_v5spositiontaking_10,
	    @isauto_v8spositiontaking_10 = @isauto_v8spositiontaking_10,
	    @isauto_v10spositiontaking_10 = @isauto_v10spositiontaking_10,
	    @isauto_v11spositiontaking_10 = @isauto_v11spositiontaking_10,
	    @isauto_v99spositiontaking_10 = @isauto_v99spositiontaking_10,
	    @isauto_spositiontaking_9999 = @isauto_spositiontaking_9999,
    	
	    @isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
	    @isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
	    @isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
	    @isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
    	
	    @isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
	    @isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
	    @isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
	    @isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
	    @isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,

	    @isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
	    @isauto_v2spositiontaking_9999 = @isauto_v2spositiontaking_9999,
    	
	    @isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
	    @isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
	    @isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,	
	    @isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,
    	
	    @isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
	    @isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
	    @isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,	
	    @isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
	    @isauto_v5spositiontaking_9999 = @isauto_v5spositiontaking_9999,	
    	
	    @isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,	
	    @isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,	
	    @isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,
    	
	    @isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
	    @isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
	    @isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,	
	    @isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,
    	
	    @isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,	
	    @isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,

	    @isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
	    @isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
	    @isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,		
	    @isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,

	    @isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
		@isauto_v99spositiontaking_9999 = @isauto_v99spositiontaking_9999,
 
	    @isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,					
	    @isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,
	    @isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
	    @isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
    	
	    @isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
	    @isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
	    @isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
	    @isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
	    @isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,		
    	
	    @discountcs = @discountcs, 
	    --comm 1x2
	    @discount1x2 = @discount1x2, 

		--BetSetting
		@BetSettingXML = @BetSettingXML,

	    -- MyanmarOdds
    	@IsMyanmarOdds = @IsMyanmarOdds,
    	@discountMyanmarOdds = @discountMyanmarOdds,
    	@SettingStatus = @SettingStatus,
	    @ErrCode = @ErrCode OUTPUT

    IF @ErrCode > 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
				    WHEN 'E' THEN 'Create customer fail. Please try again'
				    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
			    END
    				
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
    		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustId = @CustId

	    return
    END
	
	 IF @srecommend < 100 AND @site = '611111' -- For Direct Master
	 BEGIN
		   	DECLARE @VirtualRateMultiplier VARCHAR(MAX) = ''

		SELECT @VirtualRateMultiplier = CONVERT(VARCHAR(MAX),(  SELECT b.LevelID,vr.ValueID AS ValueIDLive,vr.ValueID AS ValueIDNonLive 
															FROM VRSettingHierarchy b WITH(NOLOCK) 
																CROSS APPLY VRValueMapping vr (NOLOCK)
															WHERE b.SportType = 2 
																AND b.VRLeagueGroupID = -1 
																AND b.BetType = -1 
																AND vr.Value = 1
															FOR XML RAW('Row'), ROOT ('Root'))
											)

		EXEC [Acc_CustVirtualMultiplier_Upd]
			  @CustID = @CustID
			, @SportType = 2
			, @VirtualMultiplier = @VirtualRateMultiplier
			, @UserID  = @creator
			, @IP  = @IP
			, @ErrCode = @ErrCode OUTPUT 
			, @ErrMsg = @ErrMsg OUTPUT
		
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
				DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustId = @CustId
				DELETE FROM VRCustSetting WITH (ROWLOCK) WHERE custId  =@custid
			RETURN
		END	
	 END
	
    --Allow master using auto master PT or not
    --Update CustMaster WITH(ROWLOCK,UPDLOCK) SET DisableAutoMPT = @DIsableAutoMPT WHERE CustID = @CustID

    set @endRun = GETDATE()
    set @duration  = datediff (millisecond,@startRun,@endRun)

    DECLARE @LogSPData VARCHAR(MAX)
    --Log customer info
    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)), SPACE(1))) + '" ' +
    'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)), SPACE(1))) + '" ' +
    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)), SPACE(1))) + '" ' +
    'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)), SPACE(1))) + '" ' +
    'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)), SPACE(1))) + '" ' +    
    'country="'+ COALESCE(CAST(@country AS VARCHAR(100)), SPACE(1)) + '" ' +    
    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
    'TransferOption="'+ COALESCE(CAST(@TransferOption AS VARCHAR(8)), SPACE(1)) + '" ' +
	'review="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)), SPACE(1))) + '" ' +
	'review2="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)), SPACE(1))) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +	
    'srecommend="'+ COALESCE(CAST(@srecommend AS VARCHAR(50)), SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
    'site="'+ COALESCE(CAST(@site AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 601,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH 
	    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
	    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)), SPACE(1))) + '" ' +
	    'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)), SPACE(1))) + '" ' +	    
	    'country="'+ COALESCE(CAST(@country AS VARCHAR(100)), SPACE(1)) + '" ' +	    
	    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'TransferOption="'+ COALESCE(CAST(@TransferOption AS VARCHAR(8)), SPACE(1)) + '" ' +
		'review="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)), SPACE(1))) + '" ' +
		'review2="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
	    'srecommend="'+ COALESCE(CAST(@srecommend AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
	    'site="'+ COALESCE(CAST(@site AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 601,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH	

    --Log betsetting
    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MinB="'+ COALESCE(CAST(@minbet AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxB="'+ COALESCE(CAST(@maxbet AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPM="'+ COALESCE(CAST(@maxpermatch AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPM="'+ COALESCE(CAST(@maxPOpermatch AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv2="'+ COALESCE(CAST(@minbetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv2="'+ COALESCE(CAST(@maxbetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv2="'+ COALESCE(CAST(@maxpermatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv2="'+ COALESCE(CAST(@maxPOpermatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +

		--saba
	  	'MinBv1saba="'+ COALESCE(CAST(@minbetv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv1saba="'+ COALESCE(CAST(@maxbetv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv1saba="'+ COALESCE(CAST(@maxpermatchv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv1saba="'+ COALESCE(CAST(@maxPOpermatchv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv2saba="'+ COALESCE(CAST(@minbetv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv2saba="'+ COALESCE(CAST(@maxbetv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv2saba="'+ COALESCE(CAST(@maxpermatchv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv2saba="'+ COALESCE(CAST(@maxPOpermatchv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv3="'+ COALESCE(CAST(@minbetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv3="'+ COALESCE(CAST(@maxbetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv3="'+ COALESCE(CAST(@maxpermatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv3="'+ COALESCE(CAST(@maxPOpermatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv5="'+ COALESCE(CAST(@minbetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv5="'+ COALESCE(CAST(@maxbetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv5="'+ COALESCE(CAST(@maxpermatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv5="'+ COALESCE(CAST(@maxPOpermatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv8="'+ COALESCE(CAST(@minbetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv8="'+ COALESCE(CAST(@maxbetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv8="'+ COALESCE(CAST(@maxpermatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv8="'+ COALESCE(CAST(@maxPOpermatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv10="'+ COALESCE(CAST(@minbetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv10="'+ COALESCE(CAST(@maxbetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv10="'+ COALESCE(CAST(@maxpermatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv10="'+ COALESCE(CAST(@maxPOpermatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv11="'+ COALESCE(CAST(@minbetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv11="'+ COALESCE(CAST(@maxbetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv11="'+ COALESCE(CAST(@maxpermatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv11="'+ COALESCE(CAST(@maxPOpermatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv99="'+ COALESCE(CAST(@minbetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv99="'+ COALESCE(CAST(@maxbetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv99="'+ COALESCE(CAST(@maxpermatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv99="'+ COALESCE(CAST(@maxPOpermatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv99MP="'+ COALESCE(CAST(@minbetv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv99MP="'+ COALESCE(CAST(@maxbetv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPM99MP="'+ COALESCE(CAST(@maxpermatchv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv99MP="'+ COALESCE(CAST(@maxPOpermatchv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +

		'MinBv1MP="'+ COALESCE(CAST(@minbetv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv1MP="'+ COALESCE(CAST(@maxbetv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv1MP="'+ COALESCE(CAST(@maxpermatchv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPPMv1MP="'+ COALESCE(CAST(@maxPOpermatchv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
		
		'MinBv164="' + COALESCE(CAST(@minbetv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv164="' + COALESCE(CAST(@maxbetv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv164="' + COALESCE(CAST(@maxpermatchv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
	
		'MinBv161="' + COALESCE(CAST(@minbetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MaxBv161="' + COALESCE(CAST(@maxbetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPMv161="' + COALESCE(CAST(@maxpermatchv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
		'MPBv161="' + COALESCE(CAST(@maxperballv161 AS VARCHAR(50)), space(1)) + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 301,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MinB="'+ COALESCE(CAST(@minbet AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxB="'+ COALESCE(CAST(@maxbet AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPM="'+ COALESCE(CAST(@maxpermatch AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPM="'+ COALESCE(CAST(@maxPOpermatch AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv2="'+ COALESCE(CAST(@minbetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv2="'+ COALESCE(CAST(@maxbetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv2="'+ COALESCE(CAST(@maxpermatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv2="'+ COALESCE(CAST(@maxPOpermatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +

			--saba
	  		'MinBv1saba="'+ COALESCE(CAST(@minbetv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv1saba="'+ COALESCE(CAST(@maxbetv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv1saba="'+ COALESCE(CAST(@maxpermatchv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv1saba="'+ COALESCE(CAST(@maxPOpermatchv1saba AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv2saba="'+ COALESCE(CAST(@minbetv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv2saba="'+ COALESCE(CAST(@maxbetv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv2saba="'+ COALESCE(CAST(@maxpermatchv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv2saba="'+ COALESCE(CAST(@maxPOpermatchv2saba AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv3="'+ COALESCE(CAST(@minbetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv3="'+ COALESCE(CAST(@maxbetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv3="'+ COALESCE(CAST(@maxpermatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv3="'+ COALESCE(CAST(@maxPOpermatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv5="'+ COALESCE(CAST(@minbetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv5="'+ COALESCE(CAST(@maxbetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv5="'+ COALESCE(CAST(@maxpermatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv5="'+ COALESCE(CAST(@maxPOpermatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv8="'+ COALESCE(CAST(@minbetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv8="'+ COALESCE(CAST(@maxbetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv8="'+ COALESCE(CAST(@maxpermatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv8="'+ COALESCE(CAST(@maxPOpermatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv10="'+ COALESCE(CAST(@minbetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv10="'+ COALESCE(CAST(@maxbetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv10="'+ COALESCE(CAST(@maxpermatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv10="'+ COALESCE(CAST(@maxPOpermatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv11="'+ COALESCE(CAST(@minbetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv11="'+ COALESCE(CAST(@maxbetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv11="'+ COALESCE(CAST(@maxpermatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv11="'+ COALESCE(CAST(@maxPOpermatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv99="'+ COALESCE(CAST(@minbetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv99="'+ COALESCE(CAST(@maxbetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv99="'+ COALESCE(CAST(@maxpermatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv99="'+ COALESCE(CAST(@maxPOpermatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv99MP="'+ COALESCE(CAST(@minbetv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv99MP="'+ COALESCE(CAST(@maxbetv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPM99MP="'+ COALESCE(CAST(@maxpermatchv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv99MP="'+ COALESCE(CAST(@maxPOpermatchv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +

			'MinBv1MP="'+ COALESCE(CAST(@minbetv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv1MP="'+ COALESCE(CAST(@maxbetv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv1MP="'+ COALESCE(CAST(@maxpermatchv1mp AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPPMv1MP="'+ COALESCE(CAST(@maxPOpermatchv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
		
			'MinBv164="' + COALESCE(CAST(@minbetv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv164="' + COALESCE(CAST(@maxbetv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv164="' + COALESCE(CAST(@maxpermatchv164 AS VARCHAR(50)), SPACE(1)) + '" ' +
	
			'MinBv161="' + COALESCE(CAST(@minbetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MaxBv161="' + COALESCE(CAST(@maxbetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPMv161="' + COALESCE(CAST(@maxpermatchv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
			'MPBv161="' + COALESCE(CAST(@maxperballv161 AS VARCHAR(50)), space(1)) + '" ' +
			'ErrMsg="' + ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 301,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH

    --log commission
    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)), SPACE(1)) + '" ' 
	 IF @IsMyanmarOdds = 0
		SET @LogSPData = @LogSPData  +
		'groupb="'+ COALESCE(CAST(@groupb AS VARCHAR(50)), SPACE(1)) + '" ' +
		'groupc="'+ COALESCE(CAST(@groupc AS VARCHAR(50)), SPACE(1)) + '" ' +
		'groupd="'+ COALESCE(CAST(@groupd AS VARCHAR(50)), SPACE(1)) + '" ' 
    
    SET @LogSPData = @LogSPData +
    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) +  '" '

	 IF @IsMyanmarOdds = 1
			SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds AS VARCHAR(50)), SPACE(1)) +  '" '
			
	SET @LogSPData = @LogSPData + ' />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 201,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)), SPACE(1)) + '" ' 
	    IF @IsMyanmarOdds = 0 
			SET @LogSPData = @LogSPData +
			'groupb="'+ COALESCE(CAST(@groupb AS VARCHAR(50)), SPACE(1)) + '" ' +
			'groupc="'+ COALESCE(CAST(@groupc AS VARCHAR(50)), SPACE(1)) + '" ' +
			'groupd="'+ COALESCE(CAST(@groupd AS VARCHAR(50)), SPACE(1)) + '" ' 
	    SET @LogSPData = @LogSPData +
	    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" ' +	  
	    'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) + '" '
		
		IF @IsMyanmarOdds = 1
			SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds AS VARCHAR(50)), SPACE(1)) + '" '
			
	    SET @LogSPData = @LogSPData + 'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 201,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH	

    --get data prepare write log for Keno
    DECLARE @LogDataKeno NVARCHAR(4000) = ''
    SELECT @LogDataKeno = COALESCE(@LogDataKeno + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
	    + '=' + '"' + CAST(cg.IsDisabled AS VARCHAR(1)) + '"' + SPACE(1), + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
	    + '=' + '"' + CAST(cg.IsDisabled AS VARCHAR(1)) + '"' + SPACE(1))
    FROM dbo.CustGameType cg WITH (NOLOCK)
    INNER JOIN #tmp_GameType gt ON cg.GameTypeID = gt.ID
    WHERE cg.CustID = @srecommend AND IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0

    SET @LogDataKeno = 'HideKeno="'+ COALESCE(CAST(@HideKeno AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno
	
	DECLARE @LogDataSP2 VARCHAR(4000)
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @CustID

	SET @LogDataSP2 = ''
	
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	INTO #temSportbettypeSetting
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4,@SettingStatus)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11,@SettingStatus)

	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13,@SettingStatus)

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' +  REPLACE(REPLACE(p.ProductName, ' ', ''),'*','') + '="' + COALESCE(CAST(iq.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM DBPRO.bodb02.dbo.Products p WITH (NOLOCK) 
		INNER JOIN (SELECT psd.ProductID, MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden
					FROM ProductSettingDetail psd WITH(NOLOCK)
						INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
																			AND	psd.BetType = psp.Bettype
																			AND psd.SettingType IN (4,11,13)		-- Product Status
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
						INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
						CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
					WHERE psd.ProductID <> 20 
					GROUP BY psd.ProductID	
					) iq ON iq.ProductID = p.ProductID

	SELECT @LogDataSP2	= @LogDataSP2 
						+ 'Disable' + CAST(Sporttype AS VARCHAR) + '_' + CAST(Bettype AS VARCHAR)
						+ '="' + COALESCE(CAST(custIsDisable AS VARCHAR(1)), SPACE(1)) + '" '
	FROM (
		SELECT	psp.Sporttype,
				psp.Bettype,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, psp.bitmapOrder)) AS custIsDisable
		FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	ProductStatusProfile AS psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype AND psd.BetType = psp.Bettype 
			INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
			CROSS APPLY CustProductStatus WITH(NOLOCK)
		WHERE CustID = @custid AND (psd.ProductID <> 20)
			AND psd.SettingType IN (4,11,13)-- Product Status, Game Status
	)iq

	--Log for VR lock Status
	DECLARE @VRLockedStatus_Soccer BIT = 0
	DECLARE @VRLockedStatus_OS BIT = 0

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @srecommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @srecommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

    --Log status
    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(1)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@UplineClosed AS VARCHAR(1)), SPACE(1)) + '" ' +
	'Danger="'+ COALESCE(CAST(@DangerSuper AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger2="'+ COALESCE(CAST(@DangerSuper2 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger3="'+ COALESCE(CAST(@DangerSuper3 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger4="'+ COALESCE(CAST(@DangerSuper4 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger5="'+ COALESCE(CAST(@DangerSuper5 AS VARCHAR(5)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Special=" " ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +	
   
    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableCasino="'+ COALESCE(CAST(@DisableCasino AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableAutoMPT="'+ COALESCE(CAST(@DisableAutoMPT AS VARCHAR(1)), SPACE(1)) + '" ' +
    'IsInternal="'+ COALESCE(CAST(@IsInternal AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableNumber="' + COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' +
 
	'DisableSuperLive="' + COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" ' +  @LogDataKeno + @LogDataSP2 + 
    '/>'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 1101,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'closed="'+ COALESCE(CAST(@UplineClosed AS VARCHAR(1)), SPACE(1)) + '" ' +
		'Danger="'+ COALESCE(CAST(@DangerSuper AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger2="'+ COALESCE(CAST(@DangerSuper2 AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger3="'+ COALESCE(CAST(@DangerSuper3 AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger4="'+ COALESCE(CAST(@DangerSuper4 AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger5="'+ COALESCE(CAST(@DangerSuper5 AS VARCHAR(5)), SPACE(1)) + '" ' +
		--20171206@Johnson: add more log for status
		'Special=" " ' +
		'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +
		'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
		'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	
	    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
	
	    'DisableCasino="'+ COALESCE(CAST(@DisableCasino AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'DisableAutoMPT="'+ COALESCE(CAST(@DisableAutoMPT AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'IsInternal="'+ COALESCE(CAST(@IsInternal AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'DisableNumber="' + COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' +
	   
		'DisableSuperLive="' + COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" ' +   @LogDataKeno + @LogDataSP2 +
	    'ErrMsg="'+ ERROR_MESSAGE() + ' />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 1101,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH


    -- Write Log Credit	
    DECLARE @LogSPCredit VARCHAR(MAX)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + ',
    SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) 

	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1210 as '@ActionID',
						getdate() as '@LogDate'
					FOR XML PATH('Row')	
				)

	EXEC bodb_CustomerLog.sb.CustomerLog_SendMessage @xml = @log, 
													@MessageType='MessageType_CustomerLog_UserLog_Credit', 
													@functionName = 'UserLog_Others',
													@SB_Error = @SB_Error out

	--if ssb error
	IF @SB_Error = 1
	BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1210
		END TRY
		BEGIN CATCH
			SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + ',
				SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + ',
				ErrMsg=' + ERROR_MESSAGE()
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1210
		END CATCH
    END
	
    --Log positiontaking
    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg><s spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_1), SPACE(1)) + '" ' +
    'spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_2), SPACE(1)) + '" ' +
    'spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_3), SPACE(1)) + '" ' +
    'spt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_4), SPACE(1)) + '" ' +
    'spt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_5), SPACE(1)) + '" ' +
    'spt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_6), SPACE(1)) + '" ' +
    'spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_7), SPACE(1)) + '" ' +
    'spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_8), SPACE(1)) + '" ' +
    'spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_9), SPACE(1)) + '" ' +
    'spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_10), SPACE(1)) + '" ' +
    'v2spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_10), SPACE(1)) + '" ' +
    'v3spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_10), SPACE(1)) + '" ' +
    'v5spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_10), SPACE(1)) + '" ' +
    'v8spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_10), SPACE(1)) + '" ' +
    'v10spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_10), SPACE(1)) + '" ' +
    'v11spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_10), SPACE(1)) + '" ' +
    'v99spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_10), SPACE(1)) + '" ' +
    'spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_9999), SPACE(1)) + '" ' +
    'slivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_1), SPACE(1)) + '" ' +
    'slivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_3), SPACE(1)) + '" ' +
    'slivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_7), SPACE(1)) + '" ' +
    'slivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_8), SPACE(1)) + '" ' +

    'v2spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_1), SPACE(1)) + '" ' +
    'v2spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_2), SPACE(1)) + '" ' +
    'v2spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_3), SPACE(1)) + '" ' +
    'v2spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_7), SPACE(1)) + '" ' +
    'v2spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_8), SPACE(1)) + '" ' +
 
    'v2spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_20), SPACE(1)) + '" ' +
    'v2spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_9999), SPACE(1)) + '" ' +

    'v3spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_1), SPACE(1)) + '" ' +
    'v3spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_2), SPACE(1)) + '" ' +
    'v3spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_3), SPACE(1)) + '" ' +
    'v3spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_20), SPACE(1)) + '" ' +

    'v5spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_1), SPACE(1)) + '" ' +
    'v5spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_2), SPACE(1)) + '" ' +
    'v5spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_3), SPACE(1)) + '" ' +
    'v5spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_20), SPACE(1)) + '" ' +
    'v5spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_9999), SPACE(1)) + '" ' +

    'v8spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_1), SPACE(1)) + '" ' +
    'v8spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_3), SPACE(1)) + '" ' +
    'v8spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_20), SPACE(1)) + '" ' +

    'v10spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_1), SPACE(1)) + '" ' +
    'v10spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_2), SPACE(1)) + '" ' +
    'v10spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_3), SPACE(1)) + '" ' +
    'v10spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_20), SPACE(1)) + '" ' +

    'v11spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_1), SPACE(1)) + '" ' +
    'v11spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_20), SPACE(1)) + '" ' +

    'v99spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_1), SPACE(1)) + '" ' +
    'v99spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_2), SPACE(1)) + '" ' +
    'v99spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_3), SPACE(1)) + '" ' +
    'v99spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_9), SPACE(1)) + '" ' +
    'v99spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_20), SPACE(1)) + '" ' +
	'v99spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_9999), SPACE(1)) + '" ' +
    'v161spt_81="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_81), SPACE(1)) + '" ' +
    'v161spt_83="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_83), SPACE(1)) + '" ' +
    'v161spt_86="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_86), SPACE(1)) + '" ' +
    'v161spt_88="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_88), SPACE(1)) + '" ' +
    'v161slivept_85="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_85), SPACE(1)) + '" ' +
    'v161slivept_86="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_86), SPACE(1)) + '" ' + 
    'v161slivept_87="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_87), SPACE(1)) + '" ' + 
    'v161slivept_89="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_89), SPACE(1)) + '" ' + 
    'v161slivept_90="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_90), SPACE(1)) + '" />' +

    '<au a_spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_1), SPACE(1)) + '" ' +
    'a_spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_2), SPACE(1)) + '" ' +
    'a_spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_3), SPACE(1)) + '" ' +
    'a_spt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_4), SPACE(1)) + '" ' +
    'a_spt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_5), SPACE(1)) + '" ' +
    'a_spt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_6), SPACE(1)) + '" ' +
    'a_spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_7), SPACE(1)) + '" ' +
    'a_spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_8), SPACE(1)) + '" ' +
    'a_spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_9), SPACE(1)) + '" ' +
    'a_spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_10), SPACE(1)) + '" ' +
    'a_v2spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_10), SPACE(1)) + '" ' +
    'a_v3spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_10), SPACE(1)) + '" ' +
    'a_v5spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_10), SPACE(1)) + '" ' +
    'a_v8spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_10), SPACE(1)) + '" ' +
    'a_v10spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_10), SPACE(1)) + '" ' +
    'a_v11spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_10), SPACE(1)) + '" ' +
    'a_v99spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_10), SPACE(1)) + '" ' +
    'a_spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_9999), SPACE(1)) + '" ' +
    'a_slivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_1), SPACE(1)) + '" ' +
    'a_slivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_3), SPACE(1)) + '" ' +
    'a_slivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_7), SPACE(1)) + '" ' +
    'a_slivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_8), SPACE(1)) + '" ' +

    'a_v2spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_1), SPACE(1)) + '" ' +
    'a_v2spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_2), SPACE(1)) + '" ' +
    'a_v2spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_3), SPACE(1)) + '" ' +
    'a_v2spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_7), SPACE(1)) + '" ' +
    'a_v2spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_8), SPACE(1)) + '" ' +
    
    'a_v2spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_20), SPACE(1)) + '" ' +
    'a_v2spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_9999), SPACE(1)) + '" ' +

    'a_v3spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_1), SPACE(1)) + '" ' +
    'a_v3spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_2), SPACE(1)) + '" ' +
    'a_v3spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_3), SPACE(1)) + '" ' +
    'a_v3spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_20), SPACE(1)) + '" ' +

    'a_v5spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_1), SPACE(1)) + '" ' +
    'a_v5spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_2), SPACE(1)) + '" ' +
    'a_v5spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_3), SPACE(1)) + '" ' +
    'a_v5spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_20), SPACE(1)) + '" ' +
    'a_v5spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_9999), SPACE(1)) + '" ' +

    'a_v8spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_1), SPACE(1)) + '" ' +
    'a_v8spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_3), SPACE(1)) + '" ' +
    'a_v8spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_20), SPACE(1)) + '" ' +

    'a_v10spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_1), SPACE(1)) + '" ' +
    'a_v10spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_2), SPACE(1)) + '" ' +
    'a_v10spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_3), SPACE(1)) + '" ' +
    'a_v10spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_20), SPACE(1)) + '" ' +

    'a_v11spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_1), SPACE(1)) + '" ' +
    'a_v11spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_20), SPACE(1)) + '" ' +

    'a_v99spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_1), SPACE(1)) + '" ' +
    'a_v99spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_2), SPACE(1)) + '" ' +
    'a_v99spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_3), SPACE(1)) + '" ' +
    'a_v99spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_9), SPACE(1)) + '" ' +
    'a_v99spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_20), SPACE(1)) + '" ' +
	'a_v99spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_9999), SPACE(1)) + '" ' +

    'a_v161spt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_81), SPACE(1)) + '" ' +
    'a_v161spt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_83), SPACE(1)) + '" ' + 
    'a_v161spt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_86), SPACE(1)) + '" ' +
    'a_v161spt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_88), SPACE(1)) + '" ' +
    'a_v161slivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_85), SPACE(1)) + '" ' +
    'a_v161slivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_86), SPACE(1)) + '" ' + 
    'a_v161slivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_87), SPACE(1)) + '" ' + 
    'a_v161slivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_89), SPACE(1)) + '" ' + 
    'a_v161slivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_90), SPACE(1)) + '" />' +

    '<m mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_1), SPACE(1)) + '" ' +
    'mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_2), SPACE(1)) + '" ' +
    'mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_3), SPACE(1)) + '" ' +
    'mpt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_4), SPACE(1)) + '" ' +
    'mpt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_5), SPACE(1)) + '" ' +
    'mpt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_6), SPACE(1)) + '" ' +
    'mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_7), SPACE(1)) + '" ' +
    'mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_8), SPACE(1)) + '" ' +
    'mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_9), SPACE(1)) + '" ' +
    'mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_10), SPACE(1)) + '" ' +
    'v2mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_10), SPACE(1)) + '" ' +
    'v3mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_10), SPACE(1)) + '" ' +
    'v5mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_10), SPACE(1)) + '" ' +
    'v8mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_10), SPACE(1)) + '" ' +
    'v10mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_10), SPACE(1)) + '" ' +
    'v11mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_10), SPACE(1)) + '" ' +
    'v99mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_10), SPACE(1)) + '" ' +
    'mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_9999), SPACE(1)) + '" ' +
    'mlivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_1), SPACE(1)) + '" ' +
    'mlivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_3), SPACE(1)) + '" ' +
    'mlivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_7), SPACE(1)) + '" ' +
    'mlivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_8), SPACE(1)) + '" ' +

    'v2mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_1), SPACE(1)) + '" ' +
    'v2mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_2), SPACE(1)) + '" ' +
    'v2mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_3), SPACE(1)) + '" ' +
    'v2mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_7), SPACE(1)) + '" ' +
    'v2mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_8), SPACE(1)) + '" ' +
   
    'v2mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_20), SPACE(1)) + '" ' +
    'v2mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_9999), SPACE(1)) + '" ' +

    'v3mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_1), SPACE(1)) + '" ' +
    'v3mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_2), SPACE(1)) + '" ' +
    'v3mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_3), SPACE(1)) + '" ' +
    'v3mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_20), SPACE(1)) + '" ' +
    

    'v5mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_1), SPACE(1)) + '" ' +
    'v5mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_2), SPACE(1)) + '" ' +
    'v5mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_3), SPACE(1)) + '" ' +
    'v5mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_20), SPACE(1)) + '" ' +
    'v5mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_9999), SPACE(1)) + '" ' +

    'v8mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_1), SPACE(1)) + '" ' +
    'v8mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_3), SPACE(1)) + '" ' +
    'v8mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_20), SPACE(1)) + '" ' +

    'v10mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_1), SPACE(1)) + '" ' +
    'v10mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_2), SPACE(1)) + '" ' +
    'v10mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_3), SPACE(1)) + '" ' +
    'v10mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_20), SPACE(1)) + '" ' +

    'v11mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_1), SPACE(1)) + '" ' +
    'v11mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_20), SPACE(1)) + '" ' +

    'v99mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_1), SPACE(1)) + '" ' +
    'v99mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_2), SPACE(1)) + '" ' +
    'v99mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_3), SPACE(1)) + '" ' +
    'v99mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_20), SPACE(1)) + '" ' + 

    -- mix parlay of mixed sports
    'v99mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9), SPACE(1)) + '" ' +
	'v99mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9999), SPACE(1)) + '" ' +

    -- number game
    'v161mpt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_81), SPACE(1)) + '" ' + 
    'v161mpt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_83), SPACE(1)) + '" ' + 
    'v161mpt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_86), SPACE(1)) + '" ' + 
    'v161mpt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_88), SPACE(1)) + '" ' + 
    'v161mlivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_85), SPACE(1)) + '" ' + 
    'v161mlivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_86), SPACE(1)) + '" ' + 
    'v161mlivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_87), SPACE(1)) + '" ' + 
    'v161mlivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_89), SPACE(1)) + '" ' + 
    'v161mlivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_90), SPACE(1)) + '" /></Acc_CustomerInsMember_SAg>' 

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 401,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_SAg><s spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_1), SPACE(1)) + '" ' +
	    'spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_2), SPACE(1)) + '" ' +
	    'spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_3), SPACE(1)) + '" ' +
	    'spt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_4), SPACE(1)) + '" ' +
	    'spt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_5), SPACE(1)) + '" ' +
	    'spt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_6), SPACE(1)) + '" ' +
	    'spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_7), SPACE(1)) + '" ' +
	    'spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_8), SPACE(1)) + '" ' +
	    'spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_9), SPACE(1)) + '" ' +
	    'spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_10), SPACE(1)) + '" ' +
	    'v2spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_10), SPACE(1)) + '" ' +
	    'v3spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_10), SPACE(1)) + '" ' +
	    'v5spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_10), SPACE(1)) + '" ' +
	    'v8spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_10), SPACE(1)) + '" ' +
	    'v10spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_10), SPACE(1)) + '" ' +
	    'v11spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_10), SPACE(1)) + '" ' +
	    'v99spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_10), SPACE(1)) + '" ' +
	    'spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@spositiontaking_9999), SPACE(1)) + '" ' +
	    'slivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_1), SPACE(1)) + '" ' +
	    'slivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_3), SPACE(1)) + '" ' +
	    'slivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_7), SPACE(1)) + '" ' +
	    'slivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@slivepositiontaking_8), SPACE(1)) + '" ' +

	    'v2spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_1), SPACE(1)) + '" ' +
	    'v2spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_2), SPACE(1)) + '" ' +
	    'v2spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_3), SPACE(1)) + '" ' +
	    'v2spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_7), SPACE(1)) + '" ' +
	    'v2spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_8), SPACE(1)) + '" ' +
	    
	    'v2spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_20), SPACE(1)) + '" ' +
	    'v2spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v2spositiontaking_9999), SPACE(1)) + '" ' +

	    'v3spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_1), SPACE(1)) + '" ' +
	    'v3spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_2), SPACE(1)) + '" ' +
	    'v3spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_3), SPACE(1)) + '" ' +
	    'v3spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v3spositiontaking_20), SPACE(1)) + '" ' +

	    'v5spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_1), SPACE(1)) + '" ' +
	    'v5spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_2), SPACE(1)) + '" ' +
	    'v5spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_3), SPACE(1)) + '" ' +
	    'v5spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_20), SPACE(1)) + '" ' +
	    'v5spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v5spositiontaking_9999), SPACE(1)) + '" ' +

	    'v8spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_1), SPACE(1)) + '" ' +
	    'v8spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_3), SPACE(1)) + '" ' +
	    'v8spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v8spositiontaking_20), SPACE(1)) + '" ' +

	    'v10spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_1), SPACE(1)) + '" ' +
	    'v10spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_2), SPACE(1)) + '" ' +
	    'v10spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_3), SPACE(1)) + '" ' +
	    'v10spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v10spositiontaking_20), SPACE(1)) + '" ' +

	    'v11spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_1), SPACE(1)) + '" ' +
	    'v11spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v11spositiontaking_20), SPACE(1)) + '" ' +

	    'v99spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_1), SPACE(1)) + '" ' +
	    'v99spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_2), SPACE(1)) + '" ' +
	    'v99spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_3), SPACE(1)) + '" ' +
	    'v99spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_9), SPACE(1)) + '" ' +
	    'v99spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_20), SPACE(1)) + '" ' +
		'v99spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99spositiontaking_9999), SPACE(1)) + '" ' +
	    'v161spt_81="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_81), SPACE(1)) + '" ' +
	    'v161spt_83="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_83), SPACE(1)) + '" ' +
	    'v161spt_86="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_86), SPACE(1)) + '" ' +
	    'v161spt_88="' + COALESCE(dbo.f_FomatNumericToChar(@v161spositiontaking_88), SPACE(1)) + '" ' +
	    'v161slivept_85="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_85), SPACE(1)) + '" ' +
	    'v161slivept_86="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_86), SPACE(1)) + '" ' + 
	    'v161slivept_87="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_87), SPACE(1)) + '" ' + 
	    'v161slivept_89="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_89), SPACE(1)) + '" ' + 
	    'v161slivept_90="' + COALESCE(dbo.f_FomatNumericToChar(@v161slivepositiontaking_90), SPACE(1)) + '" />' +

	    '<au a_spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_1), SPACE(1)) + '" ' +
	    'a_spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_2), SPACE(1)) + '" ' +
	    'a_spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_3), SPACE(1)) + '" ' +
	    'a_spt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_4), SPACE(1)) + '" ' +
	    'a_spt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_5), SPACE(1)) + '" ' +
	    'a_spt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_6), SPACE(1)) + '" ' +
	    'a_spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_7), SPACE(1)) + '" ' +
	    'a_spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_8), SPACE(1)) + '" ' +
	    'a_spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_9), SPACE(1)) + '" ' +
	    'a_spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v2spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v3spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v5spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v8spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v10spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v11spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_10), SPACE(1)) + '" ' +
	    'a_v99spt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_10), SPACE(1)) + '" ' +
	    'a_spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_spositiontaking_9999), SPACE(1)) + '" ' +
	    'a_slivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_1), SPACE(1)) + '" ' +
	    'a_slivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_3), SPACE(1)) + '" ' +
	    'a_slivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_7), SPACE(1)) + '" ' +
	    'a_slivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_slivepositiontaking_8), SPACE(1)) + '" ' +

	    'a_v2spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v2spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_2), SPACE(1)) + '" ' +
	    'a_v2spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v2spt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_7), SPACE(1)) + '" ' +
	    'a_v2spt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_8), SPACE(1)) + '" ' +

	    'a_v2spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_20), SPACE(1)) + '" ' +
	    'a_v2spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2spositiontaking_9999), SPACE(1)) + '" ' +

	    'a_v3spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v3spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_2), SPACE(1)) + '" ' +
	    'a_v3spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v3spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3spositiontaking_20), SPACE(1)) + '" ' +

	    'a_v5spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v5spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_2), SPACE(1)) + '" ' +
	    'a_v5spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v5spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_20), SPACE(1)) + '" ' +
	    'a_v5spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5spositiontaking_9999), SPACE(1)) + '" ' +

	    'a_v8spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v8spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v8spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8spositiontaking_20), SPACE(1)) + '" ' +

	    'a_v10spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v10spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_2), SPACE(1)) + '" ' +
	    'a_v10spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v10spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10spositiontaking_20), SPACE(1)) + '" ' +

	    'a_v11spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v11spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11spositiontaking_20), SPACE(1)) + '" ' +

	    'a_v99spt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_1), SPACE(1)) + '" ' +
	    'a_v99spt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_2), SPACE(1)) + '" ' +
	    'a_v99spt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_3), SPACE(1)) + '" ' +
	    'a_v99spt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_9), SPACE(1)) + '" ' +
	    'a_v99spt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_20), SPACE(1)) + '" ' +
		'a_v99spt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99spositiontaking_9999), SPACE(1)) + '" ' +

	    'a_v161spt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_81), SPACE(1)) + '" ' +
	    'a_v161spt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_83), SPACE(1)) + '" ' + 
	    'a_v161spt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_86), SPACE(1)) + '" ' +
	    'a_v161spt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161spositiontaking_88), SPACE(1)) + '" ' +
	    'a_v161slivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_85), SPACE(1)) + '" ' +
	    'a_v161slivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_86), SPACE(1)) + '" ' + 
	    'a_v161slivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_87), SPACE(1)) + '" ' + 
	    'a_v161slivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_89), SPACE(1)) + '" ' + 
	    'a_v161slivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v161slivepositiontaking_90), SPACE(1)) + '" />' +

	    '<m mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_1), SPACE(1)) + '" ' +
	    'mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_2), SPACE(1)) + '" ' +
	    'mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_3), SPACE(1)) + '" ' +
	    'mpt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_4), SPACE(1)) + '" ' +
	    'mpt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_5), SPACE(1)) + '" ' +
	    'mpt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_6), SPACE(1)) + '" ' +
	    'mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_7), SPACE(1)) + '" ' +
	    'mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_8), SPACE(1)) + '" ' +
	    'mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_9), SPACE(1)) + '" ' +
	    'mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_10), SPACE(1)) + '" ' +
	    'v2mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_10), SPACE(1)) + '" ' +
	    'v3mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_10), SPACE(1)) + '" ' +
	    'v5mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_10), SPACE(1)) + '" ' +
	    'v8mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_10), SPACE(1)) + '" ' +
	    'v10mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_10), SPACE(1)) + '" ' +
	    'v11mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_10), SPACE(1)) + '" ' +
	    'v99mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_10), SPACE(1)) + '" ' +
	    'mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@mpositiontaking_9999), SPACE(1)) + '" ' +
	    'mlivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_1), SPACE(1)) + '" ' +
	    'mlivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_3), SPACE(1)) + '" ' +
	    'mlivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_7), SPACE(1)) + '" ' +
	    'mlivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@mlivepositiontaking_8), SPACE(1)) + '" ' +

	    'v2mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_1), SPACE(1)) + '" ' +
	    'v2mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_2), SPACE(1)) + '" ' +
	    'v2mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_3), SPACE(1)) + '" ' +
	    'v2mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_7), SPACE(1)) + '" ' +
	    'v2mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_8), SPACE(1)) + '" ' +
	    
	    'v2mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_20), SPACE(1)) + '" ' +
	    'v2mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v2mpositiontaking_9999), SPACE(1)) + '" ' +

	    'v3mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_1), SPACE(1)) + '" ' +
	    'v3mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_2), SPACE(1)) + '" ' +
	    'v3mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_3), SPACE(1)) + '" ' +
	    'v3mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v3mpositiontaking_20), SPACE(1)) + '" ' +

	    'v5mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_1), SPACE(1)) + '" ' +
	    'v5mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_2), SPACE(1)) + '" ' +
	    'v5mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_3), SPACE(1)) + '" ' +
	    'v5mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_20), SPACE(1)) + '" ' +
	    'v5mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v5mpositiontaking_9999), SPACE(1)) + '" ' +

	    'v8mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_1), SPACE(1)) + '" ' +
	    'v8mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_3), SPACE(1)) + '" ' +
	    'v8mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v8mpositiontaking_20), SPACE(1)) + '" ' +

	    'v10mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_1), SPACE(1)) + '" ' +
	    'v10mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_2), SPACE(1)) + '" ' +
	    'v10mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_3), SPACE(1)) + '" ' +
	    'v10mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v10mpositiontaking_20), SPACE(1)) + '" ' +

	    'v11mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_1), SPACE(1)) + '" ' +
	    'v11mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v11mpositiontaking_20), SPACE(1)) + '" ' +

	    'v99mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_1), SPACE(1)) + '" ' +
	    'v99mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_2), SPACE(1)) + '" ' +
	    'v99mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_3), SPACE(1)) + '" ' +
	    'v99mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_20), SPACE(1)) + '" ' + 

	    -- mix parlay of mixed sports
	    'v99mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9), SPACE(1)) + '" ' +
		'v99mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9999), SPACE(1)) + '" ' +
	    -- number game
	    'v161mpt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_81), SPACE(1)) + '" ' + 
	    'v161mpt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_83), SPACE(1)) + '" ' + 
	    'v161mpt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_86), SPACE(1)) + '" ' + 
	    'v161mpt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mpositiontaking_88), SPACE(1)) + '" ' + 
	    'v161mlivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_85), SPACE(1)) + '" ' + 
	    'v161mlivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_86), SPACE(1)) + '" ' + 
	    'v161mlivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_87), SPACE(1)) + '" ' + 
	    'v161mlivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_89), SPACE(1)) + '" ' + 
	    'v161mlivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@v161mlivepositiontaking_90), SPACE(1)) + '" ' +
	    'ErrMsg="'+ ERROR_MESSAGE() + '" /></Acc_CustomerInsMember_SAg>' 
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 401,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH
END
GO

