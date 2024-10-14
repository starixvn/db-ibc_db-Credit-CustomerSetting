/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
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

	@SettingXML VARCHAR(MAX) = '',
	@TemplateName NVARCHAR(50) = '',
	--Log all values group from UI
	@SettingTypeAll NVARCHAR(MAX) = '',
	
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
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20230717@Johnson  
	Task : Add new member from LiteMode
	DB:  DBCUST/CustDB  
	Original sp: Acc_CustomerInsMember_Ag 
	
	Revisions: 
		- 20230717@Johnson: initial sp [redmine: #179159]
		- 20231026@Johnson: Limit New Account Update PT for i7 [redmine: #196032]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240321@Luke: NAP - Virtual rate - For Direct account :Change default of VR Status for newly created accounts to "Follow upline" [Redmine: #202624]
		- 20240318@Eden: Unify Live RNG Casino [Redmine: #198960]
		- 20240607@Johnson: scale out DBCUST [redmine: #199915]
		- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
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
    IF @ErrCode <>0	RETURN 
	
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

	DECLARE @_Site VARCHAR(10), @EnableVR BIT, @siteID SMALLINT
	
	SELECT @_Site = c.site,
		@siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend	
				
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
		AND EXISTS( 
				SELECT 1 
				FROM dbo.Site WITH (NOLOCK)
				WHERE site = @site AND SiteLabel IN ('789y')
			)
				SET @EnableVR = 1	

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
	
	
    SELECT @pwdexpiry = DATEADD(dd, -1, GETDATE())
   
    --check suspended of Agent 
    IF @Asuspended =1
    BEGIN
	    set @suspended =1
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

    IF @ErrCode > 0
    BEGIN
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @roleid = 1
	    RETURN
    END		
	
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

		--Bet Setting
		--@SettingType26 = @SettingType26, --SB
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
    				
		    EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 1
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    RETURN
    END	
	
	EXEC dbo.Acc_Custsetting_LiteMode_3rdProductIns
		@custid = @custid,
		@SettingType23 = @SettingType23,
		@RoleID = 1,
		@siteID = @siteID,
		@currency = @currency,
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT

	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END

		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID ,@RoleID = 1
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID	
		RETURN
	END	
	
	EXEC Acc_LiteMode_CustSetting_SportsbookIns
		@custid = @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,	
		@recommend = @recommend,
		@roleid = 1,
		@siteID = @siteID,
		@currency = @currency,
		--Bet Setting
		@SettingType26 = @SettingType26, --SB
		
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT
	
	IF @ErrCode > 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
				    WHEN 'E' THEN 'Create customer fail. Please try again'
				    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
			    END
    				
		    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID ,@RoleID = 1

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
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @roleid = 1
	    RETURN
    END
	
	IF @SystemID IN (2,6,10) -- ALPHA,i7 Alpha, Chatbot
	BEGIN
		EXEC Age_LimitPTDailyIns @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
								when 'E' then 'Create member fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
							END
					, @ErrCode=216
				
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @roleid = 1
			RETURN
		END	
	END
	
	SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	
    Declare @LogSPData NVARCHAR(MAX)
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
	'TemplateName="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@TemplateName AS NVARCHAR(50)), SPACE(1))) + '" ' +
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
	DECLARE @LogDataSP2 VARCHAR(4000) = ''
	
	CREATE TABLE #tempSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT, GroupID TINYINT)
	CREATE TABLE #tempProductOfferStatus(custIsHidden BIT, Name VARCHAR(50))

	INSERT INTO #tempSportbettypeSetting(ProductID,SportType,Bettype,SettingType,GroupID)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	,GroupID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)
	WHERE SettingType IN (4,11,13,21)
		AND realProductID NOT IN (24,59)
	
	INSERT INTO #tempProductOfferStatus(custIsHidden, Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, REPLACE(REPLACE(MAX(p.ProductName), ' ', ''),'*','') 
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
		INNER JOIN DBPRO.bodb02.dbo.Products p WITH (NOLOCK)  ON p.ProductID = psd.ProductID
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) NOT IN (3)
	GROUP BY psd.ProductID

	INSERT INTO #tempProductOfferStatus(CustIsHidden,Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, 'GroupID' + CAST(psd.GroupID AS VARCHAR(10))
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) IN (3)
	GROUP BY psd.GroupID

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' + t.Name  + '="' + COALESCE(CAST(t.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM #tempProductOfferStatus t

	SELECT @LogDataSP2	= @LogDataSP2 
						+ 'Disable' + CAST(Sporttype AS VARCHAR) + '_' + CAST(Bettype AS VARCHAR)
						+ '="' + COALESCE(CAST(custIsDisable AS VARCHAR(1)), SPACE(1)) + '" '
	FROM (
		SELECT	psp.Sporttype,
				psp.Bettype,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, psp.bitmapOrder)) AS custIsDisable
		FROM		#tempSportbettypeSetting AS psd WITH(NOLOCK)
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
	
	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @recommend AND Type = 4)
		SET @VRAccumulatedBalance = 1

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
		[SettingLevel] [tinyint] ,
		[ProductID] [tinyint] ,	
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
			SettingLevel	TINYINT,
			ProductID 		TINYINT,
			GroupID			  TINYINT,
			Child_DisplayOrder  INT
			)

	DECLARE @tblPT28 TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			AgentPT			SMALLMONEY,
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
	FROM CustWinLossLimit_Member cs WITH(NOLOCK)
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
	FROM CustStakeLevel_Member cs WITH(NOLOCK)
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
						--WHERE sl.GameGroupID=0
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

	DECLARE @LogGT159_GID2 VARCHAR(MAX) = '',
			@LogGT159_GID3 VARCHAR(MAX) = ''

	IF EXISTS(SELECT 1 FROM @tblCustStakeLevel WHERE GroupID = 2 AND SettingType IN (8))
	BEGIN	
		SET  @LogGT159_GID2 = 
		 '<BetLimit GroupType="159">'
			+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
						FROM @tblCustStakeLevel
						WHERE GroupID = 2
							AND SettingType IN (8)
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
		+ '</BetLimit>'	
	END

	IF EXISTS(SELECT 1 FROM @tblCustStakeLevel WHERE GroupID = 3 AND SettingType IN (8))
	BEGIN	
		SET  @LogGT159_GID3 = 
		 '<BetLimit GroupType="159">'
			+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
						FROM @tblCustStakeLevel
						WHERE GroupID = 3
							AND SettingType IN (8)
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)),SPACE(1))
		+ '</BetLimit>'	
	END
	
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
		T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney')/100 AS AgentPT
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
									AgentPT,
									SettingLevel,
									ProductID	
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
									AgentPT,
									SettingLevel,
									ProductID
							FROM @tblPT28
							WHERE SportType = 99 AND Bettype = 9							
							FOR XML RAW('R')
							) as VARCHAR(max)), SPACE(1))--SB MixParlay mix sports
			+ '</PT>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType, 
								BetType, 
								IsLive,								
								AgentPT,
								SettingLevel,
								ProductID
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
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT,SettingLevel,ProductID
						FROM @tblPT18
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '<WinLossLimit GroupType="155">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset,SettingLevel,ProductID
							FROM @tblCustWinLossLimit
							WHERE GroupID = 2
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLossLimit>'		
			+ @LogGT159_GID2
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
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT,SettingLevel,ProductID
						FROM @tblPT18						
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
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
			+ @LogGT159_GID3
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
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT,SettingLevel,ProductID
						FROM @tblPT18
						WHERE GroupID = 4
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '<WinLossLimit GroupType="155">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset
								,SettingLevel,ProductID
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

	DROP TABLE #tempProductOfferStatus
	DROP TABLE #tempSportbettypeSetting
END		