/*<info serverAlias="DBTXN-custdb" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustSetting_WinLossPercentSelect
	 @CustId INT
	,@SportType SMALLINT
	,@BetType SMALLINT
	,@SettingStatus TINYINT = 0
AS
/*  
  Created: 20160108@Elodie
  Task: Calculate WinLosslimit percent by customer
  DB: DBTXN/custdb
    
  Revisions:  
	- 20181004@Johnson: hotfix for member winloss limit with no given credit[Redmined: #102008]	
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20230731@Eden: Simplify Live Casino Customer Setting - move from bodb02 to custdb [Redmine: #189389]
	- 20230905@Eden: Enhance BBIN display [Redmine: #193539]
	- 20230928@Luke: Modify SPs to adapt in-house replication setup [Redmine: #194414]
	- 20231213@Tacy: Live Casino - Hide un-launched product from Member Win Loss Limit page [Redmine: #198317]

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

	CREATE TABLE #tmpRealSport(SportType SMALLINT, BetType SMALLINT, IsFinished BIT DEFAULT 0, ProductID TINYINT)

	DECLARE @Currency INT, @SiteID INT

	--Product Status
	SELECT	@SiteID = s.siteid,
			@Currency = c.currency
	FROM customer c WITH (NOLOCK)
	    INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site	
    WHERE c.custid = @custid

	INSERT INTO #tmpRealSport(SportType,BetType,ProductID)
	SELECT mt.SportType,mt.bettype,d.ProductId 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus) d 
		INNER JOIN dbo.SportBettypeSettingMatrix mt WITH(NOLOCK)
			ON d.SportType = mt.SporttypeRefWinlossLimit
			AND d.BetType = mt.BettypeRefWinlossLimit
			AND mt.isLicensee = 0 AND mt.Site = 'ALL' AND mt.isDeleted = 0
		INNER JOIN bodb02.dbo.Products p WITH (NOLOCK) ON p.ProductID=mt.RealProductId
	WHERE SettingType = 22
		AND d.SportType = @SportType
		AND d.BetType = @BetType
		AND p.Environment <= @SettingStatus

	IF NOT EXISTS( SELECT 1 FROM #tmpRealSport)
	BEGIN
		INSERT INTO #tmpRealSport(SportType,BetType)
		SELECT @SportType, @BetType
	END

	--Delete Non-offered Products
	DELETE ft
	FROM #tmpRealSport ft
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) 
			ON  CASE WHEN ft.ProductId = 41 THEN 9911 ELSE ft.SportType END = psp.Sporttype
			AND	CASE WHEN ft.BetType = 1021 THEN 1024 
					 WHEN ft.ProductId = 41 THEN 2400
				ELSE ft.BetType END = psp.Bettype												
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder) Hd
	WHERE hd.value = 1 

	DELETE ft
	FROM #tmpRealSport ft
		CROSS APPLY	( SELECT dbo.f_CustSetting_GetSportOfferStatusBySiteCurrency(@SiteID,@Currency,ft.Sporttype,ft.Bettype,@SettingStatus)
				) dm (IsHidden)
	WHERE dm.IsHidden = 1  
		AND ft.ProductId = 41--real Product under live casino didn't offer

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
		FROM bodb02.dbo.BalanceCreditGame WITH (NOLOCK) 
		WHERE CustId = @CustId AND BetType = @RealBetType

		SELECT @DebitBalance = SUM(ISNULL(Balance, 0))
		FROM bodb02.dbo.BalanceDebitGame WITH (NOLOCK) 
		WHERE CustId = @CustId AND BetType = @RealBetType

		IF @CreditBalance IS NULL
			SET @CreditBalance = 0

		IF @DebitBalance IS NULL
			SET @DebitBalance = 0

		SELECT @Amount = @CreditBalance - @DebitBalance

		SELECT @CreditAmount = ISNULL(credit, 0)
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE CustId = @CustId

		INSERT INTO #TempResult(SportType,BetType,MaxWinLimit,MaxWinAmount,MaxLossAmount,CurrentAmount,WinPercent,LossPercent)
		SELECT @RealSportType
			, @RealBetType
			, MaxWinLimit
			, MaxWinLimit * @CreditAmount AS MaxWinAmount
			, MaxLossLimit AS MaxLossAmount
			, @Amount as CurrentAmount
			, CASE  WHEN @RealSportType = 241 THEN -3 --N/A
					WHEN MaxWinLimit = 0 THEN -1 --unlimited
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

	DROP TABLE #TempResult
	DROP TABLE #tmpRealSport
END

GO