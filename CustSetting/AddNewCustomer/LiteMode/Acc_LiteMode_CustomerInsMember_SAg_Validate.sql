/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_SAg_Validate]
(	
	@SettingXML		VARCHAR(MAX) = ''
	,@site			VARCHAR(50) = ''
	,@srecommend	INT
	,@Language		VARCHAR(2)= 'E'
	,@credit		MONEY
	,@creator		INT
	,@IP			VARCHAR(15)=''
	,@username		VARCHAR(30)
	,@SettingStatus TINYINT = 0
	,@SystemID		TINYINT=1

	,@ErrCode		INT = 0 OUTPUT
	,@MsgType		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT
)
AS
/*
	Created: 20240704@Louisa
	Task : Validate Master Create Agent Full Mode
	DB: DBCUST/CustDB

	Revision:
		- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]
		- 20241220@Johnson: Change to use ProductSettingProfile [RedmineID: #212684]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE
		--Discount	
		@SettingType25 VARCHAR(MAX)= '' --SB
		,@SettingType19 VARCHAR(MAX)= ''--LCS
		,@SettingType3 VARCHAR(MAX)= '' --Others Games
		--Bet Setting
		,@SettingType26 VARCHAR(MAX)= '' --SB
		,@SettingType2 VARCHAR(MAX)= '' --SB2
		,@SettingType23 VARCHAR(MAX)= '' --RNG Games
		,@SettingType16 VARCHAR(MAX)= '' --Others Games
		--Parlay Max Payout
		,@SettingType27 VARCHAR(MAX)= '' --SB Parlay Max Payout
		--PT
		,@SettingType28 VARCHAR(MAX)= ''-- SB
		,@SettingType1 VARCHAR(MAX)= ''-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot)
		,@SettingType18 VARCHAR(MAX)= '' -- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)

		,@Super_site VARCHAR(50)
		,@SiteID int
		,@currency INT
		,@uplineUsername NVARCHAR(50)
		,@Credit_AllOtherMaster MONEY
		,@Credit_SAg MONEY
		,@IsMyanmarOdds BIT = 0

	DECLARE @Comm_Tbl TABLE
	(	 SportType SMALLINT  
		,BetType SMALLINT  
		,Discount DECIMAL(9,8)
		,SettingType SMALLINT
		,GroupType TINYINT
	)
	DECLARE @BetSetting_Tbl TABLE
	(
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

	DECLARE @Parlay_MaxPayout_Tbl TABLE
	(
		 SportType SMALLINT
		,BetType SMALLINT  
		,SingleMP MONEY
		,Combo2 MONEY 
		,Combo35 MONEY
		,Combo6 MONEY 
		,SettingType SMALLINT
		,GroupType TINYINT
	)

	DECLARE @PT_Tbl TABLE
	(
		SportType SMALLINT  
		,BetType SMALLINT  
		,IsLive BIT 
		,SuperPT SMALLMONEY 
		,IsAuto BIT 
		,AutoPT SMALLMONEY  
		,MasterPT SMALLMONEY
		,MinPT SMALLMONEY 
		,SettingType SMALLINT
		,GroupType TINYINT
	)

	SELECT @Super_site = site
			,@currency = currency
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @srecommend

	SET  @Site = ISNULL(NULLIF(@Site,''),@Super_site)

	-----BEGIN: CHECK UM ------------------------
	BEGIN
		DROP TABLE IF EXISTS #UMConfig
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
			DECLARE @FromTime VARCHAR(30), @ToTime VARCHAR(30)
		
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
	END
	-----/END CHECK UM

	----CHECK CREDIT NEGATIVE
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
    EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid = @srecommend
		,@ErrCode=@ErrCode output
		,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0	
	RETURN 

	SELECT @Credit_SAg = isnull(credit, 0)
	FROM CustInfo ci WITH(NOLOCK)
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
							,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
					FROM dbo.CustProductStatus  WITH(NOLOCK)
					WHERE CustID = ci.custid
					) AS cs	
    WHERE CustID = @srecommend

	-- get site FROM upline IF not direct master
	IF @srecommend > 100 
	BEGIN
	    SELECT @site = @Super_site
		SELECT @SiteID = siteid FROM site WITH(NOLOCK) WHERE site = @site
	END

	-- MyanmarOdds	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)
	IF @IsMyanmarOdds = 1 AND dbo.fn_IsMyanmarOdds (@srecommend) <> 1
	BEGIN
		 SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Cannot add Direct Master under Myanmar Odds site(s).'
						    END, @ErrCode = 361
	    RETURN	
	END
	-- /END MyanmarOdds	

	IF @site = 'IBCIndo' AND @Super_site <> 'IBCIndo'
	BEGIN
		 SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Cannot add Direct Master under IBCIndo site.'
						    END, @ErrCode = 361
	    RETURN	
	END

	SELECT @Credit_AllOtherMaster = isnull(sum(credit), 0) FROM custinfo AS ci WITH(NOLOCK) WHERE srecommend = @srecommend AND RoleID = 3
    IF @Credit_AllOtherMaster + @Credit > @Credit_SAg AND @srecommend>100
    BEGIN
	    SET @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@Credit_SAg - @Credit_AllOtherMaster, '#,#0.####'))
	    SELECT @ErrCode = 106
	    return
    END

	--Parse Json
	INSERT INTO @Comm_Tbl(GroupType,SportType,BetType,Discount)
	SELECT 150 AS GroupType,SportType,BetType,Discount
	FROM OPENJSON(@SettingXML,'$."150"') 
	WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,Discount DECIMAL(9,8)  '$.Discount'
		)
	UNION ALL
	SELECT 156 AS GroupType,SportType,BetType,Discount
	FROM OPENJSON(@SettingXML,'$."156"') 
	WITH (
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
	
	INSERT INTO @PT_Tbl(GroupType,SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT)
	SELECT 153 AS GroupType,SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT
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
					SELECT SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 28
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType1 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 1
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType18 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,SuperPT,IsAuto,AutoPT,MasterPT,MinPT
					FROM @PT_Tbl
					WHERE SettingType = 18
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_SAg
		@srecommend = @srecommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingType19 = @SettingType19 OUTPUT, --LCS
		@SettingType3  = @SettingType3 OUTPUT, --Others Games
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
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_SAg
		@srecommend = @srecommend,
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
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_SAg
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
	
	DROP TABLE #UMConfig

END
GO