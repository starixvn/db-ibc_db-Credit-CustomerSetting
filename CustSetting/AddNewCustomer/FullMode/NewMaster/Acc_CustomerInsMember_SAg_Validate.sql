/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROC Acc_CustomerInsMember_SAg_Validate
(
	@site			NVARCHAR(50)	
	,@creator		INT
	,@username		VARCHAR(30)
	,@srecommend	INT
	,@Language		VARCHAR(2)= 'E'
	,@credit		MONEY
	,@IP			VARCHAR(15)=''
	,@SettingStatus TINYINT = 0
	,@SettingXML	VARCHAR(MAX) = ''
	,@SystemID		TINYINT=1
	,@ErrCode			INT = 0		OUTPUT
	,@ErrMsg			NVARCHAR(2000) = '' OUTPUT
	,@MsgType			INT = 0			OUTPUT
) 
AS
/*
	Created: 20240704@Louisa
	Task : Validate create Master full mode
	DB: DBCUST/CustDB

	Revision:
		- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]
		- 20241216@Johnson: Change to use ProductSettingProfile [RedmineID: #212684]	
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]   
	Param's Explanation:
	- @ErrCode:
		= 0: super create master successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT
	- @SettingXML: Json format
	'{
		"150": [
			{"SportType": "1","BetType": "1","Discount": "0.0010000"},
			{"SportType": "1","BetType": "3","Discount": "0.0015000"},
			{"SportType": "1","BetType": "5","Discount": "0.0030000"},
			{"SportType": "1","BetType": "7","Discount": "0.0020000"},
			{"SportType": "1","BetType": "4","Discount": "0.0035000"},
			{"SportType": "1","BetType": "8","Discount": "0.0025000"}
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
			{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"},
			{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0"}
		]
	}'

*/
BEGIN
	DECLARE @FromTime	VARCHAR(30)
			,@ToTime	VARCHAR(30)
			,@Credit_AllOtherDownline MONEY
			,@Credit_SAg	MONEY
			,@SettingType25	VARCHAR(MAX)= ''
			,@SettingType26	VARCHAR(MAX)= ''
			,@SettingType27	VARCHAR(MAX)= ''
			,@SettingType28	VARCHAR(MAX)= ''

	DECLARE @Super_site VARCHAR(50), @currency INT, @EnableVR BIT
	DECLARE @uplineUsername NVARCHAR(50)

	SELECT @Super_site = site,
		@currency = currency,
		@uplineUsername = username
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @srecommend
	 
	SET  @Site = ISNULL(NULLIF(@Site,''),@Super_site)

	DECLARE @SiteID int
	SELECT @SiteID = siteid FROM site WITH(NOLOCK) WHERE site = @site

	----CHECK UM
	CREATE TABLE #UMConfig(SportType SMALLINT,SiteID INT, Currency INT ,BeginTime smalldatetime,EndTime smalldatetime)
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
							FROM ProductSettingProfile p WITH(NOLOCK) 
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

	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END

	EXEC Acc_CustomerLimitCreatedAccountCheck
		@Custid				= @srecommend , 
		@RuleID				= 'SAG' , 
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
	IF @creator = @srecommend
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
		
    --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @srecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    BEGIN
		IF @ErrCode <>0		
		RETURN 
	END


	 -- get site FROM upline IF not direct master
    IF @srecommend > 100 
    BEGIN
        SELECT @site = @Super_site
        SELECT @SiteID = siteid FROM site WITH(NOLOCK) WHERE site = @site
    END

    DECLARE @IsValid BIT
    SELECT @IsValid = 0
    SELECT @ErrCode = 0
    
     -- MyanmarOdds
    DECLARE @IsMyanmarOdds BIT = 0
    
    SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)

    IF @IsMyanmarOdds = 1 AND dbo.fn_IsMyanmarOdds (@srecommend) <> 1
    BEGIN
         SELECT @ErrMsg = CASE @Language
                            WHEN 'E' THEN 'Cannot add Direct Master under Myanmar Odds site(s).'
                            END, @ErrCode = 361
        RETURN  
    END

    IF @site = 'IBCIndo' AND @Super_site <> 'IBCIndo'
    BEGIN
         SELECT @ErrMsg = CASE @Language
                            WHEN 'E' THEN 'Cannot add Direct Master under IBCIndo site.'
                            END, @ErrCode = 361
        RETURN  
    END
        
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SELECT 	    
	    @Credit_SAg = isnull(credit, 0)
    FROM CustInfo ci WITH(NOLOCK)
    WHERE CustID = @srecommend	

    SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
	FROM custinfo WITH(NOLOCK) 
	WHERE SRecommend = @srecommend 
		AND (RoleID = 3  --Masters
				OR (roleid = 1 AND recommend = -4) --Super direct members
			)
    
    IF @Credit_AllOtherDownline + @Credit > @Credit_SAg AND @srecommend>100
    BEGIN
	    SET @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@Credit_SAg - @Credit_AllOtherDownline, '#,#0.####'))
	    SELECT @ErrCode = 106
	    return
    END

    --Parse Json to XML param
    SELECT @SettingType25 = CONVERT(VARCHAR(MAX),
                (
                    SELECT SportType,BetType,Discount
                    FROM OPENJSON(@SettingXML,'$."150"') WITH (
                            SportType SMALLINT  '$.SportType'
                            ,BetType SMALLINT  '$.BetType'
                            ,Discount DECIMAL(9,8)  '$.Discount'
                        )
                    FOR XML RAW('R'), ROOT ('Root'), TYPE
                )
            )

    SELECT @SettingType26 = CONVERT(VARCHAR(MAX),
                (
                    SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout
                    FROM OPENJSON(@SettingXML,'$."151"') WITH (
                            SportType SMALLINT  '$.SportType'
                            ,BetType SMALLINT  '$.BetType'
                            ,MinBet MONEY  '$.MinBet'
                            ,MaxBet MONEY  '$.MaxBet'
                            ,MPM MONEY  '$.MPM'
                            ,MaxPayout MONEY  '$.MaxPayout'
                        )
                    FOR XML RAW('R'), ROOT ('Root'), TYPE
                )
            )

    SELECT @SettingType27 = CONVERT(VARCHAR(MAX),
                (
                    SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
                    FROM OPENJSON(@SettingXML,'$."152"') WITH (
                             SportType SMALLINT  '$.SportType'
                            ,BetType SMALLINT  '$.BetType'
                            ,SingleMP MONEY  '$.SingleMP'
                            ,Combo2 MONEY  '$.Combo2'
                            ,Combo35 MONEY  '$.Combo35'
                            ,Combo6 MONEY  '$.Combo6'
                        )
                    FOR XML RAW('R'), ROOT ('Root'), TYPE
                )
            )

    SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
                (
                    SELECT SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT
                    FROM OPENJSON(@SettingXML,'$."153"') WITH (
                            SportType SMALLINT  '$.SportType'
                            ,BetType SMALLINT  '$.BetType'
                            ,IsLive BIT  '$.IsLive'
                            ,SuperPT SMALLMONEY  '$.SuperPT'
                            ,IsAuto BIT  '$.IsAutoSuperPT'
                            ,AutoPT SMALLMONEY  '$.AutoSuperPT'
                            ,MasterPT SMALLMONEY  '$.MasterPT'
                            ,MinPT SMALLMONEY  '$.MinPT'
                        )
                    FOR XML RAW('R'), ROOT ('Root'), TYPE
                )
            )
    
    --check comm
    EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_SAg
        @srecommend = @srecommend,
        @siteID = @siteID,
        @currency = @currency,
        
        @SettingType25 = @SettingType25 OUTPUT, --SB
        @SettingStatus = @SettingStatus,
        
        @ErrCode = @ErrCode OUTPUT,
        @MsgType = @MsgType OUTPUT,
        @ErrMsg = @ErrMsg OUTPUT
    
    IF @ErrCode > 0
        RETURN;
        
    --Check bet setting
    EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg
        @srecommend = @srecommend,
        @siteID = @siteID,
        @currency = @currency,
        
        @SettingType26 = @SettingType26 OUTPUT, --SB
        @SystemID = @SystemID,
        @SettingStatus = @SettingStatus,
        
        @ErrCode = @ErrCode OUTPUT,
        @MsgType = @MsgType OUTPUT,
        @ErrMsg  = @ErrMsg OUTPUT   

    IF @ErrCode > 0 
        RETURN;
        
    --Check Parlay Max Payout
    EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_SAg
        @srecommend = @srecommend,
        @siteID = @siteID,
        @currency = @currency,
        
        @SettingType27 = @SettingType27 OUTPUT, --SB
        @SettingStatus = @SettingStatus,
        
        @ErrCode = @ErrCode OUTPUT,
        @MsgType = @MsgType OUTPUT,
        @ErrMsg  = @ErrMsg OUTPUT   

    IF @ErrCode > 0 
        RETURN; 
        
    --Check PT
    EXEC Acc_LiteMode_CustomerInsMember_PTCheck_SAg
        @srecommend = @srecommend,
        @siteID = @siteID,
        @currency = @currency,
        
        @SettingType28 = @SettingType28 OUTPUT,-- SB
        @SettingStatus = @SettingStatus,
        
        @ErrCode = @ErrCode OUTPUT,
        @MsgType = @MsgType OUTPUT,
        @ErrMsg  = @ErrMsg OUTPUT   

    IF @ErrCode > 0 
        RETURN;   
		
	DROP TABLE #UMConfig
    
END