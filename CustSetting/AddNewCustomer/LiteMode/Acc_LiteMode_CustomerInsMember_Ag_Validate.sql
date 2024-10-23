/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_Ag_Validate]
	
	@creator		INT
	,@username		VARCHAR(30)
	,@SettingXML	VARCHAR(MAX) = ''
	,@Language		VARCHAR(2)= 'E'
	,@credit		MONEY
	,@recommend		INT
	,@ugroup		VARCHAR(5)
	,@SystemID		TINYINT=1
	,@IP			VARCHAR(15)=''
	,@SettingStatus TINYINT = 0

	,@ErrCode		INT = 0 OUTPUT
	,@MsgType		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT	
	
AS
/*
	Created: 20240704@Louisa
	Task : Validate Create member Lite Mode
	DB: DBCUST/CustDB

	Revision:
		- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]

	Param's Explanation: 
		- @SettingXML:
		'{
			"150": [
				{"SportType": "1","BetType": "1","Discount": "0.0010000"},
				{"SportType": "1","BetType": "5","Discount": "0.0030000"},
				{"SportType": "1","BetType": "4","Discount": "0.0035000"}
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
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"AgentPT": "38"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"AgentPT": "38"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"AgentPT": "38"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","AgentPT": "38"},
				{"SportType": "175","BetType": "7901","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "161","BetType": "81","IsLive": "0"	,"AgentPT": "38"},
				{"SportType": "202","BetType": "1501","IsLive": "0"	,"AgentPT": "38"}

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

	EXEC [Acc_CheckUM] @CustID = @recommend
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
	WHERE custid = @recommend
	
	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @recommend , 
			@RuleID				= 'AG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
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
    IF @ErrCode <>0	
	RETURN

	DECLARE @currency INT
			,@srecommend INT
			,@mrecommend INT	
			,@AgentCredit MONEY
			,@Credit_AllOtherMember MONEY
			,@MaxCredit_Mem MONEY
			,@site NVARCHAR(50)
			,@siteID SMALLINT
	
	SELECT @siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend	
				
	SELECT @currency = currency
		 , @mrecommend = mrecommend
		, @AgentCredit = ISNULL(Credit, 0) 
		,@srecommend = srecommend
    FROM custinfo ci WITH(NOLOCK)	
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs
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
	
	 SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

	--Use maxcredit in CustAgent table 
    SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) FROM custAgent WITH(NOLOCK)  WHERE CustID = @recommend

	SELECT @Credit_AllOtherMember = ISNULL(sum(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1
    SELECT @MaxCredit_Mem = CASE WHEN @MaxCredit_Mem =0 THEN (@AgentCredit - @Credit_AllOtherMember) 
						    ELSE @MaxCredit_Mem END 
    IF @Credit + @Credit_AllOtherMember>@AgentCredit
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@AgentCredit - @Credit_AllOtherMember, '#,#0.####'))
			    , @ErrCode = 204
	    return
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70032,@Language), '{number}', FORMAT(@MaxCredit_Mem, '#,#0.####'))
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
		,AgentPT SMALLMONEY 
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
	
	INSERT INTO @PT_Tbl(GroupType,SportType,BetType,IsLive,AgentPT)
	SELECT 153 AS GroupType,SportType,BetType,IsLive,AgentPT
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,IsLive BIT  '$.IsLive'
			,AgentPT SMALLMONEY  '$.AgentPT'
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
		@SettingStatus = @SettingStatus,
		@ugroup = @ugroup,
		
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

END
GO
