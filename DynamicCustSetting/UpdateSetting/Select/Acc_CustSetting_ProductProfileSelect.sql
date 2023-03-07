/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductProfileSelect]   
	@ProductID	TINYINT = NULL,
	@SettingType SMALLINT = NULL,
	@SystemID	TINYINT  = 0,
	@SettingStatus TINYINT = 0
AS  
/*  
	 Created: 20150702@Dominic  
	 Task : Get Product Profile  
	 DB:  DBCUST/CustDB  
	 Original:  

	 Revisions: 
		- 20190116@Johnson: grant permission for bodbDownlineNetView [redmine:#106601]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]

	 Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT 	
 */  
BEGIN   
	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT)

	CREATE TABLE #ProductSettingSiteDisplay(ProductID TINYINT, SettingType SMALLINT,SystemID TINYINT,DisplayMode TINYINT)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		DisplayOrder tinyint,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,DisplayOrder 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
	SELECT SportType,Bettype,IsLive, SettingType 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType,@SettingStatus)
	
	INSERT INTO #ProductSettingSiteDisplay(ProductID,SettingType,SystemID,DisplayMode)
	SELECT ProductID,SettingType,SystemID,DisplayMode
	FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)
	WHERE ProductID = @ProductID AND SystemID = @SystemID
	
	SELECT DISTINCT pdt.SettingType, pdt.SettingLevel, pdt.DisplayOrder
			--1 - Update
			--2 - Read Only
			--3 - Hidden
			, ISNULL(dpl.DisplayMode,1) DisplayMode
	FROM #ProductSettingDetail pdt WITH(NOLOCK)
	INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
	LEFT JOIN #ProductSettingSiteDisplay dpl
				ON dpl.SettingType = pdt.SettingType
	ORDER BY pdt.DisplayOrder
	
	DROP TABLE #SportBettypeFilter
	DROP TABLE #ProductSettingSiteDisplay
	DROP TABLE #ProductSettingDetail
END  
GO