ALTER PROCEDURE [dbo].[Acc_CustomerSelHRCloneSetting_MAg]
	@Custid INT
AS
/*  
	Created by: Dan
	Date:201
	Original:
	Task: Get setting information of racing for a custid
	DB: DBCUST.CustDB
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Explanation's Param:
*/
/*
EXEC dbo.Acc_CustomerSelHRCloneSetting_MAg @CustID=988115
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT 
		ci.closed
		,ci.reject AS suspended
		,ci.DisableHorseRacing
	----------commission section---------------------------------------------------------------------------------------
		,v151discount_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END)
		
	---------- bet setting section---------------------------------------------------------------------------------------
			
		,v151minbet_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END)
		,v151maxbet_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END)
		,v151maxpermatch_41 = ci.MaxPerMatch151_OT

	---------- position taking section---------------------------------------------------------------------------------------
		
		,v151apositiontaking_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking END)
		,v151mpositiontaking_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.mpositiontaking END)
		,v151isAutomPT_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 AND cs3rd.isautompositiontaking = 1 THEN 1 ELSE 0 END)
		,v151AutomPT_41 = MAX(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.autompositiontaking END)
	
	---------- min position taking section---------------------------------------------------------------------------------------
		,v151MinPT_41 = MAX(CASE WHEN csOv3rd.bettype = 41 AND csOv3rd.sporttype = 151 THEN csOv3rd.minpositiontaking END)
	FROM dbo.CustInfo AS ci WITH (NOLOCK)
		INNER JOIN dbo.CustSetting3rd AS cs3rd WITH (NOLOCK) ON ci.CustID = cs3rd.CustID
			AND ci.custid = @CustID
			AND ci.roleid = 2
		LEFT JOIN dbo.custoverride3rd AS csOv3rd WITH (NOLOCK) ON csOv3rd.custid = cs3rd.custid AND csOv3rd.sporttype = cs3rd.sporttype AND csOv3rd.bettype = cs3rd.bettype
	GROUP BY ci.closed
			,ci.reject	
			,ci.DisableHorseRacing
			,maxpermatch151_OT
			
	SET NOCOUNT OFF
END


GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelHRCloneSetting_MAg TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelHRCloneSetting_MAg TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerSelHRCloneSetting_MAg TO [vnteam]


