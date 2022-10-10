/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[f_CustSetting_ProductOfferedSelect](@ProductID TINYINT, @SiteID INT, @Currency INT, @SettingType SMALLINT, @SettingStatus TINYINT) 
RETURNS TABLE
AS
/*
	Created by: Winfred
	Date: 20221006
	Task: Get setting hidden status of product
	DB: DBCust/CustDB
	Original: 
	
	Revisions:
		- 20221006@Winfred: Get setting hidden status of product [Redmine: #174744]
	Explanation's Param:
		@SettingStatus: 0: Pro, 1: UAT
		--@SportBetTypeSetting TABLE (ProductID TINYINT, SportType SMALLINT, Bettype SMALLINT, IsLive BIT)
		
*/ 
RETURN (SELECT DISTINCT p.ProductID, p.SportType, p.Bettype, p.IsLive , p.SettingType, p.RealProductId
		FROM dbo.ProductSettingDetail p WITH(NOLOCK)
		LEFT JOIN ProductStatusSiteCurrency ps WITH(NOLOCK) ON p.SportType = ps.SportType  AND p.BetType = Ps.BetType 
													AND ps.SiteID IN (0,@SiteID) AND ps.Currency IN (0,@Currency)
		WHERE (@ProductID IS NULL OR ProductID = @ProductID ) 
				AND p.SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
				AND (@SettingType IS NULL OR SettingType = @SettingType) 
				AND ((ps.SiteID IS NULL AND ps.Currency IS NULL ) OR  ps.IsHidden = 0))

