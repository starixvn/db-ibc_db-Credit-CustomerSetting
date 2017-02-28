ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperLiveCS]
	@custid	INT
AS
/*
	Created: Johnson
	Date: 22Dec2011
	Task: Company edits super's live casino setting
	DB: DBCUST.CustDB

	Revisions:
		- 20120411@Lukas: hard code 0.008 for max comm
		- 20120611@Lukas: increase sdiscount up to 0.01
		- 20120928@Amy: Hardcode for super SLAM can have 100% PT and 0.02 comm
		- 20130301@Amy: change limitation of max super PT to 100% instead of 90%  
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameters Explanations:

*/
SET NOCOUNT ON

DECLARE @min_spositiontaking SMALLMONEY

SELECT @min_spositiontaking = minpositiontaking
FROM CustOverrideGame WITH (NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

IF @custid = 8156203
	BEGIN
		SELECT ISNULL(@min_spositiontaking, 0) AS v162spositiontaking_1101_min,
			1 AS v162spositiontaking_1101_max,
			spositiontaking AS v162spositiontaking_1101,
			sdiscount AS v162sdiscount_1101,
			0.022 AS v162sdicount_1101_max
		FROM CustSettingGame WITH (NOLOCK)
		WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
	END
ELSE
	BEGIN
		SELECT ISNULL(@min_spositiontaking, 0) AS v162spositiontaking_1101_min,
			1 AS v162spositiontaking_1101_max,
			spositiontaking AS v162spositiontaking_1101,
			sdiscount AS v162sdiscount_1101,
			0.01 AS v162sdicount_1101_max
		FROM CustSettingGame WITH (NOLOCK)
		WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
	END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperLiveCS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperLiveCS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperLiveCS] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperLiveCS] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperLiveCS] TO [vnteam] AS [dbo]