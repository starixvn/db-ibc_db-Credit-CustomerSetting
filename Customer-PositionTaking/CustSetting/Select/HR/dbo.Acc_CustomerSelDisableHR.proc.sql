ALTER PROCEDURE [dbo].[Acc_CustomerSelDisableHR]
	@CustID INT
AS
/*
Created: 20100514@Terry
Task : Get Status for HorseRacing
DB: DBCUST.CustDB

Revisions:
	- 20110225@Lukas: Add more partner (AU Horse Racing) & racing game (Greyhound, Harness)
	- 20150609@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
SET NOCOUNT ON

SELECT
	ISNULL(DisableHorseracing, 0) AS Disable151_31,
	ISNULL(DisableOpenTote, 0) AS Disable151_41,
	ISNULL(Disable151_AU, 0) AS Disable151_51,
	ISNULL(Disable152_UK, 0) AS Disable152_41,
	ISNULL(Disable152_AU, 0) AS Disable152_51,
	ISNULL(Disable153_AU, 0) AS Disable153_51
FROM custinfo WITH (NOLOCK)
WHERE CustID = @CustID



GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbDownlineNetView]
GO
