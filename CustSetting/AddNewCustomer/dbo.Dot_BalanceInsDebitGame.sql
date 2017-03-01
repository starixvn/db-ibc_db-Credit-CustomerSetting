USE bodb02
GO

ALTER PROCEDURE [dbo].[Dot_BalanceInsDebitGame]
	@custid [int],
	@winlostdate SMALLDATETIME,
	@bettype SMALLINT
WITH EXECUTE AS CALLER
AS
/*
	Created: Elodie
	Date: 2013-08-08
	Task: Insert into BalanceDebitGame
	DB: DBTXN/BODB02

	Revisions:
		- 20150710@Patrick: Support Gold deluxe

	Parameters Explanation:		
	
*/
Declare @Retry int, @Success bit
SET @Retry = 0

TryAgain:

BEGIN TRY
	SET @Retry = @Retry + 1
	SET @Success = 1	
	INSERT INTO dbo.BalanceDebitGame (custid, winlostdate, balance, bettype) VALUES (@custid, @winlostdate, 0, @bettype)			
END TRY
BEGIN CATCH
	SET @Success = 0	
END CATCH

IF @Success = 0 AND @Retry < 3 GOTO TryAgain



GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsDebitGame] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsDebitGame] TO [bodbDownlineNet] AS [dbo]