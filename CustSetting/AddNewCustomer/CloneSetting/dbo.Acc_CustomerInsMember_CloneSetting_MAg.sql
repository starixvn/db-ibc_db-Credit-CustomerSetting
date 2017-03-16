/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" IsNested = 0></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_MAg]
	@Custid int output
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
	,@SubAccountID int=0	
	,@Language varchar(2)= 'E'
	,@IP varchar(15)=''		
	,@ErrCode int = 0 output
	,@ErrMsg nvarchar(4000) = '' output
AS
/*  
 Created by: Dan  
 Date:20120207
 Original: dbo.Agm_CustomerInsMember_Ag, Acc_CustomerInsMember_MAg
 Task: Add new agent from existing agents 
	(#436.2 IRP - AgeSite - Search&Copy feature to feature to facilitate downline creation) 
 
 DB: DBCUST/CustDB
  
 History:  
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
	
 Explanation's Param:  
	• @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	• @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON

--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP bit
	
	EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = case @Language 
						when 'E' then 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
--End check IP--------------------------------------------------

	DECLARE @startRun datetime
		,@endRun datetime
		,@duration int
		,@pwdexpiry datetime
		,@recommend int		
	
	IF EXISTS (SELECT 1 FROM dbo.customer WITH(NOLOCK) WHERE username=@username OR username2=@username
			UNION ALL
				SELECT 1 FROM dbo.custsub WITH(NOLOCK) WHERE username= @username
		)
	BEGIN		
		Select @ErrMsg = case @Language 
								when 'E' then 'This username is not available.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							end		
				,@ErrCode = 201
		return		

	END	


	-- Check role and master of existing agent
	DECLARE @existingUsername varchar(30),@roleid tinyint, @existingMrecommend int, @Enabled BIT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @existingMrecommend = ISNULL(mrecommend,0), @Enabled = ISNULL(Enabled, 0)
	FROM dbo.CustInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid

	
	IF ( NOT (@roleid = 2 AND @existingMrecommend = @mrecommend))
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user ' + '(' + @existingUsername + ')!'
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

	--NOT allow masters under KH, KM, KR to create agents
	--Requested by wan 17-Jan-2007
	--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
	--20081218_By_AhWan: KER - 1238537
	--20090112_Wan: unblock KM 194354
	--20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
	if exists (select 1 from custinfo with (nolock) where custid = @mrecommend and srecommend  = 726582)
	BEGIN	
		Select @ErrMsg = case @Language 
								when 'E' then 'Sorry, cannot create agent.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40013,@Language)
							end,
			@ErrCode = 100
		return
	END

	--CREDIT CHECK
	DECLARE @Credit_AllOtherAgent MONEY, @Credit_MAg MONEY
	
	SELECT @Credit_MAg = ISNULL(credit, 0)		
	FROM CustInfo as ci with (NOLOCK) 
	WHERE CustID = @mrecommend


	SELECT @Credit_AllOtherAgent = ISNULL(SUM(credit), 0) 
	FROM custinfo AS ci WITH (NOLOCK) 
	WHERE mrecommend = @mrecommend and RoleID = 2
		

	IF @Credit_AllOtherAgent + @Credit >@Credit_MAg
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, credit update is not successful, You have exceeded your master credit.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](70011,@Language)
						END,
			@ErrCode = 101
		return
	END
	
	-- maxcredit 
	if (isnull(@maxcredit ,0) > @credit )
	BEGIN 
		Select @ErrMsg = case @Language
			when 'E' then 'Sorry, credit update is not successful, You have exceeded your agent credit.'  
			ELSE [dbo].[f_Get_MsgNamebyMsgID](70012,@Language) 
		 end,  
	  @ErrCode = 102  
	 return  
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
		,2 AS roleid
		,srecommend		
		,mrecommend
		,0 AS recommend 
		,ugroup		
		,site				
		,@pwdexpiry
	FROM dbo.customer WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	SET @Custid = SCOPE_IDENTITY()
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 103
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
	
	SET @recommend = @custid
	UPDATE Customer WITH (ROWLOCK, UPDLOCK) 
	SET recommend = @custid 
	WHERE custId = @CustID  
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 104
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
			
	-- insert CustAgent info
	INSERT INTO CustAgent(custId, MaxCredit, IsInternal, TransferOption, Site)
	SELECT @CustID,
			@MaxCredit,
			IsInternal,
			TransferOption,
			Site
	FROM dbo.CustAgent WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	IF @@ERROR <> 0  
	BEGIN  
		SELECT @ErrMsg = CASE @Language   
		   WHEN 'E' THEN 'Create customer failed. Please try again.'  
		   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		  END,  
		@ErrCode = 105  

		-- ROLLBACK MANUALLY  

		DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  
		 
		RETURN  
	END  

	DECLARE @enableUpline bit, @doubleCommLosingUpline bit, @virtualmultiplier SMALLMONEY
	Declare @autosuspend BIT,
			@autosuspend2 BIT

	select @enableUpline = isnull(enabled,0), @doubleCommLosingUpline = DoubleCommLosing,
		@autosuspend = ISNULL(autosuspend, 0),
		@autosuspend2 = ISNULL(autosuspend2, 0),
		@virtualmultiplier = ISNULL(virtualmultiplier,1)
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
			,DisableVirtualSports
			,HideVirtualSports
			,maxpermatch180
			,maxpermatch181
			,maxpermatch183
			,maxpermatch185
			,maxpermatch182
			,maxpermatch184
			,maxpermatch186
			,isAutoResetLiveCasino
			,MaxWinLiveCasino
			,DoubleCommLosing
			,DisableCasinoBonus
			, DisableHRFixedOdds
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
			,2 AS roleid
			,srecommend
			,mrecommend
			,@recommend
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
			,DisableVirtualSports
			,HideVirtualSports
			,maxpermatch180
			,maxpermatch181
			,maxpermatch183
			,maxpermatch185
			,maxpermatch182
			,maxpermatch184
			,maxpermatch186
			,isAutoResetLiveCasino
			,MaxWinLiveCasino
			,@doubleCommLosingUpline as DoubleCommLosing
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
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
					
		-- ROLLBACK MANUALLY			
		DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID  	    
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
			
			@ErrCode = @ErrCode output
	
	IF @ErrCode > 0 
	BEGIN
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end

		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID  
		
		RETURN
	END
	
	DECLARE	@UplineSecurityCode			VARCHAR(50)
		  , @isForcedChangeSecurityCode	BIT

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
	    SecurityCode, isForcedChangeSecurityCode, LastChangedSecurityCodeDate
	)
	VALUES
	(
	    @custid, NULL, GETDATE(), 1, 0,
	    NULL, @isForcedChangeSecurityCode, NULL
	)
	
	IF @@ERROR<>0
	BEGIN
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
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.CustGameType WITH (ROWLOCK) WHERE CustID = @CustID 
		DELETE FROM dbo.Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID 
		DELETE FROM custsettingGame with (ROWLOCK) where custid =  @custid
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID				
		DELETE FROM custAgent WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID		
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE CustID = @CustID

		RETURN	
	END 
	
	BEGIN TRY
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @mrecommend      
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
		DELETE FROM CustLoginInfo WITH(ROWLOCK) WHERE custid = @Custid
		DELETE FROM dbo.CustWinlimit WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.AgentCommRate WITH(ROWLOCK) WHERE CustID = @CustID
							
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
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 629,
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
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as varchar(30)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 629,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH
			
	SET NOCOUNT OFF
END

