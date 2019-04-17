/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_SettingTypeConfigSel
	@ProductID		TINYINT,
	@SettingType	SMALLINT,
	@SystemID		TINYINT  = 0,
	@IsTest			BIT = 0
AS  
/*  
	Created: 20181212@Elodie
	Task : Get SettingType of Product
	DB:  DBCUST/CustDB  
	Original:  
	
	Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]

	Param's Explanation:  
		
	Example: 
		EXEC CS_SettingTypeConfigSel @ProductID = 1, @SettingType = 1, @IsTest = 1
		EXEC CS_SettingTypeConfigSel @ProductID = 1, @SettingType = 2, @IsTest = 1

 */  
BEGIN   
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, @SettingType, @IsTest)
	
	--SELECT ProductID,SettingType,SystemID,DisplayMode
	--INTO #ProductSettingSiteDisplay
	--FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)
	--WHERE ProductID = @ProductID AND SystemID = @SystemID
	
	IF @SettingType = 1
	BEGIN
		SELECT ft.ProductID, ft.SettingType, ft.SportType, ft.Bettype, ft.IsLive, pdt.MaxPT, pdt.IntervalValue, pdt.SettingLevel, pdt.DisplayOrder, pdt.ChildOrder, pdt.LayoutType
				--1 - Update
				--2 - Read Only
				--3 - Hidden
				--, ISNULL(dpl.DisplayMode,1) DisplayMode				
		FROM dbo.CS_ProductSettingDetail pdt WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			--LEFT JOIN #ProductSettingSiteDisplay dpl ON dpl.SettingType = pdt.SettingType
		ORDER BY pdt.DisplayOrder, pdt.ChildOrder
	END	
	ELSE IF @SettingType = 2
	BEGIN
		SELECT ft.ProductID, ft.SettingType, ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId,
				CASE WHEN gc.GroupId IS NULL THEN pdt.MaxDiscount ELSE gc.MaxValue END AS MaxDiscount, 
				pdt.IntervalValue, pdt.SettingLevel, pdt.DisplayOrder, pdt.ChildOrder, pdt.LayoutType
				--1 - Update
				--2 - Read Only
				--3 - Hidden
				--, ISNULL(dpl.DisplayMode,1) DisplayMode
		FROM dbo.CS_ProductSettingDetail pdt WITH(NOLOCK)			
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = ft.SportType AND gc.BetType = ft.Bettype AND gc.IsLive = ft.IsLive
			--LEFT JOIN #ProductSettingSiteDisplay dpl ON dpl.SettingType = pdt.SettingType
		ORDER BY pdt.DisplayOrder, pdt.ChildOrder
	END
	
	DROP TABLE #SportBettypeFilter
END  
GO