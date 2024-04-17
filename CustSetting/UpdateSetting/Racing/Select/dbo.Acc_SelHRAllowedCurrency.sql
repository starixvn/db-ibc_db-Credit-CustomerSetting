ALTER PROCEDURE dbo.Acc_SelHRAllowedCurrency
AS

SET NOCOUNT ON
/*
DB: DB052.BODB02
Original: 

Revisions:
	- 20090526@Phuc: get allowed HR currency from f_GetHRAllowedCurr
*/
Select exchangeID as currency, currency as currencyName
from dbo.[f_GetHRAllowedCurr]()
	
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [wsv_nap]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [wsv_xnap]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [wsv_alp]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [wsv_alpv]
GO