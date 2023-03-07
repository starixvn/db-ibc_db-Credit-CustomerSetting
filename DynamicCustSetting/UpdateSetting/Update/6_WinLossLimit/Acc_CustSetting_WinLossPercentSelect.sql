/*<info serverAlias="DBTXN-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustSetting_WinLossPercentSelect
	@CustId INT
	,@SportType SMALLINT
	,@BetType SMALLINT
AS
/*  
  Created: 20160108@Elodie
  Task: Calculate WinLosslimit percent by customer
  DB: DBTXN/bodb02
    
  Revisions:  
	- 20181004@Johnson: hotfix for member winloss limit with no given credit[Redmined: #102008]	
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
  Parameters Explanation: 
	WinPercent: -1: winloss setting is unlimited
				-2: N/A win/loss <> 0 and given credit = 0
 */
BEGIN
	SET NOCOUNT ON	
	DECLARE @Amount MONEY, @CreditAmount MONEY, @CreditBalance MONEY, @DebitBalance MONEY
	DECLARE @RealSportType SMALLINT, @RealBetType SMALLINT

	CREATE TABLE #TempResult (
		 SportType SMALLINT
		,BetType SMALLINT
		,MaxWinLimit money
		,MaxWinAmount money
		,MaxLossAmount money
		,CurrentAmount money
		,WinPercent money
		,LossPercent money
	)

	CREATE TABLE #tmpRealSport(SportType SMALLINT, BetType SMALLINT, IsFinished BIT DEFAULT 0)

	INSERT INTO #tmpRealSport(SportType,BetType)
	SELECT DISTINCT Sporttype, Bettype
	FROM DBACC.bodb02.dbo.SportBettypeSettingMatrix WITH(NOLOCK) 
	WHERE SporttypeRefWinlossLimit = @SportType 
		AND BettypeRefWinlossLimit = @BetType 
		AND isLicensee = 0 AND Site = 'ALL'

	IF NOT EXISTS( SELECT 1 FROM #tmpRealSport)
	BEGIN
		INSERT INTO #tmpRealSport(SportType,BetType)
		SELECT @SportType, @BetType
	END

	--Delete Non-offered Products
	DELETE ft
	FROM #tmpRealSport ft
		INNER JOIN DBACC.bodb02.dbo.ProductStatusProfile psp WITH (NOLOCK) 
			ON PSP.Sporttype = ft.SportType 
			AND psp.Bettype = CASE WHEN ft.BetType	= 1021 THEN 1024 ELSE ft.BetType END													
		INNER JOIN DBACC.bodb02.dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder) Hd
	WHERE hd.value = 1

	WHILE 1 = 1
	BEGIN
		--Reset value
		SELECT @Amount = NULL, @CreditAmount = NULL, @CreditBalance = NULL, @DebitBalance = NULL

		UPDATE TOP(1) t
		SET t.IsFinished = 1,
			@RealSportType = t.SportType,
			@RealBetType = t.BetType
		FROM #tmpRealSport t
		WHERE t.IsFinished = 0

		IF @@ROWCOUNT = 0
			BREAK

		SELECT @CreditBalance = SUM(ISNULL(Balance, 0))
		FROM dbo.BalanceCreditGame WITH (NOLOCK) 
		WHERE CustId = @CustId AND BetType = @RealBetType

		SELECT @DebitBalance = SUM(ISNULL(Balance, 0))
		FROM dbo.BalanceDebitGame WITH (NOLOCK) 
		WHERE CustId = @CustId AND BetType = @RealBetType

		IF @CreditBalance IS NULL
			SET @CreditBalance = 0

		IF @DebitBalance IS NULL
			SET @DebitBalance = 0

		SELECT @Amount = @CreditBalance - @DebitBalance

		SELECT @CreditAmount = ISNULL(credit, 0)
		FROM DBCUST.CustDB.dbo.CustInfo WITH(NOLOCK)
		WHERE CustId = @CustId

		INSERT INTO #TempResult(SportType,BetType,MaxWinLimit,MaxWinAmount,MaxLossAmount,CurrentAmount,WinPercent,LossPercent)
		SELECT @RealSportType
			, @RealBetType
			, MaxWinLimit
			, MaxWinLimit * @CreditAmount AS MaxWinAmount
			, MaxLossLimit AS MaxLossAmount
			, @Amount as CurrentAmount
			, CASE WHEN MaxWinLimit = 0 THEN -1 --unlimited
					WHEN @Amount > 0 AND @CreditAmount = 0 AND MaxWinLimit > 0 THEN -2--N/A
					WHEN @Amount > 0 AND @CreditAmount > 0 AND MaxWinLimit > 0 THEN @Amount * 100/(MaxWinLimit * @CreditAmount) 
					ELSE 0 END AS WinPercent
			, CASE WHEN MaxLossLimit = 0 THEN -1--unlimited				
					WHEN @Amount < 0 AND MaxLossLimit > 0 THEN @Amount * -100/MaxLossLimit
					ELSE 0 END AS LossPercent
		FROM DBCUST.CustDB.dbo.CustWinLossLimit_Member c WITH(NOLOCK)
		WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType
	END

	SELECT SportType,BetType,MaxWinLimit,MaxWinAmount,MaxLossAmount,CurrentAmount,WinPercent,LossPercent 
	FROM #TempResult
	ORDER BY SportType,BetType
END

GO