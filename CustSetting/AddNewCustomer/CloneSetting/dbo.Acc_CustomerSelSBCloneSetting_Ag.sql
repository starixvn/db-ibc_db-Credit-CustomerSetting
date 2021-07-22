/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
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
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
	Paramter's Explanation:
*/
BEGIN
SET NOCOUNT ON

SELECT cps.closed,
	cps.reject as suspended,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 1 THEN cs.playerdiscount ELSE 0 END ) as playerdiscount,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 5 THEN cs.playerdiscount ELSE 0 END ) as playerdiscount1x2,
	MAX( CASE WHEN cs.sporttype = 1 AND cs.bettype = 4 THEN cs.playerdiscount ELSE 0 END ) as playerdiscountcs,
	MAX( CASE WHEN cs3.sporttype = 161 AND cs3.bettype = 81 THEN cs.playerdiscount ELSE 0 END ) as playerdiscountnumber,
		
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
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
GROUP BY cps.closed,
		cps.reject,
		ci.MaxPerMatch,
		ci.MaxPerMatch2,
		ci.MaxPerMatch161

END	
GO
