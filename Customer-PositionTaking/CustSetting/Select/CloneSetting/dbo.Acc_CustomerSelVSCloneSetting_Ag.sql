ALTER PROCEDURE [dbo].[Acc_CustomerSelVSCloneSetting_Ag]
	@Custid INT
AS
/*
	Created: Dan
	Date: 2012-08-23
	Task: Get virtual soccer setting of customer
	DB: DBCUST.CustDB
		
	Revisions:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)	
		- 20150616@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Paramter's Explanation:
*/
SET NOCOUNT ON
	SELECT
		MAX( CASE WHEN cs.sporttype = 180 AND cs.bettype = 1201 THEN cs.minbet ELSE 0 END) as v180minbet_1201,
		MAX( CASE WHEN cs.sporttype = 180 AND cs.bettype = 1201 THEN cs.maxbet ELSE 0 END) as v180maxbet_1201,
		ci.MaxPerMatch180 as v180MaxPerMatch_1201,
		
		MAX( CASE WHEN cs.sporttype = 181 AND cs.bettype = 1231 THEN cs.minbet ELSE 0 END) as v181minbet_1231,
		MAX( CASE WHEN cs.sporttype = 181 AND cs.bettype = 1231 THEN cs.maxbet ELSE 0 END) as v181maxbet_1231,
		ci.MaxPerMatch181 as v181MaxPerMatch_1231,	

		MAX( CASE WHEN cs.sporttype = 183 AND cs.bettype = 1231 THEN cs.minbet ELSE 0 END) as v183minbet_1231,
		MAX( CASE WHEN cs.sporttype = 183 AND cs.bettype = 1231 THEN cs.maxbet ELSE 0 END) as v183maxbet_1231,
		ci.MaxPerMatch183 as v183MaxPerMatch_1231,	

		MAX( CASE WHEN cs.sporttype = 185 AND cs.bettype = 1231 THEN cs.minbet ELSE 0 END) as v185minbet_1231,
		MAX( CASE WHEN cs.sporttype = 185 AND cs.bettype = 1231 THEN cs.maxbet ELSE 0 END) as v185maxbet_1231,
		ci.MaxPerMatch185 as v185MaxPerMatch_1231,
		
		MAX( CASE WHEN cs.sporttype = 186 AND cs.bettype = 1220 THEN cs.minbet ELSE 0 END) as v186minbet_1220,
		MAX( CASE WHEN cs.sporttype = 186 AND cs.bettype = 1220 THEN cs.maxbet ELSE 0 END) as v186maxbet_1220,
		ci.MaxPerMatch186 as v186MaxPerMatch_1220,
		-- a1	
		MAX( CASE WHEN cs.sporttype = 180 AND cs.bettype = 1201 THEN cs.apositiontaking ELSE 0 END) as v180apositiontaking_1201,
		MAX( CASE WHEN cs.sporttype = 181 AND cs.bettype = 1231 THEN cs.apositiontaking ELSE 0 END) as v181apositiontaking_1231,
		MAX( CASE WHEN cs.sporttype = 183 AND cs.bettype = 1231 THEN cs.apositiontaking ELSE 0 END) as v183apositiontaking_1231,
		MAX( CASE WHEN cs.sporttype = 185 AND cs.bettype = 1231 THEN cs.apositiontaking ELSE 0 END) as v185apositiontaking_1231,
		MAX( CASE WHEN cs.sporttype = 186 AND cs.bettype = 1220 THEN cs.apositiontaking ELSE 0 END) as v186apositiontaking_1220
	FROM CustInfo ci WITH(NOLOCK)
		INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON ci.custid = @custid AND roleid = 1 AND cs.custid = ci.custid		
	GROUP BY ci.MaxPerMatch180, ci.MaxPerMatch181,ci.MaxPerMatch183,ci.MaxPerMatch185, MaxPerMatch186
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelVSCloneSetting_Ag] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelVSCloneSetting_Ag] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelVSCloneSetting_Ag] TO [vnteam] AS [dbo]