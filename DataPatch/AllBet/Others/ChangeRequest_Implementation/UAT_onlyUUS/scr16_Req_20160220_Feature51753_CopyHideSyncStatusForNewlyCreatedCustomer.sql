/*
	Created: Helen	
	Task: Initialize Hide/SYNC Status of AllBet for Newly created Credit customers
	DB: DBCUST/CustDB
	Date: 20160301
*/ 
DECLARE @max_custid INT, @Mod BIT
	
SELECT @max_custid = xxx

CREATE TABLE #supers (CustID INT)	

INSERT INTO #supers
SELECT custid
FROM custInfo WITH (NOLOCK)
WHERE roleid = 4 AND custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	

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


	
		