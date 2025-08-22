/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_SAg]
(
	@Custid INT
	,@UserName VARCHAR(30)
	,@Userpwd VARCHAR(40)
	,@FirstName NVARCHAR(50)
	,@LastName NVARCHAR(50)
	,@Phone NVARCHAR(50)
	,@MobilePhone NVARCHAR(50)
	,@Fax NVARCHAR(50)
	,@Credit MONEY	
	,@Creator INT
	,@srecommend INT	
	,@ExistingCustid INT
	,@SubAccID INT=0	
	,@Language VARCHAR(2)= 'E'
	,@IP VARCHAR(15)=''		
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
	,@SystemID TINYINT=1
	,@SettingStatus TINYINT = 0
)
AS
/*  
 Created by: Dan  
 Date:20120207
 Original: dbo.Agm_CustomerInsMember_Ag, Acc_CustomerInsMember_SAg
 Task: Add new master from existing master
	(#436.2 IRP - AgeSite - Search&Copy feature to feature to facilitate downline creation) 
 
 DB: DBCUST/CustDB  
  
 Revisions:  
	- 20120323 @Dan: check roleid and the super of existing master before copying 
	- 20120820@Dan: add 3 fields in custinfo table (VS)
	- 20120829@Dan: isSync status for 3 products - Casino,Bingo and LiveCasino will not be cloned
	- 20120928@Dan: add fields for LCS-win limit
	- 20121012@Johnson: check double comm losing status by upline
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130218@Dan: Write more log on DBTXN server in CASE of DBLOG server failure
	- 20130220@Johnson: Add virtual horse racing setting (sporttype : 181 , bettype : 1231)
	- 20130328@Jamie: Add CustLoginInfo 
	- 20130423@Jamie: Set isForcedChangeSecurityCode = 1 WHEN Upline's SecurityCode NOT NULL 
	- 20130731@Elodie: Apply progressive bonus
	- 20131017@Kathy: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend INTo Soccer and Other Sport [Redmine:#5520] 
	- 20131113@Johnson: Apply execrep WHEN insert setting INTo CustSetting/CustSetting3rd/...
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140402@Dom: Add more sport: 183,185 for Virtual sport
	- 20140609@Elodie: Not allow create a new customer by using search & copy function from a existed account which is disabled [Redmine:#17366]
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
	- 20140711@Logan: Force using Security Code for SMA from all sites (except 789y) [Redmine:#18121]
	- 20140822@Logan:   Add status for E-Sports [Redmine: #20531]
	- 20150107@Johnson: separate virtual rate settings by sporttype, bettype [Redmine: #25840]
	- 20150427@Kathy: Add Gold Deluxe product [Redmine:#34486]
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150714@Patrick: Add max win limit for Gold deluxe
	- 20150909@Elodie: Remove copying Virtual Rate setting from function Search and Copy [Redmine:#42976]                
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151016@Elodie: Add AgentCommRate setting in Acc_CustomerInfo_Execrep_02 [Redmine: #41264, 41470]
	- 20151030@Billy: Change to new VirtualRate structure [Redmine: #46541]
	- 20151223@Patrick: Add Max/Loss limit for RnG Casino [Redmine: #49528]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170420@Helen:  Add Extra information for Direct Accounts, for NAP only - [Redmine:72339]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170704@Winnie: Apply color for closed account - [Redmine: #74494]
	- 20170920@Helen: TO Control Phase 3 - [Redmine: 75557]
	- 20171113@Helen: Support to add default TO setting for new direct customers - [Redmine:86052]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180621@Razor: Add Message Customer Read Status [Redmind: #94705]
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526] 
	- 20181205@Kan: Write @SystemID param into log [Redmine:104431]
	- 20181105@Louis: Credit Collection Summary  [RedmineID: #98621]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190923@Johnson: copy danger status from upline [redmine:#120056]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200114@Malcolm: Separate setting and notification into Live/Non-Live and bettypes [Redmine : 125076]
	- 20200210@Elodie: Problem account for credit [Redmine:#127446]
	- 20200310@Percy: Add column IsAllDayBalTransfer on CustMaster [RedmineID: #130091]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200602@Sol: Check IsAutoEnableADBMaster to enable ADB on Mater or not[Redmine: #134242]
	- 20200722@Johnson: add void time & limit amount for problem account [redmine:#135253]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210202@Winfred : Virtual Rate for Basketball - New 611111 site super must have VR setting = 0%   [Redmine: #149369]	
	- 20210224@Eden: Implement Lock for VR update [Redmine:#149370]
	- 20210319@Winfred: Check Site to limit create accounts [Redmine: #151526]
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20220419@Eden: Turn off VR Basketball & E-sports for 611111 site [Redmine: #171609]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220527@Johnson: Remove Problem Account [RedmineID:#173304]
	- 20221013@Eden: Remove unused columns from Custinfo table [RedmineID: #179014]
	- 20221122@Johnson: move sp Age_MsgCustReadStatus_Ins to web [RedmineID: #180730]
	- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
	- 20230217@Johnson: Telegram chatbot - clone account systemID = 10 [Redmine: #183697]
	- 20230302@Johnson: add auto suspend for Basketball & return Basketball VR to its original state [redmine: #184339]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230615@Johnson: Check Problem Account  Limit New Downline Per Day [redmine: #189792]
	- 20230622@Helios: Alpha/ExtNAP - Create new downlines - Remove some obsolete rules [Redmine: #190167]
	- 20230918@Helios: Update rule VR+ for New Customer [Redmine: #194141]
	- 20231211@Johnson: check permission for 777 [redmineID: #197160]
	- 20240229@Johnson: no need check permission for 777 on Alpha [redmine: #201574]
	- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240607@Johnson: scale out DBCUST [redmine: #199915]
	- 20240520@Eden: Unify RNG Games [redmine: #204358] 
	- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
	- 20240704@Helen: Revise code for scaleout dbcust - [Redmine:#206823]
	- 20241204@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
	- 20241225@July: Scale out DB - In-house Replicator - Support change for SMA TO Control [Redmine: #207042]
	- 20241230@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
	- 20250317@July: Scale Out DBCUST - Change unique key table TOControl_GlobalSetting [Redmine: #221252]
	- 20250827@Dave: Alpha_Add remark field when editing info of master/Agent/member - write log @remark [Redmine: #236744]
	
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
	- @SettingStatus: 0: Pro, 1: UAT
  
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME, @IsAllDayBalTransfer BIT, @IsAutoEnableADBMaster BIT 
	
	DECLARE @currency INT,  @site NVARCHAR(50)

	SET @CreateDate = GETDATE()
	
	DECLARE @startRun DATETIME
		,@endRun DATETIME
		,@duration INT
		,@pwdexpiry DATETIME	
		,@mrecommend	INT
		,@recommend		INT	
		,@CreditRM MONEY

		,@important		BIT			 	
		,@address		NVARCHAR(80)  
		,@city			NVARCHAR(50)  
		,@state			NVARCHAR(50)  
		,@country		NVARCHAR(50)  
		,@postal		NVARCHAR(50)  
		,@email			NVARCHAR(50)  
		,@birthday		SMALLDATETIME  
		,@refcode1		NVARCHAR(100)  
		,@refcode2		NVARCHAR(100)  
		,@remark		NVARCHAR(100)  
		,@roleid		INT
		,@ugroup		VARCHAR(5)
		,@SiteID		INT

	SELECT @pwdexpiry = dateadd(dd, 30, getdate())
		,@startRun = getdate()
	
	SELECT  @currency = currency
		,@site = site
		,@address  = '-'
		,@postal  = '-'
		,@city	  = '-'
		,@state	  = '-'
		,@country = '-'
		,@email = '-'
		,@birthday = NULL 
		,@refcode1 = NULL 
		,@refcode2 = NULL 
		,@remark   = NULL 				
		,@roleid	 = 3
		,@srecommend = srecommend
		,@mrecommend = @CustID
		,@recommend  = 0
		,@ugroup = ugroup
	FROM dbo.Customer WITH(NOLOCK) 
	WHERE custid = @ExistingCustid

	SELECT @SiteID = SiteID FROM Site  WITH (NOLOCK) WHERE site = @site
	
	BEGIN TRY
		EXEC Acc_CustomerIns
			@FirstName	= @FirstName	
			,@LastName	= @LastName	
			,@UserName	= @UserName	
			,@UserPwd	= @UserPwd	 
			,@pwdexpiry = @pwdexpiry 
			,@roleid	= @roleid	
			,@CustID	= @CustID	
			,@creator	= @creator	

			,@phone			= @phone			
			,@mobilephone	= @mobilephone	
			,@email			= @email			
			,@fax			= @fax			
			,@address		= @address		
			,@city			= @city			
			,@state			= @state			
			,@country		= @country		
			,@postal		= @postal		
			,@srecommend	= @srecommend	
			,@mrecommend	= @mrecommend	
			,@recommend		= @recommend		
			,@currency		= @currency		
			,@site			= @site			
			,@ugroup		= @ugroup
			,@birthday		= @birthday	
			,@refcode1		= @refcode1	
			,@refcode2		= @refcode2	
			,@remark		= @remark	
			,@important		= @important	
			
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg  = @ErrMsg OUTPUT	

		IF ISNULL(@ErrCode,0) <> 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
							end
				,@ErrCode = 103
				
			-- ROLLBACK MANUALLY
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID		
			RETURN
		END	
	
		-- insert CustMaster info
		SELECT @IsAllDayBalTransfer = IsAllDayBalTransfer
				, @IsAutoEnableADBMaster = IsAutoEnableADBMaster
		FROM dbo.CustSuper WITH (NOLOCK)
		WHERE CustId = @srecommend

		INSERT INTO CustMaster(custId, DisableAutoMPT, IsInternal, TransferOption, IsAllDayBalTransfer,RepUpdateTime)  
		SELECT @CustID,
				DisableAutoMPT,
				IsInternal,
				TransferOption,
				CASE WHEN @IsAutoEnableADBMaster = 1 THEN ISNULL(@IsAllDayBalTransfer, 0) ELSE 0 END,
				dbo.f_GetDateTime2()
		FROM dbo.CustMaster WITH(NOLOCK)
		WHERE custid=@ExistingCustid

		DECLARE @enableUpline bit, @doubleCommLosingUpline bit, @virtualmultiplier SMALLMONEY
		-- get autosuspend's upline
		DECLARE @autosuspend BIT,
			@autosuspend2 BIT,
			@autosuspend3 BIT,
			@DangerSuper TINYINT = 0,
			@DangerSuper2 TINYINT = 0,
			@DangerSuper3 TINYINT = 0,
			@DangerSuper4 TINYINT = 0,
			@DangerSuper5 TINYINT = 0

		select @enableUpline = isnull(enabled,0), @doubleCommLosingUpline = DoubleCommLosing,
			 @autosuspend = ISNULL(autosuspend, 0),
			 @autosuspend2 = ISNULL(autosuspend2, 0),
			 @autosuspend3 = ISNULL(autosuspend3, 0),
			 @virtualmultiplier = ISNULL(virtualmultiplier,1),
			 @DangerSuper = Danger,
			 @DangerSuper2 = Danger2,
			 @DangerSuper3 = Danger3,
			 @DangerSuper4 = Danger4,
			 @DangerSuper5 = Danger5
		from custinfo with (nolock)
		where custid = @srecommend

		-- insert CustInfo info
		INSERT INTO dbo.custInfo
				(custid
				,username
				,currency
				,roleid
				,srecommend
				,mrecommend
				,recommend
				,dangercust
				,autosuspend
				,autosuspend2
				,autosuspend3
				,credit
				,MatchLimit
				,VirtualMultiplier
				,Enabled   		
				,DisableOutright		
				,DoubleCommLosing		
				,DisableSuperLive
				,Danger
				,Danger2
				,Danger3
				,Danger4
				,Danger5
				,RepUpdateTime
				)
		 SELECT
				@custid
				,@username
				,currency
				,3 AS roleid
				,srecommend
				,@custid
				,0 as recommend
				,0 AS dangercust
				,@autosuspend AS autosuspend
				,@autosuspend2 as autosuspend2
				,@autosuspend3 as autosuspend3
				,@Credit AS Credit
				,MatchLimit
				,@virtualmultiplier
				,@enableUpline as Enabled 		
				,DisableOutright
				,@doubleCommLosingUpline as doubleCommLosing		
				,DisableSuperLive
				,@DangerSuper
				,@DangerSuper2
				,@DangerSuper3
				,@DangerSuper4
				,@DangerSuper5
				,dbo.f_GetDateTime2()
		FROM dbo.custinfo WITH(NOLOCK)
		WHERE custid=@ExistingCustid  

		SELECT @CreditRM = @credit * actualrate
		FROM dbo.exchange WITH (NOLOCK) 
		WHERE exchangeid = @currency

		IF @CreditRM > 300000
		BEGIN
			INSERT INTO SuspiciousCust (CustID, NotifyStatus1, NotifyStatus2, RepUpdateTime)
			SELECT @CustId, 1, 0, dbo.f_GetDateTime2()
		END

		DECLARE @ProductProfile VARCHAR(MAX) = ''

		EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT,
			@ProductProfile	= @ProductProfile OUTPUT
		
		IF @ErrCode > 0 
		BEGIN
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								end

			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END

		-- Start : Initialize Data 3rd Products
		EXEC dbo.Acc_Custsetting_CloneSetting_3rdProductIns
			@custid = @custid,
			@ExistingCustID = @ExistingCustid,
			@RoleID = @RoleID,
			@SiteID = @SiteID,
			@Currency = @Currency,
			@ProductProfile = @ProductProfile,
			@ErrCode = @ErrCode OUTPUT,
			@SettingStatus	= @SettingStatus

		IF @ErrCode > 0 
		BEGIN
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								end

			-- ROLLBACK MANUALLY			
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END
		-- End : Initialize Data 3rd Products

		-- Start : Initialize Data SportsBook
		EXEC dbo.Acc_Custsetting_CloneSetting_SportsbookIns
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT
	
		IF @ErrCode > 0 
		BEGIN
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								end
			-- ROLLBACK MANUALLY  
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN 
		END
	END TRY
	BEGIN CATCH 
		SELECT @ErrMsg = CASE @Language   
						   WHEN 'E' THEN 'Create customer failed. Please try again.'  
						   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						  END,  
				@ErrCode = 105  

		-- ROLLBACK MANUALLY  
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN  
	END CATCH
	
	BEGIN TRY
		If @SystemID IN (2, 10) -- ALPHA, Chatbot
		BEGIN
			EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
			IF @ErrCode > 0
			BEGIN
				SELECT @ErrMsg = CASE @Language 
									when 'E' then 'Create customer fail. Please try again'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END
				-- ROLLBACK MANUALLY  
				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
				RETURN
			END	
		END

		DECLARE	@UplineSecurityCode			VARCHAR(50)
			  , @isForcedChangeSecurityCode	BIT,@ClosedReason TINYINT=0,@Closed BIT
		SELECT TOP 1 @Closed=CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END
		FROM CustProductStatus WITH(NOLOCK) WHERE custid=@ExistingCustid

		IF (@SystemID=1 AND @Closed=1)
			SELECT @ClosedReason=1
		ELSE IF(@SystemID<>1 AND @Closed=1)
			SELECT @ClosedReason=2
		ELSE 
			SELECT @ClosedReason=0

		SELECT @UplineSecurityCode		   = NULL
			 , @isForcedChangeSecurityCode = 0

		SELECT @UplineSecurityCode = SecurityCode
			 , @isForcedChangeSecurityCode = isForcedChangeSecurityCode
		  FROM dbo.CustLoginInfo WITH(NOLOCK)
		 WHERE CustID = @SRecommend

		IF @UplineSecurityCode IS NOT NULL OR @isForcedChangeSecurityCode = 1
			SELECT @isForcedChangeSecurityCode = 1  -- Force Set Security Code WHEN login

		INSERT INTO dbo.CustLoginInfo
		(
			CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCodeCount, SecurityCode,
			isForcedChangeSecurityCode, LastChangedSecurityCodeDate,ClosedReason
		  , RepUpdateTime
		)
		VALUES
		(
			@custid, NULL, GETDATE(), 1, 0, NULL,
			@isForcedChangeSecurityCode, NULL,@ClosedReason
		  , dbo.f_GetDateTime2()	
		)
	
	END TRY
	BEGIN CATCH
		--Error occur
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								WHEN 'CS' THEN N'新增会员上成功，请重新尝试.'
								WHEN 'CT' THEN N'新增會員上成功,請重新再試.'
								WHEN 'TH' THEN N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
								WHEN 'J' THEN N'Create customer failed. Please try again.'
								WHEN 'ES' THEN N'Create customer failed. Please try again.'
								WHEN 'KO' THEN N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
								else N'Create customer failed. Please try again.'
							end,
			@ErrCode = 115
			
		-- ROLLBACK MANUALLY  
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END	CATCH
	
	BEGIN TRY
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual,RepUpdateTime)
		SELECT @Custid, seqNo, bitmapVirtual, [dbo].[f_GetDateTime2]() AS RepUpdateTime
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @srecommend
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY  
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH				
	
	BEGIN TRY
		INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status, RepUpdateTime)
		SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status, dbo.f_GetDateTime2() AS RepUpdateTime
		FROM Customer ci WITH(NOLOCK)
		WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			AND ci.srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		
		IF @@ROWCOUNT <> 0 
		BEGIN
			EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
				
			SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
			EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 601,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
			
			INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID, RepUpdateTime)
            SELECT @custid
                    -- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
                    , CASE 
                            -- currency RM in default Setting
                            WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
                            -- NOT currency RM in default Setting
                            ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
                    END AS MaxTurnOver
                    , TO_tmp.Sporttype, 0, TO_tmp.ProfileID
					, dbo.f_GetDateTime2()
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
		
			DELETE dbo.TOControl_GlobalSetting WITH (ROWLOCK)
				OUTPUT DELETED.CustID, DELETED.Sporttype, DELETED.IsGroupHeadLine, DELETED.ProfileID, dbo.f_GetDateTime2(), DELETED.ID
				INTO dbo.TOControl_GlobalSetting_Del_Inhouse(CustID, Sporttype, IsGroupHeadLine, ProfileID, RepUpdateTime, ID)
			WHERE CustID = @srecommend
			
			DELETE dbo.TOControl_Setting
			WHERE CustID = @srecommend
		END	

		 --New 611111 super must have VR setting = 0% ESport
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

			INSERT INTO [VRSettingManualUpdAcc](CustID,SportType,RepUpdateTime)
			SELECT @CustID,43 AS SportType, [dbo].[f_GetDateTime2]() AS RepUpdateTime
			WHERE NOT EXISTS (SELECT 1 FROM VRSettingManualUpdAcc WHERE custid = @CustId AND SportType = 43)
		 END
		

		 --VR lock status
		INSERT INTO VRCustLockStatus(CustID,Type,RepUpdateTime)
		SELECT @custid,Type, [dbo].[f_GetDateTime2]() AS RepUpdateTime
		FROM VRCustLockStatus v (NOLOCK) 
		WHERE CustID = @srecommend
			AND NOT EXISTS( SELECT 1 FROM VRCustLockStatus(NOLOCK) WHERE CustID = @custid AND type = v.Type)
			--AND v.Type <> 4
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY  
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 3
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH	
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	DECLARE @LogSPData VARCHAR(8000)
	--Log customer general info
	Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_SAg custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as VARCHAR(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as VARCHAR(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as VARCHAR(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as VARCHAR(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as VARCHAR(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as VARCHAR(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as VARCHAR(100)),space(1))) + '" ' +
	'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@remark as NVARCHAR(200)),space(1))) + '" ' +

	'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
	'mrecommend="'+ coalesce(cast(@mrecommend as VARCHAR(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
	'CopiedFomUsername="'+c.username+'" '+
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)),space(1)) + '" ' +
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as VARCHAR(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as VARCHAR(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	DECLARE @ActionID INT 
	SELECT @ActionID = CASE WHEN @systemID = 10 THEN 95079 --telegram chatbot					
						ELSE 95080 --Mulitple customers
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
		Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_SAg custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as VARCHAR(100)),space(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as VARCHAR(100)),space(1))) + '" ' +
		'creator="'+ coalesce(cast(@creator as VARCHAR(50)),space(1)) + '" ' +
		'username="'+ coalesce(cast(@username as VARCHAR(30)),space(1)) + '" ' +

		'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as VARCHAR(100)),space(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as VARCHAR(100)),space(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as VARCHAR(100)),space(1))) + '" ' +
		'remark="'+ dbo.f_EncodeXMLValue(coalesce(cast(@remark as NVARCHAR(200)),space(1))) + '" ' +
		'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
		'mrecommend="'+ coalesce(cast(@mrecommend as VARCHAR(50)),space(1)) + '" ' +	
		'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
		'CopiedFomUsername="'+c.username+'" '+
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)),space(1)) + '" ' +
		'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as VARCHAR(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as VARCHAR(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = @ActionID,
			@TrackingValue = @LogSPData,
			@duration = @duration		
	END CATCH
		
	SET NOCOUNT OFF
END
GO