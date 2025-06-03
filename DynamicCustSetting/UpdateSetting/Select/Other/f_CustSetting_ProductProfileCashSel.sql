/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_ProductProfileCashSel (@SettingType TINYINT = NULL, @SettingStatus TINYINT = 0, @siteid SMALLINT=0, @currency SMALLINT=0)    
RETURNS TABLE  
AS  
/*  
 Created: 20250424@Elodie  
 DB: DBCust/CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB
 Task: Get product setting detail for Live Casino  
 Original: f_CustSetting_ProductProfileCashSel  
   
 Revision:  
  - 20250424@Elodie: Init function [RedmineID: #223896]  
  
 Param's Explanation:  

 SELECT * FROM dbo.f_CustSetting_ProductProfileCashSel (NULL,3,487,0)  
*/  
RETURN
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType
	FROM dbo.ProductSettingProfile WITH(NOLOCK)
	WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1
								WHEN @SettingStatus = 0 THEN 0
								ELSE NULL END 
		AND SettingStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 0
		AND (OfferType IN (0,2) OR SettingType IN (25, 19, 3))
	UNION
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,p.ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType
	FROM dbo.ProductSettingProfile p WITH(NOLOCK)
		INNER JOIN ProductProfileSiteCurrency s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1
								WHEN @SettingStatus = 0 THEN 0
								ELSE NULL END 
		AND SettingStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 1
		AND s.SiteID = @SiteID
		AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END	
		AND OfferType IN (0,2)
		AND (OfferType IN (0,2) OR SettingType IN (25, 19, 3))
	UNION
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType
	FROM dbo.ProductSettingProfile_UAT WITH(NOLOCK)
	WHERE @SettingStatus = 3
		AND SettingStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 0
		AND (OfferType IN (0,2) OR SettingType IN (25, 19, 3))
	UNION 
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,p.ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,GroupID,GroupType,SubType
	FROM dbo.ProductSettingProfile_UAT p WITH(NOLOCK)
		INNER JOIN ProductProfileSiteCurrency_UAT s WITH(NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE @SettingStatus = 3
		AND SettingStatus <> 2
		AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND MarketType = 1
		AND s.SiteID = @SiteID
		AND 1 = CASE WHEN s.currency = @currency OR s.currency = 0 THEN 1 ELSE 0 END
		AND (OfferType IN (0,2) OR SettingType IN (25, 19, 3))
		
GO
   
    