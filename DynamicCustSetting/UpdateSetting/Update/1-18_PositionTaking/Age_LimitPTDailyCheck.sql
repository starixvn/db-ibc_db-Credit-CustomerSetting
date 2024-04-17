/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_LimitPTDailyCheck]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
	  @UpdatePT				VARCHAR(MAX),
	  @LastUpdated			DATE OUTPUT,
	  @isLimit				BIT = 0 OUTPUT,
	  @isCancel				BIT = 0 OUTPUT,
	  @SettingStatus		TINYINT = 0
AS
/*
		Task : NAP CM -  Limit Daily PT Update
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
			- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
			- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @srecommend INT,
			@mrecommend INT,
			@recommend	INT , 
			@Currency	TINYINT,
			@site		NVARCHAR(50),
			@SiteID		INT	,
			@roleActorid TINYINT = 5
	DECLARE @isTest BIT,@SQL NVARCHAR(100) = OBJECT_NAME(@@PROCID)

	IF  (@SQL like '%_xtest%' 
			OR  @SQL like '%_xpre%' 
			OR  @SQL like '%_uat1%'
			OR  @SQL like '%_uat2%'
			OR  @SQL like '%_uat3%'
			OR  @SQL like '%_uat4%')
	BEGIN
		SELECT @isTest = 1
	END
	ELSE
	BEGIN
		SELECT @isTest = 0
	END
	
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
	
	CREATE TABLE #TempLimit (ProductID TINYINT,	SportType SMALLINT,	BetType	SMALLINT,CustID INT,Currency TINYINT,SiteID INT,MaxCount TINYINT, SettingStatus TINYINT) 

	INSERT INTO #TempLimit(ProductID , SportType , BetType ,CustID ,Currency ,SiteID ,MaxCount , SettingStatus )  
	SELECT l.ProductID,b.SportType,b.BetType,l.CustID,l.Currency,l.SiteID,l.MaxCount , l.SettingStatus
	FROM LimitPTDailySetting l WITH(NOLOCK) 
	INNER JOIN #ProductSettingDetail_DailyCheck b  WITH(NOLOCK) ON l.ProductID = b.ProductID
	WHERE b.SportType IN (SELECT SportType FROM @tblPT)
	
	IF EXISTS( SELECT TOP 1 1 FROM #TempLimit t
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE  (Currency = @Currency OR Currency = 0)
							  AND (SiteID = @SiteID OR SiteID = 0) AND SettingStatus <= CASE WHEN @isTest = 1 THEN 1 ELSE 0 END
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
	END	
	
	DROP TABLE #TempLimit
	DROP TABLE #ProductSettingDetail_DailyCheck
END
GO
