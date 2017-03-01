/*
	Created: Elodie	
	Task: Initialize Product Status of AllBet for Credit customers
	DB: DBCUST/CustDB
	Date: 20160301
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
	@Custid INT
	,@roleid TINYINT
	,@srecommend INT
	,@mrecommend INT	
	,@Mode BIT	
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DB233') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DB233') RETURN -- run at dbtrans only
	
	IF NOT (dbo.f_CheckRepTable('Custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustProductStatus') = 1
	   AND dbo.f_CheckRepTable('ProductSettingDetail') = 1
	   AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
	   )
		RETURN
	

	/*******************************CUST PRODUCT STATUS TABLE*******************************/	
	IF @Mode = 1 -- NOT reply on LC
	BEGIN
		IF @roleid = 4
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.srecommend = @Custid
		END
		ELSE IF @roleid = 3
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.mrecommend = @Custid

			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.custid = @srecommend
		END
		ELSE IF @roleid = 2
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.recommend = @Custid

			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.custid = @srecommend OR ci.custid = @mrecommend
		END
	END

	IF @Mode = 0 -- reply on LC
	BEGIN
		IF @roleid = 4
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.srecommend = @Custid
		END
		ELSE IF @roleid = 3
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.mrecommend = @Custid

			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.custid = @srecommend
		END
		ELSE IF @roleid = 2
		BEGIN
			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.recommend = @Custid

			UPDATE cs
			SET bitmapIsDisabled = CASE WHEN ci.SyncLiveCasino = 1 AND ci.DisableLiveCasino = 0 THEN dbo.f_GenerateProductStatus(bitmapIsDisabled, 7, 0) ELSE bitmapIsDisabled END
			FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
				INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID
			WHERE ci.custid = @srecommend OR ci.custid = @mrecommend
		END
	END
	
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, Mode BIT, isfinished bit default(0)) --Mode 0: depend on disable OneRNG, 1: enable all
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @Mode BIT

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid, Mode)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid, 1 AS mode
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.site = '733333' and ci.roleid = 4
	-- get Username from excel file
	--AND ci.username IN (--733333 site
	--					'S922H','M922M','S922M','S922N','S922L','S922P','S922W','S922G','S922MA','S922A','SKKM','S09H','S09M','MMYBRM','PTM','S69R','S47R',
	--					--789y site
	--					'SJU','S99U','SLA','KKU','KKU1','KKV','KKP','KKQ','KKX','KKZ','KKA','KKW','KKO','K1K','K2K','S88US','SCC','VIP','SKKS','SKS','SKT'
	--					)
						

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid, Mode)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid, 0 AS mode
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND ci.site = '733333' and ci.roleid = 4
	-- get Username from excel file
	--AND ci.username IN (--733333 site
	--					'S922H','M922M','S922M','S922N','S922L','S922P','S922W','S922G','S922MA','S922A','SKKM','S09H','S09M','MMYBRM','PTM','S69R','S47R',
	--					--789y site
	--					'SJU','S99U','SLA','KKU','KKU1','KKV','KKP','KKQ','KKX','KKZ','KKA','KKW','KKO','K1K','K2K','S88US','SCC','VIP','SKKS','SKS','SKT'
	--					)
						
						
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
		,@Mode = Mode
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@Mode = @Mode
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #Cust (custid int, srecommend INT, mrecommend INT, roleid TINYINT, Mode BIT, isfinished bit default(0)) --Mode 0: depend on disable OneRNG, 1: enable all
DECLARE @custid int, @srecommend INT, @mrecommend INT, @roleid TINYINT, @Mode BIT

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid, Mode)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid, 1 AS mode
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	-- Production
	AND ci.site = '733333' and ci.roleid = 4
	--AND ci.username IN (--733333 site
	--					'S922H','M922M','S922M','S922N','S922L','S922P','S922W','S922G','S922MA','S922A','SKKM','S09H','S09M','MMYBRM','PTM','S69R','S47R',
	--					--789y site
	--					'SJU','S99U','SLA','KKU','KKU1','KKV','KKP','KKQ','KKX','KKZ','KKA','KKW','KKO','K1K','K2K','S88US','SCC','VIP','SKKS','SKS','SKT'
	--					)
						

INSERT INTO #Cust(custid, srecommend, mrecommend, roleid, Mode)
SELECT ci.custid, ci.srecommend, ci.mrecommend, ci.roleid, 0 AS mode
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	-- Production
	AND ci.site = '733333' and ci.roleid = 4
	--AND ci.username IN (--733333 site
	--					'S922H','M922M','S922M','S922N','S922L','S922P','S922W','S922G','S922MA','S922A','SKKM','S09H','S09M','MMYBRM','PTM','S69R','S47R',
	--					--789y site
	--					'SJU','S99U','SLA','KKU','KKU1','KKV','KKP','KKQ','KKX','KKZ','KKA','KKW','KKO','K1K','K2K','S88US','SCC','VIP','SKKS','SKS','SKT'
	--					)
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Cust
	SET isfinished = 1
		,@custid = custid	
		,@srecommend = srecommend	
		,@mrecommend = mrecommend
		,@roleid = roleid
		,@Mode = Mode
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustomerInfo_09 
			@custid = @custid			
			,@srecommend = @srecommend
			,@mrecommend = @mrecommend
			,@roleid = @roleid
			,@Mode = @Mode
			,@target = 'DBCUST'
			
			
	waitfor delay '00:00:0.280'
END