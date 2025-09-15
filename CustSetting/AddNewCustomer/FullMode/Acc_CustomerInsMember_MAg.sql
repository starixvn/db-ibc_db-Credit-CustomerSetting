/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_MAg]
	@custid     INT,
	@firstname  NVARCHAR(50) ='',
	@lastname   NVARCHAR(50) ='',
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50)='',
	@mobilephone NVARCHAR(50)='',	
	@fax        NVARCHAR(50)='',
	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in case direct master add new agent
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0,--Sub-AccountID,
	@credit MONEY,
	@maxcredit MONEY = 0,	
	@mrecommend INT,
	@SystemID	TINYINT=1,	
	@IP VARCHAR(15)='',
	@Site NVARCHAR(50),
	@SettingXML	VARCHAR(MAX) = '',
	@SettingStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
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
	- 20100728@Kiwi: grant execute permission to [wsv_xnap]
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
	- 20230622@Helios: Alpha/ExtNAP - Create new downlines - Remove some obsolete rules [Redmine: #190167]
	- 20230711@Helios: Add Log VR+ Accumulate Balance [Redmine: #189649]
	- 20230918@Helios: Update rule VR+ for New Customer [Redmine: #194141]
	- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240321@Luke: NAP - Virtual rate - For Direct account :Change default of VR Status for newly created accounts to "Follow upline" [Redmine: #202624]
	- 20240318@Eden: Unify Live RNG Casino [Redmine: #198960] 
	- 20240606@Johnson: Scale out DBCUST [Redmine: #199915]
	- 20240520@Eden: Unify RNG Games [redmine: #204358] 
	- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
	- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]
	- 20250915@Johnson: Max Payout Per Match - Change to Max Win [redmine: #236447]

Param's Explanation:
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT
	- @SettingXML: Json format
	'{
		"150": [
			{"SportType": "1","BetType": "1","Discount": "0.0010000"},
			{"SportType": "1","BetType": "3","Discount": "0.0015000"},
			{"SportType": "1","BetType": "5","Discount": "0.0070000"},
			{"SportType": "1","BetType": "7","Discount": "0.0020000"},
			{"SportType": "1","BetType": "4","Discount": "0.0035000"},
			{"SportType": "1","BetType": "8","Discount": "0.0025000"}
		],
		"151": [
			{"SportType": "1","BetType": "9","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "2","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "9902","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "1","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "9901","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "11","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "99","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "3","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "5","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "8","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "10","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "99","BetType": "9","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "43","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10"},
			{"SportType": "44","BetType": "3","MinBet": "0","MaxBet": "0","MPM": "0"}
		],
		"152": [
			{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
			{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
		],
		"153": [
			{"SportType": "9914","BetType": "915","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "917","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "917","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9915","BetType": "918","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "915","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "916","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "916","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"}
		]
	}'
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
			,@RoleID INT = 2
			,@SettingType25	VARCHAR(MAX)= ''
			,@SettingType26	VARCHAR(MAX)= ''
			,@SettingType27	VARCHAR(MAX)= ''
			,@SettingType28	VARCHAR(MAX)= ''
			,@SiteID int

    SET @startRun = GETDATE()

    declare 
	    @transcode bigint, @currency INT, @pwdexpiry datetime,	
	    --@Credit_AllOtherAgent MONEY, @Credit_AllMember MONEY, @Credit_MAg MONEY,
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
		@suspended BIT = 0,
		@DisableSuperLive BIT = 0,
		@DangerMaster TINYINT = 0,
		@DangerMaster2 TINYINT = 0,
		@DangerMaster3 TINYINT = 0,
		@DangerMaster4 TINYINT = 0,
		@DangerMaster5 TINYINT = 0,
		@EnableVR BIT

	
	SELECT @currency = currency
         --, @Msuspended = reject
         , @UplineClosed = cs.closed

         --, @Credit_MAg = isnull(credit, 0)
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
	 
	 SELECT @siteID = s.siteID  
	 FROM customer c WITH(NOLOCK)   
	  INNER JOIN site s WITH(NOLOCK) ON c.site = s.site  
	 WHERE CustID = @mrecommend  
	 
	 --Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @mrecommend)		
		AND EXISTS( 
				SELECT 1 
				FROM dbo.Site WITH (NOLOCK)
				WHERE site = @site AND SiteLabel IN ('789y')
			)
				SET @EnableVR = 1
	
	SELECT @username = rtrim(ltrim(@username))

    SELECT @pwdexpiry = dateadd(dd, 30, getdate())
	--Vinh@20080213: get transfer option FROM master
    DECLARE @IsInternal BIT
    select  @IsInternal = IsInternal,
            @TransferOption_dec = TransferOption 
    FROM custmaster with (nolock) 
    WHERE CustID = @mrecommend

	SELECT @SettingType25 = CONVERT(VARCHAR(MAX),
			(
				SELECT SportType,BetType,Discount
				FROM OPENJSON(@SettingXML,'$."150"') WITH (
						SportType SMALLINT  '$.SportType'
						,BetType SMALLINT  '$.BetType'
						,Discount DECIMAL(9,8)  '$.Discount'
					)
				FOR XML RAW('R'), ROOT ('Root'), TYPE
			)
		)

	SELECT @SettingType26 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout
					FROM OPENJSON(@SettingXML,'$."151"') WITH (
							SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,MinBet MONEY  '$.MinBet'
							,MaxBet MONEY  '$.MaxBet'
							,MPM MONEY  '$.MPM'
							,MaxPayout MONEY  '$.MaxPayout'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType27 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
					FROM OPENJSON(@SettingXML,'$."152"') WITH (
							 SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,SingleMP MONEY  '$.SingleMP'
							,Combo2 MONEY  '$.Combo2'
							,Combo35 MONEY  '$.Combo35'
							,Combo6 MONEY  '$.Combo6'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
					FROM OPENJSON(@SettingXML,'$."153"') WITH (
							 SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,IsLive BIT  '$.IsLive'
							,MasterPT SMALLMONEY  '$.MasterPT'
							,IsAuto BIT  '$.IsAutoMasterPT'
							,AutoPT SMALLMONEY  '$.AutoMasterPT'
							,AgentPT SMALLMONEY  '$.AgentPT'
							,MinPT SMALLMONEY  '$.MinPT'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--------START: Update parametter-------------------------------------------------------------------
	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType25 = @SettingType25 OUTPUT, --SB	
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
	
	--Check bet setting
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType26 = @SettingType26 OUTPUT, --SB
		@SystemID = @SystemID,
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
		
	--Check Parlay Max Payout
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType27 = @SettingType27 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate

	--Check PT
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_MAg
		@mrecommend = @mrecommend,
		@srecommend = @srecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
	--------END: Update parametter-------------------------------------------------------------------

	--Insert general data 
    BEGIN TRY
		EXEC dbo.Acc_CustomerInsUserInfo
			@custid = @custid,
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
			@email = '',
			@fax = @fax,
			@address = '',
			@city = '',
			@state = '',
			@country = '',
			@postal = '',
			@TransferOption = @TransferOption,
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

		IF @ErrCode <> 0
		BEGIN
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = @@ERROR
				,@ErrMsg = ERROR_MESSAGE()

		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

		RETURN
	END CATCH

	BEGIN TRY
		EXEC dbo.Acc_CustomerInfo_Execrep_00  
			@custid = @custid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@roleid = 2,
			@siteID = @siteID,
			@currency = @currency,
			@SettingType25 = @SettingType25, --Discount	
			--@SettingType26 = @SettingType26, --Bet Setting
			@SettingType27 = @SettingType27, --Parlay Max Payout
			@SettingType28 = @SettingType28, --PT
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Create customer fail. Please try again'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					END
    			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @roleid
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END	
	
		-- Start : Initialize Data SportsBook
		EXEC dbo.Acc_Custsetting_SportsbookIns
			@custid = @custid,
			@roleid = 2,
			@siteID = @siteID,
			@currency = @currency,
			@SettingType26 = @SettingType26, --Bet Setting		
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @roleid
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END

		-- Start : Initialize Data 3rd Products
		EXEC dbo.Acc_CustSetting_3rdProductIns  
			@custid = @custid,  
			@SuperID = @srecommend,  
			@MasterID = @mrecommend,  
			@AgentID = @custid,  
			@RoleID = 2,  
			@siteID = @siteID,  
			@currency = @currency,   
			@SettingStatus = @SettingStatus,  
			@ErrCode = @ErrCode OUTPUT  

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @roleid
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END
		-- End : Initialize Data 3rd Products
			
		If @SystemID = 2 -- ALPHA
		BEGIN
			EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
			IF @ErrCode > 0
			BEGIN
				SELECT @ErrMsg = CASE @Language 
									when 'E' then 'Create customer fail. Please try again'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END
				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @roleid
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
				RETURN
			END	
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = @@ERROR
				,@ErrMsg = ERROR_MESSAGE()
		
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @roleid
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH

    SET @endRun = getdate()
    SET @duration  = datediff (MILLISECOND,@startRun,@endRun)

	DECLARE @LogSPData NVARCHAR(MAX)
   
	--Log customer info
    SELECT @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS NVARCHAR(100)), SPACE(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
	'maxcredit="'+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + '" ' +
    'TransferOption="'+ COALESCE(CAST(@TransferOption AS VARCHAR(8)), SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +	
    'mrecommend="'+ COALESCE(CAST(@mrecommend AS VARCHAR(50)), SPACE(1)) + '" ' +	
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
    'site="'+ COALESCE(CAST(@site AS VARCHAR(50)), SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 602,
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
	
	DECLARE @LogDataSP2 VARCHAR(4000) = ''
	
	CREATE TABLE #tempSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT, GroupID TINYINT)
	CREATE TABLE #tempProductOfferStatus(custIsHidden BIT, Name VARCHAR(50))

	INSERT INTO #tempSportbettypeSetting(ProductID,SportType,Bettype,SettingType,GroupID)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	,GroupID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)
	WHERE SettingType IN (4,11,13,21)
		AND realProductID NOT IN (24,59)
	
	INSERT INTO #tempProductOfferStatus(custIsHidden, Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, REPLACE(REPLACE(MAX(p.ProductName), ' ', ''),'*','') 
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
		INNER JOIN dbo.Products p WITH (NOLOCK)  ON p.ProductID = psd.ProductID
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) NOT IN (3)
	GROUP BY psd.ProductID

	INSERT INTO #tempProductOfferStatus(CustIsHidden,Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, 'GroupID' + CAST(psd.GroupID AS VARCHAR(10))
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) IN (3)
	GROUP BY psd.GroupID

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' + t.Name  + '="' + COALESCE(CAST(t.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM #tempProductOfferStatus t

	SELECT @LogDataSP2	= @LogDataSP2 
						+ 'Disable' + CAST(Sporttype AS VARCHAR) + '_' + CAST(Bettype AS VARCHAR)
						+ '="' + COALESCE(CAST(custIsDisable AS VARCHAR(1)), SPACE(1)) + '" '
	FROM (
		SELECT	psp.Sporttype,
				psp.Bettype,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, psp.bitmapOrder)) AS custIsDisable
		FROM		#tempSportbettypeSetting AS psd WITH(NOLOCK)
			INNER JOIN	ProductStatusProfile AS psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype AND psd.BetType = psp.Bettype 
			CROSS APPLY CustProductStatus WITH(NOLOCK)
		WHERE CustID = @custid AND (psd.ProductID <> 20)
	)iq

	--Log for VR lock Status
	DECLARE @VRLockedStatus_Soccer BIT = 0
	DECLARE @VRLockedStatus_OS BIT = 0
	DECLARE @VRLockedStatus_Basketball BIT = 0
	--Log for VR+
	DECLARE @VRAccumulatedBalance BIT = 0

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 3)
		SET @VRLockedStatus_Basketball = 1
	
	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 4)
		SET @VRAccumulatedBalance = 1

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
	'VRAccumulatedBalance="'+ COALESCE(CAST(@VRAccumulatedBalance AS VARCHAR(10)),SPACE(1)) + '" ' + 
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
		
	--Log Commission
	SELECT @LogSPData = '<Root>' 
			+ '<Discount>' 
				+ COALESCE(REPLACE(REPLACE(@SettingType25,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</Discount>'
			+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 261002,
		@TrackingValue = @LogSPData,
		@duration = @duration  
	
	--Log BetSetting
	SELECT @LogSPData = '<Root>' 
			+ '<BetSetting>'
				+ COALESCE(REPLACE(REPLACE(@SettingType26,'<Root>',''),'</Root>',''), SPACE(1))
			+ '</BetSetting>'
			+ '<ParlayMaxPayout>' 
				+ COALESCE(REPLACE(REPLACE(@SettingType27,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</ParlayMaxPayout>'	
			+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 262006,
		@TrackingValue = @LogSPData,
		@duration = @duration  

	--Log Position Taking

	--PT SB
	DECLARE @xml XML
	SELECT @xml = CONVERT(XML, @SettingType28)

	SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT 
						T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
						T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAuto,
						T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoPT,
						T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT,
						T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS MinPT
					FROM  @xml.nodes('/Root/R') T(c)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @LogSPData = '<Root>' 
			+ '<PT>'
				+ COALESCE(REPLACE(REPLACE(@SettingType28,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</PT>'
			+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 263002,
		@TrackingValue = @LogSPData,
		@duration = @duration 

	DROP TABLE #tempProductOfferStatus
	DROP TABLE #tempSportbettypeSetting
END
GO