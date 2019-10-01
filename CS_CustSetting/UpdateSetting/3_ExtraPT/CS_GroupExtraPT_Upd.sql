/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[CS_GroupExtraPT_Upd]
	@CustID				INT,
	@ExtraPTSetting		VARCHAR(MAX),	
	@EffectiveDate 		DATE, 	
	@UserID				INT,
	@IP					VARCHAR(15)='',
	@ErrCode			INT = 0 OUTPUT,
	@ErrMsg				NVARCHAR(1000) = '' OUTPUT
AS

/*
	Creator: 20190620@Sophia	
	Task: CN88 - Edit ExtraPT Setting For Super 
	DB: DBCUST.CustDB 
	
	Revisions:
		- 20190620@Sophia: initial SP[RedmineID: #114912]
		- 20190926@Percy: Change log's format [Redmine: #118962]
		 
	Original: Acc_GroupExtraPTSetting_Upd
	Param's Explanation:
		- @EffectiveDate		
			
		- @ExtraPTSetting:	<ROOT>
								<ExtraPT ProductId="1" ExtraPT="0.02"/>
								<ExtraPT ProductId="3" ExtraPT="0.03"/>
							</ROOT>	
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
	SELECT  @startRun = GETDATE()

	DECLARE @TrackingValue2 NVARCHAR(MAX), @TrackingValue NVARCHAR(MAX)
			,@TrackingValue2_XML XML, @TrackingValue_XML XML
	
	DECLARE @today DATETIME, @EndDate DATETIME, @FromDate DATETIME
	SELECT  @today = CONVERT(DATE, GETDATE()), @EndDate = '9999-12-31'
	DECLARE @GroupId INT, @GroupName VARCHAR(50), @HeadlineId INT,  @HeadlineUsername	VARCHAR(30)			

	DECLARE @ExtraPTTmp	TABLE(ProductId INT, ExtraPT MONEY) 	
		
	IF @EffectiveDate < @today
	BEGIN			 
		SELECT
			@ErrCode = 100,
			@ErrMsg = N'Invalid effective date.'
		RETURN		 
	END	
	
	IF EXISTS (SELECT 1 FROM dbo.CustInfo WITH (NOLOCK) WHERE srecommend = @CustID and RoleID = 1) AND @EffectiveDate = @today
	BEGIN 
		SELECT
			@ErrCode = 101,
			@ErrMsg = N'This account has members already, new effective date cannot be today.'
		RETURN	
	
	END
	
		
	-- get Rate
	DECLARE @DocHandler INT
	BEGIN TRY
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @ExtraPTSetting
		
		INSERT INTO @ExtraPTTmp (ProductId, ExtraPT)
		SELECT ProductId, ExtraPT
		FROM OPENXML(@DocHandler, '/ROOT/ExtraPT', 1) WITH (ProductId INT, ExtraPT MONEY) AS Data

		EXEC sp_xml_removedocument @DocHandler
	END TRY
	BEGIN CATCH
		SELECT ErrCode = 102
			,ErrMsg = N'Paramter invalid.'
		RETURN
		
	END CATCH;
	
	--- get group extraPT			
	SELECT @GroupName = GroupName, @GroupId = GroupId
	FROM dbo.Acc_GroupExtraPT_Product a WITH (NOLOCK) 
		INNER JOIN @ExtraPTTmp e 
			ON  e.ProductID = a.ProductID
				AND e.ExtraPT = a.ExtraPT
	WHERE  	@today BETWEEN a.FromDate AND a.ToDate
			AND a.ProductID IN (1, 3)
			AND Sporttype = 0 AND SubProduct = ''
			AND GroupID BETWEEN 27 AND 42
	GROUP BY GroupName, GroupId
	HAVING COUNT(GroupId) = 2 
	
	IF @GroupName IS NULL OR @GroupID IS NULL
	BEGIN			 
		SELECT
			@ErrCode = 103,
			@ErrMsg = N'Invalid rates.'
		RETURN		 
	END
	 
	---- Check already existed		
	SELECT  @FromDate = MIN(FromDate) 
	FROM dbo.Acc_GroupExtraPTSetting WITH(NOLOCK)
	WHERE SuperId = @CustID 
		AND GroupId = @GroupId 
		AND @EffectiveDate BETWEEN FromDate AND ToDate 
		AND FromDate <= @today
	
	IF @FromDate IS NOT NULL
	BEGIN
		IF NOT EXISTS (
			SELECT TOP 1 1 FROM dbo.Acc_GroupExtraPTSetting WITH(NOLOCK)
			WHERE SuperId = @CustID 
				AND GroupId <> @GroupId
				AND FromDate > @today
		)
		BEGIN
			SELECT
				@ErrCode = 104,
				@ErrMsg = N'There is no change to be updated.'
			RETURN
		END
	END	
	
	---- Log before update
		
	SELECT @HeadlineId = UplineId
	FROM dbo.CustSuper WITH (NOLOCK) 
	WHERE CustID = @CustID	
	
	SELECT @HeadlineUsername = username FROM dbo.CustInfo WITH (NOLOCK) WHERE CustID = @HeadlineId AND roleid = 0

	SELECT @TrackingValue2_XML = (
			SELECT	@HeadlineId				AS '@HeadlineId'
					,@HeadlineUsername		AS '@Healine'
					,[Sportsbook Possess]	AS '@SportsbookPossess'
					,[Non-Sports Possess]	AS '@Non-SportsPossess'
					,EffectiveDate			AS '@EffectiveDate'
			FROM (
				SELECT
					CONVERT(VARCHAR(10), p.FromDate, 120) AS EffectiveDate
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.[Sportsbook Possess])) AS [Sportsbook Possess]
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.[Non-Sports Possess])) AS [Non-Sports Possess]
				FROM (
					SELECT CASE ProductId WHEN 1 THEN 'Sportsbook' ELSE 'Non-Sports' END + ' Possess' AS Product, ExtraPT, FromDate
					FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
					WHERE SuperId = @CustID
						AND ProductId IN (1, 3)
						AND Sporttype = 0 AND SubProduct = ''
						AND @Today BETWEEN FromDate AND ToDate
				) AS s
				PIVOT (
					MAX(ExtraPT)
					FOR Product IN ([Sportsbook Possess], [Non-Sports Possess])
				) AS p
			) AS t
			FOR XML PATH ('R'), TYPE
		)

	SELECT @TrackingValue2 = CONVERT(NVARCHAR(MAX), @TrackingValue2_XML)

	---- delete and update lated rows if any
	DELETE dbo.Acc_GroupExtraPTSetting WITH(ROWLOCK, UPDLOCK)
	WHERE SuperId = @CustID AND (FromDate > @Today OR FromDate >= @EffectiveDate)
		AND ToDate >= @today

	UPDATE dbo.Acc_GroupExtraPTSetting WITH(ROWLOCK, UPDLOCK)
	SET ToDate = DATEADD(DAY, -1, @EffectiveDate)
	WHERE SuperId = @CustID AND FromDate <= @EffectiveDate
		AND ToDate >= @today
	 
	----- Insert new setting PT		
	INSERT INTO dbo.Acc_GroupExtraPTSetting (SuperId, GroupId, GroupName, ProductId, Sporttype, SubProduct, ExtraPT, FromDate, ToDate)
	SELECT @CustId, @GroupId, @GroupName, ProductID, Sporttype, SubProduct, ExtraPT,
		CASE WHEN @EffectiveDate < FromDate THEN FromDate ELSE @EffectiveDate END AS FromDate,
		CASE WHEN @EndDate < ToDate THEN @EndDate ELSE ToDate END AS ToDate
	FROM dbo.Acc_GroupExtraPT_Product WITH(NOLOCK)
	WHERE GroupId = @GroupId
		  AND @EffectiveDate <= ToDate	
		  
	
	--- Log after update	
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)	
		  
	SELECT @TrackingValue_XML = (
			SELECT	@HeadlineId				AS '@HeadlineId'
					,@HeadlineUsername		AS '@Healine'
					,[Sportsbook Possess]	AS '@SportsbookPossess'
					,[Non-Sports Possess]	AS '@Non-SportsPossess'
					,EffectiveDate			AS '@EffectiveDate'
			FROM (
				SELECT
					CONVERT(VARCHAR(10), p.FromDate, 120) AS EffectiveDate
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.[Sportsbook Possess])) AS [Sportsbook Possess]
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.[Non-Sports Possess])) AS [Non-Sports Possess]
				FROM (
					SELECT CASE ProductId WHEN 1 THEN 'Sportsbook' ELSE 'Non-Sports' END + ' Possess' AS Product, ExtraPT, FromDate
					FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
					WHERE SuperId = @CustID
						AND ProductId IN (1, 3)
						AND Sporttype = 0 AND SubProduct = ''
						AND @Today BETWEEN FromDate AND ToDate
				) AS s
				PIVOT (
					MAX(ExtraPT)
					FOR Product IN ([Sportsbook Possess], [Non-Sports Possess])
				) AS p
			) AS t
			FOR XML PATH ('R'), TYPE
		)

	SELECT @TrackingValue = CONVERT(NVARCHAR(MAX), @TrackingValue_XML)

	EXEC CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 160009,
		@TrackingValue = @TrackingValue,
		@TrackingValue2 = @TrackingValue2,
		@Duration = @Duration
END
GO