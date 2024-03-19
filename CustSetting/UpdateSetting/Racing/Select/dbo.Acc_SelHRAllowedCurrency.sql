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
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbAdminNet,wsv_nap]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbExtAccNet,wsv_xnap]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbDownlineNet,wsv_alp]
GO
GRANT EXECUTE ON [dbo].Acc_SelHRAllowedCurrency TO [bodbDownlineNetView,wsv_alpv]
GO