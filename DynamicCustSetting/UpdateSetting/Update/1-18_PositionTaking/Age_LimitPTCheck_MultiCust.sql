/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_LimitPTCheck_MultiCust]
	-- Add the parameters for the stored procedure here
	  @actorId				INT, --userid
	  @custIdList			VARCHAR(MAX),
	  @updatePT				VARCHAR(MAX),
	  @settingStatus		TINYINT = 0,
	  @isLimit				BIT = 0 OUTPUT,	
	  @isCancel				BIT = 0 OUTPUT,
	  @LastUpdated			DATE OUTPUT,
	  @ErrCode				INT = 0 OUTPUT,
        @MsgType				INT = 0 OUTPUT,
	  @ErrMsg				NVARCHAR(4000) = '' OUTPUT
AS
/*
		Task : NAP CM - Limitation to update PT for new member
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20230620@Luke: Limitation to update PT for new member [Redmine: #188950]
			- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
	*/
BEGIN
	SET NOCOUNT ON;

	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @updatePT OUTPUT

	DECLARE @TblCust AS TABLE(
		custId INT,
		isCancel BIT
	)


	DECLARE @representCustId INT
	DECLARE @srecommend		INT,
			@mrecommend		INT,
			@recommend		INT , 
			@currency		TINYINT,
			@site			NVARCHAR(50),
			@siteId			INT,
			@roleActorid	TINYINT = 5

	SELECT	@roleActorid = roleid FROM Customer WITH(NOLOCK) WHERE custid = @actorId
	IF @roleActorid > 4
		RETURN

	INSERT INTO @TblCust(custId, isCancel)
	SELECT value, 0
	FROM string_split(@custIdList, ',')
	WHERE value <> ''

	SELECT TOP 1 @representCustId = custID
	FROM @TblCust
	
	SELECT @srecommend	= srecommend,
			@mrecommend = mrecommend,
			@recommend	= recommend,
			@currency	= currency,
			@site		= site
	FROM customer c WITH (NOLOCK)
	WHERE c.custid = @representCustId

	SELECT @SiteID = siteid FROM Site WITH(NOLOCK) WHERE site = @site

	DECLARE @TblPT AS TABLE(
		sportType	SMALLINT,
		betType		SMALLINT,
		maxCount	TINYINT
	)

	INSERT INTO @TblPT(sportType, betType)
	SELECT SportType, Bettype
	FROM dbo.f_DCS_PT_XMLParse(@UpdatePT)

	-- Exclude Sport/Product Non Offer PT Limit
	DELETE t FROM @TblPT AS t 
	CROSS APPLY (
				SELECT dbo.f_CustSetting_GetOfferPTLimit (t.SportType, t.BetType)
			) fn (IsOffer)
	WHERE fn.IsOffer = 0


	CREATE TABLE #ProductSettingDetail_Check(
		settingType SMALLINT,
		sportType	SMALLINT,
		betType		SMALLINT,
		isLive		BIT,
		productId	TINYINT
	PRIMARY KEY (settingType ASC, sportType ASC, betType ASC, islive ASC)
	)

	INSERT INTO #ProductSettingDetail_Check(settingType, sportType, betType, isLive, productId)
	SELECT SettingType, SportType, BetType, IsLive, ProductID 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	WHERE SettingType IN (1, 18)

	CREATE TABLE #TempLimit (ProductID TINYINT,	SportType SMALLINT,	BetType	SMALLINT,CustID INT,Currency TINYINT,SiteID INT,MaxCount TINYINT, SettingStatus TINYINT) 

	INSERT INTO #TempLimit(ProductID , SportType , BetType ,CustID ,Currency ,SiteID ,MaxCount , SettingStatus )  
	SELECT l.ProductID,b.SportType,b.BetType,l.CustID,l.Currency,l.SiteID,l.MaxCount , l.SettingStatus
	FROM LimitPTDailySetting l WITH(NOLOCK) 
	INNER JOIN #ProductSettingDetail_Check b  WITH(NOLOCK) ON l.ProductID = b.ProductID
	WHERE b.SportType IN (SELECT SportType FROM @tblPT)

	IF EXISTS(
		SELECT 1
		FROM #TempLimit t
			INNER JOIN @TblPT p ON t.SportType = p.sportType AND t.BetType = p.betType
		WHERE (t.Currency = @currency OR t.Currency = 0)
			AND (t.SiteID = @siteId OR t.SiteID = 0) 
			AND SettingStatus <= CASE WHEN @settingStatus IN (1,3) THEN 3 ELSE 0 END
			AND SettingStatus <> 2
			AND (t.CustID = 0 or t.CustID IN (@srecommend, @mrecommend, @recommend))
	)
	BEGIN
		SET @isLimit = 1

		UPDATE t
		SET t.MaxCount = KQ.MaxCount
		FROM @tblPT T
		CROSS APPLY(
			SELECT MIN(MaxCount) AS MaxCount
			FROM #TempLimit
			WHERE t.SportType = SportType AND t.BetType = BetType AND
					(Currency = @Currency OR Currency = 0)
					AND (SiteID = @SiteID OR SiteID = 0)
					AND (CustID = 0 OR  CustID IN (@srecommend,@mrecommend,@recommend))
		) KQ
	END

	DECLARE @ErrInfo	XML

	DECLARE @currentDate DATE = GETDATE()
	IF EXISTS(
		SELECT TOP 1 1
		FROM @TblCust c
			INNER JOIN CustLimitPTSetting t WITH(NOLOCK) ON t.CustID = c.custId
			INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
		WHERE ActorID = @Actorid AND t.PTCount >= p.MaxCount
			AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= @currentDate
	)
	BEGIN
		SET @isCancel = 1
		SELECT @LastUpdated = ISNULL((SELECT MAX(LastUpdated) FROM CustLimitPTSetting t WITH(NOLOCK) 
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
									INNER JOIN @TblCust c ON t.CustID = c.custId
								WHERE  ActorID = @Actorid AND PTCount >= p.maxCount
								AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS DATE)), GETDATE())
		SELECT @LastUpdated  = DATEADD(DAY,30,@LastUpdated)

		SELECT @ErrInfo = (
						SELECT DISTINCT p.SportType , p.BetType
						FROM @TblCust c
						INNER JOIN CustLimitPTSetting t WITH(NOLOCK) ON t.CustID = c.custId
						INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
						WHERE ActorID = @Actorid AND t.PTCount >= p.MaxCount
							AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= @currentDate
						FOR XML RAW('Row'), TYPE
					)
	END

	IF @ErrInfo IS NOT NULL
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="10078" Msg="'+ CAST (@LastUpdated AS VARCHAR(10)) +'"> ' + CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
			, @ErrCode = 10078
			, @MsgType = 6   
	END

	DROP TABLE #ProductSettingDetail_Check, #TempLimit
END	
