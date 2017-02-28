 CREATE PROCEDURE [dbo].[Acc_ExchangeSel_xtest]
	 @System varchar(50) = 'ACCOUNTING'
AS
/*
DB: DB02.BODB02
Original: member/addmaster.asp

Revisions:
	- 20090526@Phuc: get allowed HR currency from f_GetHRAllowedCurr
	- 20100720@Shifu: get system name
*/
SET NOCOUNT ON
IF(@System = 'ACCOUNTING')
BEGIN
	select 
		ExchangeID, Currency,
		case when currency IN(select currency from dbo.[f_GetHRAllowedCurr_xtest]()) then 1 else 0 end HRAllowed
	from 
		exchange with (NOLOCK)
	ORDER BY 
		currency
END
ELSE
BEGIN
	

	SELECT 
		ExchangeID, Currency,
		case when currency IN(select currency from dbo.[f_GetHRAllowedCurr_xtest]()) then 1 else 0 end HRAllowed
	FROM 
		exchange with (NOLOCK)
	WHERE ExchangeID IN (SELECT exchangeID FROM dbo.f_CurrencyBySystem(@System))
	ORDER BY 
		currency
END
GO
GRANT EXECUTE ON [dbo].[Acc_ExchangeSel_xtest] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_ExchangeSel_xtest] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_ExchangeSel_xtest] TO [vnteam]
