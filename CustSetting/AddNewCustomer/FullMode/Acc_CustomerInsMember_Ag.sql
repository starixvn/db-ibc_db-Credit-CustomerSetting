/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Ag]
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@phone NVARCHAR(50),
	@fax NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@playerdiscount DECIMAL(9, 8), 
	@playerdiscountcs DECIMAL(9, 8),
	--1x2 
	@playerdiscount1x2 DECIMAL(9, 8) = 0,
	
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
	@MinBetv1MP MONEY,
	@MaxBetv1MP MONEY,
	@MaxPerMatchv1MP MONEY,
	
	--Number game
	@MinBetv161 MONEY,
	@MaxBetv161 MONEY,
	@MaxPerBallv161 MONEY = 0,
	@MaxPerMatchv161 MONEY,
	
	@MinBetv164 MONEY =0,
	@MaxBetv164 MONEY=0,	
	@MaxPerMatchv164 MONEY=0,

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
		
	@DisableNumber BIT = 0,	

	--@Disable180_1201 BIT = 0,
	
	@recommend INT,
	@ugroup VARCHAR(5),
	@closed BIT,
			
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
	
	--@v2apositiontaking_9 SMALLMONEY=0,
	
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
	@v99apositiontaking_9 SMALLMONEY,
	@v99apositiontaking_20 SMALLMONEY,
	@v99apositiontaking_9999 SMALLMONEY,
	
	@v161apositiontaking_81 SMALLMONEY, 
	@v161apositiontaking_83 SMALLMONEY, 
	@v161apositiontaking_86 SMALLMONEY, 
	@v161apositiontaking_88 SMALLMONEY = 0, 
	@v161alivepositiontaking_85 SMALLMONEY,
	@v161alivepositiontaking_86 SMALLMONEY,
	@v161alivepositiontaking_87 SMALLMONEY,
	@v161alivepositiontaking_89 SMALLMONEY = 0,
	@v161alivepositiontaking_90 SMALLMONEY = 0,

	-- MyanmarOdds
	@playerdiscountMyanmarOdds DECIMAL(9,8)=0,
	
	@IP 			VARCHAR(15)='',
	@SystemID		TINYINT=1,
	@CreatedMode 	TINYINT = 0,
	@success 		BIT = 1 OUTPUT,
	@Language 		VARCHAR(2)= 'E',
	@SubAccID 		INT = 0, --Sub-AccountID
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,
	@ErrCode 		INT = 0 OUTPUT,
	@ErrMsg 		NVARCHAR(4000) = '' OUTPUT	,
	@IsQRCode 		BIT  = 0,
	@SettingStatus 	TINYINT = 0
AS
--@Source Control
/*
Created: 20090121@Thien
Task :  Add new member
		AgentSite-AccountingSite\add new member
DB: DBCUST/CustDB
Original:  Run in Dot_Dep_CustomerInsMember_Ag
Revisions:
    - 20081009@Phuc: Auto Master PT  
	- 20081022@Phuc: Add new sporttype 201, bettype 3
	- 20081022@Phuc: Hard code copy min/max/maxperbet/PT for 201 FROM 2 sporttype will remove WHEN deploy FI
	- 20090121@PhuongBich: Add new bettype 2(sporttype 201)
	- 20090122@PhuongNguyen: Remove userpwd FROM log writing
	- 20090218@PhuongDao: Check username2 	
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission.
	- 20090403@Phuc: hard code default values for sporttype 201 bettype 2
	- 20090407@Phuc: IF DisableFinancial (upline OR webconfig) set a1 = n2; get minbet201, maxbet201, maxpermatch201 FROM upline
	- 20090417@PhuongDao: Set default virtualrate = 0% 
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote AND Fixed 
    - 20090521@PhuongDao: 
			+ Remove HR Min-Max BET
			+ Use maxcredit in CustAgent instead of Custinfo table AND not to insert maxcredit on custinfo  
	- 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access AND check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Simon: Write Credit Log INTo Userlog_Credit table.
	- 20090917@Phuc: write log INTo DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status FROM the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Phuc: hardcode commission for member under 8RM agent.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: invoke execute permission to [bodbExtAccNet]
	- 20100828@Henry: remove mix parlay of basketball + add new section for MixParlay for Mix Sports + Setting for Numbergame
	- 20100909@Jamie: + Add param @DisableCasino 
					  + Remove param @DisableFinancial_WC 
	- 20101019@Henry: Record execution time
	- 20101029@Johnson: Include max per ball for number game
	-20110103@Johnson: Add setting for HR AU, Greyhound, Harness  
	- 20110504@Johnson: copy Danger's setting FROM upline
	- 20110520@Johnson: Allow spaces between words in user name WHEN creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20110819@Jamie: Get Next Combo, Number Group for checking message error
	- 20110822@Tom: Add P2P setting
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20110929@Johnson: Check group for adding new member under Won currency
	- 20111020@Sophia: Create balance for new customer
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@error for inserting balance table AND P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (FROM upline)
	- 20111226@Lukas: Add Live casino game - PT setting
	- 20120210@TOM: Insert default value of P2P Comm
	- 20120412@Hurri: hardcode commission for member under BARM agent
	- 20120413@Dan: add parameter @isSearchAndCopy to write log to know whether a customer was created FROM "Search AND Copy" function OR not (Full mode)
	- 20120502@Johnson: Correct tracking value for number game
	- 20120502@Lukas: Encode XML values in logging
	- 20120522@Sophia: Remove hardcode commission for member under BARM agent
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120710@Johnson: Add virtual soccer's setting
	- 20120823@Elodie: Add Abnormal field
	- 20120827@Johnson: Check a1 with min(a2,a4) AND m1 with min(m4-a1,m3-a1,l3-a1)
	- 20120925@Dan: add win limit setting for live casino
	- 20120928@Johnson: add double comm losing status
	- 20121128@Elodie: Get an error message FROM f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in CASE of DBLOG server failure
	- 20130219@Johnson: add virtual horse racing setting (sporttype : 181, bettype: 1321)
	- 20130403@Jamie: Check Recommend <> MRecommend AND <> Srecommend OR NOT
	- 20130813@Johnson: correct racing pt setting WHEN add new member
	- 20130717@Lukas: get code FROM production - limit created customers in a minute
	- 20130731@Elodie: Apply progressive bonus
	- 20130905@Lukas: restrict new customers created: 100 customers per 10 minutes
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend INTo Soccer AND Other Sport [Redmine:#5520] 
	- 20131107@Johnson: Apply execrep WHEN insert setting INTo custsetting/custsetting3rd	
	- 20131108@Elodie: Splitting bodb02 INTo CustDB (call sport, bettype by link database)
					   Insert/Delete BalanceCredit, BalanceDebit, BalanceCreditGame, BalanceDebitGame by link database
	- 20131121@Kathy: Add Virtual Greyhounds, Virtual Motor Racing (182, 184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140318@Patrick: Modify log for Keno status
	- 20140331@Sophia: Remove Fi sporttype = 201
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20140425@Logan: Check Limit of Newly Created Member Per Day of Super Agent 
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20140731@Logan: Add execrep for Keno [Redmine: #13156]
	- 20140822@Logan: Add status & log for E-Sports [Redmine: #20531]
	- 20141113@Johnson: Hardcode agent list not give commission for downlines [Redmine #25787]
	- 20141204@Johnson: Add new country Korea[bettype= 1514] for Keno [Redmine: #26647]
	- 20150113@Johnson: Separate virtual rate by sporttype, bettype [Redmine: #25840]				
	- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	- 20150601@Elodie: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150710@Patrick: Remove insert default balance value for Credit/Debit Game & insert max winlimit
	- 20150909@Elodie: Remove copying Virtual Rate setting from function Search and Copy [Redmine:#42976]                
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151013@Elodie: Balance Improvement [Redmine:#40125]
	- 20151104@Billy: Add Disable and Hide SB2 to log initial status [Redmine: #46833]
	- 20151217@Helen: Creating Disable and Hide Product dynamically - [Redmine:#48602] 
	- 20160120@Lukas: add checking constraint on prefix of username of new customer - [Redmine: #51169]
	- 20151223@Patrick: Add Max/Loss limit for RnG Casino [Redmine: #49528]
	- 20160215@Dominic: Cricket is not showed in log for MBC customers [Redmine: #52158]
	- 20160222@Dominic: Log initial status is blank [Redmine: #52657]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:#66265]
	- 20161222@Winnie: Copy Outright, ColossusBet, SuperLive status from copied member - [Redmine:#68879]
	- 20161223@Winnie: Hot Fix  Show Fishing World logs although this Product is not released to PROD yet [Redmine:69236]
	- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]					
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170620@Winnie: Apply color for closed account - [RedmineID: 74494]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20171206@Johnson: add more log for special, doublecomm, autosuspend status [Redmine: #87121]
	- 20171208@Vicky: set comm of sportbook = 0 if agent of member exists in table CustNoComm [RedmineID: #87758]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180703@viet: normal agent can create upto 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit member each minute. Normal agent can open up to 10 members per minute
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]
	- 20180924@Phillip: NAP - Allow Admin user to create more than 10 member per minute. [RedmineID: #101967]
	- 20181002@Elodie: Limit max members creation per Super. [RedmineID: #101994]
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]  
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526]
	- 20181205@Kan: Write @SystemID param into log [Redmine:104431]
	- 20181102@Johnson: Apply service broker for logging [Redmine: #103547]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190510@Johnson: remove suspend status on setting page [redmine: #105587]
	- 20190816@Johnson: copy reject status from source member for search & copy [redmine:#118736]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200309@Eden: Alpha - New function to let new member sign in via QR Code [Redmine: #129373]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201027@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210308@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210319@Winfred: Check Site to limit create accounts [Redmine: #151526]
	- 20210324@Johnson: Hide GoldDeluxe settings [redmine:#151188]
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600] 
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20220222@Elodie: Default VR for 789y site [Redmine: #168885]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20230217@Johnson: Telegram chatbot - clone account systemID = 10 [Redmine: #183697]
	- 20230302@Johnson: add auto suspend for Basketball[redmine: #184339]	
	
Param's Explanation:	
• @ErrCode:
    = 0: add new member successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
- @SettingStatus: 0: Pro, 1: UAT
- @CreatedMode: = 0: single customer
				= 1: multiple customers
*/
BEGIN
    SET NOCOUNT ON

	EXEC [Acc_CheckUM] @CustID = @recommend
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
/*
----- viet @ 15 JUL 2013 -------------------
	declare @lastMinuteMemberCount INT
	
	IF @recommend in (6201735, 11656507, 3645795, 3645796) -- Viet: to create hedge accounts for OP
	BEGIN
		SET @lastMinuteMemberCount = 0
	END
	ELSE
	BEGIN
		SELECT @lastMinuteMemberCount = COUNT(1)
		FROM Customer WITH(NOLOCK)
		WHERE recommend = @recommend
			and roleid = 1
			and creatdate > dateadd(minute, -10, CURRENT_TIMESTAMP)
	END		
	IF @lastMinuteMemberCount > 100
	BEGIN
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Sorry. You cannot create member too often.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language)
					end,
				@success = 0, @ErrCode = 998
		return
	END

----- / viet @ 15 JUL 2013 -----------------
*/
	
-----BEGIN: 20180703@viet: normal agent can create up to 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit member each minute
	DECLARE @mrecommend int, @RestrictedCredit money = 100
	IF @credit < @RestrictedCredit
	BEGIN
		--Restricted Agent, can open up to 1 low-credit member each minute--------------
		IF EXISTS(SELECT 1 from dbo.f_RestrictedRobotAgents('agent') WHERE custid = @recommend)
		BEGIN
			SELECT TOP (1) @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE roleid =1 and recommend = @recommend 
			ORDER BY custid desc
		
			IF (@success = 0) -- not allow	
			BEGIN		
				Select	@ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Sorry. You cannot create member too often.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language)
							end,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END 	
	
		--Restricted Master, can open up to 1 low-credit member each minute--------------
		SELECT @mrecommend=mrecommend FROM dbo.customer WITH(NOLOCK) WHERE custid = @recommend
		IF EXISTS(SELECT 1 from dbo.f_RestrictedRobotAgents('master') WHERE custid = @mrecommend)
		BEGIN
			SELECT TOP (1) @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE roleid =1 and mrecommend = @mrecommend 
			ORDER BY custid desc

			IF (@success = 0) -- not allow	
			BEGIN		
				Select	@ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Sorry. You cannot create member too often.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language)
							end,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END
	END

	IF @SystemID <> 1 AND @recommend NOT IN (6201735, 11656507, 3645795, 3645796) -- internal agents: allow to create member freely
	BEGIN -- can create upto 10 members / min
		DECLARE @result_top10 as TABLE (custid int)
		INSERT INTO @result_top10 (custid)
		SELECT TOP (10) custid
		FROM Customer WITH(NOLOCK)
		WHERE recommend = @recommend
			and roleid = 1
		ORDER BY custid DESC
	
		IF @@ROWCOUNT = 10
		BEGIN
			SELECT @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE custid IN (SELECT min(custid) FROM @result_top10)

			IF (@success = 0) -- not allow	
			BEGIN		
				Select	@ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Sorry. You cannot create member too often.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language)
							end,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END	
	END
-----END: 20180703@viet: normal agent can create upto 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit-member each minute. Normal agent can open up to 10 members per minute
	DECLARE @_Site VARCHAR(10), @EnableVR BIT
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @recommend
	
	DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0 , @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@_Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.recommend = @recommend
									AND c.roleid = 1
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056	
			return
		END
	END

--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP BIT
	
	/*
	EXEC Acc_CustomerInsMember_CheckIP 
		@IP = @IP,
		@isValid = @isValidIP OUTPUT
	*/
	IF @credit = 0 and
			@IP IN ('115.77.62.87', '124.248.244.56', '116.100.7.95'
			--20140626@Thien:
			,'183.91.31.31', '115.77.62.87', '42.117.7.217','203.113.172.148', '42.112.19.168'
			, '124.248.229.174', '118.69.77.60', '123.103.252.62'
			
			--20140627@Thien:
			,'116.100.7.95', '118.142.46.201', '118.69.174.108', '42.117.4.151', '122.117.7.217'
			
			--20140628@Thien:
			,'123.103.241.62', '203.113.173.121', '123.103.241.62'
			
			--20140630@Thien:
			,'61.8.32.91', '115.78.234.153'
			
			--20140701@Thien:
			,'14.169.66.152'
					)
		SELECT @isValidIP = 0 
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline OR CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
    --End check IP--------------------------------------------------

	-----20160120@Lukas  ------------------
	---- check constraint on prefix username same as upline in case of creating member from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @recommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @recommend

		IF LEFT(@username,LEN(@uplineUsername)) <> @uplineUsername
		BEGIN			
			SELECT @ErrMsg = CASE @Language
						    WHEN 'E' THEN 'This function is under maintenance and not available at the moment. Please kindly check back later. Thank you!'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](90011, @Language)
					     END,
				   @success = 0,
				   @ErrCode = 101
			RETURN
		END
	END 
	-----/20160120@Lukas -----------------
	
    declare @startRun datetime
    declare @endRun datetime
    declare @duration INT
    set @startRun = getdate()

    --20080514: Not allow agent LIM open new member (By Wan)
    IF @recommend in (920145)
    BEGIN
	    SELECT	@ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Sorry. You cannot create more member.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40016,@Language)
					    END,
			    @success = 0, @ErrCode = 999
	    return
    END        

    --Check an account disabled OR not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @recommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0	RETURN 

	--Check Limit max members creation per Super
	IF @SystemID <> 1
	BEGIN
		EXEC Age_MaxMemberLimitBySuperCheck @AgentId = @recommend, @Language = @Language, @ErrMsg = @ErrMsg OUTPUT, @ErrCode = @ErrCode OUTPUT
		IF @ErrCode <> 0 RETURN
	END

    declare @transcode bigint, @currency INT, @pwdexpiry datetime, @srecommend INT,
    	
	    @AgentCredit MONEY, @Credit_AllOtherMember MONEY,
	    @MaxCredit_Mem MONEY,
	    @Asuspended BIT,
	    @UplineClosed BIT,
	    @DisableOutright BIT,	   
		@suspended BIT = 0,
		
	    @AgentDanger tinyint,
	    @AgentDanger2 tinyint,
	    @AgentDanger3 tinyint,
		@AgentDanger4 tinyint,
	    @AgentDanger5 tinyint,
	    @AgentAbnormal tinyint,
    	
	    -- check autosuspend's upline
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@autosuspend3 BIT,

	    --m2
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
	    @v99mpositiontaking_9 SMALLMONEY,
	    @v99mpositiontaking_20 SMALLMONEY,
		@v99mpositiontaking_9999 SMALLMONEY,
    	
    	
	    @v161mpositiontaking_81 SMALLMONEY, 
	    @v161mpositiontaking_83 SMALLMONEY, 
	    @v161mpositiontaking_86 SMALLMONEY, 
	    @v161mpositiontaking_88 SMALLMONEY, 
	    @v161mlivepositiontaking_85 SMALLMONEY,
	    @v161mlivepositiontaking_86 SMALLMONEY,
	    @v161mlivepositiontaking_87 SMALLMONEY,
	    @v161mlivepositiontaking_89 SMALLMONEY,
	    @v161mlivepositiontaking_90 SMALLMONEY,    	
	 
	    @v202mpositiontaking_1501 SMALLMONEY,
	    @v202mpositiontaking_1503 SMALLMONEY,
	    @v202mpositiontaking_1504 SMALLMONEY,
	    @v202mpositiontaking_1505 SMALLMONEY,
	    @v202mpositiontaking_1507 SMALLMONEY,
	    @v202mpositiontaking_1508 SMALLMONEY,
	    @v202mpositiontaking_1509 SMALLMONEY,
	    @v202mpositiontaking_1511 SMALLMONEY,
	    @v202mpositiontaking_1513 SMALLMONEY,
	    @v202mpositiontaking_1514 SMALLMONEY,

	    --s3
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
	    @spositiontaking_9999 SMALLMONEY,
    	
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
	    
	    @v2spositiontaking_9999 SMALLMONEY,
    	
	    @v3spositiontaking_1 SMALLMONEY,
	    @v3spositiontaking_2 SMALLMONEY,
	    @v3spositiontaking_3 SMALLMONEY,
	    @v3spositiontaking_20 SMALLMONEY,

	    @v5spositiontaking_1 SMALLMONEY,
	    @v5spositiontaking_2 SMALLMONEY,
	    @v5spositiontaking_3 SMALLMONEY,
	    @v5spositiontaking_20 SMALLMONEY,
	    @v5spositiontaking_9999 SMALLMONEY,

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
    	
	    @v161spositiontaking_81 SMALLMONEY, 
	    @v161spositiontaking_83 SMALLMONEY, 
	    @v161spositiontaking_86 SMALLMONEY, 
	    @v161spositiontaking_88 SMALLMONEY, 
	    @v161slivepositiontaking_85 SMALLMONEY,
	    @v161slivepositiontaking_86 SMALLMONEY,
	    @v161slivepositiontaking_87 SMALLMONEY,
	    @v161slivepositiontaking_89 SMALLMONEY,
	    @v161slivepositiontaking_90 SMALLMONEY,    	
	     	
	    @v202spositiontaking_1501 SMALLMONEY,
	    @v202spositiontaking_1503 SMALLMONEY,
	    @v202spositiontaking_1504 SMALLMONEY,
	    @v202spositiontaking_1505 SMALLMONEY,
	    @v202spositiontaking_1507 SMALLMONEY,
	    @v202spositiontaking_1508 SMALLMONEY,
	    @v202spositiontaking_1509 SMALLMONEY,
	    @v202spositiontaking_1511 SMALLMONEY,
	    @v202spositiontaking_1513 SMALLMONEY,
	    @v202spositiontaking_1514 SMALLMONEY,
    	
	    @adiscount DECIMAL(9, 8),
	    @adiscountcs DECIMAL(9, 8),
	    @sdiscount DECIMAL(9, 8),
	    @sdiscountcs DECIMAL(9, 8),
	    @maxdiscount DECIMAL(9, 8),
	    @maxdiscountcs DECIMAL(9, 8),
    	
	    --1x2
	    @discount1x2 DECIMAL(9, 8),
	    @adiscount1x2 DECIMAL(9, 8),
	    @sdiscount1x2 DECIMAL(9, 8),
    			
	    @site NVARCHAR(50),
	    --u3
	    @auto_spositiontaking_1 SMALLMONEY,
	    @auto_spositiontaking_2 SMALLMONEY,
	    @auto_spositiontaking_3 SMALLMONEY,
	    @auto_spositiontaking_4 SMALLMONEY,
	    @auto_spositiontaking_5 SMALLMONEY,
	    @auto_spositiontaking_6 SMALLMONEY,
	    @auto_spositiontaking_7 SMALLMONEY,
	    @auto_spositiontaking_8 SMALLMONEY,
	    @auto_spositiontaking_9 SMALLMONEY,
	    @auto_spositiontaking_10 SMALLMONEY,
	    @auto_v2spositiontaking_10 SMALLMONEY,
	    @auto_v3spositiontaking_10 SMALLMONEY,
	    @auto_v5spositiontaking_10 SMALLMONEY,
	    @auto_v8spositiontaking_10 SMALLMONEY,
	    @auto_v10spositiontaking_10 SMALLMONEY,
	    @auto_v11spositiontaking_10 SMALLMONEY,
	    @auto_v99spositiontaking_10 SMALLMONEY,
	    @auto_spositiontaking_9999 SMALLMONEY,
    	
	    @auto_slivepositiontaking_1 SMALLMONEY,
	    @auto_slivepositiontaking_3 SMALLMONEY,
	    @auto_slivepositiontaking_7 SMALLMONEY,
	    @auto_slivepositiontaking_8 SMALLMONEY,
    	
	    @auto_v2spositiontaking_1 SMALLMONEY,
	    @auto_v2spositiontaking_2 SMALLMONEY,
	    @auto_v2spositiontaking_3 SMALLMONEY,
	    @auto_v2spositiontaking_7 SMALLMONEY,
	    @auto_v2spositiontaking_8 SMALLMONEY,

	    @auto_v2spositiontaking_20 SMALLMONEY,
	    
	    @auto_v2spositiontaking_9999 SMALLMONEY,

	    @auto_v3spositiontaking_1 SMALLMONEY,
	    @auto_v3spositiontaking_2 SMALLMONEY,
	    @auto_v3spositiontaking_3 SMALLMONEY,
	    @auto_v3spositiontaking_20 SMALLMONEY,

	    @auto_v5spositiontaking_1 SMALLMONEY,
	    @auto_v5spositiontaking_2 SMALLMONEY,
	    @auto_v5spositiontaking_3 SMALLMONEY,
	    @auto_v5spositiontaking_20 SMALLMONEY,
	    @auto_v5spositiontaking_9999 SMALLMONEY,

	    @auto_v8spositiontaking_1 SMALLMONEY,
	    @auto_v8spositiontaking_3 SMALLMONEY,
	    @auto_v8spositiontaking_20 SMALLMONEY,

	    @auto_v10spositiontaking_1 SMALLMONEY,
	    @auto_v10spositiontaking_2 SMALLMONEY,
	    @auto_v10spositiontaking_3 SMALLMONEY,
	    @auto_v10spositiontaking_20 SMALLMONEY,

	    @auto_v11spositiontaking_1 SMALLMONEY,
	    @auto_v11spositiontaking_20 SMALLMONEY,

	    @auto_v99spositiontaking_1 SMALLMONEY,
	    @auto_v99spositiontaking_2 SMALLMONEY,
	    @auto_v99spositiontaking_3 SMALLMONEY,
	    @auto_v99spositiontaking_9 SMALLMONEY,
	    @auto_v99spositiontaking_20 SMALLMONEY,
		@auto_v99spositiontaking_9999 SMALLMONEY,
    	
	    @auto_v161spositiontaking_81 SMALLMONEY,
	    @auto_v161spositiontaking_83 SMALLMONEY,
	    @auto_v161spositiontaking_86 SMALLMONEY,
	    @auto_v161spositiontaking_88 SMALLMONEY,
	    @auto_v161slivepositiontaking_85 SMALLMONEY,
	    @auto_v161slivepositiontaking_86 SMALLMONEY,
	    @auto_v161slivepositiontaking_87 SMALLMONEY,
	    @auto_v161slivepositiontaking_89 SMALLMONEY,
	    @auto_v161slivepositiontaking_90 SMALLMONEY,

	    @auto_v202spositiontaking_1501 SMALLMONEY,
	    @auto_v202spositiontaking_1503 SMALLMONEY,
	    @auto_v202spositiontaking_1504 SMALLMONEY,
	    @auto_v202spositiontaking_1505 SMALLMONEY,
	    @auto_v202spositiontaking_1507 SMALLMONEY,
	    @auto_v202spositiontaking_1508 SMALLMONEY,
	    @auto_v202spositiontaking_1509 SMALLMONEY,
	    @auto_v202spositiontaking_1511 SMALLMONEY,
	    @auto_v202spositiontaking_1513 SMALLMONEY,
	    @auto_v202spositiontaking_1514 SMALLMONEY,

	    --s4
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
	    @max_v99spositiontaking_9 SMALLMONEY,
	    @max_v99spositiontaking_20 SMALLMONEY,
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
  
	    @max_v202spositiontaking_1501 SMALLMONEY,
	    @max_v202spositiontaking_1503 SMALLMONEY,
	    @max_v202spositiontaking_1504 SMALLMONEY,
	    @max_v202spositiontaking_1505 SMALLMONEY,
	    @max_v202spositiontaking_1507 SMALLMONEY,
	    @max_v202spositiontaking_1508 SMALLMONEY,
	    @max_v202spositiontaking_1509 SMALLMONEY,
	    @max_v202spositiontaking_1511 SMALLMONEY,
	    @max_v202spositiontaking_1513 SMALLMONEY,
	    @max_v202spositiontaking_1514 SMALLMONEY,
	    --i3
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
	    @isauto_v99spositiontaking_9 BIT,
	    @isauto_v99spositiontaking_20 BIT,
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
	    
	    @isauto_v202spositiontaking_1501 BIT,
	    @isauto_v202spositiontaking_1503 BIT,
	    @isauto_v202spositiontaking_1504 BIT,
	    @isauto_v202spositiontaking_1505 BIT,
	    @isauto_v202spositiontaking_1507 BIT,
	    @isauto_v202spositiontaking_1508 BIT,
	    @isauto_v202spositiontaking_1509 BIT,
	    @isauto_v202spositiontaking_1511 BIT,
	    @isauto_v202spositiontaking_1513 BIT,
	    @isauto_v202spositiontaking_1514 BIT,
	    --min(a2,a4)
	    @max_apositiontaking_1 SMALLMONEY,
	    @max_apositiontaking_2 SMALLMONEY,
	    @max_apositiontaking_3 SMALLMONEY,
	    @max_apositiontaking_4 SMALLMONEY,
	    @max_apositiontaking_5 SMALLMONEY,
	    @max_apositiontaking_6 SMALLMONEY,
	    @max_apositiontaking_7 SMALLMONEY,
	    @max_apositiontaking_8 SMALLMONEY,
	    @max_apositiontaking_9 SMALLMONEY,
	    @max_apositiontaking_10 SMALLMONEY,
	    @max_v2apositiontaking_10 SMALLMONEY,
	    @max_v3apositiontaking_10 SMALLMONEY,
	    @max_v5apositiontaking_10 SMALLMONEY,
	    @max_v8apositiontaking_10 SMALLMONEY,
	    @max_v10apositiontaking_10 SMALLMONEY,
	    @max_v11apositiontaking_10 SMALLMONEY,
	    @max_v99apositiontaking_10 SMALLMONEY,
	    
	    @max_apositiontaking_9999 SMALLMONEY,
	    @max_alivepositiontaking_1 SMALLMONEY,
	    @max_alivepositiontaking_3 SMALLMONEY,
	    @max_alivepositiontaking_7 SMALLMONEY,
	    @max_alivepositiontaking_8 SMALLMONEY,
    	
	    @max_v2apositiontaking_1 SMALLMONEY,
	    @max_v2apositiontaking_2 SMALLMONEY,
	    @max_v2apositiontaking_3 SMALLMONEY,
	    @max_v2apositiontaking_7 SMALLMONEY,
	    @max_v2apositiontaking_8 SMALLMONEY,

	    @max_v2apositiontaking_20 SMALLMONEY,
	    
	    @max_v2apositiontaking_9999 SMALLMONEY,
    	
	    @max_v3apositiontaking_1 SMALLMONEY,
	    @max_v3apositiontaking_2 SMALLMONEY,
	    @max_v3apositiontaking_3 SMALLMONEY,
	    @max_v3apositiontaking_20 SMALLMONEY,

	    @max_v5apositiontaking_1 SMALLMONEY,
	    @max_v5apositiontaking_2 SMALLMONEY,
	    @max_v5apositiontaking_3 SMALLMONEY,
	    @max_v5apositiontaking_20 SMALLMONEY,
	    @max_v5apositiontaking_9999 SMALLMONEY,

	    @max_v8apositiontaking_1 SMALLMONEY,
	    @max_v8apositiontaking_3 SMALLMONEY,
	    @max_v8apositiontaking_20 SMALLMONEY,

	    @max_v10apositiontaking_1 SMALLMONEY,
	    @max_v10apositiontaking_2 SMALLMONEY,
	    @max_v10apositiontaking_3 SMALLMONEY,
	    @max_v10apositiontaking_20 SMALLMONEY,

	    @max_v11apositiontaking_1 SMALLMONEY,
	    @max_v11apositiontaking_20 SMALLMONEY,

	    @max_v99apositiontaking_1 SMALLMONEY,
	    @max_v99apositiontaking_2 SMALLMONEY,
	    @max_v99apositiontaking_3 SMALLMONEY,
	    @max_v99apositiontaking_9 SMALLMONEY,
	    @max_v99apositiontaking_20 SMALLMONEY,	
		@max_v99apositiontaking_9999 SMALLMONEY,	
    	
	    @max_v161apositiontaking_81 SMALLMONEY,
	    @max_v161apositiontaking_83 SMALLMONEY,
	    @max_v161apositiontaking_86 SMALLMONEY,
	    @max_v161apositiontaking_88 SMALLMONEY,
	    @max_v161alivepositiontaking_85 SMALLMONEY,
	    @max_v161alivepositiontaking_86 SMALLMONEY,
	    @max_v161alivepositiontaking_87 SMALLMONEY,
	    @max_v161alivepositiontaking_89 SMALLMONEY,
	    @max_v161alivepositiontaking_90 SMALLMONEY,
    	
	  
	    @v202apositiontaking_1501 SMALLMONEY,
	    @v202apositiontaking_1503 SMALLMONEY,
	    @v202apositiontaking_1504 SMALLMONEY,
	    @v202apositiontaking_1505 SMALLMONEY,
	    @v202apositiontaking_1507 SMALLMONEY,
	    @v202apositiontaking_1508 SMALLMONEY,
	    @v202apositiontaking_1509 SMALLMONEY,
	    @v202apositiontaking_1511 SMALLMONEY,
	    @v202apositiontaking_1513 SMALLMONEY,
	    @v202apositiontaking_1514 SMALLMONEY,
	    --Master auto positiontaking
    	
	    --m3
	    @max_mpositiontaking_1 SMALLMONEY,
	    @max_mpositiontaking_2 SMALLMONEY,
	    @max_mpositiontaking_3 SMALLMONEY,
	    @max_mpositiontaking_4 SMALLMONEY,
	    @max_mpositiontaking_5 SMALLMONEY,
	    @max_mpositiontaking_6 SMALLMONEY,
	    @max_mpositiontaking_7 SMALLMONEY,
	    @max_mpositiontaking_8 SMALLMONEY,
	    @max_mpositiontaking_9 SMALLMONEY,
	    @max_mpositiontaking_10 SMALLMONEY,
	    @max_v2mpositiontaking_10 SMALLMONEY,
	    @max_v3mpositiontaking_10 SMALLMONEY,
	    @max_v5mpositiontaking_10 SMALLMONEY,
	    @max_v8mpositiontaking_10 SMALLMONEY,
	    @max_v10mpositiontaking_10 SMALLMONEY,
	    @max_v11mpositiontaking_10 SMALLMONEY,
	    @max_v99mpositiontaking_10 SMALLMONEY,
	    @max_mpositiontaking_9999 SMALLMONEY,
	    @max_mlivepositiontaking_1 SMALLMONEY,
	    @max_mlivepositiontaking_3 SMALLMONEY,
	    @max_mlivepositiontaking_7 SMALLMONEY,
	    @max_mlivepositiontaking_8 SMALLMONEY,
    	
	    @max_v2mpositiontaking_1 SMALLMONEY,
	    @max_v2mpositiontaking_2 SMALLMONEY,
	    @max_v2mpositiontaking_3 SMALLMONEY,
	    @max_v2mpositiontaking_7 SMALLMONEY,
	    @max_v2mpositiontaking_8 SMALLMONEY,
	    @max_v2mpositiontaking_20 SMALLMONEY,
	    
	    @max_v2mpositiontaking_9999 SMALLMONEY,

	    @max_v3mpositiontaking_1 SMALLMONEY,
	    @max_v3mpositiontaking_2 SMALLMONEY,
	    @max_v3mpositiontaking_3 SMALLMONEY,
	    @max_v3mpositiontaking_20 SMALLMONEY,

	    @max_v5mpositiontaking_1 SMALLMONEY,
	    @max_v5mpositiontaking_2 SMALLMONEY,
	    @max_v5mpositiontaking_3 SMALLMONEY,
	    @max_v5mpositiontaking_20 SMALLMONEY,
	    @max_v5mpositiontaking_9999 SMALLMONEY,

	    @max_v8mpositiontaking_1 SMALLMONEY,
	    @max_v8mpositiontaking_3 SMALLMONEY,
	    @max_v8mpositiontaking_20 SMALLMONEY,

	    @max_v10mpositiontaking_1 SMALLMONEY,
	    @max_v10mpositiontaking_2 SMALLMONEY,
	    @max_v10mpositiontaking_3 SMALLMONEY,
	    @max_v10mpositiontaking_20 SMALLMONEY,

	    @max_v11mpositiontaking_1 SMALLMONEY,
	    @max_v11mpositiontaking_20 SMALLMONEY,

	    @max_v99mpositiontaking_1 SMALLMONEY,
	    @max_v99mpositiontaking_2 SMALLMONEY,
	    @max_v99mpositiontaking_3 SMALLMONEY,
	    @max_v99mpositiontaking_9 SMALLMONEY,
	    @max_v99mpositiontaking_20 SMALLMONEY,
		@max_v99mpositiontaking_9999 SMALLMONEY,
    	
	    @max_v161mpositiontaking_81 SMALLMONEY,
	    @max_v161mpositiontaking_83 SMALLMONEY,
	    @max_v161mpositiontaking_86 SMALLMONEY,
	    @max_v161mpositiontaking_88 SMALLMONEY,
	    @max_v161mlivepositiontaking_85 SMALLMONEY,
	    @max_v161mlivepositiontaking_86 SMALLMONEY,
	    @max_v161mlivepositiontaking_87 SMALLMONEY,
	    @max_v161mlivepositiontaking_89 SMALLMONEY,
	    @max_v161mlivepositiontaking_90 SMALLMONEY,    	
    	
	    @max_v202mpositiontaking_1501 SMALLMONEY,
	    @max_v202mpositiontaking_1503 SMALLMONEY,
	    @max_v202mpositiontaking_1504 SMALLMONEY,
	    @max_v202mpositiontaking_1505 SMALLMONEY,
	    @max_v202mpositiontaking_1507 SMALLMONEY,
	    @max_v202mpositiontaking_1508 SMALLMONEY,
	    @max_v202mpositiontaking_1509 SMALLMONEY,
	    @max_v202mpositiontaking_1511 SMALLMONEY,
	    @max_v202mpositiontaking_1513 SMALLMONEY,
	    @max_v202mpositiontaking_1514 SMALLMONEY,
	    --u2
	    @auto_mpositiontaking_1 SMALLMONEY,
	    @auto_mpositiontaking_2 SMALLMONEY,
	    @auto_mpositiontaking_3 SMALLMONEY,
	    @auto_mpositiontaking_4 SMALLMONEY,
	    @auto_mpositiontaking_5 SMALLMONEY,
	    @auto_mpositiontaking_6 SMALLMONEY,
	    @auto_mpositiontaking_7 SMALLMONEY,
	    @auto_mpositiontaking_8 SMALLMONEY,
	    @auto_mpositiontaking_9 SMALLMONEY,
	    @auto_mpositiontaking_10 SMALLMONEY,
	    @auto_v2mpositiontaking_10 SMALLMONEY,
	    @auto_v3mpositiontaking_10 SMALLMONEY,
	    @auto_v5mpositiontaking_10 SMALLMONEY,
	    @auto_v8mpositiontaking_10 SMALLMONEY,
	    @auto_v10mpositiontaking_10 SMALLMONEY,
	    @auto_v11mpositiontaking_10 SMALLMONEY,
	    @auto_v99mpositiontaking_10 SMALLMONEY,
	    @auto_mpositiontaking_9999 SMALLMONEY,
    	
	    @auto_mlivepositiontaking_1 SMALLMONEY,
	    @auto_mlivepositiontaking_3 SMALLMONEY,
	    @auto_mlivepositiontaking_7 SMALLMONEY,
	    @auto_mlivepositiontaking_8 SMALLMONEY,
    	
	    @auto_v2mpositiontaking_1 SMALLMONEY,
	    @auto_v2mpositiontaking_2 SMALLMONEY,
	    @auto_v2mpositiontaking_3 SMALLMONEY,
	    @auto_v2mpositiontaking_7 SMALLMONEY,
	    @auto_v2mpositiontaking_8 SMALLMONEY,

	    @auto_v2mpositiontaking_20 SMALLMONEY,
	    
	    @auto_v2mpositiontaking_9999 SMALLMONEY,

	    @auto_v3mpositiontaking_1 SMALLMONEY,
	    @auto_v3mpositiontaking_2 SMALLMONEY,
	    @auto_v3mpositiontaking_3 SMALLMONEY,
	    @auto_v3mpositiontaking_20 SMALLMONEY,

	    @auto_v5mpositiontaking_1 SMALLMONEY,
	    @auto_v5mpositiontaking_2 SMALLMONEY,
	    @auto_v5mpositiontaking_3 SMALLMONEY,
	    @auto_v5mpositiontaking_20 SMALLMONEY,
	    @auto_v5mpositiontaking_9999 SMALLMONEY,

	    @auto_v8mpositiontaking_1 SMALLMONEY,
	    @auto_v8mpositiontaking_3 SMALLMONEY,
	    @auto_v8mpositiontaking_20 SMALLMONEY,

	    @auto_v10mpositiontaking_1 SMALLMONEY,
	    @auto_v10mpositiontaking_2 SMALLMONEY,
	    @auto_v10mpositiontaking_3 SMALLMONEY,
	    @auto_v10mpositiontaking_20 SMALLMONEY,

	    @auto_v11mpositiontaking_1 SMALLMONEY,
	    @auto_v11mpositiontaking_20 SMALLMONEY,

	    @auto_v99mpositiontaking_1 SMALLMONEY,
	    @auto_v99mpositiontaking_2 SMALLMONEY,
	    @auto_v99mpositiontaking_3 SMALLMONEY,
	    @auto_v99mpositiontaking_9 SMALLMONEY,
	    @auto_v99mpositiontaking_20 SMALLMONEY,
		@auto_v99mpositiontaking_9999 SMALLMONEY,

	    @auto_v161mpositiontaking_81 SMALLMONEY,
	    @auto_v161mpositiontaking_83 SMALLMONEY,
	    @auto_v161mpositiontaking_86 SMALLMONEY,
	    @auto_v161mpositiontaking_88 SMALLMONEY,
	    @auto_v161mlivepositiontaking_85 SMALLMONEY,
	    @auto_v161mlivepositiontaking_86 SMALLMONEY,
	    @auto_v161mlivepositiontaking_87 SMALLMONEY,
	    @auto_v161mlivepositiontaking_89 SMALLMONEY,
	    @auto_v161mlivepositiontaking_90 SMALLMONEY,    	

	    @auto_v202mpositiontaking_1501 SMALLMONEY,
	    @auto_v202mpositiontaking_1503 SMALLMONEY,
	    @auto_v202mpositiontaking_1504 SMALLMONEY,
	    @auto_v202mpositiontaking_1505 SMALLMONEY,
	    @auto_v202mpositiontaking_1507 SMALLMONEY,
	    @auto_v202mpositiontaking_1508 SMALLMONEY,
	    @auto_v202mpositiontaking_1509 SMALLMONEY,
	    @auto_v202mpositiontaking_1511 SMALLMONEY,
	    @auto_v202mpositiontaking_1513 SMALLMONEY,
	    @auto_v202mpositiontaking_1514 SMALLMONEY,
	    --i2
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
	    @isauto_v99mpositiontaking_9 BIT,
	    @isauto_v99mpositiontaking_20 BIT,
		@isauto_v99mpositiontaking_9999 BIT,
    	    	
	    @isauto_v161mpositiontaking_81 BIT,
	    @isauto_v161mpositiontaking_83 BIT,
	    @isauto_v161mpositiontaking_86 BIT,
	    @isauto_v161mpositiontaking_88 BIT,
	    @isauto_v161mlivepositiontaking_85 BIT,
	    @isauto_v161mlivepositiontaking_86 BIT,
	    @isauto_v161mlivepositiontaking_87 BIT,
	    @isauto_v161mlivepositiontaking_89 BIT,
	    @isauto_v161mlivepositiontaking_90 BIT,    	
    	
	    @isauto_v202mpositiontaking_1501 BIT,
	    @isauto_v202mpositiontaking_1503 BIT,
	    @isauto_v202mpositiontaking_1504 BIT,
	    @isauto_v202mpositiontaking_1505 BIT,
	    @isauto_v202mpositiontaking_1507 BIT,
	    @isauto_v202mpositiontaking_1508 BIT,
	    @isauto_v202mpositiontaking_1509 BIT,
	    @isauto_v202mpositiontaking_1511 BIT,
	    @isauto_v202mpositiontaking_1513 BIT,
	    @isauto_v202mpositiontaking_1514 BIT,

	    --Keno
	    @HideKeno BIT = 1,
	
		@DisableSuperLive BIT = 0,

	    @matchlimit SMALLMONEY,
	    @discount DECIMAL(9, 8),
	    @discountcs DECIMAL(9, 8)
	    --@virtualmultiplier SMALLMONEY
    	
    declare @ErrType VARCHAR(4000)	

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --SELECT @maxpos = 0.7, @maxdownlinepos = 0.7
    --SELECT @adiscount = CASE WHEN @ugroup in ('a','hka') THEN 0.0025 WHEN @ugroup in ('b','hkb') THEN 0.005 WHEN @ugroup in ('c','hkc') THEN 0.0075 ELSE 0.01 END, @adiscountcs=0.05
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT @currency = currency
         , @mrecommend = mrecommend
         , @srecommend = srecommend
         , @AgentCredit = ISNULL(Credit, 0)     
         --, @Asuspended = reject
         , @UplineClosed = cs.closed
         , @matchlimit = matchlimit
         , @AgentDanger = Danger
         , @AgentDanger2 = Danger2
         , @AgentDanger3 = Danger3
		 , @AgentDanger4 = Danger4
         , @AgentDanger5 = Danger5
         , @AgentAbnormal = Abnormal
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
		 , @autosuspend3 = ISNULL(autosuspend3, 0)
         
         , @DisableOutright = DisableOutright   
         , @DisableNumber = CASE WHEN DisableNumber = 1 THEN 1 ELSE @DisableNumber END
         , @EnableVR = ISNULL(virtualmultiplier, 1)           
         , @HideKeno = HideKeno      
		
		 , @DisableSuperLive = DisableSuperLive
     FROM custinfo ci WITH(NOLOCK)	
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs
     WHERE CustID = @recommend	
    
	--Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @recommend)		
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@_Site)
	END	

    IF @isSearchAndCopy = 1
    BEGIN
        SELECT	
				@DisableOutright = DisableOutright,
				@DisableSuperLive = DisableSuperLive,
				@suspended = reject
          FROM custinfo WITH(NOLOCK)
         WHERE CustID = @copyFromCustID
    END

    /* 20130403@Jamie: Check Recommend <> MRecommend AND <> Srecommend OR NOT*/
    IF (@recommend = @mrecommend) OR (@recommend = @srecommend)
    BEGIN
	    SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Invalid user'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						    END,
			    @Success = 0, @ErrCode = 350
	    RETURN	
    END

    /* END: Check Recommend <> MRecommend AND <> Srecommend OR NOT*/

    --Use maxcredit in CustAgent table 
    SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) FROM custAgent WITH(NOLOCK)  WHERE CustID = @recommend

    SELECT @ErrCode = 0

	--Agent can only create up to 200 new members every day by QR.
	IF @IsQRCode = 1
	BEGIN
		DECLARE @QRMemberCount INT

		SELECT @QRMemberCount = COUNT(1) 
		FROM Customer a WITH(NOLOCK) 
			INNER JOIN CustQRCode b WITH(NOLOCK) ON a.CustID = b.CustID
		WHERE a.recommend = @recommend AND a.roleid = 1 AND a.creatdate BETWEEN CONVERT(DATE,GETDATE()) AND GETDATE()

		IF @QRMemberCount >= 200
		BEGIN
			SELECT @ErrCode = 40051
					,@ErrMsg = CASE @Language WHEN 'E' THEN 'You can only create up to 200 new members every day by this function.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40051,@Language)
								END
			RETURN
		END
	END

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsValid BIT
     -- MyanmarOdds
    
	DECLARE @IsMyanmarOdds BIT = 0,@MyanmarOddsAgent decimal(9,8) = 0 
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	BEGIN
	   SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'The selected group is not allowed for this site'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40055,@Language)
						    END,
			    @Success = 0, @ErrCode = 40055
			    
		
	    RETURN	
	END
	
	-- Reset discount value in case its value > upline
	IF @IsMyanmarOdds = 1
	BEGIN
		SELECT @playerdiscountMyanmarOdds = CASE 
											WHEN @playerdiscountMyanmarOdds > commRate THEN commRate
											ELSE @playerdiscountMyanmarOdds  
										END, @MyanmarOddsAgent = commRate  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @recommend
			AND sporttype = 1   
			AND bettype = 1 
	END
	
    EXEC dbo.Acc_CustomerInsMember_Ag_CheckParam
		@custid = @custid OUTPUT,
	    @playerdiscount=@playerdiscount,
	    @playerdiscountcs=@playerdiscountcs,
	    @playerdiscount1x2 = @playerdiscount1x2,--1x2
	  
    	-- MyanmarOdds
    	@discountMyanmarOdds = @playerdiscountMyanmarOdds,

	    @credit=@credit,

	    @recommend=@recommend,
	    @ugroup=@ugroup,
    	
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
	    @alivepositiontaking_1=@alivepositiontaking_1,
	    @alivepositiontaking_3=@alivepositiontaking_3,
	    @alivepositiontaking_7=@alivepositiontaking_7,
	    @alivepositiontaking_8=@alivepositiontaking_8,
    	
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
	    @v99apositiontaking_9 = @v99apositiontaking_9,
	    @v99apositiontaking_20=@v99apositiontaking_20,
		@v99apositiontaking_9999=@v99apositiontaking_9999,     	
    	
	    @v161apositiontaking_81 = @v161apositiontaking_81,
	    @v161apositiontaking_83 = @v161apositiontaking_83,
	    @v161apositiontaking_86 = @v161apositiontaking_86,
	    @v161apositiontaking_88 = @v161apositiontaking_88,
	    @v161alivepositiontaking_85 = @v161alivepositiontaking_85,
	    @v161alivepositiontaking_86 = @v161alivepositiontaking_86,
	    @v161alivepositiontaking_87 = @v161alivepositiontaking_87,
	    @v161alivepositiontaking_89 = @v161alivepositiontaking_89,
	    @v161alivepositiontaking_90 = @v161alivepositiontaking_90,
    	
    	
	    @isvalid=@isvalid OUTPUT,
	    @errmsg=@ErrMsg OUTPUT,
	    @errcode=@errcode OUTPUT,
	    @language=@language,
		@SystemID = @SystemID,
		@creator = @creator

    IF @IsValid = 0
    BEGIN
	    return
    END

	DECLARE @BetSettingXML VARCHAR(8000) = ''

	EXEC Acc_CustomerInsMember_CheckBetSetting
		 @custid			= @recommend
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

    --Check member group under Won currency
    IF @currency = 45 AND @ugroup NOT IN ('dea','deb','dec','ded')-- Won currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @Success = 0, @ErrCode = 300
		    return			
	    END
    	
    IF @currency <> 45 AND @ugroup IN ('dea','deb','dec','ded') -- Others currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @Success = 0, @ErrCode = 301
		    return			
	    END
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SELECT @success = 0, @username = rtrim(ltrim(@username))
    SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END		
			    , @success = 0, @ErrCode = 201
	    RETURN
    END

    --a2,m2,u2,i2
    SELECT @max_apositiontaking_1 = apositiontaking, @max_alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @auto_mpositiontaking_1 = autompositiontaking, @auto_mlivepositiontaking_1 = autolivempositiontaking, @isauto_mpositiontaking_1 = isautompositiontaking, @isauto_mlivepositiontaking_1 = isautolivempositiontaking, @discount = CASE WHEN @ugroup in ('a','hka','dea') THEN groupa WHEN @ugroup in ('b','hkb','deb') THEN groupb WHEN @ugroup in ('c','hkc','dec') THEN groupc ELSE groupd END FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 1
    SELECT @max_apositiontaking_3 = apositiontaking, @max_alivepositiontaking_3 = alivepositiontaking, @mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @auto_mpositiontaking_3 = autompositiontaking, @auto_mlivepositiontaking_3 = autolivempositiontaking, @isauto_mpositiontaking_3 = isautompositiontaking, @isauto_mlivepositiontaking_3 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 1
    SELECT @max_apositiontaking_7 = apositiontaking, @max_alivepositiontaking_7 = alivepositiontaking, @mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @auto_mpositiontaking_7 = autompositiontaking, @auto_mlivepositiontaking_7 = autolivempositiontaking, @isauto_mpositiontaking_7 = isautompositiontaking, @isauto_mlivepositiontaking_7 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=7 AND sporttype = 1
    SELECT @max_apositiontaking_8 = apositiontaking, @max_alivepositiontaking_8 = alivepositiontaking, @mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @auto_mpositiontaking_8 = autompositiontaking, @auto_mlivepositiontaking_8 = autolivempositiontaking, @isauto_mpositiontaking_8 = isautompositiontaking, @isauto_mlivepositiontaking_8 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=8 AND sporttype = 1
    SELECT @max_apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @auto_mpositiontaking_2 = autompositiontaking, @isauto_mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 1
    SELECT @max_apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @auto_mpositiontaking_4 = autompositiontaking, @isauto_mpositiontaking_4 = isautompositiontaking, @discountcs = discount FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 4 AND sporttype = 1
    SELECT @max_apositiontaking_5 = apositiontaking, @mpositiontaking_5 = mpositiontaking, @auto_mpositiontaking_5 = autompositiontaking, @isauto_mpositiontaking_5 = isautompositiontaking, @discount1x2 = discount FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 5 AND sporttype = 1
    SELECT @max_apositiontaking_6 = apositiontaking, @mpositiontaking_6 = mpositiontaking, @auto_mpositiontaking_6 = autompositiontaking, @isauto_mpositiontaking_6 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=6 AND sporttype = 1
    SELECT @max_apositiontaking_9 = apositiontaking, @mpositiontaking_9 = mpositiontaking, @auto_mpositiontaking_9 = autompositiontaking, @isauto_mpositiontaking_9 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9 AND sporttype = 1
    SELECT @max_apositiontaking_10 = apositiontaking, @mpositiontaking_10 = mpositiontaking, @auto_mpositiontaking_10 = autompositiontaking, @isauto_mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 1
    SELECT @max_v2apositiontaking_10 = apositiontaking, @v2mpositiontaking_10 = mpositiontaking, @auto_v2mpositiontaking_10 = autompositiontaking, @isauto_v2mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 2
    SELECT @max_v3apositiontaking_10 = apositiontaking, @v3mpositiontaking_10 = mpositiontaking, @auto_v3mpositiontaking_10 = autompositiontaking, @isauto_v3mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 3
    SELECT @max_v5apositiontaking_10 = apositiontaking, @v5mpositiontaking_10 = mpositiontaking, @auto_v5mpositiontaking_10 = autompositiontaking, @isauto_v5mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 5
    SELECT @max_v8apositiontaking_10 = apositiontaking, @v8mpositiontaking_10 = mpositiontaking, @auto_v8mpositiontaking_10 = autompositiontaking, @isauto_v8mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 8
    SELECT @max_v10apositiontaking_10 = apositiontaking, @v10mpositiontaking_10 = mpositiontaking, @auto_v10mpositiontaking_10 = autompositiontaking, @isauto_v10mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 10
    SELECT @max_v11apositiontaking_10 = apositiontaking, @v11mpositiontaking_10 = mpositiontaking, @auto_v11mpositiontaking_10 = autompositiontaking, @isauto_v11mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 11
    SELECT @max_v99apositiontaking_10 = apositiontaking, @v99mpositiontaking_10 = mpositiontaking, @auto_v99mpositiontaking_10 = autompositiontaking, @isauto_v99mpositiontaking_10 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 10 AND sporttype = 99
    SELECT @max_apositiontaking_9999 = apositiontaking, @mpositiontaking_9999 = mpositiontaking, @auto_mpositiontaking_9999 = autompositiontaking, @isauto_mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype = 1

    SELECT @max_v2apositiontaking_1 = apositiontaking, @v2mpositiontaking_1 = mpositiontaking, @auto_v2mpositiontaking_1 = autompositiontaking, @isauto_v2mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=2
    SELECT @max_v2apositiontaking_2 = apositiontaking, @v2mpositiontaking_2 = mpositiontaking, @auto_v2mpositiontaking_2 = autompositiontaking, @isauto_v2mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype=2
    SELECT @max_v2apositiontaking_3 = apositiontaking, @v2mpositiontaking_3 = mpositiontaking, @auto_v2mpositiontaking_3 = autompositiontaking, @isauto_v2mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=2
    SELECT @max_v2apositiontaking_7 = apositiontaking, @v2mpositiontaking_7 = mpositiontaking, @auto_v2mpositiontaking_7 = autompositiontaking, @isauto_v2mpositiontaking_7 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=7 AND sporttype=2
    SELECT @max_v2apositiontaking_8 = apositiontaking, @v2mpositiontaking_8 = mpositiontaking, @auto_v2mpositiontaking_8 = autompositiontaking, @isauto_v2mpositiontaking_8 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=8 AND sporttype=2
    SELECT @max_v2apositiontaking_20 = apositiontaking, @v2mpositiontaking_20 = mpositiontaking, @auto_v2mpositiontaking_20 = autompositiontaking, @isauto_v2mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=2
    
    SELECT @max_v2apositiontaking_9999 = apositiontaking, @v2mpositiontaking_9999 = mpositiontaking, @auto_v2mpositiontaking_9999 = autompositiontaking, @isauto_v2mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype=2
    
    SELECT @max_v3apositiontaking_1 = apositiontaking, @v3mpositiontaking_1 = mpositiontaking, @auto_v3mpositiontaking_1 = autompositiontaking, @isauto_v3mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 3
    SELECT @max_v3apositiontaking_2 = apositiontaking, @v3mpositiontaking_2 = mpositiontaking, @auto_v3mpositiontaking_2 = autompositiontaking, @isauto_v3mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 3
    SELECT @max_v3apositiontaking_3 = apositiontaking, @v3mpositiontaking_3 = mpositiontaking, @auto_v3mpositiontaking_3 = autompositiontaking, @isauto_v3mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 3
    SELECT @max_v3apositiontaking_20 = apositiontaking, @v3mpositiontaking_20 = mpositiontaking, @auto_v3mpositiontaking_20 = autompositiontaking, @isauto_v3mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 3

    SELECT @max_v5apositiontaking_1 = apositiontaking, @v5mpositiontaking_1 = mpositiontaking, @auto_v5mpositiontaking_1 = autompositiontaking, @isauto_v5mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 5
    SELECT @max_v5apositiontaking_2 = apositiontaking, @v5mpositiontaking_2 = mpositiontaking, @auto_v5mpositiontaking_2 = autompositiontaking, @isauto_v5mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 5
    SELECT @max_v5apositiontaking_3 = apositiontaking, @v5mpositiontaking_3 = mpositiontaking, @auto_v5mpositiontaking_3 = autompositiontaking, @isauto_v5mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 5
    SELECT @max_v5apositiontaking_20 = apositiontaking, @v5mpositiontaking_20 = mpositiontaking, @auto_v5mpositiontaking_20 = autompositiontaking, @isauto_v5mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 5
    SELECT @max_v5apositiontaking_9999 = apositiontaking, @v5mpositiontaking_9999 = mpositiontaking, @auto_v5mpositiontaking_9999 = autompositiontaking, @isauto_v5mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype = 5

    SELECT @max_v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @auto_v8mpositiontaking_1 = autompositiontaking, @isauto_v8mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=8
    SELECT @max_v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @auto_v8mpositiontaking_3 = autompositiontaking, @isauto_v8mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=8
    SELECT @max_v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @auto_v8mpositiontaking_20 = autompositiontaking, @isauto_v8mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=8

    SELECT @max_v10apositiontaking_1 = apositiontaking, @v10mpositiontaking_1 = mpositiontaking, @auto_v10mpositiontaking_1 = autompositiontaking, @isauto_v10mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 10
    SELECT @max_v10apositiontaking_2 = apositiontaking, @v10mpositiontaking_2 = mpositiontaking, @auto_v10mpositiontaking_2 = autompositiontaking, @isauto_v10mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 10
    SELECT @max_v10apositiontaking_3 = apositiontaking, @v10mpositiontaking_3 = mpositiontaking, @auto_v10mpositiontaking_3 = autompositiontaking, @isauto_v10mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 10
    SELECT @max_v10apositiontaking_20 = apositiontaking, @v10mpositiontaking_20 = mpositiontaking, @auto_v10mpositiontaking_20 = autompositiontaking, @isauto_v10mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 10

    SELECT @max_v11apositiontaking_1 = apositiontaking, @v11mpositiontaking_1 = mpositiontaking, @auto_v11mpositiontaking_1 = autompositiontaking, @isauto_v11mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 11
    SELECT @max_v11apositiontaking_20 = apositiontaking, @v11mpositiontaking_20 = mpositiontaking, @auto_v11mpositiontaking_20 = autompositiontaking, @isauto_v11mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 11


    SELECT @max_v99apositiontaking_1 = apositiontaking, @v99mpositiontaking_1 = mpositiontaking, @auto_v99mpositiontaking_1 = autompositiontaking, @isauto_v99mpositiontaking_1 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=99
    SELECT @max_v99apositiontaking_2 = apositiontaking, @v99mpositiontaking_2 = mpositiontaking, @auto_v99mpositiontaking_2 = autompositiontaking, @isauto_v99mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype=99
    SELECT @max_v99apositiontaking_3 = apositiontaking, @v99mpositiontaking_3 = mpositiontaking, @auto_v99mpositiontaking_3 = autompositiontaking, @isauto_v99mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=99
    SELECT @max_v99apositiontaking_9 = apositiontaking, @v99mpositiontaking_9 = mpositiontaking, @auto_v99mpositiontaking_9 = autompositiontaking, @isauto_v99mpositiontaking_9 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9 AND sporttype=99
    SELECT @max_v99apositiontaking_20 = apositiontaking, @v99mpositiontaking_20 = mpositiontaking, @auto_v99mpositiontaking_20 = autompositiontaking, @isauto_v99mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=99
	SELECT @max_v99apositiontaking_9999 = apositiontaking, @v99mpositiontaking_9999 = mpositiontaking, @auto_v99mpositiontaking_9999 = autompositiontaking, @isauto_v99mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype=99

    --v161
    SELECT @max_v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @auto_v161mpositiontaking_81 = autompositiontaking,  @isauto_v161mpositiontaking_81 = isautompositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=81 AND sporttype = 161
    SELECT @max_v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=83 AND sporttype = 161
    SELECT @max_v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=88 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=85 AND sporttype = 161
    SELECT @max_v161apositiontaking_86 = apositiontaking, @max_v161alivepositiontaking_86 = alivepositiontaking, @v161mpositiontaking_86 = mpositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=86 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=87 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=89 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=90 AND sporttype = 161
   
    --v202
    SELECT @v202apositiontaking_1501 = apositiontaking, @v202mpositiontaking_1501 = mpositiontaking, @auto_v202mpositiontaking_1501 = autompositiontaking, @isauto_v202mpositiontaking_1501 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1501 AND sporttype = 202
    SELECT @v202apositiontaking_1503 = apositiontaking, @v202mpositiontaking_1503 = mpositiontaking, @auto_v202mpositiontaking_1503 = autompositiontaking, @isauto_v202mpositiontaking_1503 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1503 AND sporttype = 202
    SELECT @v202apositiontaking_1504 = apositiontaking, @v202mpositiontaking_1504 = mpositiontaking, @auto_v202mpositiontaking_1504 = autompositiontaking, @isauto_v202mpositiontaking_1504 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1504 AND sporttype = 202
    SELECT @v202apositiontaking_1505 = apositiontaking, @v202mpositiontaking_1505 = mpositiontaking, @auto_v202mpositiontaking_1505 = autompositiontaking, @isauto_v202mpositiontaking_1505 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1505 AND sporttype = 202
    SELECT @v202apositiontaking_1507 = apositiontaking, @v202mpositiontaking_1507 = mpositiontaking, @auto_v202mpositiontaking_1507 = autompositiontaking, @isauto_v202mpositiontaking_1507 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1507 AND sporttype = 202
    SELECT @v202apositiontaking_1508 = apositiontaking, @v202mpositiontaking_1508 = mpositiontaking, @auto_v202mpositiontaking_1508 = autompositiontaking, @isauto_v202mpositiontaking_1508 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1508 AND sporttype = 202
    SELECT @v202apositiontaking_1509 = apositiontaking, @v202mpositiontaking_1509 = mpositiontaking, @auto_v202mpositiontaking_1509 = autompositiontaking, @isauto_v202mpositiontaking_1509 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1509 AND sporttype = 202
    SELECT @v202apositiontaking_1511 = apositiontaking, @v202mpositiontaking_1511 = mpositiontaking, @auto_v202mpositiontaking_1511 = autompositiontaking, @isauto_v202mpositiontaking_1511 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1511 AND sporttype = 202
    SELECT @v202apositiontaking_1513 = apositiontaking, @v202mpositiontaking_1513 = mpositiontaking, @auto_v202mpositiontaking_1513 = autompositiontaking, @isauto_v202mpositiontaking_1513 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1513 AND sporttype = 202
    SELECT @v202apositiontaking_1514 = apositiontaking, @v202mpositiontaking_1514 = mpositiontaking, @auto_v202mpositiontaking_1514 = autompositiontaking, @isauto_v202mpositiontaking_1514 = isautompositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1514 AND sporttype = 202

    --s3,m3,u3,i3
    SELECT @spositiontaking_1 = spositiontaking, @slivepositiontaking_1 = slivepositiontaking, @max_mpositiontaking_1 = mpositiontaking, @max_mlivepositiontaking_1 = mlivepositiontaking, @auto_spositiontaking_1 = autopositiontaking, @auto_slivepositiontaking_1 = autolivepositiontaking, @isauto_spositiontaking_1 = isautopositiontaking, @isauto_slivepositiontaking_1 = isautolivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 1
    SELECT @spositiontaking_3 = spositiontaking, @slivepositiontaking_3 = slivepositiontaking, @max_mpositiontaking_3 = mpositiontaking, @max_mlivepositiontaking_3 = mlivepositiontaking, @auto_spositiontaking_3 = autopositiontaking, @auto_slivepositiontaking_3 = autolivepositiontaking, @isauto_spositiontaking_3 = isautopositiontaking, @isauto_slivepositiontaking_3 = isautolivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype = 1
    SELECT @spositiontaking_7 = spositiontaking, @slivepositiontaking_7 = slivepositiontaking, @max_mpositiontaking_7 = mpositiontaking, @max_mlivepositiontaking_7 = mlivepositiontaking, @auto_spositiontaking_7 = autopositiontaking, @auto_slivepositiontaking_7 = autolivepositiontaking, @isauto_spositiontaking_7 = isautopositiontaking, @isauto_slivepositiontaking_7 = isautolivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype = 1
    SELECT @spositiontaking_8 = spositiontaking, @slivepositiontaking_8 = slivepositiontaking, @max_mpositiontaking_8 = mpositiontaking, @max_mlivepositiontaking_8 = mlivepositiontaking, @auto_spositiontaking_8 = autopositiontaking, @auto_slivepositiontaking_8 = autolivepositiontaking, @isauto_spositiontaking_8 = isautopositiontaking, @isauto_slivepositiontaking_8 = isautolivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype = 1
    SELECT @spositiontaking_2 = spositiontaking, @max_mpositiontaking_2 = mpositiontaking, @auto_spositiontaking_2 = autopositiontaking, @isauto_spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype = 1
    SELECT @spositiontaking_4 = spositiontaking, @max_mpositiontaking_4 = mpositiontaking, @auto_spositiontaking_4 = autopositiontaking, @isauto_spositiontaking_4 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 4 AND sporttype = 1
    SELECT @spositiontaking_5 = spositiontaking, @max_mpositiontaking_5 = mpositiontaking, @auto_spositiontaking_5 = autopositiontaking, @isauto_spositiontaking_5 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 5 AND sporttype = 1
    SELECT @spositiontaking_6 = spositiontaking, @max_mpositiontaking_6 = mpositiontaking, @auto_spositiontaking_6 = autopositiontaking, @isauto_spositiontaking_6 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=6 AND sporttype = 1
    SELECT @spositiontaking_9 = spositiontaking, @max_mpositiontaking_9 = mpositiontaking, @auto_spositiontaking_9 = autopositiontaking, @isauto_spositiontaking_9 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype = 1
    SELECT @spositiontaking_10 = spositiontaking, @max_mpositiontaking_10 = mpositiontaking, @auto_spositiontaking_10 = autopositiontaking, @isauto_spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 1
    SELECT @v2spositiontaking_10 = spositiontaking, @max_v2mpositiontaking_10 = mpositiontaking, @auto_v2spositiontaking_10 = autopositiontaking, @isauto_v2spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 2
    SELECT @v3spositiontaking_10 = spositiontaking, @max_v3mpositiontaking_10 = mpositiontaking, @auto_v3spositiontaking_10 = autopositiontaking, @isauto_v3spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 3
    SELECT @v5spositiontaking_10 = spositiontaking, @max_v5mpositiontaking_10 = mpositiontaking, @auto_v5spositiontaking_10 = autopositiontaking, @isauto_v5spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 5
    SELECT @v8spositiontaking_10 = spositiontaking, @max_v8mpositiontaking_10 = mpositiontaking, @auto_v8spositiontaking_10 = autopositiontaking, @isauto_v8spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 8
    SELECT @v10spositiontaking_10 = spositiontaking, @max_v10mpositiontaking_10 = mpositiontaking, @auto_v10spositiontaking_10 = autopositiontaking, @isauto_v10spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 10
    SELECT @v11spositiontaking_10 = spositiontaking, @max_v11mpositiontaking_10 = mpositiontaking, @auto_v11spositiontaking_10 = autopositiontaking, @isauto_v11spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 11
    SELECT @v99spositiontaking_10 = spositiontaking, @max_v99mpositiontaking_10 = mpositiontaking, @auto_v99spositiontaking_10 = autopositiontaking, @isauto_v99spositiontaking_10 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 10 AND sporttype = 99
    SELECT @spositiontaking_9999 = spositiontaking, @max_mpositiontaking_9999 = mpositiontaking, @auto_spositiontaking_9999 = autopositiontaking, @isauto_spositiontaking_9999 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype = 1

    SELECT @v2spositiontaking_1 = spositiontaking, @max_v2mpositiontaking_1 = mpositiontaking, @auto_v2spositiontaking_1 = autopositiontaking, @isauto_v2spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype=2
    SELECT @v2spositiontaking_2 = spositiontaking, @max_v2mpositiontaking_2 = mpositiontaking, @auto_v2spositiontaking_2 = autopositiontaking, @isauto_v2spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=2
    SELECT @v2spositiontaking_3 = spositiontaking, @max_v2mpositiontaking_3 = mpositiontaking, @auto_v2spositiontaking_3 = autopositiontaking, @isauto_v2spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype=2
    SELECT @v2spositiontaking_7 = spositiontaking, @max_v2mpositiontaking_7 = mpositiontaking, @auto_v2spositiontaking_7 = autopositiontaking, @isauto_v2spositiontaking_7 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=2
    SELECT @v2spositiontaking_8 = spositiontaking, @max_v2mpositiontaking_8 = mpositiontaking, @auto_v2spositiontaking_8 = autopositiontaking, @isauto_v2spositiontaking_8 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=2
    SELECT @v2spositiontaking_20 = spositiontaking, @max_v2mpositiontaking_20 = mpositiontaking, @auto_v2spositiontaking_20 = autopositiontaking, @isauto_v2spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=2
    
    SELECT @v2spositiontaking_9999 = spositiontaking, @max_v2mpositiontaking_9999 = mpositiontaking, @auto_v2spositiontaking_9999 = autopositiontaking, @isauto_v2spositiontaking_9999 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=2

    SELECT @v3spositiontaking_1 = spositiontaking, @max_v3mpositiontaking_1 = mpositiontaking, @auto_v3spositiontaking_1 = autopositiontaking, @isauto_v3spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 3
    SELECT @v3spositiontaking_2 = spositiontaking, @max_v3mpositiontaking_2 = mpositiontaking, @auto_v3spositiontaking_2 = autopositiontaking, @isauto_v3spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype = 3
    SELECT @v3spositiontaking_3 = spositiontaking, @max_v3mpositiontaking_3 = mpositiontaking, @auto_v3spositiontaking_3 = autopositiontaking, @isauto_v3spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype = 3
    SELECT @v3spositiontaking_20 = spositiontaking, @max_v3mpositiontaking_20 = mpositiontaking, @auto_v3spositiontaking_20 = autopositiontaking, @isauto_v3spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype = 3

    SELECT @v5spositiontaking_1 = spositiontaking, @max_v5mpositiontaking_1 = mpositiontaking, @auto_v5spositiontaking_1 = autopositiontaking, @isauto_v5spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 5
    SELECT @v5spositiontaking_2 = spositiontaking, @max_v5mpositiontaking_2 = mpositiontaking, @auto_v5spositiontaking_2 = autopositiontaking, @isauto_v5spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype = 5
    SELECT @v5spositiontaking_3 = spositiontaking, @max_v5mpositiontaking_3 = mpositiontaking, @auto_v5spositiontaking_3 = autopositiontaking, @isauto_v5spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype = 5
    SELECT @v5spositiontaking_20 = spositiontaking, @max_v5mpositiontaking_20 = mpositiontaking, @auto_v5spositiontaking_20 = autopositiontaking, @isauto_v5spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype = 5
    SELECT @v5spositiontaking_9999 = spositiontaking, @max_v5mpositiontaking_9999 = mpositiontaking, @auto_v5spositiontaking_9999 = autopositiontaking, @isauto_v5spositiontaking_9999 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype = 5

    SELECT @v8spositiontaking_1 = spositiontaking, @max_v8mpositiontaking_1 = mpositiontaking, @auto_v8spositiontaking_1 = autopositiontaking, @isauto_v8spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype=8
    SELECT @v8spositiontaking_3 = spositiontaking, @max_v8mpositiontaking_3 = mpositiontaking, @auto_v8spositiontaking_3 = autopositiontaking, @isauto_v8spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype=8
    SELECT @v8spositiontaking_20 = spositiontaking, @max_v8mpositiontaking_20 = mpositiontaking, @auto_v8spositiontaking_20 = autopositiontaking, @isauto_v8spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=8

    SELECT @v10spositiontaking_1 = spositiontaking, @max_v10mpositiontaking_1 = mpositiontaking, @auto_v10spositiontaking_1 = autopositiontaking, @isauto_v10spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 10
    SELECT @v10spositiontaking_2 = spositiontaking, @max_v10mpositiontaking_2 = mpositiontaking, @auto_v10spositiontaking_2 = autopositiontaking, @isauto_v10spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype = 10
    SELECT @v10spositiontaking_3 = spositiontaking, @max_v10mpositiontaking_3 = mpositiontaking, @auto_v10spositiontaking_3 = autopositiontaking, @isauto_v10spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype = 10
    SELECT @v10spositiontaking_20 = spositiontaking, @max_v10mpositiontaking_20 = mpositiontaking, @auto_v10spositiontaking_20 = autopositiontaking, @isauto_v10spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype = 10

    SELECT @v11spositiontaking_1 = spositiontaking, @max_v11mpositiontaking_1 = mpositiontaking, @auto_v11spositiontaking_1 = autopositiontaking, @isauto_v11spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 11
    SELECT @v11spositiontaking_20 = spositiontaking, @max_v11mpositiontaking_20 = mpositiontaking, @auto_v11spositiontaking_20 = autopositiontaking, @isauto_v11spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype = 11

    SELECT @v99spositiontaking_1 = spositiontaking, @max_v99mpositiontaking_1 = mpositiontaking, @auto_v99spositiontaking_1 = autopositiontaking, @isauto_v99spositiontaking_1 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype=99
    SELECT @v99spositiontaking_2 = spositiontaking, @max_v99mpositiontaking_2 = mpositiontaking, @auto_v99spositiontaking_2 = autopositiontaking, @isauto_v99spositiontaking_2 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=99
    SELECT @v99spositiontaking_3 = spositiontaking, @max_v99mpositiontaking_3 = mpositiontaking, @auto_v99spositiontaking_3 = autopositiontaking, @isauto_v99spositiontaking_3 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype=99
    SELECT @v99spositiontaking_9 = spositiontaking, @max_v99mpositiontaking_9 = mpositiontaking, @auto_v99spositiontaking_9 = autopositiontaking, @isauto_v99spositiontaking_9 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=99
    SELECT @v99spositiontaking_20 = spositiontaking, @max_v99mpositiontaking_20 = mpositiontaking, @auto_v99spositiontaking_20 = autopositiontaking, @isauto_v99spositiontaking_20 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=99
	SELECT @v99spositiontaking_9999 = spositiontaking, @max_v99mpositiontaking_9999 = mpositiontaking, @auto_v99spositiontaking_9999 = autopositiontaking, @isauto_v99spositiontaking_9999 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=99

    --161
    SELECT @v161spositiontaking_81 = spositiontaking, @max_v161mpositiontaking_81 = mpositiontaking,@auto_v161spositiontaking_81 = autopositiontaking, @isauto_v161spositiontaking_81 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=81 AND sporttype = 161
    SELECT @v161spositiontaking_83 = spositiontaking, @max_v161mpositiontaking_83 = mpositiontaking,@auto_v161spositiontaking_83 = autopositiontaking, @isauto_v161spositiontaking_83 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=83 AND sporttype = 161
    SELECT @v161spositiontaking_88 = spositiontaking, @max_v161mpositiontaking_88 = mpositiontaking,@auto_v161spositiontaking_88 = autopositiontaking, @isauto_v161spositiontaking_88 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=88 AND sporttype = 161
    SELECT @v161slivepositiontaking_85 = slivepositiontaking , @max_v161mlivepositiontaking_85 =mlivepositiontaking  ,@auto_v161slivepositiontaking_85 =autolivepositiontaking, @isauto_v161slivepositiontaking_85 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=85 AND sporttype = 161
    SELECT @v161spositiontaking_86 = spositiontaking, @v161slivepositiontaking_86 = slivepositiontaking , @max_v161mpositiontaking_86 = mpositiontaking,@max_v161mlivepositiontaking_86 =mlivepositiontaking  , @auto_v161spositiontaking_86 = autopositiontaking, @auto_v161slivepositiontaking_86 =autolivepositiontaking, @isauto_v161spositiontaking_86 = isautopositiontaking,@isauto_v161slivepositiontaking_86 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=86 AND sporttype = 161
    SELECT @v161slivepositiontaking_87 = slivepositiontaking , @max_v161mlivepositiontaking_87 =mlivepositiontaking , @auto_v161slivepositiontaking_87 =autolivepositiontaking, @isauto_v161slivepositiontaking_87 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=87 AND sporttype = 161
    SELECT @v161slivepositiontaking_89 = slivepositiontaking , @max_v161mlivepositiontaking_89 =mlivepositiontaking , @auto_v161slivepositiontaking_89 =autolivepositiontaking, @isauto_v161slivepositiontaking_89 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=89 AND sporttype = 161
    SELECT @v161slivepositiontaking_90 = slivepositiontaking , @max_v161mlivepositiontaking_90 =mlivepositiontaking , @auto_v161slivepositiontaking_90 =autolivepositiontaking, @isauto_v161slivepositiontaking_90 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=90 AND sporttype = 161

    
    --v202
    SELECT @v202spositiontaking_1501 = spositiontaking, @max_v202mpositiontaking_1501 = mpositiontaking, @auto_v202spositiontaking_1501 = autopositiontaking, @isauto_v202spositiontaking_1501 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1501 AND sporttype = 202
    SELECT @v202spositiontaking_1503 = spositiontaking, @max_v202mpositiontaking_1503 = mpositiontaking, @auto_v202spositiontaking_1503 = autopositiontaking, @isauto_v202spositiontaking_1503 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1503 AND sporttype = 202
    SELECT @v202spositiontaking_1504 = spositiontaking, @max_v202mpositiontaking_1504 = mpositiontaking, @auto_v202spositiontaking_1504 = autopositiontaking, @isauto_v202spositiontaking_1504 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1504 AND sporttype = 202
    SELECT @v202spositiontaking_1505 = spositiontaking, @max_v202mpositiontaking_1505 = mpositiontaking, @auto_v202spositiontaking_1505 = autopositiontaking, @isauto_v202spositiontaking_1505 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1505 AND sporttype = 202
    SELECT @v202spositiontaking_1507 = spositiontaking, @max_v202mpositiontaking_1507 = mpositiontaking, @auto_v202spositiontaking_1507 = autopositiontaking, @isauto_v202spositiontaking_1507 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1507 AND sporttype = 202
    SELECT @v202spositiontaking_1508 = spositiontaking, @max_v202mpositiontaking_1508 = mpositiontaking, @auto_v202spositiontaking_1508 = autopositiontaking, @isauto_v202spositiontaking_1508 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1508 AND sporttype = 202
    SELECT @v202spositiontaking_1509 = spositiontaking, @max_v202mpositiontaking_1509 = mpositiontaking, @auto_v202spositiontaking_1509 = autopositiontaking, @isauto_v202spositiontaking_1509 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1509 AND sporttype = 202
    SELECT @v202spositiontaking_1511 = spositiontaking, @max_v202mpositiontaking_1511 = mpositiontaking, @auto_v202spositiontaking_1511 = autopositiontaking, @isauto_v202spositiontaking_1511 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1511 AND sporttype = 202
    SELECT @v202spositiontaking_1513 = spositiontaking, @max_v202mpositiontaking_1513 = mpositiontaking, @auto_v202spositiontaking_1513 = autopositiontaking, @isauto_v202spositiontaking_1513 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1513 AND sporttype = 202
    SELECT @v202spositiontaking_1514 = spositiontaking, @max_v202mpositiontaking_1514 = mpositiontaking, @auto_v202spositiontaking_1514 = autopositiontaking, @isauto_v202spositiontaking_1514 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1514 AND sporttype = 202

    --max_a1 = min (a2,a4),max_m1 = min (m2,m4), max_m3 = min (m3,m4), s4
    SELECT @max_apositiontaking_1 = CASE WHEN @max_apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_1 END,@max_mpositiontaking_1 = CASE WHEN @max_mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_1 END,@mpositiontaking_1 = CASE WHEN @mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_1 END, @max_spositiontaking_1 = spositiontaking, @max_alivepositiontaking_1 = CASE WHEN @max_alivepositiontaking_1 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_1 END , @max_mlivepositiontaking_1 = CASE WHEN @max_mlivepositiontaking_1 < mlivepositiontaking THEN @max_mlivepositiontaking_1 ELSE mlivepositiontaking END, @mlivepositiontaking_1 = CASE WHEN @mlivepositiontaking_1 < mlivepositiontaking THEN @mlivepositiontaking_1 ELSE mlivepositiontaking END, @max_slivepositiontaking_1 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 1
    SELECT @max_apositiontaking_3 = CASE WHEN @max_apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_3 END,@max_mpositiontaking_3 = CASE WHEN @max_mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_3 END,@mpositiontaking_3 = CASE WHEN @mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_3 END, @max_spositiontaking_3 = spositiontaking, @max_alivepositiontaking_3 = CASE WHEN @max_alivepositiontaking_3 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_3 END , @max_mlivepositiontaking_3 = CASE WHEN @max_mlivepositiontaking_3 < mlivepositiontaking THEN @max_mlivepositiontaking_3 ELSE mlivepositiontaking END, @mlivepositiontaking_3 = CASE WHEN @mlivepositiontaking_3 < mlivepositiontaking THEN @mlivepositiontaking_3 ELSE mlivepositiontaking END, @max_slivepositiontaking_3 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype = 1
    SELECT @max_apositiontaking_7 = CASE WHEN @max_apositiontaking_7 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_7 END,@max_mpositiontaking_7 = CASE WHEN @max_mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_7 END,@mpositiontaking_7 = CASE WHEN @mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_7 END, @max_spositiontaking_7 = spositiontaking, @max_alivepositiontaking_7 = CASE WHEN @max_alivepositiontaking_7 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_7 END , @max_mlivepositiontaking_7 = CASE WHEN @max_mlivepositiontaking_7 < mlivepositiontaking THEN @max_mlivepositiontaking_7 ELSE mlivepositiontaking END, @mlivepositiontaking_7 = CASE WHEN @mlivepositiontaking_7 < mlivepositiontaking THEN @mlivepositiontaking_7 ELSE mlivepositiontaking END, @max_slivepositiontaking_7 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype = 1
    SELECT @max_apositiontaking_8 = CASE WHEN @max_apositiontaking_8 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_8 END,@max_mpositiontaking_8 = CASE WHEN @max_mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_8 END,@mpositiontaking_8 = CASE WHEN @mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_8 END, @max_spositiontaking_8 = spositiontaking, @max_alivepositiontaking_8 = CASE WHEN @max_alivepositiontaking_8 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_8 END , @max_mlivepositiontaking_8 = CASE WHEN @max_mlivepositiontaking_8 < mlivepositiontaking THEN @max_mlivepositiontaking_8 ELSE mlivepositiontaking END, @mlivepositiontaking_8 = CASE WHEN @mlivepositiontaking_8 < mlivepositiontaking THEN @mlivepositiontaking_8 ELSE mlivepositiontaking END, @max_slivepositiontaking_8 = slivepositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype = 1

    SELECT @max_apositiontaking_2 = CASE WHEN @max_apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_2 END,@max_mpositiontaking_2 = CASE WHEN @max_mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_2 END,@mpositiontaking_2 = CASE WHEN @mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_2 END, @max_spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype = 1
    SELECT @max_apositiontaking_4 = CASE WHEN @max_apositiontaking_4 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_4 END,@max_mpositiontaking_4 = CASE WHEN @max_mpositiontaking_4 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_4 END,@mpositiontaking_4 = CASE WHEN @mpositiontaking_4 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_4 END, @max_spositiontaking_4 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 4 AND sporttype = 1
    SELECT @max_apositiontaking_5 = CASE WHEN @max_apositiontaking_5 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_5 END,@max_mpositiontaking_5 = CASE WHEN @max_mpositiontaking_5 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_5 END,@mpositiontaking_5 = CASE WHEN @mpositiontaking_5 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_5 END, @max_spositiontaking_5 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 5 AND sporttype = 1
    SELECT @max_apositiontaking_6 = CASE WHEN @max_apositiontaking_6 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_6 END,@max_mpositiontaking_6 = CASE WHEN @max_mpositiontaking_6 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_6 END,@mpositiontaking_6 = CASE WHEN @mpositiontaking_6 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_6 END, @max_spositiontaking_6 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=6 AND sporttype = 1
    SELECT @max_apositiontaking_9 = CASE WHEN @max_apositiontaking_9 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_9 END,@max_mpositiontaking_9 = CASE WHEN @max_mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_9 END,@mpositiontaking_9 = CASE WHEN @mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_9 END, @max_spositiontaking_9 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype = 1
    SELECT @max_apositiontaking_10 = CASE WHEN @max_apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_10 END,@max_mpositiontaking_10 = CASE WHEN @max_mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_10 END,@mpositiontaking_10 = CASE WHEN @mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_10 END, @max_spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 1
    SELECT @max_v2apositiontaking_10 = CASE WHEN @max_v2apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_10 END,@max_v2mpositiontaking_10 = CASE WHEN @max_v2mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_10 END,@v2mpositiontaking_10 = CASE WHEN @v2mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_10 END, @max_v2spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 2
    SELECT @max_v3apositiontaking_10 = CASE WHEN @max_v3apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_10 END,@max_v3mpositiontaking_10 = CASE WHEN @max_v3mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_10 END,@v3mpositiontaking_10 = CASE WHEN @v3mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_10 END, @max_v3spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 3
    SELECT @max_v5apositiontaking_10 = CASE WHEN @max_v5apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_10 END,@max_v5mpositiontaking_10 = CASE WHEN @max_v5mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_10 END,@v5mpositiontaking_10 = CASE WHEN @v5mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_10 END, @max_v5spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 5
    SELECT @max_v8apositiontaking_10 = CASE WHEN @max_v8apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_10 END,@max_v8mpositiontaking_10 = CASE WHEN @max_v8mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_10 END,@v8mpositiontaking_10 = CASE WHEN @v8mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_10 END, @max_v8spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 8
    SELECT @max_v10apositiontaking_10 = CASE WHEN @max_v10apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_10 END,@max_v10mpositiontaking_10 = CASE WHEN @max_v10mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_10 END,@v10mpositiontaking_10 = CASE WHEN @v10mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_10 END, @max_v10spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 10
    SELECT @max_v11apositiontaking_10 = CASE WHEN @max_v11apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v11apositiontaking_10 END,@max_v11mpositiontaking_10 = CASE WHEN @max_v11mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v11mpositiontaking_10 END,@v11mpositiontaking_10 = CASE WHEN @v11mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v11mpositiontaking_10 END, @max_v11spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 11
    SELECT @max_v99apositiontaking_10 = CASE WHEN @max_v99apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_10 END,@max_v99mpositiontaking_10 = CASE WHEN @max_v99mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_10 END,@v99mpositiontaking_10 = CASE WHEN @v99mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_10 END, @max_v99spositiontaking_10 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 10 AND sporttype = 99
    SELECT @max_apositiontaking_9999 = CASE WHEN @max_apositiontaking_9999 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_9999 END,@max_mpositiontaking_9999 = CASE WHEN @max_mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_9999 END,@mpositiontaking_9999 = CASE WHEN @mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_9999 END, @max_spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype = 1

    SELECT @max_v2apositiontaking_1 = CASE WHEN @max_v2apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_1 END,@max_v2mpositiontaking_1 = CASE WHEN @max_v2mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_1 END, @v2mpositiontaking_1 = CASE WHEN @v2mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_1 END, @max_v2spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype=2
    SELECT @max_v2apositiontaking_2 = CASE WHEN @max_v2apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_2 END,@max_v2mpositiontaking_2 = CASE WHEN @max_v2mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_2 END, @v2mpositiontaking_2 = CASE WHEN @v2mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_2 END, @max_v2spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=2
    SELECT @max_v2apositiontaking_3 = CASE WHEN @max_v2apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_3 END,@max_v2mpositiontaking_3 = CASE WHEN @max_v2mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_3 END, @v2mpositiontaking_3 = CASE WHEN @v2mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_3 END, @max_v2spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype=2
    SELECT @max_v2apositiontaking_7 = CASE WHEN @max_v2apositiontaking_7 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_7 END,@max_v2mpositiontaking_7 = CASE WHEN @max_v2mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_7 END, @v2mpositiontaking_7 = CASE WHEN @v2mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_7 END, @max_v2spositiontaking_7 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=2
    SELECT @max_v2apositiontaking_8 = CASE WHEN @max_v2apositiontaking_8 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_8 END,@max_v2mpositiontaking_8 = CASE WHEN @max_v2mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_8 END, @v2mpositiontaking_8 = CASE WHEN @v2mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_8 END, @max_v2spositiontaking_8 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=2
    SELECT @max_v2apositiontaking_20 = CASE WHEN @max_v2apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_20 END,@max_v2mpositiontaking_20 = CASE WHEN @max_v2mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_20 END, @v2mpositiontaking_20 = CASE WHEN @v2mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_20 END, @max_v2spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=2
    
    SELECT @max_v2apositiontaking_9999 = CASE WHEN @max_v2apositiontaking_9999 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_9999 END,@max_v2mpositiontaking_9999 = CASE WHEN @max_v2mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_9999 END, @v2mpositiontaking_9999 = CASE WHEN @v2mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_9999 END, @max_v2spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=2

    SELECT @max_v3apositiontaking_1 = CASE WHEN @max_v3apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_1 END,@max_v3mpositiontaking_1 = CASE WHEN @max_v3mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_1 END, @v3mpositiontaking_1 = CASE WHEN @v3mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_1 END, @max_v3spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 3
    SELECT @max_v3apositiontaking_2 = CASE WHEN @max_v3apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_2 END,@max_v3mpositiontaking_2 = CASE WHEN @max_v3mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_2 END, @v3mpositiontaking_2 = CASE WHEN @v3mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_2 END, @max_v3spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype = 3
    SELECT @max_v3apositiontaking_3 = CASE WHEN @max_v3apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_3 END,@max_v3mpositiontaking_3 = CASE WHEN @max_v3mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_3 END, @v3mpositiontaking_3 = CASE WHEN @v3mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_3 END, @max_v3spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype = 3
    SELECT @max_v3apositiontaking_20 = CASE WHEN @max_v3apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_20 END,@max_v3mpositiontaking_20 = CASE WHEN @max_v3mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_20 END, @v3mpositiontaking_20 = CASE WHEN @v3mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_20 END, @max_v3spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype = 3

    SELECT @max_v5apositiontaking_1 = CASE WHEN @max_v5apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_1 END,@max_v5mpositiontaking_1 = CASE WHEN @max_v5mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_1 END, @v5mpositiontaking_1 = CASE WHEN @v5mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_1 END, @max_v5spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 5
    SELECT @max_v5apositiontaking_2 = CASE WHEN @max_v5apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_2 END,@max_v5mpositiontaking_2 = CASE WHEN @max_v5mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_2 END, @v5mpositiontaking_2 = CASE WHEN @v5mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_2 END, @max_v5spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype = 5
    SELECT @max_v5apositiontaking_3 = CASE WHEN @max_v5apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_3 END,@max_v5mpositiontaking_3 = CASE WHEN @max_v5mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_3 END, @v5mpositiontaking_3 = CASE WHEN @v5mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_3 END, @max_v5spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype = 5
    SELECT @max_v5apositiontaking_20 = CASE WHEN @max_v5apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_20 END,@max_v5mpositiontaking_20 = CASE WHEN @max_v5mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_20 END, @v5mpositiontaking_20 = CASE WHEN @v5mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_20 END, @max_v5spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype = 5
    SELECT @max_v5apositiontaking_9999 = CASE WHEN @max_v5apositiontaking_9999 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_9999 END,@max_v5mpositiontaking_9999 = CASE WHEN @max_v5mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_9999 END, @v5mpositiontaking_9999 = CASE WHEN @v5mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_9999 END, @max_v5spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype = 5

    SELECT @max_v8apositiontaking_1 = CASE WHEN @max_v8apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_1 END,@max_v8mpositiontaking_1 = CASE WHEN @max_v8mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_1 END, @v8mpositiontaking_1 = CASE WHEN @v8mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_1 END, @max_v8spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype=8
    SELECT @max_v8apositiontaking_3 = CASE WHEN @max_v8apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_3 END,@max_v8mpositiontaking_3 = CASE WHEN @max_v8mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_3 END, @v8mpositiontaking_3 = CASE WHEN @v8mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_3 END, @max_v8spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype=8
    SELECT @max_v8apositiontaking_20 = CASE WHEN @max_v8apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_20 END,@max_v8mpositiontaking_20 = CASE WHEN @max_v8mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_20 END, @v8mpositiontaking_20 = CASE WHEN @v8mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_20 END, @max_v8spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=8

    SELECT @max_v10apositiontaking_1 = CASE WHEN @max_v10apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_1 END,@max_v10mpositiontaking_1 = CASE WHEN @max_v10mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_1 END, @v10mpositiontaking_1 = CASE WHEN @v10mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_1 END, @max_v10spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 10
    SELECT @max_v10apositiontaking_2 = CASE WHEN @max_v10apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_2 END,@max_v10mpositiontaking_2 = CASE WHEN @max_v10mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_2 END, @v10mpositiontaking_2 = CASE WHEN @v10mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_2 END, @max_v10spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype = 10
    SELECT @max_v10apositiontaking_3 = CASE WHEN @max_v10apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_3 END,@max_v10mpositiontaking_3 = CASE WHEN @max_v10mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_3 END, @v10mpositiontaking_3 = CASE WHEN @v10mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_3 END, @max_v10spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype = 10
    SELECT @max_v10apositiontaking_20 = CASE WHEN @max_v10apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_20 END,@max_v10mpositiontaking_20 = CASE WHEN @max_v10mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_20 END, @v10mpositiontaking_20 = CASE WHEN @v10mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_20 END, @max_v10spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype = 10

    SELECT @max_v11apositiontaking_1 = CASE WHEN @max_v11apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v11apositiontaking_1 END,@max_v11mpositiontaking_1 = CASE WHEN @max_v11mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v11mpositiontaking_1 END, @v11mpositiontaking_1 = CASE WHEN @v11mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v11mpositiontaking_1 END, @max_v11spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 11
    SELECT @max_v11apositiontaking_20 = CASE WHEN @max_v11apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v11apositiontaking_20 END,@max_v11mpositiontaking_20 = CASE WHEN @max_v11mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v11mpositiontaking_20 END, @v11mpositiontaking_20 = CASE WHEN @v11mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v11mpositiontaking_20 END, @max_v11spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype = 11

    SELECT @max_v99apositiontaking_1 = CASE WHEN @max_v99apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_1 END,@max_v99mpositiontaking_1 = CASE WHEN @max_v99mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_1 END, @v99mpositiontaking_1 = CASE WHEN @v99mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_1 END, @max_v99spositiontaking_1 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype=99
    SELECT @max_v99apositiontaking_2 = CASE WHEN @max_v99apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_2 END,@max_v99mpositiontaking_2 = CASE WHEN @max_v99mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_2 END, @v99mpositiontaking_2 = CASE WHEN @v99mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_2 END, @max_v99spositiontaking_2 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=99
    SELECT @max_v99apositiontaking_3 = CASE WHEN @max_v99apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_3 END,@max_v99mpositiontaking_3 = CASE WHEN @max_v99mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_3 END, @v99mpositiontaking_3 = CASE WHEN @v99mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_3 END, @max_v99spositiontaking_3 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype=99
    SELECT @max_v99apositiontaking_9 = CASE WHEN @max_v99apositiontaking_9 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_9 END,@max_v99mpositiontaking_9 = CASE WHEN @max_v99mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_9 END, @v99mpositiontaking_9 = CASE WHEN @v99mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_9 END, @max_v99spositiontaking_9 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=99
    SELECT @max_v99apositiontaking_20 = CASE WHEN @max_v99apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_20 END,@max_v99mpositiontaking_20 = CASE WHEN @max_v99mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_20 END, @v99mpositiontaking_20 = CASE WHEN @v99mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_20 END, @max_v99spositiontaking_20 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=99
	SELECT @max_v99apositiontaking_9999 = CASE WHEN @max_v99apositiontaking_9999 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_9999 END,@max_v99mpositiontaking_9999 = CASE WHEN @max_v99mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_9999 END, @v99mpositiontaking_9999 = CASE WHEN @v99mpositiontaking_9999 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_9999 END, @max_v99spositiontaking_9999 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=99
 
    --v161
    SELECT @max_v161apositiontaking_81 = CASE WHEN @max_v161apositiontaking_81 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_81 END,@max_v161mpositiontaking_81 = CASE WHEN @max_v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_81 END, @v161mpositiontaking_81 = CASE WHEN @v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_81 END, @max_v161spositiontaking_81 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=81 AND sporttype = 161
    SELECT @max_v161apositiontaking_83 = CASE WHEN @max_v161apositiontaking_83 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_83 END,@max_v161mpositiontaking_83 = CASE WHEN @max_v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_83 END,@v161mpositiontaking_83 = CASE WHEN @v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_83 END,@max_v161spositiontaking_83 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=83 AND sporttype = 161
    SELECT @max_v161apositiontaking_88 = CASE WHEN @max_v161apositiontaking_88 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_88 END,@max_v161mpositiontaking_88 = CASE WHEN @max_v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_88 END,@v161mpositiontaking_88 = CASE WHEN @v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_88 END,@max_v161spositiontaking_88 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=88 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_85 = CASE WHEN @max_v161alivepositiontaking_85 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_85 END,@max_v161mlivepositiontaking_85 = CASE WHEN @max_v161mlivepositiontaking_85 < mlivepositiontaking THEN @max_v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @v161mlivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85 < mlivepositiontaking THEN @v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_85 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=85 AND sporttype = 161
    SELECT @max_v161apositiontaking_86 = CASE WHEN @max_v161apositiontaking_86 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_86 END,@max_v161mpositiontaking_86 = CASE WHEN @max_v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_86 END,@v161mpositiontaking_86 = CASE WHEN @v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_86 END,@max_v161spositiontaking_86 = spositiontaking, @max_v161alivepositiontaking_86 = CASE WHEN @max_v161alivepositiontaking_86 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_86 END, @max_v161mlivepositiontaking_86 = CASE WHEN @max_v161mlivepositiontaking_86 < mlivepositiontaking THEN @max_v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @v161mlivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86 < mlivepositiontaking THEN @v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_86 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=86 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_87 = CASE WHEN @max_v161alivepositiontaking_87 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_87 END,@max_v161mlivepositiontaking_87 = CASE WHEN @max_v161mlivepositiontaking_87 < mlivepositiontaking THEN @max_v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@v161mlivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87 < mlivepositiontaking THEN @v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_87 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=87 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_89 = CASE WHEN @max_v161alivepositiontaking_89 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_89 END,@max_v161mlivepositiontaking_89 = CASE WHEN @max_v161mlivepositiontaking_89 < mlivepositiontaking THEN @max_v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@v161mlivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89 < mlivepositiontaking THEN @v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_89 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=89 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_90 = CASE WHEN @max_v161alivepositiontaking_90 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_90 END,@max_v161mlivepositiontaking_90 = CASE WHEN @max_v161mlivepositiontaking_90 < mlivepositiontaking THEN @max_v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@v161mlivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90 < mlivepositiontaking THEN @v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_90 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=90 AND sporttype = 161

    --v202
    SELECT @max_v202spositiontaking_1501 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1501 AND sporttype = 202
    SELECT @max_v202spositiontaking_1503 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1503 AND sporttype = 202
    SELECT @max_v202spositiontaking_1504 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1504 AND sporttype = 202
    SELECT @max_v202spositiontaking_1505 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1505 AND sporttype = 202
    SELECT @max_v202spositiontaking_1507 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1507 AND sporttype = 202
    SELECT @max_v202spositiontaking_1508 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1508 AND sporttype = 202
    SELECT @max_v202spositiontaking_1509 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1509 AND sporttype = 202
    SELECT @max_v202spositiontaking_1511 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1511 AND sporttype = 202
    SELECT @max_v202spositiontaking_1513 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1513 AND sporttype = 202
    SELECT @max_v202spositiontaking_1514 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1514 AND sporttype = 202

    --check a1<=min(a2,a4) - Vinh
    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar(max_apositiontaking)
    + CASE WHEN b.sporttype in (1,161) AND b.bettype in (1,3,7,8,85,86,87,89,90) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar(max_alivepositiontaking) ELSE '' END + '<br>'
    FROM #tmp_Sports sports inner join
    (
			    SELECT 1 AS bettype, 1 AS sporttype, @apositiontaking_1 AS apositiontaking, @alivepositiontaking_1 AS alivepositiontaking, @max_apositiontaking_1 AS max_apositiontaking,  @max_alivepositiontaking_1 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @apositiontaking_3 AS apositiontaking, @alivepositiontaking_3 AS alivepositiontaking, @max_apositiontaking_3 AS max_apositiontaking,  @max_alivepositiontaking_3 AS max_alivepositiontaking
	    UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @apositiontaking_7 AS apositiontaking, @alivepositiontaking_7 AS alivepositiontaking, @max_apositiontaking_7 AS max_apositiontaking,  @max_alivepositiontaking_7 AS max_alivepositiontaking
	    UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @apositiontaking_8 AS apositiontaking, @alivepositiontaking_8 AS alivepositiontaking, @max_apositiontaking_8 AS max_apositiontaking,  @max_alivepositiontaking_8 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @apositiontaking_4 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_4 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @apositiontaking_5 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_5 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @apositiontaking_6 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_6 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @apositiontaking_9 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_9 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @v2apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @v3apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v3apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @v5apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @v8apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v8apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @v10apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v10apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @v11apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v11apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @v99apositiontaking_10 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_10 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    
	    UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @apositiontaking_9999 AS apositiontaking, 0 AS alivepositiontaking, @max_apositiontaking_9999 AS max_apositiontaking,  0 AS max_alivepositiontaking

	    UNION ALL 	SELECT 1 AS bettype, 2 AS sporttype, @v2apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @v2apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @v2apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
		UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @v2apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    
	    UNION ALL 	SELECT 9999 AS bettype, 2 AS sporttype, @v2apositiontaking_9999 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_9999 AS max_apositiontaking,  0 AS max_alivepositiontaking

	    UNION ALL 	SELECT 1 AS bettype, 3 AS sporttype, @v3apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v3apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @v3apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_v3apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking

	    UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @v3apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v3apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @v3apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v3apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
    	
	    UNION ALL 	SELECT 1 AS bettype, 5 AS sporttype, @v5apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @v5apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @v5apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @v5apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @v5apositiontaking_9999 AS apositiontaking, 0 AS alivepositiontaking, @max_v5apositiontaking_9999 AS max_apositiontaking,  0 AS max_alivepositiontaking
    	
	    UNION ALL 	SELECT 1 AS bettype, 8 AS sporttype, @v8apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v8apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v8apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v8apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
    	
	    UNION ALL 	SELECT 1 AS bettype, 10 AS sporttype, @v10apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v10apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @v10apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_v10apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @v10apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v10apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @v10apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v10apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
    	
	    UNION ALL 	SELECT 1 AS bettype, 11 AS sporttype, @v11apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v11apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @v11apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v11apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking

	    UNION ALL 	SELECT 1 AS bettype, 99 AS sporttype, @v99apositiontaking_1 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_1 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @v99apositiontaking_2 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_2 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @v99apositiontaking_3 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_3 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @v99apositiontaking_20 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_20 AS max_apositiontaking,  0 AS max_alivepositiontaking
		UNION ALL 	SELECT 9999 AS bettype, 99 AS sporttype, @v99apositiontaking_9999 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_9999 AS max_apositiontaking,  0 AS max_alivepositiontaking
    	
	    UNION ALL 	SELECT 9 AS bettype, 99 AS sporttype, @v99apositiontaking_9 AS apositiontaking, 0 AS alivepositiontaking, @max_v99apositiontaking_9 AS max_apositiontaking,  0 AS max_alivepositiontaking	   
    	
	    UNION ALL 	SELECT 81 AS bettype, 161 AS sporttype, @v161apositiontaking_81 AS apositiontaking, 0 AS alivepositiontaking, @max_v161apositiontaking_81 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161apositiontaking_83 AS apositiontaking, 0 AS alivepositiontaking, @max_v161apositiontaking_83 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161apositiontaking_88 AS apositiontaking, 0 AS alivepositiontaking, @max_v161apositiontaking_88 AS max_apositiontaking,  0 AS max_alivepositiontaking
	    UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS apositiontaking, @v161alivepositiontaking_85 AS alivepositiontaking, 0 AS max_apositiontaking,  @max_v161alivepositiontaking_85 AS max_alivepositiontaking
	    UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161apositiontaking_86 AS apositiontaking, @v161alivepositiontaking_86 AS alivepositiontaking, @max_v161apositiontaking_86 AS max_apositiontaking,  @max_v161alivepositiontaking_86 AS max_alivepositiontaking
	    UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS apositiontaking, @v161alivepositiontaking_87 AS alivepositiontaking, 0 AS max_apositiontaking,  @max_v161alivepositiontaking_87 AS max_alivepositiontaking
	    UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS apositiontaking, @v161alivepositiontaking_89 AS alivepositiontaking, 0 AS max_apositiontaking,  @max_v161alivepositiontaking_89 AS max_alivepositiontaking
	    UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS apositiontaking, @v161alivepositiontaking_90 AS alivepositiontaking, 0 AS max_apositiontaking,  @max_v161alivepositiontaking_90 AS max_alivepositiontaking
    			
	    ) AS b on sports.ID = b.sporttype
	    inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	    WHERE (apositiontaking>max_apositiontaking)
		    OR (alivepositiontaking >max_alivepositiontaking)

    IF @ErrType <>''
    BEGIN
	    SELECT
		    @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Wrong agent position taking.<br>'+@ErrType
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](20008,@Language) + '<br>'  +@ErrType
					    END,
		    @success = 0, @ErrCode = 203
	    return
    END

    ----------------***Use Master Auto Position Taking***----------------------------------
    --use @auto_mpt at agent
    --@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
    --IF u2 = 0 THEN m1 = m2
    --else	IF u2 < m3 - a1 THEN m1 = u2
    --		else m1 = m3 - a1

    SELECT @mpositiontaking_1 = CASE WHEN ISNULL(@isauto_mpositiontaking_1, 0) = 0 THEN @mpositiontaking_1 ELSE CASE WHEN @auto_mpositiontaking_1 < @max_mpositiontaking_1 - @apositiontaking_1 THEN @auto_mpositiontaking_1 ELSE @max_mpositiontaking_1 - @apositiontaking_1 END END
    SELECT @mpositiontaking_3 = CASE WHEN ISNULL(@isauto_mpositiontaking_3, 0) = 0 THEN @mpositiontaking_3 ELSE CASE WHEN @auto_mpositiontaking_3 < @max_mpositiontaking_3 - @apositiontaking_3 THEN @auto_mpositiontaking_3 ELSE @max_mpositiontaking_3 - @apositiontaking_3 END END
    SELECT @mpositiontaking_7 = CASE WHEN ISNULL(@isauto_mpositiontaking_7, 0) = 0 THEN @mpositiontaking_7 ELSE CASE WHEN @auto_mpositiontaking_7 < @max_mpositiontaking_7 - @apositiontaking_7 THEN @auto_mpositiontaking_7 ELSE @max_mpositiontaking_7 - @apositiontaking_7 END END
    SELECT @mpositiontaking_8 = CASE WHEN ISNULL(@isauto_mpositiontaking_8, 0) = 0 THEN @mpositiontaking_8 ELSE CASE WHEN @auto_mpositiontaking_8 < @max_mpositiontaking_8 - @apositiontaking_8 THEN @auto_mpositiontaking_8 ELSE @max_mpositiontaking_8 - @apositiontaking_8 END END

    SELECT @mlivepositiontaking_1 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_1, 0) = 0 THEN @mlivepositiontaking_1 ELSE CASE WHEN @auto_mlivepositiontaking_1 < @max_mlivepositiontaking_1 - @alivepositiontaking_1 THEN @auto_mlivepositiontaking_1 ELSE @max_mlivepositiontaking_1 - @alivepositiontaking_1 END END
    SELECT @mlivepositiontaking_3 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_3, 0) = 0 THEN @mlivepositiontaking_3 ELSE CASE WHEN @auto_mlivepositiontaking_3 < @max_mlivepositiontaking_3 - @alivepositiontaking_3 THEN @auto_mlivepositiontaking_3 ELSE @max_mlivepositiontaking_3 - @alivepositiontaking_3 END END
    SELECT @mlivepositiontaking_7 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_7, 0) = 0 THEN @mlivepositiontaking_7 ELSE CASE WHEN @auto_mlivepositiontaking_7 < @max_mlivepositiontaking_7 - @alivepositiontaking_7 THEN @auto_mlivepositiontaking_7 ELSE @max_mlivepositiontaking_7 - @alivepositiontaking_7 END END
    SELECT @mlivepositiontaking_8 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_8, 0) = 0 THEN @mlivepositiontaking_8 ELSE CASE WHEN @auto_mlivepositiontaking_8 < @max_mlivepositiontaking_8 - @alivepositiontaking_8 THEN @auto_mlivepositiontaking_8 ELSE @max_mlivepositiontaking_8 - @alivepositiontaking_8 END END

    SELECT @mpositiontaking_2 = CASE WHEN ISNULL(@isauto_mpositiontaking_2, 0) = 0 THEN @mpositiontaking_2 ELSE CASE WHEN @auto_mpositiontaking_2 < @max_mpositiontaking_2 - @apositiontaking_2 THEN @auto_mpositiontaking_2 ELSE @max_mpositiontaking_2 - @apositiontaking_2 END END
    SELECT @mpositiontaking_4 = CASE WHEN ISNULL(@isauto_mpositiontaking_4, 0) = 0 THEN @mpositiontaking_4 ELSE CASE WHEN @auto_mpositiontaking_4 < @max_mpositiontaking_4 - @apositiontaking_4 THEN @auto_mpositiontaking_4 ELSE @max_mpositiontaking_4 - @apositiontaking_4 END END
    SELECT @mpositiontaking_5 = CASE WHEN ISNULL(@isauto_mpositiontaking_5, 0) = 0 THEN @mpositiontaking_5 ELSE CASE WHEN @auto_mpositiontaking_5 < @max_mpositiontaking_5 - @apositiontaking_5 THEN @auto_mpositiontaking_5 ELSE @max_mpositiontaking_5 - @apositiontaking_5 END END
    SELECT @mpositiontaking_6 = CASE WHEN ISNULL(@isauto_mpositiontaking_6, 0) = 0 THEN @mpositiontaking_6 ELSE CASE WHEN @auto_mpositiontaking_6 < @max_mpositiontaking_6 - @apositiontaking_6 THEN @auto_mpositiontaking_6 ELSE @max_mpositiontaking_6 - @apositiontaking_6 END END
    SELECT @mpositiontaking_9 = CASE WHEN ISNULL(@isauto_mpositiontaking_9, 0) = 0 THEN @mpositiontaking_9 ELSE CASE WHEN @auto_mpositiontaking_9 < @max_mpositiontaking_9 - @apositiontaking_9 THEN @auto_mpositiontaking_9 ELSE @max_mpositiontaking_9 - @apositiontaking_9 END END
    SELECT @mpositiontaking_10 = CASE WHEN ISNULL(@isauto_mpositiontaking_10, 0) = 0 THEN @mpositiontaking_10 ELSE CASE WHEN @auto_mpositiontaking_10 < @max_mpositiontaking_10 - @apositiontaking_10 THEN @auto_mpositiontaking_10 ELSE @max_mpositiontaking_10 - @apositiontaking_10 END END
    SELECT @v2mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_10, 0) = 0 THEN @v2mpositiontaking_10 ELSE CASE WHEN @auto_v2mpositiontaking_10 < @max_v2mpositiontaking_10 - @v2apositiontaking_10 THEN @auto_v2mpositiontaking_10 ELSE @max_v2mpositiontaking_10 - @v2apositiontaking_10 END END
    SELECT @v3mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_10, 0) = 0 THEN @v3mpositiontaking_10 ELSE CASE WHEN @auto_v3mpositiontaking_10 < @max_v3mpositiontaking_10 - @v3apositiontaking_10 THEN @auto_v3mpositiontaking_10 ELSE @max_v3mpositiontaking_10 - @v3apositiontaking_10 END END
    SELECT @v5mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_10, 0) = 0 THEN @v5mpositiontaking_10 ELSE CASE WHEN @auto_v5mpositiontaking_10 < @max_v5mpositiontaking_10 - @v5apositiontaking_10 THEN @auto_v5mpositiontaking_10 ELSE @max_v5mpositiontaking_10 - @v5apositiontaking_10 END END
    SELECT @v8mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_10, 0) = 0 THEN @v8mpositiontaking_10 ELSE CASE WHEN @auto_v8mpositiontaking_10 < @max_v8mpositiontaking_10 - @v8apositiontaking_10 THEN @auto_v8mpositiontaking_10 ELSE @max_v8mpositiontaking_10 - @v8apositiontaking_10 END END
    SELECT @v10mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_10, 0) = 0 THEN @v10mpositiontaking_10 ELSE CASE WHEN @auto_v10mpositiontaking_10 < @max_v10mpositiontaking_10 - @v10apositiontaking_10 THEN @auto_v10mpositiontaking_10 ELSE @max_v10mpositiontaking_10 - @v10apositiontaking_10 END END
    SELECT @v11mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_10, 0) = 0 THEN @v11mpositiontaking_10 ELSE CASE WHEN @auto_v11mpositiontaking_10 < @max_v11mpositiontaking_10 - @v11apositiontaking_10 THEN @auto_v11mpositiontaking_10 ELSE @max_v11mpositiontaking_10 - @v11apositiontaking_10 END END
    SELECT @v99mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_10, 0) = 0 THEN @v99mpositiontaking_10 ELSE CASE WHEN @auto_v99mpositiontaking_10 < @max_v99mpositiontaking_10 - @v99apositiontaking_10 THEN @auto_v99mpositiontaking_10 ELSE @max_v99mpositiontaking_10 - @v99apositiontaking_10 END END                                
    SELECT @mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_mpositiontaking_9999, 0) = 0 THEN @mpositiontaking_9999 ELSE CASE WHEN @auto_mpositiontaking_9999 < @max_mpositiontaking_9999 - @apositiontaking_9999 THEN @auto_mpositiontaking_9999 ELSE @max_mpositiontaking_9999 - @apositiontaking_9999 END END

    SELECT @v2mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_1, 0) = 0 THEN @v2mpositiontaking_1 ELSE CASE WHEN @auto_v2mpositiontaking_1 < @max_v2mpositiontaking_1 - @v2apositiontaking_1 THEN @auto_v2mpositiontaking_1 ELSE @max_v2mpositiontaking_1 - @v2apositiontaking_1 END END
    SELECT @v2mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_2, 0) = 0 THEN @v2mpositiontaking_2 ELSE CASE WHEN @auto_v2mpositiontaking_2 < @max_v2mpositiontaking_2 - @v2apositiontaking_2 THEN @auto_v2mpositiontaking_2 ELSE @max_v2mpositiontaking_2 - @v2apositiontaking_2 END END
    SELECT @v2mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_3, 0) = 0 THEN @v2mpositiontaking_3 ELSE CASE WHEN @auto_v2mpositiontaking_3 < @max_v2mpositiontaking_3 - @v2apositiontaking_3 THEN @auto_v2mpositiontaking_3 ELSE @max_v2mpositiontaking_3 - @v2apositiontaking_3 END END
    SELECT @v2mpositiontaking_7 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_7, 0) = 0 THEN @v2mpositiontaking_7 ELSE CASE WHEN @auto_v2mpositiontaking_7 < @max_v2mpositiontaking_7 - @v2apositiontaking_7 THEN @auto_v2mpositiontaking_7 ELSE @max_v2mpositiontaking_7 - @v2apositiontaking_7 END END
    SELECT @v2mpositiontaking_8 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_8, 0) = 0 THEN @v2mpositiontaking_8 ELSE CASE WHEN @auto_v2mpositiontaking_8 < @max_v2mpositiontaking_8 - @v2apositiontaking_8 THEN @auto_v2mpositiontaking_8 ELSE @max_v2mpositiontaking_8 - @v2apositiontaking_8 END END
    SELECT @v2mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_20, 0) = 0 THEN @v2mpositiontaking_20 ELSE CASE WHEN @auto_v2mpositiontaking_20 < @max_v2mpositiontaking_20 - @v2apositiontaking_20 THEN @auto_v2mpositiontaking_20 ELSE @max_v2mpositiontaking_20 - @v2apositiontaking_20 END END
    
    SELECT @v2mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_9999, 0) = 0 THEN @v2mpositiontaking_9999 ELSE CASE WHEN @auto_v2mpositiontaking_9999 < @max_v2mpositiontaking_9999 - @v2apositiontaking_9999 THEN @auto_v2mpositiontaking_9999 ELSE @max_v2mpositiontaking_9999 - @v2apositiontaking_9999 END END

    SELECT @v3mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_1, 0) = 0 THEN @v3mpositiontaking_1 ELSE CASE WHEN @auto_v3mpositiontaking_1 < @max_v3mpositiontaking_1 - @v3apositiontaking_1 THEN @auto_v3mpositiontaking_1 ELSE @max_v3mpositiontaking_1 - @v3apositiontaking_1 END END
    SELECT @v3mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_2, 0) = 0 THEN @v3mpositiontaking_2 ELSE CASE WHEN @auto_v3mpositiontaking_2 < @max_v3mpositiontaking_2 - @v3apositiontaking_2 THEN @auto_v3mpositiontaking_2 ELSE @max_v3mpositiontaking_2 - @v3apositiontaking_2 END END
    SELECT @v3mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_3, 0) = 0 THEN @v3mpositiontaking_3 ELSE CASE WHEN @auto_v3mpositiontaking_3 < @max_v3mpositiontaking_3 - @v3apositiontaking_3 THEN @auto_v3mpositiontaking_3 ELSE @max_v3mpositiontaking_3 - @v3apositiontaking_3 END END
    SELECT @v3mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_20, 0) = 0 THEN @v3mpositiontaking_20 ELSE CASE WHEN @auto_v3mpositiontaking_20 < @max_v3mpositiontaking_20 - @v3apositiontaking_20 THEN @auto_v3mpositiontaking_20 ELSE @max_v3mpositiontaking_20 - @v3apositiontaking_20 END END

    SELECT @v5mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_1, 0) = 0 THEN @v5mpositiontaking_1 ELSE CASE WHEN @auto_v5mpositiontaking_1 < @max_v5mpositiontaking_1 - @v5apositiontaking_1 THEN @auto_v5mpositiontaking_1 ELSE @max_v5mpositiontaking_1 - @v5apositiontaking_1 END END
    SELECT @v5mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_2, 0) = 0 THEN @v5mpositiontaking_2 ELSE CASE WHEN @auto_v5mpositiontaking_2 < @max_v5mpositiontaking_2 - @v5apositiontaking_2 THEN @auto_v5mpositiontaking_2 ELSE @max_v5mpositiontaking_2 - @v5apositiontaking_2 END END
    SELECT @v5mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_3, 0) = 0 THEN @v5mpositiontaking_3 ELSE CASE WHEN @auto_v5mpositiontaking_3 < @max_v5mpositiontaking_3 - @v5apositiontaking_3 THEN @auto_v5mpositiontaking_3 ELSE @max_v5mpositiontaking_3 - @v5apositiontaking_3 END END
    SELECT @v5mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_20, 0) = 0 THEN @v5mpositiontaking_20 ELSE CASE WHEN @auto_v5mpositiontaking_20 < @max_v5mpositiontaking_20 - @v5apositiontaking_20 THEN @auto_v5mpositiontaking_20 ELSE @max_v5mpositiontaking_20 - @v5apositiontaking_20 END END
    SELECT @v5mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_9999, 0) = 0 THEN @v5mpositiontaking_9999 ELSE CASE WHEN @auto_v5mpositiontaking_9999 < @max_v5mpositiontaking_9999 - @v5apositiontaking_9999 THEN @auto_v5mpositiontaking_9999 ELSE @max_v5mpositiontaking_9999 - @v5apositiontaking_9999 END END

    SELECT @v8mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_1, 0) = 0 THEN @v8mpositiontaking_1 ELSE CASE WHEN @auto_v8mpositiontaking_1 < @max_v8mpositiontaking_1 - @v8apositiontaking_1 THEN @auto_v8mpositiontaking_1 ELSE @max_v8mpositiontaking_1 - @v8apositiontaking_1 END END
    SELECT @v8mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_3, 0) = 0 THEN @v8mpositiontaking_3 ELSE CASE WHEN @auto_v8mpositiontaking_3 < @max_v8mpositiontaking_3 - @v8apositiontaking_3 THEN @auto_v8mpositiontaking_3 ELSE @max_v8mpositiontaking_3 - @v8apositiontaking_3 END END
    SELECT @v8mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_20, 0) = 0 THEN @v8mpositiontaking_20 ELSE CASE WHEN @auto_v8mpositiontaking_20 < @max_v8mpositiontaking_20 - @v8apositiontaking_20 THEN @auto_v8mpositiontaking_20 ELSE @max_v8mpositiontaking_20 - @v8apositiontaking_20 END END

    SELECT @v10mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_1, 0) = 0 THEN @v10mpositiontaking_1 ELSE CASE WHEN @auto_v10mpositiontaking_1 < @max_v10mpositiontaking_1 - @v10apositiontaking_1 THEN @auto_v10mpositiontaking_1 ELSE @max_v10mpositiontaking_1 - @v10apositiontaking_1 END END
    SELECT @v10mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_2, 0) = 0 THEN @v10mpositiontaking_2 ELSE CASE WHEN @auto_v10mpositiontaking_2 < @max_v10mpositiontaking_2 - @v10apositiontaking_2 THEN @auto_v10mpositiontaking_2 ELSE @max_v10mpositiontaking_2 - @v10apositiontaking_2 END END
    SELECT @v10mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_3, 0) = 0 THEN @v10mpositiontaking_3 ELSE CASE WHEN @auto_v10mpositiontaking_3 < @max_v10mpositiontaking_3 - @v10apositiontaking_3 THEN @auto_v10mpositiontaking_3 ELSE @max_v10mpositiontaking_3 - @v10apositiontaking_3 END END
    SELECT @v10mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_20, 0) = 0 THEN @v10mpositiontaking_20 ELSE CASE WHEN @auto_v10mpositiontaking_20 < @max_v10mpositiontaking_20 - @v10apositiontaking_20 THEN @auto_v10mpositiontaking_20 ELSE @max_v10mpositiontaking_20 - @v10apositiontaking_20 END END

    SELECT @v11mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_1, 0) = 0 THEN @v11mpositiontaking_1 ELSE CASE WHEN @auto_v11mpositiontaking_1 < @max_v11mpositiontaking_1 - @v11apositiontaking_1 THEN @auto_v11mpositiontaking_1 ELSE @max_v11mpositiontaking_1 - @v11apositiontaking_1 END END
    SELECT @v11mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_20, 0) = 0 THEN @v11mpositiontaking_20 ELSE CASE WHEN @auto_v11mpositiontaking_20 < @max_v11mpositiontaking_20 - @v11apositiontaking_20 THEN @auto_v11mpositiontaking_20 ELSE @max_v11mpositiontaking_20 - @v11apositiontaking_20 END END

    SELECT @v99mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_1, 0) = 0 THEN @v99mpositiontaking_1 ELSE CASE WHEN @auto_v99mpositiontaking_1 < @max_v99mpositiontaking_1 - @v99apositiontaking_1 THEN @auto_v99mpositiontaking_1 ELSE @max_v99mpositiontaking_1 - @v99apositiontaking_1 END END
    SELECT @v99mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_2, 0) = 0 THEN @v99mpositiontaking_2 ELSE CASE WHEN @auto_v99mpositiontaking_2 < @max_v99mpositiontaking_2 - @v99apositiontaking_2 THEN @auto_v99mpositiontaking_2 ELSE @max_v99mpositiontaking_2 - @v99apositiontaking_2 END END
    SELECT @v99mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_3, 0) = 0 THEN @v99mpositiontaking_3 ELSE CASE WHEN @auto_v99mpositiontaking_3 < @max_v99mpositiontaking_3 - @v99apositiontaking_3 THEN @auto_v99mpositiontaking_3 ELSE @max_v99mpositiontaking_3 - @v99apositiontaking_3 END END
    SELECT @v99mpositiontaking_9 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_9, 0) = 0 THEN @v99mpositiontaking_9 ELSE CASE WHEN @auto_v99mpositiontaking_9 < @max_v99mpositiontaking_9 - @v99apositiontaking_9 THEN @auto_v99mpositiontaking_9 ELSE @max_v99mpositiontaking_9 - @v99apositiontaking_9 END END
    SELECT @v99mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_20, 0) = 0 THEN @v99mpositiontaking_20 ELSE CASE WHEN @auto_v99mpositiontaking_20 < @max_v99mpositiontaking_20 - @v99apositiontaking_20 THEN @auto_v99mpositiontaking_20 ELSE @max_v99mpositiontaking_20 - @v99apositiontaking_20 END END
	SELECT @v99mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_9999, 0) = 0 THEN @v99mpositiontaking_9999 ELSE CASE WHEN @auto_v99mpositiontaking_9999 < @max_v99mpositiontaking_9999 - @v99apositiontaking_9999 THEN @auto_v99mpositiontaking_9999 ELSE @max_v99mpositiontaking_9999 - @v99apositiontaking_9999 END END
    --v161
    SELECT @v161mpositiontaking_81 = CASE WHEN ISNULL(@isauto_v161mpositiontaking_81, 0) = 0 THEN @v161mpositiontaking_81 ELSE CASE WHEN @auto_v161mpositiontaking_81 < @max_v161mpositiontaking_81 - @v161apositiontaking_81 THEN @auto_v161mpositiontaking_81 ELSE @max_v161mpositiontaking_81 - @v161apositiontaking_81 END END
    SELECT @v161mpositiontaking_83 = CASE WHEN ISNULL(@isauto_v161mpositiontaking_83, 0) = 0 THEN @v161mpositiontaking_83 ELSE CASE WHEN @auto_v161mpositiontaking_83 < @max_v161mpositiontaking_83 - @v161apositiontaking_83 THEN @auto_v161mpositiontaking_83 ELSE @max_v161mpositiontaking_83 - @v161apositiontaking_83 END END
    SELECT @v161mpositiontaking_86 = CASE WHEN ISNULL(@isauto_v161mpositiontaking_86, 0) = 0 THEN @v161mpositiontaking_86 ELSE CASE WHEN @auto_v161mpositiontaking_86 < @max_v161mpositiontaking_86 - @v161apositiontaking_86 THEN @auto_v161mpositiontaking_86 ELSE @max_v161mpositiontaking_86 - @v161apositiontaking_86 END END
    SELECT @v161mpositiontaking_88 = CASE WHEN ISNULL(@isauto_v161mpositiontaking_88, 0) = 0 THEN @v161mpositiontaking_88 ELSE CASE WHEN @auto_v161mpositiontaking_88 < @max_v161mpositiontaking_88 - @v161apositiontaking_88 THEN @auto_v161mpositiontaking_88 ELSE @max_v161mpositiontaking_88 - @v161apositiontaking_88 END END
    SELECT @v161mlivepositiontaking_85 = CASE WHEN ISNULL(@isauto_v161mlivepositiontaking_85, 0) = 0 THEN @v161mlivepositiontaking_85 ELSE CASE WHEN @auto_v161mlivepositiontaking_85 < @max_v161mlivepositiontaking_85 - @v161alivepositiontaking_85 THEN @auto_v161mlivepositiontaking_85 ELSE @max_v161mlivepositiontaking_85 - @v161alivepositiontaking_85 END END
    SELECT @v161mlivepositiontaking_86 = CASE WHEN ISNULL(@isauto_v161mlivepositiontaking_86, 0) = 0 THEN @v161mlivepositiontaking_86 ELSE CASE WHEN @auto_v161mlivepositiontaking_86 < @max_v161mlivepositiontaking_86 - @v161alivepositiontaking_86 THEN @auto_v161mlivepositiontaking_86 ELSE @max_v161mlivepositiontaking_86 - @v161alivepositiontaking_86 END END
    SELECT @v161mlivepositiontaking_87 = CASE WHEN ISNULL(@isauto_v161mlivepositiontaking_87, 0) = 0 THEN @v161mlivepositiontaking_87 ELSE CASE WHEN @auto_v161mlivepositiontaking_87 < @max_v161mlivepositiontaking_87 - @v161alivepositiontaking_87 THEN @auto_v161mlivepositiontaking_87 ELSE @max_v161mlivepositiontaking_87 - @v161alivepositiontaking_87 END END
    SELECT @v161mlivepositiontaking_89 = CASE WHEN ISNULL(@isauto_v161mlivepositiontaking_89, 0) = 0 THEN @v161mlivepositiontaking_89 ELSE CASE WHEN @auto_v161mlivepositiontaking_89 < @max_v161mlivepositiontaking_89 - @v161alivepositiontaking_89 THEN @auto_v161mlivepositiontaking_89 ELSE @max_v161mlivepositiontaking_89 - @v161alivepositiontaking_89 END END
    SELECT @v161mlivepositiontaking_90 = CASE WHEN ISNULL(@isauto_v161mlivepositiontaking_90, 0) = 0 THEN @v161mlivepositiontaking_90 ELSE CASE WHEN @auto_v161mlivepositiontaking_90 < @max_v161mlivepositiontaking_90 - @v161alivepositiontaking_90 THEN @auto_v161mlivepositiontaking_90 ELSE @max_v161mlivepositiontaking_90 - @v161alivepositiontaking_90 END END
	
   
    --v202
    SELECT @v202mpositiontaking_1501 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1501, 0) = 0 THEN @v202mpositiontaking_1501 ELSE CASE WHEN @auto_v202mpositiontaking_1501 < @max_v202mpositiontaking_1501 THEN @auto_v202mpositiontaking_1501 ELSE @max_v202mpositiontaking_1501 END END
    SELECT @v202mpositiontaking_1503 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1503, 0) = 0 THEN @v202mpositiontaking_1503 ELSE CASE WHEN @auto_v202mpositiontaking_1503 < @max_v202mpositiontaking_1503 THEN @auto_v202mpositiontaking_1503 ELSE @max_v202mpositiontaking_1503 END END
    SELECT @v202mpositiontaking_1504 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1504, 0) = 0 THEN @v202mpositiontaking_1504 ELSE CASE WHEN @auto_v202mpositiontaking_1504 < @max_v202mpositiontaking_1504 THEN @auto_v202mpositiontaking_1504 ELSE @max_v202mpositiontaking_1504 END END
    SELECT @v202mpositiontaking_1505 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1505, 0) = 0 THEN @v202mpositiontaking_1505 ELSE CASE WHEN @auto_v202mpositiontaking_1505 < @max_v202mpositiontaking_1505 THEN @auto_v202mpositiontaking_1505 ELSE @max_v202mpositiontaking_1505 END END
    SELECT @v202mpositiontaking_1507 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1507, 0) = 0 THEN @v202mpositiontaking_1507 ELSE CASE WHEN @auto_v202mpositiontaking_1507 < @max_v202mpositiontaking_1507 THEN @auto_v202mpositiontaking_1507 ELSE @max_v202mpositiontaking_1507 END END
    SELECT @v202mpositiontaking_1508 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1508, 0) = 0 THEN @v202mpositiontaking_1508 ELSE CASE WHEN @auto_v202mpositiontaking_1508 < @max_v202mpositiontaking_1508 THEN @auto_v202mpositiontaking_1508 ELSE @max_v202mpositiontaking_1508 END END
    SELECT @v202mpositiontaking_1509 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1509, 0) = 0 THEN @v202mpositiontaking_1509 ELSE CASE WHEN @auto_v202mpositiontaking_1509 < @max_v202mpositiontaking_1509 THEN @auto_v202mpositiontaking_1509 ELSE @max_v202mpositiontaking_1509 END END
    SELECT @v202mpositiontaking_1511 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1511, 0) = 0 THEN @v202mpositiontaking_1511 ELSE CASE WHEN @auto_v202mpositiontaking_1511 < @max_v202mpositiontaking_1511 THEN @auto_v202mpositiontaking_1511 ELSE @max_v202mpositiontaking_1511 END END
    SELECT @v202mpositiontaking_1513 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1513, 0) = 0 THEN @v202mpositiontaking_1513 ELSE CASE WHEN @auto_v202mpositiontaking_1513 < @max_v202mpositiontaking_1513 THEN @auto_v202mpositiontaking_1513 ELSE @max_v202mpositiontaking_1513 END END
    SELECT @v202mpositiontaking_1514 = CASE WHEN ISNULL(@isauto_v202mpositiontaking_1514, 0) = 0 THEN @v202mpositiontaking_1514 ELSE CASE WHEN @auto_v202mpositiontaking_1514 < @max_v202mpositiontaking_1514 THEN @auto_v202mpositiontaking_1514 ELSE @max_v202mpositiontaking_1514 END END

    ----------------***Use Auto Position Taking***----------------------------------
    --use @auto_spt at master only (not exist in member yet)
    --@max_spt = @maxdownlinepos + spt ; pt: positiontaking
    --IF @auto_spt = 0 THEN @spt = @spt
    --else	IF @auto_spt < @max_spt - @mpt - @apt THEN @spt = @auto_spt
    --		else @spt = @max_spt - @mpt - @apt
    SELECT @spositiontaking_1 = CASE WHEN ISNULL(@isauto_spositiontaking_1, 0) = 0 THEN @spositiontaking_1 ELSE CASE WHEN @auto_spositiontaking_1 < @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 THEN @auto_spositiontaking_1 ELSE @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 END END
    SELECT @spositiontaking_3 = CASE WHEN ISNULL(@isauto_spositiontaking_3, 0) = 0 THEN @spositiontaking_3 ELSE CASE WHEN @auto_spositiontaking_3 < @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 THEN @auto_spositiontaking_3 ELSE @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 END END
    SELECT @spositiontaking_7 = CASE WHEN ISNULL(@isauto_spositiontaking_7, 0) = 0 THEN @spositiontaking_7 ELSE CASE WHEN @auto_spositiontaking_7 < @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 THEN @auto_spositiontaking_7 ELSE @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 END END
    SELECT @spositiontaking_8 = CASE WHEN ISNULL(@isauto_spositiontaking_8, 0) = 0 THEN @spositiontaking_8 ELSE CASE WHEN @auto_spositiontaking_8 < @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 THEN @auto_spositiontaking_8 ELSE @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 END END

    SELECT @slivepositiontaking_1 = CASE WHEN ISNULL(@isauto_slivepositiontaking_1, 0) = 0 THEN @slivepositiontaking_1 ELSE CASE WHEN @auto_slivepositiontaking_1 < @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 THEN @auto_slivepositiontaking_1 ELSE @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 END END
    SELECT @slivepositiontaking_3 = CASE WHEN ISNULL(@isauto_slivepositiontaking_3, 0) = 0 THEN @slivepositiontaking_3 ELSE CASE WHEN @auto_slivepositiontaking_3 < @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 THEN @auto_slivepositiontaking_3 ELSE @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 END END
    SELECT @slivepositiontaking_7 = CASE WHEN ISNULL(@isauto_slivepositiontaking_7, 0) = 0 THEN @slivepositiontaking_7 ELSE CASE WHEN @auto_slivepositiontaking_7 < @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 THEN @auto_slivepositiontaking_7 ELSE @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 END END
    SELECT @slivepositiontaking_8 = CASE WHEN ISNULL(@isauto_slivepositiontaking_8, 0) = 0 THEN @slivepositiontaking_8 ELSE CASE WHEN @auto_slivepositiontaking_8 < @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 THEN @auto_slivepositiontaking_8 ELSE @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 END END

    SELECT @spositiontaking_2 = CASE WHEN ISNULL(@isauto_spositiontaking_2, 0) = 0 THEN @spositiontaking_2 ELSE CASE WHEN @auto_spositiontaking_2 < @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 THEN @auto_spositiontaking_2 ELSE @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 END END
    SELECT @spositiontaking_4 = CASE WHEN ISNULL(@isauto_spositiontaking_4, 0) = 0 THEN @spositiontaking_4 ELSE CASE WHEN @auto_spositiontaking_4 < @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 THEN @auto_spositiontaking_4 ELSE @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 END END
    SELECT @spositiontaking_5 = CASE WHEN ISNULL(@isauto_spositiontaking_5, 0) = 0 THEN @spositiontaking_5 ELSE CASE WHEN @auto_spositiontaking_5 < @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 THEN @auto_spositiontaking_5 ELSE @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 END END
    SELECT @spositiontaking_6 = CASE WHEN ISNULL(@isauto_spositiontaking_6, 0) = 0 THEN @spositiontaking_6 ELSE CASE WHEN @auto_spositiontaking_6 < @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 THEN @auto_spositiontaking_6 ELSE @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 END END
    SELECT @spositiontaking_9 = CASE WHEN ISNULL(@isauto_spositiontaking_9, 0) = 0 THEN @spositiontaking_9 ELSE CASE WHEN @auto_spositiontaking_9 < @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 THEN @auto_spositiontaking_9 ELSE @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 END END
    SELECT @spositiontaking_10 = CASE WHEN ISNULL(@isauto_spositiontaking_10, 0) = 0 THEN @spositiontaking_10 ELSE CASE WHEN @auto_spositiontaking_10 < @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 THEN @auto_spositiontaking_10 ELSE @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 END END
    SELECT @v2spositiontaking_10 = CASE WHEN ISNULL(@isauto_v2spositiontaking_10, 0) = 0 THEN @v2spositiontaking_10 ELSE CASE WHEN @auto_v2spositiontaking_10 < @max_v2spositiontaking_10 - @v2mpositiontaking_10 - @v2apositiontaking_10 THEN @auto_v2spositiontaking_10 ELSE @max_v2spositiontaking_10 - @v2mpositiontaking_10 - @v2apositiontaking_10 END END
    SELECT @v3spositiontaking_10 = CASE WHEN ISNULL(@isauto_v3spositiontaking_10, 0) = 0 THEN @v3spositiontaking_10 ELSE CASE WHEN @auto_v3spositiontaking_10 < @max_v3spositiontaking_10 - @v3mpositiontaking_10 - @v3apositiontaking_10 THEN @auto_v3spositiontaking_10 ELSE @max_v3spositiontaking_10 - @v3mpositiontaking_10 - @v3apositiontaking_10 END END
    SELECT @v5spositiontaking_10 = CASE WHEN ISNULL(@isauto_v5spositiontaking_10, 0) = 0 THEN @v5spositiontaking_10 ELSE CASE WHEN @auto_v5spositiontaking_10 < @max_v5spositiontaking_10 - @v5mpositiontaking_10 - @v5apositiontaking_10 THEN @auto_v5spositiontaking_10 ELSE @max_v5spositiontaking_10 - @v5mpositiontaking_10 - @v5apositiontaking_10 END END
    SELECT @v8spositiontaking_10 = CASE WHEN ISNULL(@isauto_v8spositiontaking_10, 0) = 0 THEN @v8spositiontaking_10 ELSE CASE WHEN @auto_v8spositiontaking_10 < @max_v8spositiontaking_10 - @v8mpositiontaking_10 - @v8apositiontaking_10 THEN @auto_v8spositiontaking_10 ELSE @max_v8spositiontaking_10 - @v8mpositiontaking_10 - @v8apositiontaking_10 END END
    SELECT @v10spositiontaking_10 = CASE WHEN ISNULL(@isauto_v10spositiontaking_10, 0) = 0 THEN @v10spositiontaking_10 ELSE CASE WHEN @auto_v10spositiontaking_10 < @max_v10spositiontaking_10 - @v10mpositiontaking_10 - @v10apositiontaking_10 THEN @auto_v10spositiontaking_10 ELSE @max_v10spositiontaking_10 - @v10mpositiontaking_10 - @v10apositiontaking_10 END END
    SELECT @v11spositiontaking_10 = CASE WHEN ISNULL(@isauto_v11spositiontaking_10, 0) = 0 THEN @v11spositiontaking_10 ELSE CASE WHEN @auto_v11spositiontaking_10 < @max_v11spositiontaking_10 - @v11mpositiontaking_10 - @v11apositiontaking_10 THEN @auto_v11spositiontaking_10 ELSE @max_v11spositiontaking_10 - @v11mpositiontaking_10 - @v11apositiontaking_10 END END
    SELECT @v99spositiontaking_10 = CASE WHEN ISNULL(@isauto_v99spositiontaking_10, 0) = 0 THEN @v99spositiontaking_10 ELSE CASE WHEN @auto_v99spositiontaking_10 < @max_v99spositiontaking_10 - @v99mpositiontaking_10 - @v99apositiontaking_10 THEN @auto_v99spositiontaking_10 ELSE @max_v99spositiontaking_10 - @v99mpositiontaking_10 - @v99apositiontaking_10 END END
    SELECT @spositiontaking_9999 = CASE WHEN ISNULL(@isauto_spositiontaking_9999, 0) = 0 THEN @spositiontaking_9999 ELSE CASE WHEN @auto_spositiontaking_9999 < @max_spositiontaking_9999 - @mpositiontaking_9999 - @apositiontaking_9999 THEN @auto_spositiontaking_9999 ELSE @max_spositiontaking_9999 - @mpositiontaking_9999 - @apositiontaking_9999 END END

    SELECT @v2spositiontaking_1 = CASE WHEN ISNULL(@isauto_v2spositiontaking_1, 0) = 0 THEN @v2spositiontaking_1 ELSE CASE WHEN @auto_v2spositiontaking_1 < @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 THEN @auto_v2spositiontaking_1 ELSE @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 END END
    SELECT @v2spositiontaking_2 = CASE WHEN ISNULL(@isauto_v2spositiontaking_2, 0) = 0 THEN @v2spositiontaking_2 ELSE CASE WHEN @auto_v2spositiontaking_2 < @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 THEN @auto_v2spositiontaking_2 ELSE @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 END END
    SELECT @v2spositiontaking_3 = CASE WHEN ISNULL(@isauto_v2spositiontaking_3, 0) = 0 THEN @v2spositiontaking_3 ELSE CASE WHEN @auto_v2spositiontaking_3 < @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 THEN @auto_v2spositiontaking_3 ELSE @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 END END
    SELECT @v2spositiontaking_7 = CASE WHEN ISNULL(@isauto_v2spositiontaking_7, 0) = 0 THEN @v2spositiontaking_7 ELSE CASE WHEN @auto_v2spositiontaking_7 < @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 THEN @auto_v2spositiontaking_7 ELSE @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 END END
    SELECT @v2spositiontaking_8 = CASE WHEN ISNULL(@isauto_v2spositiontaking_8, 0) = 0 THEN @v2spositiontaking_8 ELSE CASE WHEN @auto_v2spositiontaking_8 < @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 THEN @auto_v2spositiontaking_8 ELSE @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 END END
    SELECT @v2spositiontaking_20 = CASE WHEN ISNULL(@isauto_v2spositiontaking_20, 0) = 0 THEN @v2spositiontaking_20 ELSE CASE WHEN @auto_v2spositiontaking_20 < @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 THEN @auto_v2spositiontaking_20 ELSE @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 END END
    
    SELECT @v2spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9999, 0) = 0 THEN @v2spositiontaking_9999 ELSE CASE WHEN @auto_v2spositiontaking_9999 < @max_v2spositiontaking_9999 - @v2mpositiontaking_9999 - @v2apositiontaking_9999 THEN @auto_v2spositiontaking_9999 ELSE @max_v2spositiontaking_9999 - @v2mpositiontaking_9999 - @v2apositiontaking_9999 END END

    SELECT @v3spositiontaking_1 = CASE WHEN ISNULL(@isauto_v3spositiontaking_1, 0) = 0 THEN @v3spositiontaking_1 ELSE CASE WHEN @auto_v3spositiontaking_1 < @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 THEN @auto_v3spositiontaking_1 ELSE @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 END END
    SELECT @v3spositiontaking_2 = CASE WHEN ISNULL(@isauto_v3spositiontaking_2, 0) = 0 THEN @v3spositiontaking_2 ELSE CASE WHEN @auto_v3spositiontaking_2 < @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 THEN @auto_v3spositiontaking_2 ELSE @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 END END
    SELECT @v3spositiontaking_3 = CASE WHEN ISNULL(@isauto_v3spositiontaking_3, 0) = 0 THEN @v3spositiontaking_3 ELSE CASE WHEN @auto_v3spositiontaking_3 < @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 THEN @auto_v3spositiontaking_3 ELSE @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 END END
    SELECT @v3spositiontaking_20 = CASE WHEN ISNULL(@isauto_v3spositiontaking_20, 0) = 0 THEN @v3spositiontaking_20 ELSE CASE WHEN @auto_v3spositiontaking_20 < @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 THEN @auto_v3spositiontaking_20 ELSE @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 END END

    SELECT @v5spositiontaking_1 = CASE WHEN ISNULL(@isauto_v5spositiontaking_1, 0) = 0 THEN @v5spositiontaking_1 ELSE CASE WHEN @auto_v5spositiontaking_1 < @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 THEN @auto_v5spositiontaking_1 ELSE @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 END END
    SELECT @v5spositiontaking_2 = CASE WHEN ISNULL(@isauto_v5spositiontaking_2, 0) = 0 THEN @v5spositiontaking_2 ELSE CASE WHEN @auto_v5spositiontaking_2 < @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 THEN @auto_v5spositiontaking_2 ELSE @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 END END
    SELECT @v5spositiontaking_3 = CASE WHEN ISNULL(@isauto_v5spositiontaking_3, 0) = 0 THEN @v5spositiontaking_3 ELSE CASE WHEN @auto_v5spositiontaking_3 < @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 THEN @auto_v5spositiontaking_3 ELSE @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 END END
    SELECT @v5spositiontaking_20 = CASE WHEN ISNULL(@isauto_v5spositiontaking_20, 0) = 0 THEN @v5spositiontaking_20 ELSE CASE WHEN @auto_v5spositiontaking_20 < @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 THEN @auto_v5spositiontaking_20 ELSE @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 END END
    SELECT @v5spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5spositiontaking_9999, 0) = 0 THEN @v5spositiontaking_9999 ELSE CASE WHEN @auto_v5spositiontaking_9999 < @max_v5spositiontaking_9999 - @v5mpositiontaking_9999 - @v5apositiontaking_9999 THEN @auto_v5spositiontaking_9999 ELSE @max_v5spositiontaking_9999 - @v5mpositiontaking_9999 - @v5apositiontaking_9999 END END

    SELECT @v8spositiontaking_1 = CASE WHEN ISNULL(@isauto_v8spositiontaking_1, 0) = 0 THEN @v8spositiontaking_1 ELSE CASE WHEN @auto_v8spositiontaking_1 < @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 THEN @auto_v8spositiontaking_1 ELSE @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 END END
    SELECT @v8spositiontaking_3 = CASE WHEN ISNULL(@isauto_v8spositiontaking_3, 0) = 0 THEN @v8spositiontaking_3 ELSE CASE WHEN @auto_v8spositiontaking_3 < @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 THEN @auto_v8spositiontaking_3 ELSE @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 END END
    SELECT @v8spositiontaking_20 = CASE WHEN ISNULL(@isauto_v8spositiontaking_20, 0) = 0 THEN @v8spositiontaking_20 ELSE CASE WHEN @auto_v8spositiontaking_20 < @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 THEN @auto_v8spositiontaking_20 ELSE @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 END END

    SELECT @v10spositiontaking_1 = CASE WHEN ISNULL(@isauto_v10spositiontaking_1, 0) = 0 THEN @v10spositiontaking_1 ELSE CASE WHEN @auto_v10spositiontaking_1 < @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 THEN @auto_v10spositiontaking_1 ELSE @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 END END
    SELECT @v10spositiontaking_2 = CASE WHEN ISNULL(@isauto_v10spositiontaking_2, 0) = 0 THEN @v10spositiontaking_2 ELSE CASE WHEN @auto_v10spositiontaking_2 < @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 THEN @auto_v10spositiontaking_2 ELSE @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 END END
    SELECT @v10spositiontaking_3 = CASE WHEN ISNULL(@isauto_v10spositiontaking_3, 0) = 0 THEN @v10spositiontaking_3 ELSE CASE WHEN @auto_v10spositiontaking_3 < @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 THEN @auto_v10spositiontaking_3 ELSE @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 END END
    SELECT @v10spositiontaking_20 = CASE WHEN ISNULL(@isauto_v10spositiontaking_20, 0) = 0 THEN @v10spositiontaking_20 ELSE CASE WHEN @auto_v10spositiontaking_20 < @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 THEN @auto_v10spositiontaking_20 ELSE @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 END END

    SELECT @v11spositiontaking_1 = CASE WHEN ISNULL(@isauto_v11spositiontaking_1, 0) = 0 THEN @v11spositiontaking_1 ELSE CASE WHEN @auto_v11spositiontaking_1 < @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 THEN @auto_v11spositiontaking_1 ELSE @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 END END
    SELECT @v11spositiontaking_20 = CASE WHEN ISNULL(@isauto_v11spositiontaking_20, 0) = 0 THEN @v11spositiontaking_20 ELSE CASE WHEN @auto_v11spositiontaking_20 < @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 THEN @auto_v11spositiontaking_20 ELSE @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 END END

    SELECT @v99spositiontaking_1 = CASE WHEN ISNULL(@isauto_v99spositiontaking_1, 0) = 0 THEN @v99spositiontaking_1 ELSE CASE WHEN @auto_v99spositiontaking_1 < @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 THEN @auto_v99spositiontaking_1 ELSE @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 END END
    SELECT @v99spositiontaking_2 = CASE WHEN ISNULL(@isauto_v99spositiontaking_2, 0) = 0 THEN @v99spositiontaking_2 ELSE CASE WHEN @auto_v99spositiontaking_2 < @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 THEN @auto_v99spositiontaking_2 ELSE @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 END END
    SELECT @v99spositiontaking_3 = CASE WHEN ISNULL(@isauto_v99spositiontaking_3, 0) = 0 THEN @v99spositiontaking_3 ELSE CASE WHEN @auto_v99spositiontaking_3 < @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 THEN @auto_v99spositiontaking_3 ELSE @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 END END
    SELECT @v99spositiontaking_9 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9, 0) = 0 THEN @v99spositiontaking_9 ELSE CASE WHEN @auto_v99spositiontaking_9 < @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 THEN @auto_v99spositiontaking_9 ELSE @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 END END
    SELECT @v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0) = 0 THEN @v99spositiontaking_20 ELSE CASE WHEN @auto_v99spositiontaking_20 < @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 THEN @auto_v99spositiontaking_20 ELSE @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 END END
	SELECT @v99spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9999, 0) = 0 THEN @v99spositiontaking_9999 ELSE CASE WHEN @auto_v99spositiontaking_9999 < @max_v99spositiontaking_9999 - @v99mpositiontaking_9999 - @v99apositiontaking_9999 THEN @auto_v99spositiontaking_9999 ELSE @max_v99spositiontaking_9999 - @v99mpositiontaking_9999 - @v99apositiontaking_9999 END END

    --v161
    SELECT @v161spositiontaking_81 = CASE WHEN ISNULL(@isauto_v161spositiontaking_81, 0) = 0 THEN @v161spositiontaking_81 ELSE CASE WHEN @auto_v161spositiontaking_81 < @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 THEN @auto_v161spositiontaking_81 ELSE @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 END END
    SELECT @v161spositiontaking_83 = CASE WHEN ISNULL(@isauto_v161spositiontaking_83, 0) = 0 THEN @v161spositiontaking_83 ELSE CASE WHEN @auto_v161spositiontaking_83 < @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 THEN @auto_v161spositiontaking_83 ELSE @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 END END
    SELECT @v161spositiontaking_86 = CASE WHEN ISNULL(@isauto_v161spositiontaking_86, 0) = 0 THEN @v161spositiontaking_86 ELSE CASE WHEN @auto_v161spositiontaking_86 < @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 THEN @auto_v161spositiontaking_86 ELSE @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 END END
    SELECT @v161spositiontaking_88 = CASE WHEN ISNULL(@isauto_v161spositiontaking_88, 0) = 0 THEN @v161spositiontaking_88 ELSE CASE WHEN @auto_v161spositiontaking_88 < @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 THEN @auto_v161spositiontaking_88 ELSE @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 END END

    SELECT @v161slivepositiontaking_85 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_85, 0) = 0 THEN @v161slivepositiontaking_85 ELSE CASE WHEN @auto_v161slivepositiontaking_85 < @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 THEN @auto_v161slivepositiontaking_85 ELSE @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 END END
    SELECT @v161slivepositiontaking_86 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_86, 0) = 0 THEN @v161slivepositiontaking_86 ELSE CASE WHEN @auto_v161slivepositiontaking_86 < @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 THEN @auto_v161slivepositiontaking_86 ELSE @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 END END
    SELECT @v161slivepositiontaking_87 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_87, 0) = 0 THEN @v161slivepositiontaking_87 ELSE CASE WHEN @auto_v161slivepositiontaking_87 < @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 THEN @auto_v161slivepositiontaking_87 ELSE @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 END END
    SELECT @v161slivepositiontaking_89 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_89, 0) = 0 THEN @v161slivepositiontaking_89 ELSE CASE WHEN @auto_v161slivepositiontaking_89 < @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 THEN @auto_v161slivepositiontaking_89 ELSE @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 END END
    SELECT @v161slivepositiontaking_90 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_90, 0) = 0 THEN @v161slivepositiontaking_90 ELSE CASE WHEN @auto_v161slivepositiontaking_90 < @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 THEN @auto_v161slivepositiontaking_90 ELSE @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 END END

   
    --v202
    SELECT @v202spositiontaking_1501 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1501, 0) = 0 THEN @v202spositiontaking_1501 ELSE CASE WHEN @auto_v202spositiontaking_1501 < @max_v202spositiontaking_1501 - @v202mpositiontaking_1501 THEN @auto_v202spositiontaking_1501 ELSE @max_v202spositiontaking_1501 - @v202mpositiontaking_1501 END END
    SELECT @v202spositiontaking_1503 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1503, 0) = 0 THEN @v202spositiontaking_1503 ELSE CASE WHEN @auto_v202spositiontaking_1503 < @max_v202spositiontaking_1503 - @v202mpositiontaking_1503 THEN @auto_v202spositiontaking_1503 ELSE @max_v202spositiontaking_1503 - @v202mpositiontaking_1503 END END
    SELECT @v202spositiontaking_1504 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1504, 0) = 0 THEN @v202spositiontaking_1504 ELSE CASE WHEN @auto_v202spositiontaking_1504 < @max_v202spositiontaking_1504 - @v202mpositiontaking_1504 THEN @auto_v202spositiontaking_1504 ELSE @max_v202spositiontaking_1504 - @v202mpositiontaking_1504 END END
    SELECT @v202spositiontaking_1505 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1505, 0) = 0 THEN @v202spositiontaking_1505 ELSE CASE WHEN @auto_v202spositiontaking_1505 < @max_v202spositiontaking_1505 - @v202mpositiontaking_1505 THEN @auto_v202spositiontaking_1505 ELSE @max_v202spositiontaking_1505 - @v202mpositiontaking_1505 END END
    SELECT @v202spositiontaking_1507 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1507, 0) = 0 THEN @v202spositiontaking_1507 ELSE CASE WHEN @auto_v202spositiontaking_1507 < @max_v202spositiontaking_1507 - @v202mpositiontaking_1507 THEN @auto_v202spositiontaking_1507 ELSE @max_v202spositiontaking_1507 - @v202mpositiontaking_1507 END END
    SELECT @v202spositiontaking_1508 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1508, 0) = 0 THEN @v202spositiontaking_1508 ELSE CASE WHEN @auto_v202spositiontaking_1508 < @max_v202spositiontaking_1508 - @v202mpositiontaking_1508 THEN @auto_v202spositiontaking_1508 ELSE @max_v202spositiontaking_1508 - @v202mpositiontaking_1508 END END
    SELECT @v202spositiontaking_1509 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1509, 0) = 0 THEN @v202spositiontaking_1509 ELSE CASE WHEN @auto_v202spositiontaking_1509 < @max_v202spositiontaking_1509 - @v202mpositiontaking_1509 THEN @auto_v202spositiontaking_1509 ELSE @max_v202spositiontaking_1509 - @v202mpositiontaking_1509 END END
    SELECT @v202spositiontaking_1511 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1511, 0) = 0 THEN @v202spositiontaking_1511 ELSE CASE WHEN @auto_v202spositiontaking_1511 < @max_v202spositiontaking_1511 - @v202mpositiontaking_1511 THEN @auto_v202spositiontaking_1511 ELSE @max_v202spositiontaking_1511 - @v202mpositiontaking_1511 END END
    SELECT @v202spositiontaking_1513 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1513, 0) = 0 THEN @v202spositiontaking_1513 ELSE CASE WHEN @auto_v202spositiontaking_1513 < @max_v202spositiontaking_1513 - @v202mpositiontaking_1513 THEN @auto_v202spositiontaking_1513 ELSE @max_v202spositiontaking_1513 - @v202mpositiontaking_1513 END END
    SELECT @v202spositiontaking_1514 = CASE WHEN ISNULL(@isauto_v202spositiontaking_1514, 0) = 0 THEN @v202spositiontaking_1514 ELSE CASE WHEN @auto_v202spositiontaking_1514 < @max_v202spositiontaking_1514 - @v202mpositiontaking_1514 THEN @auto_v202spositiontaking_1514 ELSE @max_v202spositiontaking_1514 - @v202mpositiontaking_1514 END END


    SELECT @adiscount =  CASE WHEN @ugroup in ('a','hka','dea') THEN groupa WHEN @ugroup in ('b','hkb','deb') THEN groupb WHEN @ugroup in ('c','hkc','dec') THEN groupc ELSE groupd END
    FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1 AND sporttype = 1
    SELECT @adiscountcs =  adiscount FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 4 AND sporttype = 1
    --1x2
    SELECT @adiscount1x2 = adiscount FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 5 AND sporttype =1 

    SELECT @sdiscount =  CASE WHEN @ugroup in ('a','hka','dea') THEN groupa WHEN @ugroup in ('b','hkb','deb') THEN groupb WHEN @ugroup in ('c','hkc','dec') THEN groupc ELSE groupd END
    FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 1
    SELECT @sdiscountcs =  sdiscount FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 4 AND sporttype = 1

    --1x2 
    SELECT @sdiscount1x2 =  sdiscount FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 5 AND sporttype = 1    
	
    --Check valid commission
    --Commission for Sportsbook
    SELECT @adiscount = CASE WHEN @adiscount > @sdiscount THEN @sdiscount ELSE @adiscount END
    SELECT @discount = CASE WHEN @discount > @adiscount THEN @adiscount ELSE @discount END

    SELECT @adiscountcs = CASE WHEN @adiscountcs > @sdiscountcs THEN @sdiscountcs ELSE @adiscountcs END
    SELECT @discountcs = CASE WHEN @discountcs > @adiscountcs THEN @adiscountcs ELSE @discountcs END

    --Commission 1x2 
    SELECT @adiscount1x2 = CASE WHEN @adiscount1x2 > @sdiscount1x2 THEN @sdiscount1x2 ELSE @adiscount1x2 END
    SELECT @discount1x2 = CASE WHEN @discount1x2 > @adiscount1x2 THEN @adiscount1x2 ELSE @discount1x2 END

	select
	    @playerdiscount = CASE WHEN @playerdiscount > @discount THEN @discount ELSE @playerdiscount END,
	    @playerdiscountcs = CASE WHEN @playerdiscountcs > @discountcs THEN @discountcs ELSE @playerdiscountcs END,
	    --1x2
	    @playerdiscount1x2 = CASE WHEN @playerdiscount1x2 > @discount1x2 THEN @discount1x2 ELSE @playerdiscount1x2 END--,   
    	

    SELECT @Credit_AllOtherMember = ISNULL(sum(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1
    SELECT @MaxCredit_Mem = CASE WHEN @MaxCredit_Mem =0 THEN (@AgentCredit - @Credit_AllOtherMember) 
						    ELSE @MaxCredit_Mem END 
    IF @Credit + @Credit_AllOtherMember>@AgentCredit
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Your credit limit has been exceeded.'  
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language)
						    END	
			    ,@success = 0, @ErrCode = 204
	    return
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Your Member max credit limit has been exceeded.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](70009,@Language)
						    END	
			    ,@success = 0, @ErrCode =217
	    return
    END 

    SELECT @pwdexpiry = CASE WHEN @IsQRCode = 1 THEN '01/01/1900' ELSE DATEADD(dd, -1, GETDATE()) END

    IF @UplineClosed = 1 SELECT @Closed = 1 

    --check suspended of Agent 
    IF @Asuspended =1
    BEGIN
	    set @suspended =1
    END

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
	    @ugroup = @ugroup,
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = @recommend,
	    @roleid = 1,
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
	    --@suspended = @suspended,
	    @closed = @closed,
    	
	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,
		@autosuspend3 = @autosuspend3,

	    @Danger = @AgentDanger,
	    @Danger2 = @AgentDanger2,
	    @Danger3 = @AgentDanger3,
		@Danger4 = @AgentDanger4,
	    @Danger5 = @AgentDanger5,
	    @Abnormal = @AgentAbnormal,
    	
	  
	    @DisableOutright = @DisableOutright,	
	    @matchlimit = @matchlimit,
	    @virtualmultiplier = @EnableVR,
	   
		@DisableNumber = @DisableNumber,	 

	    @DoubleCommLosing = 0,-- off double comm losing WHEN create new member   	 
	  
	    --Keno
	    @HideKeno = @HideKeno,
		
		@DisableSuperLive = @DisableSuperLive,

    	@SystemID=@SystemID,
	    @credit = @credit,	
	    @IP = @IP,
	    @TransferOption_dec = NULL,
	    @copyFromCustID = @copyFromCustID,
	    @isSearchAndCopy = @isSearchAndCopy,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    IF @ErrCode <> 0
	    return
    	
    --set comm of sportbook = 0 if agent of member exist in table CustNoComm
    IF EXISTS(SELECT 1 FROM CustNoComm WHERE custID = @recommend)
    BEGIN
	    SELECT @playerdiscount = 0,	@discount = 0, @adiscount = 0, @sdiscount = 0,
		    @playerdiscount1x2 = 0, @discount1x2 = 0, @adiscount1x2 = 0, @sdiscount1x2 = 0,		   
		    @playerdiscountcs = 0, @discountcs = 0, @adiscountcs = 0, @sdiscountcs = 0			
    END
  
        EXEC dbo.Acc_CustomerInfo_Execrep_00
	    @custid = @custid,
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = @recommend,
	    @roleid = 1,--create member
		@isSearchAndCopy = @isSearchAndCopy,
		@copyFromCustID = @copyFromCustID,
    	
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
    	    	
	    --v180
	    @v202spositiontaking_1501 = @v202spositiontaking_1501,
	    @v202spositiontaking_1503 = @v202spositiontaking_1503,
	    @v202spositiontaking_1504 = @v202spositiontaking_1504,
	    @v202spositiontaking_1505 = @v202spositiontaking_1505,
	    @v202spositiontaking_1507 = @v202spositiontaking_1507,
	    @v202spositiontaking_1508 = @v202spositiontaking_1508,
	    @v202spositiontaking_1509 = @v202spositiontaking_1509,
	    @v202spositiontaking_1511 = @v202spositiontaking_1511,
	    @v202spositiontaking_1513 = @v202spositiontaking_1513,
	    @v202spositiontaking_1514 = @v202spositiontaking_1514,
    	
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
    	
	    --v202
	    @v202mpositiontaking_1501 = @v202mpositiontaking_1501,
	    @v202mpositiontaking_1503 = @v202mpositiontaking_1503,
	    @v202mpositiontaking_1504 = @v202mpositiontaking_1504,
	    @v202mpositiontaking_1505 = @v202mpositiontaking_1505,
	    @v202mpositiontaking_1507 = @v202mpositiontaking_1507,
	    @v202mpositiontaking_1508 = @v202mpositiontaking_1508,
	    @v202mpositiontaking_1509 = @v202mpositiontaking_1509,
	    @v202mpositiontaking_1511 = @v202mpositiontaking_1511,
	    @v202mpositiontaking_1513 = @v202mpositiontaking_1513,
	    @v202mpositiontaking_1514 = @v202mpositiontaking_1514,
    	
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
 
	    --v202
	    @v202apositiontaking_1501 = @v202apositiontaking_1501,
	    @v202apositiontaking_1503 = @v202apositiontaking_1503,
	    @v202apositiontaking_1504 = @v202apositiontaking_1504,
	    @v202apositiontaking_1505 = @v202apositiontaking_1505,
	    @v202apositiontaking_1507 = @v202apositiontaking_1507,
	    @v202apositiontaking_1508 = @v202apositiontaking_1508,
	    @v202apositiontaking_1509 = @v202apositiontaking_1509,
	    @v202apositiontaking_1511 = @v202apositiontaking_1511,
	    @v202apositiontaking_1513 = @v202apositiontaking_1513,
	    @v202apositiontaking_1514 = @v202apositiontaking_1514,
    	
	    @discount = @discount,	
	    @discountcs = @discountcs, 
	    --comm 1x2
	    @discount1x2 = @discount1x2,
    	
	    @playerdiscount = @playerdiscount, 
	    @playerdiscountcs = @playerdiscountcs,
	    --1x2 
	    @playerdiscount1x2 = @playerdiscount1x2,		
    		
	    @adiscount = @adiscount,
	    @adiscountcs = @adiscountcs,
	    @adiscount1x2 = @adiscount1x2,
    	
	    @sdiscount = @sdiscount,		
	    @sdiscountcs = @sdiscountcs,	
	    @sdiscount1x2 = @sdiscount1x2,	 	
		
		--BetSetting
		@BetSettingXML = @BetSettingXML,

		-- MyanmarOdds
		@IsMyanmarOdds = @IsMyanmarOdds,		
    	@discountMyanmarOdds = @playerdiscountMyanmarOdds,
		@SettingStatus = @SettingStatus,
	    @ErrCode = @ErrCode OUTPUT

    IF @ErrCode > 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Create customer fail. Please try again'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					    END	
    				
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			

	    RETURN
    END	

    --EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'sportbook'
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	 
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

	
    --Keno--1501
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1501
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	 
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
    	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1503
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1503
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1504
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1504
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	 
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1505
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1505
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	   
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1507
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1507
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY

	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1508
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1508

    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	   
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1509
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1509

    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	  
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1511
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1511

    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    --Keno--1513
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1513

    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	   
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END
    
    --Keno--1514
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Keno',
	    @sporttype = 202,
	    @bettype = 1514

    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
	                       WHEN 'E' THEN 'Create member fail. Please try again'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40018, @Language)
					     END
	         , @success = 0
	         , @ErrCode = 218

	    -- ROLLBACK MANUALLY
	    Delete custsetting      with(ROWLOCK) WHERE custid = @custid
	    Delete CustSetting3rd   with(ROWLOCK) WHERE custid = @custid	 
	    DELETE custsettingGame  WITH(ROWLOCK) WHERE custId = @custid	
	    DELETE custOverride     WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd  WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH(ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType     WITH(ROWLOCK) WHERE custId = @custid
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

     ---- Create balance for new customer   
	 --EXEC DBTXN.bodb02.dbo.Dot_BalanceInsCredit @CustID = @CustID
	EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditInitialize @CustID = @CustID, @errCode = @ErrCode OUTPUT

    IF @ErrCode <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
	    EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
		
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

     --EXEC DBTXN.bodb02.dbo.Dot_BalanceInsDebit @CustID = @CustID    
		EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitInitialize @CustID = @CustID, @errCode = @ErrCode OUTPUT 

    IF @ErrCode <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	  
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
		EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END
	
	IF ISNULL(@IsQRCode,0) = 1
	BEGIN
		INSERT INTO [dbo].[CustQRCode] (CustID)
		SELECT @custid
	END

	IF @@ERROR <> 0
	BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	  
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
		EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID

		DELETE dbo.[CustQRCode] WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END
	
	If @SystemID = 2 -- ALPHA
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create member fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
							END
					, @success = 0, @ErrCode=216
			Delete custsetting with (ROWLOCK) WHERE custid  =@custid
			Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	  
			DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
			DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
			DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
			DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
			DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
			EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
			EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID

			DELETE dbo.[CustQRCode] WITH(ROWLOCK) WHERE CustID = @CustID

			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE FROM CustLimitPTSetting WITH (ROWLOCK) WHERE custId =@custid
			RETURN
		END	
	END

    SELECT @Success = 1

    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)

    declare @copyFromUsername VARCHAR(30)
    SELECT @copyFromUsername = username
    FROM customer WITH(NOLOCK)
    WHERE custid = @copyFromCustID

    Declare @LogSPData VARCHAR(8000)
    --Log customer general info
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)), SPACE(1))) + '" ' +
    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)), SPACE(1))) + '" ' +
    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
    'recommend="'+ COALESCE(CAST(@recommend AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ugroup="'+ COALESCE(CAST(@ugroup AS VARCHAR(5)), SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
    'success="'+ COALESCE(CAST(@success AS VARCHAR(50)), SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
    'isSearchAndCopy ="'+ COALESCE(CAST(@isSearchAndCopy AS VARCHAR(5)), SPACE(1)) + '" ' +
    'copyFromCustID ="'+ COALESCE(CAST(@copyFromCustID AS VARCHAR(20)), SPACE(1)) + '" ' +
    'copyFromUsername ="'+ COALESCE(@copyFromUsername, SPACE(1)) + '" ' +
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)), SPACE(1)) + '" />'
	
	DECLARE @ActionID INT 
	SELECT @ActionID = CASE WHEN @systemID = 10 THEN 95083 --telegram chatbot
							ELSE CASE WHEN @CreatedMode = 1 THEN 95084 -- Multiple customers
									ELSE 603 END-- single customer
							END		
						
    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = @ActionID,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH
	    --Log customer general info
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
	    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)), SPACE(1))) + '" ' +
	    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'recommend="'+ COALESCE(CAST(@recommend AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ugroup="'+ COALESCE(CAST(@ugroup AS VARCHAR(5)), SPACE(1)) + '" ' +
	    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
	    'success="'+ COALESCE(CAST(@success AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
	    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
	    'isSearchAndCopy ="'+ COALESCE(CAST(@isSearchAndCopy AS VARCHAR(5)), SPACE(1)) + '" ' +
	    'copyFromCustID ="'+ COALESCE(CAST(@copyFromCustID AS VARCHAR(20)), SPACE(1)) + '" ' +
	    'copyFromUsername ="'+ COALESCE(@copyFromUsername, SPACE(1)) + '" ' +
		'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'

	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = @ActionID,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH

    --Log commission
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discount="'+ COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" ' 
    
    IF @IsMyanmarOdds = 1
		SET @LogSPData = @LogSPData + 'MyanmarOdds="'+ COALESCE(CAST(@MyanmarOddsAgent AS VARCHAR(50)), SPACE(1)) + '" ' 
	
    SELECT @LogSPData = @LogSPData + 'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscount="'+ COALESCE(CAST(@playerdiscount AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscountcs="'+ COALESCE(CAST(@playerdiscountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscount1x2="'+ COALESCE(CAST(@playerdiscount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' 
   
    IF @IsMyanmarOdds = 1
		SET @LogSPData = @LogSPData + 'playerdiscountMyanmarOdds="'+ COALESCE(CAST(@playerdiscountMyanmarOdds AS VARCHAR(50)), SPACE(1)) + '" ' 
		
	SET @LogSPData = @LogSPData + ' />' 
	
    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 203,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH	
	    --Log commission
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'discount="'+ COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" '  
    
    IF @IsMyanmarOdds = 1
		SET @LogSPData = @LogSPData + 'MyanmarOdds="'+ COALESCE(CAST(@MyanmarOddsAgent AS VARCHAR(50)), SPACE(1)) + '" ' 
	
    SELECT @LogSPData = @LogSPData +
	    'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscount="'+ COALESCE(CAST(@playerdiscount AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscountcs="'+ COALESCE(CAST(@playerdiscountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscount1x2="'+ COALESCE(CAST(@playerdiscount1x2 AS VARCHAR(50)), SPACE(1)) + '" '     

		IF @IsMyanmarOdds = 1
			SET @LogSPData = @LogSPData + 'playerdiscountMyanmarOdds="'+ COALESCE(CAST(@playerdiscountMyanmarOdds AS VARCHAR(50)), SPACE(1)) + '" ' 
			
		SET @LogSPData = @LogSPData + 'errCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'errMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'
	    
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 203,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH

    --Log Bet Setting
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
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
		'MPMv99MP="'+ COALESCE(CAST(@maxpermatchv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
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
		    @ActionID = 303,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH			
	    --Log Bet Setting
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
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
		'MPMv99MP="'+ COALESCE(CAST(@maxpermatchv99mp AS VARCHAR(50)), SPACE(1)) + '" ' +
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
	    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'

	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 303,
		    @TrackingValue = @LogSPData,
		    @duration = @duration		
    END CATCH
    	
    --Log statuses
    --get data prepare write log for Keno
    DECLARE @LogDataKeno NVARCHAR(4000) = ''
    SELECT @LogDataKeno = COALESCE(@LogDataKeno + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
	    + '=' + '"' + CAST(cg.IsDisabled AS VARCHAR(1)) + '"' + SPACE(1), + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
	    + '=' + '"' + CAST(cg.IsDisabled AS VARCHAR(1)) + '"' + SPACE(1))
    FROM dbo.CustGameType cg WITH(NOLOCK)
    INNER JOIN #tmp_GameType gt ON cg.GameTypeID = gt.ID
    WHERE cg.CustID = @recommend AND IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0

    SET @LogDataKeno = 'HideKeno="'+ COALESCE(CAST(@HideKeno AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno

	DECLARE @LogDataSP2 VARCHAR(4000)
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

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@closed AS VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(50)), SPACE(1)) + '" ' +
    'Danger="'+ COALESCE(CAST(@AgentDanger AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger2="'+ COALESCE(CAST(@AgentDanger2 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger3="'+ COALESCE(CAST(@AgentDanger3 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger4="'+ COALESCE(CAST(@AgentDanger4 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger5="'+ COALESCE(CAST(@AgentDanger5 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Abnormal="'+ COALESCE(CAST(@AgentAbnormal AS VARCHAR(5)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Special=" " ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend3="'+ COALESCE(CAST(@autosuspend3 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +	
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +   
 
    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableNumber="'+ COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno + @LogDataSP2 +
   
	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 1103,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH	
	    --Log statuses
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'closed="'+ COALESCE(CAST(@closed AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'Danger="'+ COALESCE(CAST(@AgentDanger AS VARCHAR(5)), SPACE(1)) + '" ' +
	    'Danger2="'+ COALESCE(CAST(@AgentDanger2 AS VARCHAR(5)), SPACE(1)) + '" ' +
	    'Danger3="'+ COALESCE(CAST(@AgentDanger3 AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger4="'+ COALESCE(CAST(@AgentDanger4 AS VARCHAR(5)), SPACE(1)) + '" ' +
		'Danger5="'+ COALESCE(CAST(@AgentDanger5 AS VARCHAR(5)), SPACE(1)) + '" ' +
	    'Abnormal="'+ COALESCE(CAST(@AgentAbnormal AS VARCHAR(5)), SPACE(1)) + '" ' +
		--20171206@Johnson: add more log for status
		'Special=" " ' +
		'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DoubleCommLosing="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend3="'+ COALESCE(CAST(@autosuspend3 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +	 
		'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
		'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +      
	  
	    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'DisableNumber="'+ COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' +	   
	  
		'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' + @LogDataKeno + @LogDataSP2 +
	    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'
    	
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 1103,
		    @TrackingValue = @LogSPData,
		    @duration = @duration		
    END CATCH
    	
    -- Write Log Credit
    Declare @LogSPCredit VARCHAR(200)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + ',
    SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
	
	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1207 as '@ActionID',
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
				@ActionID = 1207
		END TRY
		BEGIN CATCH		
			SELECT @LogSPCredit = @LogSPCredit + ', ErrMsg= ' + error_message()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1207
		END CATCH
	END	

    --Write PT log
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_1), SPACE(1)) + '" ' +
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
    'v99apt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9), SPACE(1))  + '" ' +
    'v99apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_20), SPACE(1))  + '" ' +   
	'v99apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9999), SPACE(1))  + '" ' +   

    'v161apt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_81), SPACE(1))  + '" ' +
    'v161apt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_83), SPACE(1))  + '" ' +
    'v161apt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_86), SPACE(1))  + '" ' +
    'v161apt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_88), SPACE(1))  + '" ' +
    'v161alivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_85), SPACE(1))  + '" ' +
    'v161alivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_86), SPACE(1))  + '" ' +
    'v161alivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_87), SPACE(1))  + '" ' +
    'v161alivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_89), SPACE(1))  + '" ' +
    'v161alivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_90), SPACE(1))  + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 403,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH	
	    --Write PT log
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag apt_1="'+ COALESCE(dbo.f_FomatNumericToChar(@apositiontaking_1), SPACE(1)) + '" ' +
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
	    'v99apt_9="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9), SPACE(1))  + '" ' +
	    'v99apt_20="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_20), SPACE(1))  + '" ' +  
		'v99apt_9999="'+ COALESCE(dbo.f_FomatNumericToChar(@v99apositiontaking_9999), SPACE(1))  + '" ' +  
	    'v161apt_81="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_81), SPACE(1))  + '" ' +
	    'v161apt_83="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_83), SPACE(1))  + '" ' +
	    'v161apt_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_86), SPACE(1))  + '" ' +
	    'v161apt_88="'+ COALESCE(dbo.f_FomatNumericToChar(@v161apositiontaking_88), SPACE(1))  + '" ' +
	    'v161alivept_85="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_85), SPACE(1))  + '" ' +
	    'v161alivept_86="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_86), SPACE(1))  + '" ' +
	    'v161alivept_87="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_87), SPACE(1))  + '" ' +
	    'v161alivept_89="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_89), SPACE(1))  + '" ' +
	    'v161alivept_90="'+ COALESCE(dbo.f_FomatNumericToChar(@v161alivepositiontaking_90), SPACE(1))  + '" ' +
	    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'

	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 403,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH
END
GO