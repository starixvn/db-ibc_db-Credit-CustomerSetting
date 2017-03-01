/*
	Created: Helen
	Date: 20160824
	Task: Correct mapping due to 
	DB: DBCUST.CustDB
*/
-- Step 1: Update resouceid of MMK,MKK
	update StakeLevel set resourceid = 182 
	WHERE GameTypeID = 2401 and exchangeid in (69,70) and resourceid = 181

-- Step 2: Update Mapping
	CREATE TABLE #tmp (StakeLevelID INT,exchangeid INT,MinLabel VARCHAR(100),MaxLabel VARCHAR(100),index_row INT)

	INSERT INTO #tmp (StakeLevelID ,exchangeid ,MinLabel,MaxLabel ,index_row )
	
	SELECT StakeLevelID,exchangeid,MinLabel,MaxLabel,ROW_NUMBER() over (PARTITION BY exchangeid order by stakelevelid) as index_row
	FROM StakeLevel (NOLOCK) WHERE GameTypeID = 2401 and exchangeid in (35,17,3,64,16,40,6,1,12) and resourceid = 241
	UNION ALL
	
	SELECT StakeLevelID,exchangeid,MinLabel,MaxLabel,ROW_NUMBER() over (PARTITION BY exchangeid order by stakelevelid) as index_row
	FROM StakeLevel (NOLOCK) WHERE GameTypeID = 2401 and exchangeid in (51) and resourceid = 243

	UNION ALL
	
	SELECT StakeLevelID,exchangeid,MinLabel,MaxLabel,ROW_NUMBER() over (PARTITION BY exchangeid order by stakelevelid) as index_row
	FROM StakeLevel (NOLOCK) WHERE GameTypeID = 2401 and exchangeid in (33,34,15,22,47) and resourceid = 3
	
	UNION ALL
	
	SELECT StakeLevelID,exchangeid,MinLabel,MaxLabel,ROW_NUMBER() over (PARTITION BY exchangeid order by stakelevelid) as index_row
	FROM StakeLevel (NOLOCK) WHERE GameTypeID = 2401 and exchangeid in (69,70) and resourceid = 182

	
	SELECT t1.StakeLevelID ,t1.exchangeid ,t1.MinLabel,t1.MaxLabel,t1.index_row,tmp.StakeLevelID as StakeLevelID_updated
	INTO #Result 
	FROM #tmp t1
		CROSS APPLY (SELECT t2.StakeLevelID
					 FROM #tmp t2 WHERE t1.exchangeid = t2.exchangeid and t2.index_row = 1) as tmp	
-- update mapping
	UPDATE t 
			SET StakeLevelID_AllBet  = r.StakeLevelID_updated
	FROM tmpStakeLevelMapping t (NOLOCK)
		INNER JOIN #Result r ON t.StakeLevelID_AllBet = r.StakeLevelID
	WHERE t.GameTypeID = 2401 and r.index_row > 1
	
-- Step 3: DELETE REDUNTDANT LEVEL
	
	DELETE SL
	FROM StakeLevel SL
		INNER JOIN 	#tmp T ON SL.StakeLevelID =  T.StakeLevelID AND T.index_row > 1
	WHERE sl.GameTypeID = 2401	
	
-- Step 4: Update resourceID 
	-- $US, NTD, US$, UT, Yen, IRR, EURO, SD$, GBP
	UPDATE StakeLevel SET ResourceId = 176
	WHERE ExchangeId IN (35,17,3,64,16,40,6,1,12) AND GameTypeID = 2402
	--HK$,HKK, RMB
	UPDATE StakeLevel SET ResourceId = 12
	WHERE ExchangeId IN (5,67,13) AND GameTypeID = 2402
	--RM
	UPDATE StakeLevel SET ResourceId = 135
	WHERE ExchangeId IN (2) AND GameTypeID = 2402
	-- Won
	UPDATE StakeLevel SET ResourceId = 42
	WHERE ExchangeId IN (45) AND GameTypeID = 2402
	-- TB, THB
	UPDATE StakeLevel SET ResourceId = 28
	WHERE ExchangeId IN (4,43) AND GameTypeID = 2402

	-- INH
	UPDATE StakeLevel SET ResourceId = 13
	WHERE ExchangeId IN (51) AND GameTypeID = 2402
	-- IDD,IDR,IN, IND, DDD
	UPDATE StakeLevel SET ResourceId = 157
	WHERE ExchangeId IN (33,34,15,22,47) AND GameTypeID = 2402

	-- INR
	UPDATE StakeLevel SET ResourceId = 28
	WHERE ExchangeId IN (61) AND GameTypeID = 2402
	--MMK,MKK
	UPDATE StakeLevel SET ResourceId = 176
	WHERE ExchangeId IN (69,70) AND GameTypeID = 2402
	-- uus
	UPDATE StakeLevel SET ResourceId = 176
	WHERE ExchangeId IN (20) AND GameTypeID = 2402

