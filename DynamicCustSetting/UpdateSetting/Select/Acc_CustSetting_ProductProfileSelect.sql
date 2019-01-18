/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductProfileSelect]   
	@ProductID	TINYINT = NULL,
	@SettingType SMALLINT = NULL,
	@SystemID	TINYINT  = 0 
AS  
/*  
 Created: 20150702@Dominic  
 Task : Get Product Profile  
 DB:  DBCUST/CustDB  
 Original:  
  
 Param's Explanation:  

 Revisions: 
	- 20190116@Johnson: grant permission for bodbDownlineNetView [redmine:#106601]
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