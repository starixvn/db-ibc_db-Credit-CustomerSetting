ALTER PROCEDURE dbo.Acc_CheckHRAllowedCurrency_xtest
	@CurrencyID int = NULL,
	@CurrencyName varchar(10) = NULL,
	@Allowed bit output 
AS
/*
DB: DB052.BODB02, DBTRANS.BODB02
Original: 

Revisions:
	- 20090526@Phuc: get allowed HR currency from f_GetHRAllowedCurr
	- 20100727@Jamie: Add permission for Thai site 	
*/
SET NOCOUNT ON
if (@CurrencyName is NULL)
	select @CurrencyName = currency from exchange with (nolock) where ExchangeID = @CurrencyID
if @CurrencyName in (select currency From dbo.f_GetHRAllowedCurr_xtest()) 
	select @Allowed = 1
else
	select @Allowed = 0
	
	
GO
GRANT EXECUTE ON [dbo].Acc_CheckHRAllowedCurrency_xtest TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckHRAllowedCurrency_xtest TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckHRAllowedCurrency_xtest TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].Acc_CheckHRAllowedCurrency_xtest TO [bodbExtAccNet]
GO 