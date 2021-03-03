/*<info serverAlias="DBCUST-CUSTDB" executers="" isFunction="0"></info>*/
/*
    Created: 20210303@Helen
	Task: Archive - archive table custsub - [130032]
	DB: DBCUST-CUSTDB 
*/
USE CUSTDB
GO
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_09]
AS
BEGIN
	
	IF dbo.f_CheckRepTable('custSub') = 0 
		OR dbo.f_CheckRepTable('custInfo') = 0 
		RETURN
	
	CREATE TABLE #custSub(
		[subaccid] [int],
		Isfinished BIT
	)

	CREATE TABLE #custSub_batch(
		[subaccid] [int] 
	)

	INSERT INTO #custSub (subaccid)
	SELECT DISTINCT cs.subaccid
	FROM dbo.custsub cs WITH (NOLOCK)
		LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON cs.custid = ci.custid
	WHERE ci.custid IS NULL

	DECLARE @debug_message VARCHAR(500)
	SET @debug_message = CONVERT(VARCHAR(50), GETDATE(), 121)

	WHILE (1 = 1)
	BEGIN
		UPDATE TOP (4500) cs
			SET Isfinished = 1	
		OUTPUT DELETED.subaccid
		INTO #custSub_batch (subaccid)		
		FROM #custSub cs
		WHERE Isfinished IS NULL
		
		IF @@ROWCOUNT = 0
			BREAK
			
		RAISERROR (@debug_message, 0, 1) WITH NOWAIT
		
		DELETE cs
		FROM custsub cs
			INNER JOIN #custSub_batch b ON cs.subaccid = b.subaccid
		
		TRUNCATE TABLE #custSub_batch
		
		WAITFOR DELAY '00:00:00.100'
			
	END
	
	DROP TABLE #custSub
	DROP TABLE #custSub_batch
	
END
GO
-- STEP 1: DEPLOY THIS SP ON @DBCUST.CustDB --------

-- STEP 2: RUN THIS SCRIPT AT DBCUST --------
EXEC dbo.Acc_CustomerInfo_Execrep_09

