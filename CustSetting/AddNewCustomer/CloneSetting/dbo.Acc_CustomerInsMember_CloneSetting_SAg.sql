/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_SAg]
	@Custid INT OUTPUT
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
	,@SubAccountID INT=0	
	,@Language VARCHAR(2)= 'E'
	,@IP VARCHAR(15)=''		
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
	,@SystemID TINYINT=1
AS
/*  
 Created by: Dan  
 Date:20120207
 Original: dbo.Agm_CustomerInsMember_Ag, Acc_CustomerInsMember_SAg
 Task: Add new master from existing master
	(#436.2 IRP - AgeSite - Search&Copy feature to feature to facilitate downline creation) 
 
 DB: DBCUST/CustDB  
  
 History:  
	- 20120323 @Dan: check roleid and the super of existing master before copying 
	- 20120820@Dan: add 3 fields in custinfo table (VS)
	- 20120829@Dan: isSync status for 3 products - Casino, Bingo and LiveCasino will not be cloned
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
	
 Explanation's Param:  
	• @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	• @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON
	
--20140619@Johnson: Check IP to create downline-----------------
	DECLARE @isValidIP bit
	
	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME
	
	SET @CreateDate = GETDATE()
	
	EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032, @Language)
					end,
				@ErrCode = 1001	
		return
	END
--End check IP--------------------------------------------------

	DECLARE @startRun DATETIME
		,@endRun DATETIME
		,@duration INT
		,@pwdexpiry DATETIME
		,@mrecommend INT
				
	IF EXISTS (SELECT 1 FROM dbo.customer WITH(NOLOCK) WHERE username=@username OR username2=@username
			UNION ALL
				SELECT 1 FROM dbo.custsub WITH(NOLOCK) WHERE username= @username
		)
	BEGIN		
		Select @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This username is not available.'								
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							end		
				,@ErrCode = 201
		return		

	END	


	-- Check role and master of existing agent
	DECLARE @existingUsername VARCHAR(30),@roleid tinyint, @existingSrecommend INT, @Enabled BIT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @existingSrecommend = ISNULL(srecommend,0), @Enabled = ISNULL(Enabled, 0)
	FROM dbo.custInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	IF ( NOT (@roleid = 3 AND @existingSrecommend = @srecommend))
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		return		

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

	--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)  
	--20081218_By_AhWan: KER - 1238537  
	--20090112_Wan: unblock KM 194354  
	--20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR   
	IF @srecommend = 726582  
	BEGIN  
	 Select @ErrMsg = CASE @Language   
		  WHEN 'E' THEN 'Sorry, cannot create master.'  
		  ELSE [dbo].[f_Get_MsgNamebyMsgID](40012,@Language) 
		 end,@ErrCode = 100   	  	
	   
	 return  
	END 		

	--CREDIT CHECK

	DECLARE @Credit_AllOtherMaster MONEY, @Credit_SAg MONEY
	SELECT @Credit_AllOtherMaster = ISNULL(SUM(credit), 0) 
	FROM custinfo AS ci WITH (NOLOCK) 
	WHERE srecommend = @srecommend and RoleID = 3  
  
	SELECT @Credit_SAg = ISNULL(credit, 0)		
	FROM CustInfo as ci with (NOLOCK) 
	WHERE CustID = @srecommend

	IF @Credit_AllOtherMaster + @Credit > @Credit_SAg
	BEGIN  
		SET @ErrMsg = CASE @Language   
		  WHEN 'E' THEN 'Sorry, credit update is not successful, You have exceeded your super agent credit.'  
		  ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
		 END   
		SELECT @ErrCode = 101  
		RETURN  
	END  

		
	SELECT @pwdexpiry = dateadd(dd, 30, getdate())
		,@startRun = getdate()
	
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
		,3 AS roleid
		,srecommend		
		,0 AS mrecommend
		,0 AS recommend 
		,ugroup		
		,site				
		,@pwdexpiry
	FROM dbo.customer WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	SET @Custid = SCOPE_IDENTITY()
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
						end
			,@ErrCode = 103
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer WITH(ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
	
	SET @mrecommend = @custid
	UPDATE Customer WITH (ROWLOCK, UPDLOCK) 
	SET mrecommend = @custid 
	WHERE custId = @CustID  
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 104
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer WITH(ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
			
	-- insert CustMaster info
	INSERT INTO CustMaster(custId, DisableAutoMPT, IsInternal, TransferOption)  
	SELECT @CustID,
			DisableAutoMPT,
			IsInternal,
			TransferOption
	FROM dbo.CustMaster WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	IF @@ERROR <> 0  
	BEGIN  
		SELECT @ErrMsg = CASE @Language   
		   WHEN 'E' THEN 'Create customer failed. Please try again.'  
		   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		  END,  
		@ErrCode = 105  

		-- ROLLBACK MANUALLY  

		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  
		 
		RETURN  
	END  

	DECLARE @enableUpline bit, @doubleCommLosingUpline bit, @virtualmultiplier SMALLMONEY
	-- get autosuspend's upline
	DECLARE @autosuspend BIT,
		@autosuspend2 BIT

	select @enableUpline = isnull(enabled,0), @doubleCommLosingUpline = DoubleCommLosing,
		 @autosuspend = ISNULL(autosuspend, 0),
		 @autosuspend2 = ISNULL(autosuspend2, 0),
		 @virtualmultiplier = ISNULL(virtualmultiplier,1)
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
			@custid
			,@username
			,currency
			,3 AS roleid
			,srecommend
			,@mrecommend
			,0 as recommend
			,0 AS dangercust
			,@autosuspend AS autosuspend
			,@autosuspend2 as autosuspend2
			,reject
			,@Credit AS Credit
			,closed
			,MatchLimit
			,@virtualmultiplier
			,maxpermatch
			,maxpermatch2
			,maxpermatch3
			,maxpermatch5
			,maxpermatch8
			,maxpermatch10
			,maxpermatch11
			,maxpermatch12
			,maxpermatch99
			,@enableUpline as Enabled           
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
			,@doubleCommLosingUpline as doubleCommLosing
			,1
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
        
	IF @@error <> 0
	BEGIN 	
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
					
		-- ROLLBACK MANUALLY			
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  

		RETURN
	END

	--insert default value from upline
	EXEC dbo.Acc_CustomerWinLimitIns @CustId = @custid
		, @UplineId = @ExistingCustid
		, @IP = @IP
		, @UserId = @Creator
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END
	
		EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			
			@ErrCode = @ErrCode OUTPUT
	
	IF @ErrCode > 0 
	BEGIN
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end

		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID  
		
		RETURN
	END

	DECLARE	@UplineSecurityCode			VARCHAR(50)
		  , @isForcedChangeSecurityCode	BIT,@ClosedReason TINYINT=0,@Closed BIT
	SELECT TOP 1 @Closed=Closed FROM custInfo WITH(NOLOCK) WHERE custid=@ExistingCustid

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
	)
	VALUES
	(
	    @custid, NULL, GETDATE(), 1, 0, NULL,
	    @isForcedChangeSecurityCode, NULL,@ClosedReason
	)
	
	IF @@ERROR<>0
	BEGIN
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
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE CustID =@CustID		
		DELETE FROM dbo.CustGameType WITH(ROWLOCK) WHERE CustID =@CustID					
		DELETE FROM dbo.Custoverridegame WITH(ROWLOCK) WHERE CustID =@CustID					
		DELETE FROM custsettingGame WITH(ROWLOCK) where custid =  @custid
		DELETE FROM P2PGroupComm WITH(ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH(ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride WITH(ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH(ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting WITH(ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting3rd WITH(ROWLOCK) WHERE custid =  @CustID				
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID  		
		
		RETURN	
	END	
	
	BEGIN TRY
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
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
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID					
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE CustID =@CustID		
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID  
							
		RETURN	
	END CATCH				
	
	BEGIN TRY
		INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy)
		SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy
		FROM Customer ci WITH(NOLOCK)
		WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			AND ci.srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		
		IF @@ROWCOUNT <> 0 
		BEGIN
			SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
			EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 601,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
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
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID					
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE CustID =@CustID		
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE custId = @CustID  
		DELETE FROM dbo.CustVirtualSetting WITH(ROWLOCK) WHERE custId = @CustID  
							
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

	'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
	'mrecommend="'+ coalesce(cast(@mrecommend as VARCHAR(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
	'CopiedFomUsername="'+c.username+'" '+
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as VARCHAR(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as VARCHAR(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as VARCHAR(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 630,
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
		'credit="'+ coalesce(cast(@Credit as VARCHAR(50)),space(1)) + '" ' +	
		'mrecommend="'+ coalesce(cast(@mrecommend as VARCHAR(50)),space(1)) + '" ' +	
		'IP="'+ coalesce(cast(@IP as VARCHAR(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as VARCHAR(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as VARCHAR(10))+'" '+
		'CopiedFomUsername="'+c.username+'" '+
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as VARCHAR(30)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as VARCHAR(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as VARCHAR(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 630,
			@TrackingValue = @LogSPData,
			@duration = @duration		
	END CATCH
		
	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_SAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_SAg] TO [bodbExtAccNet]
GO