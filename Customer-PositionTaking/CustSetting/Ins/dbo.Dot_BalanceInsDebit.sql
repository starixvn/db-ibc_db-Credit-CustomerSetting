ALTER PROCEDURE [dbo].[Dot_BalanceInsDebit]
	@custid [int]
WITH EXECUTE AS CALLER
AS
/*
	Created: Elodie
	Date: 2013-08-08
	Task: Insert into BalanceDebit
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
	INSERT INTO dbo.BalanceDebit (custid, balance) VALUES (@custid, 0)		
END TRY
BEGIN CATCH
	SET @Success = 0	
END CATCH

IF @Success = 0 AND @Retry < 3 GOTO TryAgain



GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsDebit] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsDebit] TO [bodbDownlineNet] AS [dbo]