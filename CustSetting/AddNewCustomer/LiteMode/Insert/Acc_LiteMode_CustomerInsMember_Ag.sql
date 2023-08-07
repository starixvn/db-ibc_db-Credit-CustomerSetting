/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_Ag]
	@custid     INT OUTPUT,
	@firstname  NVARCHAR(50)= '',
	@lastname   NVARCHAR(50)= '',
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50)= '',
	@mobilephone NVARCHAR(50)= '',	
	@fax        NVARCHAR(50)= '',
	
	--Discount	
	@SettingType25 VARCHAR(MAX)= '', --SB
	@SettingType19 VARCHAR(MAX)= '', --LCS
	@SettingType3 VARCHAR(MAX)= '', --LCS
		
	--Bet Setting
	@SettingType26 VARCHAR(MAX)= '', --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2
	@SettingType23 VARCHAR(MAX)= '', --RNG Games
	@SettingType16 VARCHAR(MAX)= '', --SB
		
	--Parlay Max Payout
	@SettingType27 VARCHAR(MAX)= '', --SB Parlay Max Payout
	
	--PT
	@TemplateName NVARCHAR(50) = '',
	@SettingType28 VARCHAR(MAX)= '',-- SB
	@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
	@SettingType18 VARCHAR(MAX)= '',-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	--Log all values group from UI
	@SettingTypeAll VARCHAR(MAX) = '',
	
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0,--Sub-AccountID,
	@credit MONEY,
	@recommend INT,
	@ugroup VARCHAR(5),	
	@SystemID	TINYINT=1,
	
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT,	
	@CreationStatus TINYINT = 0
AS
/*
	Created: 20230717@Johnson  
	Task : Add new member from LiteMode
	DB:  DBCUST/CustDB  
	Original sp: Acc_CustomerInsMember_Ag
	
	Revisions: 
		- 20230717@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType25 = '<Root>
						<R SportType="1" BetType="1" Discount="0.0025" />
						<R SportType="1" BetType="3" Discount="0.005" />
						...
						<R SportType="2" BetType="1" Discount="0.0025" />
					</Root>'
		- @SettingType26 = '<Root>
						<R SportType="1" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						.....
						<R SportType="9902" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
					</Root>'
		- @SettingType27 = '<Root>
						<R SportType="1" BetType="9" SingleMP="1000" Combo2="1000" Combo35="1000" Combo6="1000" />
						<R SportType="99" BetType="1" SingleMP="1000" Combo2="1000" Combo35="1000" Combo6="1000" />
					</Root>'		
		- @SettingType28 = '<Root>
						<R SportType="1" BetType="1" IsLive="0" AgentPT="20" />
						<R SportType="1" BetType="1" IsLive="1" AgentPT="20" />
						....
						<R SportType="99" BetType="9" IsLive="0" AgentPT="20" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" AgentPT="20" />
						<R SportType="44" BetType="1" IsLive="0" AgentPT="20" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" AgentPT="20" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" AgentPT="20" />
						<R SportType="220" BetType="1024" IsLive="0" AgentPT="20" />
						....
						<R SportType="245" BetType="4601" IsLive="0" AgentPT="20" />
					</Root>'				
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()
	
	EXEC [Acc_CheckUM] @CustID = @recommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN
	
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
			@CreatedMode		= 1 , 
			@IsQRCode			= 0 , 
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
	
	DECLARE @_Site VARCHAR(10), @EnableVR BIT, @siteID SMALLINT
	
	SELECT @_Site = c.site,
		@siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend	
	
	DECLARE @transcode bigint, @currency INT, @pwdexpiry datetime, @srecommend INT, @mrecommend INT,	
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
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@_Site)
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
	
    -- MyanmarOdds    
	DECLARE @IsMyanmarOdds BIT = 0,@MyanmarOddsAgent decimal(9,8) = 0 
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
    SELECT @username = rtrim(ltrim(@username))
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
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'You have exceeded your credit limit.'  
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language)
						    END	
			    , @ErrCode = 204
	    return
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Member max credit has been exceeded.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](70009,@Language)
						    END	
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
	
	
    SELECT @pwdexpiry = DATEADD(dd, -1, GETDATE())
   
    --check suspended of Agent 
    IF @Asuspended =1
    BEGIN
	    set @suspended =1
    END
	
	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingType19 = @SettingType19 OUTPUT, --LCS		
		@SettingType3 =  @SettingType3 OUTPUT, --LCS
		@CreationStatus = @CreationStatus,
		@ugroup = @ugroup,
		@IsMyanmarOdds = @IsMyanmarOdds,
		
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
		@SettingType2 = @SettingType2, --SB2, VS
		@SettingType23 = @SettingType23, --RNG Games	
		@SettingType16 = @SettingType16, --Others Games
		@SystemID = @SystemID,
		@CreationStatus  = @CreationStatus,
		
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
		@CreationStatus = @CreationStatus,
		
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
		@SettingType1 = @SettingType1  OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		@SettingType18 = @SettingType18 OUTPUT,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
		@CreationStatus = @CreationStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;
	
	
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
	    @closed = @UplineClosed,
    	
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
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    IF @ErrCode <> 0
	    return	
	
	EXEC Acc_CustomerInfo_Execrep_14
		@custid = @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,	
		@recommend = @recommend,
		@roleid = 1,
		@siteID = @siteID,
		@currency = @currency,
		
		--Discount	
		@SettingType25 = @SettingType25, --SB
		@SettingType19 = @SettingType19, --LCS		
		@SettingType3 = @SettingType3, --Others Games
		-- Myanmar Odds
		@IsMyanmarOdds = @IsMyanmarOdds,
		
		--Bet Setting
		@SettingType26 = @SettingType26, --SB
		@SettingType2 = @SettingType2, --SB2, VS
		@SettingType23 = @SettingType23, --RNG Games
		@SettingType16 = @SettingType16, --Others Games
			
		--Parlay Max Payout
		@SettingType27 = @SettingType27, --SB Parlay Max Payout
		
		--PT
		@SettingType28 = @SettingType28,-- SB
		@SettingType1 = @SettingType1,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		@SettingType18 = @SettingType18,-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
				
		@CreationStatus = @CreationStatus,
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
	
	EXEC dbo.Acc_CustomerInfo_Execrep_01
		@custid = @custid, 
		@srecommend = @srecommend, 
		@mrecommend = @mrecommend, 
		@recommend = @recommend,
		@mode = 'LiteMode'
		
	IF @@Error <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
		DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
		DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
		DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
		DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
		DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
		DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
		DELETE FROM CustCommRate WHERE CustID = @CustID
		DELETE FROM custsetting WHERE CustID = @CustID
		DELETE FROM CustMaxPayoutSetting_Member WHERE CustID = @CustID		

	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	    RETURN
    END
	
	IF @SystemID IN (2, 10) -- ALPHA, Chatbot
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @CreationStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create member fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
							END
					, @ErrCode=216
			
			DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
			DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
			DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
			DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
			DELETE FROM CustCommRate WHERE CustID = @CustID
			DELETE FROM custsetting WHERE CustID = @CustID
			DELETE FROM CustMaxPayoutSetting_Member WHERE CustID = @CustID		
			
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE FROM CustLimitPTSetting WITH (ROWLOCK) WHERE custId =@custid
			RETURN
		END	
	END
	
	SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	
    Declare @LogSPData VARCHAR(MAX)
    --Log customer general info
    SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
    'recommend="'+ COALESCE(CAST(@recommend AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ugroup="'+ COALESCE(CAST(@ugroup AS VARCHAR(5)), SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +   
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +    
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)), SPACE(1)) + '" />'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95094,
		@TrackingValue = @LogSPData,
		@duration = @duration 
		
	 -- Write Log Credit
    DECLARE @LogSPCredit VARCHAR(200)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + ',
    SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
	
	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1225 as '@ActionID',
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
				@ActionID = 1225
		END TRY
		BEGIN CATCH		
			SELECT @LogSPCredit = @LogSPCredit + ', ErrMsg= ' + error_message()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1225
		END CATCH
	END		
	
	--write log product status
	DECLARE @LogDataSP2 VARCHAR(4000)
	
	SET @LogDataSP2 = ''
	
	CREATE TABLE #temSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus,@siteID,@currency)
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

    SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
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
		@ActionID = 1199,
		@TrackingValue = @LogSPData,
		@duration = @duration  

	CREATE TABLE #TmpProductSettingDetail(
		[SettingType] [smallint] ,
		[SportType] [smallint] ,
		[BetType] [smallint] ,
		[IsLive] [bit] ,						
		[Child_DisplayOrder] [int] ,
		GroupID [TINYINT],
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, 
									bettype SMALLINT, 
									playerdiscount DECIMAL(9,8), 									
									discount DECIMAL(9,8),
									GroupID	TINYINT,
									Child_DisplayOrder  INT
									)
									
	DECLARE @BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY,
		GroupID			  TINYINT,
		Child_DisplayOrder  INT
		PRIMARY KEY(sporttype, Bettype)
	);

	DECLARE @tblPT18 TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			AgentPT			SMALLMONEY,
			GroupID			  TINYINT,
			Child_DisplayOrder  INT
			)

	DECLARE @tblPT28 TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			AgentPT			SMALLMONEY,
			GroupID			  TINYINT,
			Child_DisplayOrder  INT
			)
	INSERT INTO #TmpProductSettingDetail(SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder)
	SELECT SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus,@siteID,@currency)	
	
	DECLARE @xml XML
	
	--commission
	SELECT @xml = CONVERT(XML,@SettingType25)
	
	INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
		T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount
	FROM   @xml.nodes('/Root/R') T(c) 
	
	
	SELECT @xml = CONVERT(XML,@SettingType3)
	
	INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
		T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount
	FROM   @xml.nodes('/Root/R') T(c) 
	
	SELECT @xml = CONVERT(XML,@SettingType19)
	
	INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
		T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount
	FROM   @xml.nodes('/Root/R') T(c) 
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder
	FROM @NewDiscountTbl b
		INNER JOIN #TmpProductSettingDetail p ON b.SportType = p.SportType
												AND b.BetType = p.BetType
	WHERE p.SettingType IN (25,19,3)	
		
	--Bet setting
	SELECT @xml = CONVERT(XML,@SettingType2)

	INSERT INTO @BetSetting(SportType, 
		BetType, 
		MinBet, 
		MaxBet, 
		MaxPerMatch)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
		T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
		T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch		
	FROM  @xml.nodes('/Root/R') T(c)
	
	SELECT @xml = CONVERT(XML,@SettingType16)

	INSERT INTO @BetSetting(SportType, 
		BetType, 
		MinBet, 
		MaxBet, 
		MaxPerMatch)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
		T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
		T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch		
	FROM  @xml.nodes('/Root/R') T(c)
	
	SELECT @xml = CONVERT(XML,@SettingType23)
		
	INSERT INTO @BetSetting(SportType, 
		BetType, 
		MinBet, 
		MaxBet, 
		MaxPerMatch, 
		MaxPerNumber)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
		T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
		T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
		T.c.query('.').value('(R/@MaxPerNumber)[1]', 'money') AS MaxPerNumber
	FROM  @xml.nodes('/Root/R') T(c) 
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder
	FROM @BetSetting b
		INNER JOIN #TmpProductSettingDetail p ON b.SportType = p.SportType
												AND b.BetType = p.BetType
	WHERE p.SettingType IN (2,16,23)	
	
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
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
	FROM  @xml.nodes('/Root/R') T(c)
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder
	FROM @tblPT28 b
		INNER JOIN #TmpProductSettingDetail p ON b.SportType = p.SportType
												AND b.BetType = p.BetType
												AND b.IsLive = p.IsLive
	WHERE p.SettingType IN (28)
	
	--PT
	SELECT @xml = CONVERT(XML, @SettingType1)
				
	INSERT INTO @tblPT18(
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
	
	SELECT @xml = CONVERT(XML, @SettingType18)
				
	INSERT INTO @tblPT18(
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
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder
	FROM @tblPT18 b
		INNER JOIN #TmpProductSettingDetail p ON b.SportType = p.SportType
												AND b.BetType = p.BetType
												AND b.IsLive = p.IsLive
	WHERE p.SettingType IN (1,18)	
	
	
	--log all settings
	SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '">' 
			+ '<Group ID="1">'--SB
			+ '<Discount GroupType="150">' 
				+ COALESCE(CAST((SELECT SportType,BetType,PlayerDiscount,Discount as AgentDiscount
						FROM @NewDiscountTbl
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '<BetSetting GroupType="151">'
				+ COALESCE(REPLACE(REPLACE(@SettingType26,'<Root>',''),'</Root>',''), SPACE(1)) --SB
				+ COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM	
						FROM @BetSetting
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))--SB2
			+ '</BetSetting>'
			+ '<ParlayMaxPayout GroupType="152">' 
				+ COALESCE(REPLACE(REPLACE(@SettingType27,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</ParlayMaxPayout>'	
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
									BetType, 
									IsLive,
									AgentPT
							FROM @tblPT28
							WHERE 1= CASE WHEN SportType = 99 AND Bettype = 9 THEN 0 ELSE 1 END 
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)), SPACE(1))--SB	
			+ '</PT>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
									BetType, 
									IsLive,									
									AgentPT
							FROM @tblPT28
							WHERE SportType = 99 AND Bettype = 9							
							FOR XML RAW('R')
							) as VARCHAR(max)), SPACE(1))--SB MixParlay mix sports
			+ '</PT>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
								BetType, 
								IsLive,								
								AgentPT
						FROM @tblPT18
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))--SB2
			+ '</PT>'
			+ '</Group>'	
			+ '<Group ID="2">'--RnG Games
			+ '<BetSetting GroupType="154">'
				+ 	COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM, MaxPerNumber	
						FROM @BetSetting
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</BetSetting>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT
						FROM @tblPT18
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'			
			+ '</Group>'
			+ '<Group ID="3">'--LCS
			+ '<Discount GroupType="156">' 
				+ COALESCE(CAST((SELECT SportType,BetType,PlayerDiscount,Discount as AgentDiscount
						FROM @NewDiscountTbl
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT
						FROM @tblPT18						
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '</Group>'
			+ '<Group ID="4">'--LCS
			+ '<Discount GroupType="156">' 
				+ COALESCE(CAST((SELECT SportType,BetType,PlayerDiscount,Discount as AgentDiscount
						FROM @NewDiscountTbl
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '<BetSetting GroupType="157">'
				+ 	COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM	
						FROM @BetSetting
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</BetSetting>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT
						FROM @tblPT18
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'		
			+ '</Group>'
			+ '</Root>'
			
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95095,
		@TrackingValue = @LogSPData,
		@duration = @duration  		
		
	--Log UI settings
	SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '">' 
						+ COALESCE(@SettingTypeAll,SPACE(1))
						+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95096,
		@TrackingValue = @LogSPData,
		@duration = @duration			
END	