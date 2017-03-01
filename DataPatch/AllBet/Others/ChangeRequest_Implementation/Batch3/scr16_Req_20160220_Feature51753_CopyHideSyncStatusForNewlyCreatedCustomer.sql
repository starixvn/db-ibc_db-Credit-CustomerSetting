/*
	Created: Helen	
	Task: Initialize Hide/SYNC Status of AllBet for Newly created Credit customers
	DB: DBCUST/CustDB
	Date: 20160820
*/ 
DECLARE @max_custid INT, @Mod BIT
	
SELECT @max_custid = xxx

CREATE TABLE #supers (CustID INT)	

INSERT INTO #supers
SELECT custid
FROM  Customer WITH (NOLOCK)
WHERE roleid = 4 AND custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND site in ('733333','222223')
	and custid not in (1266057,900371,4204225,674248,877004,6032879,796555,5005322) -- cross site
		/* 
			1. super no, master yes, agent yes(1266057,900371,4204225,674248,877004,6032879)
			2. Super yes, master yes, agent no: 796555, 5005322		
		*/

	AND custid <> 72

DECLARE @xmlStrHidden_0 XML
DECLARE @xmlStrSync_0 XML

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

/*******************************CUST PRODUCTSTATUS TABLE*******************************/	
UPDATE cs
		SET 	
			  bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
									 ELSE cs.bitmapHasSynced
								END	 
			, bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
									 ELSE cs.bitmapIsHidden
								END	 
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.CustID
WHERE ci.srecommend IN (SELECT CustID FROM #supers)
	AND ci.CustID > @max_custid 

-- For dummy

CREATE TABLE #DirrectMaster (custid INT)
CREATE TABLE #DirrectAgent (custid INT, mrecommend INT)

--Get Dirrect master
INSERT INTO #DirrectMaster(custid)
SELECT ci.custid
FROM customer c WITH(NOLOCK)
	INNER JOIN CustInfo ci WITH(NOLOCK) ON c.custid = ci.custid
WHERE ci.srecommend in (2,3,5,12,13) AND c.site in ('733333','222223') AND ci.roleid = 3

--Get Dirrect agent
INSERT INTO #DirrectAgent(custid, mrecommend)
SELECT ci.custid, ci.mrecommend
FROM customer c WITH(NOLOCK)
	INNER JOIN CustInfo ci WITH(NOLOCK) ON c.custid = ci.custid
WHERE ci.srecommend in (2,3,5,12,13) AND c.site in ('733333','222223') AND ci.roleid = 2
	AND ci.mrecommend NOT IN (SELECT custid FROM #DirrectMaster)

IF EXISTS (SELECT 1 FROM #DirrectMaster)
BEGIN
	UPDATE cs
		SET 	
		  bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
								 ELSE cs.bitmapHasSynced
							END	 
		, bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								 ELSE cs.bitmapIsHidden
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	WHERE ci.CustID > @max_custid AND (ci.mrecommend IN (SELECT custid FROM #DirrectMaster))
END

IF EXISTS (SELECT 1 FROM #DirrectAgent)
BEGIN
	UPDATE cs
		SET 	
		  bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
								 ELSE cs.bitmapHasSynced
							END	 
		, bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								 ELSE cs.bitmapIsHidden
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	
	WHERE ci.CustID > @max_custid 
		AND (ci.recommend IN (SELECT custid FROM #DirrectAgent) 
			 OR ci.custid IN (SELECT mrecommend FROM #DirrectAgent)
			 )
END	
			
	
		