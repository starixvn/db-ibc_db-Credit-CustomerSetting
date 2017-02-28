 ALTER PROCEDURE [dbo].[Acc_CustomerSelHRCloneSetting_Ag]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2012-07-27
		Task: get racing setting of member
		DB: DB053.bodb02
		
		Revisions:
		
		Parameter's Explanation:
	*/
SET NOCOUNT ON
	
	SELECT ci.MaxPerMatch151_OT as v151MaxPerMatch_41,
		MAX( CASE WHEN cs3.sporttype = 151 AND cs3.bettype = 41 THEN cs3.playerdiscount ELSE 0 END) as v151playerdiscount_41, 
		MAX( CASE WHEN cs3.sporttype = 151 AND cs3.bettype = 41 THEN cs3.minbet ELSE 0 END) as v151minbet_41,
		MAX( CASE WHEN cs3.sporttype = 151 AND cs3.bettype = 41 THEN cs3.maxbet ELSE 0 END) as v151maxbet_41,
		MAX( CASE WHEN cs3.sporttype = 151 AND cs3.bettype = 41 THEN cs3.apositiontaking ELSE 0 END) as v151apositiontaking_41
	FROM CustInfo ci WITH(NOLOCK)
		INNER JOIN CustSetting3rd cs3 WITH(NOLOCK) ON ci.custid = @custid AND ci.roleid = 1 AND ci.custid= cs3.custid
	GROUP BY ci.MaxPerMatch151_OT	
	

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRCloneSetting_Ag] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRCloneSetting_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRCloneSetting_Ag] TO [bodbDownlineNetView]