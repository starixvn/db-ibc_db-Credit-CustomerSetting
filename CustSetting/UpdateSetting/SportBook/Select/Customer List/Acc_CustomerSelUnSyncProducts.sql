/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO 
ALTER PROCEDURE [dbo].[Acc_CustomerSelUnSyncProducts]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2017-09-22
		Task: Get products for GD,Macau,RnG,Allbet which has direct downlines has un-sync settings
		DB: DBCUST/CustDB
		
		Revisions:
			- 20170922@Johnson: Create sp [Redmine: #72973]
		Parameter's Explanations:
		
	*/
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #UnSyncProduct (ProductID INT)
	
	DECLARE @roleid INT,
		@isSyncGD 	BIT,
		@isSyncCS	BIT,
		@isSyncAB 	BIT,
		@isSyncVB	BIT,
		
		@bitmapOrderAB TINYINT,
		@bitmapOrderVB TINYINT
		
	SELECT @roleid = roleid, 
		@isSyncGD = CASE WHEN HideGoldDeluxe = 0 THEN 1 ELSE 0 END,
		@isSyncCS = SyncCasino
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid NOT IN (2,3,4) RETURN
	
	SELECT @bitmapOrderAB = MAX(CASE WHEN sporttype = 211 THEN bitmapOrder ELSE 0 END),
		@bitmapOrderVB = MAX(CASE WHEN sporttype = 212 THEN bitmapOrder ELSE 0 END)
	FROM dbo.ProductStatusProfile WITH(NOLOCK)
	WHERE sporttype IN (211,212)
	
	SELECT @isSyncAB = CAST(CASE WHEN ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderAB),0) = 0 THEN 0 ELSE 1 END AS BIT),
		@isSyncVB = CAST(CASE WHEN ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderVB),0) = 0 THEN 0 ELSE 1 END AS BIT)
	FROM dbo.CustProductStatus cps WITH(NOLOCK)
	WHERE custid = @custid
		
	IF @roleid = 4
	BEGIN	
		--check GD
		IF @isSyncGD = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE srecommend = @custid
						AND roleid = 3
						AND HideGoldDeluxe = 1
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 12
		END
		--Check Casino
		IF @isSyncCS = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE srecommend = @custid
						AND roleid = 3
						AND SyncCasino = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 6
		END		
		--Check AB
		IF @isSyncAB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE srecommend = @custid
						AND roleid = 3
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderAB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 21
		END
		--Check VB
		IF @isSyncVB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE srecommend = @custid
						AND roleid = 3
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderVB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 22
		END
	END
	ELSE IF @roleid = 3
	BEGIN
		--check GD
		IF @isSyncGD = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE mrecommend = @custid
						AND roleid = 2
						AND HideGoldDeluxe = 1
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 12
		END
		--Check Casino
		IF @isSyncCS = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE mrecommend = @custid
						AND roleid = 2
						AND SyncCasino = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 6
		END		
		--Check AB
		IF @isSyncAB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE mrecommend = @custid
						AND roleid = 2
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderAB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 21
		END
		--Check VB
		IF @isSyncVB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE mrecommend = @custid
						AND roleid = 2
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderVB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 22
		END
	END
	ELSE IF @roleid = 2
	BEGIN
		--check GD
		IF @isSyncGD = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE recommend = @custid
						AND roleid = 1
						AND HideGoldDeluxe = 1
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 12
		END
		--Check Casino
		IF @isSyncCS = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK)
					WHERE recommend = @custid
						AND roleid = 1
						AND SyncCasino = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 6
		END		
		--Check AB
		IF @isSyncAB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE recommend = @custid
						AND roleid = 1
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderAB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 21
		END
		--Check VB
		IF @isSyncVB = 1
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo ci WITH(NOLOCK)
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON ci.custid = cps.custid
					WHERE recommend = @custid
						AND roleid = 1
						AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrderVB) = 0
					)
			INSERT INTO #UnSyncProduct (productID)
			SELECT 22
		END
	END
	
	SELECT * 
	FROM #UnSyncProduct	
END
GO