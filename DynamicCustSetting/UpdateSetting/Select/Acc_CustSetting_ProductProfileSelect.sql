SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductProfileSelect]   
	@ProductID	TINYINT = NULL,
	@SettingType SMALLINT = NULL,
	@SystemID	TINYINT  = 0 
AS  
/*  
 Created: 20150702@Dominic  
 Task : Get Product Profile  
 DB:  DBCUST/custdb  
 Original:  
  
 Param's Explanation:  

   
 */  
BEGIN   
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	SELECT ProductID,SettingType,SystemID,DisplayMode
	INTO #ProductSettingSiteDisplay
	FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)
	WHERE ProductID = @ProductID AND SystemID = @SystemID
	
	SELECT DISTINCT pdt.SettingType, pdt.SettingLevel, pdt.DisplayOrder
			--1 - Update
			--2 - Read Only
			--3 - Hidden
			, ISNULL(dpl.DisplayMode,1) DisplayMode
	FROM dbo.ProductSettingDetail pdt WITH(NOLOCK)
	INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
	LEFT JOIN #ProductSettingSiteDisplay dpl
				ON dpl.SettingType = pdt.SettingType
	ORDER BY pdt.DisplayOrder
	
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbExtAccNet]