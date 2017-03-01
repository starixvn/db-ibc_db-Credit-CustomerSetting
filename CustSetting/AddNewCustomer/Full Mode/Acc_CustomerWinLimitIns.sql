USE CustDB
GO
ALTER PROCEDURE dbo.Acc_CustomerWinLimitIns @CustId INT
	, @UplineId INT
	, @IP VARCHAR(50) = ''
	, @UserId INT = 0
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*  
  Created: 20151223@Patrick  
  Task: Add new member to CustWinlimit
  DB: DBCUST/CustDB  
    
  Revisions:  
  Parameters Explanation:    
	@UplineId is uplineid or existing custid
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSPData VARCHAR(MAX)
	SET @StartRun = GETDATE()

	IF @UplineId IS NULL --super level
	BEGIN
		DECLARE @CurrencyId INT, @DefaultMaxLossLimit MONEY
		SELECT @CurrencyId = Currency FROM dbo.CustInfo WITH(NOLOCK) WHERE CustId = @CustId

		SELECT @DefaultMaxLossLimit = DefaultLossLimit
		FROM dbo.LossLimit_GlobalSetting WITH(NOLOCK) WHERE ExchangeId = @CurrencyId

		--insert default value fro super level
		INSERT INTO dbo.CustWinLimit(CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit)
		(
			--GoldDeluxe
			SELECT @CustId AS CustId, 255 AS SportType, 1701 AS BetType, 0 AS MaxWinLimit, 1 AS IsAutoReset, 0 AS MaxLossLimit
		
			UNION ALL

			--RnG Casino
			SELECT @CustId AS CustId, 208 AS SportType, 2101 AS BetType, 0 AS MaxWinLimit, 1 AS IsAutoReset, @DefaultMaxLossLimit AS MaxLossLimit
		)
	END
	ELSE
	BEGIN
		--insert default value from upline
		INSERT INTO dbo.CustWinLimit(CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit)
		(
			--GoldDeluxe
			SELECT @CustId AS CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit
			FROM dbo.CustWinLimit WITH(NOLOCK)
			WHERE CustId = @UplineId AND SportType = 255 AND BetType = 1701
		
			UNION ALL

			--RnG Casino
			SELECT @CustId AS CustId, SportType, BetType, MaxWinLimit, IsAutoReset, MaxLossLimit
			FROM dbo.CustWinLimit WITH(NOLOCK)
			WHERE CustId = @UplineId AND SportType = 208 AND BetType = 2101
		)
	END

	IF @@ERROR <> 0
	BEGIN
		DELETE FROM dbo.CustWinLimit WITH(ROWLOCK)
		WHERE CustId = @CustId

		SELECT @ErrCode = 659, @ErrMsg = 'Failed to insert CustWinlimit data'
		RETURN
	END

    SELECT @endRun = GETDATE(), @duration  = DATEDIFF(MILLISECOND, @startRun, @endRun)

	DECLARE @TempTable TABLE(RowIndex INT IDENTITY(1,1), SportType SMALLINT, BetType SMALLINT)
	INSERT INTO @TempTable(SportType, BetType)
	VALUES(255, 1701), (208, 2101)

	DECLARE @RowIndex INT, @SportType SMALLINT, @BetType SMALLINT
	SET @RowIndex = 1

	WHILE EXISTS (SELECT TOP 1 1 FROM @TempTable WHERE RowIndex = @RowIndex)
	BEGIN
		SELECT @SportType = SportType, @BetType = BetType
		FROM @TempTable WHERE RowIndex = @RowIndex

		SELECT @RowIndex = @RowIndex + 1, @LogSPData = ''

		SELECT @LogSPData = '<Acc_CustomerWinLimitIns CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'MaxWinLimit' + '=' + '"' + CASE WHEN MaxWinlimit = 0 THEN 'Unlimited'
					ELSE CASE WHEN MaxWinlimit - FLOOR(MaxWinlimit) > 0 
						THEN COALESCE(CAST(MaxWinlimit AS VARCHAR(50)), SPACE(1)) + 'X'
						ELSE COALESCE(CAST(CAST(MaxWinlimit AS INT) AS VARCHAR(50)), SPACE(1)) + 'X' END
					END + '"' + SPACE(1)
			+ CASE WHEN @SportType = 208 THEN 'MaxLossLimit' + '=' + '"' + CAST(ISNULL(MaxLossLimit, 0) AS VARCHAR(50)) + '"' + SPACE(1) ELSE '' END
			+ 'IsAutoReset' + '=' + '"' + CAST(IsAutoReset AS VARCHAR(1)) + '"' + SPACE(1)
			+ 'SportType' + '=' + '"' + CAST(SportType AS VARCHAR(10)) + '"' + SPACE(1) 
			--+ 'BetType' + '=' + '"' + CAST(BetType AS VARCHAR(10)) + '"' + SPACE(1) 
			+ 'UserId="' + COALESCE(CAST(@UserId AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'IP="' + COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(500)), SPACE(1)) + '" />'
		FROM dbo.CustWinLimit WITH(NOLOCK)
		WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType

		 BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @UserId,
				@CustID = @CustID,
				@ActionID = 659,
				@TrackingValue = @LogSPData,
				@duration = @duration
		END TRY
		BEGIN CATCH
			SELECT @LogSPData = '<Acc_CustomerWinLimitIns CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1)) + '" ' 
				+ 'MaxWinLimit' + '=' + '"' + CASE WHEN MaxWinlimit = 0 THEN 'Unlimited'
					ELSE CASE WHEN MaxWinlimit - FLOOR(MaxWinlimit) > 0 
						THEN COALESCE(CAST(MaxWinlimit AS VARCHAR(50)), SPACE(1)) + 'X'
						ELSE COALESCE(CAST(CAST(MaxWinlimit AS INT) AS VARCHAR(50)), SPACE(1)) + 'X' END
					END + '"' + SPACE(1)
				+ CASE WHEN @SportType = 208 THEN 'MaxLossLimit' + '=' + '"' + CAST(ISNULL(MaxLossLimit, 0) AS VARCHAR(50)) + '"' + SPACE(1) ELSE '' END
				+ 'IsAutoReset' + '=' + '"' + CAST(IsAutoReset AS VARCHAR(1)) + '"' + SPACE(1)
				+ 'SportType' + '=' + '"' + CAST(SportType AS VARCHAR(10)) + '"' + SPACE(1) 
				--+ 'BetType' + '=' + '"' + CAST(BetType AS VARCHAR(10)) + '"' + SPACE(1) 
				+ 'UserId="' + COALESCE(CAST(@UserId AS VARCHAR(50)), SPACE(1)) + '" ' 
				+ 'IP="' + COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1)) + '" ' 
				+ 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' 
				+ 'ErrMsg="' + COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(500)), SPACE(1)) + '" />'
			FROM dbo.CustWinLimit WITH(NOLOCK)
			WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @UserId,
				@CustID = @CustId,
				@ActionID = 659,
				@TrackingValue = @LogSPData,
				@duration = @duration
		END CATCH

	END
	

END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitIns] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitIns] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitIns] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerWinLimitIns] TO [vnteam] AS [dbo]
GO
