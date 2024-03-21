/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_MAg]
	@custid     INT OUTPUT,
	@firstname  NVARCHAR(50) ='',
	@lastname   NVARCHAR(50) ='',
	@creator    INT,
	@username   VARCHAR(30),
	@userpwd    VARCHAR(40),
	@phone      NVARCHAR(50)='',
	@mobilephone NVARCHAR(50)='',	
	@fax        NVARCHAR(50)='',

	@TransferOption VARCHAR(8) = NULL, --pass value (not NULL) in case direct master add new agent
	@SettingXML VARCHAR(MAX) = '',
	@TemplateName NVARCHAR(50) = '',
	--Log all values group from UI
	@SettingTypeAll NVARCHAR(MAX) = '',
	
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
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20230626@Johnson  
	Task : Add new agent from LiteMode
	DB:  DBCUST/CustDB  
	Original sp: Acc_CustomerInsMember_MAg
	
	Revisions: 
		- 20230626@Johnson: initial sp [redmine: #179159]
		- 20231026@Johnson: Limit New Account Update PT for i7 [redmine: #196032]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240321@Luke: NAP - Virtual rate - For Direct account :Change default of VR Status for newly created accounts to "Follow upline" [Redmine: #202624]
  Limit New Account Update PT	Param's Explanation: 
		- @SettingXML:
		'{
			"150": [
				{"SportType": "1","BetType": "1","Discount": "0.0010000"},
				{"SportType": "1","BetType": "3","Discount": "0.0015000"},
				{"SportType": "1","BetType": "5","Discount": "0.0030000"},
				{"SportType": "1","BetType": "7","Discount": "0.0020000"},
				{"SportType": "1","BetType": "4","Discount": "0.0035000"},
				{"SportType": "1","BetType": "8","Discount": "0.0025000"}
			],
			"156": [
				{"SportType": "9911","BetType": "2400","Discount": "0.0035000"},
				{"SportType": "175","BetType": "7901","Discount": "0.0025000"}
			],

			"151": [
				{"SportType": "1","BetType": "9","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "2","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "9902","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "1","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "9901","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "11","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "99","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "3","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "5","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "8","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "10","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "99","BetType": "9","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "43","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10"},
				{"SportType": "44","BetType": "3","MinBet": "0","MaxBet": "0","MPM": "0"}
			],
			"152": [
				{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
				{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
			],
			"153": [
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "175","BetType": "7901","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "161","BetType": "81","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
				{"SportType": "202","BetType": "1501","IsLive": "0"	,"MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"}

			],

			"154": [
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			],
			"157": [
				{"SportType": "175","BetType": "7901","MinBet": "0","MaxBet": "0","MPM": "0"}
			]
		}'			
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()

	DECLARE
		--Discount	
		@SettingType25 VARCHAR(MAX)= '', --SB
		@SettingType19 VARCHAR(MAX)= '', --LCS
		@SettingType3 VARCHAR(MAX)= '', --Others Games
		--Bet Setting
		@SettingType26 VARCHAR(MAX)= '', --SB
		@SettingType2 VARCHAR(MAX)= '', --SB2
		@SettingType23 VARCHAR(MAX)= '', --RNG Games
		@SettingType16 VARCHAR(MAX)= '', --Others Games
		--Parlay Max Payout
		@SettingType27 VARCHAR(MAX)= '', --SB Parlay Max Payout
		--PT
		@SettingType28 VARCHAR(MAX)= '',-- SB
		@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		@SettingType18 VARCHAR(MAX)= '' -- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	EXEC [Acc_CheckUM] @CustID = @mrecommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN

	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END
	
	DECLARE @uplineUsername NVARCHAR(50)
	
	SELECT @uplineUsername = username 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @mrecommend
				
	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @mrecommend , 
			@RuleID				= 'MAG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= 0 , 
			@SystemID			= 0 , 
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
	
	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	IF @creator = @mrecommend
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
		
	DECLARE @Site NVARCHAR(50), @EnableVR BIT, @siteID SMALLINT
	SELECT @Site = c.site, @siteID = s.siteID
	FROM customer c WITH(NOLOCK) 
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @mrecommend
	
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
		AND EXISTS( 
				SELECT 1 
				FROM dbo.Site WITH (NOLOCK)
				WHERE site = @site AND SiteLabel IN ('789y')
			)
				SET @EnableVR = 1
	
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

    IF @Credit_AllOtherAgent + @Credit >@Credit_MAg
    BEGIN
		SET @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@Credit_MAg - @Credit_AllOtherAgent, '#,#0.####'))

	    SELECT @ErrCode = 104
	    return
    END
    -- maxcredit 
    if (isnull(@maxcredit ,0) > @credit )
    BEGIN 
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70034,@Language), '{number}', FORMAT(@maxcredit, '#,#0.####')),  
			@ErrCode = 116  
		return  
    END 

	DECLARE @Comm_Tbl TABLE(
		 SportType SMALLINT  
		,BetType SMALLINT  
		,Discount DECIMAL(9,8)
		,SettingType SMALLINT
		,GroupType TINYINT
	)

	DECLARE @BetSetting_Tbl TABLE(
		 SportType SMALLINT  
		,BetType SMALLINT  
		,MinBet MONEY  
		,MaxBet MONEY
		,MPM MONEY  
		,MaxPayout MONEY 
		,MaxPerNumber MONEY
		,SettingType SMALLINT
		,GroupType TINYINT
	)

	DECLARE @Parlay_MaxPayout_Tbl TABLE(
		 SportType SMALLINT
		,BetType SMALLINT  
		,SingleMP MONEY
		,Combo2 MONEY 
		,Combo35 MONEY
		,Combo6 MONEY 
		,SettingType SMALLINT
		,GroupType TINYINT
	)

	DECLARE @PT_Tbl TABLE(
		SportType SMALLINT  
		,BetType SMALLINT  
		,IsLive BIT 
		,MasterPT SMALLMONEY 
		,IsAuto BIT 
		,AutoPT SMALLMONEY  
		,AgentPT SMALLMONEY
		,MinPT SMALLMONEY 
		,SettingType SMALLINT
		,GroupType TINYINT
	)
	--Parse Json
	INSERT INTO @Comm_Tbl(GroupType,SportType,BetType,Discount)
	SELECT 150 AS GroupType,SportType,BetType,Discount
	FROM OPENJSON(@SettingXML,'$."150"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,Discount DECIMAL(9,8)  '$.Discount'
		)
	UNION ALL
	SELECT 156 AS GroupType,SportType,BetType,Discount
	FROM OPENJSON(@SettingXML,'$."156"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,Discount DECIMAL(9,8)  '$.Discount'
		)

	INSERT INTO @BetSetting_Tbl(GroupType,SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber)
	SELECT 151 AS GroupType,SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber
	FROM OPENJSON(@SettingXML,'$."151"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,MinBet MONEY  '$.MinBet'
			,MaxBet MONEY  '$.MaxBet'
			,MPM MONEY  '$.MPM'
			,MaxPayout MONEY  '$.MaxPayout'
			,MaxPerNumber MONEY  '$.MaxPerNumber'
		)
	UNION ALL
	SELECT 154 AS GroupType,SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber
	FROM OPENJSON(@SettingXML,'$."154"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,MinBet MONEY  '$.MinBet'
			,MaxBet MONEY  '$.MaxBet'
			,MPM MONEY  '$.MPM'
			,MaxPayout MONEY  '$.MaxPayout'
			,MaxPerNumber MONEY  '$.MaxPerNumber'
		)
	UNION ALL
	SELECT 157 AS GroupType,SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber
	FROM OPENJSON(@SettingXML,'$."157"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,MinBet MONEY  '$.MinBet'
			,MaxBet MONEY  '$.MaxBet'
			,MPM MONEY  '$.MPM'
			,MaxPayout MONEY  '$.MaxPayout'
			,MaxPerNumber MONEY  '$.MaxPerNumber'
		)


	INSERT INTO @Parlay_MaxPayout_Tbl(GroupType,SportType,BetType,SingleMP,Combo2,Combo35,Combo6)
	SELECT 152 AS GroupType,SportType,BetType,SingleMP,Combo2,Combo35,Combo6
	FROM OPENJSON(@SettingXML,'$."152"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,SingleMP MONEY  '$.SingleMP'
			,Combo2 MONEY  '$.Combo2'
			,Combo35 MONEY  '$.Combo35'
			,Combo6 MONEY  '$.Combo6'
		)
	
	INSERT INTO @PT_Tbl(GroupType,SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT)
	SELECT 153 AS GroupType,SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,IsLive BIT  '$.IsLive'
			,MasterPT SMALLMONEY  '$.MasterPT'
			,IsAuto BIT  '$.IsAutoMasterPT'
			,AutoPT SMALLMONEY  '$.AutoMasterPT'
			,AgentPT SMALLMONEY  '$.AgentPT'
			,MinPT SMALLMONEY  '$.MinPT'
		)

	DECLARE @GroupTypeTbl TABLE(
			 GroupType		TINYINT
			,SettingType	smallint
			,SportType		smallint
			,BetType		smallint
			,IsLive			bit
		)

	INSERT INTO @GroupTypeTbl(GroupType,SettingType,SportType,BetType,IsLive)
	SELECT t.GroupType,t.SettingType,t.SportType,t.BetType,t.IsLive 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency) t
	WHERE t.GroupType IN(
		 150,156 --Comm
		,151,154,157 -- Betsetting
		,152 --Parlay Max Payout
		,153 --PT
	)

	UPDATE t 
	SET t.Settingtype = g.SettingType
	FROM @Comm_Tbl t 
		INNER JOIN @GroupTypeTbl g 
			ON t.GroupType = g.GroupType
			AND t.SportType = g.SportType 
			AND t.BetType = g.BetType

	UPDATE t 
	SET t.Settingtype = g.SettingType
	FROM @BetSetting_Tbl t 
		INNER JOIN @GroupTypeTbl g 
			ON t.GroupType = g.GroupType
			AND t.SportType = g.SportType 
			AND t.BetType = g.BetType

	UPDATE t 
	SET t.Settingtype = g.SettingType
	FROM @Parlay_MaxPayout_Tbl t 
		INNER JOIN @GroupTypeTbl g 
			ON t.GroupType = g.GroupType
			AND t.SportType = g.SportType 
			AND t.BetType = g.BetType

	UPDATE t 
	SET t.Settingtype = g.SettingType
	FROM @PT_Tbl t 
		INNER JOIN @GroupTypeTbl g 
			ON t.GroupType = g.GroupType
			AND t.SportType = g.SportType 
			AND t.BetType = g.BetType
			AND t.IsLive = g.IsLive

	--Input to XML param
	--Comm
	SELECT @SettingType25 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,Discount
					FROM @Comm_Tbl
					WHERE SettingType = 25
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType19 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,Discount
					FROM @Comm_Tbl
					WHERE SettingType = 19
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType3 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,Discount
					FROM @Comm_Tbl
					WHERE SettingType = 3
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--Bet Setting
	SELECT @SettingType26 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout
					FROM @BetSetting_Tbl
					WHERE SettingType = 26
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType2 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM
					FROM @BetSetting_Tbl
					WHERE SettingType = 2
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType23 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPerNumber
					FROM @BetSetting_Tbl
					WHERE SettingType = 23
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType16 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM
					FROM @BetSetting_Tbl
					WHERE SettingType = 16
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--Parlay Max Payout
	SELECT @SettingType27 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
					FROM @Parlay_MaxPayout_Tbl
					WHERE SettingType = 27
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	
	--PT
	SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 28
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType1 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 1
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType18 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 18
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingType19 = @SettingType19 OUTPUT, --LCS	
		@SettingType3 = @SettingType3 OUTPUT, --LCS		
		@SettingStatus = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
	
	--Check bet setting
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType26 = @SettingType26, --SB
		@SettingType2 = @SettingType2, --SB2
		@SettingType23 = @SettingType23, --RNG Games
		@SettingType16 = @SettingType16, --Others Games		
		@SystemID = @SystemID,
		@SettingStatus = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;
		
	--Check Parlay Max Payout
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType27 = @SettingType27, --SB
		@SettingStatus = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;		
		
	--Check PT
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_MAg
		@mrecommend = @mrecommend,
		@srecommend = @srecommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingType1 = @SettingType1 OUTPUT,-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		@SettingType18 = @SettingType18 OUTPUT,
		@SettingStatus = @SettingStatus,
		
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

    IF @ErrCode <> 0
	    return
	
	EXEC Acc_CustomerInfo_Execrep_14
		@custid = @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,	
		@recommend = 0,
		@roleid = 2,
		@siteID = @siteID,
		@currency = @currency,
		
		--Discount	
		@SettingType25 = @SettingType25, --SB
		@SettingType19 = @SettingType19, --LCS	
		@SettingType3 = @SettingType3, --Others Games			
		
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
				
		@SettingStatus = @SettingStatus,
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
	
	If @SystemID IN (2,6) -- ALPHA, i7 alpha
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create customer fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			DELETE FROM CustLimitPTSetting			WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustProductStatus			WITH (ROWLOCK) WHERE CustID = @CustID			
			DELETE FROM CustPTSetting3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID					
			DELETE FROM CustDiscount3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustStakeLevel_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustBetSetting_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM CustMaxPayoutSetting_Agent	WITH (ROWLOCK) WHERE CustID = @CustID
			
			RETURN
		END	
	END

    SET @endRun = getdate()
    SET @duration  = datediff (MILLISECOND,@startRun,@endRun)

	DECLARE @LogSPData NVARCHAR(MAX)
   
	--Log customer info
    SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS NVARCHAR(100)), SPACE(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS NVARCHAR(100)), SPACE(1))) + '" ' +
    'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
	'maxcredit="'+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + '" ' +
    'TransferOption="'+ COALESCE(CAST(@TransferOption AS VARCHAR(8)), SPACE(1)) + '" ' +
	'TemplateName="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@TemplateName AS NVARCHAR(50)), SPACE(1))) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +	
    'mrecommend="'+ COALESCE(CAST(@mrecommend AS VARCHAR(50)), SPACE(1)) + '" ' +	
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
    'site="'+ COALESCE(CAST(@site AS VARCHAR(50)), SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95091,
		@TrackingValue = @LogSPData,
		@duration = @duration 
		
	-- Write Log Credit	
    Declare @LogSPCredit VARCHAR(MAX)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + ',
						MaxCredit='+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + ',
						SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1))
	
	DECLARE @log xml, @SB_Error BIT = 0
 
	SELECT @log = (SELECT @Creator as '@UserID',
						@custid as '@CustID',
						@LogSPCredit as '@Doing',						
						@credit as '@NewValue',
						@IP as '@IP',
						1224 as '@ActionID',
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
				@ActionID = 1224
		END TRY
		BEGIN CATCH
			SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username as VARCHAR(30)), SPACE(1)) + ',
					MaxCredit='+ COALESCE(CAST(@maxcredit as VARCHAR(50)), SPACE(1)) + ',
					SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) as VARCHAR(30)), SPACE(1)) + ',
					ErrMsg=' + ERROR_MESSAGE() 
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = @Creator,
				@CustID = @CustID,
				@Doing = @LogSPCredit,
				@NewValue = @credit,
				@IP = @IP,
				@ActionID = 1224
		END CATCH
	END		
	
	DECLARE @LogDataSP2 VARCHAR(4000)
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @CustID

	SET @LogDataSP2 = ''
	
	CREATE TABLE #temSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)
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

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 2)
		SET @VRLockedStatus_OS = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 3)
		SET @VRLockedStatus_Basketball = 1
	
	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @mrecommend AND Type = 4)
		SET @VRAccumulatedBalance = 1

    SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid as VARCHAR(50)), SPACE(1)) + '" ' +
    'isinternal="'+ COALESCE(CAST(@IsInternal as VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended as VARCHAR(1)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@UplineClosed as VARCHAR(1)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Danger="'+ COALESCE(CAST(@DangerMaster AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger2="'+ COALESCE(CAST(@DangerMaster2 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger3="'+ COALESCE(CAST(@DangerMaster3 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger4="'+ COALESCE(CAST(@DangerMaster4 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Danger5="'+ COALESCE(CAST(@DangerMaster5 AS VARCHAR(5)),SPACE(1)) + '" ' +
	'Abnormal="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'Special=" " ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend3="'+ COALESCE(CAST(@autosuspend3 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +
	'VRAccumulatedBalance="'+ COALESCE(CAST(@VRAccumulatedBalance AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_Basketball="'+ COALESCE(CAST(@VRLockedStatus_Basketball AS VARCHAR(10)),SPACE(1)) + '" ' +     
    'DisableOutright="'+ COALESCE(CAST(@DisableOutright as VARCHAR(1)), SPACE(1)) + '" ' +
 
	'DisableSuperLive="' + COALESCE(CAST(@DisableSuperLive as VARCHAR(1)), SPACE(1)) + '" ' + @LogDataSP2 + ' />'
    
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1198,
		@TrackingValue = @LogSPData,
		@duration = @duration	
		
	CREATE TABLE #TmpProductSettingDetail(
		[SettingType] [smallint] ,
		[SportType] [smallint] ,
		[BetType] [smallint] ,
		[IsLive] [bit] ,		
		[SettingLevel] [tinyint] ,
		[ProductID] [tinyint] ,			
		[Child_DisplayOrder] [int] ,
		GroupID [TINYINT],
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
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
			MasterPT		SMALLMONEY,
			IsAutoMasterPT	BIT,
			AutoMasterPT	SMALLMONEY,
			AgentPT			SMALLMONEY,				
			AgentMinPT		SMALLMONEY,	
			SettingLevel	TINYINT,
			ProductID 		TINYINT,		
			GroupID			  TINYINT,
			Child_DisplayOrder  INT
			)	
	
	DECLARE @tblPT28 TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			MasterPT		SMALLMONEY,
			IsAutoMasterPT	BIT,
			AutoMasterPT	SMALLMONEY,
			AgentPT			SMALLMONEY,				
			AgentMinPT		SMALLMONEY,
			SettingLevel	TINYINT,
			ProductID 		TINYINT,	
			GroupID			  TINYINT,
			Child_DisplayOrder  INT
			)	
	
	DECLARE @tblCustWinLossLimit TABLE
						(SportType SMALLINT
						,BetType SMALLINT
						,MaxWinLimit SMALLMONEY
						,MaxLossLimit MONEY
						,IsAutoReset BIT
						,SettingLevel TINYINT
						,ProductID TINYINT
						,GroupID TINYINT
						,Child_DisplayOrder INT)
	
	DECLARE @tblCustStakeLevel TABLE
						(SportType SMALLINT
						,BetType SMALLINT
						,StakeLevelList	VARCHAR(200)
						,SettingType SMALLINT
						,SettingLevel TINYINT
						,ProductID TINYINT	
						,GroupID TINYINT
						,Child_DisplayOrder INT)
						
	INSERT INTO #TmpProductSettingDetail(SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder,SettingLevel,ProductID)
	SELECT SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder,SettingLevel,ProductID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)	
	
	INSERT INTO @tblCustWinLossLimit (SportType
									,BetType 
									,MaxWinLimit 
									,MaxLossLimit 
									,IsAutoReset
									,SettingLevel
									,ProductID
									,GroupID
									,Child_DisplayOrder
									)
	SELECT cs.SportType
		,cs.BetType 
		,cs.MaxWinLimit 
		,cs.MaxLossLimit 
		,cs.IsAutoReset
		,t.SettingLevel
		,t.ProductID	
		,t.GroupID
		,t.Child_DisplayOrder
	FROM CustWinLossLimit_Agent cs WITH(NOLOCK)
		INNER JOIN #TmpProductSettingDetail t ON cs.SportType = t.SportType
												AND cs.BetType = t.BetType
	WHERE custid = @custid
		AND SettingType IN (6,22,12)
		
	INSERT INTO @tblCustStakeLevel (SportType
									,BetType 
									,StakeLevelList
									,SettingType
									,SettingLevel
									,ProductID
									,GroupID
									,Child_DisplayOrder
									)
	SELECT cs.SportType
		,cs.BetType 
		,cs.StakeLevelList
		,t.SettingType
		,t.SettingLevel
		,t.ProductID
		,t.GroupID
		,t.Child_DisplayOrder
	FROM CustStakeLevel_Agent cs WITH(NOLOCK)
		INNER JOIN #TmpProductSettingDetail t ON cs.SportType = t.SportType
												AND cs.BetType = t.BetType
	WHERE custid = @custid
		AND SettingType IN (7,8,17)
	
	UPDATE @tblCustStakeLevel
	SET StakeLevelList = REPLACE(StakeLevelList, ',', ';')
	WHERE SettingType IN (7,17)
	
	WHILE 0 = 0
	BEGIN
		UPDATE	ts
		SET	ts.StakeLevelList = REPLACE(ts.StakeLevelList, sl.StakeLevelID, sl.StakeLevelValue)
		FROM		@tblCustStakeLevel AS ts
		CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
									,	CAST(sl.MinLabel AS VARCHAR(20)) + '-' + CAST(sl.MaxLabel AS VARCHAR(20)) AS StakeLevelValue
						FROM		string_split(ts.StakeLevelList, ';') AS ss
						INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
								ON	ss.value = CAST(sl.StakeLevelID AS NVARCHAR(10))
						WHERE sl.GameGroupID=0
					) sl
		WHERE ts.SettingType IN (7,17)			

		IF	@@ROWCOUNT = 0
			BREAK;
	END;
	
	WHILE 0 = 0
	BEGIN
		UPDATE	ts
		SET	ts.StakeLevelList = REPLACE(ts.StakeLevelList, sl.StakeLevelID, sl.StakeLevelValue)
		FROM		@tblCustStakeLevel AS ts
		CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
									,	gg.GroupName AS StakeLevelValue
						FROM		string_split(ts.StakeLevelList, ',') AS ss
						INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
								ON	ss.value = CAST(sl.StakeLevelID AS NVARCHAR(10))
						INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK)
								ON	gg.GameGroupID = sl.GameGroupID
					) sl
		WHERE ts.SettingType IN (8)			

		IF	@@ROWCOUNT = 0
			BREAK;
	END;
	
	UPDATE @tblCustStakeLevel
	SET StakeLevelList = REPLACE(StakeLevelList, ',', ', ')
	WHERE SettingType IN (8)
	
	DECLARE @xml XML
	
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
	
	--Bet setting
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
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
	SELECT 
		T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
		T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
		T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
		T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
		T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoMasterPT,
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT,
		T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS AgentMinPT
	FROM  @xml.nodes('/Root/R') T(c)
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder,
		b.SettingLevel = p.SettingLevel,
		b.ProductID = p.ProductID
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
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
	SELECT 
		T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
		T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
		T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
		T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
		T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoMasterPT,
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT,
		T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS AgentMinPT
	FROM  @xml.nodes('/Root/R') T(c)
	
	SELECT @xml = CONVERT(XML, @SettingType18)
	
	INSERT INTO @tblPT18(
			SportType,
			BetType, 
			IsLive,
			MasterPT,
			IsAutoMasterPT,
			AutoMasterPT,
			AgentPT,				
			AgentMinPT)
	SELECT 
		T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
		T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
		T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney')/100 AS MasterPT,
		T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
		T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney')/100 AS AutoMasterPT,
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT,
		T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney')/100 AS AgentMinPT
	FROM  @xml.nodes('/Root/R') T(c)
	
	UPDATE b
	SET b.GroupID = p.GroupID,
		b.Child_DisplayOrder = p.Child_DisplayOrder,
		b.SettingLevel = p.SettingLevel,
		b.ProductID = p.ProductID
	FROM @tblPT18 b
		INNER JOIN #TmpProductSettingDetail p ON b.SportType = p.SportType
												AND b.BetType = p.BetType
												AND b.IsLive = p.IsLive
	WHERE p.SettingType IN (1,18)	
	
	--log all settings
	SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '">' 
			+ '<Group ID="1">'--SB
			+ '<Discount GroupType="150">' 
				+ COALESCE(REPLACE(REPLACE(@SettingType25,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</Discount>'
			+ '<BetSetting GroupType="151">'
				+ COALESCE(REPLACE(REPLACE(@SettingType26,'<Root>',''),'</Root>',''), SPACE(1)) --SB
				+ COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM	
								FROM @BetSetting
								WHERE GroupID = 1
								ORDER BY Child_DisplayOrder
								FOR XML RAW('R')
								) as VARCHAR(max)),SPACE(1))--SB2
			+ '</BetSetting>'
			+ '<ParlayMaxPayout GroupType="152">' 
				+ COALESCE(REPLACE(REPLACE(@SettingType27,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</ParlayMaxPayout>'	
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
										BetType, 
										IsLive,
										MasterPT,
										IsAutoMasterPT IsAuto,
										AutoMasterPT AutoPT,
										AgentPT,				
										AgentMinPT	MinPT,
										SettingLevel,
										ProductID
								FROM @tblPT28
								WHERE 1= CASE WHEN SportType = 99 AND Bettype = 9 THEN 0 ELSE 1 END 
								ORDER BY Child_DisplayOrder
								FOR XML RAW('R')
								) as VARCHAR(max)),SPACE(1))--SB	
			+ '</PT>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
										BetType, 
										IsLive,
										MasterPT,
										IsAutoMasterPT IsAuto,
										AutoMasterPT AutoPT,
										AgentPT,				
										AgentMinPT	MinPT,
										SettingLevel,
										ProductID
								FROM @tblPT28
								WHERE SportType = 99 AND Bettype = 9
								ORDER BY Child_DisplayOrder
								FOR XML RAW('R')
								) as VARCHAR(max)),SPACE(1))--SB MixParlay mix sports
			+ '</PT>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
										BetType, 
										IsLive,
										MasterPT,
										IsAutoMasterPT IsAuto,
										AutoMasterPT AutoPT,
										AgentPT,				
										AgentMinPT	MinPT,
										SettingLevel,
										ProductID
								FROM @tblPT18
								WHERE GroupID = 1
								ORDER BY Child_DisplayOrder
								FOR XML RAW('R')
								) as VARCHAR(max)),SPACE(1))--SB2
			+ '</PT>'
			+ '</Group>'	
			+ '<Group ID="2">'--RnG Games
			+ '<BetSetting GroupType="154">'
				+ 	COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM, MaxPerNumber	
							FROM @BetSetting
							WHERE GroupID = 2
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</BetSetting>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,MasterPT,IsAutoMasterPT IsAuto,
								AutoMasterPT AutoPT,AgentPT, AgentMinPT MinPT,
								SettingLevel,ProductID
						FROM @tblPT18
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
			+ '</PT>'
			+ '<WinLossLimit GroupType="155">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset,
								SettingLevel,ProductID
							FROM @tblCustWinLossLimit
							WHERE GroupID = 2
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLossLimit>'	
			+ '<BetLimit GroupType="159">'
				+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
							FROM @tblCustStakeLevel
							WHERE GroupID = 2
								AND SettingType IN (8)
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</BetLimit>'			
			+ '</Group>'
			+ '<Group ID="3">'--LCS
			+ '<Discount GroupType="156">' 
				+ COALESCE(REPLACE(REPLACE(@SettingType19,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</Discount>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,MasterPT,IsAutoMasterPT IsAuto,
								AutoMasterPT AutoPT,AgentPT, AgentMinPT MinPT,SettingLevel,ProductID
						FROM @tblPT18						
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
			+ '</PT>'
			+ '<WinLossLimit GroupType="155">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset,
								SettingLevel,ProductID
							FROM @tblCustWinLossLimit
							WHERE GroupID = 3
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLossLimit>'	
			+ '<BetLimit GroupType="158">'
				+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
							FROM @tblCustStakeLevel
							WHERE GroupID = 3
								AND SettingType IN (7,17)
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</BetLimit>'
			+ '<BetLimit GroupType="159">'
				+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
							FROM @tblCustStakeLevel
							WHERE GroupID = 3
								AND SettingType IN (8)
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</BetLimit>'
			+ '</Group>'
			+ '<Group ID="4">'--Others Games
			+ '<Discount GroupType="156">' 
				+ COALESCE(REPLACE(REPLACE(@SettingType3,'<Root>',''),'</Root>',''),SPACE(1))
			+ '</Discount>'
			+ '<BetSetting GroupType="157">'
				+ 	COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch MPM	
						FROM @BetSetting
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
			+ '</BetSetting>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,MasterPT,IsAutoMasterPT IsAuto,
								AutoMasterPT AutoPT,AgentPT, AgentMinPT MinPT,
								SettingLevel,ProductID
						FROM @tblPT18						
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
			+ '</PT>'
			+ '<WinLossLimit GroupType="155">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset,
								SettingLevel,ProductID
							FROM @tblCustWinLossLimit
							WHERE GroupID = 4
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLossLimit>'	
			+ '</Group>'
			+ '</Root>'
			
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95092,
		@TrackingValue = @LogSPData,
		@duration = @duration  		
		
	--Log UI settings
	SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '">' 
						+ COALESCE(@SettingTypeAll,SPACE(1))
						+ '</Root>'
	
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 95093,
		@TrackingValue = @LogSPData,
		@duration = @duration	
END
	