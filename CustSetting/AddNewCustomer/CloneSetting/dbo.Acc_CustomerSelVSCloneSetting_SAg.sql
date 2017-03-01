ALTER PROCEDURE [dbo].[Acc_CustomerSelVSCloneSetting_SAg]
	@Custid INT
AS
/*  
	Created by: Dan  
	Date: 2012/08/23
	Original:
	Task: Get VS setting information of master
	DB: DBCUST.CustDB

	History:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)
		- 20140402@Dom: Get Virtual Speedway/ Cycling setting (sporttype: 183|185, bettype: 1231)
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Explanation's Param:
*/

/*
EXEC dbo.Acc_CustomerSelVSCloneSetting_SAg @CustID=987853
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT
	---------- bet setting section---------------------------------------------------------------------------------------		
		v180minbet_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 THEN cs3rd.minbet ELSE 0 END)
		,v180maxbet_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 THEN cs3rd.maxbet ELSE 0 END)
		,v180maxpermatch_1201=ci.MaxPerMatch180
		
		,v181minbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 THEN cs3rd.minbet ELSE 0 END)
		,v181maxbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 THEN cs3rd.maxbet ELSE 0 END)
		,v181maxpermatch_1231=ci.MaxPerMatch181

		,v183minbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 THEN cs3rd.minbet ELSE 0 END)
		,v183maxbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 THEN cs3rd.maxbet ELSE 0 END)
		,v183maxpermatch_1231=ci.MaxPerMatch183

		,v185minbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 THEN cs3rd.minbet ELSE 0 END)
		,v185maxbet_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 THEN cs3rd.maxbet ELSE 0 END)
		,v185maxpermatch_1231=ci.MaxPerMatch185
		
		,v186minbet_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 THEN cs3rd.minbet ELSE 0 END)
		,v186maxbet_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 THEN cs3rd.maxbet ELSE 0 END)
		,v186maxpermatch_1220=ci.MaxPerMatch186		

	---------- position taking section---------------------------------------------------------------------------------------
		
		,v180mpositiontaking_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 THEN cs3rd.mpositiontaking END)		
		,v180spositiontaking_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 THEN cs3rd.spositiontaking END)		
		,v180isAutosPT_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 AND isautopositiontaking = 1 THEN 1 ELSE 0 END)		
		,v180autospositiontaking_1201=MAX(CASE WHEN cs3rd.bettype=1201 AND cs3rd.sporttype=180 THEN cs3rd.autopositiontaking END)		

		,v181mpositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 THEN cs3rd.mpositiontaking END)		
		,v181spositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 THEN cs3rd.spositiontaking END)		
		,v181isAutosPT_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 AND isautopositiontaking = 1 THEN 1 ELSE 0 END)		
		,v181autospositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=181 THEN cs3rd.autopositiontaking END)		

		,v183mpositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 THEN cs3rd.mpositiontaking END)		
		,v183spositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 THEN cs3rd.spositiontaking END)		
		,v183isAutosPT_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 AND isautopositiontaking = 1 THEN 1 ELSE 0 END)		
		,v183autospositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=183 THEN cs3rd.autopositiontaking END)	
		
		,v185mpositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 THEN cs3rd.mpositiontaking END)		
		,v185spositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 THEN cs3rd.spositiontaking END)		
		,v185isAutosPT_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 AND isautopositiontaking = 1 THEN 1 ELSE 0 END)		
		,v185autospositiontaking_1231=MAX(CASE WHEN cs3rd.bettype=1231 AND cs3rd.sporttype=185 THEN cs3rd.autopositiontaking END)		

		,v186mpositiontaking_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 THEN cs3rd.mpositiontaking END)		
		,v186spositiontaking_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 THEN cs3rd.spositiontaking END)		
		,v186isAutosPT_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 AND isautopositiontaking = 1 THEN 1 ELSE 0 END)		
		,v186autospositiontaking_1220=MAX(CASE WHEN cs3rd.bettype=1220 AND cs3rd.sporttype=186 THEN cs3rd.autopositiontaking END)			
	---------- min position taking section---------------------------------------------------------------------------------------
		,v180MinPT_1201 = MAX(CASE WHEN csOv3rd.bettype=1201 AND csOv3rd.sporttype=180 THEN csOv3rd.minpositiontaking END)
		,v181MinPT_1231 = MAX(CASE WHEN csOv3rd.bettype=1231 AND csOv3rd.sporttype=181 THEN csOv3rd.minpositiontaking END)
		,v183MinPT_1231 = MAX(CASE WHEN csOv3rd.bettype=1231 AND csOv3rd.sporttype=183 THEN csOv3rd.minpositiontaking END)
		,v185MinPT_1231 = MAX(CASE WHEN csOv3rd.bettype=1231 AND csOv3rd.sporttype=185 THEN csOv3rd.minpositiontaking END)
		,v186MinPT_1220 = MAX(CASE WHEN csOv3rd.bettype=1220 AND csOv3rd.sporttype=186 THEN csOv3rd.minpositiontaking END)

	FROM dbo.CustInfo AS ci WITH(NOLOCK)
		INNER JOIN dbo.CustSetting3rd AS cs3rd WITH(NOLOCK) ON ci.CustID = cs3rd.CustID
			AND ci.custid = @CustID
			AND ci.roleid = 3
		LEFT JOIN dbo.custoverride3rd AS csOv3rd WITH (NOLOCK) ON csOv3rd.custid = cs3rd.custid AND csOv3rd.sporttype = cs3rd.sporttype AND csOv3rd.bettype = cs3rd.bettype
	GROUP BY 
		maxpermatch180, 
		maxpermatch181,
		maxpermatch183, 
		maxpermatch185, 
		MaxPerMatch186
			
	SET NOCOUNT OFF
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelVSCloneSetting_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelVSCloneSetting_SAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelVSCloneSetting_SAg] TO [vnteam]


