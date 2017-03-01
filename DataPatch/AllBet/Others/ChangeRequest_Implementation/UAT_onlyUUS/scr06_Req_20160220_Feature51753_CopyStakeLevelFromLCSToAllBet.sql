/*
	Created: Elodie
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
		SyncLiveCasino BIT,
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT,
		SyncLiveCasino BIT,
	)
	
	INSERT INTO #MemberTemp (CustID, SyncLiveCasino)
	SELECT custid, SyncLiveCasino
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
	INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino)
	SELECT custid, roleid, SyncLiveCasino
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid IN (2,3,4) AND Enabled = 1 AND custid <= @maxcustid 

	--Bettype 2402: Lowest VIP Bet limit
	DECLARE @StakeLevelList_2402 VARCHAR(100)
	
	SELECT TOP 1 @StakeLevelList_2402 =  StakeLevelID 
	FROM dbo.StakeLevel WITH(NOLOCK) 
	WHERE ExchangeId = @exchangeID AND GameTypeID = 2402 

	INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)	
	SELECT CustID, 211, 2402, CASE WHEN SyncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
	FROM #SMATemp 

	INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)	
	SELECT CustID, 211, 2402, CASE WHEN SyncLiveCasino = 1 THEN @StakeLevelList_2402 ELSE '' END AS StakeLevelList
	FROM #MemberTemp

	--Bettype 2402: Done

	--Bettype 2401: Copy setting from LC
	IF @syncLiveCasino_super = 0
	BEGIN -- not sync yet, just put empty stakelevellist		
		--SMA Level
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, ''
		FROM #SMATemp ci 

		--Member Level
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, ''
		FROM #MemberTemp ci 
		
		RETURN
	END

	SELECT @stakeLevelList2401_super = StakeLevelList_AllBet
	FROM dbo.tmpCustGameType WITH(NOLOCK)
	WHERE custid = @srecommend
	
	DECLARE @StakeLevelList_2401_lowest VARCHAR(100)
	SELECT TOP 1 @StakeLevelList_2401_lowest =  StakeLevelID 
	FROM dbo.StakeLevel WITH(NOLOCK) 
	WHERE ExchangeId = @exchangeID AND GameTypeID = 2401
	ORDER BY MaxStake, MinStake
		
	--If don't have stake level for this line yet, just put lowest value 
	IF ISNULL(@stakeLevelList2401_super,'') = '' 
	BEGIN
		--SMA Level
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, @StakeLevelList_2401_lowest
		FROM #SMATemp ci 
		--Member Level
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)		
		SELECT custid, 211, 2401, @StakeLevelList_2401_lowest
		FROM #MemberTemp ci 
		
		RETURN
	END
		
	IF @stakeLevelList2401_super <> ''
	BEGIN
		-- all done, start insert
		INSERT INTO dbo.CustStakeLevel_Agent(CustID, SportType, BetType, StakeLevelList)
		SELECT @srecommend, 211, 2401, @stakeLevelList2401_super 
		UNION ALL
		SELECT T1.custid, 211, 2401, CASE WHEN SyncLiveCasino = 1 THEN ISNULL(T2.StakeLevelList_AllBet,@StakeLevelList_2401_lowest) ELSE '' END AS stakeLevelList
		FROM #SMATemp T1
			LEFT JOIN tmpCustGameType T2 ON T1.CustID = T2.CustID
			
		WHERE T1.roleid IN (2,3)
		
		--------------------------------------
		INSERT INTO dbo.CustStakeLevel_Member(CustID, SportType, BetType, StakeLevelList)
		SELECT T1.custid, 211, 2401, CASE WHEN T1.SyncLiveCasino = 1 THEN ISNULL(T2.StakeLevelList_AllBet,@StakeLevelList_2401_lowest) ELSE '' END AS stakeLevelList
		FROM #MemberTemp T1
			LEFT JOIN tmpCustGameType T2 ON T1.CustID = T2.CustID
			
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
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx


INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.custid <= @max_custid
	-- UAT
	AND ci.currency = 20
	
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
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.custid <= @max_custid 
	-- Production
	AND ci.currency = 20

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