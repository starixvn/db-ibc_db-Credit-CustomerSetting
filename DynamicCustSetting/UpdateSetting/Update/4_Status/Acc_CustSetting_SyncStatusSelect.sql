ALTER PROCEDURE [dbo].[Acc_CustSetting_SyncStatusSelect]   
	@CustID	INT , 
	@ProductID INT
AS  
/*  
	Created: 20160201@Elodie
	Task : Get sync status of customer by product
	DB:  DBCUST/CustDB
	Original:  
  
	Param's Explanation:  
   
 */  
BEGIN
	DECLARE @roleid INT, @BitmapOrder TINYINT, @IsHidden BIT, @IsSynced BIT, @IsDownlineSynced BIT
	
	SELECT @IsDownlineSynced = 1

	SELECT @roleid = roleid
	FROM custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	SELECT @BitmapOrder = PSP.bitmapOrder
	FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
		INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
	WHERE psd.SettingType = 4 AND psd.ProductID = @ProductID

	SELECT	@IsHidden = dbo.f_GetProductStatus(cps.bitmapIsHidden, @BitmapOrder)
			,@IsSynced = dbo.f_GetProductStatus(cps.bitmapHasSynced, @BitmapOrder)
	FROM dbo.CustProductStatus cps  WITH (NOLOCK)			
	WHERE cps.CustID = @CustID 

	IF @roleid = 4
	BEGIN
		SELECT @IsDownlineSynced = 0
		FROM dbo.CustProductStatus cpsd  WITH (NOLOCK)
			INNER JOIN custInfo ci WITH (NOLOCK) ON ci.custid = cpsd.CustID
		WHERE ci.srecommend = @CustID AND dbo.f_GetProductStatus(cpsd.bitmapHasSynced, @BitmapOrder) = 0 AND ci.CustID <> @CustID
	END
	ELSE IF @roleid = 3
	BEGIN
		SELECT @IsDownlineSynced = 0
		FROM dbo.CustProductStatus cpsd  WITH (NOLOCK)
			INNER JOIN custInfo ci WITH (NOLOCK) ON ci.custid = cpsd.CustID
		WHERE ci.mrecommend = @CustID AND dbo.f_GetProductStatus(cpsd.bitmapHasSynced, @BitmapOrder) = 0 AND ci.CustID <> @CustID
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT @IsDownlineSynced = 0
		FROM dbo.CustProductStatus cpsd  WITH (NOLOCK)
			INNER JOIN custInfo ci WITH (NOLOCK) ON ci.custid = cpsd.CustID
		WHERE ci.recommend = @CustID AND dbo.f_GetProductStatus(cpsd.bitmapHasSynced, @BitmapOrder) = 0 AND ci.CustID <> @CustID
	END

	SELECT @IsHidden AS IsHidden, @IsSynced AS IsSynced, @IsDownlineSynced AS IsDownlineSynced
END
GO

GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusSelect] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusSelect] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusSelect] TO [bodbDownlineNetView] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustSetting_SyncStatusSelect] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_SyncStatusSelect] TO [vnteam] AS [dbo]
GO


