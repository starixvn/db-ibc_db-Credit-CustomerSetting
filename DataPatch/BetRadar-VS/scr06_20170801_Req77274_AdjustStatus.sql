/*
	Created: Elodie
	Task: Adjust status for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_09]
AS
BEGIN
	SET NOCOUNT ON

	IF NOT (dbo.f_CheckRepTable('Custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustProductStatus') = 1
	   AND dbo.f_CheckRepTable('ProductSettingDetail') = 1
	   AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
	   )
		RETURN	

	DECLARE @BitmapOrder TINYINT = 10

	CREATE TABLE #CustList_Status (custid INT)
	CREATE TABLE #supers (custid INT)

	INSERT INTO #supers(custid)
	SELECT ci.custid
	FROM customer ci WITH (NOLOCK) 
		INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
		LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
	WHERE ci.roleid = 4  
				AND ci.username NOT LIKE '3rdSuper%'
				AND cs.isinternal = 0
				AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
				AND s.islicensee = 0

	INSERT INTO #CustList_Status (custid)
	SELECT ci.custid
	FROM [dbo].[CustProductStatus] cs WITH(NOLOCK)
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID	
	WHERE ci.srecommend IN (SELECT custid FROM #supers) 
		AND (cs.bitmapIsHidden <> (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(bitmapIsHidden, @BitmapOrder, ci.HideVirtualSports))  				
		OR bitmapIsDisabled <> CASE WHEN ci.HideVirtualSports = 1 THEN (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, 1))
								ELSE (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(bitmapIsDisabled, @BitmapOrder, ci.DisableVirtualSports)) END)
		
	RAISERROR('Done: Get the affected downlines list for status', 0, 1)  WITH NOWAIT

	UPDATE cs
		SET cs.bitmapIsHidden = (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitmapOrder,ci.HideVirtualSports)),
			bitmapIsDisabled = CASE WHEN ci.HideVirtualSports = 1 THEN (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitmapOrder,1)) 
									ELSE (SELECT NewBitmap FROM dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitmapOrder,ci.DisableVirtualSports)) END
	FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN #CustList_Status c WITH(NOLOCK) ON cs.CustID = c.CustID	
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON cs.CustID = ci.CustID	

	RAISERROR('Done: Update the affected downlines list for status', 0, 1)  WITH NOWAIT
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT DBCUST SERVERS -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_DynamicCustomerInfo_09 
