/*<info serverAlias="DBTXN-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/

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
  Parameters Explanation: 
	WinPercent: -1: winloss setting is unlimited
				-2: N/A win/loss <> 0 and given credit = 0
 */
BEGIN
	SET NOCOUNT ON	
	DECLARE @Amount MONEY, @CreditAmount MONEY, @CreditBalance MONEY, @DebitBalance MONEY
	
	SELECT @CreditBalance = SUM(ISNULL(Balance, 0))
	FROM dbo.BalanceCreditGame WITH (NOLOCK) 
	WHERE CustId = @CustId AND BetType = @BetType

	SELECT @DebitBalance = SUM(ISNULL(Balance, 0))
	FROM dbo.BalanceDebitGame WITH (NOLOCK) 
	WHERE CustId = @CustId AND BetType = @BetType

	IF @CreditBalance IS NULL
		SET @CreditBalance = 0

	IF @DebitBalance IS NULL
		SET @DebitBalance = 0

	SELECT @Amount = @CreditBalance - @DebitBalance

	SELECT @CreditAmount = ISNULL(credit, 0)
	FROM DBCUST.CustDB.dbo.CustInfo WITH(NOLOCK)
	WHERE CustId = @CustId

	SELECT MaxWinLimit
		, MaxWinLimit * @CreditAmount AS MaxWinAmount
		, MaxLossLimit AS MaxLossAmount
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

GO