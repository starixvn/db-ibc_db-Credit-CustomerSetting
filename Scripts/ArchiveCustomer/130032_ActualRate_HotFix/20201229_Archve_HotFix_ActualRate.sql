/*<info serverAlias="DBTXN-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20201229@Helen
	Task: Archive Issue
	DB: DBTRANS/bodb02
*/
USE bodb02

GO

CREATE TABLE #temp_FixData (transid BIGINT, actualrate float, IsFinished BIT DEFAULT (0))
CREATE TABLE #temp_batch (transid BIGINT, actualrate float)

INSERT INTO #temp_FixData (transid, actualrate)
SELECT transid, ISNULL(Oanda.actualrate,ex.actualrate) AS actualrate 
FROM dbo.bettrans b WITH(NOLOCK) 
	OUTER APPLY (SELECT TOP 1 actualrate
				FROM CUSTDB.dbo.ExchangeDailyOanda e WITH (NOLOCK) 
				WHERE e.exchangeid = b.currency AND e.ExchangeDate = b.winlostdate
				) AS Oanda
	OUTER APPLY (SELECT TOP 1 actualrate 
				 FROM CustDB.dbo.exchange ex WITH (NOLOCK)
				 WHERE ex.ExchangeId = b.currency) AS Ex			
WHERE bettype = 21004
	AND b.actualrate IS NULL 
	AND winlostdate >= '2020-12-22' 
	AND b.transdesc like '%For Delete Account - %'

WHILE (1=1)
BEGIN
	UPDATE TOP (2000) c WITH (ROWLOCK,UPDLOCK)
		SET isfinished = 1
	OUTPUT deleted.transid, deleted.actualrate INTO #temp_batch(transid,actualrate)
	FROM #temp_FixData c 
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0
		BREAK
	
	UPDATE b WITH (ROWLOCK,UPDLOCK)
		SET actualrate = c.actualrate
	FROM bettrans b
		INNER JOIN #temp_batch c ON b.transid = c.transid
	
	TRUNCATE TABLE #temp_batch
	
	WAITFOR DELAY '00:00:00.100'
	
END

DROP TABLE #temp_FixData
DROP TABLE #temp_batch



