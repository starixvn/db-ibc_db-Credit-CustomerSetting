/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_MAg]
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@discountcs DECIMAL(9, 8),
	--1x2
	@discount1x2 DECIMAL(9, 8) = 0,
			
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@email NVARCHAR(50) = NULL,
	@fax NVARCHAR(50),
	@address NVARCHAR(80)=NULL,
	@city NVARCHAR(50)	 =NULL,
	@state NVARCHAR(50) =NULL,
	@country NVARCHAR(50)=NULL,
	@postal NVARCHAR(50) =NULL,
	@groupa DECIMAL(9, 8),
	@groupb DECIMAL(9, 8),
	@groupc DECIMAL(9, 8),
	@groupd DECIMAL(9, 8),
	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in case direct master add new agent
	 	
	--@IsInternal BIT = 0,
	
	@MinBet MONEY,
	@MaxBet MONEY,
	@MaxPerMatch MONEY,
	
	@MinBetv2 MONEY,
	@MaxBetv2 MONEY,
	@MaxPerMatchv2 MONEY,

	@MinBetv3 MONEY,
	@MaxBetv3 MONEY,
	@MaxPerMatchv3 MONEY,

	@MinBetv5 MONEY,
	@MaxBetv5 MONEY,
	@MaxPerMatchv5 MONEY,

	@MinBetv8 MONEY,
	@MaxBetv8 MONEY,
	@MaxPerMatchv8 MONEY,

	@MinBetv10 MONEY,
	@MaxBetv10 MONEY,
	@MaxPerMatchv10 MONEY,

	@MinBetv11 MONEY,
	@MaxBetv11 MONEY,
	@MaxPerMatchv11 MONEY,

	@MinBetv99 MONEY,
	@MaxBetv99 MONEY,
	@MaxPerMatchv99 MONEY,
	
	-- mix parlay of mixed sports
	@MinBetv99mp MONEY,
	@MaxBetv99mp MONEY,
	@MaxPerMatchv99mp MONEY,
	
	-- mix parlay of soccer sports
	@MinBetv1mp MONEY,
	@MaxBetv1mp MONEY,
	@MaxPerMatchv1mp MONEY,	

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
	@maxcredit MONEY = 0,
	@mrecommend INT,
	@apositiontaking_1 SMALLMONEY,
	@apositiontaking_2 SMALLMONEY,
	@apositiontaking_3 SMALLMONEY,
	@apositiontaking_4 SMALLMONEY,
	@apositiontaking_5 SMALLMONEY,
	@apositiontaking_6 SMALLMONEY,
	@apositiontaking_7 SMALLMONEY,
	@apositiontaking_8 SMALLMONEY,
	@apositiontaking_9 SMALLMONEY,
	@apositiontaking_10 SMALLMONEY,
	@v2apositiontaking_10 SMALLMONEY,
	@v3apositiontaking_10 SMALLMONEY,
	@v5apositiontaking_10 SMALLMONEY,
	@v8apositiontaking_10 SMALLMONEY,
	@v10apositiontaking_10 SMALLMONEY,
	@v11apositiontaking_10 SMALLMONEY,
	@v99apositiontaking_10 SMALLMONEY,
	@apositiontaking_9999 SMALLMONEY = 0,
	
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
	@v2mpositiontaking_10 SMALLMONEY,
		
	@v3mpositiontaking_10 SMALLMONEY,
	@v5mpositiontaking_10 SMALLMONEY,
	@v8mpositiontaking_10 SMALLMONEY,
	@v10mpositiontaking_10 SMALLMONEY,
	@v11mpositiontaking_10 SMALLMONEY,
	@v99mpositiontaking_10 SMALLMONEY,
	@mpositiontaking_9999 SMALLMONEY = 0,
	
	@alivepositiontaking_1 SMALLMONEY,
	@alivepositiontaking_3 SMALLMONEY,
	@alivepositiontaking_7 SMALLMONEY,
	@alivepositiontaking_8 SMALLMONEY,
	@mlivepositiontaking_1 SMALLMONEY,
	@mlivepositiontaking_3 SMALLMONEY,
	@mlivepositiontaking_7 SMALLMONEY,
	@mlivepositiontaking_8 SMALLMONEY,
	
	@v2apositiontaking_1 SMALLMONEY,
	@v2apositiontaking_2 SMALLMONEY,
	@v2apositiontaking_3 SMALLMONEY,
	@v2apositiontaking_7 SMALLMONEY,
	@v2apositiontaking_8 SMALLMONEY,
--	@v2apositiontaking_9 SMALLMONEY,
	@v2apositiontaking_20 SMALLMONEY,
	@v2apositiontaking_9999 SMALLMONEY = 0,

	@v3apositiontaking_1 SMALLMONEY,
	@v3apositiontaking_2 SMALLMONEY,
	@v3apositiontaking_3 SMALLMONEY,
	@v3apositiontaking_20 SMALLMONEY,

	@v5apositiontaking_1 SMALLMONEY,
	@v5apositiontaking_2 SMALLMONEY,
	@v5apositiontaking_3 SMALLMONEY,
	@v5apositiontaking_20 SMALLMONEY,
	@v5apositiontaking_9999 SMALLMONEY = 0,

	@v8apositiontaking_1 SMALLMONEY,
	@v8apositiontaking_3 SMALLMONEY,
	@v8apositiontaking_20 SMALLMONEY,

	@v10apositiontaking_1 SMALLMONEY,
	@v10apositiontaking_2 SMALLMONEY,
	@v10apositiontaking_3 SMALLMONEY,
	@v10apositiontaking_20 SMALLMONEY,

	@v11apositiontaking_1 SMALLMONEY,
	@v11apositiontaking_20 SMALLMONEY,

	@v99apositiontaking_1 SMALLMONEY,
	@v99apositiontaking_2 SMALLMONEY,
	@v99apositiontaking_3 SMALLMONEY,
	@v99apositiontaking_20 SMALLMONEY,
	@v99apositiontaking_9999 SMALLMONEY,
	
	-- mix parlay of mixed sports	
	@v99apositiontaking_9 SMALLMONEY, 		
	
	@v2mpositiontaking_1 SMALLMONEY,
	@v2mpositiontaking_2 SMALLMONEY,
	@v2mpositiontaking_3 SMALLMONEY,
	@v2mpositiontaking_7 SMALLMONEY,
	@v2mpositiontaking_8 SMALLMONEY,
--	@v2mpositiontaking_9 SMALLMONEY,
	@v2mpositiontaking_20 SMALLMONEY,
	@v2mpositiontaking_9999 SMALLMONEY = 0,

	@v3mpositiontaking_1 SMALLMONEY,
	@v3mpositiontaking_2 SMALLMONEY,
	@v3mpositiontaking_3 SMALLMONEY,
	@v3mpositiontaking_20 SMALLMONEY,

	@v5mpositiontaking_1 SMALLMONEY,
	@v5mpositiontaking_2 SMALLMONEY,
	@v5mpositiontaking_3 SMALLMONEY,
	@v5mpositiontaking_20 SMALLMONEY,
	@v5mpositiontaking_9999 SMALLMONEY = 0,

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
	
	-- mix parlay of mixed sports
	@v99mpositiontaking_9 SMALLMONEY,	
	
	--Auto Master PT
	@auto_mpositiontaking_1 SMALLMONEY = 0,
	@auto_mpositiontaking_2 SMALLMONEY = 0,
	@auto_mpositiontaking_3 SMALLMONEY = 0,
	@auto_mpositiontaking_4 SMALLMONEY = 0,
	@auto_mpositiontaking_5 SMALLMONEY = 0,
	@auto_mpositiontaking_6 SMALLMONEY = 0,
	@auto_mpositiontaking_7 SMALLMONEY = 0,
	@auto_mpositiontaking_8 SMALLMONEY = 0,
	@auto_mpositiontaking_9 SMALLMONEY = 0,
	@auto_mpositiontaking_10 SMALLMONEY = 0,
	@auto_v2mpositiontaking_10 SMALLMONEY = 0,
	@auto_v3mpositiontaking_10 SMALLMONEY = 0,
	@auto_v5mpositiontaking_10 SMALLMONEY = 0,
	@auto_v8mpositiontaking_10 SMALLMONEY = 0,
	@auto_v10mpositiontaking_10 SMALLMONEY = 0,
	@auto_v11mpositiontaking_10 SMALLMONEY = 0,
	@auto_v99mpositiontaking_10 SMALLMONEY = 0,
	@auto_mpositiontaking_9999 SMALLMONEY = 0,
	@auto_mlivepositiontaking_1 SMALLMONEY = 0,
	@auto_mlivepositiontaking_3 SMALLMONEY = 0,
	@auto_mlivepositiontaking_7 SMALLMONEY = 0,
	@auto_mlivepositiontaking_8 SMALLMONEY = 0,
	
	@auto_v2mpositiontaking_1 SMALLMONEY = 0,
	@auto_v2mpositiontaking_2 SMALLMONEY = 0,
	@auto_v2mpositiontaking_3 SMALLMONEY = 0,
	@auto_v2mpositiontaking_7 SMALLMONEY = 0,
	@auto_v2mpositiontaking_8 SMALLMONEY = 0,
--	@auto_v2mpositiontaking_9 SMALLMONEY = 0,
	@auto_v2mpositiontaking_20 SMALLMONEY = 0,
	@auto_v2mpositiontaking_9999 SMALLMONEY = 0,
	
	@auto_v3mpositiontaking_1 SMALLMONEY = 0,
	@auto_v3mpositiontaking_2 SMALLMONEY = 0,
	@auto_v3mpositiontaking_3 SMALLMONEY = 0,	
	@auto_v3mpositiontaking_20 SMALLMONEY = 0,
	
	@auto_v5mpositiontaking_1 SMALLMONEY = 0,
	@auto_v5mpositiontaking_2 SMALLMONEY = 0,
	@auto_v5mpositiontaking_3 SMALLMONEY = 0,	
	@auto_v5mpositiontaking_20 SMALLMONEY = 0,
	@auto_v5mpositiontaking_9999 SMALLMONEY = 0,
	
	@auto_v8mpositiontaking_1 SMALLMONEY = 0,	
	@auto_v8mpositiontaking_3 SMALLMONEY = 0,	
	@auto_v8mpositiontaking_20 SMALLMONEY = 0,
	
	@auto_v10mpositiontaking_1 SMALLMONEY = 0,
	@auto_v10mpositiontaking_2 SMALLMONEY = 0,
	@auto_v10mpositiontaking_3 SMALLMONEY = 0,	
	@auto_v10mpositiontaking_20 SMALLMONEY = 0,
	
	@auto_v11mpositiontaking_1 SMALLMONEY = 0,	
	@auto_v11mpositiontaking_20 SMALLMONEY = 0,
	
	@auto_v99mpositiontaking_1 SMALLMONEY = 0,
	@auto_v99mpositiontaking_2 SMALLMONEY = 0,
	@auto_v99mpositiontaking_3 SMALLMONEY = 0,	
	@auto_v99mpositiontaking_20 SMALLMONEY = 0,	
	@auto_v99mpositiontaking_9999 SMALLMONEY = 0,	

	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 SMALLMONEY = 0,	
	@SystemID		TINYINT=1,
	
	-- MyanmarOdds
	@discountMyanmarOdds DECIMAL(9,8)=0,
	
	@sitename VARCHAR(20) = '',
	@IP VARCHAR(15)='',
	
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT,
	@SettingStatus TINYINT = 0
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Master create Agent
DB: DBCUST/CustDB
Original:

Revisions:
    - 20081009@Phuc: Auto Master PT, Remove site 777
    - 20081022@Phuc: Add new sporttype 201, bettype 3 Hard code copy min/max/maxperbet/PT for 201 FROM 2 sporttype
	- 20090122@PhuongNguyen: Remove userpwd FROM log writing
	- 20090122@PhuongDao: Add new sporttype 201, bettype 2.
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission.
	- 20090407@Phuc: IF DisableFinancial (upline or webconfig) set m2 = n3, a2 = 0; get minbet201, maxbet201, maxpermatch201 FROM upline
	- 20090410@Kiwi: Fix to SELECT @DisableFinancial_WC instead of @DisableFinancial
	- 20090417@PhuongDao: Set default virtualrate = 0%
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed  
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Simon: Write Credit Log INTo Userlog_Credit table.
	- 20090917@Phuc: write log INTo DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status FROM the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100831@Lukas:	- Add setting information for Number game.
						- Add setting information for mix parlay of mixed sports 
						- Remove mix parlay of basketball
	- 20100909@Jamie: + Add param @DisableCasino to check the upline's setting 
					  + Remove param @DisableFinancial_WC 	
	- 20101019@Henry: Record execution time
	- 20101027@Lukas: Add max per ball (number game)
	-20101231@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110520@Johnson: Allow spaces between words in user name when creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20110822@Tom: Add P2P setting.
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@Error for inserting P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (from upline)
	- 20111226@Lukas: Add Live casino game - PT setting
	- 20120210@TOM: Insert default value of P2P Comm	
	- 20120502@Lukas: Encode XML values in logging
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120807@Dan: add default setting for virtual soccer
	- 20120928@Johnson: add double comm losing status
	- 20121011@Dan: add win limit setting for live casino
	- 20121128@Elodie: Get an error message FROM f_Get_MsgNameByMsgID function by language
	- 20130219@Johnson: Add virtual racing setting (sporttype : 181 , bettype : 1231)
						and write log on DBTXN if DBLOG failure
	- 20130717@Lukas: limit created customers in a minute
	- 20130731@Elodie: Apply progressive bonus
	- 20130905@Lukas: restrict new customers created: 100 customers per 10 minutes
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend INTo Soccer and Other Sport [Redmine:#5520] 
	- 20131107@Johnson: Apply execrep when insert setting INTo custsetting/custsetting3rd
	- 20131108@Elodie: Splitting bodb02 INTo CustDB (call sport, bettype by link database)
	- 20131120@Kathy: Add Virtual Greyhounds, Virtual Motor Racing (182, 184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140318@Patrick: Modify log for Keno status
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
	- 20140626@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20140822@Logan:   Add status & log for E-Sports [Redmine: #20531]
	- 20140926@Johnson: pass parameter @UplineSyncLiveCasino into Acc_CustomerInfo_Execrep_00
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
	- 20160801@Elodie: Pass more param into Acc_CustomerInfo_Execrep_00 [Redmine: #60809]
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
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]  
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526]
	- 20181102@Johnson: Apply service broker for logging [Redmine: #103547]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190510@Johnson: remove suspend status on setting page [redmine: #105587]
	- 20190923@Johnson: copy danger status from upline [redmine:#120056]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200903@Elodie: Remove IsInternal param [Redmine: #134911]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201027@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210308@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210319@Winfred: Check Site to limit create accounts [Redmine: #151526]
	- 20210405@Johnson: Hide log Gold Deluxe Setting [redmined:#151188]
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20211104@Johnson: Abnormal remark on Accounting Site [redmine: #163518]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220222@Elodie: Default VR for 789y site [Redmine: #168885]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20230303@Johnson: add auto suspend for Basketball[redmine: #184339]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230427@Luke: Separate lock function for Basketball [Redmine: #185991]	
Param's Explanation:
- @ErrCode:
    = 0: Create agent successfully.
    > 0: Specific Error.
  
- @ErrMsg: Error description.
- @SettingStatus: 0: Pro, 1: UAT
*/

BEGIN
    SET NOCOUNT ON

	EXEC [Acc_CheckUM] @CustID = @mrecommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN

----- Elodie @ 01 JUN 2015 -------------------
	CREATE TABLE #tmp_Sports(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	CREATE TABLE #tmp_Bettype(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	CREATE TABLE #tmp_GameType(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	
	BEGIN TRY
		INSERT INTO #tmp_Sports(ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID	
		FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBAGE')	
	END TRY
	BEGIN CATCH
		IF OBJECT_ID(N'tempdb..#tmp_Sports') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Sports
			INSERT INTO #tmp_Sports(ID, Name, IsDisabled, IBCBettypeID)
			SELECT ID, Name, IsDisabled, IBCBettypeID	
			FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBTXN')	
		END
	END CATCH

	BEGIN TRY			
		INSERT INTO #tmp_Bettype(ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID
		FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_Bettype') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Bettype
			INSERT INTO #tmp_Bettype(ID, Name, IsDisabled, IBCBettypeID)
			SELECT ID, Name, IsDisabled, IBCBettypeID
			FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBTXN')	
		END
	END CATCH

	BEGIN TRY		
		INSERT INTO #tmp_GameType(ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID
		FROM dbo.f_GetSportTypeBetTypeGameType(3,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_GameType') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_GameType
			INSERT INTO #tmp_GameType(ID, Name, IsDisabled, IBCBettypeID)
			SELECT ID, Name, IsDisabled, IBCBettypeID
			FROM dbo.f_GetSportTypeBetTypeGameType(3,'DBTXN')	
		END
	END CATCH
----- /Elodie @ 01 JUN 2015 -------------------
	DECLARE @Site NVARCHAR(50), @EnableVR BIT
	SELECT @Site = site FROM customer WITH(NOLOCK) WHERE CustID = @mrecommend

    ----- 20130717@Lukas -------------------
	declare @lastMinuteMemberCount INT

	SELECT @lastMinuteMemberCount = COUNT(1)
	FROM Customer c WITH(NOLOCK)
		INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
	WHERE ci.mrecommend = @mrecommend
		and ci.roleid = 2
		and creatdate > dateadd(minute, -10, CURRENT_TIMESTAMP)
		
	IF @lastMinuteMemberCount > 100
	BEGIN
		Select	@ErrMsg = case @Language 
						when 'E' then 'Sorry. You cannot create customer too often.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40029,@Language)
					end,
				@ErrCode = 998	
		return
	END
    ----- / 20130717@Lukas-----------------
    --20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP BIT
	
				EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = case @Language 
						when 'E' then 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
    --End check IP--------------------------------------------------	


	-----20160120@Lukas  ------------------
	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @mrecommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @mrecommend

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


    declare @startRun datetime
    declare @endRun datetime
    declare @duration INT
    set @startRun = getdate()

    --NOT allow masters under KH, KM, KR to create agents
    --Requested by wan 17-Jan-2007
    --NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
    --20081218_By_AhWan: KER - 1238537
    --20090112_Wan: unblock KM 194354
    --20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
    if exists (SELECT 1 FROM custinfo WITH(NOLOCK) WHERE custid = @mrecommend and srecommend  = 726582)
    BEGIN	
	    SELECT @ErrMsg = case @Language 
							    when 'E' then 'Sorry, cannot create agent.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40013,@Language)
						    END,
		    @ErrCode = 100
	    return
    END

    --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @mrecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    if @ErrCode <>0		return 

    declare @ErrType VARCHAR(4000)
    declare 
	    @transcode bigint, @currency INT, @pwdexpiry datetime,	
	    @Credit_AllOtherAgent MONEY, @Credit_AllMember MONEY, @Credit_MAg MONEY,
	    @srecommend INT,	 
	    @matchlimit SMALLMONEY,
	    @TransferOption_dec TINYINT,
	    --@Msuspended BIT,
	    @UplineClosed BIT,
	    @DisableOutright BIT,
	    @DoubleCommLosing BIT,
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@autosuspend3 BIT,
		@suspended BIT = 0
		
    declare
	    @max_mapositiontaking_1 SMALLMONEY,
	    @max_mapositiontaking_2 SMALLMONEY,
	    @max_mapositiontaking_3 SMALLMONEY,
	    @max_mapositiontaking_4 SMALLMONEY,
	    @max_mapositiontaking_5 SMALLMONEY,
	    @max_mapositiontaking_6 SMALLMONEY,
	    @max_mapositiontaking_7 SMALLMONEY,
	    @max_mapositiontaking_8 SMALLMONEY,
	    @max_mapositiontaking_9 SMALLMONEY,
	    @max_mapositiontaking_10 SMALLMONEY,
	    @max_v2mapositiontaking_10 SMALLMONEY,
	    @max_v3mapositiontaking_10 SMALLMONEY,
	    @max_v5mapositiontaking_10 SMALLMONEY,
	    @max_v8mapositiontaking_10 SMALLMONEY,
	    @max_v10mapositiontaking_10 SMALLMONEY,
	    @max_v11mapositiontaking_10 SMALLMONEY,
	    @max_v99mapositiontaking_10 SMALLMONEY,
	    @max_mapositiontaking_9999 SMALLMONEY,
    	
	    @max_malivepositiontaking_1 SMALLMONEY,
	    @max_malivepositiontaking_3 SMALLMONEY,
	    @max_malivepositiontaking_7 SMALLMONEY,
	    @max_malivepositiontaking_8 SMALLMONEY,
    	
	    @max_v2mapositiontaking_1 SMALLMONEY,
	    @max_v2mapositiontaking_2 SMALLMONEY,
	    @max_v2mapositiontaking_3 SMALLMONEY,
	    @max_v2mapositiontaking_7 SMALLMONEY,
	    @max_v2mapositiontaking_8 SMALLMONEY,
	    @max_v2mapositiontaking_20 SMALLMONEY,
	    @max_v2mapositiontaking_9999 SMALLMONEY,

	    @max_v3mapositiontaking_1 SMALLMONEY,
	    @max_v3mapositiontaking_2 SMALLMONEY,
	    @max_v3mapositiontaking_3 SMALLMONEY,
	    @max_v3mapositiontaking_20 SMALLMONEY,

	    @max_v5mapositiontaking_1 SMALLMONEY,
	    @max_v5mapositiontaking_2 SMALLMONEY,
	    @max_v5mapositiontaking_3 SMALLMONEY,
	    @max_v5mapositiontaking_20 SMALLMONEY,
	    @max_v5mapositiontaking_9999 SMALLMONEY,

	    @max_v8mapositiontaking_1 SMALLMONEY,
	    @max_v8mapositiontaking_3 SMALLMONEY,
	    @max_v8mapositiontaking_20 SMALLMONEY,

	    @max_v10mapositiontaking_1 SMALLMONEY,
	    @max_v10mapositiontaking_2 SMALLMONEY,
	    @max_v10mapositiontaking_3 SMALLMONEY,
	    @max_v10mapositiontaking_20 SMALLMONEY,

	    @max_v11mapositiontaking_1 SMALLMONEY,
	    @max_v11mapositiontaking_20 SMALLMONEY,

	    @max_v99mapositiontaking_1 SMALLMONEY,
	    @max_v99mapositiontaking_2 SMALLMONEY,
	    @max_v99mapositiontaking_3 SMALLMONEY,
	    @max_v99mapositiontaking_20 SMALLMONEY,
		@max_v99mapositiontaking_9999 SMALLMONEY,

	    -- mix parlay of mixed sports
	    @max_v99mapositiontaking_9 SMALLMONEY,
	   
	    --Auto Master PT
	    @isauto_mpositiontaking_1 BIT,
	    @isauto_mpositiontaking_2 BIT,
	    @isauto_mpositiontaking_3 BIT,
	    @isauto_mpositiontaking_4 BIT,
	    @isauto_mpositiontaking_5 BIT,
	    @isauto_mpositiontaking_6 BIT,
	    @isauto_mpositiontaking_7 BIT,
	    @isauto_mpositiontaking_8 BIT,
	    @isauto_mpositiontaking_9 BIT,
	    @isauto_mpositiontaking_10 BIT,
	    @isauto_v2mpositiontaking_10 BIT,
	    @isauto_v3mpositiontaking_10 BIT,
	    @isauto_v5mpositiontaking_10 BIT,
	    @isauto_v8mpositiontaking_10 BIT,
	    @isauto_v10mpositiontaking_10 BIT,
	    @isauto_v11mpositiontaking_10 BIT,
	    @isauto_v99mpositiontaking_10 BIT,
	    @isauto_mpositiontaking_9999 BIT,
    	
	    @isauto_mlivepositiontaking_1 BIT,
	    @isauto_mlivepositiontaking_3 BIT,
	    @isauto_mlivepositiontaking_7 BIT,
	    @isauto_mlivepositiontaking_8 BIT,
    	
	    @isauto_v2mpositiontaking_1 BIT,
	    @isauto_v2mpositiontaking_2 BIT,
	    @isauto_v2mpositiontaking_3 BIT,
	    @isauto_v2mpositiontaking_7 BIT,
	    @isauto_v2mpositiontaking_8 BIT,
	    @isauto_v2mpositiontaking_20 BIT,
	    @isauto_v2mpositiontaking_9999 BIT,
    	
	    @isauto_v3mpositiontaking_1 BIT,
	    @isauto_v3mpositiontaking_2 BIT,
	    @isauto_v3mpositiontaking_3 BIT,	
	    @isauto_v3mpositiontaking_20 BIT,
    	
	    @isauto_v5mpositiontaking_1 BIT,
	    @isauto_v5mpositiontaking_2 BIT,
	    @isauto_v5mpositiontaking_3 BIT,	
	    @isauto_v5mpositiontaking_20 BIT,
	    @isauto_v5mpositiontaking_9999 BIT,	
    	
	    @isauto_v8mpositiontaking_1 BIT,	
	    @isauto_v8mpositiontaking_3 BIT,	
	    @isauto_v8mpositiontaking_20 BIT,
    	
	    @isauto_v10mpositiontaking_1 BIT,
	    @isauto_v10mpositiontaking_2 BIT,
	    @isauto_v10mpositiontaking_3 BIT,	
	    @isauto_v10mpositiontaking_20 BIT,
    	
	    @isauto_v11mpositiontaking_1 BIT,	
	    @isauto_v11mpositiontaking_20 BIT,

	    @isauto_v99mpositiontaking_1 BIT,
	    @isauto_v99mpositiontaking_2 BIT,
	    @isauto_v99mpositiontaking_3 BIT,	
	    @isauto_v99mpositiontaking_20 BIT,
		@isauto_v99mpositiontaking_9999 BIT,

	    --- mix parlay of mixed sports
	    @isauto_v99mpositiontaking_9 BIT,	 	   
		
		@DisableSuperLive BIT = 0,
		@DangerMaster TINYINT = 0,
		@DangerMaster2 TINYINT = 0,
		@DangerMaster3 TINYINT = 0,
		@DangerMaster4 TINYINT = 0,
		@DangerMaster5 TINYINT = 0
        
    SELECT @currency = currency
         --, @Msuspended = reject
         , @UplineClosed = cs.closed

         , @Credit_MAg = isnull(credit, 0)
         , @srecommend = srecommend
         , @matchlimit = matchlimit
         , @DisableOutright = DisableOutright
     
         , @DoubleCommLosing = DoubleCommLosing
 
         , @EnableVR = ISNULL(virtualmultiplier,1)
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
		 , @autosuspend3 = ISNULL(autosuspend3, 0)
       
		 , @DisableSuperLive = DisableSuperLive
		 , @DangerMaster = Danger
		 , @DangerMaster2 = Danger2
		 , @DangerMaster3 = Danger3
		 , @DangerMaster4 = Danger4
		 , @DangerMaster5 = Danger5
     FROM CustInfo ci WITH(NOLOCK) 
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs
     WHERE CustID = @mrecommend

	--Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @mrecommend)		
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	END	

    SELECT @ErrCode = 0
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    declare @IsValid BIT
	-- MyanmarOdds
	-- Reset discount value in case its value > upline
	
	DECLARE @IsMyanmarOdds BIT = 0
	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@mrecommend)
	
	IF @IsMyanmarOdds = 1
	BEGIN
		SELECT @discountMyanmarOdds = CASE 
											WHEN @discountMyanmarOdds > commRate THEN commRate
											ELSE @discountMyanmarOdds  
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @mrecommend
			AND sporttype = 1   
			AND bettype = 1  
	   SELECT @groupb = 0, @groupc = 0, @groupd = 0		
	END
	
	DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0, @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.mrecommend = @mrecommend
									AND c.roleid = 2
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			Select	@ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056		
			return
		END
	END
    EXEC dbo.Acc_CustomerInsMember_MAg_CheckParam
		@custid = @custid OUTPUT,
	    @discountcs=@discountcs,
	    @discount1x2 = @discount1x2, --1x2	   
	    @groupa=@groupa,
	    @groupb=@groupb,
	    @groupc=@groupc,
	    @groupd=@groupd,
		
	    @credit=@credit,
	    @maxcredit = @maxcredit,
	    @mrecommend=@mrecommend,
    	
	    @apositiontaking_1=@apositiontaking_1,
	    @apositiontaking_2=@apositiontaking_2,
	    @apositiontaking_3=@apositiontaking_3,
	    @apositiontaking_4=@apositiontaking_4,
	    @apositiontaking_5=@apositiontaking_5,
	    @apositiontaking_6=@apositiontaking_6,
	    @apositiontaking_7=@apositiontaking_7,
	    @apositiontaking_8=@apositiontaking_8,
	    @apositiontaking_9=@apositiontaking_9,
	    @apositiontaking_10=@apositiontaking_10,
	    @v2apositiontaking_10=@v2apositiontaking_10,
	    @v3apositiontaking_10=@v3apositiontaking_10,
	    @v5apositiontaking_10=@v5apositiontaking_10,
	    @v8apositiontaking_10=@v8apositiontaking_10,
	    @v10apositiontaking_10=@v10apositiontaking_10,
	    @v11apositiontaking_10=@v11apositiontaking_10,
	    @v99apositiontaking_10=@v99apositiontaking_10,
	    @apositiontaking_9999=@apositiontaking_9999,
    	
	    @mpositiontaking_1=@mpositiontaking_1,
	    @mpositiontaking_2=@mpositiontaking_2,
	    @mpositiontaking_3=@mpositiontaking_3,
	    @mpositiontaking_4=@mpositiontaking_4,
	    @mpositiontaking_5=@mpositiontaking_5,
	    @mpositiontaking_6=@mpositiontaking_6,
	    @mpositiontaking_7=@mpositiontaking_7,
	    @mpositiontaking_8=@mpositiontaking_8,
	    @mpositiontaking_9=@mpositiontaking_9,
	    @mpositiontaking_10=@mpositiontaking_10,
	    @v2mpositiontaking_10=@v2mpositiontaking_10,
	    @v3mpositiontaking_10=@v3mpositiontaking_10,
	    @v5mpositiontaking_10=@v5mpositiontaking_10,
	    @v8mpositiontaking_10=@v8mpositiontaking_10,
	    @v10mpositiontaking_10=@v10mpositiontaking_10,
	    @v11mpositiontaking_10=@v11mpositiontaking_10,
	    @v99mpositiontaking_10=@v99mpositiontaking_10,
	    @mpositiontaking_9999=@mpositiontaking_9999,
    	
	    @alivepositiontaking_1=@alivepositiontaking_1,
	    @alivepositiontaking_3=@alivepositiontaking_3,
	    @alivepositiontaking_7=@alivepositiontaking_7,
	    @alivepositiontaking_8=@alivepositiontaking_8,
    	
	    @mlivepositiontaking_1=@mlivepositiontaking_1,
	    @mlivepositiontaking_3=@mlivepositiontaking_3,
	    @mlivepositiontaking_7=@mlivepositiontaking_7,
	    @mlivepositiontaking_8=@mlivepositiontaking_8,
    	
	    @v2apositiontaking_1=@v2apositiontaking_1,
	    @v2apositiontaking_2=@v2apositiontaking_2,
	    @v2apositiontaking_3=@v2apositiontaking_3,
	    @v2apositiontaking_7=@v2apositiontaking_7,
	    @v2apositiontaking_8=@v2apositiontaking_8,
   
	    @v2apositiontaking_20=@v2apositiontaking_20,
	    @v2apositiontaking_9999=@v2apositiontaking_9999,
    	
	    @v3apositiontaking_1=@v3apositiontaking_1,
	    @v3apositiontaking_2=@v3apositiontaking_2,
	    @v3apositiontaking_3=@v3apositiontaking_3,
	    @v3apositiontaking_20=@v3apositiontaking_20,

	    @v5apositiontaking_1=@v5apositiontaking_1,
	    @v5apositiontaking_2=@v5apositiontaking_2,
	    @v5apositiontaking_3=@v5apositiontaking_3,
	    @v5apositiontaking_20=@v5apositiontaking_20,
	    @v5apositiontaking_9999=@v5apositiontaking_9999,

	    @v8apositiontaking_1=@v8apositiontaking_1,
	    @v8apositiontaking_3=@v8apositiontaking_3,
	    @v8apositiontaking_20=@v8apositiontaking_20,

	    @v10apositiontaking_1=@v10apositiontaking_1,
	    @v10apositiontaking_2=@v10apositiontaking_2,
	    @v10apositiontaking_3=@v10apositiontaking_3,
	    @v10apositiontaking_20=@v10apositiontaking_20,

	    @v11apositiontaking_1=@v11apositiontaking_1,
	    @v11apositiontaking_20=@v11apositiontaking_20,

	    @v99apositiontaking_1=@v99apositiontaking_1,
	    @v99apositiontaking_2=@v99apositiontaking_2,
	    @v99apositiontaking_3=@v99apositiontaking_3,
	    @v99apositiontaking_20=@v99apositiontaking_20,
		@v99apositiontaking_9999=@v99apositiontaking_9999,
    	
	    -- mix parlay of mixed sports
	    @v99apositiontaking_9 = @v99apositiontaking_9,	  	    
    	
	    @v2mpositiontaking_1=@v2mpositiontaking_1,
	    @v2mpositiontaking_2=@v2mpositiontaking_2,
	    @v2mpositiontaking_3=@v2mpositiontaking_3,
	    @v2mpositiontaking_7=@v2mpositiontaking_7,
	    @v2mpositiontaking_8=@v2mpositiontaking_8,
   
	    @v2mpositiontaking_20=@v2mpositiontaking_20,
	    @v2mpositiontaking_9999=@v2mpositiontaking_9999,
    	
	    @v3mpositiontaking_1=@v3mpositiontaking_1,
	    @v3mpositiontaking_2=@v3mpositiontaking_2,
	    @v3mpositiontaking_3=@v3mpositiontaking_3,
	    @v3mpositiontaking_20=@v3mpositiontaking_20,

	    @v5mpositiontaking_1=@v5mpositiontaking_1,
	    @v5mpositiontaking_2=@v5mpositiontaking_2,
	    @v5mpositiontaking_3=@v5mpositiontaking_3,
	    @v5mpositiontaking_20=@v5mpositiontaking_20,
	    @v5mpositiontaking_9999=@v5mpositiontaking_9999,

	    @v8mpositiontaking_1=@v8mpositiontaking_1,
	    @v8mpositiontaking_3=@v8mpositiontaking_3,
	    @v8mpositiontaking_20=@v8mpositiontaking_20,

	    @v10mpositiontaking_1=@v10mpositiontaking_1,
	    @v10mpositiontaking_2=@v10mpositiontaking_2,
	    @v10mpositiontaking_3=@v10mpositiontaking_3,
	    @v10mpositiontaking_20=@v10mpositiontaking_20,

	    @v11mpositiontaking_1=@v11mpositiontaking_1,
	    @v11mpositiontaking_20=@v11mpositiontaking_20,

	    @v99mpositiontaking_1=@v99mpositiontaking_1,
	    @v99mpositiontaking_2=@v99mpositiontaking_2,
	    @v99mpositiontaking_3=@v99mpositiontaking_3,
	    @v99mpositiontaking_20=@v99mpositiontaking_20,
		@v99mpositiontaking_9999=@v99mpositiontaking_9999,

	    -- mix parlay of mixed sports
	    @v99mpositiontaking_9=@v99mpositiontaking_9,
	  	    
	    --Auto Master PT
	    @auto_mpositiontaking_1 = @auto_mpositiontaking_1,
	    @auto_mpositiontaking_2 = @auto_mpositiontaking_2,
	    @auto_mpositiontaking_3 = @auto_mpositiontaking_3,
	    @auto_mpositiontaking_4 = @auto_mpositiontaking_4,
	    @auto_mpositiontaking_5 = @auto_mpositiontaking_5,
	    @auto_mpositiontaking_6 = @auto_mpositiontaking_6,
	    @auto_mpositiontaking_7 = @auto_mpositiontaking_7,
	    @auto_mpositiontaking_8 = @auto_mpositiontaking_8,
	    @auto_mpositiontaking_9 = @auto_mpositiontaking_9,
	    @auto_mpositiontaking_10 = @auto_mpositiontaking_10,
	    @auto_v2mpositiontaking_10 = @auto_v2mpositiontaking_10,
	    @auto_v3mpositiontaking_10 = @auto_v3mpositiontaking_10,
	    @auto_v5mpositiontaking_10 = @auto_v5mpositiontaking_10,
	    @auto_v8mpositiontaking_10 = @auto_v8mpositiontaking_10,
	    @auto_v10mpositiontaking_10 = @auto_v10mpositiontaking_10,
	    @auto_v11mpositiontaking_10 = @auto_v11mpositiontaking_10,
	    @auto_v99mpositiontaking_10 = @auto_v99mpositiontaking_10,
	    @auto_mpositiontaking_9999 = @auto_mpositiontaking_9999,
	    @auto_mlivepositiontaking_1 = @auto_mlivepositiontaking_1,
	    @auto_mlivepositiontaking_3 = @auto_mlivepositiontaking_3,
	    @auto_mlivepositiontaking_7 = @auto_mlivepositiontaking_7,
	    @auto_mlivepositiontaking_8 = @auto_mlivepositiontaking_8,
    	
	    @auto_v2mpositiontaking_1 = @auto_v2mpositiontaking_1,
	    @auto_v2mpositiontaking_2 = @auto_v2mpositiontaking_2,
	    @auto_v2mpositiontaking_3 = @auto_v2mpositiontaking_3,
	    @auto_v2mpositiontaking_7 = @auto_v2mpositiontaking_7,
	    @auto_v2mpositiontaking_8 = @auto_v2mpositiontaking_8,
    
	    @auto_v2mpositiontaking_20 = @auto_v2mpositiontaking_20,
	    @auto_v2mpositiontaking_9999 = @auto_v2mpositiontaking_9999,
    	
	    @auto_v3mpositiontaking_1 = @auto_v3mpositiontaking_1,
	    @auto_v3mpositiontaking_2 = @auto_v3mpositiontaking_2,
	    @auto_v3mpositiontaking_3 = @auto_v3mpositiontaking_3,
	    @auto_v3mpositiontaking_20 = @auto_v3mpositiontaking_20,
    	
	    @auto_v5mpositiontaking_1 = @auto_v5mpositiontaking_1,
	    @auto_v5mpositiontaking_2 = @auto_v5mpositiontaking_2,
	    @auto_v5mpositiontaking_3 = @auto_v5mpositiontaking_3,
	    @auto_v5mpositiontaking_20 = @auto_v5mpositiontaking_20,
	    @auto_v5mpositiontaking_9999 = @auto_v5mpositiontaking_9999,
    	
	    @auto_v8mpositiontaking_1 = @auto_v8mpositiontaking_1,
	    @auto_v8mpositiontaking_3 = @auto_v8mpositiontaking_3,
	    @auto_v8mpositiontaking_20 = @auto_v8mpositiontaking_20,
    	
	    @auto_v10mpositiontaking_1 = @auto_v10mpositiontaking_1,
	    @auto_v10mpositiontaking_2 = @auto_v10mpositiontaking_2,
	    @auto_v10mpositiontaking_3 = @auto_v10mpositiontaking_3,
	    @auto_v10mpositiontaking_20 = @auto_v10mpositiontaking_20,
    	
	    @auto_v11mpositiontaking_1 = @auto_v11mpositiontaking_1,
	    @auto_v11mpositiontaking_20 = @auto_v11mpositiontaking_20,
    	
	    @auto_v99mpositiontaking_1 = @auto_v99mpositiontaking_1,
	    @auto_v99mpositiontaking_2 = @auto_v99mpositiontaking_2,
	    @auto_v99mpositiontaking_3 = @auto_v99mpositiontaking_3,
	    @auto_v99mpositiontaking_20 = @auto_v99mpositiontaking_20,
		@auto_v99mpositiontaking_9999 = @auto_v99mpositiontaking_9999,
    	
	    -- mix parlay of mixed sports
	    @auto_v99mpositiontaking_9 = @auto_v99mpositiontaking_9,
	 	   
    	-- MyanmarOdds
    	@discountMyanmarOdds = @discountMyanmarOdds,
    	
	    @isvalid=@isvalid OUTPUT,
	    @errmsg=@ErrMsg OUTPUT,
	    @errcode=@errcode OUTPUT,
	    @language=@language,
		@SystemID = @SystemID,
		@creator = @creator

    if @IsValid = 0
    BEGIN
	    return
    END

	DECLARE @BetSettingXML VARCHAR(8000) = ''

	EXEC Acc_CustomerInsMember_CheckBetSetting
		 @custid			= @mrecommend
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
    SELECT @username = rtrim(ltrim(@username))

    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = case @Language 
							    when 'E' then 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END,
		    @ErrCode = 1101		
	    RETURN
    END
    SELECT @pwdexpiry = dateadd(dd, 30, getdate())

    --m3
    SELECT @max_mapositiontaking_1 =mpositiontaking, @max_malivepositiontaking_1 =mlivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=1
    SELECT @max_mapositiontaking_3 =mpositiontaking, @max_malivepositiontaking_3 =mlivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=1
    SELECT @max_mapositiontaking_7 =mpositiontaking, @max_malivepositiontaking_7 =mlivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=7 and sporttype=1
    SELECT @max_mapositiontaking_8 =mpositiontaking, @max_malivepositiontaking_8 =mlivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=8 and sporttype=1
    SELECT @max_mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=1
    SELECT @max_mapositiontaking_4 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=4 and sporttype=1
    SELECT @max_mapositiontaking_5 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=5 and sporttype=1
    SELECT @max_mapositiontaking_6 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=6 and sporttype=1
    SELECT @max_mapositiontaking_9 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9 and sporttype=1
    SELECT @max_mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=1
    SELECT @max_v2mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=2
    SELECT @max_v3mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=3
    SELECT @max_v5mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=5
    SELECT @max_v8mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=8
    SELECT @max_v10mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=10
    SELECT @max_v11mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=11
    SELECT @max_v99mapositiontaking_10 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=10 and sporttype=99
    SELECT @max_mapositiontaking_9999 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9999 and sporttype=1

    SELECT @max_v2mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=2
    SELECT @max_v2mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=2
    SELECT @max_v2mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=2
    SELECT @max_v2mapositiontaking_7 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=7 and sporttype=2
    SELECT @max_v2mapositiontaking_8 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=8 and sporttype=2
    
    SELECT @max_v2mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=2
    SELECT @max_v2mapositiontaking_9999 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9999 and sporttype=2

    SELECT @max_v3mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=3
    SELECT @max_v3mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=3
    SELECT @max_v3mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=3
    SELECT @max_v3mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=3

    SELECT @max_v5mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=5
    SELECT @max_v5mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=5
    SELECT @max_v5mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=5
    SELECT @max_v5mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=5
    SELECT @max_v5mapositiontaking_9999 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9999 and sporttype=5

    SELECT @max_v8mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=8
    SELECT @max_v8mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=8
    SELECT @max_v8mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=8

    SELECT @max_v10mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=10
    SELECT @max_v10mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=10
    SELECT @max_v10mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=10
    SELECT @max_v10mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=10

    SELECT @max_v11mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=11
    SELECT @max_v11mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=11

    SELECT @max_v99mapositiontaking_1 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=1 and sporttype=99
    SELECT @max_v99mapositiontaking_2 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=2 and sporttype=99
    SELECT @max_v99mapositiontaking_3 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=3 and sporttype=99
    SELECT @max_v99mapositiontaking_20 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=20 and sporttype=99
	SELECT @max_v99mapositiontaking_9999 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9999 and sporttype=99

    -- mix parlay of mixed sports
    SELECT @max_v99mapositiontaking_9 =mpositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=9 and sporttype=99
    
    --check m2+a2<=m3
    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + sports.Name + '-' + bettype.name + '-Max: '+ dbo.f_FomatNumericToChar(max_mapositiontaking)
	    + CASE WHEN b.sporttype in (1) and b.bettype in (1,3,7,8) then '--MaxLive: '+ dbo.f_FomatNumericToChar(max_malivepositiontaking) else '' END + '<br>'
    FROM #tmp_Sports sports inner join
    (
			    SELECT 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @max_mapositiontaking_1 as max_mapositiontaking,  @max_malivepositiontaking_1 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @max_mapositiontaking_3 as max_mapositiontaking,  @max_malivepositiontaking_3 as max_malivepositiontaking
	    UNION ALL 	SELECT 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @max_mapositiontaking_7 as max_mapositiontaking,  @max_malivepositiontaking_7 as max_malivepositiontaking
	    UNION ALL 	SELECT 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_mapositiontaking_8 as max_mapositiontaking,  @max_malivepositiontaking_8 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_4 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_5 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_6 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_9 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v11mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_9999 as max_mapositiontaking,  0 as max_malivepositiontaking

	    UNION ALL 	SELECT 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
    

	    UNION ALL 	SELECT 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 9999 as bettype, 2 as sporttype, @v2apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_9999 as max_mapositiontaking,  0 as max_malivepositiontaking
	    

	    UNION ALL 	SELECT 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
    	
	    UNION ALL 	SELECT 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_9999 as max_mapositiontaking,  0 as max_malivepositiontaking
    	
	    UNION ALL 	SELECT 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
    	
	    UNION ALL 	SELECT 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
    	
	    UNION ALL 	SELECT 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v11mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v11mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking

	    UNION ALL 	SELECT 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	    UNION ALL 	SELECT 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
		UNION ALL 	SELECT 9999 as bettype, 99 as sporttype, @v99apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_9999 as max_mapositiontaking,  0 as max_malivepositiontaking
    	
	    -- mix parlay of mixed sports
	    UNION ALL 	SELECT 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_9 as max_mapositiontaking,  0 as max_malivepositiontaking
		    
	    UNION ALL 	SELECT 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_mapositiontaking_8 as max_mapositiontaking,  @max_malivepositiontaking_8 as max_malivepositiontaking
	    UNION ALL 	SELECT 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking		  
	    ) as b on sports.ID = b.sporttype
	    inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	    WHERE (apositiontaking + mpositiontaking>max_mapositiontaking)
		    or (alivepositiontaking + mlivepositiontaking>max_malivepositiontaking)

    if @ErrType <>''
    BEGIN
	    SELECT @ErrMsg = case @Language 
							    when 'E' then 'Wrong position taking (max for master set by super).<br>'+@ErrType
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
						    END
	    SELECT @ErrCode = 102
	    return 
    END
    
    --Auto Master PT
    SELECT @auto_mpositiontaking_1=  CASE WHEN @auto_mpositiontaking_1>@max_mapositiontaking_1 then @max_mapositiontaking_1 else @auto_mpositiontaking_1 END
    SELECT @auto_mpositiontaking_2=  CASE WHEN @auto_mpositiontaking_2>@max_mapositiontaking_2 then @max_mapositiontaking_2 else @auto_mpositiontaking_2 END
    SELECT @auto_mpositiontaking_3=  CASE WHEN @auto_mpositiontaking_3>@max_mapositiontaking_3 then @max_mapositiontaking_3 else @auto_mpositiontaking_3 END
    SELECT @auto_mpositiontaking_4=  CASE WHEN @auto_mpositiontaking_4>@max_mapositiontaking_4 then @max_mapositiontaking_4 else @auto_mpositiontaking_4 END
    SELECT @auto_mpositiontaking_5=  CASE WHEN @auto_mpositiontaking_5>@max_mapositiontaking_5 then @max_mapositiontaking_5 else @auto_mpositiontaking_5 END
    SELECT @auto_mpositiontaking_6=  CASE WHEN @auto_mpositiontaking_6>@max_mapositiontaking_6 then @max_mapositiontaking_6 else @auto_mpositiontaking_6 END
    SELECT @auto_mpositiontaking_7=  CASE WHEN @auto_mpositiontaking_7>@max_mapositiontaking_7 then @max_mapositiontaking_7 else @auto_mpositiontaking_7 END
    SELECT @auto_mpositiontaking_8= CASE WHEN @auto_mpositiontaking_8>@max_mapositiontaking_8 then @max_mapositiontaking_8 else @auto_mpositiontaking_8 END
    SELECT @auto_mpositiontaking_9=  CASE WHEN @auto_mpositiontaking_9>@max_mapositiontaking_9 then @max_mapositiontaking_9 else @auto_mpositiontaking_9 END
    SELECT @auto_mpositiontaking_10=  CASE WHEN @auto_mpositiontaking_10>@max_mapositiontaking_10 then @max_mapositiontaking_10 else @auto_mpositiontaking_10 END
    SELECT @auto_v2mpositiontaking_10=  CASE WHEN @auto_v2mpositiontaking_10>@max_v2mapositiontaking_10 then @max_v2mapositiontaking_10 else @auto_v2mpositiontaking_10 END
    SELECT @auto_v3mpositiontaking_10=  CASE WHEN @auto_v3mpositiontaking_10>@max_v3mapositiontaking_10 then @max_v3mapositiontaking_10 else @auto_v3mpositiontaking_10 END
    SELECT @auto_v5mpositiontaking_10=  CASE WHEN @auto_v5mpositiontaking_10>@max_v5mapositiontaking_10 then @max_v5mapositiontaking_10 else @auto_v5mpositiontaking_10 END
    SELECT @auto_v8mpositiontaking_10=  CASE WHEN @auto_v8mpositiontaking_10>@max_v8mapositiontaking_10 then @max_v8mapositiontaking_10 else @auto_v8mpositiontaking_10 END
    SELECT @auto_v10mpositiontaking_10=  CASE WHEN @auto_v10mpositiontaking_10>@max_v10mapositiontaking_10 then @max_v10mapositiontaking_10 else @auto_v10mpositiontaking_10 END
    SELECT @auto_v11mpositiontaking_10=  CASE WHEN @auto_v11mpositiontaking_10>@max_v11mapositiontaking_10 then @max_v11mapositiontaking_10 else @auto_v11mpositiontaking_10 END
    SELECT @auto_v99mpositiontaking_10=  CASE WHEN @auto_v99mpositiontaking_10>@max_v99mapositiontaking_10 then @max_v99mapositiontaking_10 else @auto_v99mpositiontaking_10 END
    SELECT @auto_mpositiontaking_9999=  CASE WHEN @auto_mpositiontaking_9999>@max_mapositiontaking_9999 then @max_mapositiontaking_9999 else @auto_mpositiontaking_9999 END

    SELECT @auto_mlivepositiontaking_1=  CASE WHEN @auto_mlivepositiontaking_1>@max_malivepositiontaking_1 then @max_malivepositiontaking_1 else @auto_mlivepositiontaking_1 END
    SELECT @auto_mlivepositiontaking_3=  CASE WHEN @auto_mlivepositiontaking_3>@max_malivepositiontaking_3 then @max_malivepositiontaking_3 else @auto_mlivepositiontaking_3 END
    SELECT @auto_mlivepositiontaking_7=  CASE WHEN @auto_mlivepositiontaking_7>@max_malivepositiontaking_7 then @max_malivepositiontaking_7 else @auto_mlivepositiontaking_7 END
    SELECT @auto_mlivepositiontaking_8=  CASE WHEN @auto_mlivepositiontaking_8>@max_malivepositiontaking_8 then @max_malivepositiontaking_8 else @auto_mlivepositiontaking_8 END

    SELECT @auto_v2mpositiontaking_1=  CASE WHEN @auto_v2mpositiontaking_1>@max_v2mapositiontaking_1 then @max_v2mapositiontaking_1 else @auto_v2mpositiontaking_1 END
    SELECT @auto_v2mpositiontaking_2=  CASE WHEN @auto_v2mpositiontaking_2>@max_v2mapositiontaking_2 then @max_v2mapositiontaking_2 else @auto_v2mpositiontaking_2 END
    SELECT @auto_v2mpositiontaking_3=  CASE WHEN @auto_v2mpositiontaking_3>@max_v2mapositiontaking_3 then @max_v2mapositiontaking_3 else @auto_v2mpositiontaking_3 END
    SELECT @auto_v2mpositiontaking_7=  CASE WHEN @auto_v2mpositiontaking_7>@max_v2mapositiontaking_7 then @max_v2mapositiontaking_7 else @auto_v2mpositiontaking_7 END
    SELECT @auto_v2mpositiontaking_8=  CASE WHEN @auto_v2mpositiontaking_8>@max_v2mapositiontaking_8 then @max_v2mapositiontaking_8 else @auto_v2mpositiontaking_8 END
    
    SELECT @auto_v2mpositiontaking_20=  CASE WHEN @auto_v2mpositiontaking_20>@max_v2mapositiontaking_20 then @max_v2mapositiontaking_20 else @auto_v2mpositiontaking_20 END
    SELECT @auto_v2mpositiontaking_9999=  CASE WHEN @auto_v2mpositiontaking_9999>@max_v2mapositiontaking_9999 then @max_v2mapositiontaking_9999 else @auto_v2mpositiontaking_9999 END

    SELECT @auto_v3mpositiontaking_1=  CASE WHEN @auto_v3mpositiontaking_1>@max_v3mapositiontaking_1 then @max_v3mapositiontaking_1 else @auto_v3mpositiontaking_1 END
    SELECT @auto_v3mpositiontaking_2=  CASE WHEN @auto_v3mpositiontaking_2>@max_v3mapositiontaking_2 then @max_v3mapositiontaking_2 else @auto_v3mpositiontaking_2 END
    SELECT @auto_v3mpositiontaking_3=  CASE WHEN @auto_v3mpositiontaking_3>@max_v3mapositiontaking_3 then @max_v3mapositiontaking_3 else @auto_v3mpositiontaking_3 END
    SELECT @auto_v3mpositiontaking_20=  CASE WHEN @auto_v3mpositiontaking_20>@max_v3mapositiontaking_20 then @max_v3mapositiontaking_20 else @auto_v3mpositiontaking_20 END

    SELECT @auto_v5mpositiontaking_1=  CASE WHEN @auto_v5mpositiontaking_1>@max_v5mapositiontaking_1 then @max_v5mapositiontaking_1 else @auto_v5mpositiontaking_1 END
    SELECT @auto_v5mpositiontaking_2=  CASE WHEN @auto_v5mpositiontaking_2>@max_v5mapositiontaking_2 then @max_v5mapositiontaking_2 else @auto_v5mpositiontaking_2 END
    SELECT @auto_v5mpositiontaking_3=  CASE WHEN @auto_v5mpositiontaking_3>@max_v5mapositiontaking_3 then @max_v5mapositiontaking_3 else @auto_v5mpositiontaking_3 END
    SELECT @auto_v5mpositiontaking_20=  CASE WHEN @auto_v5mpositiontaking_20>@max_v5mapositiontaking_20 then @max_v5mapositiontaking_20 else @auto_v5mpositiontaking_20 END
    SELECT @auto_v5mpositiontaking_9999=  CASE WHEN @auto_v5mpositiontaking_9999>@max_v5mapositiontaking_9999 then @max_v5mapositiontaking_9999 else @auto_v5mpositiontaking_9999 END

    SELECT @auto_v8mpositiontaking_1=  CASE WHEN @auto_v8mpositiontaking_1>@max_v8mapositiontaking_1 then @max_v8mapositiontaking_1 else @auto_v8mpositiontaking_1 END
    SELECT @auto_v8mpositiontaking_3=  CASE WHEN @auto_v8mpositiontaking_3>@max_v8mapositiontaking_3 then @max_v8mapositiontaking_3 else @auto_v8mpositiontaking_3 END
    SELECT @auto_v8mpositiontaking_20=  CASE WHEN @auto_v8mpositiontaking_20>@max_v8mapositiontaking_20 then @max_v8mapositiontaking_20 else @auto_v8mpositiontaking_20 END

    SELECT @auto_v10mpositiontaking_1=  CASE WHEN @auto_v10mpositiontaking_1>@max_v10mapositiontaking_1 then @max_v10mapositiontaking_1 else @auto_v10mpositiontaking_1 END
    SELECT @auto_v10mpositiontaking_2=  CASE WHEN @auto_v10mpositiontaking_2>@max_v10mapositiontaking_2 then @max_v10mapositiontaking_2 else @auto_v10mpositiontaking_2 END
    SELECT @auto_v10mpositiontaking_3=  CASE WHEN @auto_v10mpositiontaking_3>@max_v10mapositiontaking_3 then @max_v10mapositiontaking_3 else @auto_v10mpositiontaking_3 END
    SELECT @auto_v10mpositiontaking_20=  CASE WHEN @auto_v10mpositiontaking_20>@max_v10mapositiontaking_20 then @max_v10mapositiontaking_20 else @auto_v10mpositiontaking_20 END

    SELECT @auto_v11mpositiontaking_1=  CASE WHEN @auto_v11mpositiontaking_1>@max_v11mapositiontaking_1 then @max_v11mapositiontaking_1 else @auto_v11mpositiontaking_1 END
    SELECT @auto_v11mpositiontaking_20=  CASE WHEN @auto_v11mpositiontaking_20>@max_v11mapositiontaking_20 then @max_v11mapositiontaking_20 else @auto_v11mpositiontaking_20 END

    SELECT @auto_v99mpositiontaking_1=  CASE WHEN @auto_v99mpositiontaking_1>@max_v99mapositiontaking_1 then @max_v99mapositiontaking_1 else @auto_v99mpositiontaking_1 END
    SELECT @auto_v99mpositiontaking_2=  CASE WHEN @auto_v99mpositiontaking_2>@max_v99mapositiontaking_2 then @max_v99mapositiontaking_2 else @auto_v99mpositiontaking_2 END
    SELECT @auto_v99mpositiontaking_3=  CASE WHEN @auto_v99mpositiontaking_3>@max_v99mapositiontaking_3 then @max_v99mapositiontaking_3 else @auto_v99mpositiontaking_3 END
    SELECT @auto_v99mpositiontaking_20=  CASE WHEN @auto_v99mpositiontaking_20>@max_v99mapositiontaking_20 then @max_v99mapositiontaking_20 else @auto_v99mpositiontaking_20 END
	SELECT @auto_v99mpositiontaking_9999=  CASE WHEN @auto_v99mpositiontaking_9999>@max_v99mapositiontaking_9999 then @max_v99mapositiontaking_9999 else @auto_v99mpositiontaking_9999 END
    -- mix parlay of mixed sports
    SELECT @auto_v99mpositiontaking_9 =  CASE WHEN @auto_v99mpositiontaking_9>@max_v99mapositiontaking_9 then @max_v99mapositiontaking_9 else @auto_v99mpositiontaking_9 END   
    
    --Check valid commission for financial and HR
    SELECT 
	    @groupa = CASE WHEN @groupa>groupa then groupa else @groupa END,
	    @groupb = CASE WHEN @groupb>groupb then groupb else @groupb END,
	    @groupc = CASE WHEN @groupc>groupc then groupc else @groupc END,
	    @groupd = CASE WHEN @groupd>groupd then groupd else @groupd END
    FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and  bettype=1 and sporttype=1

    SELECT 
	    @discountcs = CASE WHEN @discountcs>adiscount then adiscount else @discountcs END
    FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=4 and sporttype=1

    --1x2 Commission
    SELECT 
	    @discount1x2 = CASE WHEN @discount1x2>adiscount then adiscount else @discount1x2 END
    FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend and bettype=5 and sporttype=1


    --Vinh@20080213: get transfer option FROM master
	DECLARE @IsInternal BIT
    select	@IsInternal = IsInternal,
		    @TransferOption_dec = TransferOption 
    FROM custmaster with (nolock) 
    WHERE CustID = @mrecommend

    SELECT @Credit_AllOtherAgent = isnull(sum(credit), 0) FROM custinfo as ci WITH(NOLOCK) WHERE mrecommend = @mrecommend and RoleID = 2

    if @Credit_AllOtherAgent + @Credit >@Credit_MAg
    BEGIN
	    SELECT @ErrMsg = case @Language 
						    when 'E' then 'Sorry, credit update is not successful, You have exceeded your master credit.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](70011,@Language)
					    END,
		    @ErrCode = 104
	    return
    END
    -- maxcredit 
    if (isnull(@maxcredit ,0) > @credit )
    BEGIN 
	    SELECT @ErrMsg = case @Language
		    when 'E' then 'Sorry, credit update is not successful, You have exceeded your agent credit.'  
            ELSE [dbo].[f_Get_MsgNamebyMsgID](70012,@Language)
         END,  
      @ErrCode = 116  
     return  
    END 

    --Auto Master PT

    select	@isauto_mpositiontaking_1 	= case when	@auto_mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_2 	= case when	@auto_mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_3 	= case when	@auto_mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_4 	= case when	@auto_mpositiontaking_4 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_5 	= case when	@auto_mpositiontaking_5 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_6 	= case when	@auto_mpositiontaking_6 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_7 	= case when	@auto_mpositiontaking_7 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_8 	= case when	@auto_mpositiontaking_8 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_9 	= case when	@auto_mpositiontaking_9 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_10 	= case when	@auto_mpositiontaking_10 	>0 then 1 else 0 END,	   
	    @isauto_v2mpositiontaking_10 	= case when	@auto_v2mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v3mpositiontaking_10 	= case when	@auto_v3mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v5mpositiontaking_10 	= case when	@auto_v5mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v8mpositiontaking_10 	= case when	@auto_v8mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v10mpositiontaking_10 	= case when	@auto_v10mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v11mpositiontaking_10 	= case when	@auto_v11mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_v99mpositiontaking_10 	= case when	@auto_v99mpositiontaking_10 	>0 then 1 else 0 END,
	    @isauto_mpositiontaking_9999 	= case when	@auto_mpositiontaking_9999 	>0 then 1 else 0 END,
	    @isauto_mlivepositiontaking_1 	= case when	@auto_mlivepositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_mlivepositiontaking_3 	= case when	@auto_mlivepositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_mlivepositiontaking_7 	= case when	@auto_mlivepositiontaking_7 	>0 then 1 else 0 END,
	    @isauto_mlivepositiontaking_8 	= case when	@auto_mlivepositiontaking_8 	>0 then 1 else 0 END,
    	
	    @isauto_v2mpositiontaking_1 	= case when	@auto_v2mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v2mpositiontaking_2 	= case when	@auto_v2mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_v2mpositiontaking_3 	= case when	@auto_v2mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v2mpositiontaking_7 	= case when	@auto_v2mpositiontaking_7 	>0 then 1 else 0 END,
	    @isauto_v2mpositiontaking_8 	= case when	@auto_v2mpositiontaking_8 	>0 then 1 else 0 END,

	    @isauto_v2mpositiontaking_20 	= case when	@auto_v2mpositiontaking_20	>0 then 1 else 0 END,
	    @isauto_v2mpositiontaking_9999 	= case when	@auto_v2mpositiontaking_9999	>0 then 1 else 0 END,
    	
	    @isauto_v3mpositiontaking_1 	= case when	@auto_v3mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v3mpositiontaking_2 	= case when	@auto_v3mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_v3mpositiontaking_3 	= case when	@auto_v3mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v3mpositiontaking_20 	= case when	@auto_v3mpositiontaking_20	>0 then 1 else 0 END,
    	
	    @isauto_v5mpositiontaking_1 	= case when	@auto_v5mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v5mpositiontaking_2 	= case when	@auto_v5mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_v5mpositiontaking_3 	= case when	@auto_v5mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v5mpositiontaking_20 	= case when	@auto_v5mpositiontaking_20	>0 then 1 else 0 END,
	    @isauto_v5mpositiontaking_9999 	= case when	@auto_v5mpositiontaking_9999 	>0 then 1 else 0 END,
    	
	    @isauto_v8mpositiontaking_1 	= case when	@auto_v8mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v8mpositiontaking_3 	= case when	@auto_v8mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v8mpositiontaking_20 	= case when	@auto_v8mpositiontaking_20	>0 then 1 else 0 END,
    	
	    @isauto_v10mpositiontaking_1 	= case when	@auto_v10mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v10mpositiontaking_2 	= case when	@auto_v10mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_v10mpositiontaking_3 	= case when	@auto_v10mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v10mpositiontaking_20 	= case when	@auto_v10mpositiontaking_20	>0 then 1 else 0 END,
    	
	    @isauto_v11mpositiontaking_1 	= case when	@auto_v11mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v11mpositiontaking_20 	= case when	@auto_v11mpositiontaking_20	>0 then 1 else 0 END,
    	
	    @isauto_v99mpositiontaking_1 	= case when	@auto_v99mpositiontaking_1 	>0 then 1 else 0 END,
	    @isauto_v99mpositiontaking_2 	= case when	@auto_v99mpositiontaking_2 	>0 then 1 else 0 END,
	    @isauto_v99mpositiontaking_3 	= case when	@auto_v99mpositiontaking_3 	>0 then 1 else 0 END,
	    @isauto_v99mpositiontaking_20 	= case when	@auto_v99mpositiontaking_20	>0 then 1 else 0 END,
		@isauto_v99mpositiontaking_9999 = case when	@auto_v99mpositiontaking_9999	>0 then 1 else 0 END,

	    @isauto_v99mpositiontaking_9 	= case when	@auto_v99mpositiontaking_9 	> 0 then 1 else 0 END 
	   
    --check suspended
    --if @Msuspended =1 
    --BEGIN
	   -- set @suspended =1 
    --END 

	
    --Insert general data 
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
	    @mrecommend = @mrecommend,
	    @recommend = 0,
	    @roleid = 2,
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
	    --@suspended = @suspended,
	    @closed=@UplineClosed,

	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,
		@autosuspend3 = @autosuspend3,

	    @DisableOutright = @DisableOutright,	
	    @matchlimit = @matchlimit,
	    @virtualmultiplier = @EnableVR,
	   
	    @IsInternal = @IsInternal,
		
    	@SystemID=@SystemID,
	    @credit = @credit,
	    @maxcredit = @maxcredit,
	
	    @DoubleCommLosing = @DoubleCommLosing,	 
		@DisableSuperLive = @DisableSuperLive,
		@Danger = @DangerMaster,
		@Danger2 = @DangerMaster2,
		@Danger3 = @DangerMaster3,
		@Danger4 = @DangerMaster4,
		@Danger5 = @DangerMaster5,
	 
	    @IP = @IP,
	    @TransferOption_dec = @TransferOption_dec,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    if @ErrCode <> 0
	    return

    EXEC dbo.Acc_CustomerInfo_Execrep_00
	    @custid = @custid,
		@srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @roleid = 2,
    	
	    @groupa = @groupa, 
	    @groupb = @groupb, 
	    @groupc = @groupc, 
	    @groupd = @groupd,
    	
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
    	
	    @apositiontaking_1 = @apositiontaking_1,
	    @apositiontaking_2 = @apositiontaking_2,
	    @apositiontaking_3 = @apositiontaking_3,
	    @apositiontaking_4 = @apositiontaking_4,
	    @apositiontaking_5 = @apositiontaking_5,
	    @apositiontaking_6 = @apositiontaking_6,
	    @apositiontaking_7 = @apositiontaking_7,
	    @apositiontaking_8 = @apositiontaking_8,
	    @apositiontaking_9 = @apositiontaking_9,
	    @apositiontaking_10 = @apositiontaking_10,
	    @v2apositiontaking_10 = @v2apositiontaking_10,
	    @v3apositiontaking_10 = @v3apositiontaking_10,
	    @v5apositiontaking_10 = @v5apositiontaking_10,
	    @v8apositiontaking_10 = @v8apositiontaking_10,
	    @v10apositiontaking_10 = @v10apositiontaking_10,
	    @v11apositiontaking_10 = @v11apositiontaking_10,
	    @v99apositiontaking_10 = @v99apositiontaking_10,
	    @apositiontaking_9999 = @apositiontaking_9999,
    	
	    @alivepositiontaking_1 = @alivepositiontaking_1,
	    @alivepositiontaking_3 = @alivepositiontaking_3,
	    @alivepositiontaking_7 = @alivepositiontaking_7,
	    @alivepositiontaking_8 = @alivepositiontaking_8,
    	
	    @v2apositiontaking_1 = @v2apositiontaking_1,
	    @v2apositiontaking_2 = @v2apositiontaking_2,
	    @v2apositiontaking_3 = @v2apositiontaking_3,
	    @v2apositiontaking_7 = @v2apositiontaking_7,
	    @v2apositiontaking_8 = @v2apositiontaking_8,
	
	    @v2apositiontaking_20 = @v2apositiontaking_20,
	    @v2apositiontaking_9999 = @v2apositiontaking_9999,

	    @v3apositiontaking_1 = @v3apositiontaking_1,
	    @v3apositiontaking_2 = @v3apositiontaking_2,
	    @v3apositiontaking_3 = @v3apositiontaking_3,
	    @v3apositiontaking_20 = @v3apositiontaking_20,

	    @v5apositiontaking_1 = @v5apositiontaking_1,
	    @v5apositiontaking_2 = @v5apositiontaking_2,
	    @v5apositiontaking_3 = @v5apositiontaking_3,
	    @v5apositiontaking_20 = @v5apositiontaking_20,
	    @v5apositiontaking_9999 = @v5apositiontaking_9999,

	    @v8apositiontaking_1 = @v8apositiontaking_1,
	    @v8apositiontaking_3 = @v8apositiontaking_3,
	    @v8apositiontaking_20 = @v8apositiontaking_20,

	    @v10apositiontaking_1 = @v10apositiontaking_1,
	    @v10apositiontaking_2 = @v10apositiontaking_2,
	    @v10apositiontaking_3 = @v10apositiontaking_3,
	    @v10apositiontaking_20 = @v10apositiontaking_20,

	    @v11apositiontaking_1 = @v11apositiontaking_1,
	    @v11apositiontaking_20 = @v11apositiontaking_20,

	    @v99apositiontaking_1 = @v99apositiontaking_1,
	    @v99apositiontaking_2 = @v99apositiontaking_2,
	    @v99apositiontaking_3 = @v99apositiontaking_3,
	    @v99apositiontaking_9 = @v99apositiontaking_9,
	    @v99apositiontaking_20 = @v99apositiontaking_20,
		@v99apositiontaking_9999 = @v99apositiontaking_9999,	  
    	
	    @auto_mpositiontaking_1 = @auto_mpositiontaking_1,
	    @auto_mpositiontaking_2 = @auto_mpositiontaking_2,
	    @auto_mpositiontaking_3 = @auto_mpositiontaking_3,
	    @auto_mpositiontaking_4 = @auto_mpositiontaking_4,
	    @auto_mpositiontaking_5 = @auto_mpositiontaking_5,
	    @auto_mpositiontaking_6 = @auto_mpositiontaking_6,
	    @auto_mpositiontaking_7 = @auto_mpositiontaking_7,
	    @auto_mpositiontaking_8 = @auto_mpositiontaking_8,
	    @auto_mpositiontaking_9 = @auto_mpositiontaking_9,
	    @auto_mpositiontaking_10 = @auto_mpositiontaking_10,
	    @auto_v2mpositiontaking_10 = @auto_v2mpositiontaking_10,
	    @auto_v3mpositiontaking_10 = @auto_v3mpositiontaking_10,
	    @auto_v5mpositiontaking_10 = @auto_v5mpositiontaking_10,
	    @auto_v8mpositiontaking_10 = @auto_v8mpositiontaking_10,
	    @auto_v10mpositiontaking_10 = @auto_v10mpositiontaking_10,
	    @auto_v11mpositiontaking_10 = @auto_v11mpositiontaking_10,
	    @auto_v99mpositiontaking_10 = @auto_v99mpositiontaking_10,
	    @auto_mpositiontaking_9999 = @auto_mpositiontaking_9999,
	    @auto_mlivepositiontaking_1 = @auto_mlivepositiontaking_1,
	    @auto_mlivepositiontaking_3 = @auto_mlivepositiontaking_3,
	    @auto_mlivepositiontaking_7 = @auto_mlivepositiontaking_7,
	    @auto_mlivepositiontaking_8 = @auto_mlivepositiontaking_8,
    	
	    @auto_v2mpositiontaking_1 = @auto_v2mpositiontaking_1,
	    @auto_v2mpositiontaking_2 = @auto_v2mpositiontaking_2,
	    @auto_v2mpositiontaking_3 = @auto_v2mpositiontaking_3,
	    @auto_v2mpositiontaking_7 = @auto_v2mpositiontaking_7,
	    @auto_v2mpositiontaking_8 = @auto_v2mpositiontaking_8,
  
	    @auto_v2mpositiontaking_20 = @auto_v2mpositiontaking_20,
	    @auto_v2mpositiontaking_9999 = @auto_v2mpositiontaking_9999,
    	
	    @auto_v3mpositiontaking_1 = @auto_v3mpositiontaking_1,
	    @auto_v3mpositiontaking_2 = @auto_v3mpositiontaking_2,
	    @auto_v3mpositiontaking_3 = @auto_v3mpositiontaking_3,	
	    @auto_v3mpositiontaking_20 = @auto_v3mpositiontaking_20,
    	
	    @auto_v5mpositiontaking_1 = @auto_v5mpositiontaking_1,
	    @auto_v5mpositiontaking_2 = @auto_v5mpositiontaking_2,
	    @auto_v5mpositiontaking_3 = @auto_v5mpositiontaking_3,	
	    @auto_v5mpositiontaking_20 = @auto_v5mpositiontaking_20,
	    @auto_v5mpositiontaking_9999 = @auto_v5mpositiontaking_9999,
    	
	    @auto_v8mpositiontaking_1 = @auto_v8mpositiontaking_1,	
	    @auto_v8mpositiontaking_3 = @auto_v8mpositiontaking_3,	
	    @auto_v8mpositiontaking_20 = @auto_v8mpositiontaking_20,
    	
	    @auto_v10mpositiontaking_1 = @auto_v10mpositiontaking_1,
	    @auto_v10mpositiontaking_2 = @auto_v10mpositiontaking_2,
	    @auto_v10mpositiontaking_3 = @auto_v10mpositiontaking_3,	
	    @auto_v10mpositiontaking_20 = @auto_v10mpositiontaking_20,
    	
	    @auto_v11mpositiontaking_1 = @auto_v11mpositiontaking_1,	
	    @auto_v11mpositiontaking_20 = @auto_v11mpositiontaking_20,
    	
	    @auto_v99mpositiontaking_1 = @auto_v99mpositiontaking_1,
	    @auto_v99mpositiontaking_2 = @auto_v99mpositiontaking_2,
	    @auto_v99mpositiontaking_3 = @auto_v99mpositiontaking_3,	
	    @auto_v99mpositiontaking_20 = @auto_v99mpositiontaking_20,	
		@auto_v99mpositiontaking_9999 = @auto_v99mpositiontaking_9999,	

	    -- mix parlay of mixed sports
	    @auto_v99mpositiontaking_9 = @auto_v99mpositiontaking_9,	      		
    	
	    @isauto_mpositiontaking_1 = @isauto_mpositiontaking_1,
	    @isauto_mpositiontaking_2 = @isauto_mpositiontaking_2,
	    @isauto_mpositiontaking_3 = @isauto_mpositiontaking_3,
	    @isauto_mpositiontaking_4 = @isauto_mpositiontaking_4,
	    @isauto_mpositiontaking_5 = @isauto_mpositiontaking_5,
	    @isauto_mpositiontaking_6 = @isauto_mpositiontaking_6,
	    @isauto_mpositiontaking_7 = @isauto_mpositiontaking_7,
	    @isauto_mpositiontaking_8 = @isauto_mpositiontaking_8,
	    @isauto_mpositiontaking_9 = @isauto_mpositiontaking_9,
	    @isauto_mpositiontaking_10 = @isauto_mpositiontaking_10,
	    @isauto_v2mpositiontaking_10 = @isauto_v2mpositiontaking_10,
	    @isauto_v3mpositiontaking_10 = @isauto_v3mpositiontaking_10,
	    @isauto_v5mpositiontaking_10 = @isauto_v5mpositiontaking_10,
	    @isauto_v8mpositiontaking_10 = @isauto_v8mpositiontaking_10,
	    @isauto_v10mpositiontaking_10 = @isauto_v10mpositiontaking_10,
	    @isauto_v11mpositiontaking_10 = @isauto_v11mpositiontaking_10,
	    @isauto_v99mpositiontaking_10 = @isauto_v99mpositiontaking_10,
	    @isauto_mpositiontaking_9999 = @isauto_mpositiontaking_9999,
    	
	    @isauto_mlivepositiontaking_1 = @isauto_mlivepositiontaking_1,
	    @isauto_mlivepositiontaking_3 = @isauto_mlivepositiontaking_3,
	    @isauto_mlivepositiontaking_7 = @isauto_mlivepositiontaking_7,
	    @isauto_mlivepositiontaking_8 = @isauto_mlivepositiontaking_8,
    	
	    @isauto_v2mpositiontaking_1 = @isauto_v2mpositiontaking_1,
	    @isauto_v2mpositiontaking_2 = @isauto_v2mpositiontaking_2,
	    @isauto_v2mpositiontaking_3 = @isauto_v2mpositiontaking_3,
	    @isauto_v2mpositiontaking_7 = @isauto_v2mpositiontaking_7,
	    @isauto_v2mpositiontaking_8 = @isauto_v2mpositiontaking_8,
	    @isauto_v2mpositiontaking_20 = @isauto_v2mpositiontaking_20,
	    @isauto_v2mpositiontaking_9999 = @isauto_v2mpositiontaking_9999,
    	
	    @isauto_v3mpositiontaking_1 = @isauto_v3mpositiontaking_1,
	    @isauto_v3mpositiontaking_2 = @isauto_v3mpositiontaking_2,
	    @isauto_v3mpositiontaking_3 = @isauto_v3mpositiontaking_3,	
	    @isauto_v3mpositiontaking_20 = @isauto_v3mpositiontaking_20,
    	
	    @isauto_v5mpositiontaking_1 = @isauto_v5mpositiontaking_1,
	    @isauto_v5mpositiontaking_2 = @isauto_v5mpositiontaking_2,
	    @isauto_v5mpositiontaking_3 = @isauto_v5mpositiontaking_3,	
	    @isauto_v5mpositiontaking_20 = @isauto_v5mpositiontaking_20,
	    @isauto_v5mpositiontaking_9999 = @isauto_v5mpositiontaking_9999,
    	
	    @isauto_v8mpositiontaking_1 = @isauto_v8mpositiontaking_1,	
	    @isauto_v8mpositiontaking_3 = @isauto_v8mpositiontaking_3,	
	    @isauto_v8mpositiontaking_20 = @isauto_v8mpositiontaking_20,
    	
	    @isauto_v10mpositiontaking_1 = @isauto_v10mpositiontaking_1,
	    @isauto_v10mpositiontaking_2 = @isauto_v10mpositiontaking_2,
	    @isauto_v10mpositiontaking_3 = @isauto_v10mpositiontaking_3,	
	    @isauto_v10mpositiontaking_20 = @isauto_v10mpositiontaking_20,
    	
	    @isauto_v11mpositiontaking_1 = @isauto_v11mpositiontaking_1,	
	    @isauto_v11mpositiontaking_20 = @isauto_v11mpositiontaking_20,

	    @isauto_v99mpositiontaking_1 = @isauto_v99mpositiontaking_1,
	    @isauto_v99mpositiontaking_2 = @isauto_v99mpositiontaking_2,
	    @isauto_v99mpositiontaking_3 = @isauto_v99mpositiontaking_3,	
	    @isauto_v99mpositiontaking_20 = @isauto_v99mpositiontaking_20,
		@isauto_v99mpositiontaking_9999 = @isauto_v99mpositiontaking_9999,

	    --- mix parlay of mixed sports
	    @isauto_v99mpositiontaking_9 = @isauto_v99mpositiontaking_9,    		  

	    @discountcs = @discountcs, 
	    --comm 1x2
	    @discount1x2 = @discount1x2,

		--BetSetting
		@BetSettingXML = @BetSettingXML,

	    -- MyanmarOdds
	    @IsMyanmarOdds=@IsMyanmarOdds,
	    @discountMyanmarOdds = @discountMyanmarOdds,
	    @SettingStatus = @SettingStatus,
	    @ErrCode = @ErrCode OUTPUT

    IF @ErrCode > 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    when 'E' then 'Create customer fail. Please try again'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					    END

		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
    		
	    return
    END
	
	If @SystemID IN (2, 10) -- ALPHA, Chatbot
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE FROM CustLimitPTSetting WITH (ROWLOCK) WHERE custId =@custid
			RETURN
		END	
	END

    SET @endRun = getdate()
    SET @duration  = datediff (MILLISECOND,@startRun,@endRun)

    DECLARE @LogSPData VARCHAR(MAX)
    --Log customer info
    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname as VARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname as VARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator as VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone as VARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone as VARCHAR(100)), SPACE(1))) + '" ' +
    'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email as VARCHAR(100)), SPACE(1))) + '" ' +
    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax as VARCHAR(100)), SPACE(1))) + '" ' +
    'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address as VARCHAR(160)), SPACE(1))) + '" ' +
    'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city as VARCHAR(100)), SPACE(1))) + '" ' +    
    'country="'+ COALESCE(CAST(@country as VARCHAR(100)), SPACE(1)) + '" ' +    
    'TransferOption="'+ COALESCE(CAST(@TransferOption as VARCHAR(8)), SPACE(1)) + '" ' +
    'credit="'+ COALESCE(CAST(@credit as VARCHAR(50)), SPACE(1)) + '" ' +
    'maxcredit="'+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + '" ' +
    'mrecommend="'+ COALESCE(CAST(@mrecommend as VARCHAR(50)), SPACE(1)) + '" ' +
    'sitename="'+ COALESCE(CAST(@sitename as VARCHAR(20)), SPACE(1)) + '" ' +
    'review="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal as VARCHAR(100)), SPACE(1))) + '" ' +
	'review2="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state as VARCHAR(100)), SPACE(1))) + '" ' +
	'IP="'+ COALESCE(CAST(@IP as VARCHAR(15)), SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language as VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(4000)), SPACE(1)) + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 602,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY	
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
	    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname as VARCHAR(100)), SPACE(1))) + '" ' +
	    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname as VARCHAR(100)), SPACE(1))) + '" ' +
	    'creator="'+ COALESCE(CAST(@creator as VARCHAR(50)), SPACE(1)) + '" ' +
	    'username="'+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + '" ' +
	    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone as VARCHAR(100)), SPACE(1))) + '" ' +
	    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone as VARCHAR(100)), SPACE(1))) + '" ' +
	    'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email as VARCHAR(100)), SPACE(1))) + '" ' +
	    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax as VARCHAR(100)), SPACE(1))) + '" ' +
	    'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address as VARCHAR(160)), SPACE(1))) + '" ' +
	    'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city as VARCHAR(100)), SPACE(1))) + '" ' +	    
	    'country="'+ COALESCE(CAST(@country as VARCHAR(100)), SPACE(1)) + '" ' +	    
	    'TransferOption="'+ COALESCE(CAST(@TransferOption as VARCHAR(8)), SPACE(1)) + '" ' +
	    'credit="'+ COALESCE(CAST(@credit as VARCHAR(50)), SPACE(1)) + '" ' +
	    'maxcredit="'+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + '" ' +
	    'mrecommend="'+ COALESCE(CAST(@mrecommend as VARCHAR(50)), SPACE(1)) + '" ' +
	    'sitename="'+ COALESCE(CAST(@sitename as VARCHAR(20)), SPACE(1)) + '" ' +
		'review="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal as VARCHAR(100)), SPACE(1))) + '" ' +
		'review2="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state as VARCHAR(100)), SPACE(1))) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP as VARCHAR(15)), SPACE(1)) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language as VARCHAR(2)), SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,

		    @CustID = @CustID,
		    @ActionID = 602,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH

    --Log commission
    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
    'groupa="'+ COALESCE(CAST(@groupa as VARCHAR(50)), SPACE(1)) + '" ' 
	IF @IsMyanmarOdds = 0 
		SET @LogSPData = @LogSPData +
		'groupb="'+ COALESCE(CAST(@groupb as VARCHAR(50)), SPACE(1)) + '" ' +
		'groupc="'+ COALESCE(CAST(@groupc as VARCHAR(50)), SPACE(1)) + '" ' +
		'groupd="'+ COALESCE(CAST(@groupd as VARCHAR(50)), SPACE(1)) + '" ' 
   
    SET @LogSPData = @LogSPData +
    'discountcs="'+ COALESCE(CAST(@discountcs as VARCHAR(50)), SPACE(1)) + '" ' + 
    'discount1x2="'+ COALESCE(CAST(@discount1x2 as VARCHAR(50)), SPACE(1)) + '" ' 
	IF @IsMyanmarOdds = 1 
		SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds as VARCHAR(50)), SPACE(1)) + '" ' 
	SET @LogSPData = @LogSPData + ' />'	
		
    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 202,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
	    'groupa="'+ COALESCE(CAST(@groupa as VARCHAR(50)), SPACE(1)) + '" ' 
		IF @IsMyanmarOdds = 0 
			SET @LogSPData = @LogSPData +
			'groupb="'+ COALESCE(CAST(@groupb as VARCHAR(50)), SPACE(1)) + '" ' +
			'groupc="'+ COALESCE(CAST(@groupc as VARCHAR(50)), SPACE(1)) + '" ' +
			'groupd="'+ COALESCE(CAST(@groupd as VARCHAR(50)), SPACE(1)) + '" ' 
	    SET @LogSPData = @LogSPData +
	    'discountcs="'+ COALESCE(CAST(@discountcs as VARCHAR(50)), SPACE(1)) + '" ' + 
	    'discount1x2="'+ COALESCE(CAST(@discount1x2 as VARCHAR(50)), SPACE(1)) + '" '  
    	IF @IsMyanmarOdds = 1 
			SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds as VARCHAR(50)), SPACE(1)) + '" ' 
    	
    	SET @LogSPData = @LogSPData + 'ErrMsg="' + ERROR_MESSAGE() + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 202,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH	

    --log bet Setting
    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
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
	'MPPMv1MP="'+ COALESCE(CAST(@maxPOpermatchv1MP AS VARCHAR(50)), SPACE(1)) + '" />'
		
	 EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 302,
		@TrackingValue = @LogSPData,
		@duration = @duration    
    
	DECLARE @LogDataSP2 VARCHAR(4000)
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @CustID

	SET @LogDataSP2 = ''
	
	CREATE TABLE #temSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT)
		
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4,@SettingStatus)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11,@SettingStatus)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13,@SettingStatus)

	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,21,@SettingStatus)

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' +  REPLACE(REPLACE(p.ProductName, ' ', ''),'*','') + '="' + COALESCE(CAST(iq.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM DBPRO.bodb02.dbo.Products p WITH (NOLOCK) 
		INNER JOIN (SELECT psd.ProductID, MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden
					FROM #temSportbettypeSetting psd WITH(NOLOCK)
						INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
																			AND	psd.BetType = psp.Bettype
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
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
		FROM		#temSportbettypeSetting AS psd WITH(NOLOCK)
			INNER JOIN	ProductStatusProfile AS psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype AND psd.BetType = psp.Bettype 
			CROSS APPLY CustProductStatus WITH(NOLOCK)
		WHERE CustID = @custid AND (psd.ProductID <> 20)
	)iq

	--Log for VR lock Status
	DECLARE @VRLockedStatus_Soccer BIT = 0
	DECLARE @VRLockedStatus_OS BIT = 0
	DECLARE @VRLockedStatus_Basketball BIT = 0

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 3)
		SET @VRLockedStatus_Basketball = 1

    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
    'isinternal="'+ COALESCE(CAST(@IsInternal as VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended as VARCHAR(1)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@UplineClosed as VARCHAR(1)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Danger="'+ COALESCE(CAST(@DangerMaster AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger2="'+ COALESCE(CAST(@DangerMaster2 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger3="'+ COALESCE(CAST(@DangerMaster3 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger4="'+ COALESCE(CAST(@DangerMaster4 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger5="'+ COALESCE(CAST(@DangerMaster5 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Abnormal="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'Special=" " ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend3="'+ COALESCE(CAST(@autosuspend3 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_Basketball="'+ COALESCE(CAST(@VRLockedStatus_Basketball AS VARCHAR(10)),SPACE(1)) + '" ' +     
    'DisableOutright="'+ COALESCE(CAST(@DisableOutright as VARCHAR(1)), SPACE(1)) + '" ' +
 
	'DisableSuperLive="' + COALESCE(CAST(@DisableSuperLive as VARCHAR(1)), SPACE(1)) + '" ' + @LogDataSP2 + ' />'
    
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1102,
		@TrackingValue = @LogSPData,
		@duration = @duration	

    -- Write Log Credit	
    Declare @LogSPCredit VARCHAR(MAX)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + ',
    MaxCredit='+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + ',
    SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1))
	
	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1209 as '@ActionID',
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
				@ActionID = 1209
		END TRY
		BEGIN CATCH
			SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + ',
		MaxCredit='+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + ',
		SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1)) + ',
		ErrMsg=' + ERROR_MESSAGE() 
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1209
		END CATCH
	END	

    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg><ag apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_1), SPACE(1)) + '" ' +
    'apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_2), SPACE(1)) + '" ' +
    'apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_3), SPACE(1)) + '" ' +
    'apt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_4), SPACE(1)) + '" ' +
    'apt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_5), SPACE(1)) + '" ' +
    'apt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_6), SPACE(1)) + '" ' +
    'apt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_7), SPACE(1)) + '" ' +
    'apt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_8), SPACE(1)) + '" ' +
    'apt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_9), SPACE(1)) + '" ' +
    'apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_10), SPACE(1)) + '" ' +
    'v2apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_10), SPACE(1)) + '" ' +
    'v3apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v3apositiontaking_10), SPACE(1)) + '" ' +
    'v5apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_10), SPACE(1)) + '" ' +
    'v8apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v8apositiontaking_10), SPACE(1)) + '" ' +
    'v10apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v10apositiontaking_10), SPACE(1)) + '" ' +
    'v11apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v11apositiontaking_10), SPACE(1)) + '" ' +
    'v99apt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_10), SPACE(1)) + '" ' +
    
    'apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_9999), SPACE(1)) + '" ' +
    'alivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@alivepositiontaking_1), SPACE(1)) + '" ' +
    'alivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@alivepositiontaking_3), SPACE(1)) + '" ' +
    'alivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@alivepositiontaking_7), SPACE(1)) + '" ' +
    'alivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@alivepositiontaking_8), SPACE(1)) + '" ' +

    'v2apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_1), SPACE(1)) + '" ' +
    'v2apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_2), SPACE(1)) + '" ' +
    'v2apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_3), SPACE(1)) + '" ' +
    'v2apt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_7), SPACE(1)) + '" ' +
    'v2apt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_8), SPACE(1)) + '" ' +
   
    'v2apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_20), SPACE(1)) + '" ' +
    'v2apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v2apositiontaking_9999), SPACE(1)) + '" ' +

    'v3apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v3apositiontaking_1), SPACE(1)) + '" ' +
    'v3apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v3apositiontaking_2), SPACE(1)) + '" ' +
    'v3apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v3apositiontaking_3), SPACE(1)) + '" ' +
    'v3apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v3apositiontaking_20), SPACE(1)) + '" ' +

    'v5apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_1), SPACE(1)) + '" ' +
    'v5apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_2), SPACE(1)) + '" ' +
    'v5apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_3), SPACE(1)) + '" ' +
    'v5apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_20), SPACE(1)) + '" ' +
    'v5apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v5apositiontaking_9999), SPACE(1)) + '" ' +

    'v8apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v8apositiontaking_1), SPACE(1)) + '" ' +
    'v8apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v8apositiontaking_3), SPACE(1)) + '" ' +
    'v8apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v8apositiontaking_20), SPACE(1)) + '" ' +

    'v10apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v10apositiontaking_1), SPACE(1)) + '" ' +
    'v10apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v10apositiontaking_2), SPACE(1)) + '" ' +
    'v10apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v10apositiontaking_3), SPACE(1)) + '" ' +
    'v10apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v10apositiontaking_20), SPACE(1)) + '" ' +

    'v11apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v11apositiontaking_1), SPACE(1)) + '" ' +
    'v11apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v11apositiontaking_20), SPACE(1)) + '" ' +

    'v99apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_1), SPACE(1)) + '" ' +
    'v99apt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_2), SPACE(1)) + '" ' +
    'v99apt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_3), SPACE(1)) + '" ' +
    'v99apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_20), SPACE(1)) + '" ' +
	'v99apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9999), SPACE(1)) + '" ' +

    'v99apt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9), SPACE(1)) + '" />' +   

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
	'v99mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9999), SPACE(1)) + '" ' +
    'v99mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99mpositiontaking_9), SPACE(1)) + '" />' +    

    --auto v1
    '<aum a_mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_1), SPACE(1)) + '" ' +
    'a_mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_2), SPACE(1)) + '" ' +
    'a_mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_3), SPACE(1)) + '" ' +
    'a_mpt_4="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_4), SPACE(1)) + '" ' +
    'a_mpt_5="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_5), SPACE(1)) + '" ' +
    'a_mpt_6="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_6), SPACE(1)) + '" ' +
    'a_mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_7), SPACE(1)) + '" ' +
    'a_mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_8), SPACE(1)) + '" ' +
    'a_mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_9), SPACE(1)) + '" ' +
    'a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_10), SPACE(1)) + '" ' +
    'v2a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_10), SPACE(1)) + '" ' +
    'v3a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_10), SPACE(1)) + '" ' +
    'v5a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_10), SPACE(1)) + '" ' +
    'v8a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_10), SPACE(1)) + '" ' +
    'v10a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_10), SPACE(1)) + '" ' +
    'v11a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_10), SPACE(1)) + '" ' +
    'v99a_mpt_10="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_10), SPACE(1)) + '" ' +
    'a_mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mpositiontaking_9999), SPACE(1)) + '" ' +
    'a_mlivept_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_1), SPACE(1)) + '" ' +
    'a_mlivept_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_3), SPACE(1)) + '" ' +
    'a_mlivept_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_7), SPACE(1)) + '" ' +
    'a_mlivept_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_8), SPACE(1)) + '" ' +

    --auto v2
    'a_v2mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v2mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_2), SPACE(1)) + '" ' +
    'a_v2mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v2mpt_7="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_7), SPACE(1)) + '" ' +
    'a_v2mpt_8="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_8), SPACE(1)) + '" ' +
   
    'a_v2mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_20), SPACE(1)) + '" ' +
    'a_v2mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_9999), SPACE(1)) + '" ' +

    --auto v3
    'a_v3mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v3mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_2), SPACE(1)) + '" ' +
    'a_v3mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v3mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_20), SPACE(1)) + '" ' +

    --auto v5
    'a_v5mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v5mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_2), SPACE(1)) + '" ' +
    'a_v5mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v5mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_20), SPACE(1)) + '" ' +
    'a_v5mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_9999), SPACE(1)) + '" ' +

    --auto v8
    'a_v8mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v8mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v8mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_20), SPACE(1)) + '" ' +

    --auto v10
    'a_v10mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v10mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_2), SPACE(1)) + '" ' +
    'a_v10mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v10mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_20), SPACE(1)) + '" ' +

    --auto v11
    'a_v11mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v11mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_20), SPACE(1)) + '" ' +

    --auto v99
    'a_v99mpt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_1), SPACE(1)) + '" ' +
    'a_v99mpt_2="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_2), SPACE(1)) + '" ' +
    'a_v99mpt_3="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_3), SPACE(1)) + '" ' +
    'a_v99mpt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_20), SPACE(1)) + '" ' +
	'a_v99mpt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_9999), SPACE(1)) + '" ' +
    'a_v99mpt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_9), SPACE(1)) +  '" />' +
      
    --isauto v1
    '<iam isa_mpt_1="'+ COALESCE(CAST(@isauto_mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_2="'+ COALESCE(CAST(@isauto_mpositiontaking_2 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_3="'+ COALESCE(CAST(@isauto_mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_4="'+ COALESCE(CAST(@isauto_mpositiontaking_4 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_5="'+ COALESCE(CAST(@isauto_mpositiontaking_5 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_6="'+ COALESCE(CAST(@isauto_mpositiontaking_6 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_7="'+ COALESCE(CAST(@isauto_mpositiontaking_7 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_8="'+ COALESCE(CAST(@isauto_mpositiontaking_8 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_9="'+ COALESCE(CAST(@isauto_mpositiontaking_9 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_10="'+ COALESCE(CAST(@isauto_mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_10="'+ COALESCE(CAST(@isauto_v2mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v3mpt_10="'+ COALESCE(CAST(@isauto_v3mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v5mpt_10="'+ COALESCE(CAST(@isauto_v5mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v8mpt_10="'+ COALESCE(CAST(@isauto_v8mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v10mpt_10="'+ COALESCE(CAST(@isauto_v10mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v11mpt_10="'+ COALESCE(CAST(@isauto_v11mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v99mpt_10="'+ COALESCE(CAST(@isauto_v99mpositiontaking_10 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mpt_9999="'+ COALESCE(CAST(@isauto_mpositiontaking_9999 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mlivept_1="'+ COALESCE(CAST(@isauto_mlivepositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mlivept_3="'+ COALESCE(CAST(@isauto_mlivepositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mlivept_7="'+ COALESCE(CAST(@isauto_mlivepositiontaking_7 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_mlivept_8="'+ COALESCE(CAST(@isauto_mlivepositiontaking_8 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v2
    'isa_v2mpt_1="'+ COALESCE(CAST(@isauto_v2mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_2="'+ COALESCE(CAST(@isauto_v2mpositiontaking_2 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_3="'+ COALESCE(CAST(@isauto_v2mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_7="'+ COALESCE(CAST(@isauto_v2mpositiontaking_7 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_8="'+ COALESCE(CAST(@isauto_v2mpositiontaking_8 as VARCHAR(50)), SPACE(1)) + '" ' +

    'isa_v2mpt_20="'+ COALESCE(CAST(@isauto_v2mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v2mpt_9999="'+ COALESCE(CAST(@isauto_v2mpositiontaking_9999 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v3
    'isa_v3mpt_1="'+ COALESCE(CAST(@isauto_v3mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v3mpt_2="'+ COALESCE(CAST(@isauto_v3mpositiontaking_2 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v3mpt_3="'+ COALESCE(CAST(@isauto_v3mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v3mpt_20="'+ COALESCE(CAST(@isauto_v3mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v5
    'isa_v5mpt_1="'+ COALESCE(CAST(@isauto_v5mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v5mpt_2="'+ COALESCE(CAST(@isauto_v5mpositiontaking_2 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v5mpt_3="'+ COALESCE(CAST(@isauto_v5mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v5mpt_20="'+ COALESCE(CAST(@isauto_v5mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v5mpt_9999="'+ COALESCE(CAST(@isauto_v5mpositiontaking_9999 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v8
    'isa_v8mpt_1="'+ COALESCE(CAST(@isauto_v8mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v8mpt_3="'+ COALESCE(CAST(@isauto_v8mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v8mpt_20="'+ COALESCE(CAST(@isauto_v8mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v10
    'isa_v10mpt_1="'+ COALESCE(CAST(@isauto_v10mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v10mpt_2="'+ COALESCE(CAST(@isauto_v10mpositiontaking_2 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v10mpt_3="'+ COALESCE(CAST(@isauto_v10mpositiontaking_3 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v10mpt_20="'+ COALESCE(CAST(@isauto_v10mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v11
    'isa_v11mpt_1="'+ COALESCE(CAST(@isauto_v11mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v11mpt_20="'+ COALESCE(CAST(@isauto_v11mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +

    --isauto v99
    'isa_v99mpt_1="'+ COALESCE(CAST(@isauto_v99mpositiontaking_1 as VARCHAR(50)), SPACE(1)) + '" ' +
    'isa_v99mpt_2="'+ COALESCE(CAST(@isauto_v99mpositiontaking_2 as VARCHAR(50)), SPACE(1))+ '" ' +
    'isa_v99mpt_3="'+ COALESCE(CAST(@isauto_v99mpositiontaking_3 as VARCHAR(50)), SPACE(1))+ '" ' +
    'isa_v99mpt_20="'+ COALESCE(CAST(@isauto_v99mpositiontaking_20 as VARCHAR(50)), SPACE(1)) + '" ' +
	'isa_v99mpt_9999="'+ COALESCE(CAST(@isauto_v99mpositiontaking_9999 as VARCHAR(50)), SPACE(1)) + '" ' +
    -- mix parlay of mixed sports
    'isa_v99mpt_9="'+ COALESCE(CAST(@isauto_v99mpositiontaking_9 as VARCHAR(50)), SPACE(1)) + '" /></Acc_CustomerInsMember_MAg>'  

	 --Log positiontaking
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 402,
		    @TrackingValue = @LogSPData,
		    @duration = @duration   
END
GO
