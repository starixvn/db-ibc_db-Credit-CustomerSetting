/*<info serverAlias="DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Age_LimitPTDailyCheck]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
	  @UpdatePT				VARCHAR(MAX),
	  @isLimit				BIT = 0 OUTPUT,
	  @isCancel				BIT = 0 OUTPUT
AS
/*
		Task : NAP CM -  Limit Daily PT Update
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
	*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @srecommend INT,
			@mrecommend INT,
			@recommend	INT , 
			@Currency	TINYINT,
			@site		varchar(10),
			@SiteID		INT	

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
	
	CREATE TABLE #TempLimit (ProductID TINYINT,	SportType SMALLINT,	BetType	SMALLINT,CustID INT,Currency TINYINT,SiteID INT,MaxCount TINYINT) 
	SELECT l.ProductID,b.SportType,b.BetType,l.CustID,l.Currency,l.SiteID,l.MaxCount 
	FROM LimitPTDailySetting l WITH(NOLOCK) 
	INNER JOIN ProductSettingDetail b  WITH(NOLOCK) ON l.ProductID = b.ProductID
	WHERE b.SportType IN (SELECT SportType FROM @tblPT)
	
	IF EXISTS( SELECT TOP 1 1 FROM #TempLimit t
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE  (Currency = @Currency OR Currency = 0)
							  AND (SiteID = @SiteID OR SiteID = 0)
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
							  AND CAST(LastUpdated AS  DATE) = CAST(DATEADD(HOUR,4,GETDATE()) AS  DATE) )
	BEGIN
		SET @isCancel = 1
	END	
	
	DROP TABLE #TempLimit
END
GO
