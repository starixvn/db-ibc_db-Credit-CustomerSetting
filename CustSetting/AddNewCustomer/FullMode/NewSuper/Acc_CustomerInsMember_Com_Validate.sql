/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROC Acc_CustomerInsMember_Com_Validate
(
	@currency		INT,		
	@site			NVARCHAR(50),	
	@creator		INT,
	@username		VARCHAR(30),
	@Language		VARCHAR(2)= 'E',
	@credit			MONEY,
	@SettingStatus	TINYINT = 0,
	@SettingXML		VARCHAR(MAX) = '',
	@ErrCode		INT = 0			OUTPUT,
	@ErrMsg			NVARCHAR(2000) = '' OUTPUT,
	@MsgType		INT = 0			OUTPUT
) 
AS
/*
	Created: 20240704@Louisa
	Task : Validate COmpany create Super full Mode
	DB: DBCUST/CustDB

	Revision:
		- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]

	Param's Explanation:
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT
	- @SettingXML: Json format
	'{
		"150": [
			{"SportType": "1","BetType": "1","Discount": "0.0010000"},
			{"SportType": "1","BetType": "3","Discount": "0.0015000"},
			{"SportType": "1","BetType": "5","Discount": "0.0070000"},
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
			{"SportType": "9914","BetType": "915","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "917","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "917","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9915","BetType": "918","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "915","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "916","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "916","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"}
		]
	}'
*/
BEGIN
	DECLARE @SiteID		INT
			,@SiteLabel VARCHAR(50)
			,@FromTime	VARCHAR(30)
			,@ToTime	VARCHAR(30)
			,@SettingType25	VARCHAR(MAX)= ''
			,@SettingType26	VARCHAR(MAX)= ''
			,@SettingType27	VARCHAR(MAX)= ''
			,@SettingType28	VARCHAR(MAX)= ''

	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpExchange TABLE (exchangeID INT, Currency NVARCHAR(50), OfferSite TINYINT)

	SELECT @SiteID = siteid
			, @SiteLabel=SiteLabel
	FROM site WITH(NOLOCK)
	WHERE site = @site

	----CHECK UM
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
		AND t.SuperID = 0

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

	IF @SiteLabel  = '789y'	
	BEGIN
		IF EXISTS(SELECT 1 FROM Acc_SuperPrefix WITH(NOLOCK)
			WHERE GroupName IN ('ACCUT','ACCYEN789','ACCYEN889','ACCTEST')
				AND Prefix = LEFT(@username,2)
				AND AllowNewSuper = 0
			)
		BEGIN
			SELECT @ErrMsg =  'The selected username prefix is not allowed for new supers anymore.',
				@ErrCode = 205
			RETURN		
		END	
	END

	IF NOT EXISTS(SELECT 1 FROM Exchange (NOLOCK) WHERE ExchangeID = @Currency)
	BEGIN
		SELECT @ErrCode = 5
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Invalid currency.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40015,@Language)
							END
		RETURN
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
					SELECT SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT,MinPT
					FROM OPENJSON(@SettingXML,'$."153"') WITH (
							 SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,IsLive BIT  '$.IsLive'
							,SuperPT SMALLMONEY  '$.SuperPT'
							,MasterPT SMALLMONEY  '$.MasterPT'
							,AgentPT SMALLMONEY  '$.AgentPT'
							,MinPT SMALLMONEY  '$.MinPT'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	--check comm
	EXEC Acc_CustomerInsMember_DiscountCheck_Com
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
	EXEC Acc_CustomerInsMember_BetSettingCheck_Com
		@siteID = @siteID,
		@currency = @currency,
		@SettingType26 = @SettingType26 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;
		
	--Check Parlay Max Payout
	EXEC Acc_CustomerInsMember_ParlayMaxPayoutCheck_Com
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
	EXEC Acc_CustomerInsMember_PTCheck_Com
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