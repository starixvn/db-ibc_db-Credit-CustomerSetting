 ALTER PROCEDURE dbo.Acc_SelHRAllowedCurrency_xtest
AS

SET NOCOUNT ON
/*
DB: DB052.BODB02
Original: 

Revisions:
	- 20090526@Phuc: get allowed HR currency from f_GetHRAllowedCurr
*/
Select exchangeID as currency, currency as currencyName
from dbo.[f_GetHRAllowedCurr_xtest]()
	
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency_xtest TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency_xtest TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency_xtest TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency_xtest TO [bodbDownlineNetView]
GO