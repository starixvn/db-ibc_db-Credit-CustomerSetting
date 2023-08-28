/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductProfileSelect]   
	@CreationStatus TINYINT = 0,
	@site	VARCHAR(50)= '',
	@currency SMALLINT = 0
AS  
/*  
	 Created: 20230428@Johnson  
	 Task : Get Product Profile for Lite Mode create downlines
	 DB:  DBCUST/CustDB  
	
	 Revisions: 
		- 20230428@Johnson: initial sp [redmine: #179159]

	 Param's Explanation: 
		@CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO
 */  
BEGIN   
	SET NOCOUNT ON
	
	DECLARE @siteID SMALLINT

	SELECT @siteID = siteid FROM Site WITH(NOLOCK) WHERE site = @site
	
	IF @CreationStatus IN (1,0)
	BEGIN
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, CreationStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType
		FROM dbo.ProductSettingProfile p WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 0	
			AND GroupType NOT IN (155)
		UNION 
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, CreationStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType
		FROM dbo.ProductSettingProfile p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 1
			AND GroupType NOT IN (155)
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
		ORDER BY GroupID, GroupTypeOrder, SubGroupOrder, Child_DisplayOrder
	END
	ELSE IF @CreationStatus = 3
	BEGIN			
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, CreationStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType
		FROM dbo.ProductSettingProfile_UAT p WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 0		
			AND GroupType NOT IN (155)
		UNION 
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, CreationStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType
		FROM dbo.ProductSettingProfile_UAT p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE CreationStatus <> 2
			AND GroupID IS NOT NULL
			AND MarketType = 1
			AND GroupType NOT IN (155)
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
		ORDER BY GroupID, GroupTypeOrder, SubGroupOrder, Child_DisplayOrder		
	END
END