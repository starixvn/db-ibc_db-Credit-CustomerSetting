/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_Com]
(
	@Custid INT
	,@UserName VARCHAR(30)
	,@Userpwd VARCHAR(40)
	,@FirstName NVARCHAR(50)
	,@LastName NVARCHAR(50)
	,@Phone NVARCHAR(50)
	,@MobilePhone NVARCHAR(50)
	,@Site NVARCHAR(50)
	,@Fax NVARCHAR(50)
	,@Credit MONEY	
	,@IsInternal BIT
	,@ExistingCustid INT
	,@Creator INT	
	,@Language VARCHAR(2)= 'E'
	,@IP VARCHAR(15)=''		
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
	,@SystemID TINYINT=1
	,@SettingStatus TINYINT = 0
)
AS
/*  
 Created by: Elodie  
 Date:20131025
 Original: 
 Task: Add new super from existing super [Redmine:#5456]
 DB: DBCUST/CustDB  
  
 Revisions:  
	- 20131113@Johnson: Apply execrep WHEN insert setting INTo CustSetting/CustSetting3rd/...
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184) [Redmine:#7234]
	- 20140304@Patrick	: Add more sport: 202 for Keno
	- 20140402@Dom	: Add more sport: 183,185 for Virtual sport
	- 20140609@Elodie: Not allow create a new customer by using search & copy function from a existed account which is disabled [Redmine:#17366]
	- 20140711@Logan: Force using Security Code for SMA from all sites (except 789y) [Redmine:#18121]
	- 20140822@Logan:   Add E-Sports status [Redmine: #20531]
	- 20150107@Johnson: separate virtual rate settings by sporttype, bettype [Redmine: #25840]
	- 20150427@Kathy: Add Gold Deluxe product [Redmine:#34486]
	- 20150707@Elodie: Add Super Live product [Redmine: #35776]
	- 20150714@Patrick: Add max win limit for Gold deluxe    
	- 20150821@Elodie: Set HideGoldDeluxe = 1 for 789y site    
	- 20150909@Elodie: Remove copying Virtual Rate setting from function Search and Copy [Redmine:#42976]                
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151016@Elodie: Add AgentCommRate setting in Acc_CustomerInfo_Execrep_02 [Redmine: #41264, 41470]
	- 20151030@Billy: Change to new VirtualRate structure [Redmine: #46541]
	- 20151223@Patrick: Add Max/Loss limit for RnG Casino [Redmine: #49528]
	- 20160217@Dominic: Not allow to create a IMBC customer from MBC customer and and vice versa [Redmine: #50028]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170207@Elodie: Set HideGoldDeluxe = 0 for 789y site - [Redmine: #69200]
	- 20170420@Helen:  Add Extra information for Direct Accounts, for NAP only - [Redmine:72339]
	- 20170614@Johnson: Force Security Code for newly created Super on i7  - [Redmine: #78293]
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170704@Winnie: Apply color for closed account - [Redmine: #74494]
	- 20170920@Helen: TO Control Phase 3 - [Redmine: 75557]
	- 20171113@Helen: Support to add default TO setting for new direct customers - [Redmine:86052]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180621@Razor: Add Message Customer Read Status [Redmind: #94705]
	- 20181002@Elodie: Limit max members creation per Super. [RedmineID: #101994]
	- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882] 
	- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526] 	
	- 20181105@Louis: Credit Collection Summary  [RedmineID: #98621]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200102@Malcolm: Separate setting and notification into Live/Non-Live and bettypes [Redmine : 125076]
	- 20200323@Elodie: Block to add new customer for 789y [Redmine: #130636]
	- 20200403@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20201008@Winfred : New Super - Prefix Warning [Redmine: #142239]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20201005@Eden: Minimize UM Time Phase 2 [Redmine: #142115]
	- 20210202@Winfred : Virtual Rate for Basketball - New 611111 site super must have VR setting = 0%   [Redmine: #149369]	
	- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20220222@Elodie: Default VR for 789y site [Redmine: #168885]
	- 20220419@Eden: Turn off VR Basketball & E-sports for 611111 site [Redmine: #171609]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20220823@Johnson: Copy Date Limit range and  Auto Transfer Type for real currency 789y [redmine:#176778] 
	- 20221013@Eden: Remove unused columns from Custinfo table [RedmineID: #179014]
	- 20221017@Tacy: NAP - Prevent search & copy Super cross site [redmineID: #179019]
	- 20221122@Johnson: move sp Age_MsgCustReadStatus_Ins to web [RedmineID: #180730]
	- 20221226@Tacy: Alpha/NAP - Split 789y Site [RedmineID: #181596]
	- 20230302@Johnson: Return Basketball VR to its original state [redmine:#184339]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230718@Eden: Scale out DBTRANS for Credit [Redmine: #181595]
	- 20230915@Tacy: Alpha/NAP - Support to update siteLabel for MBC [Redmine: #194034]
	- 20240129@Luke: NAP - Virtual rate - Change default of VR Status for newly created Super to Enable [Redmine: #200311]
	- 20231211@Johnson: check permission for 777 [redmineID: #197160]
	- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	- 20240419@Tacy: NAP - Permission controls on real currency [redmineID: #202523]
	- 20240607@Johnson: scale out DBCUST [redmine: #199915]
	- 20240520@Eden: Unify RNG Games [redmine: #204358]   
	- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
	- 20240704@Helen: Revise code for scaleout dbcust - [Redmine:#206823]
	- 20241204@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
	- 20241225@July: Scale out DB - In-house Replicator - Support change for SMA TO Control [Redmine: #207042]
	- 20241230@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
	- @SettingStatus: 0: Pro, 1: UAT
  
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT
			,@srecommend	INT	
			,@mrecommend	INT	
			,@recommend		INT	
			,@CreditRM		MONEY
			,@source_SiteLabel VARCHAR(50),@_Site VARCHAR(10)
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
			,@pwdexpiry		DATETIME
			,@roleid		INT
			,@ugroup		VARCHAR(5)
			,@SiteID		INT

	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME	
	SET @CreateDate = GETDATE()	

	-- Check role of existing super and get source site
	DECLARE  @currency INT
		
	DECLARE @SiteLabel varchar(50), @SiteDBGroupID	smallint

	SELECT @SiteLabel=SiteLabel, @SiteDBGroupID = SiteDBGroupID, @SiteID = siteid
	FROM site WITH(NOLOCK) 
	WHERE site = @site

	SELECT  @currency = ci.currency, @source_SiteLabel=s.SiteLabel, @_Site = c.site
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
			,@roleid	 = 4
			,@srecommend = @CustID
			,@mrecommend = 0
			,@recommend  = 0 		
			,@pwdexpiry  = NULL 
			,@important  = 0
			,@ugroup	 = c.ugroup
	FROM dbo.CustInfo ci WITH(NOLOCK) 
		INNER JOIN Customer c WITH(NOLOCK) ON ci.custid=c.custid
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE ci.custid = @ExistingCustid
	
	DECLARE @EnableVR BIT
	SELECT @EnableVR = 1 --Enable as default [#200311]

	SELECT @startRun = getdate()

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
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
							end
				,@ErrCode = 103	
		
			-- ROLLBACK MANUALLY
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN

		END

		-- insert CustSuper info
		DECLARE @MaxMember INT, @MaxMemberLog VARCHAR(50)
		SELECT @MaxMember = CASE WHEN @SiteLabel = '789y' THEN 20000 ELSE -1 END
		SELECT @MaxMemberLog = CASE WHEN @SiteLabel = '789y' THEN '20000' ELSE 'Unlimited' END
	
		INSERT INTO CustSuper(custId,IsInternal, TransferOption, LimitPerIP, SelectedBetting,MaxMember,SiteDBGroupID,RepUpdateTime)  
		SELECT	@CustID, @IsInternal, TransferOption, LimitPerIP, SelectedBetting, @MaxMember,@SiteDBGroupID, dbo.f_GetDateTime2()	
		FROM CustSuper WITH(NOLOCK)
		WHERE custid=@ExistingCustid		
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language   
		   WHEN 'E' THEN 'Create customer failed. Please try again.'  
		   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		  END,  
		@ErrCode = 105  

		-- ROLLBACK MANUALLY
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN

	END CATCH
	
	SELECT @CreditRM = @credit * actualrate
	FROM dbo.exchange WITH (NOLOCK) 
	WHERE exchangeid = @currency

	BEGIN TRY
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
				,credit
				,MatchLimit
				,VirtualMultiplier
				,Enabled   							
				,DisableOutright				
				,DoubleCommLosing	
				,DisableSuperLive
				,RepUpdateTime
				)
		 SELECT
				@CustID
				,@username
				,currency
				,4 AS roleid
				,@CustID
				,0 as mrecommend
				,0 as recommend
				,dangercust
				,0 AS autosuspend
				,@Credit AS Credit
				,MatchLimit
				,@EnableVR AS VirtualMultiplier
				,Enabled  						
				,DisableOutright				
				,doubleCommLosing		
				,DisableSuperLive		
				,dbo.f_GetDateTime2()
		FROM dbo.custinfo WITH(NOLOCK)
		WHERE custid=@ExistingCustid  
		
		IF @CreditRM > 300000
		BEGIN
			INSERT INTO SuspiciousCust (CustID, NotifyStatus1, NotifyStatus2, RepUpdateTime)
			SELECT @CustId, 1, 0, dbo.f_GetDateTime2()
		END

		DECLARE @ProductProfile VARCHAR(MAX) = ''
		EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@Language = @Language,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT,
			@ProductProfile	= @ProductProfile OUTPUT

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END

			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 4
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
					,@ErrCode = 106
		
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 4
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		
		
			RETURN
		END
		-- End : Initialize Data 3rd Products

		-- Start : Initialize Data SportsBook
		EXEC dbo.Acc_Custsetting_CloneSetting_SportsbookIns
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@Language = @Language,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT
	
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END

			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 4
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		
			RETURN
		END
		-- End : Initialize Data SportsBook

		DECLARE @isForcedChangeSecurityCode BIT = 0, @ClosedReason TINYINT=0,@Closed BIT
		SELECT TOP 1 @Closed= CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END
		FROM CustProductStatus WITH(NOLOCK) WHERE custid=@ExistingCustid

		IF (@SystemID=1 AND @Closed=1)
			SELECT @ClosedReason=1
		ELSE IF(@SystemID<>1 AND @Closed=1)
			SELECT @ClosedReason=2
		ELSE 
			SELECT @ClosedReason=0

		SELECT @isForcedChangeSecurityCode = 1

		INSERT INTO dbo.CustLoginInfo
		(
		    CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCodeCount,
		    SecurityCode, isForcedChangeSecurityCode, LastChangedSecurityCodeDate,ClosedReason
		  , RepUpdateTime
		)
		VALUES
		(   @custid, NULL, GETDATE(), 1, 0,
		    NULL, @isForcedChangeSecurityCode, NULL,@ClosedReason
		  , dbo.f_GetDateTime2()
		)
	
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual, RepUpdateTime)
		SELECT custid, seqNo, bitmapVirtual, [dbo].[f_GetDateTime2]() AS RepUpdateTime 
		FROM f_GenerateVirtualSettingBySite (@site,@CustID)
	
		INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status, RepUpdateTime)
		SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status, dbo.f_GetDateTime2() AS RepUpdateTime
		FROM Customer ci WITH(NOLOCK)
		WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		
		IF @@ROWCOUNT <> 0 
			BEGIN
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
				
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 600,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
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
					
			END	
		 
		 --New 611111 super must have VR setting = 0% (Basketball level) + Esport
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
										WHEN 'E' THEN 'Create customer failed. Please try again.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
									END

				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 4
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		
				RETURN
			END

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
			
		-- ROLLBACK MANUALLY
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 4
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN

	END CATCH	
	
	DECLARE @transferType TINYINT,
			@MinDate SMALLDATETIME,
			@LimitDays SMALLINT,
			@NoLimitText VARCHAR(100) = 'No Limit',
			@IsLogDateLimit BIT = 0
	
	IF @source_SiteLabel = '789y' AND @SiteLabel = '789y' AND @Currency <> 20
	BEGIN			
		--auto transfer 
		SELECT @transferType = TransferType,
			@IsLogDateLimit = 1
		FROM Acc_ClearBalanceList WITH(NOLOCK)
		WHERE custid = @ExistingCustid
		
		IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO [dbo].[Acc_ClearBalanceList]
				   ([custid] 
				   ,[status]
				   ,[LastTransfer]           
				   ,[transferType])       
			SELECT @custid,'', GETDATE()-1, @TransferType
		END
		
		--copy Date limit value	
		SELECT @MinDate = MinDate,
			@LimitDays = LimitDays,
			@IsLogDateLimit = 1
		FROM Age_CustDateLimit WITH(NOLOCK)
		WHERE custid = @ExistingCustid
		
		IF @@ROWCOUNT > 0
		BEGIN
			INSERT INTO [dbo].[Age_CustDateLimit]
				   ([CustId]
				   ,[MinDate]
				   ,[LimitDays]
				   ,RepUpdateTime
				  )
			SELECT @custId, @MinDate, @LimitDays, dbo.f_GetDateTime2()
		END
		
	END
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	Declare @LogSPData VARCHAR(8000)
	--Log customer general info
	SELECT @LogSPData = '<Acc_CustomerInsMember_CloneSetting_Com custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as VARCHAR(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as VARCHAR(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as VARCHAR(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as VARCHAR(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as VARCHAR(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as VARCHAR(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as VARCHAR(100)),space(1))) + '" ' +
	'site="'+ coalesce(cast(@site as VARCHAR(50)),space(1)) + '" ' +	
	'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
	'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
	CASE WHEN @IsLogDateLimit = 1 THEN 'TransferType="'+ coalesce(CAST(@transferType as VARCHAR(10)) ,space(1)) + '" ' ELSE '' END +
	CASE WHEN @IsLogDateLimit = 1 THEN 'DataAvailable="'+ COALESCE(CAST(@LimitDays AS VARCHAR(10)), CONVERT(VARCHAR, @MinDate, 101), @NoLimitText) + '" ' ELSE '' END +	
	'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
	'CopiedFromUsername="'+c.username+'" '+
	'ErrCode="'+ coalesce(cast(@ErrCode as VARCHAR(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as VARCHAR(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 638,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH	
		--Log customer general info
		SELECT @LogSPData = '<Acc_CustomerInsMember_CloneSetting_Com custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as VARCHAR(100)),space(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as VARCHAR(100)),space(1))) + '" ' +
		'creator="'+ coalesce(cast(@creator as VARCHAR(50)),space(1)) + '" ' +
		'username="'+ coalesce(cast(@username as VARCHAR(30)),space(1)) + '" ' +
		'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as VARCHAR(100)),space(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as VARCHAR(100)),space(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as VARCHAR(100)),space(1))) + '" ' +
		'site="'+ coalesce(cast(@site as VARCHAR(50)),space(1)) + '" ' +	
		'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
		'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
		'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
		CASE WHEN @IsLogDateLimit = 1 THEN 'TransferType="'+ coalesce(CAST(@transferType as VARCHAR(10)) ,space(1)) + '" ' ELSE '' END +
		CASE WHEN @IsLogDateLimit = 1 THEN 'DataAvailable="'+ COALESCE(CAST(@LimitDays AS VARCHAR(10)), CONVERT(VARCHAR, @MinDate, 101), @NoLimitText) + '" ' ELSE '' END +	
		'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
		'CopiedFromUsername="'+c.username+'" '+
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as VARCHAR(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as VARCHAR(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 638,
			@TrackingValue = @LogSPData,
			@duration = @duration		
	END CATCH
		
	SET NOCOUNT OFF
END
GO


