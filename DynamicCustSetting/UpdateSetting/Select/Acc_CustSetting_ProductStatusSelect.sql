ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductStatusSelect]   
	@CustID	INT = NULL, @IsMultiple INT = 0
AS  
/*  
	Created: 20150702@Helen
	Task : Get Product Profile  
	DB:  DBCUST/custdb ; DBAGE/bodb02 ; DBACC/bodb02 
	Original:  
 
	Revision: 
		- 20160801@Elodie: Implementing GameStatus Setting - [Redmine: #60809]
		- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]	
	Param's Explanation:  
   
 */  
 
 
BEGIN

	IF @IsMultiple = 0
	BEGIN
		SELECT DISTINCT P.productID,P.ProductName,psd.SettingLevel,psd.SportType,psd.Bettype
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, PSP.bitmapOrder)) AS IsHidden
		FROM DBAGE.bodb02.dbo.Products P WITH (NOLOCK)
			INNER JOIN dbo.ProductSettingDetail psd WITH(NOLOCK)  ON P.productID = PSD.ProductID
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
			INNER JOIN dbo.CustProductStatus cps  WITH (NOLOCK) ON cps.CustID =  @CustID
		WHERE psd.SettingType IN (4	,11, 13)
	END
	ELSE IF @IsMultiple = 1
	BEGIN
		DECLARE @roleid INT
		SELECT @roleid = roleid
		FROM custInfo WITH (NOLOCK)
		WHERE custid = @CustID
		
		IF @roleid = 4
		BEGIN
			SELECT DISTINCT P.productID,P.ProductName,psd.SettingLevel,psd.SportType,psd.Bettype
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, PSP.bitmapOrder)) AS IsHidden
			FROM DBAGE.bodb02.dbo.Products P WITH (NOLOCK)
				INNER JOIN dbo.ProductSettingDetail psd WITH(NOLOCK)  ON P.productID = PSD.ProductID
				INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
				INNER JOIN dbo.CustProductStatus cps  WITH (NOLOCK) ON cps.CustID IN (SELECT CustID FROM custInfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)
			WHERE psd.SettingType IN (4	,11, 13)
		
		END
		ELSE IF @roleid = 3
		BEGIN
			SELECT DISTINCT P.productID,P.ProductName,psd.SettingLevel,psd.SportType,psd.Bettype
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, PSP.bitmapOrder)) AS IsHidden
			FROM DBAGE.bodb02.dbo.Products P WITH (NOLOCK)
				INNER JOIN dbo.ProductSettingDetail psd WITH(NOLOCK)  ON P.productID = PSD.ProductID
				INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
				INNER JOIN dbo.CustProductStatus cps  WITH (NOLOCK) ON cps.CustID IN (SELECT CustID FROM custInfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 2)
			WHERE psd.SettingType IN (4	,11, 13)
			
		END
		ELSE IF @roleid = 2
		BEGIN
			SELECT DISTINCT P.productID,P.ProductName,psd.SettingLevel,psd.SportType,psd.Bettype
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabled
			, (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, PSP.bitmapOrder)) AS IsHidden
			FROM DBAGE.bodb02.dbo.Products P WITH (NOLOCK)
				INNER JOIN dbo.ProductSettingDetail psd WITH(NOLOCK)  ON P.productID = PSD.ProductID
				INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
				INNER JOIN dbo.CustProductStatus cps  WITH (NOLOCK) ON cps.CustID IN (SELECT CustID FROM custInfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid = 1)
			WHERE psd.SettingType IN (4	,11, 13)
			
		END
		
	END	
END
 
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbExtAccNet]

	