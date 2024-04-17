/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_Com]
(
	@Custid INT OUTPUT
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
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
	- @SettingStatus: 0: Pro, 1: UAT
  
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
			,@srecommend INT	
			,@CreditRM MONEY
			,@source_SiteLabel VARCHAR(50),@_Site VARCHAR(10)

	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME	
	SET @CreateDate = GETDATE()	

	-- Check role of existing super and get source site
	DECLARE @existingUsername VARCHAR(30),@roleid tinyint, @Enabled BIT, @currency INT
		
	SELECT @existingUsername =  ISNULL(ci.username,''), @roleid = ISNULL(ci.roleid,0), @Enabled = ISNULL(ci.Enabled, 0)
		, @currency = ci.currency, @source_SiteLabel=s.SiteLabel, @_Site = c.site
	FROM dbo.CustInfo ci WITH(NOLOCK) 
		INNER JOIN Customer c WITH(NOLOCK) ON ci.custid=c.custid
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE ci.custid = @ExistingCustid
	
	-------------------BLOCK ADDING NEW USE UMCONFIG----------------------------
	DECLARE @SiteID int, @SiteLabel varchar(50), @SiteDBGroupID	smallint,  @EnableVR BIT

	SELECT @SiteID = siteid, @SiteLabel=SiteLabel, @SiteDBGroupID = SiteDBGroupID
	FROM site WITH(NOLOCK) 
	WHERE site = @site

	-- SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	SELECT @EnableVR = 1 --Enable as default [#200311]

	DECLARE @FromTime VARCHAR(30), @ToTime VARCHAR(30)
	CREATE TABLE #UMConfig(SportType SMALLINT,SiteID INT, Currency INT ,BeginTime smalldatetime,EndTime smalldatetime)
		
	INSERT INTO #UMConfig(SportType,SiteID,Currency,BeginTime,EndTime)	
	SELECT t.SportType,t.SiteID,t.Currency,t.BeginTime,t.EndTime
	FROM UMConfig t WITH(NOLOCK)
	WHERE CONVERT(SMALLDATETIME,GETDATE()) BETWEEN t.BeginTime AND t.EndTime
		AND t.Currency IN (0,@currency)
		AND t.SiteID IN (0,@siteid)
		AND (t.FunctionType = 2 
			 OR (t.FunctionType = 1 AND t.LockAddingNew = 1)
			 )
		AND t.SuperID = 0
	
	--Delete Non-offered Products
	DELETE ft
	FROM #UMConfig ft
		INNER JOIN SportNonOfferedSiteCurrency nof WITH(NOLOCK)
			ON ft.SportType = nof.SportType
			AND nof.siteID IN (ft.SiteID, 0)
			AND nof.Currency IN (ft.Currency, 0)
	WHERE NOT EXISTS(	SELECT 1 
						FROM ProductSettingDetail p WITH(NOLOCK) 
						WHERE nof.SportType = p.SportType 
							AND nof.BetType <> p.BetType 
							AND p.SettingStatus = 0 
					)

	SELECT @FromTime = CONVERT(VARCHAR,MIN(dateadd(HH,12,t.BeginTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MIN(dateadd(HH,12,t.BeginTime)),8),5)),
		  @ToTime = CONVERT(VARCHAR,MAX(dateadd(HH,12,t.EndTime)),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MAX(dateadd(HH,12,t.EndTime)),8),5))
	FROM #UMConfig t

	IF @FromTime IS NOT NULL AND @ToTime IS NOT NULL
	BEGIN
		SELECT @ErrCode = 90016
			 , @ErrMsg =   REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](90016,@Language),'<FromTime>',@FromTime),'<ToTime>',@ToTime)

		RETURN
	END
	------------------------------END----------------------------------------
	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END

	--Check Inactive site:
	IF EXISTS (SELECT 1 FROM Site WITH (NOLOCK) WHERE site=@_Site AND isActive=0)
	BEGIN
		SELECT	@ErrMsg='Cannot copy Super because Source super''s site is inactive',
				@ErrCode=98
		RETURN

	END
	
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

	-- For Myanmar Odds
	DECLARE @IsMyanmarOdds_destination BIT = 0
	DECLARE @IsMyanmarOdds_source BIT = 0
	
	SET @IsMyanmarOdds_destination = dbo.fn_IsMyanmarOddsBySite(@Site)
	
	SET @IsMyanmarOdds_source = dbo.fn_IsMyanmarOdds (@ExistingCustid)
		
	IF @IsMyanmarOdds_destination <> @IsMyanmarOdds_source and @IsMyanmarOdds_source = 1
	BEGIN
		SELECT @ErrMsg = 'Cannot copy Super from Myanmar Odds site(s) to ' + @Site +'.',@ErrCode = 200								
		RETURN		
	END	

	IF @IsMyanmarOdds_destination <> @IsMyanmarOdds_source and @IsMyanmarOdds_destination = 1
	BEGIN
		SELECT @ErrMsg = 'Cannot copy Super from ' + @_Site +' to Myanmar Odds site(s).',@ErrCode = 201								
		RETURN		
	END

	--Check cross-site:
	IF ( @source_SiteLabel IN ('789y','MBC','IBC','777') OR @SiteLabel IN ('789y','MBC','IBC','777') )
		AND @SiteLabel<>@source_SiteLabel
	BEGIN
		SELECT	@ErrMsg='Cannot copy Super from ' + @_Site + ' (' + @source_SiteLabel + ') to ' + @Site + ' (' + @SiteLabel + ')',
				@ErrCode=99
		RETURN
	END

	DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT


	IF @IsExists = 1
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This username is not available.'								
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							end		
				,@ErrCode = 201
		RETURN		
	END	
	
	IF @SiteLabel  = '789y'	
	BEGIN
		IF EXISTS(SELECT 1 FROM Acc_SuperPrefix WITH(NOLOCK)
			WHERE GroupName IN ('ACCUT','ACCYEN789','ACCYEN889','ACCTEST')
				AND Prefix = LEFT(@username,2)
				AND AllowNewSuper = 0
			)
		BEGIN
			SELECT @ErrMsg =  'The selected username prefix is not allowed for new supers anymore.',
				@ErrCode = 205
			RETURN		
		END	
	END
	
	--Not allow to create a IMBC customer from MBC customer and and vice versa
	IF (@_Site = 'IMBC' OR @Site = 'IMBC') AND @_Site <> @Site
	BEGIN
		SELECT @ErrMsg = 'Not allow to copy IMBC super setting to others and vice versa!',@ErrCode = 204								
		RETURN	
	END
	
	
	IF @roleid <> 4
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		RETURN		
	END		 		
	
	IF @Enabled = 0
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This account was disabled!' + ' (' + @existingUsername + ')'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60020,@Language) + ' (' + @existingUsername + ')'
								END, 
						@ErrCode = 203
		RETURN		
	END		 
	SELECT @startRun = getdate()
	
	BEGIN TRY
		--INSERT GENERAL INFORMATION OF CUSTOMER
		INSERT INTO dbo.customer
			(firstname
			,lastname
			,address
			,postal
			,city
			,state
			,country
			,phone
			,mobilephone
			,fax
			,email
			,birthday
			,refcode1
			,refcode2
			,remark
			,creatdate
			,creator
			,username
			,currency
			,userpwd				
			,roleid
			,srecommend 
			,mrecommend
			,recommend
			,ugroup		
			,site		
			,pwdexpiry
			,important
			)
		SELECT
			@firstname
			,@lastname
			,'-' AS address
			,'-' AS postal
			,'-' AS city
			,'-' AS state
			,'-' AS country
			,@phone
			,@mobilephone
			,@fax
			,'-' AS email
			,NULL AS birthday
			,NULL AS refcode1
			,NULL AS refcode2
			,NULL AS remark
			,GETDATE() AS creatdate
			,@creator
			,@username
			,currency
			,@userpwd				
			,4 AS roleid
			,0 as srecommend		
			,0 AS mrecommend
			,0 AS recommend 
			,ugroup		
			,@site				
			,NULL
			,0 as important
		FROM dbo.customer WITH(NOLOCK)
		WHERE custid=@ExistingCustid		

		SET @Custid = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
						end
			,@ErrCode = 103			
		RETURN
	END	CATCH
	
	--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Ins  @Custid, 0, 4, @ErrCode, @ErrMsg
	--IF @ErrCode <> 0
--	BEGIN
--			SELECT @ErrMsg = CASE @Language 
--							    WHEN 'E' THEN 'Create customer failed. Please try again.'
--							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
--						    END
--				, @ErrCode = 107
--		 -- ROLLBACK MANUALLY
--			DELETE FROM Customer WITH (ROWLOCK) WHERE custId = @CustID
			
--			RETURN
--	END
	
	BEGIN TRY
		SET @srecommend = @CustID
		UPDATE Customer WITH (ROWLOCK, UPDLOCK) 
		SET srecommend = @CustID 
		WHERE custId = @CustID  
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 104
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID	
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		
		RETURN
	END	CATCH
			
	BEGIN TRY
		-- insert CustSuper info
		DECLARE @MaxMember INT, @MaxMemberLog VARCHAR(50)
		SELECT @MaxMember = CASE WHEN @SiteLabel = '789y' THEN 20000 ELSE -1 END
		SELECT @MaxMemberLog = CASE WHEN @SiteLabel = '789y' THEN '20000' ELSE 'Unlimited' END

		INSERT INTO CustSuper(custId,IsInternal, TransferOption, LimitPerIP, SelectedBetting,MaxMember,SiteDBGroupID)  
		SELECT	@CustID, @IsInternal, TransferOption, LimitPerIP, SelectedBetting, @MaxMember,@SiteDBGroupID	
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
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		
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
				)
		 SELECT
				@CustID
				,@username
				,currency
				,4 AS roleid
				,@srecommend
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
		FROM dbo.custinfo WITH(NOLOCK)
		WHERE custid=@ExistingCustid  
		
		IF @CreditRM > 300000
		BEGIN
			INSERT INTO SuspiciousCust (CustID, NotifyStatus1, NotifyStatus2)
			SELECT @CustId, 1, 0
		END

	END TRY	
	BEGIN CATCH	
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
					
		-- ROLLBACK MANUALLY			
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  
		DELETE FROM SuspiciousCust WITH(ROWLOCK) WHERE custId = @CustID 

		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid		
		RETURN
	END CATCH

	
	BEGIN TRY
				EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@Language = @Language,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  
		
		
		RETURN
	END CATCH

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

	BEGIN TRY
		INSERT INTO dbo.CustLoginInfo
		(
		    CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCodeCount,
		    SecurityCode, isForcedChangeSecurityCode, LastChangedSecurityCodeDate,ClosedReason
		)
		VALUES
		(   @custid, NULL, GETDATE(), 1, 0,
		    NULL, @isForcedChangeSecurityCode, NULL,@ClosedReason
		)
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
							
		RETURN	
	END CATCH
	
	BEGIN TRY
		
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT custid, seqNo, bitmapVirtual FROM f_GenerateVirtualSettingBySite (@site,@CustID)
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		RETURN	
	END CATCH		
	
	BEGIN TRY
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
		  
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @Custid
		
		RETURN	
	END CATCH	
		
	BEGIN TRY
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

		INSERT INTO [VRSettingManualUpdAcc](CustID,SportType)		
		SELECT @CustID,43 AS SportType
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
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		--EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @Custid
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM VRCustSetting WITH (ROWLOCK) WHERE custId  =@custid
		DELETE FROM VRSettingManualUpdAcc WITH (ROWLOCK) WHERE CustId = @custid
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
				   ,[LimitDays])
			SELECT @custId, @MinDate, @LimitDays
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


