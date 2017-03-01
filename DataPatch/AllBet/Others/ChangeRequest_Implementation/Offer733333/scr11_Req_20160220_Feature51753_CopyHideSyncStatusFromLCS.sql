/*
	Created: Helen	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20160820
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
	@srecommend INT	
	--,@maxcustid INT
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF NOT (dbo.f_CheckRepTable('Custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustProductStatus') = 1
	   AND dbo.f_CheckRepTable('ProductSettingDetail') = 1
	   AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
	   )
		RETURN
	
	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		SyncLiveCasino BIT,
		MaxWinLiveCasino SMALLMONEY,
		isAutoResetLiveCasino BIT
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT,
		SyncLiveCasino BIT,
		MaxWinLiveCasino SMALLMONEY,
		isAutoResetLiveCasino BIT
	)
	
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
	
	IF @srecommend IN (2,3,5,12,13)
	BEGIN
		
		CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
		CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
			
		INSERT INTO #DirectMaster (CustID,roleid)
		SELECT custid, roleid
		FROM Customer with(nolock)
		WHERE SITE in ('733333','222223')
			and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and roleid=3 AND srecommend = @srecommend 
			
		--- get direct agent
		INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
		SELECT custid, mrecommend,roleid
		FROM Customer WITH(NOLOCK)
		WHERE SITE in ('733333','222223')
			and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and roleid=2 AND srecommend = @srecommend 
		
		IF EXISTS (SELECT 1 FROM #DirectMaster)
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
			WHERE (ci.mrecommend IN (SELECT custid FROM #DirectMaster) /*AND ci.recommend NOT IN (16129,59308,68531)*/) OR ci.custid = @srecommend
		END
		
		IF EXISTS (SELECT 1 FROM #DirectAgent)
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
			
			WHERE ci.recommend IN (SELECT custid FROM #DirectAgent) 
				OR ci.custid = @srecommend 
				OR ci.custid IN (SELECT mrecommend FROM #DirectAgent) 
		END
	END
	ELSE
	BEGIN
		IF @srecommend IN (1266057,913628,877004,900371,4204225,6032879,896708) --super no, master yes, agent yes
		BEGIN
		
			INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino)
			SELECT custid, roleid, SyncLiveCasino
			FROM Custinfo WITH (NOLOCK)
			WHERE custid = @srecommend
			UNION ALL
			-- Roleid = 3
			SELECT CI.custid, CI.roleid, CI.SyncLiveCasino
			FROM Custinfo CI WITH (NOLOCK)
				INNER JOIN Customer C (NOLOCK) ON CI.custid = c.custid
			WHERE Enabled = 1 
				AND ci.srecommend = @srecommend AND c.Site  IN ('733333','222223')
				AND CI.roleid = 3
				
			INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino)
			SELECT CI.custid, CI.roleid, CI.SyncLiveCasino
			FROM Custinfo CI WITH (NOLOCK)
				INNER JOIN Customer C (NOLOCK) ON CI.custid = C.custid
				INNER JOIN #SMATemp master_tmp (NOLOCK) ON master_tmp.custid = CI.mrecommend AND master_tmp.roleid = 3
			WHERE Enabled = 1 
				AND ci.srecommend = @srecommend AND c.Site  IN ('733333','222223')
				AND CI.roleid = 2
			
			INSERT INTO #MemberTemp (CustID, SyncLiveCasino)
			SELECT ci.custid, ci.SyncLiveCasino
			FROM Custinfo ci WITH (NOLOCK)
				INNER JOIN #SMATemp agent_tmp ON ci.recommend = agent_tmp.CustID AND agent_tmp.roleid = 2
			WHERE CI.srecommend = @srecommend AND CI.roleid = 1  AND Enabled = 1 
			
			
			UPDATE cs
			SET 	
				  bitmapHasSynced = CASE WHEN tmp.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
										 ELSE cs.bitmapHasSynced
									END	 
				, bitmapIsHidden =  CASE WHEN tmp.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
										 ELSE cs.bitmapIsHidden
									END	 
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMATemp tmp WITH (NOLOCK) ON tmp.CustID = cs.CustID
			
			
			UPDATE cs
			SET 	
				  bitmapHasSynced = CASE WHEN tmp.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
										 ELSE cs.bitmapHasSynced
									END	 
				, bitmapIsHidden =  CASE WHEN tmp.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
										 ELSE cs.bitmapIsHidden
									END	 
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberTemp tmp WITH (NOLOCK) ON tmp.CustID = cs.CustID
			
				  	
			
		END
		ELSE IF @srecommend IN (796555,5005322) --Super yes, master yes, agent no
		BEGIN
			INSERT INTO #SMATemp (CustID, roleid, SyncLiveCasino)
			SELECT custid, roleid, SyncLiveCasino
			FROM Custinfo WITH (NOLOCK)
			WHERE custid = @srecommend
			UNION ALL
			-- Roleid = 3
			SELECT CI.custid, CI.roleid, CI.SyncLiveCasino
			FROM Custinfo CI WITH (NOLOCK)
				INNER JOIN Customer C (NOLOCK) ON CI.custid = c.custid
			WHERE Enabled = 1 
				AND ci.srecommend = @srecommend AND c.Site  IN ('733333','222223')
				AND CI.roleid = 3
			
			UPDATE cs
			SET 	
				  bitmapHasSynced = CASE WHEN tmp.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
										 ELSE cs.bitmapHasSynced
									END	 
				, bitmapIsHidden =  CASE WHEN tmp.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
										 ELSE cs.bitmapIsHidden
									END	 
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #SMATemp tmp WITH (NOLOCK) ON tmp.CustID = cs.CustID
			
			
			UPDATE cs
			SET 	
				  bitmapHasSynced = CASE WHEN tmp.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
										 ELSE cs.bitmapHasSynced
									END	 
				, bitmapIsHidden =  CASE WHEN tmp.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
										 ELSE cs.bitmapIsHidden
									END	 
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #MemberTemp tmp WITH (NOLOCK) ON tmp.CustID = cs.CustID
				
		END
		ELSE 
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
				INNER JOIN custInfo CI WITH (NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.srecommend = @srecommend 
		END
	END
	
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site in ('733333','222223')
		AND ci.custid <> 72
		)
		OR ci.custid IN (
			-- dummy account
			2,3,5,12,13
			-- cross site
			/* 
			1. super no, master yes, agent yes(1266057,900371,4204225,674248,877004,6032879)
			2. Super yes, master yes, agent no: 796555, 5005322		
			*/
			,1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322 
		)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 @srecommend = @srecommend
			--,@maxcustid = @max_custid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site in ('733333','222223')
		AND ci.custid <> 72)
		OR ci.custid IN (
			-- dummy account
			2,3,5,12,13
			-- cross site
			/* 
			1. super no, master yes, agent yes(1266057,900371,4204225,674248,877004,6032879)
			2. Super yes, master yes, agent no: 796555, 5005322		
			*/
			,1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322 
		)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustomerInfo_09 @srecommend = @srecommend
			--,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END