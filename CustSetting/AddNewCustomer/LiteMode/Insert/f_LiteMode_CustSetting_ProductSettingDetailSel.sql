/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(@SettingType TINYINT = NULL, @CreationStatus TINYINT = 0, @siteid SMALLINT=0, @currency SMALLINT=0)  
RETURNS TABLE
AS
/*
	Created: 20230523@Johnson
	DB: DBCust/CustDB
	Task: Get product setting detail for LiteMode
	Original: f_CustSetting_ProductSettingDetailSel
	
	Revision:
		- 20230523@Johnson: Init function [RedmineID: #179159]

	Param's Explanation:
	SELECT * FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,3)
*/
RETURN
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType,CreationStatus
	FROM dbo.ProductSettingProfile WITH(NOLOCK)
	WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1
								WHEN @CreationStatus = 0 THEN 0
								ELSE NULL END 
		AND CreationStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 0
	UNION
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,p.ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType,CreationStatus
	FROM dbo.ProductSettingProfile p WITH(NOLOCK)
		INNER JOIN ProductProfileSiteCurrency s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1
								WHEN @CreationStatus = 0 THEN 0
								ELSE NULL END 
		AND CreationStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 1
		AND s.SiteID = @SiteID
		AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END	
	UNION
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType,CreationStatus
	FROM dbo.ProductSettingProfile_UAT WITH(NOLOCK)
	WHERE @CreationStatus = 3
		AND CreationStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 0
	UNION 
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,p.ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType,CreationStatus
	FROM dbo.ProductSettingProfile_UAT p WITH(NOLOCK)
		INNER JOIN ProductProfileSiteCurrency_UAT s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1
								WHEN @CreationStatus = 0 THEN 0
								ELSE NULL END 
		AND @CreationStatus = 3
		AND CreationStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 1
		AND s.SiteID = @SiteID
		AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
		
GO