/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_ProductProfileSelByGroupType
	(
	 @GroupType	    TINYINT = NULL
     , @SettingStatus TINYINT = 0
     , @siteid	    SMALLINT=0
     , @currency	    SMALLINT=0
	)
RETURNS TABLE
	AS
/*  
	Created: 20231017@Helios  
	DB: DBCust/CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB
	Task: Get product setting detail by GroupType  
	Original: f_CustSetting_ProductProfileSel  
		     
	Revision:  
	- 20230731@Helios: Init function [RedmineID: #189389]  
		    
	Param's Explanation:  
	SELECT * FROM dbo.f_CustSetting_ProductProfileSelByGroupType (NULL,3,487,0)  
*/
RETURN
	SELECT
		SettingType , SportType , bettype , isLive , ProductID , MaxPT , MaxDiscount , IsSync , IsHidden , IsDisabled , SettingLevel , DisplayOrder , SettingStatus , IntervalValue , RealProductId , MaxChoice , 
		ProductSettingID , Parent_ProductSettingID , Child_DisplayOrder , SubType , GroupID , GroupType
	FROM dbo.ProductSettingProfile WITH (NOLOCK)
	WHERE SettingStatus <= CASE
					WHEN @SettingStatus = 1 THEN 1
					WHEN @SettingStatus = 0 THEN 0
					ELSE NULL 
					END
	AND SettingStatus <> 2
	AND (@GroupType IS NULL OR GroupType = @GroupType)
	AND MarketType = 0

	UNION

	SELECT
		SettingType , SportType , bettype , isLive , ProductID , MaxPT , MaxDiscount , IsSync , IsHidden , IsDisabled , SettingLevel , DisplayOrder , SettingStatus , IntervalValue , RealProductId , MaxChoice , 
		p.ProductSettingID , Parent_ProductSettingID , Child_DisplayOrder , SubType , GroupID , GroupType
	FROM dbo.ProductSettingProfile p WITH (NOLOCK)
	INNER JOIN ProductProfileSiteCurrency s WITH (NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE SettingStatus <= CASE
						WHEN @SettingStatus = 1 THEN 1
						WHEN @SettingStatus = 0 THEN 0
						ELSE NULL 
					END
	AND SettingStatus <> 2
	AND (@GroupType IS NULL OR GroupType = @GroupType)
	AND MarketType = 1
	AND s.SiteID = @siteid
	AND 1 = CASE
				WHEN s.currency = @currency OR s.currency = 0 THEN 1
				ELSE 0
		END

	UNION

	SELECT
		SettingType , SportType , BetType , IsLive , ProductID , MaxPT , MaxDiscount , IsSync , IsHidden , IsDisabled , SettingLevel , DisplayOrder , SettingStatus , IntervalValue , RealProductId , MaxChoice , 
		ProductSettingID , Parent_ProductSettingID , Child_DisplayOrder , SubType , GroupID , GroupType
	FROM dbo.ProductSettingProfile_UAT WITH (NOLOCK)
	WHERE @SettingStatus = 3
	AND SettingStatus <> 2
	AND (@GroupType IS NULL OR GroupType = @GroupType)
	AND MarketType = 0

	UNION

	SELECT
		SettingType , SportType , BetType , IsLive , ProductID , MaxPT , MaxDiscount , IsSync , IsHidden , IsDisabled , SettingLevel , DisplayOrder , SettingStatus , IntervalValue , RealProductId , MaxChoice , 
		p.ProductSettingID , Parent_ProductSettingID, Child_DisplayOrder , SubType, GroupID, GroupType
	FROM dbo.ProductSettingProfile_UAT p WITH (NOLOCK)
	INNER JOIN ProductProfileSiteCurrency_UAT s WITH (NOLOCK) ON p.ProductSettingID = s.ProductSettingID
	WHERE @SettingStatus = 3
	AND SettingStatus <> 2
	AND (@GroupType IS NULL OR GroupType = @GroupType)
	AND MarketType = 1
	AND s.SiteID = @siteid
	AND 1 = CASE
				WHEN s.currency = @currency OR s.currency = 0 THEN 1
				ELSE 0
		END  
    