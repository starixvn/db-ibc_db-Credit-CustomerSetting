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
  
	History:   
		- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
		- 20150904@Helen: commission setting for MO [Redmine #41470]
	Explanation's Param:
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @discountMyanmarOdds DECIMAL(9,8)=0
	DECLARE @IsMyanmarOdds BIT = 0, @srecommend INT = 0
	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@custid)
	
	IF @IsMyanmarOdds = 1
		SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @Custid AND Sporttype = 1 AND Bettype = 301)

	SELECT 
		ci.closed
		,ci.reject AS suspended
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

		--Number Game commission
		,v161discount_81=MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.discount ELSE 0 END)
		
		--HR Fixed Odds commission
		,max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.discount else 0 end) as v154discount_20

		,dbo.F_Decimal_Binary(ISNULL(TransferOption,0))  as TransferOption
			
	---------- bet setting section---------------------------------------------------------------------------------------
		--Minbet, maxbet, MaxPerMatch for soccer
		,v1minbet_1=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.minbet ELSE 0 END)
		,v1maxbet_1=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=1 THEN cs.maxbet ELSE 0 END)
		,v1maxpermatch_1=ci.MaxPerMatch
		
		--Minbet, maxbet, MaxPerMatch for basketball
		,v2minbet_1=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 THEN cs.minbet ELSE 0 END)
		,v2maxbet_1=MAX(CASE WHEN cs.bettype=1 AND cs.sporttype=2 THEN cs.maxbet ELSE 0 END)
		,v2maxpermatch_1=ci.MaxPerMatch2
		
		--Minbet, maxbet, MaxPerMatch for NumberGame
		,v161minbet_81=MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.minbet ELSE 0 END)
		,v161maxbet_81=MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.maxbet ELSE 0 END)
		,v161maxpermatch_81=ci.MaxPerMatch161
		
		
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
		
		--PT of Number game (on behalf of bettype=81)
		,v161apositiontaking_81 = MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.apositiontaking END)		
		,v161mpositiontaking_81 = MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.mpositiontaking END)		
		,v161isAutomPT_81 = MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 AND cs3rd.isautompositiontaking = 1 THEN 1 else 0 END)
		,v161AutomPT_81 = MAX(CASE WHEN cs3rd.bettype=81 AND cs3rd.sporttype=161 THEN cs3rd.autompositiontaking END)
		
	-------- Min position taking section---------------------------------------------------------------------------------------
		--min PT of soccers (on behalf of HDP)
		,v1MinPT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=1 THEN csOv.minpositiontaking END)
		,v1MinLivePT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=1 THEN csOv.minlivepositiontaking END)

		--min PT of basketball (on behalf of HDP)
		,v2MinPT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=2 THEN csOv.minpositiontaking END)
		--,v2MinLivePT_1 = MAX(CASE WHEN csOv.bettype=1 AND csOv.sporttype=2 THEN csOv.minlivepositiontaking END)

		--min PT of number game (on behalf of bettype=81)
		,v161MinPT_81 = MAX(CASE WHEN csOv3rd.bettype=81 AND csOv3rd.sporttype=161 THEN csOv3rd.minpositiontaking END)
		
		--min live PT of number game (on behalf of bettype=85)
		,v161MinLivePT_85 = MAX(CASE WHEN csOv3rd.bettype=85 AND csOv3rd.sporttype=161 THEN csOv3rd.minlivepositiontaking END)
		, ISNULL(@discountMyanmarOdds,0) AS discountMyanmarOdds
	FROM dbo.CustInfo AS ci WITH(NOLOCK)
		INNER JOIN dbo.CustSetting AS cs WITH(NOLOCK) ON cs.CustID=ci.CustID
			AND ci.custid=@CustID
			AND ci.roleid=2			
		INNER JOIN dbo.CustSetting3rd AS cs3rd WITH(NOLOCK) ON cs3rd.CustID=ci.CustID
		INNER JOIN dbo.CustAgent AS csAg WITH(NOLOCK) ON csAg.CustID=ci.CustID				
		LEFT JOIN dbo.custoverride AS csOv WITH (NOLOCK) on csOv.custid = cs.custid AND csOv.sporttype = cs.sporttype AND csOv.bettype = cs.bettype
		LEFT JOIN dbo.custoverride3rd AS csOv3rd WITH (NOLOCK) ON csOv3rd.custid = cs3rd.custid AND csOv3rd.sporttype = cs3rd.sporttype AND csOv3rd.bettype = cs3rd.bettype
	GROUP BY ci.closed
			,ci.reject
			,MaxPerMatch
			,MaxPerMatch2
			,MaxPerMatch161
			,TransferOption
	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSBCloneSetting_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSBCloneSetting_MAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSBCloneSetting_MAg] TO [vnteam]


