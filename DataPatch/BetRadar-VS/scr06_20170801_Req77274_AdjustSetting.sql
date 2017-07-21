/*
	Created: Elodie
	Task: Adjust Setting for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
DECLARE @ProductID TINYINT = 5
CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
		CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
		SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (1, 2)

CREATE TABLE #supers (custid int)

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
			AND ci.username NOT LIKE '3rdSuper%'
			AND cs.isinternal = 0
			AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
			AND s.islicensee = 0

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
FROM dbo.CustSetting3rd cs WITH(NOLOCK) 
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
	INNER JOIN dbo.custOverride3rd co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype	
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
FROM dbo.CustSetting3rd cs WITH(NOLOCK)
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
SET csa.minBet = cs.minbet,       
	csa.MaxBet = cs.MaxBet,   
	csa.maxperMatch = CASE	WHEN dest.fSportType = 181 THEN c.maxpermatch181
							WHEN dest.fSportType = 182 THEN c.maxpermatch182					 
							WHEN dest.fSportType = 183 THEN c.maxpermatch183
							WHEN dest.fSportType = 184 THEN c.maxpermatch184
							WHEN dest.fSportType = 185 THEN c.maxpermatch185
							WHEN dest.fSportType = 186 THEN c.maxpermatch186
							ELSE c.maxpermatch180 END
FROM dbo.CustSetting3rd cs WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	INNER JOIN dbo.CustBetSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK) ON csa.custid = cs.custid and csa.sporttype = tSportType and csa.bettype = tBetType	
WHERE c.roleid IN (2,3,4) AND Enabled = 1
		AND (
			cs.minBet <> csa.minBet
			OR cs.MaxBet <> csa.MaxBet
			OR CASE	WHEN dest.fSportType = 181 THEN c.maxpermatch181
					WHEN dest.fSportType = 182 THEN c.maxpermatch182					 
					WHEN dest.fSportType = 183 THEN c.maxpermatch183
					WHEN dest.fSportType = 184 THEN c.maxpermatch184
					WHEN dest.fSportType = 185 THEN c.maxpermatch185
					WHEN dest.fSportType = 186 THEN c.maxpermatch186
					ELSE c.maxpermatch180 END <> csa.maxperMatch			
			)

--Member Level
UPDATE csm
SET csm.minBet = cs.minbet,       
	csm.MaxBet = cs.MaxBet,   
	csm.maxperMatch = CASE	WHEN dest.fSportType = 181 THEN c.maxpermatch181
							WHEN dest.fSportType = 182 THEN c.maxpermatch182					 
							WHEN dest.fSportType = 183 THEN c.maxpermatch183
							WHEN dest.fSportType = 184 THEN c.maxpermatch184
							WHEN dest.fSportType = 185 THEN c.maxpermatch185
							WHEN dest.fSportType = 186 THEN c.maxpermatch186
							ELSE c.maxpermatch180 END
FROM dbo.CustSetting3rd cs WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	INNER JOIN dbo.CustBetSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK) ON csm.custid = cs.custid and csm.sporttype = tSportType and csm.bettype = tBetType	
WHERE c.roleid = 1 AND Enabled = 1
		AND (
			cs.minBet <> csm.minBet
			OR cs.MaxBet <> csm.MaxBet
			OR CASE	WHEN dest.fSportType = 181 THEN c.maxpermatch181
					WHEN dest.fSportType = 182 THEN c.maxpermatch182					 
					WHEN dest.fSportType = 183 THEN c.maxpermatch183
					WHEN dest.fSportType = 184 THEN c.maxpermatch184
					WHEN dest.fSportType = 185 THEN c.maxpermatch185
					WHEN dest.fSportType = 186 THEN c.maxpermatch186
					ELSE c.maxpermatch180 END <> csm.maxperMatch			
			)
			
/*******************************CUST PRODUCTSTATUS TABLE*******************************/	
DECLARE @BitmapOrder TINYINT = 10

UPDATE cs
SET cs.bitmapIsHidden = dbo.f_GenerateProductStatus(bitmapIsHidden, @BitmapOrder, ci.HideVirtualSports),
	bitmapIsDisabled = CASE WHEN ci.HideVirtualSports = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, 1) 
							ELSE dbo.f_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, ci.DisableVirtualSports) END
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID	
WHERE ci.srecommend IN (SELECT custid FROM #supers) 
	AND (cs.bitmapIsHidden <> dbo.f_GenerateProductStatus(bitmapIsHidden, @BitmapOrder, ci.HideVirtualSports)  				
	OR bitmapIsDisabled <> CASE WHEN ci.HideVirtualSports = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, 1) 
							ELSE dbo.f_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, ci.DisableVirtualSports) END)

DROP TABLE #DestinationSportBetType		