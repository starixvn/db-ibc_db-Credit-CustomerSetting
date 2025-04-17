/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_LimitPTDailyCheck]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
	  @UpdatePT				VARCHAR(MAX),
	  @LastUpdated			DATE OUTPUT,
	  @isLimit				BIT = 0 OUTPUT,
	  @isCancel				BIT = 0 OUTPUT,
	  @SettingStatus			TINYINT = 0,
	  @ErrCode				INT = 0 OUTPUT,
        @MsgType				INT = 0 OUTPUT,
	  @ErrMsg				NVARCHAR(4000) = '' OUTPUT
AS
/*
		Task : NAP CM -  Limit Daily PT Update
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
			- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
			- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
			- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
			- 20250410@Johnson: change datatype for ExchangeID[redmine: #223630]
	*/
BEGIN
	SET NOCOUNT ON;

	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @UpdatePT OUTPUT
	
	DECLARE @srecommend INT,
			@mrecommend INT,
			@recommend	INT , 
			@Currency	INT,
			@site		NVARCHAR(50),
			@SiteID		INT	,
			@roleActorid TINYINT = 5
	
	SELECT	@roleActorid = roleid FROM Customer WITH(NOLOCK)	WHERE custid = @Actorid
	IF @roleActorid > 4 
	BEGIN
		RETURN
	END 
	
	SELECT	@srecommend = srecommend,
			@mrecommend = mrecommend,
			@recommend  = recommend,
			@Currency	= currency,
			@site		= Site
	FROM Customer WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT @SiteID = siteid FROM Site WITH(NOLOCK) WHERE site = @site
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT , 
				MaxCount		TINYINT
				)			
	
	-- For read xml 				
	INSERT INTO @tblPT(
				SportType,
				BetType
			)
	SELECT
		SportType,
		BetType
	FROM dbo.f_DCS_PT_XMLParse(@UpdatePT)	

	-- Exclude Sport/Product Non Offer PT Limit
	DELETE t FROM @tblPT AS t 
	CROSS APPLY (
				SELECT dbo.f_CustSetting_GetOfferPTLimit (t.SportType, t.BetType)
			) fn (IsOffer)
	WHERE fn.IsOffer = 0

	CREATE TABLE #ProductSettingDetail_DailyCheck(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_DailyCheck(SportType,BetType,SettingType,IsLive,ProductID)
	SELECT SportType,BetType,SettingType,IsLive,ProductID
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	
	CREATE TABLE #TempLimit (ProductID TINYINT,	SportType SMALLINT,	BetType	SMALLINT,CustID INT,Currency INT,SiteID INT,MaxCount TINYINT, SettingStatus TINYINT) 

	INSERT INTO #TempLimit(ProductID , SportType , BetType ,CustID ,Currency ,SiteID ,MaxCount , SettingStatus )  
	SELECT l.ProductID,b.SportType,b.BetType,l.CustID,l.Currency,l.SiteID,l.MaxCount , l.SettingStatus
	FROM LimitPTDailySetting l WITH(NOLOCK) 
	INNER JOIN #ProductSettingDetail_DailyCheck b  WITH(NOLOCK) ON l.ProductID = b.ProductID
	WHERE b.SportType IN (SELECT SportType FROM @tblPT)
	
	IF EXISTS( SELECT TOP 1 1 FROM #TempLimit t
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE  (Currency = @Currency OR Currency = 0)
							  AND (SiteID = @SiteID OR SiteID = 0) 
							  AND SettingStatus <= CASE WHEN @SettingStatus IN (1,3) THEN 3 ELSE 0 END
							  AND SettingStatus <> 2
							  AND (CustID = 0 OR  CustID IN (@srecommend,@mrecommend,@recommend)))
	BEGIN
		SET @isLimit = 1
		
		UPDATE t
		SET t.MaxCount = KQ.MaxCount
		FROM @tblPT T
		CROSS APPLY (
						SELECT MIN(MaxCount) AS MaxCount
						FROM #TempLimit
						WHERE t.SportType = SportType AND t.BetType = BetType AND
							  (Currency = @Currency OR Currency = 0)
							  AND (SiteID = @SiteID OR SiteID = 0)
							  AND (CustID = 0 OR  CustID IN (@srecommend,@mrecommend,@recommend))
					) KQ
	END	
	
	DECLARE @ErrInfo	XML


	IF EXISTS( SELECT TOP 1 1 FROM CustLimitPTSetting t WITH(NOLOCK) 
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE  t.CustID = @custid AND ActorID = @Actorid AND PTCount >= p.MaxCount
							  AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS DATE))
	BEGIN
		SET @isCancel = 1

		SELECT @LastUpdated = ISNULL((SELECT MAX(LastUpdated) FROM CustLimitPTSetting t WITH(NOLOCK) 
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE  t.CustID = @custid AND ActorID = @Actorid AND PTCount >= p.MaxCount
							  AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS DATE)), GETDATE())
		SELECT @LastUpdated  = DATEADD(DAY,30,@LastUpdated)


		SELECT @ErrInfo = (
						SELECT DISTINCT p.SportType , p.BetType
						FROM CustLimitPTSetting t WITH(NOLOCK) 
						INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
						WHERE  t.CustID = @custid AND ActorID = @Actorid AND PTCount >= p.MaxCount
						AND DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS DATE)
						FOR XML RAW('Row'), TYPE
					)
	END	
	
	IF @ErrInfo IS NOT NULL
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="10078" Msg="'+ CAST (@LastUpdated AS VARCHAR(10)) +'"> ' + CONVERT(VARCHAR(MAX),@ErrInfo) + '</Root>'
			, @ErrCode = 10078
			, @MsgType = 6   
	END

	DROP TABLE #TempLimit
	DROP TABLE #ProductSettingDetail_DailyCheck
END
GO
