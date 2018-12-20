/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_ProductProfileSelect
	@ProductID		TINYINT = NULL,
	@SettingType	SMALLINT = NULL,
	@SystemID		TINYINT  = 0,
	@IsTest			BIT = 0
AS  
/*  
	Created: 20181212@Elodie
	Task : Get Product Profile  
	DB:  DBCUST/CustDB  
	Original:  
	
	Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]

	Param's Explanation:  
		
	Example: 
		EXEC CS_ProductProfileSelect @ProductID = 1, @IsTest = 1

 */  
BEGIN   
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, @SettingType, @IsTest)
	
	--SELECT ProductID,SettingType,SystemID,DisplayMode
	--INTO #ProductSettingSiteDisplay
	--FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)
	--WHERE ProductID = @ProductID AND SystemID = @SystemID
	
	SELECT DISTINCT pdt.SettingType, pdt.SettingLevel, pdt.DisplayOrder
			--1 - Update
			--2 - Read Only
			--3 - Hidden
			--, ISNULL(dpl.DisplayMode,1) DisplayMode
	FROM dbo.CS_ProductSettingDetail pdt WITH(NOLOCK)
		INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
		--LEFT JOIN #ProductSettingSiteDisplay dpl ON dpl.SettingType = pdt.SettingType
	ORDER BY pdt.DisplayOrder
	
	DROP TABLE #SportBettypeFilter
END  
GO