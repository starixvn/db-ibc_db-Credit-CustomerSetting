/*
	Created: Helen	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20160820
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
	@srecommend INT	
	,@maxcustid INT
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
			and roleid=3 AND srecommend = @srecommend AND custid <= @maxcustid
			
		--- get direct agent
		INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
		SELECT custid, mrecommend,roleid
		FROM Customer WITH(NOLOCK)
		WHERE SITE in ('733333','222223')
			and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and roleid=2 AND srecommend = @srecommend AND custid <= @maxcustid
		
		IF EXISTS (SELECT 1 FROM #DirectMaster)
		BEGIN
			UPDATE cs
				SET 	
				
					bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_1)))	
									
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE (ci.mrecommend IN (SELECT custid FROM #DirectMaster) /*AND ci.recommend NOT IN (16129,59308,68531)*/) AND cs.custid <= @maxcustid
		END
		
		IF EXISTS (SELECT 1 FROM #DirectAgent)
		BEGIN
			UPDATE cs
				SET 	
				  bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden_1)))	 
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			
			WHERE (ci.recommend IN (SELECT custid FROM #DirectAgent) 
				OR ci.custid IN (SELECT mrecommend FROM #DirectAgent) ) AND CS.CustID <> 4300
				AND cs.custid <= @maxcustid
		END
	END
	
END

-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE  ci.custid IN (
			-- dummy account
			2,13
		)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
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
WHERE  ci.custid IN (
			-- dummy account
			2,13
		)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustomerInfo_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END