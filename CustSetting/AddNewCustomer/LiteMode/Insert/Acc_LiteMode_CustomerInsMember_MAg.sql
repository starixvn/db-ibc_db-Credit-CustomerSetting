/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_MAg]
	@custid     INT OUTPUT,
	@firstname  NVARCHAR(50),
	@lastname   NVARCHAR(50),
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50),
	@mobilephone NVARCHAR(50),	
	@fax        NVARCHAR(50),

	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in case direct master add new agent

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
	@TemplateName VARCHAR(50) = '',
	@SettingType28 VARCHAR(MAX)= '',-- SB
	@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
	@SettingType18 VARCHAR(MAX)= '',-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	--Log all values group from UI
	@SettingTypeAll VARCHAR(MAX) = '',
	
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0,--Sub-AccountID,
	@credit MONEY,
	@maxcredit MONEY = 0,	
	@mrecommend INT,
	@SystemID	TINYINT=1,
	
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT,
	@CreationStatus TINYINT = 0
AS
/*
	Created: 20230626@Johnson  
	Task : Add new agent from LiteMode
	DB:  DBCUST/CustDB  
	Original sp: Acc_CustomerInsMember_MAg
	
	Revisions: 
		- 20230626@Johnson: initial sp [redmine: #179159]

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
						<R SportType="1" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="1" BetType="1" IsLive="1" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="99" BetType="9" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<R SportType="43" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="44" BetType="1" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="9908" BetType="1201" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<R SportType="169" BetType="3611" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						<R SportType="220" BetType="1024" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
						....
						<R SportType="245" BetType="4601" IsLive="0" MasterPT="40" IsAuto="0" AutoPT="0" AgentPT="30" MinPT="0" />
					</Root>'				
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()
	
	EXEC [Acc_CheckUM] @CustID = @mrecommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN
	
	--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP BIT, @isAllowed BIT
	
	EXEC Acc_ProblemAccountLimitDownlineCheck
			@custid = @mrecommend,
			@isAllowed = @isAllowed OUTPUT
		
	IF @isAllowed = 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
					WHEN 'E' THEN 'Sorry, you can only create 3 agents per day, please try again tomorrow.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](40063, @Language)
				end,
			@ErrCode = 1002
	return
	END
	
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

	DECLARE @Site NVARCHAR(50), @EnableVR BIT
	SELECT @Site = site FROM customer WITH(NOLOCK) WHERE CustID = @mrecommend

	-----20160120@Lukas  ------------------
	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @mrecommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @mrecommend

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
	-----/20160120@Lukas -----------------
	
	--NOT allow masters under KH, KM, KR to create agents
    --Requested by wan 17-Jan-2007
    --NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
    --20081218_By_AhWan: KER - 1238537
    --20090112_Wan: unblock KM 194354
    --20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
    if exists (SELECT 1 FROM custinfo WITH(NOLOCK) WHERE custid = @mrecommend and srecommend  = 726582)
    BEGIN	
	    SELECT @ErrMsg = case @Language 
							    when 'E' then 'Sorry, cannot create agent.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40013,@Language)
						    END,
		    @ErrCode = 100
	    return
    END

    --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @mrecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    if @ErrCode <>0		return 
	
	declare @ErrType VARCHAR(4000)
    declare 
	    @transcode bigint, @currency INT, @pwdexpiry datetime,	
	    @Credit_AllOtherAgent MONEY, @Credit_AllMember MONEY, @Credit_MAg MONEY,
	    @srecommend INT,	 
	    @matchlimit SMALLMONEY,
	    @TransferOption_dec TINYINT,
	    --@Msuspended BIT,
	    @UplineClosed BIT,
	    @DisableOutright BIT,
	    @DoubleCommLosing BIT,
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@autosuspend3 BIT,
		@suspended BIT = 0,
		@DisableSuperLive BIT = 0,
		@DangerMaster TINYINT = 0,
		@DangerMaster2 TINYINT = 0,
		@DangerMaster3 TINYINT = 0,
		@DangerMaster4 TINYINT = 0,
		@DangerMaster5 TINYINT = 0
	
	SELECT @currency = currency
         --, @Msuspended = reject
         , @UplineClosed = cs.closed

         , @Credit_MAg = isnull(credit, 0)
         , @srecommend = srecommend
         , @matchlimit = matchlimit
         , @DisableOutright = DisableOutright
     
         , @DoubleCommLosing = DoubleCommLosing
 
         , @EnableVR = ISNULL(virtualmultiplier,1)
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
		 , @autosuspend3 = ISNULL(autosuspend3, 0)
       
		 , @DisableSuperLive = DisableSuperLive
		 , @DangerMaster = Danger
		 , @DangerMaster2 = Danger2
		 , @DangerMaster3 = Danger3
		 , @DangerMaster4 = Danger4
		 , @DangerMaster5 = Danger5
     FROM CustInfo ci WITH(NOLOCK) 
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs
     WHERE CustID = @mrecommend
	 
	 --Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @mrecommend)		
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	END	

    SELECT @ErrCode = 0
	
	-- MyanmarOdds
	-- Reset discount value in case its value > upline
	
	DECLARE @IsMyanmarOdds BIT = 0
	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@mrecommend)
	
	DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0, @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.mrecommend = @mrecommend
									AND c.roleid = 2
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			Select	@ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056		
			return
		END
	END
	
	SELECT @username = rtrim(ltrim(@username))

    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = case @Language 
							    when 'E' then 'This username is not available.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						    END,
		    @ErrCode = 1101		
	    RETURN
    END
    SELECT @pwdexpiry = dateadd(dd, 30, getdate())
	
	 --Vinh@20080213: get transfer option FROM master
	DECLARE @IsInternal BIT
    select	@IsInternal = IsInternal,
		    @TransferOption_dec = TransferOption 
    FROM custmaster with (nolock) 
    WHERE CustID = @mrecommend

    SELECT @Credit_AllOtherAgent = isnull(sum(credit), 0) FROM custinfo as ci WITH(NOLOCK) WHERE mrecommend = @mrecommend and RoleID = 2

    if @Credit_AllOtherAgent + @Credit >@Credit_MAg
    BEGIN
	    SELECT @ErrMsg = case @Language 
						    when 'E' then 'Sorry, credit update is not successful, You have exceeded your master credit.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](70011,@Language)
					    END,
		    @ErrCode = 104
	    return
    END
    -- maxcredit 
    if (isnull(@maxcredit ,0) > @credit )
    BEGIN 
	    SELECT @ErrMsg = case @Language
		    when 'E' then 'Sorry, credit update is not successful, You have exceeded your agent credit.'  
            ELSE [dbo].[f_Get_MsgNamebyMsgID](70012,@Language)
         END,  
      @ErrCode = 116  
     return  
    END 

	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_MAg
		@mrecommend = @mrecommend,
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingType19 = @SettingType19 OUTPUT, --LCS		
		@CreationStatus = @CreationStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
	
	--Check bet setting
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg
		@mrecommend = @mrecommend,
		@SettingType26 = @SettingType26, --SB
		@SettingType2 = @SettingType2, --SB2
		@SettingType23 = @SettingType23, --RNG Games			
		@SystemID = @SystemID,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;
		
	--Check Parlay Max Payout
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_SAg
		@mrecommend = @mrecommend,
		@SettingType27 = @SettingType27, --SB
				
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;		
		
	--Check PT
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_MAg
		@mrecommend = @mrecommend,
		@srecommend = @srecommend,
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingType1 = @SettingType1 OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		@SettingType18 = @SettingType18 OUTPUT,
		@CreationStatus = @CreationStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

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
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = 0,
	    @roleid = 2,
	    @phone = @phone,
	    @mobilephone = @mobilephone,
	    @email = '',
	    @fax = @fax,
	    @address = '',
	    @city = '',
	    @state = '',
	    @country = '',
	    @postal = '',
	    @TransferOption = @TransferOption,
	    --@suspended = @suspended,
	    @closed=@UplineClosed,

	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,
		@autosuspend3 = @autosuspend3,

	    @DisableOutright = @DisableOutright,	
	    @matchlimit = @matchlimit,
	    @virtualmultiplier = @EnableVR,
	   
	    @IsInternal = @IsInternal,
		
    	@SystemID=@SystemID,
	    @credit = @credit,
	    @maxcredit = @maxcredit,
	
	    @DoubleCommLosing = @DoubleCommLosing,	 
		@DisableSuperLive = @DisableSuperLive,
		@Danger = @DangerMaster,
		@Danger2 = @DangerMaster2,
		@Danger3 = @DangerMaster3,
		@Danger4 = @DangerMaster4,
		@Danger5 = @DangerMaster5,
	 
	    @IP = @IP,
	    @TransferOption_dec = @TransferOption_dec,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT

    if @ErrCode <> 0
	    return
		
END
	