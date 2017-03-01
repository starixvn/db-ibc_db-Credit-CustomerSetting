/*
	Created: Helen	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20160820
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
	
	IF @roleid = 4
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.srecommend = @Custid AND ci.SyncLiveCasino = 1
	
		UPDATE cs
			SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
		
		UPDATE cs
			SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
	END
	ELSE IF @roleid = 3
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.mrecommend = @Custid AND ci.SyncLiveCasino = 1
		UNION ALL
		SELECT @srecommend
		
		UPDATE cs
		SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID

		UPDATE cs
		SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
		
	END
	ELSE IF @roleid = 2
	BEGIN
		INSERT INTO #cust_tmp (Custid)
		SELECT ci.custid 
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.recommend = @Custid AND ci.SyncLiveCasino = 1
		UNION ALL
		SELECT @srecommend 
		UNION ALL
		SELECT @mrecommend 
		
		UPDATE cs
		SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 6, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID

		UPDATE cs
		SET bitmapIsDisabled = dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0)
		FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #cust_tmp ci WITH(NOLOCK) ON cs.CustID = ci.CustID
	END
	
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, IsDownLine BIT, isfinished bit default(0)) --Mode 0: depend on disable LC, 1: enable all
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @IsDownLine BIT = 0

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.username IN ('S12M',
'S12MM',
'SBHK',
'MMYBRM',
'M83RM',
'RM8',
'MJRMB',
'SJM',
'SJJM',
'SHKK',
'SHHK2',
'SHHK7',
'hhma',
'HHN',
'HHK4',
'SAKM',
'SWM',
'SLLM',
'SATM',
'SKPRMB',
'KPM',
'JJB',
'XKM',
'XKH',
'TLM',
'TLN',
'D71',
'cks',
'C1',
'C2',
'C3',
'C5',
'C7',
'TLH',
'C8',
'C9',
'C10',
'C11',
'C12',
'C13',
'C15',
'H9',
'H1',
'C6',
'H2',
'H3',
'HZ',
'H5',
'CV',
'9H',
'1C',
'EPL',
'KP',
'H8',
'S1',
'S2',
'S3',
'S6',
'S7',
'S9',
'SR',
'CM',
'ZS',
'CN',
'JD',
'JG',
'A6',
'R8',
'A1',
'A2',
'A3',
'A5',
'US',
'J1',
'ZJ',
'CQ',
'A7',
'FJM',
'TS1',
'TS2',
'TS3',
'TS4',
'TS5',
'TS6',
'DK',
'DM',
'CTV',
'CTM'
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
	AND ci.username IN ('S12M',
'S12MM',
'SBHK',
'MMYBRM',
'M83RM',
'RM8',
'MJRMB',
'SJM',
'SJJM',
'SHKK',
'SHHK2',
'SHHK7',
'hhma',
'HHN',
'HHK4',
'SAKM',
'SWM',
'SLLM',
'SATM',
'SKPRMB',
'KPM',
'JJB',
'XKM',
'XKH',
'TLM',
'TLN',
'D71',
'cks',
'C1',
'C2',
'C3',
'C5',
'C7',
'TLH',
'C8',
'C9',
'C10',
'C11',
'C12',
'C13',
'C15',
'H9',
'H1',
'C6',
'H2',
'H3',
'HZ',
'H5',
'CV',
'9H',
'1C',
'EPL',
'KP',
'H8',
'S1',
'S2',
'S3',
'S6',
'S7',
'S9',
'SR',
'CM',
'ZS',
'CN',
'JD',
'JG',
'A6',
'R8',
'A1',
'A2',
'A3',
'A5',
'US',
'J1',
'ZJ',
'CQ',
'A7',
'FJM',
'TS1',
'TS2',
'TS3',
'TS4',
'TS5',
'TS6',
'DK',
'DM',
'CTV',
'CTM',
-- add 222223
'KMM',
'KHH'

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