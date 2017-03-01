/*
	Created: Helen
	Task: Update Sync Status for SMA & members not offer Allbet - [Redmine:n/a]
	DB: DBCUST/CustDB
	Date: 20161201
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@srecommend INT	
	,@maxcustid INT
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN	
	IF dbo.f_CheckRepTable('CustProductStatus') = 0 RETURN	
	
	DECLARE @xmlStrSync XML
	
	SET @xmlStrSync =(
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
			
	CREATE TABLE #tbl_ListCusts (CustID INT PRIMARY KEY)
	
	INSERT INTO #tbl_ListCusts(CustID)
	SELECT ci.custid
	FROM custInfo CI (NOLOCK)
		LEFT JOIN CustWinLossLimit_Agent PT (NOLOCK) ON CI.custid = PT.CustID AND PT.SportType = 211 AND PT.BetType = 2401 
	WHERE CI.srecommend = @srecommend AND PT.custid IS NULL	AND CI.roleid IN (4,3,2) AND ci.custid <=@maxcustid
	
	UNION ALL
	
	SELECT CI.custId
	FROM custInfo CI (NOLOCK)
		LEFT JOIN CustWinLossLimit_Member PT (NOLOCK) ON CI.custid = PT.CustID AND PT.SportType = 211 AND PT.BetType = 2401 
	WHERE CI.srecommend = @srecommend AND PT.custid IS NULL	AND CI.roleid = 1 AND ci.custid <=@maxcustid
	
	--- Update sync Status
	UPDATE cs
		SET bitmapHasSynced = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync))) 
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN #tbl_ListCusts ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	
	DROP TABLE #tbl_ListCusts	
		
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,exchangeid INT,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.custid <= @max_custid

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend 
			,@maxcustid = @max_custid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,exchangeid INT,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.custid <= @max_custid
		
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
		
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END