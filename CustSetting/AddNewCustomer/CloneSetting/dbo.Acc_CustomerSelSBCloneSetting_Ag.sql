/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
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
		- 20210802@Eden: Max Payout Per Match [redmine: #158073]
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
		
	--Minbet, maxbet, MaxPerMatch for soccer
	v1minbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.minbet ELSE 0 END),
	v1maxbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.maxbet ELSE 0 END),
	v1maxpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.MaxPerMatch ELSE 0 END),
	v1maxpayoutpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.MaxPayoutPerMatch ELSE 0 END),
		
	--Minbet, maxbet, MaxPerMatch for basketball
	v2minbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.minbet ELSE 0 END),
	v2maxbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.maxbet ELSE 0 END),
	v2maxpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.MaxPerMatch ELSE 0 END),
	v2maxpayoutpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.MaxPayoutPerMatch ELSE 0 END),
		
	--Minbet, maxbet, MaxPerMatch for NumberGame
	v161minbet_81=MAX(CASE WHEN cb.bettype=81 AND cb.sporttype=161 THEN cb.minbet ELSE 0 END),
	v161maxbet_81=MAX(CASE WHEN cb.bettype=81 AND cb.sporttype=161 THEN cb.maxbet ELSE 0 END),
	v161maxpermatch_81=MAX(CASE WHEN cb.bettype=81 AND cb.sporttype=161 THEN cb.MaxPerMatch ELSE 0 END),
	v161maxperball_81=MAX(CASE WHEN cb.bettype=81 AND cb.sporttype=161 THEN cb.MaxPerNumber ELSE 0 END),
		
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
	INNER JOIN CustBetSetting_Member cb WITH(NOLOCK) ON ci.custid = cb.CustID
GROUP BY cps.closed,
		cps.reject

END	
GO
