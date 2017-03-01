ALTER FUNCTION [dbo].[f_IsHRAllowedCurr]
(
	@currencyID int
)
RETURNS bit
AS
BEGIN

	--Hard code
	if exists(
	select 1 from dbo.strsplit('US$,EURO,GBP,RM,SD$,RMB,HK$,Yen,NTD,$US,Y$US,IRR,UUS,TB', ',') h inner join exchange e with (nolock) on h.val = e.currency
	where exchangeid = @currencyID
	)
		return 1
	return 0
END