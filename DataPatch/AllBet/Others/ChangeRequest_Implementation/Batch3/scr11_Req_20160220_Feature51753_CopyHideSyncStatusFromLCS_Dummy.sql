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
	   AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
	   )
		RETURN
	
	CREATE TABLE #CustListTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
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
	INSERT INTO #CustListTemp (CustID,SyncLiveCasino)
	SELECT CI.CustID,CI.SyncLiveCasino -- Direct Master 
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
	UNION 
	SELECT DISTINCT CI.CustID,CI.SyncLiveCasino -- Master of direct agent
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
	WHERE CI.custid NOT IN (4174,4178,4300,8619,4177,4183) -- under this master having direct agent of 7555555			
	
	UNION 

	SELECT CI.CustID,CI.SyncLiveCasino -- Agent of direct master
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
	WHERE CI.roleid = 2 
				
	UNION 
	SELECT CI.CustID,CI.SyncLiveCasino -- Direct Agent
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.custid = D.CustID 
	
	UNION 

	SELECT DISTINCT CI.CustID,CI.SyncLiveCasino -- Master of direct member
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember D ON CI.custid = D.mrecommend 
	WHERE  ci.Enabled = 1 AND CI.custid NOT IN (4174,4178,4300,8619,4177,4183)

	UNION 
	SELECT DISTINCT CI.CustID,CI.SyncLiveCasino -- agent of direct member
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember D ON CI.custid = D.recommend 
	WHERE  ci.Enabled = 1 
		
	---------- For members ---------
	INSERT INTO #CustListTemp (CustID, SyncLiveCasino)
	SELECT CI.custid, SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
	WHERE CI.roleid = 1	

	UNION 
	SELECT CI.custid, SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
	WHERE CI.roleid = 1 
	-- Direct member
		
	UNION 
	
	SELECT CI.custid, SyncLiveCasino
	FROM Custinfo CI WITH (NOLOCK)
		INNER JOIN #DirectMember M ON CI.custid = M.CustID
	
	
	DECLARE @xmlStrHidden_0 XML, @xmlStrHidden_1 XML
	DECLARE @xmlStrSync_0 XML,@xmlStrSync_1 XML
	
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
	UPDATE cs
	SET 	
		  bitmapHasSynced = CASE WHEN ci.SyncLiveCasino = 0 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_0)))	
								 ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync_1)))	
							END	 
		, bitmapIsHidden =  CASE WHEN ci.SyncLiveCasino = 1 THEN (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_0)))	
								 ELSE (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_1)))	
							END	 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN #CustListTemp CI WITH (NOLOCK) ON cs.CustID = ci.CustID
	

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
		AND ci.custid IN (2,3,4,5,12,13,15) -- dummy account
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
		AND ci.custid IN (2,3,4,5,12,13,15) -- dummy account
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