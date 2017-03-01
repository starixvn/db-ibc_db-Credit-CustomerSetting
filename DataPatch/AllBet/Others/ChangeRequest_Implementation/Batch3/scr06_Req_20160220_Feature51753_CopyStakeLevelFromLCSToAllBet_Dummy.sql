/*
	Created: Helen
	Date: 20160302
	Task: Copy stake level from LCS to AllBet
	DB: DBCUST/CustDB
*/  
 -- BEGIN STEP 1: DEPLOY THIS SP @DBCUST.CustDB ------
------------------------------------------------------
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@srecommend INT	
	,@maxcustid INT
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustGameType') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0 RETURN
	IF (SELECT COUNT(1) FROM sys.objects WHERE NAME IN ('tmpCustGameType')) <> 1
		RETURN
	-----------------
	DECLARE @syncLiveCasino_super BIT, @exchangeID INT, @stakeLevelList2401_super VARCHAR(100)

	SELECT @exchangeID = currency, @syncLiveCasino_super = syncLiveCasino FROM dbo.custinfo WITH(NOLOCK) WHERE custid = @srecommend
	
	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		DirectUplineID INT,
		SyncLiveCasino BIT
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		DirectUplineID INT,
		roleid TINYINT,
		SyncLiveCasino BIT
	)
		
	CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
	CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
	CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT)	

	--- get direct master
	INSERT INTO #DirectMaster (CustID,roleid)
	SELECT custid, roleid
	FROM Customer with(nolock)
	WHERE SITE in ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')
		and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and roleid=3 AND srecommend = @srecommend
		
	--- get direct agent
	INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
	SELECT custid, mrecommend,roleid
	FROM Customer WITH(NOLOCK)
	WHERE SITE in ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666')
		and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and roleid=2 AND srecommend = @srecommend

	INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
	SELECT custid, recommend,mrecommend,roleid
	FROM Customer c WITH(NOLOCK)
	WHERE custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		AND recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		AND roleid=1 AND srecommend =@srecommend
		
	----------- For SMA  -----------
	INSERT INTO #SMATemp (CustID,roleid,SyncLiveCasino)
	SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Direct Master 
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
	WHERE  ci.Enabled = 1 AND ci.custid <= @maxcustid 	
			
	UNION 
	SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Master of direct agent
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
	WHERE  ci.Enabled = 1 AND ci.custid <= @maxcustid 	AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)
		
	UNION 

	SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Agent of direct master
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
	WHERE CI.roleid = 2 AND ci.Enabled = 1 AND ci.custid <= @maxcustid 	
	UNION 
	
	SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Direct Agent
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.custid = D.CustID 
	WHERE ci.Enabled = 1 AND ci.custid <= @maxcustid 		
	UNION 
	
	SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Master of direct member
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember D ON CI.custid = D.mrecommend 
	WHERE  ci.Enabled = 1 AND ci.custid <= @maxcustid 	AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)
	
	UNION 
	
	SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino -- agent of direct member
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember D ON CI.custid = D.recommend 
	WHERE  ci.Enabled = 1 AND ci.custid <= @maxcustid 	
	
	---------- For members ---------
	INSERT INTO #MemberTemp (CustID, SyncLiveCasino)
	SELECT CI.custid, SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
	WHERE CI.roleid = 1	AND ci.Enabled = 1 AND ci.custid <= @maxcustid 	

	UNION 
	SELECT CI.custid, SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
	WHERE CI.roleid = 1 AND ci.Enabled = 1 AND ci.custid <= @maxcustid 	
	-- Direct member
	UNION 
	SELECT CI.custid, CI.SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember M ON CI.custid = M.CustID AND ci.custid <= @maxcustid 	
		
		
	--Bettype 2402: Lowest VIP Bet limit
	DECLARE @StakeLevelList_2402 VARCHAR(100)
	
	SELECT TOP 1 @StakeLevelList_2402 =  StakeLevelID 
	FROM dbo.StakeLevel WITH(NOLOCK) 
	WHERE ExchangeId = @exchangeID AND GameTypeID = 2402 

	INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)	
	SELECT CustID, 211, 2402, CASE WHEN SyncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
	FROM #SMATemp 

	INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)	
	SELECT CustID, 211, 2402,  CASE WHEN SyncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
	FROM #MemberTemp

	--Bettype 2402: Done

	--Bettype 2401: Copy setting from LC
	IF @syncLiveCasino_super = 0
	BEGIN -- not sync yet, just put empty stakelevellist		
		--SMA Level
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, ''
		FROM #SMATemp ci 
		WHERE ci.roleid IN (2,3)

		--Member Level
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, ''
		FROM #MemberTemp ci 
		
		RETURN
	END

	SELECT @stakeLevelList2401_super = StakeLevelList_AllBet
	FROM dbo.tmpCustGameType WITH(NOLOCK)
	WHERE custid = @srecommend
	
	DECLARE @StakeLevelList_2401_lowest VARCHAR(100),@StakeLevelList_2401_allLevel4Super VARCHAR (100)
	
	SELECT TOP 1 @StakeLevelList_2401_lowest =  StakeLevelID 
	FROM dbo.StakeLevel WITH(NOLOCK) 
	WHERE ExchangeId = @exchangeID AND GameTypeID = 2401
	ORDER BY MaxStake, MinStake
	
	-- Supper: full stake level	
	SET @StakeLevelList_2401_allLevel4Super = STUFF((SELECT  ',' + CONVERT(VARCHAR(10),StakeLevelID) 
										FROM dbo.StakeLevel WITH(NOLOCK) 
										WHERE ExchangeId = @exchangeID AND GameTypeID = 2401
									 ORDER BY MaxStake, MinStake
									 FOR XML PATH ('')),1,1,'')
	--If don't have stake level for this line yet, just put lowest value 
	IF ISNULL(@stakeLevelList2401_super,'') = '' 
	BEGIN
		--SMA Level
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
		
		SELECT custid, 211, 2401, @StakeLevelList_2401_lowest
		FROM #SMATemp ci 
		WHERE ci.roleid IN (2,3)
		
		--UNION ALL
		
		--SELECT @srecommend, 211, 2401, @StakeLevelList_2401_allLevel4Super
		
		--Member Level
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, @StakeLevelList_2401_lowest
		FROM #MemberTemp ci 
		
		RETURN
	END
	

	UPDATE T1
		SET DirectUplineID = CASE WHEN ci.roleid = 2 THEN CI.mrecommend
								  WHEN ci.roleid = 3 THEN CI.srecommend
							ELSE 0 END 	 
	FROM #SMATemp T1
		INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid
	
	UPDATE T1
		SET DirectUplineID = ci.recommend	 
	FROM #MemberTemp T1
		INNER JOIN custInfo ci (NOLOCK) ON T1.CustID = CI.custid
	
	DECLARE @StakeLevelLowestSuper VARCHAR(100)
	
	SET @StakeLevelLowestSuper = ISNULL((SELECT TOP 1 CONVERT(VARCHAR(100),SL.StakeLevelID) 
									FROM strSplit (@stakeLevelList2401_super,',') tmp 
										INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
									WHERE SL.ExchangeId = @exchangeID AND GameTypeID = 2401
									ORDER BY SL.MaxStake, SL.MinStake),'')
					
	IF @stakeLevelList2401_super <> ''
	BEGIN
		-- all done, start insert
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)
		-- Rolid = 4
		--SELECT T1.CustID, 211, 2401, @StakeLevelList_2401_allLevel4Super  
		--FROM #SMATemp T1
		--WHERE T1.roleid = 4
		--UNION ALL
		-- Rolid = 3
		SELECT T1.custid, 211, 2401, CASE WHEN SyncLiveCasino = 1 THEN ISNULL(T2.StakeLevelList_AllBet,@StakeLevelLowestSuper) ELSE '' END AS stakeLevelList
		FROM #SMATemp T1
			LEFT JOIN tmpCustGameType T2 WITH (NOLOCK) ON T1.CustID = T2.CustID
		WHERE T1.roleid = 3
		-- Roleid = 2
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)
		SELECT T1.custid, 211, 2401, CASE WHEN t1.SyncLiveCasino = 1 THEN ISNULL(T2.StakeLevelList_AllBet,ISNULL(CONVERT(VARCHAR(100),temp.StakeLevelID),'')) ELSE '' END AS stakeLevelList
		FROM #SMATemp T1
			LEFT JOIN tmpCustGameType T2 WITH (NOLOCK) ON T1.CustID = T2.CustID AND t1.SyncLiveCasino = 1
			OUTER APPLY (SELECT TOP 1  SL.StakeLevelID 
						FROM strSplit ((SELECT ISNULL(T3.StakeLevelList,-1)  
										FROM CustStakeLevel_Agent T3 WITH (NOLOCK) 
										WHERE T3.custid = t1.DirectUplineID
											  AND T3.SportType = 211 AND T3.BetType = 2401),',') tmp 
							INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
						WHERE SL.ExchangeId = @exchangeID AND sl.GameTypeID = 2401
						ORDER BY SL.MaxStake, SL.MinStake
						) AS temp
		WHERE T1.roleid = 2
		
		-- RoleID = 1
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)
		SELECT T1.custid, 211, 2401, CASE WHEN T1.SyncLiveCasino = 1 THEN ISNULL(T2.StakeLevelList_AllBet,ISNULL(CONVERT(VARCHAR(100),temp.StakeLevelID),'')) ELSE '' END AS stakeLevelList
		FROM #MemberTemp T1
			LEFT JOIN tmpCustGameType T2 WITH (NOLOCK) ON T1.CustID = T2.CustID
			OUTER APPLY (SELECT TOP 1  SL.StakeLevelID 
						FROM strSplit ((SELECT ISNULL(T3.StakeLevelList,-1)  
										FROM CustStakeLevel_Agent T3 WITH (NOLOCK) 
										WHERE T3.custid = t1.DirectUplineID
											AND T3.SportType = 211 AND T3.BetType = 2401),',') tmp 
							INNER JOIN StakeLevel SL WITH(NOLOCK) ON tmp.val = SL.StakeLevelID
						WHERE SL.ExchangeId = @exchangeID AND sl.GameTypeID = 2401
						ORDER BY SL.MaxStake, SL.MinStake
						) AS temp
			
	END	
	
	DROP TABLE #SMATemp
	DROP TABLE #MemberTemp
END

GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

---
---
-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0) )

DECLARE @max_custid INT, @srecommend INT
SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.custid <= @max_custid
		-- Production
		AND ci.custid IN 
		(
			-- dummy account
			2,3,4,5,12,13,15
		)
		
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid

	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0),IsDummy BIT)

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.custid <= @max_custid 
		-- Production
		AND ci.custid IN 
		(
			-- dummy account
			2,3,4,5,12,13,15
		)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
		
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END