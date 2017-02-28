ALTER PROCEDURE [dbo].[Dot_BalanceInsCredit]
	@custid [int]
WITH EXECUTE AS CALLER
AS
/*
	Created: Elodie
	Date: 2013-08-08
	Task: Insert into BalanceCredit
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
	INSERT INTO dbo.BalanceCredit (custid, balance) VALUES (@custid, 0)		
END TRY
BEGIN CATCH
	SET @Success = 0	
END CATCH

IF @Success = 0 AND @Retry < 3 GOTO TryAgain



GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsCredit] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsCredit] TO [bodbDownlineNet] AS [dbo]