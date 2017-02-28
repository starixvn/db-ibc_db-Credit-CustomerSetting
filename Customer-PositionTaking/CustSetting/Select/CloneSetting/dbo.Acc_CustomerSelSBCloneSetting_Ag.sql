ALTER PROCEDURE [dbo].[Acc_CustomerSelSBCloneSetting_Ag]
	@Custid INT
AS
/*
	Created: Johnson
	Date: 2012-07-27
	Task: Get sport book setting of customer
	DB: DBCUST.CustDB
		
	Revisions:
		- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	Paramter's Explanation:
*/
SET NOCOUNT ON

SELECT ci.closed,
	ci.reject as suspended,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 1 THEN cs.playerdiscount ELSE 0 END ) as playerdiscount,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 5 THEN cs.playerdiscount ELSE 0 END ) as playerdiscount1x2,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 4 THEN cs.playerdiscount ELSE 0 END ) as playerdiscountcs,
	MAX( CASE WHEN cs3.sporttype = 161 AND cs3.bettype = 81 THEN cs.playerdiscount ELSE 0 END ) as playerdiscountnumber,
	MAX( CASE WHEN cs.sporttype = 154 and cs.bettype = 20 THEN cs.playerdiscount ELSE 0 END) as playerdiscountHRFixedOdds,
		
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 1 THEN cs.minbet ELSE 0 END) as v1minbet_1,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 1 THEN cs.maxbet ELSE 0 END) as v1maxbet_1,
	ci.MaxPerMatch as v1MaxPerMatch_1,
		
	MAX( CASE WHEN cs.sporttype = 2 AND cs.bettype = 1 THEN cs.minbet ELSE 0 END) as v2minbet_1,
	MAX( CASE WHEN cs.sporttype = 2 AND cs.bettype = 1 THEN cs.maxbet ELSE 0 END) as v2maxbet_1,
	ci.MaxPerMatch2 as v2MaxPerMatch_1,
		
	MAX( CASE WHEN cs.sporttype = 161 AND cs.bettype = 81 THEN cs.minbet ELSE 0 END) as v161minbet_81,
	MAX( CASE WHEN cs.sporttype = 161 AND cs.bettype = 81 THEN cs.maxbet ELSE 0 END) as v161maxbet_81,
	ci.MaxPerMatch161 as v161MaxPerMatch_81,
		
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 1 THEN cs.apositiontaking ELSE 0 END) as v1apositiontaking_1,
	MAX( CASE WHEN cs.sporttype = 2 AND cs.bettype = 1 THEN cs.apositiontaking ELSE 0 END) as v2apositiontaking_1,
	MAX( CASE WHEN cs3.sporttype = 161 AND cs3.bettype = 81 THEN cs3.apositiontaking ELSE 0 END) as v161apositiontaking_81	
FROM CustInfo ci WITH(NOLOCK)
	INNER JOIN CustSetting cs WITH(NOLOCK) ON ci.custid = @custid AND roleid = 1 AND cs.custid = ci.custid
	INNER JOIN CustSetting3rd cs3 WITH(NOLOCK) ON cs3.custid = ci.custid
GROUP BY ci.closed,
		ci.reject,
		ci.MaxPerMatch,
		ci.MaxPerMatch2,
		ci.MaxPerMatch161

	
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSBCloneSetting_Ag] TO [vnteam]
GO
GRANT EXECUTE On [dbo].[Acc_CustomerSelSBCloneSetting_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSBCloneSetting_Ag] TO [bodbDownlineNetView]