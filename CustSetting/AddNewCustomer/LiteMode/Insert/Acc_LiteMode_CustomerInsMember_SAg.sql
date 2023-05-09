/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_SAg]
	@custid     INT OUTPUT,
	@firstname  NVARCHAR(50),
	@lastname   NVARCHAR(50),
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50),
	@mobilephone NVARCHAR(50),	
	@fax        NVARCHAR(50),

	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in CASE dummy super add new master
	@DisableAutoMPT   BIT = 1,--Super allow master using auto master PT or not.
	
	--Discount	
	@SettingType25 VARCHAR(MAX)= '', --SB
	@SettingType19 VARCHAR(MAX)= '', --LCS
	@SettingType3 VARCHAR(MAX)= '', --NG2
	
	--Bet Setting
	@SettingType26 VARCHAR(MAX)= '', --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2
	@SettingType23 VARCHAR(MAX)= '', --RNG Games
	@SettingType9 VARCHAR(MAX)= '', --NG2
	
	--Parlay Max Payout
	@SettingType27 VARCHAR(MAX)= '', --SB Parlay Max Payout
	
	--WinLoss Limit
	@SettingType6 VARCHAR(MAX)= '',-- VS
	@SettingType22 VARCHAR(MAX)= '', -- RNG Lottery, LCS
	
	--Loss Limit
	@SettingType12 VARCHAR(MAX)= '',-- BBIN
	
	--PT
	@SettingType28 VARCHAR(MAX)= '',-- SB
	@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot), NG2
	@SettingType18 VARCHAR(MAX)= '',-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	@Language VARCHAR(2)= 'E',
	@SubAccID INT = 0,--Sub-AccountID,
	@credit MONEY,
	@srecommend INT,
	@SystemID	TINYINT=1,
	
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT,
	@site VARCHAR(50) = '',
	@CreationStatus TINYINT = 0
AS
/*
	Created: 20230512@Johnson  
	Task : Add new master from LiteMode
	DB:  DBCUST/CustDB  
	Original sp: Acc_CustomerInsMember_SAg
	
	Revisions: 
		- 20230512@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType25 = '<Root>
						<r sporttype="1" bettype="1" discount="0.0025" />
						<r sporttype="1" bettype="3" discount="0.005" />
						...
						<r sporttype="2" bettype="1" discount="0.0025" />
					</Root>'
		- @SettingType26 = '<Root>
						<r sporttype="1" bettype="1" minbet="1" maxbet="100" mpm="1000" maxpayout="1000" />
						.....
						<r sporttype="9902" bettype="1" minbet="1" maxbet="100" mpm="1000" maxpayout="1000" />
					</Root>'
		- @SettingType27 = '<Root>
						<r sporttype="1" bettype="9" singlemp="1000" combo2="1000" combo35="1000" combo6="1000" />
						<r sporttype="99" bettype="1" singlemp="1000" combo2="1000" combo35="1000" combo6="1000" />
					</Root>'
		- @SettingType6 = '<Root>
						<r sporttype="9908" bettype="1201" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
						...
						<r sporttype="170" bettype="3701" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
					</Root>'
		- @SettingType22 = '<Root>
						<r sporttype="9909" bettype="3700" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
					</Root>'
		- @SettingType12 = '<Root>
						<r sporttype="241" bettype="3300" maxlosslimit="20000" isautoreset="0"  />
					</Root>'
		- @SettingType28 = '<Root>
						<r sporttype="1" bettype="1" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
						<r sporttype="1" bettype="1" islive="1" superpt="90" isauto="0" masterpt="0" minpt="0" />
						....
						<r sporttype="99" bettype="9" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<r sporttype="43" bettype="1" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
						<r sporttype="44" bettype="1" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
						....
						<r sporttype="9908" bettype="1201" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<r sporttype="169" bettype="3611" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
						<r sporttype="220" bettype="1024" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
						....
						<r sporttype="245" bettype="4601" islive="0" superpt="90" isauto="0" masterpt="0" minpt="0" />
					</Root>'			
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Super_site VARCHAR(50), @currency INT, @EnableVR BIT
	SELECT @Super_site = site,
		@currency = currency
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @srecommend
	 
	SET  @Site = ISNULL(NULLIF(@Site,''),@Super_site)

	-------------------BLOCK ADDING NEW USE UMCONFIG----------------------------
	IF @Site = @Super_site
		OR NOT EXISTS ( SELECT 1 FROM Site WITH(NOLOCK) WHERE site = @Site) -- @site = 'ExtAcc'
	BEGIN
		EXEC [Acc_CheckUM] @CustID = @srecommend
			,@FunctionType = 2
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
			,@ReturnUMData = 0
			,@Language = @Language

		IF @ErrCode <> 0 RETURN
	END
	ELSE
	BEGIN -- Direct master cross site
		DECLARE @SiteID int
		SELECT @SiteID = siteid FROM site WITH(NOLOCK) WHERE site = @site

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
			AND t.SuperID IN (0, @srecommend)
	
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
	END
	------------------------------END----------------------------------------

	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @creator AND roleid > 4) --Only check on admin user
	BEGIN
		DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
		DECLARE @tmpUserid VARCHAR(50)
		
		SELECT @tmpUserid=CAST(@creator AS VARCHAR(50))
		
		INSERT INTO  @tmp (siteid , site,SpecialGroup)
		SELECT siteid , [site], SpecialGroup FROM NAP_UserControl.dbo.f_GetDeniedSiteByUser(@tmpUserid)	
	
		IF (@site IN (SELECT site FROM @tmp ))
		BEGIN
			SELECT @ErrCode = 110, @ErrMsg ='You don''t have permission to access'
			RETURN
		END
	END
	
	  ----- 20130717@Lukas -------------------
	DECLARE @lastMINUTEMemberCount INT

	SELECT @lastMINUTEMemberCount = COUNT(1)
	  FROM Customer c WITH(NOLOCK)
		INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
	 WHERE ci.srecommend = @srecommend
		AND ci.roleid = 3
		AND creatdate > DATEADD(MINUTE, -10, CURRENT_TIMESTAMP)
		
	IF @lastMINUTEMemberCount > 100
	BEGIN		
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Sorry. You cannot create customer too often.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40029,@Language)
					end,
				@ErrCode = 998	
		RETURN 
	END
    ----- / 20130717@Lukas-----------------
	
	DECLARE @DefaultValueLimitAcc INT = 0 , @lastAccountToDay INT = 0, @CurrentDate DATETIME
	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@Site)),0)
	IF @DefaultValueLimitAcc > 0
	BEGIN
		SET @lastAccountToDay = (SELECT  COUNT(1)
								FROM Customer c WITH(NOLOCK)
								WHERE c.srecommend = @srecommend
									AND c.roleid = 3
									AND c.creatdate  > @CurrentDate)
			
		IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
		BEGIN
			Select	@ErrMsg = CASE @Language  
							WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
							ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
						END,
					@ErrCode = 40056	
			RETURN
		END
	END
	
	--20140619@Johnson: Check IP to create downline-----------------
	DECLARE @isValidIP BIT
	
	EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
    --End check IP--------------------------------------------------
	
	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @srecommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @srecommend

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
		
    DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    set @startRun = GETDATE()

    --NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
    --20081218_By_AhWan: KER - 1238537
    --20090112_Wan: unblock KM 194354
    --20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
    IF @srecommend = 726582
    BEGIN
	    Select	@ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Sorry, cannot create master.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40012,@Language)
					    END,@ErrCode = 100	
    	
	    return
    END

    --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @srecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0		RETURN 
	
	DECLARE 
	    @transcode BIGINT, @pwdexpiry DATETIME,
    	
	    @Credit_AllOtherMaster MONEY, 
		@Credit_AllMember MONEY, 
		@Credit_SAg MONEY,
	    @RoleID_SAg TINYINT, 
		@matchlimit SMALLMONEY,
	    @TransferOption_dec TINYINT,
	    @DisableOutright BIT,
	    --@Ssuspended BIT,
	    @UplineClosed BIT,
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@autosuspend3 BIT,
		@suspended    BIT = 0,
		@DoubleCommLosing	BIT,

		@DisableSuperLive BIT = 0,
		@DangerSuper TINYINT = 0,
		@DangerSuper2 TINYINT = 0,
		@DangerSuper3 TINYINT = 0,
		@DangerSuper4 TINYINT = 0,
		@DangerSuper5 TINYINT = 0
		
	SELECT @username = rtrim(ltrim(@username))

    SELECT 
	    --@currency = currency,
	    --@Ssuspended = cs.reject,
	    @UplineClosed = cs.closed,
	    @Credit_SAg = isnull(credit, 0),
	    @matchlimit = matchlimit,
	
	    @DisableOutright = DisableOutright,
	    
	    @DoubleCommLosing = DoubleCommLosing,
	    @EnableVR = ISNULL(virtualmultiplier,1),	  
	    @autosuspend = ISNULL(autosuspend, 0 ),
	    @autosuspend2 = ISNULL(autosuspend2, 0),
		@autosuspend3 = ISNULL(autosuspend3, 0 ),
		
		@DisableSuperLive = DisableSuperLive,
		@DangerSuper = Danger,
		@DangerSuper2 = Danger2,
		@DangerSuper3 = Danger3,
		@DangerSuper4 = Danger4,
		@DangerSuper5 = Danger5
    FROM CustInfo ci WITH(NOLOCK)
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs	
    WHERE CustID = @srecommend	
	
	--Virtual rate
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH(NOLOCK) WHERE custid = @srecommend)				
	BEGIN
		SELECT @EnableVR = EnableVR FROM f_GenerateVirtualStatusBySite (@site)
	END	

	DECLARE @IsValid BIT
    SELECT @IsValid = 0
    SELECT @ErrCode = 0
    
    -- MyanmarOdds
	-- Reset discount value in case its value > upline
	DECLARE @IsMyanmarOdds BIT = 0
	
	 IF @srecommend > 100 -- get site FROM upline IF not direct master
	 BEGIN
		   SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Super_site)
	 END
	 ELSE
	 BEGIN
		   	-- For Direct Master
			SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)
	 END

	IF @IsMyanmarOdds = 1 AND dbo.fn_IsMyanmarOdds (@srecommend) <> 1
	BEGIN
		 SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Cannot add Direct Master under Myanmar Odds site(s).'
						    END, @ErrCode = 361
	    RETURN	
	END
		
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    DECLARE @IsExists BIT 
	EXEC Age_CustomerCheckExists @username = @username, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'This username is not available.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
					    END		
	    SELECT @ErrCode = 1101
	    RETURN
    END
    SELECT @pwdexpiry = DATEADD(dd, 30, GETDATE())
	
	 --Vinh@20080213: get transfer option FROM super
    IF @srecommend > 100 -- get site FROM upline IF not direct master
	    SELECT @site = site FROM customer WITH(NOLOCK) WHERE CustID = @srecommend

	DECLARE @IsInternal BIT
    select	@IsInternal = IsInternal,
		    @TransferOption_dec = TransferOption
    FROM custsuper WITH(NOLOCK) WHERE CustID = @srecommend

    SELECT @Credit_AllOtherMaster = isnull(sum(credit), 0) FROM custinfo AS ci WITH(NOLOCK) WHERE srecommend = @srecommend AND RoleID = 3

    IF @Credit_AllOtherMaster + @Credit > @Credit_SAg AND @srecommend>100
    BEGIN
	    SET @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'Sorry, credit update is not successful, You have exceeded your super agent credit.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
					    END	
	    SELECT @ErrCode = 106
	    return
    END
	
	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_SAg
		@srecommend = @srecommend,
		@SettingType25 = @SettingType25, --SB
		@SettingType19 = @SettingType19, --LCS
		@SettingType3 = @SettingType3, --NG2
		@CreationStatus = @CreationStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	--Check bet setting
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg
		@srecommend = @srecommend,
		@SettingType26 = @SettingType26, --SB
		@SettingType2 = @SettingType2, --SB2
		@SettingType23 = @SettingType23, --RNG Games
		@SettingType9 = @SettingType9, --NG2		
		@SystemID = @SystemID,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;
		
	--Check Parlay Max Payout
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg
		@srecommend = @srecommend,
		@SettingType27 = @SettingType27, --SB
				
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;	
		
	--Check WinLoss Limit
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg
		@srecommend = @srecommend,
		--WinLoss Limit
		@SettingType6 = @SettingType6,-- VS
		@SettingType22 = @SettingType22, -- RNG Lottery, LCS
		
		--Loss Limit
		@SettingType12 = @SettingType12,-- BBIN
				
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;		
END
		