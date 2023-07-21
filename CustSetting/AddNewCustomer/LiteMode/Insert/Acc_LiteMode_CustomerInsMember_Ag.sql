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
		
	--Bet Setting
	@SettingType26 VARCHAR(MAX)= '', --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2
	@SettingType23 VARCHAR(MAX)= '', --RNG Games
		
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
	@closed BIT,
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
						<R SportType="1" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="1" BetType="1" IsLive="1" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="99" BetType="9" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="44" BetType="1" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						<R SportType="220" BetType="1024" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
						....
						<R SportType="245" BetType="4601" IsLive="0" SuperPT="90" IsAuto="0" AutoPT="0" MasterPT="0" MinPT="0" />
					</Root>'				
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()
	/*
	EXEC [Acc_CheckUM] @CustID = @recommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN
	
	DECLARE @isAllowed  BIT
	
	
	EXEC Acc_ProblemAccountLimitDownlineCheck
		@custid = @recommend,
		@isAllowed = @isAllowed OUTPUT
	
	IF @isAllowed = 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
					WHEN 'E' THEN 'Sorry, you can only create 5 members per day, please try again tomorrow.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language)
				end,
			@ErrCode = 1002
	return
	END
	
	DECLARE @mrecommend int
-----END: 20180703@viet: normal agent can create upto 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit-member each minute. Normal agent can open up to 10 members per minute
	DECLARE @_Site VARCHAR(10), @EnableVR BIT
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @recommend
	
	DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0 , @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@_Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.recommend = @recommend
									AND c.roleid = 1
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056	
			return
		END
	END
		
	--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP BIT
		
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

	--Check Limit max members creation per Super
	IF @SystemID <> 1
	BEGIN
		EXEC Age_MaxMemberLimitBySuperCheck @AgentId = @recommend, @Language = @Language, @ErrMsg = @ErrMsg OUTPUT, @ErrCode = @ErrCode OUTPUT
		IF @ErrCode <> 0 RETURN
	END
	
	DECLARE @transcode bigint, @currency INT, @pwdexpiry datetime, @srecommend INT,
	
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
	    @matchlimit SMALLMONEY,
		@Success BIT
		
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
*/
	 /* 20130403@Jamie: Check Recommend <> MRecommend AND <> Srecommend OR NOT*/
 /*   IF (@recommend = @mrecommend) OR (@recommend = @srecommend)
    BEGIN
	    SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Invalid user'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						    END,
			    @Success = 0, @ErrCode = 350
	    RETURN	
    END
	
	 --Use maxcredit in CustAgent table 
    SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) FROM custAgent WITH(NOLOCK)  WHERE CustID = @recommend

    SELECT @ErrCode = 0
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsValid BIT
     -- MyanmarOdds
    
	DECLARE @IsMyanmarOdds BIT = 0,@MyanmarOddsAgent decimal(9,8) = 0 
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	BEGIN
	   SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'The selected group is not allowed for this site'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40055,@Language)
						    END,
			    @Success = 0, @ErrCode = 40055
			    
		
	    RETURN	
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
    SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END		
			    , @success = 0, @ErrCode = 201
	    RETURN
    END	
	*/
END	