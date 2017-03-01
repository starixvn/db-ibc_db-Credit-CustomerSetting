/*
	Created: Elodie	
	Task: Hide Product Status of AllBet for line 1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322 
	DB: DBCUST/CustDB
	Date: 20161216
*/ 
USE CustDB
GO 

DECLARE @xmlStrHidden_1 XML

SET @xmlStrHidden_1 =(
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

SELECT custid
INTO #CustTemp
FROM custInfo WITH (NOLOCK)
WHERE srecommend IN (1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322)

-- 5427 affected rows
UPDATE cs
SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_1)))	
FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #CustTemp ci WITH(NOLOCK) ON cs.CustID = ci.CustID