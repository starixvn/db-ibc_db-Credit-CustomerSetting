/*
	Created: Elodie
	Task: Adjust Setting for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
DECLARE @ProductID TINYINT = 28
CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
SELECT	202, 1501, SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (1,6)

INSERT INTO #DestinationSportBetType
SELECT	202, 15, SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (2)

--------------------------------------PT Setting-------------------------------------------------	
--AGENT LEVEL
UPDATE csa
SET	csa.SuperPT = cs.spositiontaking  *100
	,csa.MasterPT =  cs.mpositiontaking  *100
	,csa.AgentPT = cs.apositiontaking  *100
	,csa.IsAutoMasterPT = cs.isautompositiontaking
	,csa.AutoMasterPT = cs.autompositiontaking *100
	,csa.IsAutoSuperPT = cs.isautopositiontaking 
	,csa.AutoSuperPT = cs.autopositiontaking  *100
	,csa.MinPT = co.minpositiontaking *100
FROM dbo.custSettingGame cs WITH(NOLOCK) 
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
	INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype	
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	INNER JOIN dbo.CustPTSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK) ON csa.custid = cs.custid and csa.sporttype = tSportType and csa.bettype = tBetType
WHERE ci.roleid IN (2,3,4) AND Enabled = 1
		AND (
			cs.SPositionTaking * 100 <> csa.SuperPT
			OR cs.MPositionTaking * 100 <> csa.MasterPT
			OR cs.APositionTaking * 100 <> csa.AgentPT
			OR cs.IsAutoMPositionTaking <> csa.IsAutoMasterPT
			OR cs.AutoMPositionTaking * 100 <> csa.AutoMasterPT
			OR cs.IsAutoPositionTaking <> csa.IsAutoSuperPT
			OR cs.AutoPositionTaking * 100 <> csa.AutoSuperPT
			OR co.MinPositionTaking  * 100 <> csa.MinPT 
			)
	
--MEMBER LEVEL
UPDATE csm
SET	csm.SuperPT = cs.spositiontaking  *100
	,csm.MasterPT =  cs.mpositiontaking  *100
	,csm.AgentPT = cs.apositiontaking  *100
	,csm.IsAutoMasterPT = cs.isautompositiontaking
	,csm.AutoMasterPT = cs.autompositiontaking *100
	,csm.IsAutoSuperPT = cs.isautopositiontaking 
	,csm.AutoSuperPT = cs.autopositiontaking  *100
FROM dbo.custSettingGame cs WITH(NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK) ON csm.custid = cs.custid and csm.sporttype = tSportType and csm.bettype = tBetType	
WHERE ci.roleid = 1 AND Enabled = 1
		AND (
			cs.SPositionTaking  * 100 <> csm.SuperPT
			OR cs.MPositionTaking  * 100 <> csm.MasterPT
			OR cs.APositionTaking  * 100 <> csm.AgentPT
			OR cs.IsAutoMPositionTaking <> csm.IsAutoMasterPT
			OR cs.AutoMPositionTaking * 100 <> csm.AutoMasterPT
			OR cs.IsAutoPositionTaking <> csm.IsAutoSuperPT
			OR cs.AutoPositionTaking  * 100 <> csm.AutoSuperPT
			)

--------------------------------------Bet Setting-------------------------------------------------		
--Agent Level
UPDATE csa
SET csa.minBet = cs.MinBet,       
	csa.MaxBet = cs.MaxBet,   
	csa.maxperMatch = cs.MaxPerGameType
FROM dbo.CustGameType cs WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType
	INNER JOIN dbo.CustBetSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK) ON csa.custid = cs.custid and csa.sporttype = tSportType and csa.bettype = tBetType	
WHERE c.roleid IN (2,3,4) AND Enabled = 1
		AND (
			cs.minBet <> csa.minBet
			OR cs.MaxBet <> csa.MaxBet
			OR cs.MaxPerGameType <> csa.maxperMatch			
			)

--Member Level
UPDATE csm
SET csm.minBet = cs.minbet,       
	csm.MaxBet = cs.MaxBet,   
	csm.maxperMatch = cs.MaxPerGameType
FROM dbo.CustGameType cs WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType
	INNER JOIN dbo.CustBetSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK) ON csm.custid = cs.custid and csm.sporttype = tSportType and csm.bettype = tBetType	
WHERE c.roleid = 1 AND Enabled = 1
		AND (
			cs.minBet <> csm.minBet
			OR cs.MaxBet <> csm.MaxBet
			OR cs.MaxPerGameType <> csm.maxperMatch			
			)

DROP TABLE #DestinationSportBetType		