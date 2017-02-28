 ALTER PROCEDURE [dbo].[Acc_ExchangeSel]
	 @System varchar(50) = 'ACCOUNTING'
AS
/*
DB: DB02.BODB02
Original: member/addmaster.asp

Revisions:
	- 20090526@Phuc: get allowed HR currency from f_GetHRAllowedCurr
	- 20100720@Shifu: get system name
	- 20110614@Johnson: not check currency for HR SA Tote
*/
SET NOCOUNT ON
IF(@System = 'ACCOUNTING')
BEGIN
	select 
		ExchangeID, Currency
	from 
		exchange with (NOLOCK)
	ORDER BY 
		currency
END
ELSE
BEGIN
	

	SELECT 
		ExchangeID, Currency
	FROM 
		exchange with (NOLOCK)
	WHERE ExchangeID IN (SELECT exchangeID FROM dbo.f_CurrencyBySystem(@System))
	ORDER BY 
		currency
END
GO
GRANT EXECUTE ON [dbo].[Acc_ExchangeSel] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_ExchangeSel] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_ExchangeSel] TO [vnteam]
