/*
	Created: Elodie	
	Task: Synced Product Status of AllBet for batch 2
	DB: DBCUST/CustDB
	Date: 20161216
*/ 
USE CustDB
GO 

CREATE TABLE #supers (custid int)

DECLARE @max_custid INT

SELECT @max_custid =xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site in ('733333','222223')
		AND ci.custid <> 72

CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	SyncLiveCasino BIT
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT,
	SyncLiveCasino BIT
)
	
CREATE TABLE #TempCust (CustID INT PRIMARY KEY, roleID INT,SyncLiveCasino BIT)
	
DECLARE @xmlStrSync_1 XML
DECLARE @xmlStrSync_0 XML
	
SET @xmlStrSync_1 =(
		SELECT (
				SELECT psp.bitmapOrder	AS '@b'
					, 1	AS '@s'
				FROM ProductStatusProfile psp WITH (NOLOCK)
				WHERE psp.Sporttype = 211 AND Bettype IN (2401,2402)	
				FOR XML PATH('r')
					, TYPE
				)
		FOR XML PATH('root')
			, TYPE
		)
	
SET @xmlStrSync_0 =(
		SELECT (
				SELECT psp.bitmapOrder	AS '@b'
					, 0	AS '@s'
				FROM ProductStatusProfile psp WITH (NOLOCK)
				WHERE psp.Sporttype = 211 AND Bettype IN (2401,2402)	
				FOR XML PATH('r')
					, TYPE
				)
		FOR XML PATH('root')
			, TYPE
		)

--For dummy 2,3,5,12,13 		
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
			
INSERT INTO #DirectMaster (CustID,roleid)
SELECT custid, roleid
FROM Customer with(nolock)
WHERE SITE in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=3 AND srecommend IN (2,3,5,12,13)
	AND custid > @max_custid
			
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE SITE in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend IN (2,3,5,12,13)
	AND custid > @max_custid
		
IF EXISTS (SELECT 1 FROM #DirectMaster)
BEGIN
	-- Update Master
	UPDATE cs
	SET 	
			bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
									ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.custid IN (SELECT custid FROM #DirectMaster)
		AND ci.roleid = 3
			
	-- Update Agent
	UPDATE cs
	SET 	
			bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
									ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.mrecommend IN (SELECT custid FROM #DirectMaster)
		AND ci.roleid = 2
			
	-- Update Member
	UPDATE cs
	SET 	
			bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
									ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.mrecommend IN (SELECT custid FROM #DirectMaster) 
			AND ci.roleid = 1
			
END
		
IF EXISTS (SELECT 1 FROM #DirectAgent)
BEGIN
	-- Update Agent
	UPDATE cs
	SET 	
			bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
									ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.custid IN (SELECT custid FROM #DirectAgent) 
		AND ci.roleid = 2	
			
	-- Update Member
	UPDATE cs
	SET 	
			bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
									ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.recommend IN (SELECT custid FROM #DirectAgent) 
		AND ci.roleid = 1		 
				
END
--End dummy 2,3,5,12,13 

INSERT INTO #TempCust (CustID,roleID,SyncLiveCasino)
SELECT CI.custid,roleid,SyncLiveCasino
FROM custInfo CI WITH (NOLOCK) 
WHERE ci.srecommend IN (SELECT custid FROM #supers)
	AND CI.custid > @max_custid
			
UPDATE cs
SET 	
		bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
								ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
						END	 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #TempCust CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.roleID = 4
			
UPDATE cs
SET 	
		bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
								ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
						END	 
				
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #TempCust CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.roleID = 3
			
UPDATE cs
SET 	
		bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
								ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
						END	 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #TempCust CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.roleID = 2
			
UPDATE cs
SET 	
		bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
								ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
						END	 
				
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #TempCust CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.roleID = 1
	



