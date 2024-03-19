/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelSBCloneSetting_MAg]
	@Custid INT
AS
/*
	Created by: Dan
	Date: 20120203
	Original:
	Task: Get setting information of sport book for a custid 
	("search and copy" feature of creating new agent) 
	DB: DBCUST.CustDB
  
	Revisions: 
		- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
		- 20210513@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210802@Eden: Max Payout Per Match [redmine: #158073]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	Explanation's Param:
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @discountMyanmarOdds DECIMAL(9,8)=0
	DECLARE @IsMyanmarOdds BIT = 0, @srecommend INT = 0
	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@custid)
	IF @IsMyanmarOdds = 1
		SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @Custid AND Sporttype = 1 AND Bettype = 1)

	SELECT 
		cps.closed
		,cps.reject AS suspended
	----------commission section---------------------------------------------------------------------------------------
		--groupA: for HDP, OU, OE
		,groupA=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.groupA ELSE 0 END)
				
		--groupB: for HDP, OU, OE
		,groupB=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.groupB ELSE 0 END)
	
		--groupC: for HDP, OU, OE
		,groupC=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.groupC ELSE 0 END)		
		
		--groupD: for HDP, OU, OE
		,groupD=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.groupD ELSE 0 END)		

		--comm2: for 1x2 (on behalf=5)
		,v1discount_5=MAX(CASE WHEN cs.bettype=5 AND cs.sporttype=1 THEN cs.discount ELSE 0 END)		
	
		--comm3: for other bettypes (on behalf=4)
		,v1discount_4=MAX(CASE WHEN cs.bettype=4 AND cs.sporttype=1 THEN cs.discount ELSE 0 END)
		
		
		,dbo.F_Decimal_Binary(ISNULL(TransferOption,0))  as TransferOption
			
	---------- bet setting section---------------------------------------------------------------------------------------
		--Minbet, maxbet, MaxPerMatch for soccer
		,v1minbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.minbet ELSE 0 END)
		,v1maxbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.maxbet ELSE 0 END)
		,v1maxpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.MaxPerMatch ELSE 0 END)
		,v1maxpayoutpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=1 THEN cb.MaxPayoutPerMatch ELSE 0 END)
		
		--Minbet, maxbet, MaxPerMatch for basketball
		,v2minbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.minbet ELSE 0 END)
		,v2maxbet_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.maxbet ELSE 0 END)
		,v2maxpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.MaxPerMatch ELSE 0 END)
		,v2maxpayoutpermatch_1=MAX(CASE WHEN cb.bettype=1 AND cb.sporttype=2 THEN cb.MaxPayoutPerMatch ELSE 0 END)				
		
	---------- position taking section---------------------------------------------------------------------------------------
		--PT of soccers (on behalf of HDP)
		,v1apositiontaking_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.apositiontaking END)
		,v1mpositiontaking_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.mpositiontaking END)
		,v1isAutomPT_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 AND cs.isautompositiontaking = 1 THEN 1 ELSE 0 END)
		,v1AutomPT_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.autompositiontaking END)
		
		--PT of basketball (on behalf HDP)
		,v2apositiontaking_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 THEN cs.apositiontaking END)
		,v2mpositiontaking_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 THEN cs.mpositiontaking END)
		,v2isAutomPT_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 AND cs.isautompositiontaking = 1 THEN 1 ELSE 0 END)
		,v2AutomPT_1 = MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 THEN cs.autompositiontaking END)				
		
	-------- Min position taking section---------------------------------------------------------------------------------------
		--min PT of soccers (on behalf of HDP)
		,v1MinPT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=1 THEN csOv.minpositiontaking END)
		,v1MinLivePT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=1 THEN csOv.minlivepositiontaking END)

		--min PT of basketball (on behalf of HDP)
		,v2MinPT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=2 THEN csOv.minpositiontaking END)
		--,v2MinLivePT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=2 THEN csOv.minlivepositiontaking END)
		
		,ISNULL(@discountMyanmarOdds,0) AS discountMyanmarOdds
	FROM dbo.CustInfo AS ci WITH(NOLOCK)
		INNER JOIN dbo.CustSetting AS cs WITH(NOLOCK) ON cs.CustID=ci.CustID
			AND ci.custid=@CustID
			AND ci.roleid=2			
		INNER JOIN dbo.CustAgent AS csAg WITH(NOLOCK) ON csAg.CustID=ci.CustID				
		CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
		LEFT JOIN dbo.custoverride AS csOv WITH (NOLOCK) on csOv.custid = cs.custid AND csOv.sporttype = cs.sporttype AND csOv.bettype = cs.bettype
		INNER JOIN CustBetSetting_Agent cb WITH(NOLOCK) ON ci.custid = cb.CustID
	GROUP BY cps.closed
			,cps.reject
			,TransferOption
	SET NOCOUNT OFF

END

GO



