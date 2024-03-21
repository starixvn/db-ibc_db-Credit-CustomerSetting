/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Ag]
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@fax NVARCHAR(50),
	@credit MONEY,	
	--
	@SettingXML VARCHAR(MAX) = '', -- store all settings
	--
	@Language 		VARCHAR(2)= 'E',
	@SubAccID 		INT = 0, --Sub-AccountID
	@recommend		INT,
	@ugroup			VARCHAR(5) = NULL,
	@SystemID		TINYINT=1,
	@IP 			VARCHAR(15)='',
	@ErrCode 		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg 		NVARCHAR(4000) = '' OUTPUT,
	--
	@isSearchAndCopy BIT = 0,
	@ExistingCustID INT = 0,
	@IsQRCode 		BIT  = 0,
	--
	@SettingStatus TINYINT = 0
AS
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
	- 20100728@Kiwi: invoke execute permission to [bodbExtAccNet,wsv_xnap]
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
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230427@Luke: Separate lock function for Basketball [Redmine: #185991]	
	- 20230510@Eden: Scale out DBTRANS for Credit [Redmine: #181595]
	- 20230615@Johnson: Check Problem Account  Limit New Downline Per Day [redmine: #189792]
	- 20230622@Helios: Alpha/ExtNAP - Create new downlines - Remove some obsolete rules [Redmine: #190167]
	- 20230711@Helios: Add Log VR+ Accumulate Balance [Redmine: #189649]
	- 20230918@Helios: Update rule VR+ for New Customer [Redmine: #194141]
	- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240321@Luke: NAP - Virtual rate - For Direct account :Change default of VR Status for newly created accounts to "Follow upline" [Redmine: #202624]
Param's Explanation:	
	- @ErrCode:
		= 0: add new member successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT, 3: UAT

	- @SettingXML: Json format
	'{
		"150": [
			{"SportType": "1","BetType": "1","Discount": "0.0010000"},
			{"SportType": "1","BetType": "5","Discount": "0.0070000"},
			{"SportType": "1","BetType": "4","Discount": "0.0035000"}
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
			{"SportType": "9914","BetType": "915","IsLive": "0","AgentPT": "38"},
			{"SportType": "9914","BetType": "917","IsLive": "0","AgentPT": "38"},
			{"SportType": "9913","BetType": "917","IsLive": "1","AgentPT": "38"},
			{"SportType": "9915","BetType": "918","IsLive": "0","AgentPT": "38"},
			{"SportType": "9913","BetType": "915","IsLive": "1","AgentPT": "38"},
			{"SportType": "9913","BetType": "916","IsLive": "1","AgentPT": "38"},
			{"SportType": "9914","BetType": "916","IsLive": "0","AgentPT": "38"}
		]
	}'
	
*/
BEGIN
    SET NOCOUNT ON

	declare @startRun datetime
    declare @endRun datetime
    declare @duration INT
    set @startRun = getdate()

	DECLARE @SettingType25 VARCHAR(MAX)= '', --Discount
			@SettingType26 VARCHAR(MAX)= '', --Bet Setting
			@SettingType27 VARCHAR(MAX)= '', --Parlay Max Payout
			@SettingType28 VARCHAR(MAX)= ''  --PT

	EXEC [Acc_CheckUM] @CustID = @recommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN

	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END

	DECLARE @uplineUsername NVARCHAR(50)
	
	SELECT @uplineUsername = username 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @recommend

	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @recommend , 
			@RuleID				= 'AG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= @IsQRCode , 
			@SystemID			= @SystemID , 
			@IP					= @IP ,
			@Credit				= @Credit ,
			@ErrCode			= @ErrCode OUTPUT , 
			@ErrMsg				= @ErrMsg OUTPUT , 
			@Language			= @Language
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN		
	END	

	---- check constraint on prefix username same as upline in case of creating member from alpha site
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
				   @ErrCode = 101
			RETURN
		END
	END 

    --Check an account disabled OR not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @recommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0	RETURN 

    declare @transcode bigint, @currency INT, @pwdexpiry datetime, @srecommend INT, @mrecommend INT,
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
    			
	    @site NVARCHAR(50),  	    		  
		@DisableSuperLive BIT = 0,
	    @matchlimit SMALLMONEY	

    DECLARE @_Site VARCHAR(10), @EnableVR BIT, @siteID SMALLINT

	SELECT @_Site = c.site,
		@siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend	

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
         , @EnableVR = ISNULL(virtualmultiplier, 1)           
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
		AND EXISTS( 
				SELECT 1 
				FROM dbo.Site WITH (NOLOCK)
				WHERE site = @site AND SiteLabel IN ('789y')
			)
				SET @EnableVR = 1

	DECLARE @Closed BIT = 0, @Suspend BIT = 0

    IF @isSearchAndCopy = 1
    BEGIN
		SELECT	@DisableOutright = DisableOutright,
			@DisableSuperLive = DisableSuperLive
		FROM custinfo WITH(NOLOCK)
		WHERE CustID = @ExistingCustID

		SELECT	@ugroup = ugroup
		FROM customer WITH(NOLOCK)
		WHERE CustID = @ExistingCustID

		SELECT @Closed = CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END
			,@suspended = CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END 							
		FROM dbo.CustProductStatus  WITH(NOLOCK)
		WHERE CustID = @ExistingCustID
    END

    /* 20130403@Jamie: Check Recommend <> MRecommend AND <> Srecommend OR NOT*/
    IF (@recommend = @mrecommend) OR (@recommend = @srecommend)
    BEGIN
	    SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Invalid user'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						    END,
			     @ErrCode = 350
	    RETURN	
    END

    /* END: Check Recommend <> MRecommend AND <> Srecommend OR NOT*/

    SELECT @ErrCode = 0

     -- MyanmarOdds
	DECLARE @IsMyanmarOdds BIT = 0
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	BEGIN
	   SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'The selected group is not allowed for this site'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40055,@Language)
						    END,
			     @ErrCode = 40055
	    RETURN	
	END

    --Check member group under Won currency
    IF @currency = 45 AND @ugroup NOT IN ('dea','deb','dec','ded')-- Won currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @ErrCode = 300
		    return			
	    END
    	
    IF @currency <> 45 AND @ugroup IN ('dea','deb','dec','ded') -- Others currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @ErrCode = 301
		    return			
	    END
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SELECT  @username = rtrim(ltrim(@username))
    SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END		
			    , @ErrCode = 201
	    RETURN
    END

	--Use maxcredit in CustAgent table 
    SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) FROM custAgent WITH(NOLOCK)  WHERE CustID = @recommend

    SELECT @Credit_AllOtherMember = ISNULL(sum(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1
    SELECT @MaxCredit_Mem = CASE WHEN @MaxCredit_Mem =0 THEN (@AgentCredit - @Credit_AllOtherMember) 
						    ELSE @MaxCredit_Mem END 
    IF @Credit + @Credit_AllOtherMember>@AgentCredit
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@AgentCredit - @Credit_AllOtherMember, '#,#0.####'))
			    , @ErrCode = 204
	    return
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70032,@Language), '{number}', FORMAT(@MaxCredit_Mem, '#,#0.####'))
			    , @ErrCode =217
	    return
    END 

	IF @credit <0
		or @recommend <=0
		or @ugroup not in ('a','b','c','d','hka','hkb','hkc','hkd','indoa','indob','indoc','indod','dea','deb','dec','ded')
	BEGIN
		select @ErrCode = 102
				,@ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per ball/ Max per match/ Credit/ Agent name/ user group.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10001,@Language)
					end
		return
	END

    SELECT @pwdexpiry = CASE WHEN @IsQRCode = 1 THEN '01/01/1900' ELSE DATEADD(dd, -1, GETDATE()) END

    --check suspended of Agent 
    IF @Asuspended =1
    BEGIN
	    set @suspended =1
    END

	IF @isSearchAndCopy = 1 --Clone Setting --> Get Setting from SourceCustID
	BEGIN
		EXEC Acc_CustomerIns_CloneMemberSetting_Sel
			 @siteid = @siteID
			,@currency = @currency
			,@ExistingCustID = @ExistingCustID
			,@AgentID = @recommend
			,@SettingType25 = @SettingType25 OUT
			,@SettingType26 = @SettingType26 OUT
			,@SettingType27 = @SettingType27 OUT
			,@SettingType28 = @SettingType28 OUT
			,@SettingStatus = @SettingStatus
	END
	ELSE --Fullmode --> Get setting from Json input value
	BEGIN
		--Parse Json to XML param
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
						SELECT SportType,BetType,IsLive,AgentPT
						FROM OPENJSON(@SettingXML,'$."153"') WITH (
								SportType SMALLINT  '$.SportType'
								,BetType SMALLINT  '$.BetType'
								,IsLive BIT  '$.IsLive'
								,AgentPT SMALLMONEY  '$.AgentPT'
							)
						FOR XML RAW('R'), ROOT ('Root'), TYPE
					)
				)
	END

	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@ugroup = @ugroup,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_Ag
		@srecommend =@srecommend,
		@mrecommend =@mrecommend,
		@recommend =@recommend,
		@siteid =@siteid,
		@currency =@currency,
		
		@SettingType26 = @SettingType26, --SB
		@SystemID = @SystemID,
		@SettingStatus  = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,
		@siteid =@siteid,
		@currency =@currency,
		
		@SettingType27 = @SettingType27, --SB
		@SettingStatus = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,		
		@siteid = @siteid,
		@currency = @currency,
		
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;

	IF @UplineClosed = 1
		SET @Closed = 1

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
	    @closed = @Closed,
    	
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
	   
	    @DoubleCommLosing = 0,-- off double comm losing WHEN create new member   	 
	  
		@DisableSuperLive = @DisableSuperLive,

    	@SystemID=@SystemID,
	    @credit = @credit,	
	    @IP = @IP,
	    @TransferOption_dec = NULL,
	    @copyFromCustID = @ExistingCustID,
	    @isSearchAndCopy = @isSearchAndCopy,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    IF @ErrCode <> 0
	    return
  
    EXEC dbo.Acc_CustomerInfo_Execrep_00
	    @custid = @custid,
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = @recommend,
	    @roleid = 1,--create member
		@isSearchAndCopy = @isSearchAndCopy,
		@copyFromCustID = @ExistingCustID,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType25 = @SettingType25, --Discount	
		@SettingType26 = @SettingType26, --Bet Setting
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
    				
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			

	    RETURN
    END	

	IF @isSearchAndCopy = 1
	BEGIN
		--Correct 3rd Products Setting 
		EXEC [Acc_CustSetting_DCSSettingCopyInsertMember]
			 @CustID = @CustID
			,@ExistingCustID = @ExistingCustID
			,@SubAccID = @SubAccID
			,@IP = @IP
			,@UserID = @creator
			,@SystemID = @SystemID
			,@IsCountPT = 0
			,@isSearchAndCopy = @isSearchAndCopy
			--,@ErrCode = @ErrCode OUTPUT
			--,@ErrMsg = @ErrMsg OUTPUT
			,@SettingStatus = @SettingStatus

		--IF @ErrCode <> 0
		--BEGIN
		--	--Error occurs
		--	SELECT @ErrMsg = CASE @Language 
		--							WHEN 'E' THEN 'Create member fail. Please try again'
		--							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		--						END	+ CHAR(10) + CHAR(13) + @ErrMsg
    	
		--	-- ROLLBACK MANUALLY	
		--	DELETE FROM CustPTSetting3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustSettingMode3rd			WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustDiscount3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustWinLossLimit_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustStakeLevel_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustBetSetting_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		--	DELETE FROM CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE CustID = @CustID

		--	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

		--	RETURN
		--END   
	END


    EXEC dbo.Acc_CustomerInfo_Execrep_01
		@custid = @custid, 
		@srecommend = @srecommend, 
		@mrecommend = @mrecommend, 
		@recommend = @recommend,
		@mode = 'sportbook'
    	
    IF @@ERROR <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @ErrCode=216
    	
	    -- ROLLBACK MANUALLY	
		DELETE FROM CustPTSetting3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSettingMode3rd			WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustDiscount3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustWinLossLimit_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustStakeLevel_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    RETURN
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
			    , @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
		DELETE FROM CustQRCode					WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustPTSetting3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSettingMode3rd			WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustDiscount3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustWinLossLimit_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustStakeLevel_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE CustID = @CustID	

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END
	
	If @SystemID IN (2, 10) -- ALPHA, Chatbot
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create member fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
							END
					, @ErrCode=216	

			DELETE FROM CustQRCode					WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustLimitPTSetting			WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd			WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Member		WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustStakeLevel_Member		WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustBetSetting_Member		WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE CustID = @CustID			

			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END	
	END

    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)

    declare @copyFromUsername VARCHAR(30)
    SELECT @copyFromUsername = username
    FROM customer WITH(NOLOCK)
    WHERE custid = @ExistingCustID

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
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
    'isSearchAndCopy ="'+ COALESCE(CAST(@isSearchAndCopy AS VARCHAR(5)), SPACE(1)) + '" ' +
    'copyFromCustID ="'+ COALESCE(CAST(@ExistingCustID AS VARCHAR(20)), SPACE(1)) + '" ' +
    'copyFromUsername ="'+ COALESCE(@copyFromUsername, SPACE(1)) + '" ' +
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)), SPACE(1)) + '" />'
	
	DECLARE @ActionID INT 
	SELECT @ActionID = CASE WHEN @systemID = 10 THEN 95083 --telegram chatbot
							ELSE  95084 -- Multiple customers
							END		
						
    
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = @ActionID,
		@TrackingValue = @LogSPData,
		@duration = @duration


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
 	
    --Log statuses
	--write log product status
	DECLARE @LogDataSP2 VARCHAR(4000) = ''
	
	CREATE TABLE #temSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)
	WHERE SettingType IN (4,11,13,21)
		AND realProductID NOT IN (24,59)
		
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
	--Log for VR+
	DECLARE @VRAccumulatedBalance BIT = 0

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 3)
		SET @VRLockedStatus_Basketball = 1
	
	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 4)
		SET @VRAccumulatedBalance = 1

    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@UplineClosed AS VARCHAR(50)), SPACE(1)) + '" ' +
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
	'VRAccumulatedBalance="'+ COALESCE(CAST(@VRAccumulatedBalance AS VARCHAR(10)),SPACE(1)) + '" ' +  
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +   
 	'VRLockStatus_Basketball="'+ COALESCE(CAST(@VRLockedStatus_Basketball AS VARCHAR(10)),SPACE(1)) + '" ' +   

    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataSP2 +
   
	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1103,
		@TrackingValue = @LogSPData,
		@duration = @duration  

	DECLARE @xml XML
	DECLARE @NewDiscountTbl TABLE (
			sporttype SMALLINT, 
			bettype SMALLINT, 
			playerdiscount DECIMAL(9,8), 									
			discount DECIMAL(9,8)
			)

	DECLARE @tblPT28 TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			AgentPT			SMALLMONEY
			)

	
	--Log Commission
	SELECT @xml = CONVERT(XML,@SettingType25)
	
	INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
		T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount
	FROM   @xml.nodes('/Root/R') T(c) 

	SELECT @LogSPData = '<Root>' 
			+ '<Discount>' 
				+ COALESCE(CAST((	SELECT SportType,BetType,PlayerDiscount,Discount as AgentDiscount
									FROM @NewDiscountTbl
									FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 261003,
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
		@ActionID = 262003,
		@TrackingValue = @LogSPData,
		@duration = @duration  

	--Log Position Taking
	--PT
	SELECT @xml = CONVERT(XML, @SettingType28)
				
	INSERT INTO @tblPT28(
			SportType,
			BetType, 
			IsLive,
			AgentPT)
	SELECT 
		T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
		T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT
	FROM  @xml.nodes('/Root/R') T(c)

	SELECT @LogSPData = '<Root>' 
			+ '<PT>'
				+ COALESCE(CAST((SELECT SportType, BetType, IsLive,AgentPT
							FROM @tblPT28
							FOR XML RAW('R')
							) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 263003,
		@TrackingValue = @LogSPData,
		@duration = @duration 
END
GO
