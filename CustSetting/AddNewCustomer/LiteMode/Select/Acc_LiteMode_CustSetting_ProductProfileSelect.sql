/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductProfileSelect]   
	@SettingStatus TINYINT = 0,
	@site	VARCHAR(50)= '',
	@currency SMALLINT = 0,
	@GroupID TINYINT = NULL,
	@SystemID TINYINT  = 0
AS  
/*  
	 Created: 20230428@Johnson  
	 Task : Get Product Profile for Lite Mode create downlines
	 DB:  DBCUST/CustDB  
	
	 Revisions: 
		- 20230428@Johnson: initial sp [redmine: #179159]
		- 20231201@Johnson: Separate PT for Live & RNG Casino [redmine: #197629]
		- 20230918@Eden:  DCS Sportsbook Credit[redmine: #193083]
	 Param's Explanation: 
		@SettingStatus: 0: Pro, 1: UAT, 3: UAT/PRO

		@GroupID = 
			NULL: LiteMode --> all sport
			1: FullMode --> Sportsbook only

	 Examples:
		EXEC [Acc_LiteMode_CustSetting_ProductProfileSelect]
			@SettingStatus = 3,
			@site = 'BEST-ODDS',
			@currency = 20,
			@GroupID = 1,
			@SystemID = 1
 */  
BEGIN   
	SET NOCOUNT ON
	CREATE TABLE #ProductSettingProfile (
		 SettingType	smallint
		,SportType	smallint
		,BetType	smallint
		,IsLive	bit
		,GroupID	tinyint
		,GroupType	tinyint
		,GroupTypeOrder	tinyint
		,SubGroupID	tinyint
		,SubGroupOrder	tinyint
		,SettingStatus	tinyint
		,DisplayType	tinyint
		,Child_DisplayOrder	int
		,ProductSettingID	int
		,MarketType	tinyint
		,ProductID	tinyint
	)
	
	CREATE TABLE #ProductSettingSiteDisplay(ProductID TINYINT, SettingType SMALLINT,SystemID TINYINT,DisplayMode TINYINT)  

	INSERT INTO #ProductSettingSiteDisplay(ProductID,SettingType,SystemID,DisplayMode)  
	SELECT ProductID,SettingType,SystemID,DisplayMode
	FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)  
	WHERE SystemID = @SystemID  

	DECLARE @siteID SMALLINT

	SELECT @siteID = siteid FROM Site WITH(NOLOCK) WHERE site = @site
	
	IF @SettingStatus IN (1,0)
	BEGIN
		INSERT INTO #ProductSettingProfile(SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID)
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID
		FROM dbo.ProductSettingProfile p WITH(NOLOCK)
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 0	
			AND GroupType NOT IN (155,158,159,160)
			AND 1 = CASE WHEN p.GroupID = @GroupID OR @GroupID IS NULL THEN 1 ELSE 0 END
		UNION 
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID
		FROM dbo.ProductSettingProfile p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 1
			AND GroupType NOT IN (155,158,159,160)
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
			AND 1 = CASE WHEN p.GroupID = @GroupID OR @GroupID IS NULL THEN 1 ELSE 0 END
		ORDER BY GroupID, GroupTypeOrder, SubGroupOrder, Child_DisplayOrder
	END
	ELSE IF @SettingStatus = 3
	BEGIN
		INSERT INTO #ProductSettingProfile(SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID)
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID
		FROM dbo.ProductSettingProfile_UAT p WITH(NOLOCK)
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IS NOT NULL
			AND MarketType = 0		
			AND GroupType NOT IN (155,158,159,160)
			AND 1 = CASE WHEN p.GroupID = @GroupID OR @GroupID IS NULL THEN 1 ELSE 0 END
		UNION 
		SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, SettingStatus, DisplayType, Child_DisplayOrder, p.ProductSettingID, MarketType,ProductID
		FROM dbo.ProductSettingProfile_UAT p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE SettingStatus <> 2
			AND GroupID IS NOT NULL
			AND MarketType = 1
			AND GroupType NOT IN (155,158,159,160)
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
			AND 1 = CASE WHEN p.GroupID = @GroupID OR @GroupID IS NULL THEN 1 ELSE 0 END
		ORDER BY GroupID, GroupTypeOrder, SubGroupOrder, Child_DisplayOrder		
	END

	SELECT p.SettingType, p.SportType, p.BetType, p.IsLive, p.GroupID, p.GroupType, p.GroupTypeOrder, p.SubGroupID, p.SubGroupOrder
		, p.SettingStatus, p.DisplayType, p.Child_DisplayOrder, p.ProductSettingID, p.MarketType, p.ProductID
	   --1 - Update  
	   --2 - Read Only  
	   --3 - Hidden  
	   , ISNULL(dpl.DisplayMode,1) DisplayMode  
	 FROM #ProductSettingProfile p WITH(NOLOCK)   
		LEFT JOIN #ProductSettingSiteDisplay dpl  
		ON dpl.SettingType = p.SettingType  
		AND dpl.ProductID = p.ProductID
	 ORDER BY p.GroupID, p.GroupTypeOrder, p.SubGroupOrder, p.Child_DisplayOrder		
END