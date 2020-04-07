/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Com]
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@address NVARCHAR(80)=NULL,
	@postal NVARCHAR(50)=NULL,
	@city NVARCHAR(50)=NULL,
	@state NVARCHAR(50)=NULL,
	@country NVARCHAR(50)=NULL,
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@email NVARCHAR(50) = '',
	@fax NVARCHAR(50),
	@refcode1 NVARCHAR(50)=NULL,
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@site NVARCHAR(50),
	@currency INT, 
	@credit MONEY,
	@groupa DECIMAL(9,8), 
	@groupb DECIMAL(9,8), 
	@groupc DECIMAL(9,8), 
	@groupd DECIMAL(9,8),
	@discountcs DECIMAL(9,8)=0, 
	--comm 1x2
	@discount1x2 DECIMAL(9,8)=0,

	@isinternal BIT = 0,

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
	
	--Mix Parlay mix sports
	@MinBetv99MP MONEY,
	@MaxBetv99MP MONEY,
	@MaxPerMatchv99MP MONEY,
	
	--Mix Parlay soccer sports
	@MinBetv1MP MONEY = 0,
	@MaxBetv1MP MONEY = 0,
	@MaxPerMatchv1MP MONEY = 0,	

	--Number game
	@MinBetv161 MONEY,
	@MaxBetv161 MONEY,
	@MaxPerMatchv161 MONEY,

	@MaxPerBallv161 MONEY = 0,

	@MinBetv164 MONEY,
	@MaxBetv164 MONEY,
	@MaxPerMatchv164 MONEY,	
	
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
	@v99spositiontaking_9 SMALLMONEY,
	@v99spositiontaking_20 SMALLMONEY,
	@v99spositiontaking_9999 SMALLMONEY,
	--v161
	@v161spositiontaking_81 SMALLMONEY,
	@v161spositiontaking_83 SMALLMONEY,
	@v161spositiontaking_86 SMALLMONEY,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY,
	@v161slivepositiontaking_86 SMALLMONEY,
	@v161slivepositiontaking_87 SMALLMONEY,	
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0,
	
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
	@mpositiontaking_9999 SMALLMONEY =0,
	
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
	@v2mpositiontaking_9999 SMALLMONEY =0,
	
	
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
	@v99mpositiontaking_9 SMALLMONEY,
	@v99mpositiontaking_20 SMALLMONEY,	
	@v99mpositiontaking_9999 SMALLMONEY,	
	--v161
	@v161mpositiontaking_81 SMALLMONEY,
	@v161mpositiontaking_83 SMALLMONEY,
	@v161mpositiontaking_86 SMALLMONEY,
	@v161mpositiontaking_88 SMALLMONEY,
	@v161mlivepositiontaking_85 SMALLMONEY,
	@v161mlivepositiontaking_86 SMALLMONEY,
	@v161mlivepositiontaking_87 SMALLMONEY,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY =0,
	
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
	
	@alivepositiontaking_1 SMALLMONEY,
	@alivepositiontaking_3 SMALLMONEY,
	@alivepositiontaking_7 SMALLMONEY,
	@alivepositiontaking_8 SMALLMONEY,
	
	@v2apositiontaking_1 SMALLMONEY,
	@v2apositiontaking_2 SMALLMONEY,
	@v2apositiontaking_3 SMALLMONEY,
	@v2apositiontaking_7 SMALLMONEY,
	@v2apositiontaking_8 SMALLMONEY,
	@v2apositiontaking_20 SMALLMONEY,
	@v2apositiontaking_9999 SMALLMONEY =0,
	
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
	@v99apositiontaking_9 SMALLMONEY,
	@v99apositiontaking_20 SMALLMONEY,
	@v99apositiontaking_9999 SMALLMONEY,
	--v161
	@v161apositiontaking_81 SMALLMONEY,
	@v161apositiontaking_83 SMALLMONEY,
	@v161apositiontaking_86 SMALLMONEY,
	@v161apositiontaking_88 SMALLMONEY,
	@v161alivepositiontaking_85 SMALLMONEY,
	@v161alivepositiontaking_86 SMALLMONEY,
	@v161alivepositiontaking_87 SMALLMONEY,
	@v161alivepositiontaking_89 SMALLMONEY = 0,
	@v161alivepositiontaking_90 SMALLMONEY = 0,
	@SystemID		TINYINT=1,	
	@DisableCasino BIT = 0, 
	@DisableNumber BIT = 0,
	@DoubleCommLosing BIT = 1,
	
	@DisableGoldDeluxe BIT = 0,
	@DisableSuperLive BIT = 1,
	@IP VARCHAR(15)='',
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(2000) = '' OUTPUT
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
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
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

Param's Explanation:
• @ErrCode:
    = 0: Create super successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpUserid VARCHAR(50)
	
	SELECT @tmpUserid=CAST(@creator AS VARCHAR(50))
		
	INSERT INTO  @tmp (siteid , site,SpecialGroup)
	SELECT siteid , [site], SpecialGroup FROM NAP_UserControl.dbo.f_GetDeniedSiteByUser(@tmpUserid)
	
	IF (@site IN (SELECT site FROM @tmp ))
	BEGIN
		SELECT @ErrCode = 103, @ErrMsg ='You don''t have permission to access'
		RETURN
	END
	
	DECLARE @BlockNewCust BIT, @UnblockTime VARCHAR(50)

	EXEC [dbo].[Acc_BlockNewCust_Check]
		@Site  = @Site,
		@BlockNewCust = @BlockNewCust OUTPUT , 
		@UnblockTime = @UnblockTime OUTPUT

	IF @BlockNewCust = 1
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'VI' THEN N'Chúng tôi đang xử lý việc ra mắt sản phẩm mới, vui lòng tạo tài khoản cấp dưới sau ' + @UnblockTime + N'. Vui lòng liên hệ với cấp trên hoặc bộ phận Chăm Sóc Khách Hàng để biết thêm thông tin.'
							ELSE 'We are in processing for new product offering, please try to create downline account after ' + @UnblockTime + '. Please contact your upline or CSD for further information.'
						END	
				,@ErrCode = 101	
		RETURN
	END

	----- Elodie @ 01 JUN 2015 -------------------
		DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)

		BEGIN TRY		
			INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
			SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
		END TRY
		BEGIN CATCH		
			INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
			SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
		END CATCH

	----- /Elodie @ 01 JUN 2015 -------------------
	DECLARE @startRun DATETIME , @endRun DATETIME , @duration INT
	SET @startRun = GETDATE()

	DECLARE @transcode BIGINT 
	DECLARE @isvalid BIT
	SELECT @ErrCode = 0
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	EXEC dbo.Acc_CustomerInsMember_Com_CheckParam 
				@custid = @custid OUTPUT,
				@currency = @currency,
				@credit = @credit,
				@groupa = @groupa,
				@groupb = @groupb,
				@groupc = @groupc,
				@groupd = @groupd,
				@discountcs = @discountcs,	
				@discount1x2 = @discount1x2, --1x2		
				
				@MinBet = @MinBet,
				@MaxBet = @MaxBet,
				@MaxPerMatch = @MaxPerMatch,
				@MinBetv2 = @MinBetv2,
				@MaxBetv2 = @MaxBetv2,
				@MaxPerMatchv2 = @MaxPerMatchv2,
				@MinBetv3 = @MinBetv3,
				@MaxBetv3 = @MaxBetv3,
				@MaxPerMatchv3 = @MaxPerMatchv3,
				@MinBetv5 = @MinBetv5,
				@MaxBetv5 = @MaxBetv5,
				@MaxPerMatchv5 = @MaxPerMatchv5,
				@MinBetv8 = @MinBetv8,
				@MaxBetv8 = @MaxBetv8,
				@MaxPerMatchv8 = @MaxPerMatchv8,
				@MinBetv10 = @MinBetv10,
				@MaxBetv10 = @MaxBetv10,
				@MaxPerMatchv10 = @MaxPerMatchv10,
				@MinBetv11 = @MinBetv11,
				@MaxBetv11 = @MaxBetv11,
				@MaxPerMatchv11 = @MaxPerMatchv11,

				@MinBetv99 = @MinBetv99,
				@MaxBetv99 = @MaxBetv99,
				@MaxPerMatchv99 = @MaxPerMatchv99,
				
				--Mix Parlay mix sports
				@MinBetv99MP = @MinBetv99MP,
				@MaxBetv99MP = @MaxBetv99MP,
				@MaxPerMatchv99MP = @MaxPerMatchv99MP,
				
				--Mix Parlay Soccer sports
				@MinBetv1MP = @MinBetv1MP,
				@MaxBetv1MP = @MaxBetv1MP,
				@MaxPerMatchv1MP = @MaxPerMatchv1MP,				

				--Number game
				@MinBetv161 = @MinBetv161,
				@MaxBetv161 = @MaxBetv161,
				@MaxPerMatchv161 = @MaxPerMatchv161,

				@MaxPerBallv161 = @MaxPerBallv161,
				
				@MinBetv164 = @MinBetv164,
				@MaxBetv164 = @MaxBetv164,
				@MaxPerMatchv164 = @MaxPerMatchv164,
				
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
				@v99spositiontaking_10 = @v99spositiontaking_10,
				@v2spositiontaking_10 = @v2spositiontaking_10,
				@v3spositiontaking_10 = @v3spositiontaking_10,
				@v5spositiontaking_10 = @v5spositiontaking_10,
				@v8spositiontaking_10 = @v8spositiontaking_10,
				@v10spositiontaking_10 = @v10spositiontaking_10,
				@v11spositiontaking_10 = @v11spositiontaking_10,
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
				--v161
				@v161apositiontaking_81 = @v161apositiontaking_81,
				@v161apositiontaking_83 = @v161apositiontaking_83,
				
				@v161apositiontaking_86 = @v161apositiontaking_86,
				@v161apositiontaking_88 = @v161apositiontaking_88,
				@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
				@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
				@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
				@v161alivepositiontaking_89 = @v161alivepositiontaking_89,
				@v161alivepositiontaking_90 = @v161alivepositiontaking_90,
							
				
				@isvalid = @isvalid OUTPUT,
				@errmsg = @errmsg OUTPUT,
				@errcode = @errcode OUTPUT,
				@language = @language,
				@SystemID = @SystemID,
				@creator = @creator

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
		SELECT @ErrCode = 101		
		RETURN
	END

	--check for allow play horseracing
	

	DECLARE @HideKeno BIT, @HideGoldDeluxe  BIT
			

	SELECT @HideKeno = 0 --Enable Keno by default for all sites

	SELECT @HideGoldDeluxe = 0 -- 20151001@Elodie: Set HideGoldDeluxe = 0, DisableGoldDeluxe = 0 for real super
		
	DECLARE @autosuspend BIT,
			@autosuspend2 BIT

	SET @autosuspend = 0
	SET @autosuspend2 = 0

	--Insert general info
	EXEC dbo.Acc_CustomerInsUserInfo 
		@custid = @custid OUTPUT,
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
		@email = @email,
		@fax = @fax,
		@address = @address,
		@city = @city,
		@state = @state,
		@country = @country,
		@postal = @postal,
		@TransferOption = NULL,
		@suspended = 0,
		@SystemID=@SystemID,
		@autosuspend = @autosuspend,
		@autosuspend2 = @autosuspend2,		
		@matchlimit = 1,
		--@Johnson: Disable virtual rate status as default
		@virtualmultiplier = 0,	
	
		
	
		@DisableCasino = @DisableCasino,
		@DisableNumber = @DisableNumber,
		@DoubleCommLosing = @DoubleCommLosing,		
		
		@DisableGoldDeluxe = @DisableGoldDeluxe,
		@HideGoldDeluxe = @HideGoldDeluxe,
		
		@DisableSuperLive = @DisableSuperLive,

		@MaxPerMatch = @MaxPerMatch,
		@MaxPerMatchv2 = @MaxPerMatchv2,
		@MaxPerMatchv3 = @MaxPerMatchv3,
		@MaxPerMatchv5 = @MaxPerMatchv5,
		@MaxPerMatchv8 = @MaxPerMatchv8,
		@MaxPerMatchv10 = @MaxPerMatchv10,
		@MaxPerMatchv11 = @MaxPerMatchv11,
		@MaxPerMatchv99 = @MaxPerMatchv99,
		@MaxPerMatchv99MP = @MaxPerMatchv99MP,
		
		@MaxPerMatchv1MP = @MaxPerMatchv1MP,
		@MaxPerMatchv161 = @MaxPerMatchv161,	
		@MaxPerBallv161 = @MaxPerBallv161,	
		@MaxPerMatchv164 = @MaxPerMatchv164,
		--keno
		@HideKeno = @HideKeno,

		@credit = @credit,
		@maxcredit = NULL,
		@IP = @IP,
		@isinternal = @isinternal,
		@TransferOption_dec = NULL,
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	--Error occurs
	IF @ErrCode <> 0
		RETURN

	--insert max win limit
EXEC dbo.Acc_CustomerWinLimitIns @CustId = @custid
	, @UplineId = NULL --for super livel
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
		@roleid = 4,
		
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
		--v161
		@v161apositiontaking_81 = @v161apositiontaking_81,
		@v161apositiontaking_83 = @v161apositiontaking_83,
		
		@v161apositiontaking_86 = @v161apositiontaking_86,
		@v161apositiontaking_88 = @v161apositiontaking_88,
		@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
		@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
		@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
		@v161alivepositiontaking_89 = @v161alivepositiontaking_89,
		@v161alivepositiontaking_90 = @v161alivepositiontaking_90,
						
		@MinBet = @MinBet,
		@MaxBet = @MaxBet,	
		@MinBetv2 = @MinBetv2,
		@MaxBetv2 = @MaxBetv2,		
		@MinBetv3 = @MinBetv3,
		@MaxBetv3 = @MaxBetv3,	
		@MinBetv5 = @MinBetv5,
		@MaxBetv5 = @MaxBetv5,	
		@MinBetv8 = @MinBetv8,
		@MaxBetv8 = @MaxBetv8,	
		@MinBetv10 = @MinBetv10,
		@MaxBetv10 = @MaxBetv10,	
		@MinBetv11 = @MinBetv11,
		@MaxBetv11 = @MaxBetv11,	
		@MinBetv99 = @MinBetv99,
		@MaxBetv99 = @MaxBetv99,		
		--Mix Parlay mix sports
		@MinBetv99MP = @MinBetv99MP,
		@MaxBetv99MP = @MaxBetv99MP,		
		
		--Mix Parlay Soccer sports
		@MinBetv1MP = @MinBetv1MP,
		@MaxBetv1MP = @MaxBetv1MP,	

		--Number game
		@MinBetv161 = @MinBetv161,
		@MaxBetv161 = @MaxBetv161,	
		
		@MinBetv164 = @MinBetv164,
		@MaxBetv164 = @MaxBetv164,
		
		@discountcs = @discountcs, 
		--comm 1x2
		@discount1x2 = @discount1x2,
	
		@ErrCode = @ErrCode OUTPUT

	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustId = @CustId
		RETURN
	END	

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	DECLARE @MaxMemberLog VARCHAR(50)
	SELECT @MaxMemberLog = CASE WHEN @Site = '789y' THEN '20000' ELSE 'Unlimited' END

	DECLARE @LogSPData VARCHAR(MAX)
	--Write general info
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +

	'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)),SPACE(1))) + '" ' +
	'postal="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)),SPACE(1))) + '" ' +
	'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)),SPACE(1))) + '" ' +
	'state="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)),SPACE(1))) + '" ' +
	'country="'+ COALESCE(CAST(@country AS VARCHAR(100)),SPACE(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)),SPACE(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
	'refcode1="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@refcode1 AS VARCHAR(100)),SPACE(1))) + '" ' +
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

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 600,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +

		'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
		'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)),SPACE(1))) + '" ' +
		'postal="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)),SPACE(1))) + '" ' +
		'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)),SPACE(1))) + '" ' +
		'state="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)),SPACE(1))) + '" ' +
		'country="'+ COALESCE(CAST(@country AS VARCHAR(100)),SPACE(1)) + '" ' +
		'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
		'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)),SPACE(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
		'refcode1="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@refcode1 AS VARCHAR(100)),SPACE(1))) + '" ' +
		'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)),SPACE(1)) + '" ' +
		'username="'+ COALESCE(CAST(@username AS VARCHAR(20)),SPACE(1)) + '" ' +
		'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +
		'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
		'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 600,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

	--Write commission log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" '  +
	'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)),SPACE(1)) + '" ' 

	SET @LogSPData = @LogSPData + 
		'groupb="' + COALESCE(CAST(@groupb AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupc="' + COALESCE(CAST(@groupc AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupd="' + COALESCE(CAST(@groupd AS VARCHAR(50)),SPACE(1)) + '" ' 

	SET @LogSPData = @LogSPData + 
	'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)),SPACE(1)) + '" ' +
	'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)),SPACE(1)) + '" ' 

	SET @LogSPData = @LogSPData + ' />'


	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 200,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)),SPACE(1)) + '" ' 
		
		SET @LogSPData = @LogSPData +
		'groupb="'+ COALESCE(CAST(@groupb AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupc="'+ COALESCE(CAST(@groupc AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupd="'+ COALESCE(CAST(@groupd AS VARCHAR(50)),SPACE(1)) + '" ' 
		SET @LogSPData = @LogSPData +
		'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)),SPACE(1)) + '" ' +
		'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)),SPACE(1)) + '" ' 	

		SET @LogSPData = @LogSPData + 'ErrMsg="'+ ERROR_MESSAGE() +	'" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 200,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH

	--Write status log
	--Get data prepare write log for Keno
	DECLARE @LogDataKeno NVARCHAR(4000) = '', @isDisableKeno BIT

	SELECT @isDisableKeno = 0 --Enable Keno by default for all sites

	SELECT @LogDataKeno = COALESCE(@LogDataKeno + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
		+ '=' + '"' + CAST(@isDisableKeno AS VARCHAR(1)) + '"' + SPACE(1), + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
		+ '=' + '"' + CAST(@isDisableKeno AS VARCHAR(1)) + '"' + SPACE(1))
	FROM @tmp_GameType gt
	WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0

	SET @LogDataKeno = 'HideKeno="'+ COALESCE(CAST(@HideKeno AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno

	DECLARE @LogDataSP2 VARCHAR(4000)
	
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	INTO #temSportbettypeSetting
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13)
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @CustID

	SET @LogDataSP2 = ''

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' +  REPLACE(REPLACE(p.ProductName, ' ', ''),'*','') + '="' + COALESCE(CAST(iq.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM DBPRO.bodb02.dbo.Products p WITH (NOLOCK)
		INNER JOIN (SELECT psd.ProductID, MIN(CAST(dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) AS INT)) AS custIsHidden
					FROM ProductSettingDetail psd WITH(NOLOCK)
						INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
																			AND	psd.BetType = psp.Bettype
																			AND psd.SettingType IN (4,11,13)		-- Product Status
						INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
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

	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	--20171205@Johnson: add more log for status
	'Special=" " ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +	
	
	'disableCasino="'+ COALESCE(CAST(@disableCasino AS VARCHAR(1)),SPACE(1)) + '" ' +
	'disablenumber="'+ COALESCE(CAST(@disablenumber AS VARCHAR(1)),SPACE(1)) + '" ' +

	
	'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +

	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)),SPACE(1)) + '" ' +
	 @LogDataKeno + @LogDataSP2 +
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" />'

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 1100,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		--20171205@Johnson: add more log for status
		'Special=" " ' +
		'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'virtualmultiplier="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	
		'disableCasino="'+ COALESCE(CAST(@disableCasino AS VARCHAR(1)),SPACE(1)) + '" ' +
		'disablenumber="'+ COALESCE(CAST(@disablenumber AS VARCHAR(1)),SPACE(1)) + '" ' +
		
		'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
		
		'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)),SPACE(1)) + '" ' +		
		'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' + @LogDataKeno + @LogDataSP2 +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 1100,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

	--Write Bet setting log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv164="'+ COALESCE(CAST(@MinBetv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv164="'+ COALESCE(CAST(@MaxBetv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv164="'+ COALESCE(CAST(@MaxPerMatchv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPBv161="' + COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)),SPACE(1)) + '" />' 

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 300,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'MinBv164="'+ COALESCE(CAST(@MinBetv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv164="'+ COALESCE(CAST(@MaxBetv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv164="'+ COALESCE(CAST(@MaxPerMatchv164 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPBv161="' + COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="' + ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 300,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

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
	
	--Write PT log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com><s spt_1="'+ COALESCE(CAST(@spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_2="'+ COALESCE(CAST(@spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_3="'+ COALESCE(CAST(@spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_4="'+ COALESCE(CAST(@spositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_5="'+ COALESCE(CAST(@spositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_6="'+ COALESCE(CAST(@spositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_7="'+ COALESCE(CAST(@spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_8="'+ COALESCE(CAST(@spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_9="'+ COALESCE(CAST(@spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_10="'+ COALESCE(CAST(@spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_10="'+ COALESCE(CAST(@v2spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_10="'+ COALESCE(CAST(@v3spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_10="'+ COALESCE(CAST(@v5spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_10="'+ COALESCE(CAST(@v8spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_10="'+ COALESCE(CAST(@v10spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11spt_10="'+ COALESCE(CAST(@v11spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_10="'+ COALESCE(CAST(@v99spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_9999="'+ COALESCE(CAST(@spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_1="'+ COALESCE(CAST(@slivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_3="'+ COALESCE(CAST(@slivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_7="'+ COALESCE(CAST(@slivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_8="'+ COALESCE(CAST(@slivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2spt_1="'+ COALESCE(CAST(@v2spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_2="'+ COALESCE(CAST(@v2spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_3="'+ COALESCE(CAST(@v2spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_7="'+ COALESCE(CAST(@v2spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_8="'+ COALESCE(CAST(@v2spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v2spt_20="'+ COALESCE(CAST(@v2spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--BAIO
	'v2spt_9999="'+ COALESCE(CAST(@v2spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3spt_1="'+ COALESCE(CAST(@v3spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_2="'+ COALESCE(CAST(@v3spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_3="'+ COALESCE(CAST(@v3spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_20="'+ COALESCE(CAST(@v3spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5spt_1="'+ COALESCE(CAST(@v5spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_2="'+ COALESCE(CAST(@v5spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_3="'+ COALESCE(CAST(@v5spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_20="'+ COALESCE(CAST(@v5spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_9999="'+ COALESCE(CAST(@v5spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8spt_1="'+ COALESCE(CAST(@v8spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_3="'+ COALESCE(CAST(@v8spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_20="'+ COALESCE(CAST(@v8spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10spt_1="'+ COALESCE(CAST(@v10spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_2="'+ COALESCE(CAST(@v10spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_3="'+ COALESCE(CAST(@v10spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_20="'+ COALESCE(CAST(@v10spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11spt_1="'+ COALESCE(CAST(@v11spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11spt_20="'+ COALESCE(CAST(@v11spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99spt_1="'+ COALESCE(CAST(@v99spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_2="'+ COALESCE(CAST(@v99spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_3="'+ COALESCE(CAST(@v99spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_9="'+ COALESCE(CAST(@v99spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_20="'+ COALESCE(CAST(@v99spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_9999="'+ COALESCE(CAST(@v99spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v161spt_81="'+ COALESCE(CAST(@v161spositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161spt_83="'+ COALESCE(CAST(@v161spositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v161spt_86="'+ COALESCE(CAST(@v161spositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161spt_88="'+ COALESCE(CAST(@v161spositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_85="'+ COALESCE(CAST(@v161slivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_86="'+ COALESCE(CAST(@v161slivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_87="'+ COALESCE(CAST(@v161slivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_89="'+ COALESCE(CAST(@v161slivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_90="'+ COALESCE(CAST(@v161slivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


	'<m mpt_1="'+ COALESCE(CAST(@mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_2="'+ COALESCE(CAST(@mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_3="'+ COALESCE(CAST(@mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_4="'+ COALESCE(CAST(@mpositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_5="'+ COALESCE(CAST(@mpositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_6="'+ COALESCE(CAST(@mpositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_7="'+ COALESCE(CAST(@mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_8="'+ COALESCE(CAST(@mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_9="'+ COALESCE(CAST(@mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_10="'+ COALESCE(CAST(@mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_10="'+ COALESCE(CAST(@v2mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_10="'+ COALESCE(CAST(@v3mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_10="'+ COALESCE(CAST(@v5mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_10="'+ COALESCE(CAST(@v8mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_10="'+ COALESCE(CAST(@v10mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11mpt_10="'+ COALESCE(CAST(@v11mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_10="'+ COALESCE(CAST(@v99mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_9999="'+ COALESCE(CAST(@mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_1="'+ COALESCE(CAST(@mlivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_3="'+ COALESCE(CAST(@mlivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_7="'+ COALESCE(CAST(@mlivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_8="'+ COALESCE(CAST(@mlivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2mpt_1="'+ COALESCE(CAST(@v2mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_2="'+ COALESCE(CAST(@v2mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_3="'+ COALESCE(CAST(@v2mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_7="'+ COALESCE(CAST(@v2mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_8="'+ COALESCE(CAST(@v2mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v2mpt_20="'+ COALESCE(CAST(@v2mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--BAIO 
	'v2mpt_9999="'+ COALESCE(CAST(@v2mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3mpt_1="'+ COALESCE(CAST(@v3mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_2="'+ COALESCE(CAST(@v3mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_3="'+ COALESCE(CAST(@v3mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_20="'+ COALESCE(CAST(@v3mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5mpt_1="'+ COALESCE(CAST(@v5mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_2="'+ COALESCE(CAST(@v5mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_3="'+ COALESCE(CAST(@v5mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_20="'+ COALESCE(CAST(@v5mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_9999="'+ COALESCE(CAST(@v5mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8mpt_1="'+ COALESCE(CAST(@v8mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_3="'+ COALESCE(CAST(@v8mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_20="'+ COALESCE(CAST(@v8mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10mpt_1="'+ COALESCE(CAST(@v10mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_2="'+ COALESCE(CAST(@v10mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_3="'+ COALESCE(CAST(@v10mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_20="'+ COALESCE(CAST(@v10mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11mpt_1="'+ COALESCE(CAST(@v11mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11mpt_20="'+ COALESCE(CAST(@v11mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99mpt_1="'+ COALESCE(CAST(@v99mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_2="'+ COALESCE(CAST(@v99mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_3="'+ COALESCE(CAST(@v99mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_9="'+ COALESCE(CAST(@v99mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_20="'+ COALESCE(CAST(@v99mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_9999="'+ COALESCE(CAST(@v99mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mpt_81="'+ COALESCE(CAST(@v161mpositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mpt_83="'+ COALESCE(CAST(@v161mpositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v161mpt_86="'+ COALESCE(CAST(@v161mpositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mpt_88="'+ COALESCE(CAST(@v161mpositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_85="'+ COALESCE(CAST(@v161mlivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_86="'+ COALESCE(CAST(@v161mlivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_87="'+ COALESCE(CAST(@v161mlivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_89="'+ COALESCE(CAST(@v161mlivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_90="'+ COALESCE(CAST(@v161mlivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


	'<ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	-- BAIO
	'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_9999="'+ COALESCE(CAST(@v99apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" /></Acc_CustomerInsMember_Com>' 

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 400,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH

		SELECT @LogSPData = '<Acc_CustomerInsMember_Com><s spt_1="'+ COALESCE(CAST(@spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_2="'+ COALESCE(CAST(@spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_3="'+ COALESCE(CAST(@spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_4="'+ COALESCE(CAST(@spositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_5="'+ COALESCE(CAST(@spositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_6="'+ COALESCE(CAST(@spositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_7="'+ COALESCE(CAST(@spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_8="'+ COALESCE(CAST(@spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_9="'+ COALESCE(CAST(@spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_10="'+ COALESCE(CAST(@spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_10="'+ COALESCE(CAST(@v2spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_10="'+ COALESCE(CAST(@v3spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_10="'+ COALESCE(CAST(@v5spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_10="'+ COALESCE(CAST(@v8spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_10="'+ COALESCE(CAST(@v10spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11spt_10="'+ COALESCE(CAST(@v11spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_10="'+ COALESCE(CAST(@v99spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_9999="'+ COALESCE(CAST(@spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_1="'+ COALESCE(CAST(@slivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_3="'+ COALESCE(CAST(@slivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_7="'+ COALESCE(CAST(@slivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_8="'+ COALESCE(CAST(@slivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2spt_1="'+ COALESCE(CAST(@v2spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_2="'+ COALESCE(CAST(@v2spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_3="'+ COALESCE(CAST(@v2spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_7="'+ COALESCE(CAST(@v2spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_8="'+ COALESCE(CAST(@v2spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v2spt_20="'+ COALESCE(CAST(@v2spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		-- BAIO
		'v2spt_9999="'+ COALESCE(CAST(@v2spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3spt_1="'+ COALESCE(CAST(@v3spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_2="'+ COALESCE(CAST(@v3spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_3="'+ COALESCE(CAST(@v3spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_20="'+ COALESCE(CAST(@v3spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5spt_1="'+ COALESCE(CAST(@v5spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_2="'+ COALESCE(CAST(@v5spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_3="'+ COALESCE(CAST(@v5spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_20="'+ COALESCE(CAST(@v5spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_9999="'+ COALESCE(CAST(@v5spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8spt_1="'+ COALESCE(CAST(@v8spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_3="'+ COALESCE(CAST(@v8spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_20="'+ COALESCE(CAST(@v8spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10spt_1="'+ COALESCE(CAST(@v10spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_2="'+ COALESCE(CAST(@v10spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_3="'+ COALESCE(CAST(@v10spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_20="'+ COALESCE(CAST(@v10spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11spt_1="'+ COALESCE(CAST(@v11spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11spt_20="'+ COALESCE(CAST(@v11spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99spt_1="'+ COALESCE(CAST(@v99spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_2="'+ COALESCE(CAST(@v99spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_3="'+ COALESCE(CAST(@v99spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_9="'+ COALESCE(CAST(@v99spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_20="'+ COALESCE(CAST(@v99spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_9999="'+ COALESCE(CAST(@v99spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161spt_81="'+ COALESCE(CAST(@v161spositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161spt_83="'+ COALESCE(CAST(@v161spositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v161spt_86="'+ COALESCE(CAST(@v161spositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161spt_88="'+ COALESCE(CAST(@v161spositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_85="'+ COALESCE(CAST(@v161slivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_86="'+ COALESCE(CAST(@v161slivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_87="'+ COALESCE(CAST(@v161slivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_89="'+ COALESCE(CAST(@v161slivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_90="'+ COALESCE(CAST(@v161slivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


		'<m mpt_1="'+ COALESCE(CAST(@mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_2="'+ COALESCE(CAST(@mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_3="'+ COALESCE(CAST(@mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_4="'+ COALESCE(CAST(@mpositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_5="'+ COALESCE(CAST(@mpositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_6="'+ COALESCE(CAST(@mpositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_7="'+ COALESCE(CAST(@mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_8="'+ COALESCE(CAST(@mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_9="'+ COALESCE(CAST(@mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_10="'+ COALESCE(CAST(@mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_10="'+ COALESCE(CAST(@v2mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_10="'+ COALESCE(CAST(@v3mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_10="'+ COALESCE(CAST(@v5mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_10="'+ COALESCE(CAST(@v8mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_10="'+ COALESCE(CAST(@v10mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11mpt_10="'+ COALESCE(CAST(@v11mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_10="'+ COALESCE(CAST(@v99mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_9999="'+ COALESCE(CAST(@mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_1="'+ COALESCE(CAST(@mlivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_3="'+ COALESCE(CAST(@mlivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_7="'+ COALESCE(CAST(@mlivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_8="'+ COALESCE(CAST(@mlivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2mpt_1="'+ COALESCE(CAST(@v2mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_2="'+ COALESCE(CAST(@v2mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_3="'+ COALESCE(CAST(@v2mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_7="'+ COALESCE(CAST(@v2mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_8="'+ COALESCE(CAST(@v2mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v2mpt_20="'+ COALESCE(CAST(@v2mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--BAIO
		'v2mpt_9999="'+ COALESCE(CAST(@v2mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3mpt_1="'+ COALESCE(CAST(@v3mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_2="'+ COALESCE(CAST(@v3mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_3="'+ COALESCE(CAST(@v3mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_20="'+ COALESCE(CAST(@v3mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5mpt_1="'+ COALESCE(CAST(@v5mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_2="'+ COALESCE(CAST(@v5mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_3="'+ COALESCE(CAST(@v5mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_20="'+ COALESCE(CAST(@v5mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_9999="'+ COALESCE(CAST(@v5mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8mpt_1="'+ COALESCE(CAST(@v8mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_3="'+ COALESCE(CAST(@v8mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_20="'+ COALESCE(CAST(@v8mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10mpt_1="'+ COALESCE(CAST(@v10mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_2="'+ COALESCE(CAST(@v10mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_3="'+ COALESCE(CAST(@v10mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_20="'+ COALESCE(CAST(@v10mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11mpt_1="'+ COALESCE(CAST(@v11mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11mpt_20="'+ COALESCE(CAST(@v11mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99mpt_1="'+ COALESCE(CAST(@v99mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_2="'+ COALESCE(CAST(@v99mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_3="'+ COALESCE(CAST(@v99mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_9="'+ COALESCE(CAST(@v99mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_20="'+ COALESCE(CAST(@v99mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_9999="'+ COALESCE(CAST(@v99mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161mpt_81="'+ COALESCE(CAST(@v161mpositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mpt_83="'+ COALESCE(CAST(@v161mpositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v161mpt_86="'+ COALESCE(CAST(@v161mpositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mpt_88="'+ COALESCE(CAST(@v161mpositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_85="'+ COALESCE(CAST(@v161mlivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_86="'+ COALESCE(CAST(@v161mlivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_87="'+ COALESCE(CAST(@v161mlivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_89="'+ COALESCE(CAST(@v161mlivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_90="'+ COALESCE(CAST(@v161mlivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


		'<ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--BAIO
		'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_9999="'+ COALESCE(CAST(@v99apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" /></Acc_CustomerInsMember_Com>' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 400,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH
END
GO

