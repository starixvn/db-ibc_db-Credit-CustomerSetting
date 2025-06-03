/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CashMember_Validate]
	
	@creator		INT
	,@username		VARCHAR(30)
	,@SettingXML	VARCHAR(MAX) = ''
	,@Language		VARCHAR(2)= 'E'	
	,@recommend		INT	
	,@SystemID		TINYINT=1
	,@IP			VARCHAR(15)=''
	,@SettingStatus TINYINT = 0

	,@ErrCode		INT = 0 OUTPUT
	,@MsgType		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT	
	
AS
/*
	Created: 20250509@Elodie	
	Task: Validate when Agent create cash member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		
	Parameter's Explanation:
	- @SettingXML:
		'{
			
			--BetSetting:
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
			"154": [
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			],

			--Parlay Maxpayout:
			"152": [
				{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
				{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
			],

			--PT:
			"153": [
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","SuperPT": "38"},
				{"SportType": "9909","BetType": "3700","IsLive": "0","SuperPT": "38"},
				{"SportType": "9911","BetType": "2400","IsLive": "0","SuperPT": "38"},
				{"SportType": "9918","BetType": "4601","IsLive": "0","SuperPT": "38"}

			],

			--Winloss Limit:
			"161": [
					{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }

				],

			--Stake Level:
			"158": [
					{"SportType": "159","BetType": "3151","StakeLevelList": "3151"},
					{"SportType": "211","BetType": "2401","StakeLevelList": "3151"}
				],

			--Product Status:
			"160": [
					{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
					{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
				]
		}'	
	
*/	
BEGIN
	SET NOCOUNT ON

	DECLARE	
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
	@SettingType18 VARCHAR(MAX)= '', -- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	--
	@GroupTypeT158 VARCHAR(MAX)= '', --Stake Level
	@GroupTypeT161 VARCHAR(MAX)= '', --Win Limit
	@GroupTypeT160 VARCHAR(MAX)= '' --Product Status

	EXEC [Acc_CheckUM] @CustID = @recommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN	
	
	DECLARE @uplineUsername NVARCHAR(50), @ServiceType TINYINT = 0
	
	SELECT @uplineUsername = username 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @recommend
	
	SELECT 
		@ServiceType = ServiceType
	FROM vw_CustInfoExtra WITH(NOLOCK) 
	WHERE custid = @recommend
	
	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @recommend , 
			@RuleID				= 'CashAG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@ServiceType		= @ServiceType,
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= 0 , 
			@SystemID			= @SystemID , 
			@Credit				= 0 ,
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
    IF @ErrCode <>0	
	RETURN

	DECLARE @currency INT
			,@srecommend INT
			,@mrecommend INT				
			,@site NVARCHAR(50)
			,@siteID SMALLINT
	
	SELECT @siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend	
				
	SELECT @currency = currency
		 , @mrecommend = mrecommend	
		,@srecommend = srecommend
    FROM custinfo ci WITH(NOLOCK)			
    WHERE CustID = @recommend	

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
		,AgentPT SMALLMONEY 
		,SettingType SMALLINT
		,GroupType TINYINT
	)
	--Parse Json
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
	
	INSERT INTO @PT_Tbl(GroupType,SportType,BetType,IsLive,AgentPT)
	SELECT 153 AS GroupType,SportType,BetType,IsLive,AgentPT
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,IsLive BIT  '$.IsLive'
			,AgentPT SMALLMONEY  '$.AgentPT'
		)

	SELECT @GroupTypeT161 = (
								SELECT SportType, BetType, MaxWinLimit, IsAutoReset
								FROM OPENJSON(@SettingXML,'$."161"') WITH (
											SportType		SMALLINT
										,BetType		SMALLINT
										,MaxWinLimit	MONEY									
										,IsAutoReset	BIT
									) AS Limit
								FOR JSON PATH
							)

	SELECT @GroupTypeT158 = (
								SELECT	ox.SportType, ox.BetType, ox.StakeLevelList
								FROM OPENJSON(@SettingXML,'$."158"') WITH (
											SportType		SMALLINT
										,BetType		INT
										,StakeLevelList	VARCHAR(200)	
										) AS ox
								FOR JSON PATH
							)

	SELECT @GroupTypeT160 = (
								SELECT SportType, BetType, IsDisabled
								FROM OPENJSON(@SettingXML,'$."160"') WITH (
											SportType			SMALLINT	
										,BetType			SMALLINT
										,IsDisabled			BIT
									) AS DisabledProductStatus
								FOR JSON PATH
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
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@siteID,@currency) t
	WHERE t.GroupType IN(
		151,154,157 -- Betsetting
		,152 --Parlay Max Payout
		,153 --PT
	)	

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
					SELECT SportType,BetType,IsLive,AgentPT
					FROM @PT_Tbl
					WHERE SettingType = 28
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType1 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,AgentPT
					FROM @PT_Tbl
					WHERE SettingType = 1
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType18 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,AgentPT
					FROM @PT_Tbl
					WHERE SettingType = 18
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)
							
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
		@SettingStatus  = @SettingStatus,
		
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
		@SettingStatus = @SettingStatus,
		
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
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;

	EXEC Acc_CustomerInsMember_WinlossLimitCheck_CashMember
		@recommend = @recommend,			
		@siteid = @siteid,
		@currency = @currency,
	
		@GroupTypeT161 = @GroupTypeT161,
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;

	EXEC Acc_CustomerInsMember_StakeLevelCheck_CashMember
		@recommend = @recommend,		
		@siteid = @siteid,
		@currency = @currency,
		@SystemID = @SystemID,
		@site = @Site,
	
		@GroupTypeT158 = @GroupTypeT158,
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;

	EXEC Acc_CustomerInsMember_ProductStatusCheck_CashMember
		@recommend = @recommend,		
		@siteid = @siteid,
		@currency = @currency,
		@SystemID = @SystemID,
	
		@GroupTypeT160 = @GroupTypeT160,
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;


END
GO
