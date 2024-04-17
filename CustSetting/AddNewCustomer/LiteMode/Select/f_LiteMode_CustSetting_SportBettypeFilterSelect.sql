/*<info serverAlias="DBCust-CustDB" selecters="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID TINYINT, @GroupType SMALLINT, @SubGroupID TINYINT =NULL, @SettingStatus TINYINT, @siteid smallint= 0, @currency SMALLINT = 0) 
RETURNS @SportBetTypeSetting TABLE (ProductID TINYINT, RealProductID TINYINT, SportType SMALLINT, Bettype SMALLINT, IsLive BIT, IntervalValue DECIMAL(19,8),SubType TINYINT
	, Child_DisplayOrder INT, SettingLevel TINYINT, MaxPT SMALLMONEY,MaxDiscount	DECIMAL(9,8), SubGroupID TINYINT, SubGroupOrder TINYINT)
/*
	Created by: 20230427@Johnson
	Task: Get sport-bettype by product group for Lite Mode
	DB: DBCust/CustDB
	
	Revisions:
		- 20230427@Johnson: Initial sp [redmine: #179159]
		- 20231201@Johnson: get subgroupid [redmine: #197629]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	Explanation's Param:
		@SettingStatus: 0: Pro, 1: UAT, 3: UAT/PRO
		
*/   
BEGIN 
	IF @SettingStatus IN (1,0)
	BEGIN
		INSERT @SportBetTypeSetting(ProductID,RealProductID,SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder)
		SELECT DISTINCT ProductID,RealProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder  
		FROM dbo.ProductSettingProfile WITH(NOLOCK)
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND MarketType = 0
		UNION
		SELECT DISTINCT ProductID,RealProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder
			FROM dbo.ProductSettingProfile p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND MarketType = 1
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END		
	END
	ELSE IF @SettingStatus = 3
	BEGIN
		INSERT @SportBetTypeSetting(ProductID,RealProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder)
		SELECT DISTINCT ProductID,RealProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder
		FROM dbo.ProductSettingProfile_UAT WITH(NOLOCK)
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND SettingStatus <> 2
			AND MarketType = 0
		UNION
		SELECT DISTINCT ProductID,RealProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder, SettingLevel,MaxPT,MaxDiscount,SubGroupID,SubGroupOrder
			FROM dbo.ProductSettingProfile_UAT p  WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND SettingStatus <> 2
			AND MarketType = 1
			AND s.SiteID = @SiteID
			AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END	
	END
	
	RETURN
END