/*
	Created: Elodie	
	Task: Unhide Product Status of AllBet for line 2,13 with 733333 site
	DB: DBCUST/CustDB
	Date: 20160820
*/ 
USE CustDB
GO 

DECLARE @xmlStrHidden_0 XML

SET @xmlStrHidden_0 =(
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
					
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
			
INSERT INTO #DirectMaster (CustID,roleid)
SELECT custid, roleid
FROM Customer with(nolock)
WHERE SITE in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=3 AND srecommend IN (2,13) 
			
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE SITE in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend IN (2,13) 
		
IF EXISTS (SELECT 1 FROM #DirectMaster)
BEGIN
	--Update Master
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.custid IN (SELECT custid FROM #DirectMaster) 
		AND ci.roleid = 3

	--Update Agent
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.mrecommend IN (SELECT custid FROM #DirectMaster) 
		AND ci.roleid = 2

	--Update Member
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.mrecommend IN (SELECT custid FROM #DirectMaster) 
		AND ci.roleid = 1
END
		
IF EXISTS (SELECT 1 FROM #DirectAgent)
BEGIN
	-- Update Master
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	  
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.custid IN (SELECT mrecommend FROM #DirectAgent)
		AND cs.CustID <> 4300

	-- Update Agent
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	  
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.custid IN (SELECT custid FROM #DirectAgent)
		AND ci.roleid = 2

	-- Update Member
	UPDATE cs
	SET bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								ELSE cs.bitmapIsHidden
							END	 	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.recommend IN (SELECT custid FROM #DirectAgent)
		AND ci.roleid = 1
END
	
