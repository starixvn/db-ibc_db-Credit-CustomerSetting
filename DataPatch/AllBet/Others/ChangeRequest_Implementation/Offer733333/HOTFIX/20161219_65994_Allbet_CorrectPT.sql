DECLARE @MaxPT TINYINT

SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1

--CREATE TABLE #supers (custid int)

--INSERT INTO #supers(custid)
--SELECT ci.custid
--FROM dbo.Customer ci WITH(NOLOCK)
--WHERE ci.username in ('BHOAM'
--'BHOAM'
--'S56UH0G'
--'S56UH0G'
--'S56UH0G'
--'S56UH0G'
--'S56UH0F'
--S56UH0G
--S56UH0F
--HPOC1ST
--HPOC1ST
--)

CREATE TABLE #Cust_Follow_LC (Custid INT PRIMARY KEY)

INSERT INTO #Cust_Follow_LC (Custid)
VALUES (20513220),
(20513201),
(24399359),
(24495704),
(24437120),
(24495779),
(24414179),
(24417946),
(24385969),
(16579257),
(16579257)
-- Correct PT follow LC setting	
-- sma level	
--UPDATE cs1
--SET cs1.SuperPT = cs2.spositiontaking * 100,
--	cs1.MasterPT = cs2.mpositiontaking * 100,
--	cs1.AgentPT = cs2.apositiontaking * 100,
--	cs1.IsAutoMasterPT = cs2.isautompositiontaking,
--	cs1.AutoMasterPT = cs2.autompositiontaking * 100,
--	cs1.IsAutoSuperPT = cs2.isautopositiontaking,
--	cs1.AutoSuperPT = cs2.autopositiontaking * 100,
--	cs1.MinPT = co.minpositiontaking * 100
--FROM dbo.custInfo ci WITH (NOLOCK) 
--	INNER JOIN dbo.CustPTSetting3rd_Agent cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
--	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
--	INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs1.CustID = co.CustID AND co.Sporttype = cs2.Sporttype AND co.Bettype = cs2.Bettype
--	INNER JOIN #Cust_Follow_LC lc ON lc.Custid = ci.custid
--WHERE ci.roleid IN (2,3,4) AND ci.Enabled = 1 and cs2.bettype = 1101 AND cs2.sporttype = 162 AND cs1.SportType = 211 AND cs1.BetType = 2401
--	AND ci.srecommend IN (SELECT s.custid 
--						FROM #supers s 
--							INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
--						WHERE spositiontaking <= @MaxPT) 
--	AND (cs1.SuperPT <> (cs2.spositiontaking * 100) OR
			
--			(ci.roleid <> 4 AND cs1.MasterPT <> (cs2.mpositiontaking * 100)) OR -- not adjust m4,a4
			
--			(ci.roleid <> 4 AND cs1.AgentPT  <> (cs2.apositiontaking  * 100)) OR --  not adjust m4,a4
			
--			cs1.IsAutoMasterPT <> cs2.isautompositiontaking OR
--			cs1.AutoMasterPT <> (cs2.autompositiontaking * 100) OR
--			cs1.IsAutoSuperPT <> cs2.isautopositiontaking OR
--			cs1.AutoSuperPT <> (cs2.autopositiontaking * 100) OR
--			cs1.MinPT <> co.minpositiontaking * 100)
			
-- member level
UPDATE cs1
	SET cs1.SuperPT = cs2.spositiontaking * 100,
		cs1.MasterPT = cs2.mpositiontaking * 100,
		cs1.AgentPT = cs2.apositiontaking * 100,
		cs1.IsAutoMasterPT = cs2.isautompositiontaking,
		cs1.AutoMasterPT = cs2.autompositiontaking * 100,
		cs1.IsAutoSuperPT = cs2.isautopositiontaking,
		cs1.AutoSuperPT = cs2.autopositiontaking * 100
FROM dbo.custInfo ci WITH (NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Member cs1 WITH(ROWLOCK,UPDLOCK) ON ci.custid = cs1.CustID
	INNER JOIN CustSettingGame cs2 ON cs2.CustID = cs1.CustID
	INNER JOIN #Cust_Follow_LC lc ON lc.Custid = ci.custid
	
WHERE ci.roleid = 1 AND ci.Enabled = 1 and cs2.bettype = 162 AND cs2.sporttype = 1101 AND cs1.SportType = 211 AND cs1.BetType = 2401
	/*
	AND ci.srecommend IN (SELECT s.custid 
						FROM #supers s 
							INNER JOIN CustSettingGame cs WITH(NOLOCK) ON s.custid = cs.custid AND cs.sporttype = 162 AND cs.bettype = 1101
						WHERE spositiontaking <= @MaxPT) 
	*/					
	AND (cs1.SuperPT <> (cs2.spositiontaking * 100) OR
			cs1.MasterPT <> (cs2.mpositiontaking * 100) OR
			cs1.AgentPT <> (cs2.apositiontaking * 100) OR
			cs1.IsAutoMasterPT <> cs2.isautompositiontaking OR
			cs1.AutoMasterPT <> (cs2.autompositiontaking * 100) OR
			cs1.IsAutoSuperPT <> cs2.isautopositiontaking OR
			cs1.AutoSuperPT <> (cs2.autopositiontaking * 100))			