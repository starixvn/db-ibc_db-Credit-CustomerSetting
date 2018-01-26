/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE [CustDB]
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_Com]
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
AS
/*  
 Created by: Elodie  
 Date:20131025
 Original: 
 Task: Add new super from existing super [Redmine:#5456]
 DB: DBCUST/CustDB  
  
 History:  
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
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
		,@endRun DATETIME
		,@duration INT
		,@srecommend INT
	
	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME
	
	SET @CreateDate = GETDATE()
		
	
	IF EXISTS (SELECT 1 FROM dbo.customer WITH(NOLOCK) WHERE username=@username OR username2=@username
			UNION ALL
				SELECT 1 FROM dbo.custsub WITH(NOLOCK) WHERE username= @username
		)
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This username is not available.'								
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							end		
				,@ErrCode = 201
		return		

	END	

	-- Check role of existing super
	DECLARE @existingUsername VARCHAR(30),@roleid tinyint, @Enabled BIT, @currency INT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @Enabled = ISNULL(Enabled, 0), @currency = currency
	FROM dbo.CustInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	-- For Myanmar Odds
	DECLARE @IsMyanmarOdds_destination BIT = 0
	DECLARE @IsMyanmarOdds_source BIT = 0
	
	IF @Site = '766666' 
		SET @IsMyanmarOdds_destination = 1
	
	SET @IsMyanmarOdds_source = dbo.fn_IsMyanmarOdds (@ExistingCustid)
		
	IF @IsMyanmarOdds_destination <> @IsMyanmarOdds_source
	BEGIN
		SELECT @ErrMsg = 'Cannot copy super ' + @existingUsername + ' since amongs the new and old sites, one has % Odds.',@ErrCode = 200								
		RETURN		

	END			
	
	--Not allow to create a IMBC customer from MBC customer and and vice versa
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.Customer WITH(NOLOCK)
	WHERE CustID = @ExistingCustid
	
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
		RETURN
	END	CATCH
			
	BEGIN TRY
		-- insert CustSuper info
		INSERT INTO CustSuper(custId, AutoIBCPositionTaking_Tote, AutoIBCPositionTaking_Fixed, AutoIBCPT151_AU, AutoIBCPT152_UK, AutoIBCPT152_AU, AutoIBCPT153_AU, IsInternal, TransferOption, LimitPerIP, SelectedBetting)  
		SELECT	@CustID, AutoIBCPositionTaking_Tote, AutoIBCPositionTaking_Fixed, AutoIBCPT151_AU, AutoIBCPT152_UK, AutoIBCPT152_AU, AutoIBCPT153_AU, @IsInternal, TransferOption, LimitPerIP, SelectedBetting
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
		RETURN  
	END CATCH
	
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
				,reject
				,credit
				,closed
				,MatchLimit
				,VirtualMultiplier
				,maxpermatch
				,maxpermatch2
				,maxpermatch3
				,maxpermatch5
				,maxpermatch8
				,maxpermatch10
				,maxpermatch11
				,maxpermatch12
				,maxpermatch99
				,Enabled           
				,maxpermatch151
				,maxpermatch201
				,DisableHorseRacing
				,DisableFinancial
				,DisableCasino
				,SyncCasino           
				,DisableOutright
				,DisableOpenTote
				,maxpermatch151_OT
				,MaxPerMatch99MP
				,DisableBingo
				,DisableNumber
				,maxpermatch161
				,SyncBingo
				,MaxPerBall161
				,MaxPerMatch151_AU
				,MaxPerMatch152_UK
				,MaxPerMatch152_AU
				,MaxPerMatch153_AU
				,Disable151_AU
				,Disable152_UK
				,Disable152_AU
				,Disable153_AU
				,MaxTransferP2P
				,IsAutoResetP2P
				,DisableP2P
				,DisableFunP2P
				,DisableLiveCasino
				,SyncLiveCasino
				--,DisableVirtualSports
				--,HideVirtualSports
				--,maxpermatch180
				--,maxpermatch181
				--,maxpermatch183--dom
				--,maxpermatch185--dom
				--,maxpermatch182
				--,maxpermatch184
				--,maxpermatch186
				,isAutoResetLiveCasino
				,MaxWinLiveCasino
				,DoubleCommLosing
				,DisableCasinoBonus
				,DisableHRFixedOdds
				,maxpermatch154
				,HideKeno
				,DisableEsports
				,HideGoldDeluxe
				,DisableGoldDeluxe
				,HideColossusBet
				,DisableColossusBet
				,DisableSuperLive
				,MaxPerMatch1MP
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
				,reject
				,@Credit AS Credit
				,closed
				,MatchLimit
				,0 AS VirtualMultiplier
				,maxpermatch
				,maxpermatch2
				,maxpermatch3
				,maxpermatch5
				,maxpermatch8
				,maxpermatch10
				,maxpermatch11
				,maxpermatch12
				,maxpermatch99
				,Enabled           
				,maxpermatch151
				,maxpermatch201
				,DisableHorseRacing
				,DisableFinancial
				,DisableCasino
				,0 as SyncCasino           
				,DisableOutright
				,DisableOpenTote
				,maxpermatch151_OT
				,MaxPerMatch99MP
				,DisableBingo
				,DisableNumber
				,maxpermatch161
				,0 as SyncBingo
				,MaxPerBall161
				,MaxPerMatch151_AU
				,MaxPerMatch152_UK
				,MaxPerMatch152_AU
				,MaxPerMatch153_AU
				,Disable151_AU
				,Disable152_UK
				,Disable152_AU
				,Disable153_AU
				,MaxTransferP2P
				,IsAutoResetP2P
				,DisableP2P
				,DisableFunP2P
				,DisableLiveCasino
				,0 as SyncLiveCasino
				--,DisableVirtualSports
				--,HideVirtualSports
				--,maxpermatch180
				--,maxpermatch181
				--,maxpermatch183--dom
				--,maxpermatch185--dom
				--,maxpermatch182
				--,maxpermatch184
				--,maxpermatch186
				,isAutoResetLiveCasino
				,MaxWinLiveCasino
				,doubleCommLosing
				,DisableCasinoBonus
				,DisableHRFixedOdds
				,maxpermatch154
				,HideKeno
				,DisableEsports
				,HideGoldDeluxe 
				,DisableGoldDeluxe
				,HideColossusBet
				,DisableColossusBet
				,DisableSuperLive
				,MaxPerMatch1MP
		FROM dbo.custinfo WITH(NOLOCK)
		WHERE custid=@ExistingCustid  
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

		RETURN
	END CATCH

	BEGIN TRY
		--insert default value from upline
		EXEC dbo.Acc_CustomerWinLimitIns @CustId = @custid
			, @UplineId = @ExistingCustid
			, @IP = @IP
			, @UserId = @Creator
			, @ErrCode = @ErrCode OUTPUT
			, @ErrMsg = @ErrMsg OUTPUT

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
		DELETE FROM custInfo WITH(ROWLOCK) WHERE custId = @CustID  
	END CATCH

	
	BEGIN TRY
				EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			@Language = @Language,
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
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID  
		
		RETURN
	END CATCH

    DECLARE @isForcedChangeSecurityCode BIT = 0, @ClosedReason TINYINT=0,@Closed BIT
	SELECT TOP 1 @Closed=Closed FROM custInfo WITH(NOLOCK) WHERE custid=@ExistingCustid

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
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID									
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE custId = @CustID    
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID
							
		RETURN	
	END CATCH
	
	BEGIN TRY
		
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT	@Custid, 
				seqNo,
				(
					SELECT TOP 1 bitmap
					FROM dbo.f_GenerateVirtualSetting_multiple(0x00, CONVERT(VARCHAR(MAX), virtualXML))
				) AS virtualXML
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
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID									
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE custId = @CustID    
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		RETURN	
	END CATCH		
	
	BEGIN TRY
		INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy)
		SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy
		FROM Customer ci WITH(NOLOCK)
		WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		
		IF @@ROWCOUNT <> 0 
			BEGIN
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 600,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0
	            
				FROM (        
						-- Soccer 
						SELECT TOP 1 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 1 sporttype, MaxTurnOver,TOCurrency
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
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID									
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE custId = @CustID    
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @Custid
		
		RETURN	
	END CATCH	
		
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
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
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
		'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
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
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_Com] TO [bodbAdminNet]
GO

