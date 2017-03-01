ALTER PROCEDURE [dbo].[Dot_BalanceDelCreditGame]
	@custid [int]
WITH EXECUTE AS CALLER
AS
/*
	Created: Elodie
	Date: 2013-08-08
	Task: Delete from BalanceCreditGame
	DB: DBTXN/BODB02

	Revisions:

	Parameters Explanation:		
	
*/
Declare @Retry int, @Success bit
SET @Retry = 0

TryAgain:

BEGIN TRY
	SET @Retry = @Retry + 1
	SET @Success = 1	
	DELETE BalanceCreditGame WITH (ROWLOCK) WHERE custid = @custid
END TRY
BEGIN CATCH
	SET @Success = 0	
END CATCH

IF @Success = 0 AND @Retry < 3 GOTO TryAgain



GO
GRANT EXECUTE ON [dbo].[Dot_BalanceDelCreditGame] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Dot_BalanceDelCreditGame] TO [bodbDownlineNet] AS [dbo]