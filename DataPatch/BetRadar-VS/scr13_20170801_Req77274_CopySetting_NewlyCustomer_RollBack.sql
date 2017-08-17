/*
	Created: Elodie
	Task: Copy Setting for newly created customer
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
DECLARE @MaxCustID INT
	
SELECT @MaxCustID = xxx
	
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

DECLARE @ProductID TINYINT = 5
CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
INSERT INTO #DestinationSportBetType
SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
		CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
		SportType, BetType, 0, SettingType
FROM dbo.ProductSettingDetail WITH (NOLOCK)
WHERE ProductID = @ProductID AND SettingType IN (1, 2)

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	currency INT
)
	
INSERT INTO #MemberTemp (CustID)
SELECT custid
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid = 1  AND custid > @MaxCustID
	
INSERT INTO #SMATemp (CustID, roleid, currency)
SELECT custid, roleid, currency
FROM Custinfo WITH (NOLOCK)
WHERE srecommend IN (SELECT custid FROM #supers) AND roleid IN (2,3,4) AND custid > @MaxCustID

DECLARE @MaxPT TINYINT--, @MaxComm DECIMAL(9,8), @Currency INT
SELECT TOP 1 @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 1
--SELECT TOP 1 @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 3
--SELECT @Currency = currency FROM customer WITH (NOLOCK) WHERE custid = @srecommend
	
--------------------------------------PT Setting-------------------------------------------------	
--AGENT LEVEL
INSERT INTO dbo.CustSetting3rd (custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, 
								autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, 
								alivepositiontaking, mlivepositiontaking, slivepositiontaking, 
								autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking)	
SELECT 
	cspt.custid, dest.fbettype, dest.fsporttype
	,cspt.AgentPT  /100
	,cspt.MasterPT  /100
	,cspt.SuperPT  /100
	,0 AS playerdiscount
	,0 AS discount
	,0 AS adiscount
	,0 AS sdiscount
	,csbs.MinBet 
	,csbs.MaxBet
	,cspt.AutoSuperPT  /100
	,cspt.IsAutoSuperPT 
	,cspt.AutoMasterPT /100	
	,cspt.IsAutoMasterPT
	,0 AS alivepositiontaking
	,0 AS mlivepositiontaking
	,0 AS alivepositiontaking
	,0 AS slivepositiontaking
	,0 AS autolivepositiontaking
	,0 AS isautolivepositiontaking
	,0 AS autolivempositiontaking	
FROM dbo.CustPTSetting3rd_Agent cspt WITH(NOLOCK) 
	INNER JOIN dbo.CustBetSetting3rd_Agent csbs ON csbs.CustID = cspt.CustID AND csbs.BetType = cspt.BetType AND csbs.SportType = cspt.SportType
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cspt.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cspt.bettype = dest.tBetType AND cspt.sporttype = dest.tSportType
	
--AGENT LEVEL
INSERT INTO dbo.custOverride3rd (custid, bettype, sporttype, minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)	
SELECT 
	cspt.custid, dest.fbettype, dest.fsporttype
	,cspt.MinPT  /100
	,cspt.MaxPT /100
	,0 AS minlivepositiontaking
	,0 AS maxlivepositiontaking	
FROM dbo.CustPTSetting3rd_Agent cspt WITH(NOLOCK) 
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cspt.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cspt.bettype = dest.tBetType AND cspt.sporttype = dest.tSportType

--MEMBER LEVEL
INSERT INTO dbo.CustSetting3rd (custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, 
								autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, 
								alivepositiontaking, mlivepositiontaking, slivepositiontaking, 
								autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking)	
SELECT 
	cspt.custid, dest.fbettype, dest.fsporttype
	,cspt.AgentPT  /100
	,cspt.MasterPT  /100
	,cspt.SuperPT  /100
	,0 AS playerdiscount
	,0 AS discount
	,0 AS adiscount
	,0 AS sdiscount
	,csbs.MinBet 
	,csbs.MaxBet
	,cspt.AutoSuperPT  /100
	,cspt.IsAutoSuperPT 
	,cspt.AutoMasterPT /100	
	,cspt.IsAutoMasterPT
	,0 AS alivepositiontaking
	,0 AS mlivepositiontaking
	,0 AS alivepositiontaking
	,0 AS slivepositiontaking
	,0 AS autolivepositiontaking
	,0 AS isautolivepositiontaking
	,0 AS autolivempositiontaking	
FROM dbo.CustPTSetting3rd_Agent cspt WITH(NOLOCK) 
	INNER JOIN dbo.CustBetSetting3rd_Agent csbs ON csbs.CustID = cspt.CustID AND csbs.BetType = cspt.BetType AND csbs.SportType = cspt.SportType
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cspt.custid
	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cspt.bettype = dest.tBetType AND cspt.sporttype = dest.tSportType

	
--------------------------------------MaxPerMatch-------------------------------------------------		
--Agent Level
UPDATE csa
SET csa.maxperMatch180 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 180

UPDATE csa
SET csa.maxperMatch181 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 181

UPDATE csa
SET csa.maxperMatch182 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 182

UPDATE csa
SET csa.maxperMatch183 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 183

UPDATE csa
SET csa.maxperMatch184 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 184

UPDATE csa
SET csa.maxperMatch185 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 185

UPDATE csa
SET csa.maxperMatch186 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #SMATemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 186

--Member Level
UPDATE csa
SET csa.maxperMatch180 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 180

UPDATE csa
SET csa.maxperMatch181 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 181

UPDATE csa
SET csa.maxperMatch182 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 182

UPDATE csa
SET csa.maxperMatch183 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 183

UPDATE csa
SET csa.maxperMatch184 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 184

UPDATE csa
SET csa.maxperMatch185 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 185

UPDATE csa
SET csa.maxperMatch186 = cs.MaxPerMatch
FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON csa.CustID = ci.custid
	INNER JOIN dbo.CustBetSetting3rd_Member cs WITH (NOLOCK) ON cs.CustID = csa.custid
WHERE cs.SportType = 186

/*******************************CUST PRODUCTSTATUS TABLE*******************************/	
DECLARE @BitmapOrder TINYINT = 10

UPDATE ci
SET ci.HideVirtualSports = (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsHidden, @BitmapOrder))		
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID	
WHERE ci.srecommend IN (SELECT custid FROM #supers) AND ci.custid > @MaxCustID

UPDATE ci
SET ci.DisableVirtualSports = CASE WHEN ci.HideVirtualSports = 1 THEN 0 ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, @BitmapOrder)) END
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID	
WHERE ci.srecommend IN (SELECT custid FROM #supers) AND ci.custid > @MaxCustID

DROP TABLE #SMATemp
DROP TABLE #MemberTemp
DROP TABLE #DestinationSportBetType		