/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_MAg]
(
	@Custid int
	,@UserName varchar(30)
	,@Userpwd varchar(40)
	,@FirstName nvarchar(50)
	,@LastName nvarchar(50)
	,@Phone nvarchar(50)
	,@MobilePhone nvarchar(50)
	,@Fax nvarchar(50)
	,@Credit money
	,@MaxCredit money
	,@Creator int
	,@mrecommend int	
	,@ExistingCustid int
	,@SubAccID int=0	
	,@Language varchar(2)= 'E'
	,@IP varchar(15)=''		
	,@ErrCode int = 0 output
	,@ErrMsg nvarchar(4000) = '' output
	,@SystemID TINYINT=1
	,@SettingStatus TINYINT = 0
)
AS
/*  
 Created by: Dan  
 Date:20120207
 Original: dbo.Agm_CustomerInsMember_Ag, Acc_CustomerInsMember_MAg
 Task: Add new agent from existing agents 
	(#436.2 IRP - AgeSite - Search&Copy feature to feature to facilitate downline creation) 
 
 DB: DBCUST/CustDB
  
 Revisions:  
	- 20120323 @Dan: check roleid and the master of existing agent before copying 
	- 20120718@Dan: add 1 more field "site" in CustAgent table
	- 20120801@Dan: add 3 fields in custinfo table (VS)
	- 20120829@Dan: isSync status for 3 products - Casino, Bingo and LiveCasino will not be cloned
	- 20120928@Dan: add fields for LCS-win limit
	- 20121012@Johnson: check double comm losing status by upline
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20130220@Johnson: Add virtual horse racing setting(sporttype: 181, bettype: 1231)
	- 20130328@Jamie: Add CustLoginInfo
	- 20130423@Jamie: Set isForcedChangeSecurityCode = 1 WHEN Upline's SecurityCode NOT NULL 
	- 20130731@Elodie: Apply progressive bonus
	- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend into Soccer and Other Sport [Redmine:#5520]
	- 20131113@Johnson: Apply execrep when insert setting into CustSetting/CustSetting3rd/...[Redmine:#3244]
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport: 202 for Keno
	- 20140402@Dom: Add more sport: 183,185 for Virtual sport
	- 20140609@Elodie: Not allow create a new customer by using search & copy function from a existed account which is disabled [Redmine:#17366]
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
	- 20140711@Logan: Force using Security Code for SMA from all sites (except 789y) [Redmine:#18121]
	- 20140822@Logan:   Add status for E-SPorts [Redmine: #20531]
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
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190923@Johnson: copy danger status from upline [redmine:#120056]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200102@Malcolm: Separate setting and notification into Live/Non-Live and bettypes [Redmine : 125076]
	- 20200210@Elodie: Problem account for credit [Redmine:#127446]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
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
	- 20230302@Johnson: add auto suspend for Basketball & return Basketball VR to its original state [redmine: #184339]
	- 20230217@Johnson: Telegram chatbot - clone account systemID = 10 [Redmine: #183697]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230615@Johnson: Check Problem Account  Limit New Downline Per Day [redmine: ##189792]
	- 20230622@Helios: Alpha/ExtNAP - Create new downlines - Remove some obsolete rules [Redmine: #190167]
	- 20230918@Helios: Update rule VR+ for New Customer [Redmine: #194141]
	- 20231211@Johnson: check permission for 777 [redmineID: #197160]
	- 20240229@Johnson: no need check permission for 777 on Alpha [redmine: #201574]
	- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240607@Johnson: scale out DBCUST [redmine: #199915]
	- 20240520@Eden: Unify RNG Games [redmine: #204358] 
	- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
	- 20240704@Helen: Revise code for scaleout dbcust - [Redmine:#206823]
	- 20241125@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
	- 20241225@July: Scale out DB - In-house Replicator - Support change for SMA TO Control [Redmine: #207042]
	- 20250220@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
	- @SettingStatus: 0: Pro, 1: UAT
  
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME
	SET @CreateDate = GETDATE()

	DECLARE @startRun datetime
		,@endRun datetime
		,@duration int
		,@pwdexpiry datetime
		,@recommend int		
		,@CreditRM MONEY

		,@srecommend	INT	
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

	DECLARE @currency INT, @site NVARCHAR(50), @ExistingSrecommend int

	SELECT @pwdexpiry = dateadd(dd, 30, getdate())
		,@startRun = getdate()
		,@currency = currency
		,@site = site
		,@ExistingSrecommend = ISNULL(srecommend,0)
		,@currency = currency
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
		,@roleid	 = 2
		,@srecommend = srecommend
		,@mrecommend = mrecommend
		,@recommend  = @custid
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

 
		IF ISNULL(@ErrCode,0) > 0
		BEGIN
			SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 103
				
			-- ROLLBACK MANUALLY
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END	

		INSERT INTO CustAgent(custId, MaxCredit, IsInternal, TransferOption, Site, RepUpdateTime)
		SELECT @CustID,
				@MaxCredit,
				IsInternal,
				TransferOption,
				Site,
				dbo.f_GetDateTime2()
		FROM dbo.CustAgent WITH(NOLOCK)
		WHERE custid=@ExistingCustid		 

		DECLARE @enableUpline bit, @doubleCommLosingUpline bit, @virtualmultiplier SMALLMONEY
		Declare @autosuspend BIT,
				@autosuspend2 BIT,
				@autosuspend3 BIT,
				@DangerMaster TINYINT = 0,
				@DangerMaster2 TINYINT = 0,
				@DangerMaster3 TINYINT = 0,
				@DangerMaster4 TINYINT = 0,
				@DangerMaster5 TINYINT = 0

		select @enableUpline = isnull(enabled,0), @doubleCommLosingUpline = DoubleCommLosing,
			@autosuspend = ISNULL(autosuspend, 0),
			@autosuspend2 = ISNULL(autosuspend2, 0),
			@autosuspend3 = ISNULL(autosuspend3, 0),
			@virtualmultiplier = ISNULL(virtualmultiplier,1),
			@DangerMaster = Danger,
			@DangerMaster2 = Danger2,
			@DangerMaster3 = Danger3,
			@DangerMaster4 = Danger4,
			@DangerMaster5 = Danger5
		from custinfo with (nolock)
		where custid = @mrecommend

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
				,2 AS roleid
				,srecommend
				,mrecommend
				,@custid
				,0 AS dangercust
				,@autosuspend AS autosuspend
				,@autosuspend2 as autosuspend2
				,@autosuspend3 AS autosuspend3
				,@Credit AS Credit
				,MatchLimit
				,@virtualmultiplier
				,@enableUpline as Enabled          	     
				,DisableOutright		
				,@doubleCommLosingUpline as DoubleCommLosing	
				,DisableSuperLive
				,@DangerMaster
				,@DangerMaster2
				,@DangerMaster3
				,@DangerMaster4
				,@DangerMaster5
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
			@ProductProfile = @ProductProfile OUTPUT,
			@ErrCode = @ErrCode output

		IF @ErrCode > 0 
		BEGIN
			SELECT @ErrMsg = case @Language 
									when 'E' then 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								end

			-- ROLLBACK MANUALLY	
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
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
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END
		-- End : Initialize Data 3rd Products
	
		-- Start : Initialize Data SportsBook
		EXEC dbo.Acc_Custsetting_CloneSetting_SportsbookIns
				@custid = @custid,
				@ExistingCustid = @ExistingCustid,
				@SettingStatus = @SettingStatus,
				@ErrCode = @ErrCode output

		IF @ErrCode > 0 
		BEGIN
			SELECT @ErrMsg = case @Language 
									when 'E' then 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								end

			-- ROLLBACK MANUALLY  
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
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
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
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
				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
				RETURN
			END	
		END

		DECLARE	@UplineSecurityCode			VARCHAR(50)
			  , @isForcedChangeSecurityCode	BIT, @ClosedReason TINYINT=0,@Closed BIT
		SELECT TOP 1 @Closed= CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END
		FROM CustProductStatus WITH(NOLOCK) WHERE custid=@ExistingCustid

		IF (@SystemID=1 AND @Closed=1)
			SELECT @ClosedReason=1
		ELSE IF(@SystemID<>1 AND @Closed=1)
			SELECT @ClosedReason=2
		ELSE 
			SELECT @ClosedReason=0

		SELECT @UplineSecurityCode				= NULL
			 , @isForcedChangeSecurityCode	= 0

		SELECT @UplineSecurityCode = SecurityCode
			 , @isForcedChangeSecurityCode = isForcedChangeSecurityCode
		  FROM dbo.CustLoginInfo WITH(NOLOCK)
		 WHERE CustID = @MRecommend

		IF @UplineSecurityCode IS NOT NULL OR @isForcedChangeSecurityCode = 1
			SELECT @isForcedChangeSecurityCode = 1  -- Force Set Security Code when login

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
	END TRY
	BEGIN CATCH
		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								when 'CS' then N'新增会员上成功，请重新尝试.'
								when 'CT' then N'新增會員上成功,請重新再試.'
								when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
								when 'J' then N'Create customer failed. Please try again.'
								when 'ES' then N'Create customer failed. Please try again.'
								when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
								else N'Create customer failed. Please try again.'
							end,
			@ErrCode = 114
			
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN			
	END CATCH
	
	BEGIN TRY
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual,RepUpdateTime)
		SELECT @Custid, seqNo, bitmapVirtual, [dbo].[f_GetDateTime2]() AS RepUpdateTime
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @mrecommend      
	
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
				OUTPUT DELETED.CustID, DELETED.Sporttype, DELETED.IsGroupHeadLine, DELETED.ProfileID, dbo.f_GetDateTime2()
				INTO dbo.TOControl_GlobalSetting_Del_Inhouse(CustID, Sporttype, IsGroupHeadLine, ProfileID, RepUpdateTime)
			WHERE CustID IN (@ExistingSrecommend,@mrecommend)
			
			DELETE dbo.TOControl_Setting
			WHERE CustID IN (@ExistingSrecommend,@mrecommend)
		END	
	
		 --VR lock status
		INSERT INTO VRCustLockStatus(CustID,Type,RepUpdateTime)
		SELECT @custid,Type, [dbo].[f_GetDateTime2]() AS RepUpdateTime
		FROM VRCustLockStatus v (NOLOCK) 
		WHERE CustID = @mrecommend
			AND NOT EXISTS( SELECT 1 FROM VRCustLockStatus(NOLOCK) WHERE CustID = @custid AND type = v.Type)
			--AND v.Type <> 4

		IF @site = '611111'
		BEGIN
			INSERT INTO [VRSettingManualUpdAcc](CustID,SportType,RepUpdateTime)			
			SELECT @CustID,43 AS SportType, [dbo].[f_GetDateTime2]() AS RepUpdateTime
			WHERE NOT EXISTS (SELECT 1 FROM VRSettingManualUpdAcc WHERE custid = @CustId AND SportType = 43)
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 2
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	Declare @LogSPData varchar(8000)
	--Log customer general info
	Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
	'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +
	'MaxCredit="'+ coalesce(cast(@MaxCredit as varchar(50)),space(1)) + '" ' +
	'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
	'CopiedFomUsername="'+c.username+'" '+
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	DECLARE @ActionID INT 
	SELECT @ActionID = CASE WHEN @systemID = 10 THEN 95081 --telegram chatbot
							ELSE 95082 --Multiple customers
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
		
		Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
		'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
		'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
		'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
		'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +
		'MaxCredit="'+ coalesce(cast(@MaxCredit as varchar(50)),space(1)) + '" ' +
		'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +	
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
		'CopiedFomUsername="'+c.username+'" '+
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'
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