CREATE PROCEDURE [dbo].[Acc_CustSetting_SettingRestrictionSelect]  
AS  
/*  
	Created: 20160217@Dominic  
	Task: Get RestrictionMode
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  

	SELECT TOP 1 CASE WHEN RestrictionMode = 1 THEN 1 ELSE 0 END AS IsAllowed
	FROM dbo.ProductSettingUpdateRestriction WITH(NOLOCK)
	
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionSelect] TO [bodbExtAccNet]