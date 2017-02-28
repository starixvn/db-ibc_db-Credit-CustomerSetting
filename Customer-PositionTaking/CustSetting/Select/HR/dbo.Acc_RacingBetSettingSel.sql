ALTER PROCEDURE [dbo].[Acc_RacingBetSettingSel]
	@sporttype	INT			= NULL,
	@bettype	TINYINT		= NULL,
	@currency	VARCHAR(50)	= NULL
AS 
/*
	Created: Johnson
	Date: 2013-03-05
	Task: get racing bet setting of 3rd
	DB: DBCUST.CustDB
		
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameter's Explanation:
*/

SET NOCOUNT ON

SELECT	sporttype, 
		bettype, 
		rs.currency,
		c.currency as currencyName,
		CASE WHEN c.code = 'VND' THEN 'INH' ELSE c.code END AS currencyCode,
		ISNULL(rs.minbet, 0) AS minbet
FROM RacingBetSetting rs WITH(NOLOCK)
	INNER JOIN Exchange c WITH(NOLOCK) ON rs.currency = c.exchangeid 
WHERE sporttype = ISNULL(@sporttype, sporttype) 
	AND bettype = ISNULL(@bettype, bettype)
	AND c.currency LIKE ISNULL(@currency, c.currency)
	AND c.description <> 'Unused'

		
GO
GRANT EXECUTE ON [dbo].[Acc_RacingBetSettingSel] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_RacingBetSettingSel] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_RacingBetSettingSel] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_RacingBetSettingSel] TO [bodbExtAccNet]