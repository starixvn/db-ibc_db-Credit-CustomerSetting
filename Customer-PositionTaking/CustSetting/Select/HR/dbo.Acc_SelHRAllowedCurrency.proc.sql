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
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbDownlineNetView]
GO