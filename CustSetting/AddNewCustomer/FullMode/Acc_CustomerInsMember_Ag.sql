/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO

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
	
	@playerdiscountnumber DECIMAL(9, 8) = 0,
	-- MyanmarOdds
	@playerdiscountMyanmarOdds DECIMAL(9,8)=0,
	
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
	
	@credit MONEY,
	@suspended BIT = NULL,	
	
	@DisableCasino BIT = 0, 
	@DisableNumber BIT = 0,	

	--@Disable180_1201 BIT = 0,
	
	@recommend INT,
	@ugroup VARCHAR(5),
	@closed BIT,
	
	@suspendedFlag VARCHAR(6) = NULL,
		
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
	
	
	@v161apositiontaking_81 SMALLMONEY, 
	@v161apositiontaking_83 SMALLMONEY, 
	@v161apositiontaking_86 SMALLMONEY, 
	@v161apositiontaking_88 SMALLMONEY = 0, 
	@v161alivepositiontaking_85 SMALLMONEY,
	@v161alivepositiontaking_86 SMALLMONEY,
	@v161alivepositiontaking_87 SMALLMONEY,
	@v161alivepositiontaking_89 SMALLMONEY = 0,
	@v161alivepositiontaking_90 SMALLMONEY = 0,

	@IP VARCHAR(15)='',
	@SystemID		TINYINT=1,
	@success BIT = 1 OUTPUT,
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
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
Param's Explanation:	
• @ErrCode:
    = 0: add new member successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON
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

    declare @transcode bigint, @currency INT, @pwdexpiry datetime, @srecommend INT,
	    @MinMinBet MONEY, @MaxMaxBet MONEY, @MaxMaxPerMatch MONEY,
	    @MinMinBetv2 MONEY, @MaxMaxBetv2 MONEY, @MaxMaxPerMatchv2 MONEY,
	    @MinMinBetv3 MONEY, @MaxMaxBetv3 MONEY, @MaxMaxPerMatchv3 MONEY,
	    @MinMinBetv5 MONEY, @MaxMaxBetv5 MONEY, @MaxMaxPerMatchv5 MONEY,
	    @MinMinBetv8 MONEY, @MaxMaxBetv8 MONEY, @MaxMaxPerMatchv8 MONEY,
	    @MinMinBetv10 MONEY, @MaxMaxBetv10 MONEY, @MaxMaxPerMatchv10 MONEY,
	    @MinMinBetv11 MONEY, @MaxMaxBetv11 MONEY, @MaxMaxPerMatchv11 MONEY,
	    @MinMinBetv99 MONEY, @MaxMaxBetv99 MONEY, @MaxMaxPerMatchv99 MONEY,	
	    @MinMinBetv99MP MONEY, @MaxMaxBetv99MP MONEY, @MaxMaxPerMatchv99MP MONEY,	
	    
	    @MinMinBetv1MP MONEY, @MaxMaxBetv1MP MONEY, @MaxMaxPerMatchv1MP MONEY,		    
	  
	    @MinMinBetv161 MONEY, @MaxMaxBetv161 MONEY, @MaxMaxPerMatchv161 MONEY,@MaxMaxPerBallv161 MONEY,	
	    --@MinBetv180 MONEY, @MaxBetv180 MONEY, @MaxPerMatchv180 MONEY,
	    --@MinMinBetv180 MONEY, @MaxMaxBetv180 MONEY, @MaxMaxPerMatchv180 MONEY, 
	    --@MinBetv181 MONEY, @MaxBetv181 MONEY, @MaxPerMatchv181 MONEY,
	    --@MinMinBetv181 MONEY, @MaxMaxBetv181 MONEY, @MaxMaxPerMatchv181 MONEY, 
	    --@MinBetv182 MONEY, @MaxBetv182 MONEY, @MaxPerMatchv182 MONEY,
	    --@MinMinBetv182 MONEY, @MaxMaxBetv182 MONEY, @MaxMaxPerMatchv182 MONEY, 
	    --@MinBetv183 MONEY, @MaxBetv183 MONEY, @MaxPerMatchv183 MONEY,
	    --@MinMinBetv183 MONEY, @MaxMaxBetv183 MONEY, @MaxMaxPerMatchv183 MONEY, 
	    --@MinBetv184 MONEY, @MaxBetv184 MONEY, @MaxPerMatchv184 MONEY,
	    --@MinMinBetv184 MONEY, @MaxMaxBetv184 MONEY, @MaxMaxPerMatchv184 MONEY, 
	    --@MinBetv185 MONEY, @MaxBetv185 MONEY, @MaxPerMatchv185 MONEY,
	    --@MinMinBetv185 MONEY, @MaxMaxBetv185 MONEY, @MaxMaxPerMatchv185 MONEY,
	    --@MinBetv186 MONEY, @MaxBetv186 MONEY, @MaxPerMatchv186 MONEY,
	    --@MinMinBetv186 MONEY, @MaxMaxBetv186 MONEY, @MaxMaxPerMatchv186 MONEY, 	
    	
	    @AgentCredit MONEY, @Credit_AllOtherMember MONEY,
	    @MaxCredit_Mem MONEY,
	    @Asuspended BIT,
	    @UplineClosed BIT,
	    @DisableOutright BIT,	   
	    --@HideVirtualSports  BIT,
	    @DisableCasinoBonus BIT,	  

	    @AgentDanger tinyint,
	    @AgentDanger2 tinyint,
	    @AgentDanger3 tinyint,
	    @AgentAbnormal tinyint,
    	
	    -- check autosuspend's upline
	    @autosuspend BIT,
	    @autosuspend2 BIT,
	    
	    --E-Sports
	    @DisableEsports BIT,

    --	@AgentMaxPerMatch MONEY, @AgentMaxPerMatchb MONEY,
    --	@MaxPerMatch_AllOtherMember MONEY, @MaxPerMatchv2_AllOtherMember MONEY,

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
	    --@v2mpositiontaking_9 SMALLMONEY,
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
    	
	    --@v201mpositiontaking_2 SMALLMONEY,
	    --@v201mpositiontaking_3 SMALLMONEY,
    	
	    @v161mpositiontaking_81 SMALLMONEY, 
	    @v161mpositiontaking_83 SMALLMONEY, 
	    @v161mpositiontaking_86 SMALLMONEY, 
	    @v161mpositiontaking_88 SMALLMONEY, 
	    @v161mlivepositiontaking_85 SMALLMONEY,
	    @v161mlivepositiontaking_86 SMALLMONEY,
	    @v161mlivepositiontaking_87 SMALLMONEY,
	    @v161mlivepositiontaking_89 SMALLMONEY,
	    @v161mlivepositiontaking_90 SMALLMONEY,    	
	 
		@v255mpositiontaking_1701 SMALLMONEY,
    	
	    --@v180mpositiontaking_1201 SMALLMONEY,
	    --@v181mpositiontaking_1231 SMALLMONEY,
	    --@v182mpositiontaking_1231 SMALLMONEY,
	    --@v183mpositiontaking_1231 SMALLMONEY,
	    --@v184mpositiontaking_1231 SMALLMONEY,
	    --@v185mpositiontaking_1231 SMALLMONEY,
	    --@v186mpositiontaking_1220 SMALLMONEY,
    	
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
	    --@v2spositiontaking_9 SMALLMONEY,
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
    		
	    --@v201spositiontaking_2 SMALLMONEY,
	    --@v201spositiontaking_3 SMALLMONEY,
    	
	    @v161spositiontaking_81 SMALLMONEY, 
	    @v161spositiontaking_83 SMALLMONEY, 
	    @v161spositiontaking_86 SMALLMONEY, 
	    @v161spositiontaking_88 SMALLMONEY, 
	    @v161slivepositiontaking_85 SMALLMONEY,
	    @v161slivepositiontaking_86 SMALLMONEY,
	    @v161slivepositiontaking_87 SMALLMONEY,
	    @v161slivepositiontaking_89 SMALLMONEY,
	    @v161slivepositiontaking_90 SMALLMONEY,    	
	 
		@v255spositiontaking_1701 SMALLMONEY,
    	
	    --@v180spositiontaking_1201 SMALLMONEY,
	    --@v181spositiontaking_1231 SMALLMONEY,
	    --@v182spositiontaking_1231 SMALLMONEY,
	    --@v183spositiontaking_1231 SMALLMONEY,
	    --@v184spositiontaking_1231 SMALLMONEY,
	    --@v185spositiontaking_1231 SMALLMONEY,
	    --@v186spositiontaking_1220 SMALLMONEY,
    	
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

	    --v201
	    --@v201discount DECIMAL(9, 8),
	    --@v201adiscount DECIMAL(9, 8),
	    --@v201sdiscount DECIMAL(9, 8),

	    --v161
	    @discountnumber DECIMAL(9, 8),
	    @adiscountnumber DECIMAL(9, 8),
	    @sdiscountnumber DECIMAL(9, 8),
    	
		--v255
	    @v255discount_1701 DECIMAL(9, 8),
	    @v255adiscount_1701 DECIMAL(9, 8),
	    @v255sdiscount_1701 DECIMAL(9, 8),
    	
	    @site NVARCHAR(50),
    --	@maxpos SMALLMONEY,
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
	    --@auto_v2spositiontaking_9 SMALLMONEY,
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
    	
	    @auto_v161spositiontaking_81 SMALLMONEY,
	    @auto_v161spositiontaking_83 SMALLMONEY,
	    @auto_v161spositiontaking_86 SMALLMONEY,
	    @auto_v161spositiontaking_88 SMALLMONEY,
	    @auto_v161slivepositiontaking_85 SMALLMONEY,
	    @auto_v161slivepositiontaking_86 SMALLMONEY,
	    @auto_v161slivepositiontaking_87 SMALLMONEY,
	    @auto_v161slivepositiontaking_89 SMALLMONEY,
	    @auto_v161slivepositiontaking_90 SMALLMONEY,

	    --@auto_v201spositiontaking_2 SMALLMONEY,
	    --@auto_v201spositiontaking_3 SMALLMONEY,
		@auto_v255spositiontaking_1701 SMALLMONEY,
    	
	    --@auto_v180spositiontaking_1201 SMALLMONEY,
	    --@auto_v181spositiontaking_1231 SMALLMONEY,
	    --@auto_v182spositiontaking_1231 SMALLMONEY,
	    --@auto_v183spositiontaking_1231 SMALLMONEY,
	    --@auto_v184spositiontaking_1231 SMALLMONEY,
	    --@auto_v185spositiontaking_1231 SMALLMONEY,
	    --@auto_v186spositiontaking_1220 SMALLMONEY,
    	
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
	    --@max_v2spositiontaking_9 SMALLMONEY,
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

	    @max_v161spositiontaking_81 SMALLMONEY,
	    @max_v161spositiontaking_83 SMALLMONEY,
	    @max_v161spositiontaking_86 SMALLMONEY,
	    @max_v161spositiontaking_88 SMALLMONEY,
	    @max_v161slivepositiontaking_85 SMALLMONEY,
	    @max_v161slivepositiontaking_86 SMALLMONEY,
	    @max_v161slivepositiontaking_87 SMALLMONEY,
	    @max_v161slivepositiontaking_89 SMALLMONEY,
	    @max_v161slivepositiontaking_90 SMALLMONEY,
    			
	    --@max_v201spositiontaking_2 SMALLMONEY,
	    --@max_v201spositiontaking_3 SMALLMONEY,
		@max_v255spositiontaking_1701 SMALLMONEY,
    	
	    --@max_v180spositiontaking_1201 SMALLMONEY,
	    --@max_v181spositiontaking_1231 SMALLMONEY,
	    --@max_v182spositiontaking_1231 SMALLMONEY,
	    --@max_v183spositiontaking_1231 SMALLMONEY,
	    --@max_v184spositiontaking_1231 SMALLMONEY,
	    --@max_v185spositiontaking_1231 SMALLMONEY,
	    --@max_v186spositiontaking_1220 SMALLMONEY,
    	
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
    --	@maxdownlinepos SMALLMONEY,
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
	    --@isauto_v2spositiontaking_9 BIT,
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

	    @isauto_v161spositiontaking_81 BIT,
	    @isauto_v161spositiontaking_83 BIT,
	    @isauto_v161spositiontaking_86 BIT,
	    @isauto_v161spositiontaking_88 BIT,
	    @isauto_v161slivepositiontaking_85 BIT,
	    @isauto_v161slivepositiontaking_86 BIT,
	    @isauto_v161slivepositiontaking_87 BIT,
	    @isauto_v161slivepositiontaking_89 BIT,
	    @isauto_v161slivepositiontaking_90 BIT,    
    		
	    --@isauto_v201spositiontaking_2 BIT,
	    --@isauto_v201spositiontaking_3 BIT,
	    
		@isauto_v255spositiontaking_1701 BIT,
    	
	    --@isauto_v180spositiontaking_1201 BIT,
	    --@isauto_v181spositiontaking_1231 BIT,
	    --@isauto_v182spositiontaking_1231 BIT,
	    --@isauto_v183spositiontaking_1231 BIT,
	    --@isauto_v184spositiontaking_1231 BIT,
	    --@isauto_v185spositiontaking_1231 BIT,
	    --@isauto_v186spositiontaking_1220 BIT,
    	
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
	    --@max_v2apositiontaking_9 SMALLMONEY,
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
    	
	    @max_v161apositiontaking_81 SMALLMONEY,
	    @max_v161apositiontaking_83 SMALLMONEY,
	    @max_v161apositiontaking_86 SMALLMONEY,
	    @max_v161apositiontaking_88 SMALLMONEY,
	    @max_v161alivepositiontaking_85 SMALLMONEY,
	    @max_v161alivepositiontaking_86 SMALLMONEY,
	    @max_v161alivepositiontaking_87 SMALLMONEY,
	    @max_v161alivepositiontaking_89 SMALLMONEY,
	    @max_v161alivepositiontaking_90 SMALLMONEY,
    	
	  
		@v255apositiontaking_1701 SMALLMONEY,	
    	
	    --@v180apositiontaking_1201 SMALLMONEY,
	    --@v181apositiontaking_1231 SMALLMONEY,
	    --@v182apositiontaking_1231 SMALLMONEY,
	    --@v183apositiontaking_1231 SMALLMONEY,
	    --@v184apositiontaking_1231 SMALLMONEY,
	    --@v185apositiontaking_1231 SMALLMONEY,
	    --@v186apositiontaking_1220 SMALLMONEY,
    	
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
	    --@max_v2mpositiontaking_9 SMALLMONEY,
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
    	
	    @max_v161mpositiontaking_81 SMALLMONEY,
	    @max_v161mpositiontaking_83 SMALLMONEY,
	    @max_v161mpositiontaking_86 SMALLMONEY,
	    @max_v161mpositiontaking_88 SMALLMONEY,
	    @max_v161mlivepositiontaking_85 SMALLMONEY,
	    @max_v161mlivepositiontaking_86 SMALLMONEY,
	    @max_v161mlivepositiontaking_87 SMALLMONEY,
	    @max_v161mlivepositiontaking_89 SMALLMONEY,
	    @max_v161mlivepositiontaking_90 SMALLMONEY,    	
    	
	    --@max_v201mpositiontaking_2 SMALLMONEY,
	    --@max_v201mpositiontaking_3 SMALLMONEY,
		@max_v255mpositiontaking_1701 SMALLMONEY,
    	
	    --@max_v180mpositiontaking_1201 SMALLMONEY,
	    --@max_v181mpositiontaking_1231 SMALLMONEY,
	    --@max_v182mpositiontaking_1231 SMALLMONEY,
	    --@max_v183mpositiontaking_1231 SMALLMONEY,
	    --@max_v184mpositiontaking_1231 SMALLMONEY,
	    --@max_v185mpositiontaking_1231 SMALLMONEY,
	    --@max_v186mpositiontaking_1220 SMALLMONEY,
    	
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
	    --@auto_v2mpositiontaking_9 SMALLMONEY,
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

	    @auto_v161mpositiontaking_81 SMALLMONEY,
	    @auto_v161mpositiontaking_83 SMALLMONEY,
	    @auto_v161mpositiontaking_86 SMALLMONEY,
	    @auto_v161mpositiontaking_88 SMALLMONEY,
	    @auto_v161mlivepositiontaking_85 SMALLMONEY,
	    @auto_v161mlivepositiontaking_86 SMALLMONEY,
	    @auto_v161mlivepositiontaking_87 SMALLMONEY,
	    @auto_v161mlivepositiontaking_89 SMALLMONEY,
	    @auto_v161mlivepositiontaking_90 SMALLMONEY,    	

	    --@auto_v201mpositiontaking_2 SMALLMONEY,
	    --@auto_v201mpositiontaking_3 SMALLMONEY,
		@auto_v255mpositiontaking_1701 SMALLMONEY,
    	
	    --@auto_v180mpositiontaking_1201 SMALLMONEY,
	    --@auto_v181mpositiontaking_1231 SMALLMONEY,
	    --@auto_v182mpositiontaking_1231 SMALLMONEY,
	    --@auto_v183mpositiontaking_1231 SMALLMONEY,
	    --@auto_v184mpositiontaking_1231 SMALLMONEY,
	    --@auto_v185mpositiontaking_1231 SMALLMONEY,
	    --@auto_v186mpositiontaking_1220 SMALLMONEY,
    	
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
	    --@isauto_v2mpositiontaking_9 BIT,
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
    	    	
	    @isauto_v161mpositiontaking_81 BIT,
	    @isauto_v161mpositiontaking_83 BIT,
	    @isauto_v161mpositiontaking_86 BIT,
	    @isauto_v161mpositiontaking_88 BIT,
	    @isauto_v161mlivepositiontaking_85 BIT,
	    @isauto_v161mlivepositiontaking_86 BIT,
	    @isauto_v161mlivepositiontaking_87 BIT,
	    @isauto_v161mlivepositiontaking_89 BIT,
	    @isauto_v161mlivepositiontaking_90 BIT,    	
    		
	    --@isauto_v201mpositiontaking_2 BIT,
	    --@isauto_v201mpositiontaking_3 BIT,
		@isauto_v255mpositiontaking_1701 BIT,
    	
	    --@isauto_v180mpositiontaking_1201 BIT,
	    --@isauto_v181mpositiontaking_1231 BIT,
	    --@isauto_v182mpositiontaking_1231 BIT,
	    --@isauto_v183mpositiontaking_1231 BIT,
	    --@isauto_v184mpositiontaking_1231 BIT,
	    --@isauto_v185mpositiontaking_1231 BIT,
	    --@isauto_v186mpositiontaking_1220 BIT,
    	
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
		@DisableGoldDeluxe BIT = 0,
		@HideGoldDeluxe BIT = 1,
		
		@DisableColossusBet BIT = 0,
		@HideColossusBet BIT = 1,
		
		@DisableSuperLive BIT = 0,

	    @matchlimit SMALLMONEY,
	    @discount DECIMAL(9, 8),
	    @discountcs DECIMAL(9, 8),
	    @virtualmultiplier SMALLMONEY
    	
    declare @ErrType VARCHAR(4000)	

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --SELECT @maxpos = 0.7, @maxdownlinepos = 0.7
    --SELECT @adiscount = CASE WHEN @ugroup in ('a','hka') THEN 0.0025 WHEN @ugroup in ('b','hkb') THEN 0.005 WHEN @ugroup in ('c','hkc') THEN 0.0075 ELSE 0.01 END, @adiscountcs=0.05
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    SELECT @currency = currency
         , @mrecommend = mrecommend
         , @srecommend = srecommend
         , @AgentCredit = ISNULL(Credit, 0)     
         , @Asuspended = reject
         , @UplineClosed = closed
         , @matchlimit = matchlimit
         , @AgentDanger = Danger
         , @AgentDanger2 = Danger2
         , @AgentDanger3 = Danger3
         , @AgentAbnormal = Abnormal
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
         --, @MaxPerMatchv180 = MaxPerMatch180
         --, @MaxPerMatchv181 = MaxPerMatch181
         --, @MaxPerMatchv182 = MaxPerMatch182
         --, @MaxPerMatchv183 = MaxPerMatch183
         --, @MaxPerMatchv184 = MaxPerMatch184
         --, @MaxPerMatchv185 = MaxPerMatch185
         --, @MaxPerMatchv186 = MaxPerMatch186       
        
         , @DisableCasino = CASE WHEN DisableCasino = 1 THEN 1 ELSE @DisableCasino END        
         , @DisableOutright = DisableOutright 
		 , @DisableColossusBet = DisableColossusBet      
         , @DisableNumber = CASE WHEN DisableNumber = 1 THEN 1 ELSE @DisableNumber END
         --, @Disable180_1201 = DisableVirtualSports
         --, @HideVirtualSports = HideVirtualSports
         , @DisableCasinoBonus = 1
         , @virtualmultiplier = ISNULL(virtualmultiplier, 1)           
         , @HideKeno = HideKeno
         , @DisableEsports = DisableEsports
		 , @DisableGoldDeluxe = DisableGoldDeluxe
		 , @HideGoldDeluxe = HideGoldDeluxe
		 , @DisableColossusBet = DisableColossusBet
		 , @HideColossusBet = HideColossusBet
		 , @DisableSuperLive = DisableSuperLive
     FROM custinfo WITH(NOLOCK)
     WHERE CustID = @recommend

	--Check Limit max members creation per Super
	EXEC Age_MaxMemberLimitBySuperCheck @custid = @srecommend, @ErrMsg = @ErrMsg OUTPUT, @ErrCode = @ErrCode OUTPUT
	IF @ErrCode <> 0 RETURN
    
    IF @isSearchAndCopy = 1
    BEGIN
        SELECT	@DisableEsports = DisableEsports,
				@DisableOutright = DisableOutright,
				@DisableColossusBet = DisableColossusBet,
				@DisableSuperLive = DisableSuperLive
				--@virtualmultiplier = ISNULL(virtualmultiplier, 1)
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
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsValid BIT
    
    -- MyanmarOdds
    
	DECLARE @IsMyanmarOdds BIT = 0
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	BEGIN
		 SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'The selected group is not allowed for this site'
						    END,
			    @Success = 0, @ErrCode = 351
	    RETURN	
	END
	
	-- Reset discount value in case its value > upline
	IF @IsMyanmarOdds = 1
	BEGIN
		SELECT @playerdiscountMyanmarOdds = CASE 
											WHEN @playerdiscountMyanmarOdds > commRate THEN commRate
											ELSE @playerdiscountMyanmarOdds  
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @recommend
			AND sporttype = 1   
			AND bettype = 301  
	END
    
                EXEC dbo.Acc_CustomerInsMember_Ag_CheckParam
	    @playerdiscount=@playerdiscount,
	    @playerdiscountcs=@playerdiscountcs,
	    @playerdiscount1x2 = @playerdiscount1x2,--1x2
	    @playerdiscountnumber = @playerdiscountnumber,
	    @discountMyanmarOdds = @playerdiscountMyanmarOdds,
	    @MinBet=@MinBet,
	    @MaxBet=@MaxBet,
	    @MaxPerMatch=@MaxPerMatch,
    	
	    @MinBetv2=@MinBetv2,
	    @MaxBetv2=@MaxBetv2,
	    @MaxPerMatchv2=@MaxPerMatchv2,
    	
	    @MinBetv3=@MinBetv3,
	    @MaxBetv3=@MaxBetv3,
	    @MaxPerMatchv3=@MaxPerMatchv3,

	    @MinBetv5=@MinBetv5,
	    @MaxBetv5=@MaxBetv5,
	    @MaxPerMatchv5=@MaxPerMatchv5,

	    @MinBetv8=@MinBetv8,
	    @MaxBetv8=@MaxBetv8,
	    @MaxPerMatchv8=@MaxPerMatchv8,

	    @MinBetv10=@MinBetv10,
	    @MaxBetv10=@MaxBetv10,
	    @MaxPerMatchv10=@MaxPerMatchv10,

	    @MinBetv11=@MinBetv11,
	    @MaxBetv11=@MaxBetv11,
	    @MaxPerMatchv11=@MaxPerMatchv11,

	    @MinBetv99=@MinBetv99,
	    @MaxBetv99=@MaxBetv99,
	    @MaxPerMatchv99=@MaxPerMatchv99,
    	
	    @MinBetv99MP = @MinBetv99MP,
	    @MaxBetv99MP = @MaxBetv99MP,
	    @MaxPerMatchv99MP = @MaxPerMatchv99MP,
    	
    	@MinBetv1MP = @MinBetv1MP,
	    @MaxBetv1MP = @MaxBetv1MP,
	    @MaxPerMatchv1MP = @MaxPerMatchv1MP,	    
	    
	    @MinBetv161 = @MinBetv161,
	    @MaxBetv161 = @MaxBetv161,
	    @MaxPerBallv161 = @MaxPerBallv161,
	    @MaxPerMatchv161 = @MaxPerMatchv161,

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
	    --@v2apositiontaking_9=@v2apositiontaking_9,
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
	    @language=@language

    IF @IsValid = 0
    BEGIN
	    return
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
    --@username = replace(@username, ' ', '')

    SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

    IF exists(SELECT 1 FROM customer WITH(NOLOCK) WHERE username= @username)
	    OR exists (SELECT 1 FROM customer WITH(NOLOCK) WHERE username2 = @username)
	    OR exists(SELECT 1 FROM custsub WITH(NOLOCK) WHERE username= @username) 
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END		
			    , @success = 0, @ErrCode = 201
	    return
    END

    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType +  (CASE WHEN MP=0 THEN Name ELSE 'Mixed Sports' END )       + ', '
    FROM #tmp_Sports sports inner join
    (
				    SELECT 1 AS sporttype,0 AS MP, @MinBet AS MinBet, @MaxBet AS MaxBet, @MaxPerMatch AS MaxPerMatch
	    UNION ALL	SELECT 2 AS sporttype,0 AS MP, @MinBetv2 AS MinBet, @MaxBetv2 AS MaxBet, @MaxPerMatchv2 AS MaxPerMatch
	    UNION ALL	SELECT 3 AS sporttype,0 AS MP, @MinBetv3 AS MinBet, @MaxBetv3 AS MaxBet, @MaxPerMatchv3 AS MaxPerMatch
	    UNION ALL	SELECT 5 AS sporttype,0 AS MP, @MinBetv5 AS MinBet, @MaxBetv5 AS MaxBet, @MaxPerMatchv5 AS MaxPerMatch
	    UNION ALL	SELECT 8 AS sporttype,0 AS MP, @MinBetv8 AS MinBet, @MaxBetv8 AS MaxBet, @MaxPerMatchv8 AS MaxPerMatch
	    UNION ALL	SELECT 10 AS sporttype,0 AS MP, @MinBetv10 AS MinBet, @MaxBetv10 AS MaxBet, @MaxPerMatchv10 AS MaxPerMatch
	    UNION ALL	SELECT 11 AS sporttype,0 AS MP, @MinBetv11 AS MinBet, @MaxBetv11 AS MaxBet, @MaxPerMatchv11 AS MaxPerMatch
	    UNION ALL	SELECT 99 AS sporttype,0 AS MP, @MinBetv99 AS MinBet, @MaxBetv99 AS MaxBet, @MaxPerMatchv99 AS MaxPerMatch	 
	    UNION ALL	SELECT 99 AS sporttype,1 AS MP, @MinBetv99MP AS MinBet, @MaxBetv99MP AS MaxBet, @MaxPerMatchv99MP AS MaxPerMatch
	    
	    UNION ALL	SELECT 1 AS sporttype,1 AS MP, @MinBetv1MP AS MinBet, @MaxBetv1MP AS MaxBet, @MaxPerMatchv1MP AS MaxPerMatch   
	  
	    UNION ALL	SELECT 161 AS sporttype,0 AS MP, @MinBetv161 AS MinBet, @MaxBetv161 AS MaxBet, @MaxPerMatchv161 AS MaxPerMatch	 
    ) AS b on sports.ID = b.sporttype
    WHERE (MinBet<>0 AND MaxBet <> 0 AND  MinBet>MaxBet) 
	    OR (MaxBet<> 0 AND MaxPerMatch <> 0 AND MaxBet>MaxPerMatch) 
	    OR (MinBet <> 0 AND MaxPerMatch <> 0 AND MinBet>MaxPerMatch)

    IF @ErrType <>''
    BEGIN
	    SELECT
		    @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Min bet must be less than max bet AND max bet must be less than max per match ('+@ErrType+').'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + @ErrType + ').'
					    END		
					    + char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch),
		    @success = 0, @ErrCode = 202
	    return
    END

    --SELECT @ErrType = ''
    --SELECT @ErrType = @ErrType +sportname
    --FROM @tmp_Sports sports 
    --WHERE sporttype = 161 AND ((@MaxBetv161 <> 0 AND @MaxPerBallv161 <>0 AND @MaxBetv161 >@MaxPerBallv161)
    --OR (@MaxPerBallv161 <> 0 AND @MaxPerMatchv161 <> 0 AND @MaxPerBallv161 > @MaxPerMatchv161))
    --
    --IF @ErrType <> ''
    --BEGIN
    --	SELECT
    --		@ErrMsg = CASE @Language 
    --							WHEN 'E' THEN 'Max per ball must be greater than OR equal to max bet AND less than OR equal to Max Per Match('+@ErrType+').'
    --							WHEN 'CS' THEN N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注('+@ErrType+').'
    --							WHEN 'CT' THEN N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注 ('+@ErrType+').'
    --							WHEN 'TH' THEN N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน ('+@ErrType+').'
    --							WHEN 'J' THEN N'Max per ball must be greater than OR equal to max bet AND less than OR equal to Max Per Match('+@ErrType+').'
    --							WHEN 'ES' THEN N'Max per ball must be greater than OR equal to max bet AND less than OR equal to Max Per Match('+@ErrType+').'
    --							WHEN 'KO' THEN N'Max per ball must be greater than OR equal to max bet AND less than OR equal to Max Per Match('+@ErrType+').'
    --							else N'Max per ball must be greater than OR equal to max bet AND less than OR equal to Max Per Match('+@ErrType+').'
    --					end		
    --					+ char(13) + char(10) + convert(varchar(20), @MaxBetv161) + '-' + convert(varchar(20), @MaxPerBallv161) + '-' + convert(varchar(20), @MaxPerMatchv161),
    --		@success = 0, @ErrCode = 202
    --	RETURN	
    --END



    --a2,m2,u2,i2
    SELECT @max_apositiontaking_1 = apositiontaking, @max_alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @auto_mpositiontaking_1 = autompositiontaking, @auto_mlivepositiontaking_1 = autolivempositiontaking, @isauto_mpositiontaking_1 = isautompositiontaking, @isauto_mlivepositiontaking_1 = isautolivempositiontaking, @minMinBet = MinBet, @maxMaxBet = MaxBet, @discount = CASE WHEN @ugroup in ('a','hka','dea') THEN groupa WHEN @ugroup in ('b','hkb','deb') THEN groupb WHEN @ugroup in ('c','hkc','dec') THEN groupc ELSE groupd END FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 1
    --SELECT @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @minMinBet = MinBet, @maxMaxBet = MaxBet, @maxdiscount = CASE WHEN @ugroup in ('a','hka') THEN groupa WHEN @ugroup in ('b','hkb') THEN groupb WHEN @ugroup in ('c','hkc') THEN groupc ELSE groupd END FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 1
    SELECT @max_apositiontaking_3 = apositiontaking, @max_alivepositiontaking_3 = alivepositiontaking, @mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @auto_mpositiontaking_3 = autompositiontaking, @auto_mlivepositiontaking_3 = autolivempositiontaking, @isauto_mpositiontaking_3 = isautompositiontaking, @isauto_mlivepositiontaking_3 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 1
    SELECT @max_apositiontaking_7 = apositiontaking, @max_alivepositiontaking_7 = alivepositiontaking, @mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @auto_mpositiontaking_7 = autompositiontaking, @auto_mlivepositiontaking_7 = autolivempositiontaking, @isauto_mpositiontaking_7 = isautompositiontaking, @isauto_mlivepositiontaking_7 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=7 AND sporttype = 1
    SELECT @max_apositiontaking_8 = apositiontaking, @max_alivepositiontaking_8 = alivepositiontaking, @mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @auto_mpositiontaking_8 = autompositiontaking, @auto_mlivepositiontaking_8 = autolivempositiontaking, @isauto_mpositiontaking_8 = isautompositiontaking, @isauto_mlivepositiontaking_8 = isautolivempositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=8 AND sporttype = 1
    SELECT @max_apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @auto_mpositiontaking_2 = autompositiontaking, @isauto_mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 1
    SELECT @max_apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @auto_mpositiontaking_4 = autompositiontaking, @isauto_mpositiontaking_4 = isautompositiontaking, @discountcs = discount FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 4 AND sporttype = 1
    --SELECT @mpositiontaking_4 = mpositiontaking, @maxdiscountcs = discount FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 4 AND sporttype = 1
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

    SELECT @max_v2apositiontaking_1 = apositiontaking, @v2mpositiontaking_1 = mpositiontaking, @auto_v2mpositiontaking_1 = autompositiontaking, @isauto_v2mpositiontaking_1 = isautompositiontaking, @minMinBetv2 = MinBet, @maxMaxBetv2 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=2
    SELECT @max_v2apositiontaking_2 = apositiontaking, @v2mpositiontaking_2 = mpositiontaking, @auto_v2mpositiontaking_2 = autompositiontaking, @isauto_v2mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype=2
    SELECT @max_v2apositiontaking_3 = apositiontaking, @v2mpositiontaking_3 = mpositiontaking, @auto_v2mpositiontaking_3 = autompositiontaking, @isauto_v2mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=2
    SELECT @max_v2apositiontaking_7 = apositiontaking, @v2mpositiontaking_7 = mpositiontaking, @auto_v2mpositiontaking_7 = autompositiontaking, @isauto_v2mpositiontaking_7 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=7 AND sporttype=2
    SELECT @max_v2apositiontaking_8 = apositiontaking, @v2mpositiontaking_8 = mpositiontaking, @auto_v2mpositiontaking_8 = autompositiontaking, @isauto_v2mpositiontaking_8 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=8 AND sporttype=2
    --SELECT @max_v2apositiontaking_9 = apositiontaking, @v2mpositiontaking_9 = mpositiontaking, @auto_v2mpositiontaking_9 = autompositiontaking, @isauto_v2mpositiontaking_9 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9 AND sporttype=2
    SELECT @max_v2apositiontaking_20 = apositiontaking, @v2mpositiontaking_20 = mpositiontaking, @auto_v2mpositiontaking_20 = autompositiontaking, @isauto_v2mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=2
    
    SELECT @max_v2apositiontaking_9999 = apositiontaking, @v2mpositiontaking_9999 = mpositiontaking, @auto_v2mpositiontaking_9999 = autompositiontaking, @isauto_v2mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype=2
    
    SELECT @max_v3apositiontaking_1 = apositiontaking, @v3mpositiontaking_1 = mpositiontaking, @auto_v3mpositiontaking_1 = autompositiontaking, @isauto_v3mpositiontaking_1 = isautompositiontaking, @minMinBetv3 = MinBet, @maxMaxBetv3 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 3
    SELECT @max_v3apositiontaking_2 = apositiontaking, @v3mpositiontaking_2 = mpositiontaking, @auto_v3mpositiontaking_2 = autompositiontaking, @isauto_v3mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 3
    SELECT @max_v3apositiontaking_3 = apositiontaking, @v3mpositiontaking_3 = mpositiontaking, @auto_v3mpositiontaking_3 = autompositiontaking, @isauto_v3mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 3
    SELECT @max_v3apositiontaking_20 = apositiontaking, @v3mpositiontaking_20 = mpositiontaking, @auto_v3mpositiontaking_20 = autompositiontaking, @isauto_v3mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 3

    SELECT @max_v5apositiontaking_1 = apositiontaking, @v5mpositiontaking_1 = mpositiontaking, @auto_v5mpositiontaking_1 = autompositiontaking, @isauto_v5mpositiontaking_1 = isautompositiontaking, @minMinBetv5 = MinBet, @maxMaxBetv5 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 5
    SELECT @max_v5apositiontaking_2 = apositiontaking, @v5mpositiontaking_2 = mpositiontaking, @auto_v5mpositiontaking_2 = autompositiontaking, @isauto_v5mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 5
    SELECT @max_v5apositiontaking_3 = apositiontaking, @v5mpositiontaking_3 = mpositiontaking, @auto_v5mpositiontaking_3 = autompositiontaking, @isauto_v5mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 5
    SELECT @max_v5apositiontaking_20 = apositiontaking, @v5mpositiontaking_20 = mpositiontaking, @auto_v5mpositiontaking_20 = autompositiontaking, @isauto_v5mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 5
    SELECT @max_v5apositiontaking_9999 = apositiontaking, @v5mpositiontaking_9999 = mpositiontaking, @auto_v5mpositiontaking_9999 = autompositiontaking, @isauto_v5mpositiontaking_9999 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9999 AND sporttype = 5

    SELECT @max_v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @auto_v8mpositiontaking_1 = autompositiontaking, @isauto_v8mpositiontaking_1 = isautompositiontaking, @minMinBetv8 = MinBet, @maxMaxBetv8 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=8
    SELECT @max_v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @auto_v8mpositiontaking_3 = autompositiontaking, @isauto_v8mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=8
    SELECT @max_v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @auto_v8mpositiontaking_20 = autompositiontaking, @isauto_v8mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=8

    SELECT @max_v10apositiontaking_1 = apositiontaking, @v10mpositiontaking_1 = mpositiontaking, @auto_v10mpositiontaking_1 = autompositiontaking, @isauto_v10mpositiontaking_1 = isautompositiontaking, @minMinBetv10 = MinBet, @maxMaxBetv10 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 10
    SELECT @max_v10apositiontaking_2 = apositiontaking, @v10mpositiontaking_2 = mpositiontaking, @auto_v10mpositiontaking_2 = autompositiontaking, @isauto_v10mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype = 10
    SELECT @max_v10apositiontaking_3 = apositiontaking, @v10mpositiontaking_3 = mpositiontaking, @auto_v10mpositiontaking_3 = autompositiontaking, @isauto_v10mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype = 10
    SELECT @max_v10apositiontaking_20 = apositiontaking, @v10mpositiontaking_20 = mpositiontaking, @auto_v10mpositiontaking_20 = autompositiontaking, @isauto_v10mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 10

    SELECT @max_v11apositiontaking_1 = apositiontaking, @v11mpositiontaking_1 = mpositiontaking, @auto_v11mpositiontaking_1 = autompositiontaking, @isauto_v11mpositiontaking_1 = isautompositiontaking, @minMinBetv11 = MinBet, @maxMaxBetv11 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype = 11
    SELECT @max_v11apositiontaking_20 = apositiontaking, @v11mpositiontaking_20 = mpositiontaking, @auto_v11mpositiontaking_20 = autompositiontaking, @isauto_v11mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype = 11


    SELECT @max_v99apositiontaking_1 = apositiontaking, @v99mpositiontaking_1 = mpositiontaking, @auto_v99mpositiontaking_1 = autompositiontaking, @isauto_v99mpositiontaking_1 = isautompositiontaking, @minMinBetv99 = MinBet, @maxMaxBetv99 = MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1 AND sporttype=99
    SELECT @max_v99apositiontaking_2 = apositiontaking, @v99mpositiontaking_2 = mpositiontaking, @auto_v99mpositiontaking_2 = autompositiontaking, @isauto_v99mpositiontaking_2 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype=99
    SELECT @max_v99apositiontaking_3 = apositiontaking, @v99mpositiontaking_3 = mpositiontaking, @auto_v99mpositiontaking_3 = autompositiontaking, @isauto_v99mpositiontaking_3 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=99
    SELECT @max_v99apositiontaking_9 = apositiontaking, @v99mpositiontaking_9 = mpositiontaking, @auto_v99mpositiontaking_9 = autompositiontaking, @isauto_v99mpositiontaking_9 = isautompositiontaking,@minMinBetv99MP=MinBet, @maxMaxBetv99MP=MaxBet  FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=9 AND sporttype=99
    SELECT @max_v99apositiontaking_20 = apositiontaking, @v99mpositiontaking_20 = mpositiontaking, @auto_v99mpositiontaking_20 = autompositiontaking, @isauto_v99mpositiontaking_20 = isautompositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @recommend AND bettype=20 AND sporttype=99

    --v161
    SELECT @max_v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @auto_v161mpositiontaking_81 = autompositiontaking,  @isauto_v161mpositiontaking_81 = isautompositiontaking, @minMinBetv161 = MinBet, @maxMaxBetv161 = MaxBet, @discountnumber = discount FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=81 AND sporttype = 161
    SELECT @max_v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=83 AND sporttype = 161
    SELECT @max_v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=88 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=85 AND sporttype = 161
    SELECT @max_v161apositiontaking_86 = apositiontaking, @max_v161alivepositiontaking_86 = alivepositiontaking, @v161mpositiontaking_86 = mpositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=86 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=87 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=89 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=90 AND sporttype = 161


    --v201
    --SELECT @v201mpositiontaking_2 = mpositiontaking, @auto_v201mpositiontaking_2 = autompositiontaking, @isauto_v201mpositiontaking_2 = isautompositiontaking  FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype=2 AND sporttype=201
    --SELECT @v201mpositiontaking_3 = mpositiontaking, @auto_v201mpositiontaking_3 = autompositiontaking, @isauto_v201mpositiontaking_3 = isautompositiontaking, @v201discount = discount FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 3 AND sporttype=201

	--v255
    SELECT @v255apositiontaking_1701 = apositiontaking, @v255mpositiontaking_1701 = mpositiontaking, @auto_v255mpositiontaking_1701 = autompositiontaking, @isauto_v255mpositiontaking_1701 = isautompositiontaking , @v255discount_1701 = discount FROM CustSettingGame WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1701 AND sporttype = 255

    --v180
    --SELECT @v180apositiontaking_1201 = apositiontaking, @v180mpositiontaking_1201 = mpositiontaking, @auto_v180mpositiontaking_1201 = autompositiontaking, @isauto_v180mpositiontaking_1201 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1201 AND sporttype = 180
    --SELECT @v181apositiontaking_1231 = apositiontaking, @v181mpositiontaking_1231 = mpositiontaking, @auto_v181mpositiontaking_1231 = autompositiontaking, @isauto_v181mpositiontaking_1231 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1231 AND sporttype = 181
    --SELECT @v182apositiontaking_1231 = apositiontaking, @v182mpositiontaking_1231 = mpositiontaking, @auto_v182mpositiontaking_1231 = autompositiontaking, @isauto_v182mpositiontaking_1231 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1231 AND sporttype = 182
    --SELECT @v183apositiontaking_1231 = apositiontaking, @v183mpositiontaking_1231 = mpositiontaking, @auto_v183mpositiontaking_1231 = autompositiontaking, @isauto_v183mpositiontaking_1231 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1231 AND sporttype = 183
    --SELECT @v184apositiontaking_1231 = apositiontaking, @v184mpositiontaking_1231 = mpositiontaking, @auto_v184mpositiontaking_1231 = autompositiontaking, @isauto_v184mpositiontaking_1231 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1231 AND sporttype = 184
    --SELECT @v185apositiontaking_1231 = apositiontaking, @v185mpositiontaking_1231 = mpositiontaking, @auto_v185mpositiontaking_1231 = autompositiontaking, @isauto_v185mpositiontaking_1231 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1231 AND sporttype = 185
    --SELECT @v186apositiontaking_1220 = apositiontaking, @v186mpositiontaking_1220 = mpositiontaking, @auto_v186mpositiontaking_1220 = autompositiontaking, @isauto_v186mpositiontaking_1220 = isautompositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1220 AND sporttype = 186

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
    --SELECT @v2spositiontaking_9 = spositiontaking, @max_v2mpositiontaking_9 = mpositiontaking, @auto_v2spositiontaking_9 = autopositiontaking, @isauto_v2spositiontaking_9 = isautopositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=2
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

    --161
    SELECT @v161spositiontaking_81 = spositiontaking, @max_v161mpositiontaking_81 = mpositiontaking,@auto_v161spositiontaking_81 = autopositiontaking, @isauto_v161spositiontaking_81 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=81 AND sporttype = 161
    SELECT @v161spositiontaking_83 = spositiontaking, @max_v161mpositiontaking_83 = mpositiontaking,@auto_v161spositiontaking_83 = autopositiontaking, @isauto_v161spositiontaking_83 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=83 AND sporttype = 161
    SELECT @v161spositiontaking_88 = spositiontaking, @max_v161mpositiontaking_88 = mpositiontaking,@auto_v161spositiontaking_88 = autopositiontaking, @isauto_v161spositiontaking_88 = isautopositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=88 AND sporttype = 161
    SELECT @v161slivepositiontaking_85 = slivepositiontaking , @max_v161mlivepositiontaking_85 =mlivepositiontaking  ,@auto_v161slivepositiontaking_85 =autolivepositiontaking, @isauto_v161slivepositiontaking_85 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=85 AND sporttype = 161
    SELECT @v161spositiontaking_86 = spositiontaking, @v161slivepositiontaking_86 = slivepositiontaking , @max_v161mpositiontaking_86 = mpositiontaking,@max_v161mlivepositiontaking_86 =mlivepositiontaking  , @auto_v161spositiontaking_86 = autopositiontaking, @auto_v161slivepositiontaking_86 =autolivepositiontaking, @isauto_v161spositiontaking_86 = isautopositiontaking,@isauto_v161slivepositiontaking_86 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=86 AND sporttype = 161
    SELECT @v161slivepositiontaking_87 = slivepositiontaking , @max_v161mlivepositiontaking_87 =mlivepositiontaking , @auto_v161slivepositiontaking_87 =autolivepositiontaking, @isauto_v161slivepositiontaking_87 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=87 AND sporttype = 161
    SELECT @v161slivepositiontaking_89 = slivepositiontaking , @max_v161mlivepositiontaking_89 =mlivepositiontaking , @auto_v161slivepositiontaking_89 =autolivepositiontaking, @isauto_v161slivepositiontaking_89 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=89 AND sporttype = 161
    SELECT @v161slivepositiontaking_90 = slivepositiontaking , @max_v161mlivepositiontaking_90 =mlivepositiontaking , @auto_v161slivepositiontaking_90 =autolivepositiontaking, @isauto_v161slivepositiontaking_90 = isautolivepositiontaking   FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=90 AND sporttype = 161


    --v201
    --SELECT @v201spositiontaking_2 = spositiontaking, @max_v201mpositiontaking_2 = mpositiontaking, @auto_v201spositiontaking_2 = autopositiontaking, @isauto_v201spositiontaking_2 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=201
    --SELECT @v201spositiontaking_3 = spositiontaking, @max_v201mpositiontaking_3 = mpositiontaking, @auto_v201spositiontaking_3 = autopositiontaking, @isauto_v201spositiontaking_3 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype=201

	--v255
    SELECT @v255spositiontaking_1701 = spositiontaking, @max_v255mpositiontaking_1701 = mpositiontaking, @auto_v255spositiontaking_1701 = autopositiontaking, @isauto_v255spositiontaking_1701 = isautopositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1701 AND sporttype = 255

    --v180
    --SELECT @v180spositiontaking_1201 = spositiontaking, @max_v180mpositiontaking_1201 = mpositiontaking, @auto_v180spositiontaking_1201 = autopositiontaking, @isauto_v180spositiontaking_1201 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1201 AND sporttype = 180
    --SELECT @v181spositiontaking_1231 = spositiontaking, @max_v181mpositiontaking_1231 = mpositiontaking, @auto_v181spositiontaking_1231 = autopositiontaking, @isauto_v181spositiontaking_1231 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1231 AND sporttype = 181
    --SELECT @v182spositiontaking_1231 = spositiontaking, @max_v182mpositiontaking_1231 = mpositiontaking, @auto_v182spositiontaking_1231 = autopositiontaking, @isauto_v182spositiontaking_1231 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1231 AND sporttype = 182
    --SELECT @v183spositiontaking_1231 = spositiontaking, @max_v183mpositiontaking_1231 = mpositiontaking, @auto_v183spositiontaking_1231 = autopositiontaking, @isauto_v183spositiontaking_1231 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1231 AND sporttype = 183
    --SELECT @v184spositiontaking_1231 = spositiontaking, @max_v184mpositiontaking_1231 = mpositiontaking, @auto_v184spositiontaking_1231 = autopositiontaking, @isauto_v184spositiontaking_1231 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1231 AND sporttype = 184
    --SELECT @v185spositiontaking_1231 = spositiontaking, @max_v185mpositiontaking_1231 = mpositiontaking, @auto_v185spositiontaking_1231 = autopositiontaking, @isauto_v185spositiontaking_1231 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1231 AND sporttype = 185
    --SELECT @v186spositiontaking_1220 = spositiontaking, @max_v186mpositiontaking_1220 = mpositiontaking, @auto_v186spositiontaking_1220 = autopositiontaking, @isauto_v186spositiontaking_1220 = isautopositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1220 AND sporttype = 186

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
    --SELECT @max_v2spositiontaking_9 = spositiontaking FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=2
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

 
    --v161
    SELECT @max_v161apositiontaking_81 = CASE WHEN @max_v161apositiontaking_81 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_81 END,@max_v161mpositiontaking_81 = CASE WHEN @max_v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_81 END, @v161mpositiontaking_81 = CASE WHEN @v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_81 END, @max_v161spositiontaking_81 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=81 AND sporttype = 161
    SELECT @max_v161apositiontaking_83 = CASE WHEN @max_v161apositiontaking_83 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_83 END,@max_v161mpositiontaking_83 = CASE WHEN @max_v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_83 END,@v161mpositiontaking_83 = CASE WHEN @v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_83 END,@max_v161spositiontaking_83 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=83 AND sporttype = 161
    SELECT @max_v161apositiontaking_88 = CASE WHEN @max_v161apositiontaking_88 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_88 END,@max_v161mpositiontaking_88 = CASE WHEN @max_v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_88 END,@v161mpositiontaking_88 = CASE WHEN @v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_88 END,@max_v161spositiontaking_88 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=88 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_85 = CASE WHEN @max_v161alivepositiontaking_85 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_85 END,@max_v161mlivepositiontaking_85 = CASE WHEN @max_v161mlivepositiontaking_85 < mlivepositiontaking THEN @max_v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @v161mlivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85 < mlivepositiontaking THEN @v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_85 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=85 AND sporttype = 161
    SELECT @max_v161apositiontaking_86 = CASE WHEN @max_v161apositiontaking_86 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_86 END,@max_v161mpositiontaking_86 = CASE WHEN @max_v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_86 END,@v161mpositiontaking_86 = CASE WHEN @v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_86 END,@max_v161spositiontaking_86 = spositiontaking, @max_v161alivepositiontaking_86 = CASE WHEN @max_v161alivepositiontaking_86 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_86 END, @max_v161mlivepositiontaking_86 = CASE WHEN @max_v161mlivepositiontaking_86 < mlivepositiontaking THEN @max_v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @v161mlivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86 < mlivepositiontaking THEN @v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_86 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=86 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_87 = CASE WHEN @max_v161alivepositiontaking_87 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_87 END,@max_v161mlivepositiontaking_87 = CASE WHEN @max_v161mlivepositiontaking_87 < mlivepositiontaking THEN @max_v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@v161mlivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87 < mlivepositiontaking THEN @v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_87 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=87 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_89 = CASE WHEN @max_v161alivepositiontaking_89 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_89 END,@max_v161mlivepositiontaking_89 = CASE WHEN @max_v161mlivepositiontaking_89 < mlivepositiontaking THEN @max_v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@v161mlivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89 < mlivepositiontaking THEN @v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_89 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=89 AND sporttype = 161
    SELECT @max_v161alivepositiontaking_90 = CASE WHEN @max_v161alivepositiontaking_90 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_90 END,@max_v161mlivepositiontaking_90 = CASE WHEN @max_v161mlivepositiontaking_90 < mlivepositiontaking THEN @max_v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@v161mlivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90 < mlivepositiontaking THEN @v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_90 = slivepositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=90 AND sporttype = 161


    --v201
    --SELECT @max_v201spositiontaking_2 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=201
    --SELECT @max_v201spositiontaking_3 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype=201

	--v255
    SELECT @max_v255spositiontaking_1701 = spositiontaking FROM CustSettingGame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1701 AND sporttype = 255

    --v180
    --SELECT @max_v180spositiontaking_1201 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1201 AND sporttype = 180
    --SELECT @max_v181spositiontaking_1231 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1231 AND sporttype = 181
    --SELECT @max_v182spositiontaking_1231 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1231 AND sporttype = 182
    --SELECT @max_v183spositiontaking_1231 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1231 AND sporttype = 183
    --SELECT @max_v184spositiontaking_1231 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1231 AND sporttype = 184
    --SELECT @max_v185spositiontaking_1231 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1231 AND sporttype = 185
    --SELECT @max_v186spositiontaking_1220 = spositiontaking FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1220 AND sporttype = 186

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
    SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Max: '+ CAST((max_apositiontaking) AS VARCHAR(10))
    + CASE WHEN b.sporttype in (1,161) AND b.bettype in (1,3,7,8,85,86,87,89,90) THEN '-MaxLive: '+ CAST((max_alivepositiontaking) AS VARCHAR(10)) ELSE '' END + '<br>'
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
    --	UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @v2apositiontaking_7 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_7 AS max_apositiontaking,  0 AS max_alivepositiontaking
    --	UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @v2apositiontaking_8 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_8 AS max_apositiontaking,  0 AS max_alivepositiontaking
    --	UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @v2apositiontaking_9 AS apositiontaking, 0 AS alivepositiontaking, @max_v2apositiontaking_9 AS max_apositiontaking,  0 AS max_alivepositiontaking
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
    --SELECT @v2mpositiontaking_9 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_9, 0) = 0 THEN @v2mpositiontaking_9 ELSE CASE WHEN @auto_v2mpositiontaking_9 < @max_v2mpositiontaking_9 - @v2apositiontaking_9 THEN @auto_v2mpositiontaking_9 ELSE @max_v2mpositiontaking_9 - @v2apositiontaking_9 END END
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
	
    --v201
    --SELECT @v201mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v201mpositiontaking_2, 0) = 0 THEN @v201mpositiontaking_2 ELSE CASE WHEN @auto_v201mpositiontaking_2 < @max_v201mpositiontaking_2 THEN @auto_v201mpositiontaking_2 ELSE @max_v201mpositiontaking_2 END END
    --SELECT @v201mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v201mpositiontaking_3, 0) = 0 THEN @v201mpositiontaking_3 ELSE CASE WHEN @auto_v201mpositiontaking_3 < @max_v201mpositiontaking_3 THEN @auto_v201mpositiontaking_3 ELSE @max_v201mpositiontaking_3 END END

	--v255
    SELECT @v255mpositiontaking_1701 = CASE WHEN ISNULL(@isauto_v255mpositiontaking_1701, 0) = 0 THEN @v255mpositiontaking_1701 ELSE CASE WHEN @auto_v255mpositiontaking_1701 < @max_v255mpositiontaking_1701 THEN @auto_v255mpositiontaking_1701 ELSE @max_v255mpositiontaking_1701 END END

    --v180
    --SELECT @v180mpositiontaking_1201 = CASE WHEN ISNULL(@isauto_v180mpositiontaking_1201, 0) = 0 THEN @v180mpositiontaking_1201 ELSE CASE WHEN @auto_v180mpositiontaking_1201 < @max_v180mpositiontaking_1201 THEN @auto_v180mpositiontaking_1201 ELSE @max_v180mpositiontaking_1201 END END
    --SELECT @v181mpositiontaking_1231 = CASE WHEN ISNULL(@isauto_v181mpositiontaking_1231, 0) = 0 THEN @v181mpositiontaking_1231 ELSE CASE WHEN @auto_v181mpositiontaking_1231 < @max_v181mpositiontaking_1231 THEN @auto_v181mpositiontaking_1231 ELSE @max_v181mpositiontaking_1231 END END
    --SELECT @v182mpositiontaking_1231 = CASE WHEN ISNULL(@isauto_v182mpositiontaking_1231, 0) = 0 THEN @v182mpositiontaking_1231 ELSE CASE WHEN @auto_v182mpositiontaking_1231 < @max_v182mpositiontaking_1231 THEN @auto_v182mpositiontaking_1231 ELSE @max_v182mpositiontaking_1231 END END
    --SELECT @v183mpositiontaking_1231 = CASE WHEN ISNULL(@isauto_v183mpositiontaking_1231, 0) = 0 THEN @v183mpositiontaking_1231 ELSE CASE WHEN @auto_v183mpositiontaking_1231 < @max_v183mpositiontaking_1231 THEN @auto_v183mpositiontaking_1231 ELSE @max_v183mpositiontaking_1231 END END
    --SELECT @v184mpositiontaking_1231 = CASE WHEN ISNULL(@isauto_v184mpositiontaking_1231, 0) = 0 THEN @v184mpositiontaking_1231 ELSE CASE WHEN @auto_v184mpositiontaking_1231 < @max_v184mpositiontaking_1231 THEN @auto_v184mpositiontaking_1231 ELSE @max_v184mpositiontaking_1231 END END
    --SELECT @v185mpositiontaking_1231 = CASE WHEN ISNULL(@isauto_v185mpositiontaking_1231, 0) = 0 THEN @v185mpositiontaking_1231 ELSE CASE WHEN @auto_v185mpositiontaking_1231 < @max_v185mpositiontaking_1231 THEN @auto_v185mpositiontaking_1231 ELSE @max_v185mpositiontaking_1231 END END
    --SELECT @v186mpositiontaking_1220 = CASE WHEN ISNULL(@isauto_v186mpositiontaking_1220, 0) = 0 THEN @v186mpositiontaking_1220 ELSE CASE WHEN @auto_v186mpositiontaking_1220 < @max_v186mpositiontaking_1220 THEN @auto_v186mpositiontaking_1220 ELSE @max_v186mpositiontaking_1220 END END

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
    --SELECT @v2spositiontaking_9 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9, 0) = 0 THEN @v2spositiontaking_9 ELSE CASE WHEN @auto_v2spositiontaking_9 < @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 THEN @auto_v2spositiontaking_9 ELSE @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 END END
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

    ---------------------

    --v201
    --SELECT @v201spositiontaking_2 = CASE WHEN ISNULL(@isauto_v201spositiontaking_2, 0) = 0 THEN @v201spositiontaking_2 ELSE CASE WHEN @auto_v201spositiontaking_2 < @max_v201spositiontaking_2 - @v201mpositiontaking_2 THEN @auto_v201spositiontaking_2 ELSE @max_v201spositiontaking_2 - @v201mpositiontaking_2 END END
    --SELECT @v201spositiontaking_3 = CASE WHEN ISNULL(@isauto_v201spositiontaking_3, 0) = 0 THEN @v201spositiontaking_3 ELSE CASE WHEN @auto_v201spositiontaking_3 < @max_v201spositiontaking_3 - @v201mpositiontaking_3 THEN @auto_v201spositiontaking_3 ELSE @max_v201spositiontaking_3 - @v201mpositiontaking_3 END END
    ---------------------
    
	--v255
    SELECT @v255spositiontaking_1701 = CASE WHEN ISNULL(@isauto_v255spositiontaking_1701, 0) = 0 THEN @v255spositiontaking_1701 ELSE CASE WHEN @auto_v255spositiontaking_1701 < @max_v255spositiontaking_1701 - @v255mpositiontaking_1701 THEN @auto_v255spositiontaking_1701 ELSE @max_v255spositiontaking_1701 - @v255mpositiontaking_1701 END END

    --v180
    --SELECT @v180spositiontaking_1201 = CASE WHEN ISNULL(@isauto_v180spositiontaking_1201, 0) = 0 THEN @v180spositiontaking_1201 ELSE CASE WHEN @auto_v180spositiontaking_1201 < @max_v180spositiontaking_1201 - @v180mpositiontaking_1201 THEN @auto_v180spositiontaking_1201 ELSE @max_v180spositiontaking_1201 - @v180mpositiontaking_1201 END END
    --SELECT @v181spositiontaking_1231 = CASE WHEN ISNULL(@isauto_v181spositiontaking_1231, 0) = 0 THEN @v181spositiontaking_1231 ELSE CASE WHEN @auto_v181spositiontaking_1231 < @max_v181spositiontaking_1231 - @v181mpositiontaking_1231 THEN @auto_v181spositiontaking_1231 ELSE @max_v181spositiontaking_1231 - @v181mpositiontaking_1231 END END
    --SELECT @v182spositiontaking_1231 = CASE WHEN ISNULL(@isauto_v182spositiontaking_1231, 0) = 0 THEN @v182spositiontaking_1231 ELSE CASE WHEN @auto_v182spositiontaking_1231 < @max_v182spositiontaking_1231 - @v182mpositiontaking_1231 THEN @auto_v182spositiontaking_1231 ELSE @max_v182spositiontaking_1231 - @v182mpositiontaking_1231 END END
    --SELECT @v183spositiontaking_1231 = CASE WHEN ISNULL(@isauto_v183spositiontaking_1231, 0) = 0 THEN @v183spositiontaking_1231 ELSE CASE WHEN @auto_v183spositiontaking_1231 < @max_v183spositiontaking_1231 - @v183mpositiontaking_1231 THEN @auto_v183spositiontaking_1231 ELSE @max_v183spositiontaking_1231 - @v183mpositiontaking_1231 END END
    --SELECT @v184spositiontaking_1231 = CASE WHEN ISNULL(@isauto_v184spositiontaking_1231, 0) = 0 THEN @v184spositiontaking_1231 ELSE CASE WHEN @auto_v184spositiontaking_1231 < @max_v184spositiontaking_1231 - @v184mpositiontaking_1231 THEN @auto_v184spositiontaking_1231 ELSE @max_v184spositiontaking_1231 - @v184mpositiontaking_1231 END END
    --SELECT @v185spositiontaking_1231 = CASE WHEN ISNULL(@isauto_v185spositiontaking_1231, 0) = 0 THEN @v185spositiontaking_1231 ELSE CASE WHEN @auto_v185spositiontaking_1231 < @max_v185spositiontaking_1231 - @v185mpositiontaking_1231 THEN @auto_v185spositiontaking_1231 ELSE @max_v185spositiontaking_1231 - @v185mpositiontaking_1231 END END
    --SELECT @v186spositiontaking_1220 = CASE WHEN ISNULL(@isauto_v186spositiontaking_1220, 0) = 0 THEN @v186spositiontaking_1220 ELSE CASE WHEN @auto_v186spositiontaking_1220 < @max_v186spositiontaking_1220 - @v186mpositiontaking_1220 THEN @auto_v186spositiontaking_1220 ELSE @max_v186spositiontaking_1220 - @v186mpositiontaking_1220 END END

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

    --v161 adiscount
    SELECT @adiscountnumber = adiscount FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 81 AND sporttype =161

    ----v201
    --SELECT @v201adiscount = adiscount 
    --FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 3 AND sporttype=201

	--v255
    SELECT @v255adiscount_1701 = adiscount
    FROM CustSettingGame WITH(NOLOCK) WHERE custid = @mrecommend AND bettype = 1701 AND sporttype = 255

    SELECT @sdiscount =  CASE WHEN @ugroup in ('a','hka','dea') THEN groupa WHEN @ugroup in ('b','hkb','deb') THEN groupb WHEN @ugroup in ('c','hkc','dec') THEN groupc ELSE groupd END
    FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1 AND sporttype = 1
    SELECT @sdiscountcs =  sdiscount FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 4 AND sporttype = 1

    --1x2 
    SELECT @sdiscount1x2 =  sdiscount FROM custsetting WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 5 AND sporttype = 1    

    --v161 sdiscount
    SELECT @sdiscountnumber =  sdiscount FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype=81 AND sporttype = 161

    --v201
    --SELECT @v201sdiscount = sdiscount 
    --FROM CustSetting3rd WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 3 AND sporttype=201

	--v255
    SELECT @v255sdiscount_1701 = sdiscount
    FROM custsettinggame WITH(NOLOCK) WHERE custid = @srecommend AND bettype = 1701 AND sporttype = 255
    --SELECT 
    --	@discount = CASE WHEN @discount>@maxdiscount THEN @maxdiscount ELSE @discount END,
    --	@discountcs = CASE WHEN @discountcs>@maxdiscountcs THEN @maxdiscountcs ELSE @discountcs 

    -- NOTE : agent discount  get value FROM custsetting which Master set to them
    -- 	change code to get value direct to @discount , @discountcs  instead of pass to @maxdiscount , @maxdiscountcs

    --SELECT 
    --	@playerdiscount = CASE WHEN @playerdiscount>@discount THEN @discount ELSE @playerdiscount END,
    --	@playerdiscountcs = CASE WHEN @playerdiscountcs>@discountcs THEN @discountcs ELSE @playerdiscountcs END


    --Check valid commission
    --Commission for Sportsbook
    SELECT @adiscount = CASE WHEN @adiscount > @sdiscount THEN @sdiscount ELSE @adiscount END
    SELECT @discount = CASE WHEN @discount > @adiscount THEN @adiscount ELSE @discount END

    SELECT @adiscountcs = CASE WHEN @adiscountcs > @sdiscountcs THEN @sdiscountcs ELSE @adiscountcs END
    SELECT @discountcs = CASE WHEN @discountcs > @adiscountcs THEN @adiscountcs ELSE @discountcs END

    --Commission 1x2 
    SELECT @adiscount1x2 = CASE WHEN @adiscount1x2 > @sdiscount1x2 THEN @sdiscount1x2 ELSE @adiscount1x2 END
    SELECT @discount1x2 = CASE WHEN @discount1x2 > @adiscount1x2 THEN @adiscount1x2 ELSE @discount1x2 END

    --Commission for FI
    --SELECT @v201adiscount = CASE WHEN @v201adiscount > @v201sdiscount THEN @v201sdiscount ELSE @v201adiscount END
    --SELECT @v201discount = CASE WHEN @v201discount > @v201adiscount THEN @v201adiscount ELSE @v201discount END

    --Commission for Number Game
    SELECT @adiscountnumber = CASE WHEN @adiscountnumber > @sdiscountnumber THEN @sdiscountnumber ELSE @adiscountnumber END
    SELECT @discountnumber = CASE WHEN @discountnumber > @adiscountnumber THEN @adiscountnumber ELSE @discountnumber END

	--v255
    SELECT @v255adiscount_1701 = CASE WHEN @v255adiscount_1701 > @v255sdiscount_1701 THEN @v255sdiscount_1701 ELSE @v255adiscount_1701 END
    SELECT @v255discount_1701 = CASE WHEN @v255discount_1701 > @v255adiscount_1701 THEN @v255adiscount_1701 ELSE @v255discount_1701 END
    select
	    @playerdiscount = CASE WHEN @playerdiscount > @discount THEN @discount ELSE @playerdiscount END,
	    @playerdiscountcs = CASE WHEN @playerdiscountcs > @discountcs THEN @discountcs ELSE @playerdiscountcs END,
	    --1x2
	    @playerdiscount1x2 = CASE WHEN @playerdiscount1x2 > @discount1x2 THEN @discount1x2 ELSE @playerdiscount1x2 END,   

	    --v161
	    @playerdiscountnumber = CASE WHEN @playerdiscountnumber > @discountnumber THEN @discountnumber ELSE @playerdiscountnumber END

    --End check valid commission
    	

    SELECT @Credit_AllOtherMember = ISNULL(sum(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1
    SELECT @MaxCredit_Mem = CASE WHEN @MaxCredit_Mem =0 THEN (@AgentCredit - @Credit_AllOtherMember) 
						    ELSE @MaxCredit_Mem END 
    IF @Credit + @Credit_AllOtherMember>@AgentCredit
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Sorry, credit increase unsuccessful. You have exceeded your agent credit.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](70003,@Language)
						    END	
			    ,@success = 0, @ErrCode = 204
	    return
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Sorry, increase credit unsuccessfully, You have exceeded the member max credit.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](70009,@Language)
						    END	
			    ,@success = 0, @ErrCode =217
	    return
    END 
    /*
    SELECT @MaxPerMatch_AllOtherMember = ISNULL(sum(MaxPerMatch), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1

    IF @MaxPerMatch + @MaxPerMatch_AllOtherMember>@AgentMaxPerMatch
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							    WHEN 'CS' THEN N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							    WHEN 'J' THEN N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							    ELSE N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
						    END	
			    ,@success = 0, @ErrCode = 104
	    RaisError(@ErrMsg, 16, 1)
	    return
    END

    SELECT @MaxPerMatchv2_AllOtherMember = ISNULL(sum(MaxPerMatchb), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1

    IF @MaxPerMatchv2 + @MaxPerMatchv2_AllOtherMember>@AgentMaxPerMatchb
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							    WHEN 'CS' THEN N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							    WHEN 'J' THEN N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							    ELSE N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
						    END	
			    ,@success = 0, @ErrCode = 104
	    RaisError(@ErrMsg, 16, 1)
	    return
    END
    */
    SET ANSI_WARNINGS OFF
    SELECT 
	    @MinMinBet = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBet = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype = 1
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv2 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv2 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype=2
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv3 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv3 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype = 3
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv5 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv5 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype = 5
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv8 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv8 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype=8
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv10 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv10 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype = 10
    WHERE ci.custid = @Recommend

    SELECT 
	    @MinMinBetv11 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv11 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype = 11
    WHERE ci.custid = @Recommend

    --v151
    --SELECT 
    --	@MinMinBetv151 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
    --	@MaxMaxBetv151 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
    --	custsetting AS cs WITH(NOLOCK)
    --	INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 31 AND cs.sporttype = 151
    --where ci.custid = @Recommend

    SELECT 
	    @MinMinBetv99 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv99 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1 AND cs.sporttype=99
    WHERE ci.custid = @Recommend

    --Mix Parlay Mixed Sports
    SELECT 
	    @MinMinBetv99MP = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv99MP = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    custsetting AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 9 AND cs.sporttype=99
    WHERE ci.custid = @Recommend

    --v161
    SELECT 
	    @MinMinBetv161 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	    @MaxMaxBetv161 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    FROM 
	    CustSetting3rd AS cs WITH(NOLOCK)
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 81 AND cs.sporttype = 161
    WHERE ci.custid = @Recommend

    ----VS
    ---- Virtual Scoccer
    --SELECT 
	   -- @MinMinBetv180 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv180 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1201 AND cs.sporttype = 180
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv180 = ISNULL(MinBet, 0), @maxbetv180 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1201 AND sporttype = 180

    --IF @MinMinBetv180>0 AND @minbetv180>0 AND @minbetv180<@MinMinBetv180
	   -- SET @minbetv180 = @MinMinBetv180
    	
    --IF @MaxMaxBetv180>0 AND @maxbetv180>0 AND @maxbetv180>@MaxMaxBetv180
	   -- SET @maxbetv180 = @MaxMaxBetv180

    ----Virtual horse racing
    --SELECT 
	   -- @MinMinBetv181 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv181 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1231 AND cs.sporttype = 181
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv181 = ISNULL(MinBet, 0), @maxbetv181 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1231 AND sporttype = 181

    --IF @MinMinBetv181>0 AND @minbetv181>0 AND @minbetv181<@MinMinBetv181
	   -- SET @minbetv181 = @MinMinBetv181
    	
    --IF @MaxMaxBetv181>0 AND @maxbetv181>0 AND @maxbetv181>@MaxMaxBetv181
	   -- SET @maxbetv181 = @MaxMaxBetv181

    ---- Virtual Greyhounds
    --SELECT 
	   -- @MinMinBetv182 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv182 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1231 AND cs.sporttype = 182
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv182 = ISNULL(MinBet, 0), @maxbetv182 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1231 AND sporttype = 182

    --IF @MinMinBetv182>0 AND @minbetv182>0 AND @minbetv182<@MinMinBetv182
	   -- SET @minbetv182 = @MinMinBetv182
    	
    --IF @MaxMaxBetv182>0 AND @maxbetv182>0 AND @maxbetv182>@MaxMaxBetv182
	   -- SET @maxbetv182 = @MaxMaxBetv182


    ---- Virtual Speedway 183
    --SELECT 
	   -- @MinMinBetv183 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv183 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1231 AND cs.sporttype = 183
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv183 = ISNULL(MinBet, 0), @maxbetv183 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1231 AND sporttype = 183

    --IF @MinMinBetv183>0 AND @minbetv183>0 AND @minbetv183<@MinMinBetv183
	   -- SET @minbetv183 = @MinMinBetv183
    	
    --IF @MaxMaxBetv183>0 AND @maxbetv183>0 AND @maxbetv183>@MaxMaxBetv183
	   -- SET @maxbetv183 = @MaxMaxBetv183

    ---- Virtual Cycling 185
    --SELECT 
	   -- @MinMinBetv185 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv185 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1231 AND cs.sporttype = 185
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv185 = ISNULL(MinBet, 0), @maxbetv185 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1231 AND sporttype = 185

    --IF @MinMinBetv185>0 AND @minbetv185>0 AND @minbetv185<@MinMinBetv185
	   -- SET @minbetv185 = @MinMinBetv185
    	
    --IF @MaxMaxBetv185>0 AND @maxbetv185>0 AND @maxbetv185>@MaxMaxBetv185
	   -- SET @maxbetv185 = @MaxMaxBetv185

	   -- --Virtual Motor Racing
    --SELECT 
	   -- @MinMinBetv184 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv184 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1231 AND cs.sporttype = 184
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv184 = ISNULL(MinBet, 0), @maxbetv184 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1231 AND sporttype = 184

    --IF @MinMinBetv184>0 AND @minbetv184>0 AND @minbetv184<@MinMinBetv184
	   -- SET @minbetv184 = @MinMinBetv184 
    	
    --IF @MaxMaxBetv184>0 AND @maxbetv184>0 AND @maxbetv184>@MaxMaxBetv184
	   -- SET @maxbetv184 = @MaxMaxBetv184
    	
    ---- Virtual Tennis
    --SELECT 
	   -- @MinMinBetv186 = ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0), 
	   -- @MaxMaxBetv186 = ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0)
    --FROM 
	   -- custsetting3rd AS cs WITH(NOLOCK)
	   -- INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend) AND cs.bettype = 1220 AND cs.sporttype = 186
    --WHERE ci.custid = @Recommend

    --SELECT @minbetv186 = ISNULL(MinBet, 0), @maxbetv186 = ISNULL(MaxBet, 0) 
    --FROM custsetting3rd WITH(NOLOCK) 
    --WHERE custid = @Recommend AND bettype= 1220 AND sporttype = 186

    --IF @MinMinBetv186>0 AND @minbetv186>0 AND @minbetv186<@MinMinBetv186
	   -- SET @minbetv186 = @MinMinBetv186
    	
    --IF @MaxMaxBetv186>0 AND @maxbetv186>0 AND @maxbetv186>@MaxMaxBetv186
	   -- SET @maxbetv186 = @MaxMaxBetv186

    Select	
	    @MaxMaxperMatch = ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0), 
	    @MaxMaxPerMatchv2 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch2 = 0 THEN NULL ELSE cs.MaxPerMatch2 END),0),
	    @MaxMaxPerMatchv3 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch3 = 0 THEN NULL ELSE cs.MaxPerMatch3 END),0),
	    @MaxMaxPerMatchv5 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch5 = 0 THEN NULL ELSE cs.MaxPerMatch5 END),0),
	    @MaxMaxPerMatchv8 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch8 = 0 THEN NULL ELSE cs.MaxPerMatch8 END),0),
	    @MaxMaxPerMatchv10 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch10 = 0 THEN NULL ELSE cs.MaxPerMatch10 END),0),
	    @MaxMaxPerMatchv11 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch11 = 0 THEN NULL ELSE cs.MaxPerMatch11 END),0),
	    @MaxMaxPerMatchv99 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch99 = 0 THEN NULL ELSE cs.MaxPerMatch99 END),0),
	    @MaxMaxPerMatchv99MP = ISNULL(MIN(CASE WHEN cs.MaxPerMatch99MP = 0 THEN NULL ELSE cs.MaxPerMatch99MP END),0),
	    
	    @MaxMaxPerMatchv1MP = ISNULL(MIN(CASE WHEN cs.MaxPerMatch1MP = 0 THEN NULL ELSE cs.MaxPerMatch1MP END),0),	    
	  
	    @MaxMaxPerMatchv161 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch161 = 0 THEN NULL ELSE cs.MaxPerMatch161 END),0),
	    @MaxMaxPerBallv161 = ISNULL(MIN(CASE WHEN cs.MaxPerBall161 = 0 THEN null ELSE cs.MaxPerBall161 END),0)
	    --@MaxMaxPerMatchv180 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch180 = 0 THEN NULL ELSE cs.MaxPerMatch180 END),0),
	    --@MaxMaxPerMatchv181 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch181 = 0 THEN NULL ELSE cs.MaxPerMatch181 END),0),
	    --@MaxMaxPerMatchv182 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch182 = 0 THEN NULL ELSE cs.MaxPerMatch182 END),0),
	    --@MaxMaxPerMatchv183 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch183 = 0 THEN NULL ELSE cs.MaxPerMatch183 END),0),
	    --@MaxMaxPerMatchv184 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch184 = 0 THEN NULL ELSE cs.MaxPerMatch184 END),0),
	    --@MaxMaxPerMatchv185 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch185 = 0 THEN NULL ELSE cs.MaxPerMatch185 END),0),
	    --@MaxMaxPerMatchv186 = ISNULL(MIN(CASE WHEN cs.MaxPerMatch186 = 0 THEN NULL ELSE cs.MaxPerMatch186 END),0)
    FROM 
	    custinfo AS cs WITH(NOLOCK) 
	    INNER JOIN custinfo AS ci WITH(NOLOCK) on (cs.CustID = ci.CustID OR cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend)
    WHERE ci.custid = @Recommend
    SET ANSI_WARNINGS ON

    ---- Virtual Scoccer
    --IF @MaxMaxPerMatchv180>0 AND @MaxPerMatchv180>0 AND @MaxPerMatchv180>@MaxMaxPerMatchv180
	   -- SET @MaxPerMatchv180 = @MaxMaxPerMatchv180
    	
    --IF (@minbetv180<>0 AND @maxbetv180 <> 0 AND  @minbetv180>@maxbetv180) 
	   -- OR (@maxbetv180<> 0 AND @MaxPerMatchv180 <> 0 AND @maxbetv180>@MaxPerMatchv180) 
	   -- OR (@minbetv180 <> 0 AND @MaxPerMatchv180 <> 0 AND @minbetv180>@MaxPerMatchv180)	
    --BEGIN
	   -- SELECT @minbetv180=0, @maxbetv180 = 0, @MaxPerMatchv180 = 0 
    --END	
    ---- Virtual horse racing
    --IF @MaxMaxPerMatchv181>0 AND @MaxPerMatchv181>0 AND @MaxPerMatchv181>@MaxMaxPerMatchv181
	   -- SET @MaxPerMatchv181 = @MaxMaxPerMatchv181
    	
    --IF (@minbetv181<>0 AND @maxbetv181 <> 0 AND  @minbetv181>@maxbetv181) 
	   -- OR (@maxbetv181<> 0 AND @MaxPerMatchv181 <> 0 AND @maxbetv181>@MaxPerMatchv181) 
	   -- OR (@minbetv181 <> 0 AND @MaxPerMatchv181 <> 0 AND @minbetv181>@MaxPerMatchv181)	
    --BEGIN
	   -- SELECT @minbetv181=0, @maxbetv181 = 0, @MaxPerMatchv181 = 0 
    --END	
    ---- Virtual Tennis
    --IF @MaxMaxPerMatchv186>0 AND @MaxPerMatchv186>0 AND @MaxPerMatchv186>@MaxMaxPerMatchv186
	   -- SET @MaxPerMatchv186 = @MaxMaxPerMatchv186
    	
    --IF (@minbetv186<>0 AND @maxbetv186 <> 0 AND  @minbetv186>@maxbetv186) 
	   -- OR (@maxbetv186<> 0 AND @MaxPerMatchv186 <> 0 AND @maxbetv186>@MaxPerMatchv186) 
	   -- OR (@minbetv186 <> 0 AND @MaxPerMatchv186 <> 0 AND @minbetv186>@MaxPerMatchv186)
    --BEGIN
	   -- SELECT @minbetv186=0, @maxbetv186 = 0, @MaxPerMatchv186 = 0 
    --END	
    ---- Virtual Greyhounds
    --IF @MaxMaxPerMatchv182>0 AND @MaxPerMatchv182>0 AND @MaxPerMatchv182>@MaxMaxPerMatchv182
	   -- SET @MaxPerMatchv182 = @MaxMaxPerMatchv182
    	
    --IF (@minbetv182<>0 AND @maxbetv182 <> 0 AND  @minbetv182>@maxbetv182) 
	   -- OR (@maxbetv182<> 0 AND @MaxPerMatchv182 <> 0 AND @maxbetv182>@MaxPerMatchv182) 
	   -- OR (@minbetv182 <> 0 AND @MaxPerMatchv182 <> 0 AND @minbetv182>@MaxPerMatchv182)	
    --BEGIN
	   -- SELECT @minbetv182=0, @maxbetv182 = 0, @MaxPerMatchv182 = 0 
    --END	

    ---- Virtual Speedway 183
    --IF @MaxMaxPerMatchv183>0 AND @MaxPerMatchv183>0 AND @MaxPerMatchv183>@MaxMaxPerMatchv183
	   -- SET @MaxPerMatchv183 = @MaxMaxPerMatchv183
    	
    --IF (@minbetv183<>0 AND @maxbetv183 <> 0 AND  @minbetv183>@maxbetv183) 
	   -- OR (@maxbetv183<> 0 AND @MaxPerMatchv183 <> 0 AND @maxbetv183>@MaxPerMatchv183) 
	   -- OR (@minbetv183 <> 0 AND @MaxPerMatchv183 <> 0 AND @minbetv183>@MaxPerMatchv183)	
    --BEGIN
	   -- SELECT @minbetv183=0, @maxbetv183 = 0, @MaxPerMatchv183 = 0 
    --END	

    ---- Virtual Motor Racing
    --IF @MaxMaxPerMatchv184>0 AND @MaxPerMatchv184>0 AND @MaxPerMatchv184>@MaxMaxPerMatchv184
	   -- SET @MaxPerMatchv184 = @MaxMaxPerMatchv184
    	
    --IF (@minbetv184<>0 AND @maxbetv184 <> 0 AND  @minbetv184>@maxbetv184) 
	   -- OR (@maxbetv184<> 0 AND @MaxPerMatchv184 <> 0 AND @maxbetv184>@MaxPerMatchv184) 
	   -- OR (@minbetv184 <> 0 AND @MaxPerMatchv184 <> 0 AND @minbetv184>@MaxPerMatchv184)	
    --BEGIN
	   -- SELECT @minbetv184=0, @maxbetv184 = 0, @MaxPerMatchv184 = 0 
    --END	

    ---- Virtual Cycling 185
    --IF @MaxMaxPerMatchv185>0 AND @MaxPerMatchv185>0 AND @MaxPerMatchv185>@MaxMaxPerMatchv185
	   -- SET @MaxPerMatchv185 = @MaxMaxPerMatchv185
    	
    --IF (@minbetv185<>0 AND @maxbetv185 <> 0 AND  @minbetv185>@maxbetv185) 
	   -- OR (@maxbetv185<> 0 AND @MaxPerMatchv185 <> 0 AND @maxbetv185>@MaxPerMatchv185) 
	   -- OR (@minbetv185 <> 0 AND @MaxPerMatchv185 <> 0 AND @minbetv185>@MaxPerMatchv185)	
    --BEGIN
	   -- SELECT @minbetv185=0, @maxbetv185 = 0, @MaxPerMatchv185 = 0 
    --END	

    --Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR IF invalid copy FROM upline
    --IF ((@minbetv151 < @MinMinBetv151 OR @maxbetv151 > @MaxMaxBetv151 OR @MaxPerMatchv151 > @MaxMaxPerMatchv151) 
    --	and not (@minbetv151 = 0 AND @maxbetv151 = 0 AND @MaxPerMatchv151 = 0))
    --	SELECT @minbetv151 = @MinMinBetv151,
    --			@maxbetv151 = @MaxMaxBetv151,
    --			@MaxPerMatchv151 = @MaxMaxPerMatchv151
    --End Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR IF invalid copy FROM upline

    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + (CASE WHEN MP=0 THEN sports.name ELSE 'Mixed Sports' END )   + ', '
    FROM #tmp_Sports sports inner join
    (
				    SELECT 1 AS sporttype,0 AS MP, @MinBet AS MinBet, @MinMinBet AS MinMinBet
	    UNION ALL	SELECT 2 AS sporttype,0 AS MP, @MinBetv2 AS MinBet, @MinMinBetv2 AS MinMinBet
	    UNION ALL	SELECT 3 AS sporttype,0 AS MP, @MinBetv3 AS MinBet, @MinMinBetv3 AS MinMinBet
	    UNION ALL	SELECT 5 AS sporttype,0 AS MP, @MinBetv5 AS MinBet, @MinMinBetv5 AS MinMinBet
	    UNION ALL	SELECT 8 AS sporttype,0 AS MP, @MinBetv8 AS MinBet, @MinMinBetv8 AS MinMinBet
	    UNION ALL	SELECT 10 AS sporttype,0 AS MP, @MinBetv10 AS MinBet, @MinMinBetv10 AS MinMinBet

	    UNION ALL	SELECT 11 AS sporttype,0 AS MP, @MinBetv11 AS MinBet, @MinMinBetv11 AS MinMinBet
	    UNION ALL	SELECT 99 AS sporttype,0 AS MP, @MinBetv99 AS MinBet, @MinMinBetv99 AS MinMinBet	 
	    UNION ALL	SELECT 99 AS sporttype,1 AS MP, @MinBetv99MP AS MinBet, @MinMinBetv99MP AS MinMinBet	   
	    UNION ALL	SELECT 161 AS sporttype,0 AS MP, @MinBetv161 AS MinBet, @MinMinBetv161 AS MinMinBet	
    ) AS b on sports.ID = b.sporttype
    WHERE MinMinBet>0 AND MinBet>0 AND MinBet<MinMinBet
    IF @ErrType <>''
    BEGIN
	    SELECT
		    @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Min bet must be equal to OR greater than Super/Master/Agent min bet ('+@ErrType+').'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](10012,@Language) + ' ('+@ErrType+').'
					    END										
	    SELECT @ErrCode = 205
	    return
    END

    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + (CASE WHEN MP=0 THEN sports.name ELSE 'Mixed Sports' END )   + ', '
    FROM #tmp_Sports sports inner join
    (
				    SELECT 1 AS sporttype,0 AS MP, @MaxBet AS MaxBet, @MaxMaxBet AS MaxMaxBet
	    UNION ALL	SELECT 2 AS sporttype,0 AS MP, @MaxBetv2 AS MaxBet, @MaxMaxBetv2 AS MaxMaxBet
	    UNION ALL	SELECT 3 AS sporttype,0 AS MP, @MaxBetv3 AS MaxBet, @MaxMaxBetv3 AS MaxMaxBet
	    UNION ALL	SELECT 5 AS sporttype,0 AS MP, @MaxBetv5 AS MaxBet, @MaxMaxBetv5 AS MaxMaxBet
	    UNION ALL	SELECT 8 AS sporttype,0 AS MP, @MaxBetv8 AS MaxBet, @MaxMaxBetv8 AS MaxMaxBet
	    UNION ALL	SELECT 10 AS sporttype,0 AS MP, @MaxBetv10 AS MaxBet, @MaxMaxBetv10 AS MaxMaxBet
	    UNION ALL	SELECT 11 AS sporttype,0 AS MP, @MaxBetv11 AS MaxBet, @MaxMaxBetv11 AS MaxMaxBet
	    UNION ALL	SELECT 99 AS sporttype,0 AS MP, @MaxBetv99 AS MaxBet, @MaxMaxBetv99 AS MaxMaxBet	 
	    UNION ALL	SELECT 99 AS sporttype,1 AS MP, @MaxBetv99MP AS MaxBet, @MaxMaxBetv99MP AS MaxMaxBet	 	    
	    UNION ALL	SELECT 161 AS sporttype,0 AS MP, @MaxBetv161 AS MaxBet, @MaxMaxBetv161 AS MaxMaxBet	 
    	
    ) AS b on sports.ID = b.sporttype
    WHERE MaxMaxBet>0 AND MaxBet>0 AND MaxBet>MaxMaxBet
    IF @ErrType <>''
    BEGIN
	    SELECT
		    @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Max bet must be equal to OR less than Master/Agent max bet ('+@ErrType+').'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](10013,@Language) + ' ('+@ErrType+').'
					    END										
	    SELECT @ErrCode = 107
	    return
    END

    SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + (CASE WHEN MP=0 THEN sports.name ELSE 'Mixed Sports' END )   + ', '
    FROM #tmp_Sports sports inner join
    (
				    SELECT 1 AS sporttype,0 AS MP, @MaxPerMatch AS MaxPerMatch, @MaxMaxPerMatch AS MaxMaxPerMatch
	    UNION ALL	SELECT 2 AS sporttype,0 AS MP, @MaxPerMatchv2 AS MaxPerMatch, @MaxMaxPerMatchv2 AS MaxMaxPerMatch
	    UNION ALL	SELECT 3 AS sporttype,0 AS MP, @MaxPerMatchv3 AS MaxPerMatch, @MaxMaxPerMatchv3 AS MaxMaxPerMatch
	    UNION ALL	SELECT 5 AS sporttype,0 AS MP, @MaxPerMatchv5 AS MaxPerMatch, @MaxMaxPerMatchv5 AS MaxMaxPerMatch
	    UNION ALL	SELECT 8 AS sporttype,0 AS MP, @MaxPerMatchv8 AS MaxPerMatch, @MaxMaxPerMatchv8 AS MaxMaxPerMatch
	    UNION ALL	SELECT 10 AS sporttype,0 AS MP, @MaxPerMatchv10 AS MaxPerMatch, @MaxMaxPerMatchv10 AS MaxMaxPerMatch
	    UNION ALL	SELECT 11 AS sporttype,0 AS MP, @MaxPerMatchv11 AS MaxPerMatch, @MaxMaxPerMatchv11 AS MaxMaxPerMatch
	    UNION ALL	SELECT 99 AS sporttype,0 AS MP, @MaxPerMatchv99 AS MaxPerMatch, @MaxMaxPerMatchv99 AS MaxMaxPerMatch	 
	    UNION ALL	SELECT 99 AS sporttype,1 AS MP, @MaxPerMatchv99MP AS MaxPerMatch, @MaxMaxPerMatchv99MP AS MaxMaxPerMatch	 
	    
	    UNION ALL	SELECT 1 AS sporttype,1 AS MP, @MaxPerMatchv1MP AS MaxPerMatch, @MaxMaxPerMatchv1MP AS MaxMaxPerMatch	 
	   
	    UNION ALL	SELECT 161 AS sporttype,0 AS MP, @MaxPerMatchv161 AS MaxPerMatch, @MaxMaxPerMatchv161 AS MaxMaxPerMatch
    ) AS b on sports.ID = b.sporttype
    WHERE MaxMaxPerMatch>0 AND MaxPerMatch>0 AND MaxPerMatch>MaxMaxPerMatch
    IF @ErrType <>''
    BEGIN
	    SELECT
		    @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Max Per Match must be equal to OR less than Master/Agent Max Per Match ('+@ErrType+').'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](10014,@Language) + ' ('+@ErrType+').'
					    END										
	    SELECT @ErrCode = 107
	    return
    END

    SELECT @ErrType = ''
    IF @MaxPerBallv161 > 0 AND @MaxMaxPerBallv161 > 0 AND @MaxPerBallv161 > @MaxMaxPerBallv161
    BEGIN
	    SELECT @ErrType = @ErrType + sports.name 
	    FROM #tmp_Sports sports
	    WHERE ID = 161
    	
	    SELECT @ErrMsg= CASE @Language
						    WHEN 'E' THEN 'Max Per Ball must equal to OR less than Agent Max Per Ball ('+@ErrType+').'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](10009,@Language) + ' ('+@ErrType+').'
				    END
	    SELECT @ErrCode = 107
	    RETURN
    END

    SELECT @pwdexpiry = DATEADD(dd, 30, GETDATE())

    IF @UplineClosed = 1 SELECT @Closed = 1 

    --check suspended of Agent 
    IF @Asuspended =1 AND @suspendedFlag IS NULL
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
	    @suspended = @suspended,
	    @closed = @closed,
    	
	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,

	    @Danger = @AgentDanger,
	    @Danger2 = @AgentDanger2,
	    @Danger3 = @AgentDanger3,
	    @Abnormal = @AgentAbnormal,
    	
	  
	    @DisableOutright = @DisableOutright,	
	    @matchlimit = @matchlimit,
	    @virtualmultiplier = @virtualmultiplier,
	   
	    @DisableCasino = @DisableCasino,
		@DisableNumber = @DisableNumber,	 
	 
	    --@Disable180_1201 = @Disable180_1201,
	    --@HideVirtualSports = @HideVirtualSports,
	    @DoubleCommLosing = 0,-- off double comm losing WHEN create new member
	    @DisableCasinoBonus = @DisableCasinoBonus,	    	 
	  
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
	    --@MaxPerMatchv180 = @MaxPerMatchv180,
	    --@MaxPerMatchv181 = @MaxPerMatchv181,
	    --@MaxPerMatchv182 = @MaxPerMatchv182,
	    --@MaxPerMatchv183 = @MaxPerMatchv183,
	    --@MaxPerMatchv184 = @MaxPerMatchv184,
	    --@MaxPerMatchv185 = @MaxPerMatchv185,
	    --@MaxPerMatchv186 = @MaxPerMatchv186,
	    --Keno
	    @HideKeno = @HideKeno,
		@DisableGoldDeluxe = @DisableGoldDeluxe,
		@HideGoldDeluxe = @HideGoldDeluxe,
		
		@DisableColossusBet = @DisableColossusBet,
		@HideColossusBet = @HideColossusBet,
		
		@DisableSuperLive = @DisableSuperLive,

	    --E-Sports
	    @DisableEsports = @DisableEsports,
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

	--insert default value from upline
	EXEC dbo.Acc_CustomerWinLimitIns @CustId = @custid
		, @UplineId = @recommend
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
    	
    --set comm of sportbook = 0 if agent of member exist in table CustNoComm
    IF EXISTS(SELECT 1 FROM CustNoComm WHERE custID = @recommend)
    BEGIN
	    SELECT @playerdiscount = 0,	@discount = 0, @adiscount = 0, @sdiscount = 0,
		    @playerdiscount1x2 = 0, @discount1x2 = 0, @adiscount1x2 = 0, @sdiscount1x2 = 0,		   
		    @playerdiscountcs = 0, @discountcs = 0, @adiscountcs = 0, @sdiscountcs = 0,
					
		    --@v201discount = 0, @v201adiscount = 0, @v201sdiscount = 0, 
		    @discountnumber = 0, @adiscountnumber = 0, @sdiscountnumber = 0,		  
			@v255discount_1701 = 0 , @v255adiscount_1701 = 0, @v255sdiscount_1701 = 0
    END
  
        EXEC dbo.Acc_CustomerInfo_Execrep_00
	    @custid = @custid,
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = @recommend,
	    @roleid = 1,--create member
    	
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
	    --@v2spositiontaking_9 = @v2spositiontaking_9,
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
	
	    --v161
	    @v161spositiontaking_81 = @v161spositiontaking_81,
	    @v161spositiontaking_83 = @v161spositiontaking_83,
	    --@v161spositiontaking_85 = @v161spositiontaking_85,
	    @v161spositiontaking_86 = @v161spositiontaking_86,
	    @v161spositiontaking_88 = @v161spositiontaking_88,
	    @v161slivepositiontaking_85 = @v161slivepositiontaking_85,
	    @v161slivepositiontaking_86 = @v161slivepositiontaking_86,
	    @v161slivepositiontaking_87 = @v161slivepositiontaking_87,	
	    @v161slivepositiontaking_89 = @v161slivepositiontaking_89,
	    @v161slivepositiontaking_90 = @v161slivepositiontaking_90,
    		
	    --v201
	    --@v201spositiontaking_2 = @v201spositiontaking_2,
	    --@v201spositiontaking_3 = @v201spositiontaking_3,  
			
		--v255
	    @v255spositiontaking_1701 = @v255spositiontaking_1701,
    	
	    --v180
	    --@v180spositiontaking_1201 = @v180spositiontaking_1201,
	    --@v181spositiontaking_1231 = @v181spositiontaking_1231,
	    --@v182spositiontaking_1231 = @v182spositiontaking_1231,
	    --@v183spositiontaking_1231 = @v183spositiontaking_1231,
	    --@v184spositiontaking_1231 = @v184spositiontaking_1231,
	    --@v185spositiontaking_1231 = @v185spositiontaking_1231,
	    --@v186spositiontaking_1220 = @v186spositiontaking_1220,
    	
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
	    --@v2mpositiontaking_9 = @v2mpositiontaking_9,
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
    	
	    --v161
	    @v161mpositiontaking_81 = @v161mpositiontaking_81,
	    @v161mpositiontaking_83 = @v161mpositiontaking_83,
	    --@v161mpositiontaking_85 = @v161mpositiontaking_85,
	    @v161mpositiontaking_86 = @v161mpositiontaking_86,
	    @v161mpositiontaking_88 = @v161mpositiontaking_88,
	    @v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
	    @v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
	    @v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
	    @v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
	    @v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,
    		
	    --v201
	    --@v201mpositiontaking_2 = @v201mpositiontaking_2,
	    --@v201mpositiontaking_3 = @v201mpositiontaking_3,
		    
    	--v255
	    @v255mpositiontaking_1701 = @v255mpositiontaking_1701,

	    --v180
	    --@v180mpositiontaking_1201 = @v180mpositiontaking_1201,
	    --@v181mpositiontaking_1231 = @v181mpositiontaking_1231,
	    --@v182mpositiontaking_1231 = @v182mpositiontaking_1231,
	    --@v183mpositiontaking_1231 = @v183mpositiontaking_1231,
	    --@v184mpositiontaking_1231 = @v184mpositiontaking_1231,
	    --@v185mpositiontaking_1231 = @v185mpositiontaking_1231,
	    --@v186mpositiontaking_1220 = @v186mpositiontaking_1220,
    	
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
	    --@v2apositiontaking_9 = @v2apositiontaking_9,
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
	   
	    --v161
	    @v161apositiontaking_81 = @v161apositiontaking_81,
	    @v161apositiontaking_83 = @v161apositiontaking_83,
	    --@v161apositiontaking_85 = @v161apositiontaking_85,
	    @v161apositiontaking_86 = @v161apositiontaking_86,
	    @v161apositiontaking_88 = @v161apositiontaking_88,
	    @v161alivepositiontaking_85 = @v161alivepositiontaking_85,
	    @v161alivepositiontaking_86 = @v161alivepositiontaking_86,
	    @v161alivepositiontaking_87 = @v161alivepositiontaking_87,
	    @v161alivepositiontaking_89 = @v161alivepositiontaking_89,
	    @v161alivepositiontaking_90 = @v161alivepositiontaking_90,
 
    	--v255
	    @v255apositiontaking_1701 = @v255apositiontaking_1701,

	    --v180
	    --@v180apositiontaking_1201 = @v180apositiontaking_1201,
	    --@v181apositiontaking_1231 = @v181apositiontaking_1231,
	    --@v182apositiontaking_1231 = @v182apositiontaking_1231,
	    --@v183apositiontaking_1231 = @v183apositiontaking_1231,
	    --@v184apositiontaking_1231 = @v184apositiontaking_1231,
	    --@v185apositiontaking_1231 = @v185apositiontaking_1231,
	    --@v186apositiontaking_1220 = @v186apositiontaking_1220,
    	
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
	    @discountnumber = @discountnumber,
    	
	    @playerdiscount = @playerdiscount, 
	    @playerdiscountcs = @playerdiscountcs,
	    --1x2 
	    @playerdiscount1x2 = @playerdiscount1x2,	
    	
	    @playerdiscountnumber = @playerdiscountnumber,
	    
    	@IsMyanmarOdds = @IsMyanmarOdds,
    	@discountMyanmarOdds = @playerdiscountMyanmarOdds,    	
    		
	    @adiscount = @adiscount,
	    @adiscountcs = @adiscountcs,
	    @adiscount1x2 = @adiscount1x2,
	    @adiscountnumber = @adiscountnumber,
    	
	    @sdiscount = @sdiscount,		
	    @sdiscountcs = @sdiscountcs,	
	    @sdiscount1x2 = @sdiscount1x2,	
	    @sdiscountnumber = @sdiscountnumber,
    	
	    ----v201
	    --@v201discount = @v201discount,
	    --@v201adiscount = @v201adiscount,
	    --@v201sdiscount = @v201sdiscount,    	
	  
    	--v255
	    @v255discount_1701  = @v255discount_1701,
	    @v255adiscount_1701 = @v255adiscount_1701,
	    @v255sdiscount_1701 = @v255sdiscount_1701,

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
	    
	    --Mix Parlay soccer sports
	    @MinBetv1MP = @MinBetv1MP,
	    @MaxBetv1MP = @MaxBetv1MP,		
	 
	    --Number game
	    @MinBetv161 = @MinBetv161,
	    @MaxBetv161 = @MaxBetv161,
    	
	    --@minbetv180 = @minbetv180,
	    --@maxbetv180 = @maxbetv180,
	    --@minbetv181 = @minbetv181,
	    --@maxbetv181 = @maxbetv181,
	    --@minbetv182 = @minbetv182,
	    --@maxbetv182 = @maxbetv182,
	    --@minbetv183 = @minbetv183,
	    --@maxbetv183 = @maxbetv183,
	    --@minbetv184 = @minbetv184,
	    --@maxbetv184 = @maxbetv184,
	    --@minbetv185 = @minbetv185,
	    --@maxbetv185 = @maxbetv185,
	    --@minbetv186 = @minbetv186,
	    --@maxbetv186 = @maxbetv186,

	    @ErrCode = @ErrCode OUTPUT

    IF @ErrCode > 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Create customer fail. Please try again'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					    END	
    				
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

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

		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    /*--Virtual soccer
    --EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 180, @bettype = 1201, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 180,
	    @bettype = 1201
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
    	DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual horse racing

    --EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 181, @bettype = 1231, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 181,
	    @bettype = 1231
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual Greyhounds


        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 182,
	    @bettype = 1231
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	  
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual Speedway


        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 183,
	    @bettype = 1231
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual Cycling


        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 185,
	    @bettype = 1231
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid	   
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual Motor Racing


        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 184,
	    @bettype = 1231
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	 
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual tennis
    --EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 186, @bettype = 1220, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
        EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'Virtual-sports',
	    @sporttype = 186,
	    @bettype = 1220
    	
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	  
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END
	*/ 

		EXEC dbo.Acc_CustomerInfo_Execrep_01
	    @custid = @custid, 
	    @srecommend = @srecommend, 
	    @mrecommend = @mrecommend, 
	    @recommend = @recommend,
	    @mode = 'GoldDeluxe',
		@sporttype = 255,
		@bettype = 1701
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language  WHEN 'E' THEN 'Create member fail. Please try again' ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language) END, @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	    DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	    DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	    DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID	

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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID
    	
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END
    --EXEC Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @srecommend = @srecommend , @mrecommend = @mrecommend , @recommend = @recommend
    		
    --print @v2mpositiontaking_20
    /*
    INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], MinBet, MaxBet, autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking)
    SELECT @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1,@spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    --1x2
    UNION ALL
    SELECT @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, @playerdiscount1x2, @discount1x2, @adiscount1x2, @sdiscount1x2, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0

    UNION ALL
    SELECT @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    --UNION ALL
    --SELECT @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0

    UNION ALL
    SELECT @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0

    UNION ALL
    SELECT @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0

    UNION ALL
    SELECT @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0

    UNION ALL
    SELECT @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0

    UNION ALL

    SELECT @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0


    UNION ALL
    SELECT @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 9, 99, @v99apositiontaking_9, ISNULL(@v99mpositiontaking_9,0), ISNULL(@v99spositiontaking_9,0), 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99MP, @MaxBetv99MP, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
  
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=215
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid

		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END



    --inser INTo CustSetting3rd
    INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], MinBet, MaxBet, autopositiontaking, isautopositiontaking, alivepositiontaking,mlivepositiontaking,slivepositiontaking,autolivepositiontaking,isautolivepositiontaking)
    SELECT @custid, 2, 201, 0, @v201mpositiontaking_2, @v201spositiontaking_2, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0
    UNION ALL
    SELECT @custid, 3, 201, 0, @v201mpositiontaking_3, @v201spositiontaking_3, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0   

    --v161
    UNION ALL
    SELECT @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, @v161spositiontaking_81, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
    UNION ALL
    SELECT @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, @v161spositiontaking_83, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
    UNION ALL
    SELECT @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, @v161spositiontaking_88, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
    UNION ALL
    SELECT @custid, 85, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_85,@v161mlivepositiontaking_85,@v161slivepositiontaking_85,0,0
    UNION ALL
    SELECT @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, @v161spositiontaking_86, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_86,@v161mlivepositiontaking_86,@v161slivepositiontaking_86,0,0
    UNION ALL
    SELECT @custid, 87, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_87,@v161mlivepositiontaking_87,@v161slivepositiontaking_87,0,0
    UNION ALL
    SELECT @custid, 89, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_89,@v161mlivepositiontaking_89,@v161slivepositiontaking_89,0,0
    UNION ALL
    SELECT @custid, 90, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_90,@v161mlivepositiontaking_90,@v161slivepositiontaking_90,0,0
    --v180
    UNION ALL
    SELECT @custid, 1201, 180, ISNULL(@v180apositiontaking_1201,0), ISNULL(@v180mpositiontaking_1201,0), ISNULL(@v180spositiontaking_1201,0), 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0,0,0,0,0,0
    UNION ALL
    SELECT @custid, 1231, 181, ISNULL(@v181apositiontaking_1231,0), ISNULL(@v181mpositiontaking_1231,0), ISNULL(@v181spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv181,0), ISNULL(@maxbetv181,0), 0, 0,0,0,0,0,0
    UNION ALL
    SELECT @custid, 1220, 186, ISNULL(@v186apositiontaking_1220,0), ISNULL(@v186mpositiontaking_1220,0), ISNULL(@v186spositiontaking_1220,0), 0, 0, 0, 0, ISNULL(@minbetv186,0), ISNULL(@maxbetv186,0), 0, 0,0,0,0,0,0

    IF @@Error <> 0

    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=215
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid

		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    return
    END

    EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
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
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Racing
    EXEC Acc_CustomerUpdMemberHR_MinMaxPositiontaking @custid = @custid, @srecommend = @srecommend , @mrecommend = @mrecommend , @recommend = @recommend
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=217
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual soccer
    EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 180, @bettype = 1201, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual horse racing
    EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 181, @bettype = 1231, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END

    --Virtual tennis
    EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 186, @bettype = 1220, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
    IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=218
    	
	    -- ROLLBACK MANUALLY
	    Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	    Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
    	
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END  
    
    */


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
		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

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

		DELETE dbo.CustWinLimit WITH(ROWLOCK) WHERE CustID = @CustID

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    return
    END
	
    ------ Create default balance for Live casino for new customer
    --DECLARE @today smalldatetime
    --SET @today = convert(nvarchar(10), current_timestamp,120)

    ----INSERT INTO BalanceCreditGame (CustID, winlostdate, Balance )
    ----VALUES (@CustID, @today, 0)
    ----EXEC DBTXN.bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @CustID, @winlostdate = @today

    --IF @@error <> 0
    --BEGIN
	   -- --Error occurs
	   -- SELECT @ErrMsg = CASE @Language 
				--			    WHEN 'E' THEN 'Create member fail. Please try again'
				--			    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
				--		    END	
			 --   , @success = 0, @ErrCode=219
    	
	   -- -- ROLLBACK MANUALLY
	   -- Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	   -- Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	
	   -- DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	   -- DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid

	   -- EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID --DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid	
	   -- EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID --DELETE BalanceDebit WITH (ROWLOCK) WHERE custid = @custid	
	   -- --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCreditGame @CustID = @CustID --DELETE BalanceCreditGame WITH (ROWLOCK) WHERE custid = @custid

	   -- EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	   -- return
    --END


    ----INSERT INTO BalanceDebitGame (CustID, winlostdate, Balance )
    ----VALUES (@CustID, @today, 0)
    ----EXEC DBTXN.bodb02.dbo.Dot_BalanceInsDebitGame @CustID = @CustID, @winlostdate = @today

    --IF @@error <> 0
    --BEGIN
	   -- --Error occurs
	   -- SELECT @ErrMsg = CASE @Language 
				--			    WHEN 'E' THEN 'Create member fail. Please try again'
				--			    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
				--		    END	
			 --   , @success = 0, @ErrCode=220
    	
	   -- -- ROLLBACK MANUALLY
	   -- Delete custsetting with (ROWLOCK) WHERE custid  =@custid
	   -- Delete CustSetting3rd with (ROWLOCK) WHERE custid  =@custid
	
	   -- DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	   -- DELETE custOverride WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE custOverride3rd WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE custOverrideGame WITH (ROWLOCK) WHERE custId = @custid		
	   -- DELETE CustGameType WITH (ROWLOCK) WHERE custId = @custid

	   -- EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID --DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid	
	   -- EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID --DELETE BalanceDebit WITH (ROWLOCK) WHERE custid = @custid	
	   -- --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCreditGame @CustID = @CustID --DELETE BalanceCreditGame WITH (ROWLOCK) WHERE custid = @custid
	   -- --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebitGame @CustID = @CustID --DELETE BalanceDebitGame WITH (ROWLOCK) WHERE custid = @custid	
    	
	   -- EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	   -- return
    --END
	
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
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)), SPACE(1)) + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 603,
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
	    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)), SPACE(1)) + '" />'

	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 603,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH

    --Log commission
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discount="'+ COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'discountnumber="'+ COALESCE(CAST(@discountnumber AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscount="'+ COALESCE(CAST(@playerdiscount AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscountcs="'+ COALESCE(CAST(@playerdiscountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
    'playerdiscount1x2="'+ COALESCE(CAST(@playerdiscount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +   
    'playerdiscountnumber="'+ COALESCE(CAST(@playerdiscountnumber AS VARCHAR(50)), SPACE(1)) + '" '
    
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
	    'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'discountnumber="'+ COALESCE(CAST(@discountnumber AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscount="'+ COALESCE(CAST(@playerdiscount AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscountcs="'+ COALESCE(CAST(@playerdiscountcs AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'playerdiscount1x2="'+ COALESCE(CAST(@playerdiscount1x2 AS VARCHAR(50)), SPACE(1)) + '" ' +	    
	    'playerdiscountnumber="'+ COALESCE(CAST(@playerdiscountnumber AS VARCHAR(50)), SPACE(1)) + '" ' 
	    
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
    'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +  
    'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    
    'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
    
    'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPBv161="'+ COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)), SPACE(1)) + '" />'

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
	    'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)), SPACE(1)) + '" ' +	   
	    'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    
	    'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)), SPACE(1)) + '" ' +
	    
	    'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPBv161="'+ COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)), SPACE(1)) + '" ' + 
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
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @recommend

	SET @LogDataSP2 = ''
	
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	INTO #temSportbettypeSetting
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13)

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' +  REPLACE(REPLACE(p.ProductName, ' ', ''),'*','') + '="' + COALESCE(CAST(iq.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM DBPRO.bodb02.dbo.Products p WITH (NOLOCK)
		INNER JOIN (SELECT psd.ProductID, MIN(CAST(dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) AS INT)) AS custIsHidden
					FROM ProductSettingDetail psd WITH(NOLOCK)
						INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
																			AND	psd.BetType = psp.Bettype
																			AND psd.SettingType IN (4,11,13)		-- Product Status, Game Status
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
						INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
					WHERE @_Site = 'IMBC' OR psd.ProductID <> 20 --iCricket
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
		WHERE CustID = @custid AND (@_Site = 'IMBC' OR psd.ProductID <> 20)--iCricket
			AND psd.SettingType IN (4,11,13)-- Product Status, Game Status
	)iq

    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@closed AS VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(50)), SPACE(1)) + '" ' +
    'Danger="'+ COALESCE(CAST(@AgentDanger AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger2="'+ COALESCE(CAST(@AgentDanger2 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger3="'+ COALESCE(CAST(@AgentDanger3 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Abnormal="'+ COALESCE(CAST(@AgentAbnormal AS VARCHAR(5)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Special=" " ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@virtualmultiplier AS VARCHAR(10)),SPACE(1)) + '" ' +	   
   
    --'DisableVirtualSports="'+ COALESCE(CAST(@Disable180_1201 AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableCasino="'+ COALESCE(CAST(@DisableCasino AS VARCHAR(1)), SPACE(1)) + '" ' +   
    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
    'DisableNumber="'+ COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno + @LogDataSP2 +

    'DisableEsports="'+ COALESCE(CAST(@DisableEsports AS VARCHAR(1)), SPACE(1)) + '" ' +
	'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)), SPACE(1)) + '" ' +
	'HideColossusBet="'+ COALESCE(CAST(@HideColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DisableColossusBet="'+ COALESCE(CAST(@DisableColossusBet AS VARCHAR(1)), SPACE(1)) + '" ' +
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
	    'Abnormal="'+ COALESCE(CAST(@AgentAbnormal AS VARCHAR(5)), SPACE(1)) + '" ' +
		--20171206@Johnson: add more log for status
		'Special=" " ' +
		'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DoubleCommLosing="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'virtualmultiplier="'+ COALESCE(CAST(@virtualmultiplier AS VARCHAR(10)),SPACE(1)) + '" ' +	    
	  
	    --'DisableVirtualSports="'+ COALESCE(CAST(@Disable180_1201 AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'DisableCasino="'+ COALESCE(CAST(@DisableCasino AS VARCHAR(1)), SPACE(1)) + '" ' +	  
	    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' +
	    'DisableNumber="'+ COALESCE(CAST(@DisableNumber AS VARCHAR(1)), SPACE(1)) + '" ' +	   
	  
	    'DisableEsports="'+ COALESCE(CAST(@DisableEsports AS VARCHAR(1)), SPACE(1)) + '" ' +
		'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)), SPACE(1)) + '" ' +
		'HideColossusBet="'+ COALESCE(CAST(@HideColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DisableColossusBet="'+ COALESCE(CAST(@DisableColossusBet AS VARCHAR(1)), SPACE(1)) + '" ' +
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

    --Write PT log
    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +
    --'v2apt_9="'+ COALESCE(CAST(@v2apositiontaking_9 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +
    
    'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

    'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
    'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)), SPACE(1))  + '" ' +   

    'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)), SPACE(1))  + '" ' +
    'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)), SPACE(1))  + '" />'

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
	    SELECT @LogSPData = '<Acc_CustomerInsMember_Ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    --'v2apt_9="'+ COALESCE(CAST(@v2apositiontaking_9 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    
	    'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)), SPACE(1)) + '" ' +

	    'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)), SPACE(1)) + '" ' +
	    'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)), SPACE(1))  + '" ' +  
	    'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)), SPACE(1))  + '" ' +
	    'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)), SPACE(1))  + '" ' +
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