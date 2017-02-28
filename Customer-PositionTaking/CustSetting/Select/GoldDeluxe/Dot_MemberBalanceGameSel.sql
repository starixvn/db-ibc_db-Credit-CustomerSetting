USE bodb02
GO
ALTER PROCEDURE dbo.Dot_MemberBalanceGameSel @CustId INT
	, @BetType SMALLINT

	, @CreditBalance MONEY = 0 OUTPUT
	, @DebitBalance MONEY = 0 OUTPUT
AS
/*  
  Created: 20150706@Patrick  
  Task: Get credit & debit balance game
  DB: DBTXN/bodb02
    
  Revisions:  
  Parameters Explanation:    
 */
BEGIN
	SET NOCOUNT ON	

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
END
GO
GRANT EXECUTE ON dbo.Dot_MemberBalanceGameSel TO [Dot_Member] AS [dbo]
GO
