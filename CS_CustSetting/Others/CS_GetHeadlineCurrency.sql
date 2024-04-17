/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_GetHeadlineCurrency
	@Username NVARCHAR(50)
AS
/*
	Created: 20181212@Elodie
	Task : Suggest top 10 Headline username
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		
	Example: 
		EXEC CS_GetHeadlineCurrency @Username = 'MSHCN88'
*/

BEGIN
	SET NOCOUNT ON

	SELECT e.exchangeid AS exchangeid, e.currency AS CurrencyName
	FROM dbo.custInfo ci WITH (NOLOCK)
		INNER JOIN dbo.exchange e WITH (NOLOCK) ON e.exchangeid = ci.currency 
	WHERE username = @Username AND roleid = 0  
END
