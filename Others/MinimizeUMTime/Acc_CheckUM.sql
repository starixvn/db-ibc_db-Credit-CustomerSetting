/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CheckUM]
	@CustID	int ,
	@ProductID tinyint = NULL,
	@SportType smallint = NULL,
	@SettingType tinyint = NULL,
	@FunctionType tinyint = NULL,
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg	NVARCHAR(4000) = '' OUTPUT,
	@ReturnUMData BIT = 1 
AS
BEGIN
/*
Created: 20200629@Eden
Task :  Lock Update Customer setting for Credit customer
DB: DBCUST.CustDB
Revisions:	
	- 20200629@Eden: Minimize UM Time - Lock Update Customer setting [Redmine: #136464]
Param's Explanation:
	- @FunctionType : Affect funtion
		1. Edit
	- @ReturnUMData : 
		1 : Return table to show announcement
		0 : Return Error for lock action funtion SP
		
Examples : 
	DECLARE @ErrCode INT = 0, @ErrMsg	NVARCHAR(4000) = ''
	EXEC [Acc_CheckUM] @CustID = 1, @ProductID = 38, @SportType = 245, @SettingType = 1
		, @FunctionType = 1,@ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT SELECT @ErrCode, @ErrMsg
	EXEC [Acc_CheckUM] @CustID = 1, @ProductID = 1, @SportType = 0, @SettingType = 0
		, @FunctionType = 1 ,@ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT
		SELECT @ErrCode, @ErrMsg
	EXEC [Acc_CheckUM] @CustID = 1, @ProductID = 8, @SportType = 0, @SettingType = 0
		, @FunctionType = 1 ,@ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT ,@Language = 'CT'
		SELECT @ErrCode, @ErrMsg
	EXEC [Acc_CheckUM] @CustID = 1
*/


SET NOCOUNT ON	
	DECLARE @UMProduct TABLE(
		 ProductID    TINYINT, 
		 SportType    SMALLINT, 
		 SettingType  TINYINT, 
		 Functiontype TINYINT, 
		 BeginTime    SMALLDATETIME, 
		 EndTime      SMALLDATETIME, 
		 Time_Stamp   BINARY(8), 
		 Currency     INT, 
		 SiteID       INT
		);

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].UMConfig c WITH(NOLOCK) )
	BEGIN
		IF @ReturnUMData = 1
			SELECT ProductID
				,SportType
				,SettingType
				,Functiontype
				,BeginTime
				,EndTime
				,Time_Stamp 
			FROM @UMProduct
		RETURN
	END

	INSERT INTO @UMProduct(
		 ProductID
		,SportType
		,SettingType
		,Functiontype
		,BeginTime
		,EndTime
		,Time_Stamp
		,Currency
		,SiteID
	)
	SELECT c.ProductID, 
		   c.Sporttype, 
		   c.SettingType, 
		   c.FunctionType,
		   MIN(c.BeginTime) AS BeginTime, 
		   MAX(c.EndTime) AS EndTime, 
		   MAX(c.Time_Stamp) AS Time_Stamp,
		   MAX(c.Currency) AS Currency,
		   MAX(c.SiteID) AS SiteID
	FROM [dbo].f_CustSetting_SportUMByCust(@CustID) c
	WHERE c.SportType IN(ISNULL(@SportType, c.Sporttype), 0)
		AND c.SettingType IN(ISNULL(@SettingType, c.SettingType), 0)
		AND c.FunctionType = ISNULL(@FunctionType,c.FunctionType)
		AND c.ProductID IN(ISNULL(@ProductID, c.ProductID), 0)
	GROUP BY c.ProductID, 
			 c.Sporttype, 
			 c.SettingType,
			 c.FunctionType

	--Delete Non-offered Products
	DELETE ft
	FROM @UMProduct ft
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Sporttype = ft.SportType															
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder) Hd
	WHERE hd.value = 1

	DELETE ft
	FROM @UMProduct ft
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

	DECLARE @ErrorTemplate NVARCHAR(4000)
	DECLARE @FromTime VARCHAR(30), @ToTime VARCHAR(30), @ProductName VARCHAR(30) 

	SELECT @ErrMsg = ''

	IF EXISTS(SELECT 1 FROM @UMProduct)
		AND ISNULL(@SettingType,0) = 0 AND @ProductID IN(1,6,8,12) AND @FunctionType = 1 --edit
	BEGIN
		SELECT @FromTime = CONVERT(VARCHAR,MIN(t.BeginTime),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MIN(t.BeginTime),8),5)),
			@ToTime = CONVERT(VARCHAR,MAX(t.EndTime),103) + ' ' + LTRIM(LEFT(CONVERT(VARCHAR, MIN(t.EndTime),8),5))
		FROM @UMProduct t
		WHERE t.ProductID IN (@ProductID,0)

		SELECT @ProductName = p.ProductName FROM DBPRO.bodb02.dbo.Products p WITH(NOLOCK) WHERE p.ProductID = @ProductID

		IF @Language NOT IN  ('E', 'EN')
			SET @ProductName = '{0}' --web translate

		SELECT @ErrCode = 90014
		SELECT @ErrorTemplate = [dbo].[f_Get_MsgNamebyMsgID](90014,@Language)
		SELECT @ErrMsg =   REPLACE(REPLACE(REPLACE(@ErrorTemplate,'<Product>',@ProductName),'<FromTime>',@FromTime),'<ToTime>',@ToTime)
	END

	IF @ReturnUMData = 1
		SELECT ProductID
			,SportType
			,SettingType
			,Functiontype
			,BeginTime
			,EndTime
			,Time_Stamp 
		FROM @UMProduct
END
GO