/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsUserInfo]
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@pwdexpiry DATETIME,
	@currency INT,
	@site NVARCHAR(50),
	@ugroup VARCHAR(5) = NULL,

	@srecommend INT,
	@mrecommend INT,
	@recommend INT,
	@roleid INT,
	
	@Danger TINYINT = 0,
	@Danger2 TINYINT = 0,
	@Danger3 TINYINT = 0,
	@Danger4 TINYINT = 0,
	@Danger5 TINYINT = 0,
	@Abnormal TINYINT = 0,
	
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@email NVARCHAR(50),
	@fax NVARCHAR(50),
	@address NVARCHAR(80),
	@city NVARCHAR(50),
	@state NVARCHAR(50),
	@country NVARCHAR(50),
	@postal NVARCHAR(50),
	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in case direct master add new agent
	--@suspended BIT = NULL,

	@closed BIT = NULL,	
	@DisableOutright BIT = 0,
	@matchlimit SMALLMONEY,
	@virtualmultiplier SMALLMONEY,
	@DisableAutoMPT BIT = 1,
	@IsInternal BIT = 0,
	
	@autosuspend BIT = 0,
	@autosuspend2 BIT = 0,

	@MaxPerMatch MONEY,
	@MaxPerMatchv2 MONEY,
	@MaxPerMatchv3 MONEY,
	@MaxPerMatchv5 MONEY,
	@MaxPerMatchv8 MONEY,
	@MaxPerMatchv10 MONEY,
	@MaxPerMatchv11 MONEY,
	@MaxPerMatchv99 MONEY,
	@MaxPerMatchv99MP MONEY,	
	
	@MaxPerMatchv1MP MONEY = 0,	
	
	@MaxPerMatchv161 MONEY,	
	@MaxPerBallv161 MONEY = 0,	
	@MaxPerMatchv164 MONEY = 0,
	
	@DisableNumber BIT = 0,

	@DisableCasino BIT = 0,

	@DoubleCommLosing BIT = 0,

	@DisableEsports BIT = 0,
	@DisableGoldDeluxe BIT = 0,
	@HideGoldDeluxe BIT = 0,
	
	@DisableSuperLive BIT = 0,

	--Keno
	@HideKeno BIT = 0,	
	
	@credit MONEY,
	@maxcredit MONEY = 0,
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,
	
	@IP VARCHAR(15)='',
	@TransferOption_dec TINYINT,
	@SystemID	TINYINT=1,
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS

/*
Created: 20090121@Phuc
Task :	Insert general customer's Informatioin.
		Table related: customer, custinfo
DB: DBTXN/CustDB
Original:

Revisions:
	- 20090521@PhuongDao: Not to insert maxcredit on custinfo table 
	- 20090703@Phuc: manual rollback
	- 20090901@Shifu: add IsInternal
	- 20091112@Jamie: Add the input param @DisableOutright 
    - 20100413@Kiwi: + Remove to do not insert answer field.
					 + Move transferoption to CustSuper/CustMaster/CustAgent
	- 20100505@Huynguyen: Add param @DisableOpenTote
	- 20100828@Lukas:	- Add setting information (max per match, DisableBingo, DisableNumber) for Number game
						- Add Max per match for Mix Parlay for Mixed Sports
	- 20101029@Johnson: Include max per ball for number game
	- 20101230@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110405@Johnson: Add Danger's setting
	- 20110822@Tom: Add P2P setting
	- 20111222@Johnson: Add live casino setting 
	- 20120718@Dan: add 1 more field "site" in CustAgent table
	- 20120731@Dan: add Virtual soccer
	- 20120823@Elodie: add Abnormal field	
	- 20120926@Dan: add new fields for LCS-win limit
	- 20120928@Johnson: add double comm losing status
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130219@Johnson: Add virtual horse racing setting (sporttype : 181, bettype : 1321)
	- 20130328@Jamie: Add CustLoginInfo 
	- 20130423@Jamie: Set isForcedChangeSecurityCode = 1 WHEN Upline's SecurityCode NOT NULL 
	- 20130731@Elodie: Apply progressive bonus
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Add @autosuspend, @autosuspend2 [Redmine:#5520]
	- 20131120@Johnson: Add virtual greyhounds, virtual motor racing
	- 20140303@Patrick: Add more field HideKeno
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20140709@Logan: Force using Security Code for SMA from all sites (except 789y) [Redmine:#18121]
	- 20140822@Logan: Add Esport status [Redmine: #20531]
	- 20150102@Johnson: Separate virtual rate by sporttype, bettype [Redmine: #25840]				
	- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	- 20150623@Elodie: Set HideGoldDeluxe = 1 for 789y site
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150821@Elodie: Exclude WON currency for GoldDeluxe [Redmine: #41785]
	- 20150909@Elodie: Remove copying Virtual Rate setting from function Search and Copy [Redmine:#42976]                	
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151028@Jim:Implement Muay's Setting for Deposit Customer [Redmine: #45491]
	- 20151029@Billy: Change to new VirtualRate structure [Redmine: #46541]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170207@Elodie: Set HideGoldDeluxe = 0 for 789y site - [Redmine: #69200]
	- 20170420@Helen:  Add Extra information for Direct Accounts, for NAP only - [Redmine:72339]
	- 20170620@Winnie: Apply color for closed account - [RedmineID: 74494]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170920@Helen: TO Control Phase 3 - [Redmine: 75557]
	- 20171113@Helen: Support to add default TO setting for new direct customers - [Redmine:86052]
	- 20180125@Winnie: Hide inactive products, set Disable151_AU=1 on new customer for report part [RedmineID: #86086]
	- 20180621@Razor: Add Message Customer Read Status [Redmind: #94705]
	- 20181002@Elodie: Limit max members creation per Super. [RedmineID: #101994]
	- 20181107@Louis: Credit Collection [Redmine: #98621]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200114@Malcolm: Separate setting and notification into Live/Non-Live and bettypes [Redmine : 125076]
	- 20200120@Max: Support Separate setting and notification into Live/Non-Live major and minor bettypes [Redmine: #126841]
	- 20200210@Elodie: Problem account for credit [Redmine:#127446]	
	- 20200310@Percy: Add column IsAllDayBalTransfer on CustMaster [RedmineID: #130091]
	- 20200311@Elodie: Suspicious account [Redmine:#129119]
	- 20200602@Sol: Check IsAutoEnableADBMaster to enable ADB on Mater or not[Redmine: #134242]
	- 20200722@Johnson: add void time & limit amount for problem account [redmine: #135253]
	- 20201103@Tina: Get site from Agent for member level [redmine: #144323]
	- 20210224@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	
	Param's Explanation:
• @ErrCode:
		= 0: Insert successfully.
		> 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON 
	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME, @IsAllDayBalTransfer BIT, @CreditRM MONEY
			, @IsAutoEnableADBMaster BIT
	
	SET @CreateDate = GETDATE()
	
	IF @currency = 45 --Gold Deluxe doesn't support WON currency [Redmine: #41785]
		SELECT @HideGoldDeluxe = 1, @DisableGoldDeluxe = 1

	IF (@roleid = 1 AND ISNULL(@site,'') = '') --role member and @site does not have value will get site from agent
	BEGIN
		SELECT @site = cus.[site]
		FROM Customer cus WITH (NOLOCK)
		WHERE cus.custid = @recommend
	END
		
    INSERT INTO Customer   			
			    (username, firstname, lastname, phone, mobilephone, fax, email, address,
			    city, state, country, postal, userpwd, roleid, srecommend, mrecommend, recommend, 
			    currency, pwdexpiry, creator, Site, creatdate, ugroup
			    ) 
 		     VALUES (@username, @firstname, @lastname, @phone, @mobilephone, @fax, @email, @address, 
			    @city, @state, @country, @postal, @userpwd, @roleid, @srecommend, @mrecommend, @recommend, 
			    @currency, @pwdexpiry, @creator, @site, GETDATE(), @ugroup
			    )
	
	
    SELECT @custid=@@IDENTITY
	
    IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create customer failed. Please try again.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
						    END,
		    @ErrCode = 111
    		
	    -- ROLLBACK MANUALLY
	    DELETE FROM Customer WITH (ROWLOCK) WHERE custId = @CustID
    		
	    RETURN
    END
	
	EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Ins  @custid, 0, @roleid, @ErrCode, @ErrMsg
	
	IF @ErrCode <>0
	BEGIN
			SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create customer failed. Please try again.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
						    END
				, @ErrCode = 116
		 -- ROLLBACK MANUALLY
			DELETE FROM Customer WITH (ROWLOCK) WHERE custId = @CustID
			
			RETURN
	END
	
    DECLARE	@UplineSecurityCode			 VARCHAR(50)
	      , @isForcedChangeSecurityCode BIT

    SELECT @UplineSecurityCode		 = NULL
	     , @isForcedChangeSecurityCode = 0

    IF @roleid = 4
    BEGIN
        SELECT @isForcedChangeSecurityCode = CASE
                                               WHEN site LIKE '789y%' THEN 0
                                               ELSE 1
                                             END
          FROM Customer WITH(NOLOCK)
         WHERE custid = @custid

	    SET @srecommend = @custid
	    UPDATE Customer WITH(ROWLOCK, UPDLOCK)
	       SET srecommend = @custid
	     WHERE custId = @CustID
		
	    INSERT INTO CustSuper
	    (
	        custId, AutoIBCPositionTaking_Tote,  IsInternal, TransferOption, MaxMember
	    )
	    VALUES
	    (
	        @CustID, 0,  @IsInternal, 
			CASE
				WHEN @TransferOption IS NULL THEN ISNULL(@TransferOption_dec, 0)
				ELSE dbo.F_Binary_Decimal(ISNULL(@TransferOption, 0))
	        END,
			CASE
				WHEN @site = '789y' THEN 20000
				ELSE -1 
	        END
        )
		
			--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT	@Custid, 
				seqNo,
				(
					SELECT TOP 1 bitmap
					FROM dbo.f_GenerateVirtualSetting_multiple(0x00, CONVERT(VARCHAR(MAX), virtualXML))
				) AS bitmapVirtual
		FROM (
			SELECT DISTINCT seqNo
			FROM ProfileVirtualSetting WITH(NOLOCK)
		) pvs
		CROSS APPLY (
			SELECT (
				SELECT	(
							SELECT	ipvs.profileID			AS '@p',
									vr.virtualMultiplier	AS '@v'
							FROM	ProfileVirtualSetting	AS ipvs WITH(NOLOCK)
							CROSS APPLY (
								SELECT CAST(1.00 AS SMALLMONEY) AS virtualMultiplier
							) vr
							WHERE	ipvs.seqNo = pvs.seqNo
							FOR XML PATH ('r'), 
							TYPE
						)
				FOR XML PATH ('root'), 
				TYPE
			) AS virtualXML
		) p	 
    END
    ELSE IF @roleid = 3
    BEGIN
	    SELECT @UplineSecurityCode = SecurityCode,
	           @isForcedChangeSecurityCode = isForcedChangeSecurityCode
	      FROM dbo.CustLoginInfo WITH(NOLOCK)
	     WHERE CustID = @srecommend

		SELECT 
			@IsAllDayBalTransfer = IsAllDayBalTransfer
			, @IsAutoEnableADBMaster = IsAutoEnableADBMaster
		FROM dbo.CustSuper WITH (NOLOCK)
		WHERE CustId = @srecommend

	    SET @mrecommend = @custid 
	    UPDATE Customer WITH (ROWLOCK, UPDLOCK) SET mrecommend = @custid WHERE custId = @CustID

	    INSERT INTO CustMaster(custId, DisableAutoMPT, IsInternal, TransferOption, IsAllDayBalTransfer)
	    VALUES
		(
			@CustID,
			@DisableAutoMPT, 
			@IsInternal, 
			CASE WHEN @TransferOption IS NULL THEN ISNULL(@TransferOption_dec, 0) ELSE dbo.F_Binary_Decimal(ISNULL(@TransferOption, 0)) END, 
			CASE WHEN @IsAutoEnableADBMaster = 1 THEN ISNULL(@IsAllDayBalTransfer, 0) ELSE 0 END
		)
	
		--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @srecommend
    END
    ELSE IF @roleid = 2
    BEGIN

	    SELECT @UplineSecurityCode = SecurityCode,
	           @isForcedChangeSecurityCode = isForcedChangeSecurityCode
	      FROM dbo.CustLoginInfo WITH(NOLOCK)
	     WHERE CustID = @mrecommend

	    SET @recommend = @custid
	    UPDATE Customer WITH (ROWLOCK, UPDLOCK) SET recommend = @custid WHERE custId = @CustID

	    INSERT INTO CustAgent(custId, MaxCredit, IsInternal, TransferOption, Site)
	    VALUES(@CustID, @MaxCredit, @IsInternal, CASE WHEN @TransferOption IS NULL THEN ISNULL(@TransferOption_dec, 0) ELSE dbo.F_Binary_Decimal(ISNULL(@TransferOption, 0)) END, @site)
		
		--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @mrecommend  
    END
	ELSE IF @roleid = 1
	BEGIN		
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @recommend  
	END
    IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 112

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 3
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 2
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END	

	DECLARE @UplineID INT

	SELECT @UplineID = CASE WHEN @roleid = 3 THEN @srecommend 
							WHEN @roleid = 2 THEN @mrecommend
							WHEN @roleid = 1 THEN @recommend
						END

	--VR lock status
	INSERT INTO VRCustLockStatus(CustID,Type)
	SELECT @custid,Type
	FROM VRCustLockStatus v (NOLOCK) 
	WHERE CustID = @UplineID
		AND NOT EXISTS( SELECT 1 FROM VRCustLockStatus(NOLOCK) WHERE CustID = @custid AND type = v.Type)

	IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 112

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 3
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 2
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
		DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END	


	DECLARE @ClosedReason TINYINT 
	IF(@SystemID=1 AND @closed=1)
		SELECT @ClosedReason=1
	ELSE IF(@SystemID<>1 AND @closed=1)
		SELECT @ClosedReason=2
	ELSE 
		SELECT @ClosedReason=0

    IF @roleid BETWEEN 2 AND 4 
    BEGIN
	    IF @UplineSecurityCode IS NOT NULL OR @isForcedChangeSecurityCode = 1
		    SELECT @isForcedChangeSecurityCode = 1

	    INSERT INTO dbo.CustLoginInfo
	    (
	        CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCodeCount,
	        SecurityCode, isForcedChangeSecurityCode, LastChangedSecurityCodeDate,ClosedReason
	    )
	    VALUES
	    (
	        @custid, NULL, GETDATE(), 1, 0,
	        NULL, @isForcedChangeSecurityCode, NULL,@ClosedReason
	    )

	    IF @@ERROR <> 0
	    BEGIN
		    SELECT	@ErrMsg = CASE @Language
								    WHEN 'E' THEN 'Create customer failed. Please try again.'
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							    END
				    ,@ErrCode = 115

		    IF @RoleID = 4
			    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
		    ELSE IF @RoleID = 3
			    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
		    ELSE IF @RoleID = 2
			    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

		    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
			DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
			EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
		    RETURN
	    END
    END

	IF @roleid=1
	BEGIN		
		IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo_Member WITH(NOLOCK) WHERE custid = @custid)
		BEGIN
			INSERT INTO CustLoginInfo_Member([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason)
			VALUES(@custid,NULL,@IP,@creator,GETDATE(),@ClosedReason)
			IF @@ERROR <> 0
			BEGIN
				SELECT	@ErrMsg = CASE @Language
										WHEN 'E' THEN 'Create customer failed. Please try again.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
									END
						,@ErrCode = 115

				IF @RoleID = 4
					DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
				ELSE IF @RoleID = 3
					DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
				ELSE IF @RoleID = 2
					DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

				DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
				DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
				EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
				RETURN
			END
		END
	END

	BEGIN TRY
		INSERT INTO [dbo].[custinfo]
		(
			custid, currency
		  , maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11
		  , maxpermatch99
		  , roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, autosuspend2
		 -- , reject
		  , credit
		  --, closed
		  , username
		  , MatchLimit, VirtualMultiplier
		  , DisableOutright, DisableCasino, DisableNumber, maxpermatch161, MaxPerMatch99MP, MaxPerBall161
		  , danger, danger2, danger3, danger4, danger5, Abnormal
		  ,  DoubleCommLosing
		  , HideKeno, DisableEsports, DisableGoldDeluxe, HideGoldDeluxe, DisableSuperLive
		  , MaxPerMatch1MP,maxpermatch164)
		VALUES
		(
			@custid, @currency--,1
		  , @MaxPerMatch, @MaxPerMatchv2, @MaxPerMatchv3, @MaxPerMatchv5, @MaxPerMatchv8, @MaxPerMatchv10, @MaxPerMatchv11
		  , @MaxPerMatchv99
		  , @roleid, @srecommend, @mrecommend, @recommend, 0, @autosuspend, @autosuspend2
		  --, ISNULL(@suspended, 0)
		  , @credit
		  --, ISNULL(@closed, 0)
		  , @username
		  , @matchlimit, @virtualmultiplier
		  , @DisableOutright, @DisableCasino, @DisableNumber,  @MaxPerMatchv161, @MaxPerMatchv99MP, @MaxPerBallv161
		  , @danger, @danger2, @danger3, @danger4, @danger5, @Abnormal
		  ,  @DoubleCommLosing	
		  , @HideKeno, @DisableEsports, @DisableGoldDeluxe, @HideGoldDeluxe, @DisableSuperLive
		  , @MaxPerMatchv1MP, @maxpermatchv164
		)

		IF @roleid <> 4
		BEGIN
			INSERT INTO dbo.ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember, ActionId, SubIssueTypeId,VoidTime,LimitAmount)
			SELECT @CustId, pa.ProblemStatus, NULL, NULL, NULL, NULL, GETDATE(), 0, 0, pa.ActionId,
				CASE WHEN @roleid = 1 THEN a.SubIssueTypeId ELSE NULL END, 
				pa.VoidTime, 0
			FROM ProblemAccount pa WITH (NOLOCK)	
				INNER JOIN ProblemAccountAction a WITH (NOLOCK) ON a.ActionID = pa.ActionId 		
			WHERE CustId = CASE WHEN @roleid = 3 THEN @srecommend 
								WHEN @roleid = 2 THEN @mrecommend
								WHEN @roleid = 1 THEN @recommend END
		END

		SELECT @CreditRM = @credit * actualrate
		FROM dbo.exchange WITH (NOLOCK) 
		WHERE exchangeid = @currency

		IF @CreditRM > 300000 AND @roleid <> 1
		BEGIN
			INSERT INTO SuspiciousCust (CustID, NotifyStatus1, NotifyStatus2)
			SELECT @CustId, 1, 0
		END
	END TRY
	BEGIN CATCH		
		SELECT @ErrMsg = CASE @Language
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END,
				@ErrCode = 113

		-- ROLLBACK MANUALLY
		IF @RoleID = 4
		BEGIN
			DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID
		END
		ELSE IF @RoleID = 3
		BEGIN
			DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
		END
		ELSE IF @RoleID = 2
		BEGIN
			DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
		END

		DELETE FROM ProblemAccount WITH (ROWLOCK) WHERE CustId = @custid
		DELETE FROM SuspiciousCust WITH (ROWLOCK) WHERE CustId = @custid
		DELETE FROM custInfo WITH (ROWLOCK) WHERE CustId = @custid
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID	
		DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
		RETURN
    END CATCH
	
    -- For Extra Info Direct Account, FOR CREDIT ONLY
    IF NOT EXISTS (SELECT 1 FROM Dep_CustSuper WITH (NOLOCK) WHERE custid = @srecommend)
    BEGIN
		IF @roleid = 1 
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
						
			IF @@ROWCOUNT <> 0
			BEGIN				
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID IN (@srecommend,@mrecommend,@recommend)
				
				DELETE dbo.TOControl_Setting
				WHERE CustID IN (@srecommend,@mrecommend,@recommend)
			END
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN			
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 602,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
				
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID IN (@srecommend,@mrecommend)
				
				DELETE dbo.TOControl_Setting
				WHERE CustID IN (@srecommend,@mrecommend)
					
			END	
				
		END	
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN						
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
				
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
	    
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 601,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
				
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID = @srecommend
				
				DELETE dbo.TOControl_Setting
				WHERE CustID = @srecommend 
					
			END
				
		END
		ELSE IF @roleid = 4
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN			
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
	    
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 600,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
			END
			
		END
		
		IF @@ERROR <> 0
		BEGIN 
		--	DELETE customer with (ROWLOCK) where custid =  @custid
			SELECT @ErrMsg = CASE @Language
							   WHEN 'E' THEN 'Create customer failed. Please try again.'
							   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							 END,
				   @ErrCode = 113

			-- ROLLBACK MANUALLY
			IF @RoleID = 4
			BEGIN
				DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID
				DELETE FROM custinfo WITH (ROWLOCK) WHERE CustID = @CustID
			END
			ELSE IF @RoleID = 3
			BEGIN
				DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
				DELETE FROM custinfo WITH (ROWLOCK) WHERE CustID = @CustID
			END
			ELSE IF @RoleID = 2
			BEGIN
				DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
				DELETE FROM custinfo WITH (ROWLOCK) WHERE CustID = @CustID
			END

			DELETE FROM ProblemAccount WITH (ROWLOCK) WHERE CustId = @custid
			DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM custInfo WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID	
			DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
			EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
			
			RETURN
		END
    END
END


GO
