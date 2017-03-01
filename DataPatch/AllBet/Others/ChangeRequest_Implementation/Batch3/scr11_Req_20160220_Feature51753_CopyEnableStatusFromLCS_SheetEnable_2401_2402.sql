/*
	Created: Helen	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20161229
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
	@Custid INT
	,@roleid TINYINT
	,@srecommend INT
	,@mrecommend INT	
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
	
	
	/*******************************CUST PRODUCT STATUS TABLE*******************************/	
	CREATE TABLE #cust_tmp (Custid INT PRIMARY KEY)
	
	DECLARE @xmlDisable_0 XML
	
	SET @xmlDisable_0 =(
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
	
	IF @roleid = 4
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.srecommend = @Custid AND ci.SyncLiveCasino = 1 AND roleid IN (1,2,3)
	
		UPDATE cs
			SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		-- Super	
		UPDATE cs
			SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		WHERE cs.CustID = @srecommend	
		
	END
	ELSE IF @roleid = 3
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.mrecommend = @Custid AND ci.SyncLiveCasino = 1 AND roleid IN (1,2,3)
		
		UPDATE cs
		SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		-- Super
		UPDATE cs
			SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		WHERE cs.CustID = @srecommend		

	END
	ELSE IF @roleid = 2
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.recommend = @Custid AND ci.SyncLiveCasino = 1 AND roleid IN (1,2)
		UNION ALL
		SELECT @mrecommend 
		
		UPDATE cs
		SET bitmapIsDisabled =dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		--Super
		UPDATE cs
			SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (cs.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlDisable_0)))
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		WHERE cs.CustID = @srecommend		
	END
	
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (DB04x/DB05x/DB06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, IsDownLine BIT, isfinished bit default(0)) --Mode 0: depend on disable LC, 1: enable all
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @IsDownLine BIT = 0

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.username IN ('TKRM',
'MMYBH',
'BYS',
'MBY',
'BYM',
'BYU',
'6666BP',
'6666EU',
'6666HK',
'M6HK',
'6hk6601',
'M6SD',
'S6EU',
'S6US',
'M6RM',
'6666AHK',
'MPH',
'JPG',
'S6H',
'S6BP',
's6cn',
'S6HK',
'S6RMB',
'S6P',
'S9EU',
'S6AHK',
'BR1',
'SJR',
'SJH',
'SJU',
'SJSD',
'S2R',
'SAKH',
'SWU',
'SWK',
'SATU',
'SATE',
'SATS',
'JK6',
'MMS',
'S8',
'S11',
'P9',
'G1',
'TUK',
'CRR'
)


WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, IsDownLine BIT, isfinished bit default(0)) --Mode 0: depend on disable LC, 1: enable all
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @IsDownLine BIT = 0

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.username IN ('TKRM',
'MMYBH',
'BYS',
'MBY',
'BYM',
'BYU',
'6666BP',
'6666EU',
'6666HK',
'M6HK',
'6hk6601',
'M6SD',
'S6EU',
'S6US',
'M6RM',
'6666AHK',
'MPH',
'JPG',
'S6H',
'S6BP',
's6cn',
'S6HK',
'S6RMB',
'S6P',
'S9EU',
'S6AHK',
'BR1',
'SJR',
'SJH',
'SJU',
'SJSD',
'S2R',
'SAKH',
'SWU',
'SWK',
'SATU',
'SATE',
'SATS',
'JK6',
'MMS',
'S8',
'S11',
'P9',
'G1',
'TUK',
'CRR'
)


WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@target = 'DBCUST'
			
			
	waitfor delay '00:00:0.280'
END