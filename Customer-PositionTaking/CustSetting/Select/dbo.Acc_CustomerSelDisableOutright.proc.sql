ALTER PROCEDURE [dbo].[Acc_CustomerSelDisableOutRight]
	@CustID INT
AS

/*
Created: 
Task : Get status DisableOutright by custid
DB: DBCUST.CustDB
Original: Accounting site

Revisions:
	- 20090729@Simon: Get customer DisableOutright status
	- 20150617@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
	@CustID: id of customer
*/		

SET NOCOUNT ON

SELECT ISNULL(DisableOutright, 0) AS DisableOutright
FROM custinfo WITH (NOLOCK)
WHERE CustID = @CustID


GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableOutRight] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableOutRight] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableOutRight] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelDisableOutRight] TO [vnteam]
GO