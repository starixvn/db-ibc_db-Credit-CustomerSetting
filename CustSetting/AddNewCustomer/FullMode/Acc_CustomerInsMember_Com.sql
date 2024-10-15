/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Com]
	@custid INT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@fax NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@site NVARCHAR(50),
	@currency INT, 
	@credit MONEY,
	@isinternal BIT = 0,
	@SystemID		TINYINT=1,	
	@IP VARCHAR(15)='',
	@Language		VARCHAR(2)= 'E',
	@SettingXML	VARCHAR(MAX) = '',
	@SettingStatus	TINYINT = 0,
	@ErrCode		INT = 0 OUTPUT,
	@ErrMsg			NVARCHAR(2000) = '' OUTPUT,
	@MsgType		INT = 0 OUTPUT
AS

--@Source Control
/*
Created: 20090121@Thien
Task : Company create Super
DB: DBCUST/CustDB
Original:

Revisions:
    - 20081021@Phuc: Add new sporttype 201, bettype 3,Hard code copy min/max/maxperbet/PT for sporttype 201 from 2 sporttype 
	- 20090122@PhuongBich: Add new sporttype 201, bettype 2.
	- 20090122@PhuongNguyen: Remove userpwd from log writing
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
    - 20090424@Phuc:Separate finance sporttype(201).
	- 20090514@PhuongDao: Add commission for 1x2  
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove HR input params of Min-Max BET and commission 
    - 20090525@Kiwi: not using Allowed HR currency from systemsetting table
    - 20090901@Shifu: Add IsInternal user option
    - 20090903@Simon: Write Credit Log into Userlog_Credit table.
	- 20090917@Phuc: write log into DBLOG.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [wsv_xnap]
	- 20100828@Henry: remove mix parlay of basketball + add new section for MixParlay for Mix Sports + Setting for Numbergame
	- 20100909@Jamie: Add param @DisableCasino 
	- 20101019@Henry: Record execution time
	- 20101026@Lukas: add max per ball(number game)
	- 20101205@Henry: change the commision to use discountcs of Mix Sports Parlay instead of Group A/B/C/D
	- 20103012@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20110822@Tom: Add P2P setting
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20111214@Sophia: Check @@Error for inserting P2P
	- 20111222@Johnson: Add live casino setting
	- 20120412@Johnson: Hard code commission 0
	- 20120502@Lukas: Encode XML values in logging
	- 20120704@Johnson: Remove setting hard code of number group bettype
	- 20120731@Dan: add default setting for Virtual soccer
	- 20120928@Johnson: Add double comm losing status
	- 20121011@Dan: add win limit setting for live casino
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130219@Johnson: Add virtual horse racing setting (sporttype : 181, bettype: 1231)
					and write log into DBTXN if DBLOG failure.
	- 20130731@Elodie: Apply progressive bonus	
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend into Soccer and Other Sport [Redmine:#5520]		
	- 20131107@Johnson: Apply execrep when insert setting into custsetting/custsetting3rd
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140318@Patrick: Modify log for Keno status
	- 20140612@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20140822@Logan:   Add status for Esports [Redmine: #20531]
	- 20141225@Johnson: Separate virtual rate by sporttype, bettype [Redmine: #25840]				
	- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	- 20150601@Elodie: Separate CustDB to DBCUST server (Use temp table for GameType table)
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150714@Patrick: Add max win limit for Gold deluxe
	- 20151001@Elodie: Set HideGoldDeluxe = 0, DisableGoldDeluxe = 0 for real super
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151104@Billy: Add Disable and Hide to log initial status [Redmine: #46833]
	- 20151217@Helen: Creating Disable and Hide Product dynamically - [Redmine:#48602] 
	- 20151223@Patrick: Add Max/Loss limit for RnG Casino [Redmine: #49528]
	- 20160215@Dominic: Cricket is not showed in log for MBC customers [Redmine: #52158]
	- 20160222@Dominic: Log initial status is blank [Redmine: #52657]
	- 20160315@Winnie: Hotfix 51457 write wrong log info
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20160707@Winnie: #48948 Hide_special_sites_from_unautorized_users
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20161223@Winnie: Hot Fix  Show Fishing World logs although this Product is not released to PROD yet [Redmine:69236]
	- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]					
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170620@Winnie: Apply color for closed account - [RedmineID: 74494]
	- 20171205@Johnson: add more log for special, doublecomm, autosuspend status [Redmine: #87121]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180808@Helen: DB05.DBPOLICY migration  [Redmine:99462]  	
	- 20181002@Elodie: Limit max members creation per Super. [RedmineID: #101994]
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]  
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526] 	
	- 20181102@Johnson: Apply service broker for logging [Redmine: #103547]  	
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200228@Tiara: Enable Keno product by default for 789y Headline [Redmine: 124311]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201027@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20201008@Winfred : New Super - Prefix Warning [Redmine: #142239]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210202@Winfred : Virtual Rate for Basketball - New 611111 site super must have VR setting = 0%   [Redmine: #149369]	
	- 20210308@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210405@Johnson: Hide log Gold Deluxe Setting [redmined:#151188]
	- 20210616@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20211104@Johnson: Abnormal remark on Accounting Site [redmine: #163518]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220222@Elodie: Default VR for 789y site [Redmine: #168885]
	- 20220419@Eden: Turn off VR Basketball & E-sports for 611111 site [Redmine: #171609]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20221226@Tacy: Alpha/NAP - Split 789y Site [RedmineID: #181596]
	- 20230303@Johnson: add auto suspend for Basketball and return Basketball VR to its original state [redmine: #184339]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230427@Luke: Separate lock function for Basketball [Redmine: #185991]
	- 20230711@Helios: Add Log VR+ Accumulate Balance [Redmine: #189649] 
	- 20240129@Luke: NAP - Virtual rate - Change default of VR Status for newly created Super to Enable [Redmine: #200311]
	- 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240318@Eden: Unify Live RNG Casino [Redmine: #198960] 
	- 20240419@Tacy: NAP - Permission controls on real currency [redmineID: #202523
	- 20240606@Johnson: Scale out DBCUST [Redmine: #199915]
	- 20240520@Eden: Unify RNG Games [redmine: #204358] 
	- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
	- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]

Param's Explanation:
	- @ErrCode:
		= 0: Create super successfully.
		> 0: Specific Error.
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT
	- @SettingXML: Json format
		'{
					"150": [
						{"SportType": "1","BetType": "1","Discount": "0.0010000"},
						{"SportType": "1","BetType": "3","Discount": "0.0015000"},
						{"SportType": "1","BetType": "5","Discount": "0.0025000"},
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
						{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "87"},
						{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
						{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
						{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
						{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
						{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
						{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"}
					]
				}'
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME , @endRun DATETIME , @duration INT
	DECLARE @roleid INT = 4
			,@SettingType25	VARCHAR(MAX)= ''
			,@SettingType26	VARCHAR(MAX)= ''
			,@SettingType27	VARCHAR(MAX)= ''
			,@SettingType28	VARCHAR(MAX)= ''

	SET @startRun = GETDATE()
	-------------------BLOCK ADDING NEW USE UMCONFIG----------------------------
	DECLARE @SiteID int, @SiteLabel varchar(50), @EnableVR BIT
	DECLARE @DisableSuperLive BIT = 1, @DoubleCommLosing BIT = 1

	SELECT @SiteID = siteid, @SiteLabel=SiteLabel
	FROM site WITH(NOLOCK)
	WHERE site = @site

	--SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	SELECT @EnableVR = 1 --Enable as default [#200311]

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
					SELECT SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,MinPT
					FROM OPENJSON(@SettingXML,'$."153"') WITH (
							 SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,IsLive BIT  '$.IsLive'
							,SuperPT SMALLMONEY  '$.SuperPT'
							,MasterPT SMALLMONEY  '$.MasterPT'
							,AgentPT SMALLMONEY  '$.AgentPT'
							,MinPT SMALLMONEY  '$.MinPT'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	EXEC Acc_CustomerInsMember_DiscountCheck_Com
		@siteID = @siteID,
		@currency = @currency,
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
		
	--Check bet setting
	EXEC Acc_CustomerInsMember_BetSettingCheck_Com
		@siteID = @siteID,
		@currency = @currency,
		@SettingType26 = @SettingType26 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
		
	--Check Parlay Max Payout
	EXEC Acc_CustomerInsMember_ParlayMaxPayoutCheck_Com
		@siteID = @siteID,
		@currency = @currency,
		@SettingType27 = @SettingType27 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate
		
	--Check PT
	EXEC Acc_CustomerInsMember_PTCheck_Com
		@siteID = @siteID,
		@currency = @currency,
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingStatus = @SettingStatus,
		@IsValidateParam = 0,
		@IsUpdateParam = 1--update parameter only, skip validate

	--Insert general info
	BEGIN TRY
		EXEC dbo.Acc_CustomerInsUserInfo 
			@custid = @custid,
			@firstname = @firstname,
			@lastname = @lastname,
			@creator = @creator,
			@username = @username,
			@userpwd = @userpwd,
			@pwdexpiry = NULL,
			@currency = @currency,
			@site = @site,
			@srecommend = 0,
			@mrecommend = 0,
			@recommend = 0,
			@roleid = 4,
			@phone = @phone,
			@mobilephone = @mobilephone,
			@email = '',
			@fax = @fax,
			@address = '',
			@city = '',
			@state = '',
			@country = '',
			@postal = '',
			@TransferOption = NULL,
			--@suspended = 0,
			@SystemID=@SystemID,
			@autosuspend = 0,
			@autosuspend2 = 0,	
			@autosuspend3 = 0,	
			@matchlimit = 1,
			@virtualmultiplier = @EnableVR,	

			@DoubleCommLosing = @DoubleCommLosing,					
			@DisableSuperLive = @DisableSuperLive,

			@credit = @credit,
			@maxcredit = NULL,
			@IP = @IP,
			@isinternal = @isinternal,
			@TransferOption_dec = NULL,
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
		DECLARE @ProductProfile VARCHAR(MAX) = ''

		EXEC dbo.Acc_CustomerInfo_Execrep_00
			@custid = @custid,
			@roleid = 4,
			@siteID = @siteID,
			@currency = @currency,
			@SettingType25 = @SettingType25, --Discount	
			--@SettingType26 = @SettingType26, --Bet Setting
			@SettingType27 = @SettingType27, --Parlay Max Payout
			@SettingType28 = @SettingType28, --PT
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT,
			@ProductProfile = @ProductProfile OUTPUT

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END		

			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @RoleID
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END

	-- Start : Initialize Data SportsBook
		EXEC dbo.Acc_Custsetting_SportsbookIns
			@custid = @custid,
			@roleid = 4,
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
			@SuperID = @custid,
			@RoleID = 4,
			@siteID = @siteID,
			@currency = @currency,
			@ProductProfile = @ProductProfile,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END
				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = @RoleID
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID	
				RETURN
		END
		-- End : Initialize Data 3rd Products

		 --New 611111 super must have VR setting = 0% (Basketball level)
		 IF @site = '611111'
		 BEGIN				
			DECLARE @VirtualRateMultiplier2 VARCHAR(MAX) = '' --Esports
			SELECT @VirtualRateMultiplier2 = CONVERT(VARCHAR(MAX),(  SELECT b.LevelID,vr.ValueID AS ValueIDLive,vr.ValueID AS ValueIDNonLive 
																FROM VRSettingHierarchy b WITH(NOLOCK) 
																	CROSS APPLY VRValueMapping vr (NOLOCK)
																WHERE b.SportType = 43 
																	AND b.VRLeagueGroupID = -1 
																	AND b.BetType = -1 
																	AND vr.Value = 1
																FOR XML RAW('Row'), ROOT ('Root'))
												)

			EXEC [Acc_CustVirtualMultiplier_Upd]
				  @CustID = @CustID
				, @SportType = 43
				, @VirtualMultiplier = @VirtualRateMultiplier2
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
	
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	DECLARE @MaxMemberLog VARCHAR(50)
	SELECT @MaxMemberLog = CASE WHEN @SiteLabel = '789y' THEN '20000' ELSE 'Unlimited' END

	DECLARE @LogSPData VARCHAR(MAX)
	--Write general info
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +

	'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
	'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)),SPACE(1)) + '" ' +
	'username="'+ COALESCE(CAST(@username AS VARCHAR(20)),SPACE(1)) + '" ' +
	'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +
	'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
	'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)),SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 600,
		@TrackingValue = @LogSPData,
		@duration = @duration	

		-- Write Log Credit	
	DECLARE @LogSPCredit VARCHAR(MAX)
	SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1))

	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1208 as '@ActionID',
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
				@ActionID = 1208
		END TRY
		BEGIN CATCH
			SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1)) 
								+  ', ErrMsg=' + ERROR_MESSAGE() 
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1208					
		END CATCH
	END

	--Write status log	
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

	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	--20171205@Johnson: add more log for status
	'Special=" " ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend3="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(1)),SPACE(1)) + '" ' +
	'VRAccumulatedBalance="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'VRLockStatus_Soccer="'+ COALESCE(CAST(0 AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(0 AS VARCHAR(10)),SPACE(1)) + '" ' +
	'VRLockStatus_Basketball="'+ COALESCE(CAST(0 AS VARCHAR(10)),SPACE(1)) + '" ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +	
		
	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)),SPACE(1)) + '" ' + @LogDataSP2 +
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1100,
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
		@ActionID = 261000,
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
		@ActionID = 262000,
		@TrackingValue = @LogSPData,
		@duration = @duration  

	--Log Position Taking
	DECLARE @XML XML
	SELECT @xml = CONVERT(XML, @SettingType28)

	SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT 
						T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney')/100 AS SuperPT,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
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
		@ActionID = 263000,
		@TrackingValue = @LogSPData,
		@duration = @duration 

	DROP TABLE #tempProductOfferStatus
	DROP TABLE #tempSportbettypeSetting

END
GO


